`timescale 1ns / 1ps

// Computes K(selected_message || ciphertext) after constant-time implicit
// rejection selection. The ciphertext RAM is replayed twice according to the
// public pseudohash schedule.
module trike_decaps_kdf #(
    parameter int M_BYTES               = 32,
    parameter int CIPHERTEXT_BYTES      = 3180,
    parameter bit RUNTIME_LENGTH        = 1'b0,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0,
    parameter int DATA_W                = 8 * M_BYTES,
    parameter int CT_ADDR_W             = ((CIPHERTEXT_BYTES > 1) ? $clog2(CIPHERTEXT_BYTES) : 1),
    parameter int SS_IDX_W              = ((M_BYTES > 1) ? $clog2(M_BYTES) : 1)
) (
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_start,
    input  logic [         31:0] i_runtime_ciphertext_bytes,
    input  logic [   DATA_W-1:0] i_selected_message,
    output logic                 o_ciphertext_re,
    output logic [CT_ADDR_W-1:0] o_ciphertext_raddr,
    input  logic [          7:0] i_ciphertext_rdata,
    output logic                 o_shared_secret_valid,
    output logic [ SS_IDX_W-1:0] o_shared_secret_index,
    output logic [          7:0] o_shared_secret_data,
    output logic                 o_shared_secret_last,
    input  logic                 i_shared_secret_ready,
    output logic                 o_busy,
    output logic                 o_done,
    output logic [        511:0] o_k_digest,
    output logic                 o_compress_start,
    output logic [        511:0] o_compress_block,
    output logic [        255:0] o_compress_state,
    input  logic                 i_compress_busy,
    input  logic                 i_compress_done,
    input  logic [        255:0] i_compress_state
);

  localparam int K_MESSAGE_BYTES = M_BYTES + CIPHERTEXT_BYTES;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_K_START,
    ST_K_RUN,
    ST_SS_OUTPUT
  } state_t;

  state_t                state_q;
  logic   [  DATA_W-1:0] selected_message_q;
  integer                k_input_count_q;
  logic   [SS_IDX_W-1:0] ss_count_q;
  logic                  k_input_ready;
  logic                  k_done;
  logic   [       511:0] k_digest;
  logic   [         7:0] k_input_data;
  integer                ciphertext_byte_c;
  logic                  unused_k_input_pass;
  logic                  unused_k_busy;
  integer                active_ciphertext_bytes_q;
  integer                active_k_message_bytes_q;

  function automatic logic [7:0] wide_byte(input  logic [DATA_W-1:0] value,
                                           input int unsigned byte_idx);
    begin
      wide_byte = value[8*byte_idx+:8];
    end
  endfunction

  function automatic logic [7:0] digest_byte(input  logic [511:0] value,
                                             input int unsigned byte_idx);
    begin
      digest_byte = value[511-8*byte_idx-:8];
    end
  endfunction

  assign ciphertext_byte_c = k_input_count_q - M_BYTES;
  assign o_shared_secret_valid = state_q == ST_SS_OUTPUT;
  assign o_shared_secret_index = ss_count_q;
  assign o_shared_secret_data = digest_byte(o_k_digest, int'(ss_count_q));
  assign o_shared_secret_last = ss_count_q == SS_IDX_W'(M_BYTES - 1);
  assign o_busy = state_q != ST_IDLE;

  always_comb begin
    k_input_data = i_ciphertext_rdata;
    if (k_input_count_q < M_BYTES) begin
      k_input_data = wide_byte(selected_message_q, k_input_count_q);
    end

    o_ciphertext_re = 1'b0;
    o_ciphertext_raddr = '0;
    if (state_q == ST_K_START) begin
      o_ciphertext_re = 1'b1;
    end else if ((state_q == ST_K_RUN) && k_input_ready && (k_input_count_q >= M_BYTES)) begin
      o_ciphertext_re = 1'b1;
      o_ciphertext_raddr = (ciphertext_byte_c == (active_ciphertext_bytes_q - 1)) ?
          '0 : CT_ADDR_W'(ciphertext_byte_c + 1);
    end
  end

  trike_pseudohash512_stream #(
      .MESSAGE_BYTES        (K_MESSAGE_BYTES),
      .RUNTIME_LENGTH       (RUNTIME_LENGTH),
      .USE_EXTERNAL_COMPRESS(USE_EXTERNAL_COMPRESS)
  ) u_k (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_start                (state_q == ST_K_START),
      .i_runtime_message_bytes(32'(active_k_message_bytes_q)),
      .i_input_valid          (state_q == ST_K_RUN),
      .i_input_data           (k_input_data),
      .o_input_ready          (k_input_ready),
      .o_input_pass           (unused_k_input_pass),
      .o_busy                 (unused_k_busy),
      .o_done                 (k_done),
      .o_digest               (k_digest),
      .o_compress_start       (o_compress_start),
      .o_compress_block       (o_compress_block),
      .o_compress_state       (o_compress_state),
      .i_compress_busy        (i_compress_busy),
      .i_compress_done        (i_compress_done),
      .i_compress_state       (i_compress_state)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      selected_message_q <= '0;
      k_input_count_q <= 0;
      ss_count_q <= '0;
      o_k_digest <= '0;
      active_ciphertext_bytes_q <= CIPHERTEXT_BYTES;
      active_k_message_bytes_q <= K_MESSAGE_BYTES;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            selected_message_q <= i_selected_message;
            k_input_count_q <= 0;
            ss_count_q <= '0;
            if (RUNTIME_LENGTH) begin
              active_ciphertext_bytes_q <= int'(i_runtime_ciphertext_bytes);
              active_k_message_bytes_q  <= M_BYTES + int'(i_runtime_ciphertext_bytes);
            end else begin
              active_ciphertext_bytes_q <= CIPHERTEXT_BYTES;
              active_k_message_bytes_q  <= K_MESSAGE_BYTES;
            end
            state_q <= ST_K_START;
          end
        end

        ST_K_START: state_q <= ST_K_RUN;

        ST_K_RUN: begin
          if (k_input_ready) begin
            k_input_count_q <=
                (k_input_count_q == (active_k_message_bytes_q - 1)) ? 0 : k_input_count_q + 1;
          end
          if (k_done) begin
            o_k_digest <= k_digest;
            ss_count_q <= '0;
            state_q <= ST_SS_OUTPUT;
          end
        end

        ST_SS_OUTPUT: begin
          if (i_shared_secret_ready) begin
            if (ss_count_q == SS_IDX_W'(M_BYTES - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              ss_count_q <= ss_count_q + 1'b1;
            end
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_LENGTH) begin
      if ((i_runtime_ciphertext_bytes < 1) || (i_runtime_ciphertext_bytes > CIPHERTEXT_BYTES))
        $fatal(1, "trike_decaps_kdf runtime ciphertext length out of range");
    end
  end
`endif

endmodule
