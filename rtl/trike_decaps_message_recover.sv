`timescale 1ns / 1ps

// Computes L(e') from the padded decoder error RAM, then emits
// m' = c2 xor L(e'). The error RAM is replayed twice using the public
// pseudohash pass schedule; error data never affects addresses or control.
module trike_decaps_message_recover #(
    parameter int M_BYTES               = 32,
    parameter int ERROR_BYTES           = 4800,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0,
    parameter int ERROR_ADDR_W          = ((ERROR_BYTES > 1) ? $clog2(ERROR_BYTES) : 1),
    parameter int MESSAGE_IDX_W         = ((M_BYTES > 1) ? $clog2(M_BYTES) : 1)
) (
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    input  logic                     i_start,
    input  logic                     i_c2_valid,
    input  logic [              7:0] i_c2_data,
    output logic                     o_c2_ready,
    output logic                     o_error_re,
    output logic [ ERROR_ADDR_W-1:0] o_error_raddr,
    input  logic [              7:0] i_error_rdata,
    output logic                     o_message_valid,
    output logic [MESSAGE_IDX_W-1:0] o_message_index,
    output logic [              7:0] o_message_data,
    output logic                     o_message_last,
    input  logic                     i_message_ready,
    output logic                     o_busy,
    output logic                     o_done,
    output logic [            511:0] o_l_digest,
    output logic                     o_compress_start,
    output logic [            511:0] o_compress_block,
    output logic [            255:0] o_compress_state,
    input  logic                     i_compress_busy,
    input  logic                     i_compress_done,
    input  logic [            255:0] i_compress_state
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_C2_LOAD,
    ST_L_START,
    ST_L_RUN,
    ST_MESSAGE_OUTPUT
  } state_t;

  state_t                     state_q;
  logic   [              7:0] c2_mem[0:M_BYTES-1];
  integer                     c2_count_q;
  integer                     l_input_count_q;
  logic   [MESSAGE_IDX_W-1:0] message_count_q;
  logic   [            511:0] l_digest;
  logic                       l_input_ready;
  logic                       l_done;
  logic                       unused_l_input_pass;
  logic                       unused_l_busy;

  function automatic logic [7:0] digest_byte(input  logic [511:0] value,
                                             input int unsigned byte_idx);
    begin
      digest_byte = value[511-8*byte_idx-:8];
    end
  endfunction

  assign o_c2_ready = state_q == ST_C2_LOAD;
  assign o_message_valid = state_q == ST_MESSAGE_OUTPUT;
  assign o_message_index = message_count_q;
  assign o_message_data = c2_mem[message_count_q] ^ digest_byte(o_l_digest, int'(message_count_q));
  assign o_message_last = message_count_q == MESSAGE_IDX_W'(M_BYTES - 1);
  assign o_busy = state_q != ST_IDLE;

  always_comb begin
    o_error_re = 1'b0;
    o_error_raddr = ERROR_ADDR_W'(l_input_count_q);
    if (state_q == ST_L_START) begin
      o_error_re = 1'b1;
      o_error_raddr = '0;
    end else if ((state_q == ST_L_RUN) && l_input_ready) begin
      o_error_re = 1'b1;
      o_error_raddr = (l_input_count_q == (ERROR_BYTES - 1)) ?
          '0 : ERROR_ADDR_W'(l_input_count_q + 1);
    end
  end

  trike_pseudohash512_stream #(
      .MESSAGE_BYTES        (ERROR_BYTES),
      .USE_EXTERNAL_COMPRESS(USE_EXTERNAL_COMPRESS)
  ) u_l (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (state_q == ST_L_START),
      .i_input_valid   (state_q == ST_L_RUN),
      .i_input_data    (i_error_rdata),
      .o_input_ready   (l_input_ready),
      .o_input_pass    (unused_l_input_pass),
      .o_busy          (unused_l_busy),
      .o_done          (l_done),
      .o_digest        (l_digest),
      .o_compress_start(o_compress_start),
      .o_compress_block(o_compress_block),
      .o_compress_state(o_compress_state),
      .i_compress_busy (i_compress_busy),
      .i_compress_done (i_compress_done),
      .i_compress_state(i_compress_state)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      c2_count_q <= 0;
      l_input_count_q <= 0;
      message_count_q <= '0;
      o_l_digest <= '0;
      o_done <= 1'b0;
      for (int idx = 0; idx < M_BYTES; idx++) c2_mem[idx] <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            c2_count_q <= 0;
            l_input_count_q <= 0;
            message_count_q <= '0;
            state_q <= ST_C2_LOAD;
          end
        end

        ST_C2_LOAD: begin
          if (i_c2_valid) begin
            c2_mem[c2_count_q] <= i_c2_data;
            if (c2_count_q == (M_BYTES - 1)) begin
              l_input_count_q <= 0;
              state_q <= ST_L_START;
            end else begin
              c2_count_q <= c2_count_q + 1;
            end
          end
        end

        ST_L_START: state_q <= ST_L_RUN;

        ST_L_RUN: begin
          if (l_input_ready) begin
            l_input_count_q <= (l_input_count_q == (ERROR_BYTES - 1)) ? 0 : l_input_count_q + 1;
          end
          if (l_done) begin
            o_l_digest <= l_digest;
            message_count_q <= '0;
            state_q <= ST_MESSAGE_OUTPUT;
          end
        end

        ST_MESSAGE_OUTPUT: begin
          if (i_message_ready) begin
            if (message_count_q == MESSAGE_IDX_W'(M_BYTES - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              message_count_q <= message_count_q + 1'b1;
            end
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  initial begin
    if ((M_BYTES <= 0) || (ERROR_BYTES <= 0))
      $fatal(1, "trike_decaps_message_recover requires positive message lengths");
  end

endmodule
