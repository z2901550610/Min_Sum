`timescale 1ns / 1ps

// Public-length streaming SM3 engine.
//
// INPUT_BYTES allocates the maximum public length. The input stream accepts
// one byte per valid/ready transfer. Padding and the 64-bit big-endian message
// length are generated internally.
module sm3_hash_stream #(
    parameter int INPUT_BYTES           = 32,
    parameter bit RUNTIME_LENGTH        = 1'b0,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0
) (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic [ 31:0] i_runtime_input_bytes,
    input  logic         i_input_valid,
    input  logic [  7:0] i_input_data,
    output logic         o_input_ready,
    output logic         o_busy,
    output logic         o_done,
    output logic [255:0] o_digest,
    output logic         o_compress_start,
    output logic [511:0] o_compress_block,
    output logic [255:0] o_compress_state,
    input  logic         i_compress_busy,
    input  logic         i_compress_done,
    input  logic [255:0] i_compress_state
);

  localparam logic [255:0] SM3_INITIAL_STATE = {
    32'h7380166f,
    32'h4914b2b9,
    32'h172442d7,
    32'hda8a0600,
    32'ha96f30bc,
    32'h163138aa,
    32'he38dee4d,
    32'hb0fb0e4e
  };
  localparam int INPUT_COUNT_W = (INPUT_BYTES > 1) ? $clog2(INPUT_BYTES) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_ABSORB,
    ST_COMPRESS_START,
    ST_COMPRESS_WAIT
  } state_t;

  typedef enum logic [1:0] {
    ACTION_CONTINUE,
    ACTION_FINAL,
    ACTION_SECOND_PADDING,
    ACTION_EMPTY_PADDING
  } action_t;

  state_t                      state_q;
  action_t                     action_q;

  logic    [            511:0] block_q;
  logic    [            255:0] chaining_state_q;
  logic    [INPUT_COUNT_W-1:0] input_count_q;
  logic    [              5:0] block_byte_idx_q;
  integer                      active_input_bytes_q;
  logic    [             63:0] message_bits_q;

  logic                        compress_start;
  logic                        compress_busy;
  logic                        compress_done;
  logic    [            255:0] compress_state;
  logic                        internal_compress_busy;
  logic                        internal_compress_done;
  logic    [            255:0] internal_compress_state;

  logic    [            511:0] block_with_input;

  function automatic logic [511:0] set_block_byte(
      input  logic [511:0] block_i, input  logic [5:0] byte_idx, input  logic [7:0] byte_value);
    logic [511:0] block_o;
    begin
      block_o = block_i;
      block_o[511-8*byte_idx-:8] = byte_value;
      set_block_byte = block_o;
    end
  endfunction

  function automatic logic [511:0] add_final_padding(input  logic [511:0] block_i,
                                                     input  logic [5:0] padding_byte_idx,
                                                     input  logic [63:0] message_bits);
    logic [511:0] block_o;
    begin
      block_o = set_block_byte(block_i, padding_byte_idx, 8'h80);
      block_o[63:0] = message_bits;
      add_final_padding = block_o;
    end
  endfunction

  function automatic logic [511:0] add_first_padding(input  logic [511:0] block_i,
                                                     input  logic [5:0] padding_byte_idx);
    begin
      add_first_padding = set_block_byte(block_i, padding_byte_idx, 8'h80);
    end
  endfunction

  function automatic logic [511:0] make_second_padding(input  logic [63:0] message_bits);
    logic [511:0] block_o;
    begin
      block_o             = '0;
      block_o[63:0]       = message_bits;
      make_second_padding = block_o;
    end
  endfunction

  function automatic logic [511:0] make_empty_padding(input  logic [63:0] message_bits);
    logic [511:0] block_o;
    begin
      block_o            = '0;
      block_o[511:504]   = 8'h80;
      block_o[63:0]      = message_bits;
      make_empty_padding = block_o;
    end
  endfunction

  assign o_input_ready = (state_q == ST_ABSORB);
  assign compress_start = (state_q == ST_COMPRESS_START) && !compress_busy;
  assign block_with_input = set_block_byte(block_q, block_byte_idx_q, i_input_data);
  assign compress_busy = USE_EXTERNAL_COMPRESS ? i_compress_busy : internal_compress_busy;
  assign compress_done = USE_EXTERNAL_COMPRESS ? i_compress_done : internal_compress_done;
  assign compress_state = USE_EXTERNAL_COMPRESS ? i_compress_state : internal_compress_state;
  assign o_compress_start = compress_start;
  assign o_compress_block = block_q;
  assign o_compress_state = chaining_state_q;

  generate
    if (!USE_EXTERNAL_COMPRESS) begin : g_internal_compress
      sm3_compress u_sm3_compress (
          .i_clk  (i_clk),
          .i_rst_n(i_rst_n),
          .i_start(compress_start),
          .i_block(block_q),
          .i_state(chaining_state_q),
          .o_busy (internal_compress_busy),
          .o_done (internal_compress_done),
          .o_state(internal_compress_state)
      );
    end else begin : g_external_compress
      assign internal_compress_busy  = 1'b0;
      assign internal_compress_done  = 1'b0;
      assign internal_compress_state = '0;
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q              <= ST_IDLE;
      action_q             <= ACTION_CONTINUE;
      block_q              <= '0;
      chaining_state_q     <= SM3_INITIAL_STATE;
      input_count_q        <= '0;
      block_byte_idx_q     <= '0;
      active_input_bytes_q <= INPUT_BYTES;
      message_bits_q       <= 64'(INPUT_BYTES) * 64'd8;
      o_busy               <= 1'b0;
      o_done               <= 1'b0;
      o_digest             <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            action_q         <= ACTION_CONTINUE;
            block_q          <= '0;
            chaining_state_q <= SM3_INITIAL_STATE;
            input_count_q    <= '0;
            block_byte_idx_q <= '0;
            if (RUNTIME_LENGTH) begin
              active_input_bytes_q <= int'(i_runtime_input_bytes);
              message_bits_q <= 64'(i_runtime_input_bytes) * 64'd8;
            end else begin
              active_input_bytes_q <= INPUT_BYTES;
              message_bits_q <= 64'(INPUT_BYTES) * 64'd8;
            end
            o_busy  <= 1'b1;
            state_q <= ST_ABSORB;
          end
        end

        ST_ABSORB: begin
          if (i_input_valid && o_input_ready) begin
            if (input_count_q == INPUT_COUNT_W'(active_input_bytes_q - 1)) begin
              if (block_byte_idx_q == 6'd63) begin
                block_q  <= block_with_input;
                action_q <= ACTION_EMPTY_PADDING;
              end else if (block_byte_idx_q <= 6'd54) begin
                block_q <= add_final_padding(
                    block_with_input, block_byte_idx_q + 1'b1, message_bits_q
                );
                action_q <= ACTION_FINAL;
              end else begin
                block_q  <= add_first_padding(block_with_input, block_byte_idx_q + 1'b1);
                action_q <= ACTION_SECOND_PADDING;
              end
              state_q <= ST_COMPRESS_START;
            end else begin
              input_count_q <= input_count_q + 1'b1;
              if (block_byte_idx_q == 6'd63) begin
                block_q  <= block_with_input;
                action_q <= ACTION_CONTINUE;
                state_q  <= ST_COMPRESS_START;
              end else begin
                block_q          <= block_with_input;
                block_byte_idx_q <= block_byte_idx_q + 1'b1;
              end
            end
          end
        end

        ST_COMPRESS_START: begin
          state_q <= ST_COMPRESS_WAIT;
        end

        ST_COMPRESS_WAIT: begin
          if (compress_done) begin
            unique case (action_q)
              ACTION_CONTINUE: begin
                block_q          <= '0;
                chaining_state_q <= compress_state;
                block_byte_idx_q <= '0;
                state_q          <= ST_ABSORB;
              end

              ACTION_SECOND_PADDING: begin
                block_q          <= make_second_padding(message_bits_q);
                chaining_state_q <= compress_state;
                action_q         <= ACTION_FINAL;
                state_q          <= ST_COMPRESS_START;
              end

              ACTION_EMPTY_PADDING: begin
                block_q          <= make_empty_padding(message_bits_q);
                chaining_state_q <= compress_state;
                action_q         <= ACTION_FINAL;
                state_q          <= ST_COMPRESS_START;
              end

              ACTION_FINAL: begin
                o_digest <= compress_state;
                o_busy   <= 1'b0;
                o_done   <= 1'b1;
                state_q  <= ST_IDLE;
              end

              default: begin
                o_busy  <= 1'b0;
                state_q <= ST_IDLE;
              end
            endcase
          end
        end

        default: begin
          o_busy  <= 1'b0;
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (INPUT_BYTES < 1) $error("sm3_hash_stream INPUT_BYTES must be at least 1");
  end

  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_LENGTH) begin
      if ((i_runtime_input_bytes < 1) || (i_runtime_input_bytes > INPUT_BYTES))
        $fatal(1, "sm3_hash_stream runtime length out of range");
    end
  end
`endif

endmodule
