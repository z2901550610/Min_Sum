`timescale 1ns / 1ps

// ICCS SM3 derivation function with a fixed public input length.
//
// The input stream is consumed twice. o_input_pass identifies the requested
// pass so that an upstream seed memory can replay the same bytes without this
// module buffering a parameter-dependent message.
module sm3_df_stream #(
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
    output logic         o_input_pass,
    output logic         o_busy,
    output logic         o_done,
    output logic [439:0] o_seed,
    output logic         o_compress_start,
    output logic [511:0] o_compress_block,
    output logic [255:0] o_compress_state,
    input  logic         i_compress_busy,
    input  logic         i_compress_done,
    input  logic [255:0] i_compress_state
);

  localparam int INPUT_COUNT_W = (INPUT_BYTES > 1) ? $clog2(INPUT_BYTES) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_HASH_START,
    ST_PREFIX,
    ST_INPUT,
    ST_HASH_WAIT
  } state_t;

  state_t                     state_q;

  logic                       pass_q;
  logic   [              2:0] prefix_idx_q;
  logic   [INPUT_COUNT_W-1:0] input_count_q;
  logic   [            255:0] first_digest_q;
  integer                     active_input_bytes_q;

  logic                       hash_start;
  logic                       hash_input_valid;
  logic   [              7:0] hash_input_data;
  logic                       hash_input_ready;
  logic                       hash_done;
  logic   [            255:0] hash_digest;

  function automatic logic [7:0] prefix_byte(input  logic pass, input  logic [2:0] byte_idx);
    begin
      unique case (byte_idx)
        3'd0: prefix_byte = pass ? 8'h02 : 8'h01;
        3'd1: prefix_byte = 8'h00;
        3'd2: prefix_byte = 8'h00;
        3'd3: prefix_byte = 8'h01;
        default: prefix_byte = 8'hb8;
      endcase
    end
  endfunction

  assign o_input_ready = (state_q == ST_INPUT) && hash_input_ready;
  assign o_input_pass = pass_q;

  assign hash_start = (state_q == ST_HASH_START);
  assign hash_input_valid = (state_q == ST_PREFIX) || ((state_q == ST_INPUT) && i_input_valid);
  assign hash_input_data = (state_q == ST_PREFIX) ? prefix_byte(
      pass_q, prefix_idx_q
  ) : i_input_data;

  sm3_hash_stream #(
      .INPUT_BYTES          (INPUT_BYTES + 5),
      .RUNTIME_LENGTH       (RUNTIME_LENGTH),
      .USE_EXTERNAL_COMPRESS(USE_EXTERNAL_COMPRESS)
  ) u_hash (
      .i_clk                (i_clk),
      .i_rst_n              (i_rst_n),
      .i_start              (hash_start),
      .i_runtime_input_bytes(32'(active_input_bytes_q + 5)),
      .i_input_valid        (hash_input_valid),
      .i_input_data         (hash_input_data),
      .o_input_ready        (hash_input_ready),
      .o_busy               (),
      .o_done               (hash_done),
      .o_digest             (hash_digest),
      .o_compress_start     (o_compress_start),
      .o_compress_block     (o_compress_block),
      .o_compress_state     (o_compress_state),
      .i_compress_busy      (i_compress_busy),
      .i_compress_done      (i_compress_done),
      .i_compress_state     (i_compress_state)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q              <= ST_IDLE;
      pass_q               <= 1'b0;
      prefix_idx_q         <= '0;
      input_count_q        <= '0;
      first_digest_q       <= '0;
      active_input_bytes_q <= INPUT_BYTES;
      o_busy               <= 1'b0;
      o_done               <= 1'b0;
      o_seed               <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            pass_q        <= 1'b0;
            prefix_idx_q  <= '0;
            input_count_q <= '0;
            if (RUNTIME_LENGTH) active_input_bytes_q <= int'(i_runtime_input_bytes);
            else active_input_bytes_q <= INPUT_BYTES;
            o_busy  <= 1'b1;
            state_q <= ST_HASH_START;
          end
        end

        ST_HASH_START: begin
          prefix_idx_q <= '0;
          state_q      <= ST_PREFIX;
        end

        ST_PREFIX: begin
          if (hash_input_valid && hash_input_ready) begin
            if (prefix_idx_q == 3'd4) begin
              input_count_q <= '0;
              state_q       <= ST_INPUT;
            end else begin
              prefix_idx_q <= prefix_idx_q + 1'b1;
            end
          end
        end

        ST_INPUT: begin
          if (i_input_valid && o_input_ready) begin
            if (input_count_q == INPUT_COUNT_W'(active_input_bytes_q - 1)) begin
              state_q <= ST_HASH_WAIT;
            end else begin
              input_count_q <= input_count_q + 1'b1;
            end
          end
        end

        ST_HASH_WAIT: begin
          if (hash_done) begin
            if (!pass_q) begin
              first_digest_q <= hash_digest;
              pass_q         <= 1'b1;
              state_q        <= ST_HASH_START;
            end else begin
              o_seed  <= {first_digest_q, hash_digest[255:72]};
              o_busy  <= 1'b0;
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end
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
    if (INPUT_BYTES < 1) $error("sm3_df_stream INPUT_BYTES must be at least 1");
  end

  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_LENGTH) begin
      if ((i_runtime_input_bytes < 1) || (i_runtime_input_bytes > INPUT_BYTES))
        $fatal(1, "sm3_df_stream runtime length out of range");
    end
  end
`endif

endmodule
