`timescale 1ns / 1ps

// Fixed-schedule TRIKE Encaps controller.
//
// Input byte order is the serialized public key followed by the message:
//   r2 || sigma || m.
// Ciphertext output order is:
//   u || v || c2.
//
// The cryptographic stages execute in a public, parameter-dependent order and
// share one SM3 compressor. Input and output backpressure can extend the outer
// transaction, but neither data values nor sampled error positions change the
// internal stage schedule or RAM access count.
module trike_encaps_core #(
    parameter int M_BYTES = 32,
    parameter int R_BITS = 15581,
    parameter int ERROR_WEIGHT = 263,
    parameter int WORD_W = 64,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0,
    parameter int PADDED_R_BYTES = ((R_BITS + 511) / 512) * 64,
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic         i_input_valid,
    input  logic [  7:0] i_input_data,
    output logic         o_input_ready,
    output logic         o_ciphertext_valid,
    output logic [  7:0] o_ciphertext_data,
    output logic         o_ciphertext_last,
    input  logic         i_ciphertext_ready,
    output logic         o_shared_secret_valid,
    output logic [  7:0] o_shared_secret_data,
    output logic         o_shared_secret_last,
    input  logic         i_shared_secret_ready,
    output logic         o_busy,
    output logic         o_done,
    output logic         o_compress_start,
    output logic [511:0] o_compress_block,
    output logic [255:0] o_compress_state,
    input  logic         i_compress_busy,
    input  logic         i_compress_done,
    input  logic [255:0] i_compress_state
);

  localparam int R_BYTES = (R_BITS + 7) / 8;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int INPUT_BYTES = R_BYTES + (2 * M_BYTES);
  localparam int ERROR_BYTES = 3 * PADDED_R_BYTES;
  localparam int CIPHERTEXT_BYTES = (2 * R_BYTES) + M_BYTES;
  localparam int K_MESSAGE_BYTES = M_BYTES + CIPHERTEXT_BYTES;
  localparam int SUPPORT_ADDR_W = (ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1;
  localparam int GLOBAL_INDEX_W = ((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1;
  localparam int ERROR_ADDR_W = (ERROR_BYTES > 1) ? $clog2(ERROR_BYTES) : 1;
  localparam int VECTOR_BYTE_W = (R_BYTES > 1) ? $clog2(R_BYTES) : 1;

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_LOAD,
    ST_H123_START,
    ST_H123_RUN,
    ST_H4_START,
    ST_H4_RUN,
    ST_UV_START,
    ST_UV_RUN,
    ST_L_START,
    ST_L_RUN,
    ST_C2_FILL,
    ST_K_START,
    ST_K_RUN,
    ST_CT_PREFETCH,
    ST_CT_OUTPUT,
    ST_SS_OUTPUT
  } state_t;

  state_t                      state_q;
  integer                      load_count_q;
  integer                      h123_seed_count_q;
  integer                      h4_seed_count_q;
  integer                      uv_support_count_q;
  integer                      uv_u_word_count_q;
  integer                      uv_v_word_count_q;
  integer                      l_input_count_q;
  integer                      c2_fill_count_q;
  integer                      k_input_count_q;
  integer                      ciphertext_count_q;
  integer                      shared_secret_count_q;
  logic   [        WORD_W-1:0] r2_pack_q;
  logic   [        WORD_W-1:0] vector_pack_q;
  logic                        uv_support_loaded_q;
  logic                        uv_operand_loaded_q;
  logic   [             511:0] l_digest_q;
  logic   [             511:0] k_digest_q;

  logic   [               7:0] sigma_mem[0:M_BYTES-1];
  logic   [               7:0] message_mem[0:M_BYTES-1];
  logic   [               7:0] c2_mem[0:M_BYTES-1];

  logic                        r2_we;
  logic   [   WORD_ADDR_W-1:0] r2_waddr;
  logic   [        WORD_W-1:0] r2_wdata;
  logic                        r2_re;
  logic   [   WORD_ADDR_W-1:0] r2_raddr;
  logic   [        WORD_W-1:0] r2_rdata;
  logic                        t1_we;
  logic   [   WORD_ADDR_W-1:0] t1_waddr;
  logic   [        WORD_W-1:0] t1_wdata;
  logic                        t1_re;
  logic   [   WORD_ADDR_W-1:0] t1_raddr;
  logic   [        WORD_W-1:0] t1_rdata;
  logic                        t2_we;
  logic   [   WORD_ADDR_W-1:0] t2_waddr;
  logic   [        WORD_W-1:0] t2_wdata;
  logic                        t2_re;
  logic   [   WORD_ADDR_W-1:0] t2_raddr;
  logic   [        WORD_W-1:0] t2_rdata;
  logic                        r1_we;
  logic   [   WORD_ADDR_W-1:0] r1_waddr;
  logic   [        WORD_W-1:0] r1_wdata;
  logic                        r1_re;
  logic   [   WORD_ADDR_W-1:0] r1_raddr;
  logic   [        WORD_W-1:0] r1_rdata;
  logic                        u_we;
  logic   [   WORD_ADDR_W-1:0] u_waddr;
  logic   [        WORD_W-1:0] u_wdata;
  logic                        u_re;
  logic   [   WORD_ADDR_W-1:0] u_raddr;
  logic   [        WORD_W-1:0] u_rdata;
  logic                        v_we;
  logic   [   WORD_ADDR_W-1:0] v_waddr;
  logic   [        WORD_W-1:0] v_wdata;
  logic                        v_re;
  logic   [   WORD_ADDR_W-1:0] v_raddr;
  logic   [        WORD_W-1:0] v_rdata;

  logic                        h123_start;
  logic                        h123_seed_valid;
  logic   [               7:0] h123_seed_data;
  logic                        h123_seed_ready;
  logic                        h123_vector_valid;
  logic   [               1:0] h123_vector_select;
  logic   [ VECTOR_BYTE_W-1:0] h123_vector_byte;
  logic   [               7:0] h123_vector_data;
  logic                        h123_done;
  logic                        h123_compress_start;
  logic   [             511:0] h123_compress_block;
  logic   [             255:0] h123_compress_state;

  logic                        h4_start;
  logic                        h4_seed_valid;
  logic   [               7:0] h4_seed_data;
  logic                        h4_seed_ready;
  logic                        h4_support_re;
  logic   [SUPPORT_ADDR_W-1:0] h4_support_raddr;
  logic   [GLOBAL_INDEX_W-1:0] h4_support_rdata;
  logic                        h4_error_re;
  logic   [  ERROR_ADDR_W-1:0] h4_error_raddr;
  logic   [               7:0] h4_error_rdata;
  logic                        h4_done;
  logic                        h4_compress_start;
  logic   [             511:0] h4_compress_block;
  logic   [             255:0] h4_compress_state;

  logic                        uv_start;
  logic                        uv_error_valid;
  logic   [SUPPORT_ADDR_W-1:0] uv_error_position;
  logic   [GLOBAL_INDEX_W-1:0] uv_error_index;
  logic                        uv_error_ready;
  logic   [               1:0] uv_operand_select;
  logic   [   WORD_ADDR_W-1:0] uv_operand_word;
  logic                        uv_operand_valid;
  logic   [        WORD_W-1:0] uv_operand_data;
  logic                        uv_operand_ready;
  logic                        uv_result_valid;
  logic                        uv_result_select;
  logic   [        WORD_W-1:0] uv_result_data;
  logic                        uv_result_ready;
  logic                        uv_done;

  logic                        l_start;
  logic                        l_input_valid;
  logic   [               7:0] l_input_data;
  logic                        l_input_ready;
  logic                        l_done;
  logic   [             511:0] l_digest;
  logic                        l_compress_start;
  logic   [             511:0] l_compress_block;
  logic   [             255:0] l_compress_state;

  logic                        k_start;
  logic                        k_input_valid;
  logic   [               7:0] k_input_data;
  logic                        k_input_ready;
  logic                        k_done;
  logic   [             511:0] k_digest;
  logic                        k_compress_start;
  logic   [             511:0] k_compress_block;
  logic   [             255:0] k_compress_state;

  logic                        shared_compress_start;
  logic   [             511:0] shared_compress_block;
  logic   [             255:0] shared_compress_input_state;
  logic                        shared_compress_busy;
  logic                        shared_compress_done;
  logic   [             255:0] shared_compress_output_state;

  logic   [        WORD_W-1:0] r2_write_word_c;
  logic   [        WORD_W-1:0] vector_write_word_c;
  integer                      h4_r2_byte_c;
  integer                      k_u_byte_c;
  integer                      k_v_byte_c;
  integer                      ct_u_byte_c;
  integer                      ct_v_byte_c;

  function automatic logic [7:0] digest_byte(input  logic [511:0] value, input integer byte_idx);
    begin
      digest_byte = value[511-8*byte_idx-:8];
    end
  endfunction

  function automatic logic [7:0] word_byte(input  logic [WORD_W-1:0] value, input integer byte_idx);
    begin
      word_byte = value[8*byte_idx+:8];
    end
  endfunction

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_r2_mem (
      .i_clk  (i_clk),
      .i_we   (r2_we),
      .i_waddr(r2_waddr),
      .i_wdata(r2_wdata),
      .i_re   (r2_re),
      .i_raddr(r2_raddr),
      .o_rdata(r2_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t1_mem (
      .i_clk  (i_clk),
      .i_we   (t1_we),
      .i_waddr(t1_waddr),
      .i_wdata(t1_wdata),
      .i_re   (t1_re),
      .i_raddr(t1_raddr),
      .o_rdata(t1_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t2_mem (
      .i_clk  (i_clk),
      .i_we   (t2_we),
      .i_waddr(t2_waddr),
      .i_wdata(t2_wdata),
      .i_re   (t2_re),
      .i_raddr(t2_raddr),
      .o_rdata(t2_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_r1_mem (
      .i_clk  (i_clk),
      .i_we   (r1_we),
      .i_waddr(r1_waddr),
      .i_wdata(r1_wdata),
      .i_re   (r1_re),
      .i_raddr(r1_raddr),
      .o_rdata(r1_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_u_mem (
      .i_clk  (i_clk),
      .i_we   (u_we),
      .i_waddr(u_waddr),
      .i_wdata(u_wdata),
      .i_re   (u_re),
      .i_raddr(u_raddr),
      .o_rdata(u_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_v_mem (
      .i_clk  (i_clk),
      .i_we   (v_we),
      .i_waddr(v_waddr),
      .i_wdata(v_wdata),
      .i_re   (v_re),
      .i_raddr(v_raddr),
      .o_rdata(v_rdata)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  trike_h123_vectors #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (R_BITS),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_h123 (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (h123_start),
      .i_seed_valid    (h123_seed_valid),
      .i_seed_data     (h123_seed_data),
      .o_seed_ready    (h123_seed_ready),
      .o_seed_pass     (),
      .o_vector_valid  (h123_vector_valid),
      .o_vector_select (h123_vector_select),
      .o_vector_byte   (h123_vector_byte),
      .o_vector_data   (h123_vector_data),
      .i_vector_ready  (state_q == ST_H123_RUN),
      .o_busy          (),
      .o_done          (h123_done),
      .o_v             (),
      .o_c             (),
      .o_reseed_counter(),
      .o_compress_start(h123_compress_start),
      .o_compress_block(h123_compress_block),
      .o_compress_state(h123_compress_state),
      .i_compress_busy (shared_compress_busy),
      .i_compress_done (shared_compress_done),
      .i_compress_state(shared_compress_output_state)
  );

  trike_h4_error_vector #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (R_BITS),
      .ERROR_WEIGHT         (ERROR_WEIGHT),
      .PADDED_R_BYTES       (PADDED_R_BYTES),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_h4 (
      .i_clk                   (i_clk),
      .i_rst_n                 (i_rst_n),
      .i_start                 (h4_start),
      .i_runtime_r_bits        ('0),
      .i_runtime_error_weight  ('0),
      .i_runtime_padded_r_bytes('0),
      .i_seed_valid            (h4_seed_valid),
      .i_seed_data             (h4_seed_data),
      .o_seed_ready            (h4_seed_ready),
      .o_seed_pass             (),
      .i_support_re            (h4_support_re),
      .i_support_raddr         (h4_support_raddr),
      .o_support_rdata         (h4_support_rdata),
      .i_error_re              (h4_error_re),
      .i_error_raddr           (h4_error_raddr),
      .o_error_rdata           (h4_error_rdata),
      .o_busy                  (),
      .o_done                  (h4_done),
      .o_v                     (),
      .o_c                     (),
      .o_reseed_counter        (),
      .o_compress_start        (h4_compress_start),
      .o_compress_block        (h4_compress_block),
      .o_compress_state        (h4_compress_state),
      .i_compress_busy         (shared_compress_busy),
      .i_compress_done         (shared_compress_done),
      .i_compress_state        (shared_compress_output_state)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  trike_encaps_uv_core #(
      .R_BITS      (R_BITS),
      .WORD_W      (WORD_W),
      .ERROR_WEIGHT(ERROR_WEIGHT),
      .WORD_ADDR_W (WORD_ADDR_W)
  ) u_uv (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (uv_start),
      .i_error_valid   (uv_error_valid),
      .i_error_position(uv_error_position),
      .i_error_index   (uv_error_index),
      .o_error_ready   (uv_error_ready),
      .o_operand_select(uv_operand_select),
      .o_operand_word  (uv_operand_word),
      .i_operand_valid (uv_operand_valid),
      .i_operand_data  (uv_operand_data),
      .o_operand_ready (uv_operand_ready),
      .o_result_valid  (uv_result_valid),
      .o_result_select (uv_result_select),
      .o_result_data   (uv_result_data),
      .o_result_last   (),
      .i_result_ready  (uv_result_ready),
      .o_busy          (),
      .o_done          (uv_done)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  trike_pseudohash512_stream #(
      .MESSAGE_BYTES        (ERROR_BYTES),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_l (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_start                (l_start),
      .i_runtime_message_bytes('0),
      .i_input_valid          (l_input_valid),
      .i_input_data           (l_input_data),
      .o_input_ready          (l_input_ready),
      .o_input_pass           (),
      .o_busy                 (),
      .o_done                 (l_done),
      .o_digest               (l_digest),
      .o_compress_start       (l_compress_start),
      .o_compress_block       (l_compress_block),
      .o_compress_state       (l_compress_state),
      .i_compress_busy        (shared_compress_busy),
      .i_compress_done        (shared_compress_done),
      .i_compress_state       (shared_compress_output_state)
  );

  trike_pseudohash512_stream #(
      .MESSAGE_BYTES        (K_MESSAGE_BYTES),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_k (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_start                (k_start),
      .i_runtime_message_bytes('0),
      .i_input_valid          (k_input_valid),
      .i_input_data           (k_input_data),
      .o_input_ready          (k_input_ready),
      .o_input_pass           (),
      .o_busy                 (),
      .o_done                 (k_done),
      .o_digest               (k_digest),
      .o_compress_start       (k_compress_start),
      .o_compress_block       (k_compress_block),
      .o_compress_state       (k_compress_state),
      .i_compress_busy        (shared_compress_busy),
      .i_compress_done        (shared_compress_done),
      .i_compress_state       (shared_compress_output_state)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  assign o_compress_start = shared_compress_start;
  assign o_compress_block = shared_compress_block;
  assign o_compress_state = shared_compress_input_state;

  generate
    if (USE_EXTERNAL_COMPRESS) begin : gen_external_compress
      assign shared_compress_busy = i_compress_busy;
      assign shared_compress_done = i_compress_done;
      assign shared_compress_output_state = i_compress_state;
    end else begin : gen_local_compress
      trike_sm3_service u_sm3_service (
          .i_clk  (i_clk),
          .i_rst_n(i_rst_n),
          .i_start(shared_compress_start),
          .i_block(shared_compress_block),
          .i_state(shared_compress_input_state),
          .o_busy (shared_compress_busy),
          .o_done (shared_compress_done),
          .o_state(shared_compress_output_state)
      );
    end
  endgenerate

  always_comb begin
    r2_write_word_c = r2_pack_q;
    if (load_count_q < R_BYTES) begin
      r2_write_word_c[8*(load_count_q%(WORD_W/8))+:8] = i_input_data;
    end

    vector_write_word_c = vector_pack_q;
    vector_write_word_c[8*(int'(h123_vector_byte)%(WORD_W/8))+:8] = h123_vector_data;

    h4_r2_byte_c = h4_seed_count_q - M_BYTES;
    k_u_byte_c = k_input_count_q - M_BYTES;
    k_v_byte_c = k_input_count_q - M_BYTES - R_BYTES;
    ct_u_byte_c = ciphertext_count_q;
    ct_v_byte_c = ciphertext_count_q - R_BYTES;
  end

  always_comb begin
    o_input_ready = state_q == ST_LOAD;
    o_ciphertext_valid = state_q == ST_CT_OUTPUT;
    o_ciphertext_data = '0;
    o_ciphertext_last = ciphertext_count_q == (CIPHERTEXT_BYTES - 1);
    o_shared_secret_valid = state_q == ST_SS_OUTPUT;
    o_shared_secret_data = digest_byte(k_digest_q, shared_secret_count_q);
    o_shared_secret_last = shared_secret_count_q == (M_BYTES - 1);
    o_busy = state_q != ST_IDLE;

    r2_we = 1'b0;
    r2_waddr = '0;
    r2_wdata = r2_write_word_c;
    r2_re = 1'b0;
    r2_raddr = '0;
    t1_we = 1'b0;
    t1_waddr = '0;
    t1_wdata = vector_write_word_c;
    t1_re = 1'b0;
    t1_raddr = '0;
    t2_we = 1'b0;
    t2_waddr = '0;
    t2_wdata = vector_write_word_c;
    t2_re = 1'b0;
    t2_raddr = '0;
    r1_we = 1'b0;
    r1_waddr = '0;
    r1_wdata = vector_write_word_c;
    r1_re = 1'b0;
    r1_raddr = '0;
    u_we = 1'b0;
    u_waddr = '0;
    u_wdata = uv_result_data;
    u_re = 1'b0;
    u_raddr = '0;
    v_we = 1'b0;
    v_waddr = '0;
    v_wdata = uv_result_data;
    v_re = 1'b0;
    v_raddr = '0;

    h123_start = state_q == ST_H123_START;
    h123_seed_valid = state_q == ST_H123_RUN;
    h123_seed_data = sigma_mem[h123_seed_count_q];
    h4_start = state_q == ST_H4_START;
    h4_seed_valid = state_q == ST_H4_RUN;
    h4_seed_data = (h4_seed_count_q < M_BYTES) ? message_mem[h4_seed_count_q] :
        word_byte(r2_rdata, h4_r2_byte_c % (WORD_W / 8));
    h4_support_re = 1'b0;
    h4_support_raddr = SUPPORT_ADDR_W'(uv_support_count_q);
    h4_error_re = 1'b0;
    h4_error_raddr = ERROR_ADDR_W'(l_input_count_q);

    uv_start = state_q == ST_UV_START;
    uv_error_valid = (state_q == ST_UV_RUN) && uv_support_loaded_q;
    uv_error_position = SUPPORT_ADDR_W'(uv_support_count_q);
    uv_error_index = h4_support_rdata;
    uv_operand_valid = (state_q == ST_UV_RUN) && uv_operand_loaded_q;
    unique case (uv_operand_select)
      2'd0: uv_operand_data = r1_rdata;
      2'd1: uv_operand_data = r2_rdata;
      2'd2: uv_operand_data = t1_rdata;
      default: uv_operand_data = t2_rdata;
    endcase
    uv_result_ready = state_q == ST_UV_RUN;

    l_start = state_q == ST_L_START;
    l_input_valid = state_q == ST_L_RUN;
    l_input_data = h4_error_rdata;
    k_start = state_q == ST_K_START;
    k_input_valid = state_q == ST_K_RUN;
    k_input_data = '0;
    if (k_input_count_q < M_BYTES) begin
      k_input_data = message_mem[k_input_count_q];
    end else if (k_input_count_q < (M_BYTES + R_BYTES)) begin
      k_input_data = word_byte(u_rdata, k_u_byte_c % (WORD_W / 8));
    end else if (k_input_count_q < (M_BYTES + (2 * R_BYTES))) begin
      k_input_data = word_byte(v_rdata, k_v_byte_c % (WORD_W / 8));
    end else begin
      k_input_data = c2_mem[k_input_count_q-M_BYTES-(2*R_BYTES)];
    end

    shared_compress_start = 1'b0;
    shared_compress_block = '0;
    shared_compress_input_state = '0;
    if ((state_q == ST_H123_START) || (state_q == ST_H123_RUN)) begin
      shared_compress_start = h123_compress_start;
      shared_compress_block = h123_compress_block;
      shared_compress_input_state = h123_compress_state;
    end else if ((state_q == ST_H4_START) || (state_q == ST_H4_RUN)) begin
      shared_compress_start = h4_compress_start;
      shared_compress_block = h4_compress_block;
      shared_compress_input_state = h4_compress_state;
    end else if ((state_q == ST_L_START) || (state_q == ST_L_RUN)) begin
      shared_compress_start = l_compress_start;
      shared_compress_block = l_compress_block;
      shared_compress_input_state = l_compress_state;
    end else if ((state_q == ST_K_START) || (state_q == ST_K_RUN)) begin
      shared_compress_start = k_compress_start;
      shared_compress_block = k_compress_block;
      shared_compress_input_state = k_compress_state;
    end

    if ((state_q == ST_LOAD) && i_input_valid && o_input_ready &&
        (load_count_q < R_BYTES) &&
        (((load_count_q % (WORD_W / 8)) == ((WORD_W / 8) - 1)) ||
         (load_count_q == (R_BYTES - 1)))) begin
      r2_we = 1'b1;
      r2_waddr = WORD_ADDR_W'(load_count_q / (WORD_W / 8));
    end

    if ((state_q == ST_H123_RUN) && h123_vector_valid) begin
      if (((int'(h123_vector_byte) % (WORD_W / 8)) == ((WORD_W / 8) - 1)) ||
          (int'(h123_vector_byte) == (R_BYTES - 1))) begin
        unique case (h123_vector_select)
          2'd0: begin
            t1_we = 1'b1;
            t1_waddr = WORD_ADDR_W'(int'(h123_vector_byte) / (WORD_W / 8));
          end
          2'd1: begin
            t2_we = 1'b1;
            t2_waddr = WORD_ADDR_W'(int'(h123_vector_byte) / (WORD_W / 8));
          end
          default: begin
            r1_we = 1'b1;
            r1_waddr = WORD_ADDR_W'(int'(h123_vector_byte) / (WORD_W / 8));
          end
        endcase
      end
    end

    if ((state_q == ST_H4_RUN) && h4_seed_valid && h4_seed_ready) begin
      if (h4_seed_count_q == (M_BYTES - 1)) begin
        r2_re = 1'b1;
        r2_raddr = '0;
      end else if ((h4_seed_count_q >= M_BYTES) &&
                   ((h4_r2_byte_c % (WORD_W / 8)) == ((WORD_W / 8) - 1)) &&
                   (h4_r2_byte_c != (R_BYTES - 1))) begin
        r2_re = 1'b1;
        r2_raddr = WORD_ADDR_W'((h4_r2_byte_c / (WORD_W / 8)) + 1);
      end
    end

    if (state_q == ST_UV_START) begin
      h4_support_re = 1'b1;
      h4_support_raddr = '0;
    end else if ((state_q == ST_UV_RUN) && uv_error_valid && uv_error_ready &&
                 (uv_support_count_q != (ERROR_WEIGHT - 1))) begin
      h4_support_re = 1'b1;
      h4_support_raddr = SUPPORT_ADDR_W'(uv_support_count_q + 1);
    end

    if ((state_q == ST_UV_RUN) && uv_operand_ready &&
        (!uv_operand_loaded_q || (uv_operand_word != WORD_ADDR_W'(WORDS - 1)))) begin
      unique case (uv_operand_select)
        2'd0: begin
          r1_re = 1'b1;
          r1_raddr = uv_operand_loaded_q ? WORD_ADDR_W'(int'(uv_operand_word) + 1) :
              uv_operand_word;
        end
        2'd1: begin
          r2_re = 1'b1;
          r2_raddr = uv_operand_loaded_q ? WORD_ADDR_W'(int'(uv_operand_word) + 1) :
              uv_operand_word;
        end
        2'd2: begin
          t1_re = 1'b1;
          t1_raddr = uv_operand_loaded_q ? WORD_ADDR_W'(int'(uv_operand_word) + 1) :
              uv_operand_word;
        end
        default: begin
          t2_re = 1'b1;
          t2_raddr = uv_operand_loaded_q ? WORD_ADDR_W'(int'(uv_operand_word) + 1) :
              uv_operand_word;
        end
      endcase
    end

    if ((state_q == ST_UV_RUN) && uv_result_valid && uv_result_ready) begin
      if (uv_result_select) begin
        v_we = 1'b1;
        v_waddr = WORD_ADDR_W'(uv_v_word_count_q);
      end else begin
        u_we = 1'b1;
        u_waddr = WORD_ADDR_W'(uv_u_word_count_q);
      end
    end

    if (state_q == ST_L_START) begin
      h4_error_re = 1'b1;
      h4_error_raddr = '0;
    end else if ((state_q == ST_L_RUN) && l_input_valid && l_input_ready) begin
      h4_error_re = 1'b1;
      h4_error_raddr = (l_input_count_q == (ERROR_BYTES - 1)) ? '0 :
          ERROR_ADDR_W'(l_input_count_q + 1);
    end

    if ((state_q == ST_K_RUN) && k_input_valid && k_input_ready) begin
      if (k_input_count_q == (M_BYTES - 1)) begin
        u_re = 1'b1;
        u_raddr = '0;
      end else if ((k_input_count_q >= M_BYTES) &&
                   (k_input_count_q < (M_BYTES + R_BYTES - 1)) &&
                   ((k_u_byte_c % (WORD_W / 8)) == ((WORD_W / 8) - 1))) begin
        u_re = 1'b1;
        u_raddr = WORD_ADDR_W'((k_u_byte_c / (WORD_W / 8)) + 1);
      end else if (k_input_count_q == (M_BYTES + R_BYTES - 1)) begin
        v_re = 1'b1;
        v_raddr = '0;
      end else if ((k_input_count_q >= (M_BYTES + R_BYTES)) &&
                   (k_input_count_q < (M_BYTES + (2 * R_BYTES) - 1)) &&
                   ((k_v_byte_c % (WORD_W / 8)) == ((WORD_W / 8) - 1))) begin
        v_re = 1'b1;
        v_raddr = WORD_ADDR_W'((k_v_byte_c / (WORD_W / 8)) + 1);
      end
    end

    if (state_q == ST_CT_PREFETCH) begin
      u_re = 1'b1;
      u_raddr = '0;
    end else if ((state_q == ST_CT_OUTPUT) && o_ciphertext_valid && i_ciphertext_ready) begin
      if ((ciphertext_count_q < (R_BYTES - 1)) &&
          ((ct_u_byte_c % (WORD_W / 8)) == ((WORD_W / 8) - 1))) begin
        u_re = 1'b1;
        u_raddr = WORD_ADDR_W'((ct_u_byte_c / (WORD_W / 8)) + 1);
      end else if (ciphertext_count_q == (R_BYTES - 1)) begin
        v_re = 1'b1;
        v_raddr = '0;
      end else if ((ciphertext_count_q >= R_BYTES) &&
                   (ciphertext_count_q < ((2 * R_BYTES) - 1)) &&
                   ((ct_v_byte_c % (WORD_W / 8)) == ((WORD_W / 8) - 1))) begin
        v_re = 1'b1;
        v_raddr = WORD_ADDR_W'((ct_v_byte_c / (WORD_W / 8)) + 1);
      end
    end

    if (ciphertext_count_q < R_BYTES) begin
      o_ciphertext_data = word_byte(u_rdata, ct_u_byte_c % (WORD_W / 8));
    end else if (ciphertext_count_q < (2 * R_BYTES)) begin
      o_ciphertext_data = word_byte(v_rdata, ct_v_byte_c % (WORD_W / 8));
    end else begin
      o_ciphertext_data = c2_mem[ciphertext_count_q-(2*R_BYTES)];
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      load_count_q <= 0;
      h123_seed_count_q <= 0;
      h4_seed_count_q <= 0;
      uv_support_count_q <= 0;
      uv_u_word_count_q <= 0;
      uv_v_word_count_q <= 0;
      l_input_count_q <= 0;
      c2_fill_count_q <= 0;
      k_input_count_q <= 0;
      ciphertext_count_q <= 0;
      shared_secret_count_q <= 0;
      r2_pack_q <= '0;
      vector_pack_q <= '0;
      uv_support_loaded_q <= 1'b0;
      uv_operand_loaded_q <= 1'b0;
      l_digest_q <= '0;
      k_digest_q <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            load_count_q <= 0;
            r2_pack_q <= '0;
            state_q <= ST_LOAD;
          end
        end

        ST_LOAD: begin
          if (i_input_valid && o_input_ready) begin
            if (load_count_q < R_BYTES) begin
              if (((load_count_q % (WORD_W / 8)) == ((WORD_W / 8) - 1)) ||
                  (load_count_q == (R_BYTES - 1))) begin
                r2_pack_q <= '0;
              end else begin
                r2_pack_q <= r2_write_word_c;
              end
            end else if (load_count_q < (R_BYTES + M_BYTES)) begin
              sigma_mem[load_count_q-R_BYTES] <= i_input_data;
            end else begin
              message_mem[load_count_q-R_BYTES-M_BYTES] <= i_input_data;
            end

            if (load_count_q == (INPUT_BYTES - 1)) begin
              h123_seed_count_q <= 0;
              vector_pack_q <= '0;
              state_q <= ST_H123_START;
            end else begin
              load_count_q <= load_count_q + 1;
            end
          end
        end

        ST_H123_START: begin
          state_q <= ST_H123_RUN;
        end

        ST_H123_RUN: begin
          if (h123_seed_valid && h123_seed_ready) begin
            h123_seed_count_q <= (h123_seed_count_q == (M_BYTES - 1)) ? 0 : h123_seed_count_q + 1;
          end
          if (h123_vector_valid) begin
            if (((int'(h123_vector_byte) % (WORD_W / 8)) == ((WORD_W / 8) - 1)) ||
                (int'(h123_vector_byte) == (R_BYTES - 1))) begin
              vector_pack_q <= '0;
            end else begin
              vector_pack_q <= vector_write_word_c;
            end
          end
          if (h123_done) begin
            h4_seed_count_q <= 0;
            state_q <= ST_H4_START;
          end
        end

        ST_H4_START: begin
          state_q <= ST_H4_RUN;
        end

        ST_H4_RUN: begin
          if (h4_seed_valid && h4_seed_ready) begin
            h4_seed_count_q <= (h4_seed_count_q == (M_BYTES + R_BYTES - 1)) ? 0 :
                h4_seed_count_q + 1;
          end
          if (h4_done) begin
            uv_support_count_q <= 0;
            uv_u_word_count_q <= 0;
            uv_v_word_count_q <= 0;
            uv_support_loaded_q <= 1'b0;
            uv_operand_loaded_q <= 1'b0;
            state_q <= ST_UV_START;
          end
        end

        ST_UV_START: begin
          uv_support_loaded_q <= 1'b1;
          state_q <= ST_UV_RUN;
        end

        ST_UV_RUN: begin
          if (uv_error_valid && uv_error_ready) begin
            if (uv_support_count_q == (ERROR_WEIGHT - 1)) begin
              uv_support_loaded_q <= 1'b0;
            end else begin
              uv_support_count_q <= uv_support_count_q + 1;
            end
          end

          if (uv_operand_ready) begin
            if (!uv_operand_loaded_q) begin
              uv_operand_loaded_q <= 1'b1;
            end else if (uv_operand_word == WORD_ADDR_W'(WORDS - 1)) begin
              uv_operand_loaded_q <= 1'b0;
            end
          end

          if (uv_result_valid && uv_result_ready) begin
            if (uv_result_select) begin
              uv_v_word_count_q <= uv_v_word_count_q + 1;
            end else begin
              uv_u_word_count_q <= uv_u_word_count_q + 1;
            end
          end

          if (uv_done) begin
            l_input_count_q <= 0;
            state_q <= ST_L_START;
          end
        end

        ST_L_START: begin
          state_q <= ST_L_RUN;
        end

        ST_L_RUN: begin
          if (l_input_valid && l_input_ready) begin
            l_input_count_q <= (l_input_count_q == (ERROR_BYTES - 1)) ? 0 : l_input_count_q + 1;
          end
          if (l_done) begin
            l_digest_q <= l_digest;
            c2_fill_count_q <= 0;
            state_q <= ST_C2_FILL;
          end
        end

        ST_C2_FILL: begin
          c2_mem[c2_fill_count_q] <= message_mem[c2_fill_count_q] ^ digest_byte(
              l_digest_q, c2_fill_count_q
          );
          if (c2_fill_count_q == (M_BYTES - 1)) begin
            k_input_count_q <= 0;
            state_q <= ST_K_START;
          end else begin
            c2_fill_count_q <= c2_fill_count_q + 1;
          end
        end

        ST_K_START: begin
          state_q <= ST_K_RUN;
        end

        ST_K_RUN: begin
          if (k_input_valid && k_input_ready) begin
            k_input_count_q <= (k_input_count_q == (K_MESSAGE_BYTES - 1)) ? 0 : k_input_count_q + 1;
          end
          if (k_done) begin
            k_digest_q <= k_digest;
            ciphertext_count_q <= 0;
            state_q <= ST_CT_PREFETCH;
          end
        end

        ST_CT_PREFETCH: begin
          state_q <= ST_CT_OUTPUT;
        end

        ST_CT_OUTPUT: begin
          if (o_ciphertext_valid && i_ciphertext_ready) begin
            if (ciphertext_count_q == (CIPHERTEXT_BYTES - 1)) begin
              shared_secret_count_q <= 0;
              state_q <= ST_SS_OUTPUT;
            end else begin
              ciphertext_count_q <= ciphertext_count_q + 1;
            end
          end
        end

        ST_SS_OUTPUT: begin
          if (o_shared_secret_valid && i_shared_secret_ready) begin
            if (shared_secret_count_q == (M_BYTES - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              shared_secret_count_q <= shared_secret_count_q + 1;
            end
          end
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if ((WORD_W % 8) != 0) $error("trike_encaps_core WORD_W must be divisible by 8");
    if (WORD_ADDR_W != ((WORDS > 1) ? $clog2(WORDS) : 1)) begin
      $error("trike_encaps_core WORD_ADDR_W must match WORDS");
    end
    if ((M_BYTES < 1) || (M_BYTES > 64)) begin
      $error("trike_encaps_core M_BYTES must be in [1,64]");
    end
  end
`endif

endmodule
