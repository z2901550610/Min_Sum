`timescale 1ns / 1ps

// Maximum-geometry Decaps input storage, shared support prefetch, runtime
// syndrome generation, and decoder load boundary. The first support block is
// broadcast to both H0 arithmetic and the complete-H sorter from one RAM read;
// the other two blocks feed only the sorter.
module trike_decaps_input_decoder_load_core #(
    parameter int WORD_W            = 64,
    parameter int DIGIT_W           = 16,
    parameter int BLOCKS            = 3,
    parameter int M_BYTES           = 32,
    parameter bit USE_EXTERNAL_MUL  = 1'b0,
    parameter int MAX_R_BITS        = bike_pkg::P_R_VALS                [3],
    parameter int MAX_SECRET_WEIGHT = bike_pkg::P_W_VALS                [3],
    parameter int MAX_R_BYTES       = (MAX_R_BITS + 7) / 8,
    parameter int MAX_WORDS         = (MAX_R_BITS + WORD_W - 1) / WORD_W,
    parameter int MAX_SUPPORT_COUNT = BLOCKS * MAX_SECRET_WEIGHT,
    parameter int MAX_CT_BYTES      = (2 * MAX_R_BYTES) + M_BYTES,
    parameter int SUPPORT_ADDR_W    = $clog2(MAX_SUPPORT_COUNT),
    parameter int ROW_ADDR_W        = $clog2(MAX_R_BITS),
    parameter int WORD_ADDR_W       = $clog2(MAX_WORDS),
    parameter int BLOCK_W           = $clog2(BLOCKS),
    parameter int DIAG_W            = $clog2(MAX_SECRET_WEIGHT),
    parameter int R_ADDR_W          = $clog2(MAX_R_BYTES),
    parameter int CT_ADDR_W         = $clog2(MAX_CT_BYTES)
) (
    input  logic                              i_clk,
    input  logic                              i_rst_n,
    input  logic                              i_start,
    input  logic [bike_pkg::PROFILE_ID_W-1:0] i_param_level,
    input  logic                              i_input_valid,
    input  logic [                       7:0] i_input_data,
    output logic                              o_input_ready,
    output logic                              o_h_we,
    output logic [               BLOCK_W-1:0] o_h_block_idx,
    output logic [                DIAG_W-1:0] o_h_diag_idx,
    output logic [            ROW_ADDR_W-1:0] o_h_index,
    input  logic                              i_h_loaded,
    input  logic                              i_h_error,
    output logic                              o_syndrome_we,
    output logic [            ROW_ADDR_W-1:0] o_syndrome_addr,
    output logic                              o_syndrome_data,
    output logic                              o_decoder_start,
    input  logic                              i_decoder_done,
    input  logic                              i_r2_re,
    input  logic [              R_ADDR_W-1:0] i_r2_raddr,
    output logic [                       7:0] o_r2_rdata,
    input  logic                              i_ciphertext_re,
    input  logic [             CT_ADDR_W-1:0] i_ciphertext_raddr,
    output logic [                       7:0] o_ciphertext_rdata,
    output logic [             8*M_BYTES-1:0] o_sigma2,
    output logic [bike_pkg::PROFILE_ID_W-1:0] o_param_level,
    output logic [                      31:0] o_r_bits,
    output logic [                      31:0] o_secret_weight,
    output logic [                      31:0] o_error_weight,
    output logic [                      31:0] o_r_bytes,
    output logic [                      31:0] o_padded_r_bytes,
    output logic [                      31:0] o_words,
    output logic [                      31:0] o_support_count,
    output logic [                      31:0] o_secret_key_bytes,
    output logic [                      31:0] o_ciphertext_bytes,
    output logic [                      31:0] o_input_bytes,
    output logic [                      31:0] o_error_bytes,
    output logic                              o_error,
    output logic                              o_busy,
    output logic                              o_done,
    output logic                              o_mul_start,
    output logic [                      31:0] o_mul_runtime_r_bits,
    output logic [                      31:0] o_mul_runtime_words,
    output logic [                      31:0] o_mul_runtime_sparse_weight,
    output logic                              o_mul_sparse_a,
    output logic                              o_mul_a_valid,
    output logic [                WORD_W-1:0] o_mul_a_data,
    input  logic                              i_mul_a_ready,
    output logic                              o_mul_sparse_index_valid,
    output logic [            ROW_ADDR_W-1:0] o_mul_sparse_index,
    input  logic                              i_mul_sparse_index_ready,
    output logic                              o_mul_b_valid,
    output logic [                WORD_W-1:0] o_mul_b_data,
    input  logic                              i_mul_b_ready,
    input  logic                              i_mul_result_valid,
    input  logic [                WORD_W-1:0] i_mul_result_data,
    input  logic                              i_mul_result_last,
    output logic                              o_mul_result_ready
);

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_LOAD,
    ST_START,
    ST_RUN
  } state_t;

  state_t                      state_q;
  logic                        store_start;
  logic                        store_busy;
  logic                        store_done;
  logic                        run_start;
  logic                        support_re;
  logic   [SUPPORT_ADDR_W-1:0] support_raddr;
  logic   [    ROW_ADDR_W-1:0] support_rdata;
  logic                        t0_re;
  logic   [   WORD_ADDR_W-1:0] t0_raddr;
  logic   [        WORD_W-1:0] t0_rdata;
  logic                        u_re;
  logic   [   WORD_ADDR_W-1:0] u_raddr;
  logic   [        WORD_W-1:0] u_rdata;
  logic                        v_re;
  logic   [   WORD_ADDR_W-1:0] v_raddr;
  logic   [        WORD_W-1:0] v_rdata;
  logic                        h_valid;
  logic   [    ROW_ADDR_W-1:0] h_index;
  logic                        h_ready;
  logic                        h0_valid;
  logic   [    ROW_ADDR_W-1:0] h0_index;
  logic                        h0_ready;
  logic                        support_busy;
  logic                        support_done;
  logic                        syndrome_valid;
  logic   [        WORD_W-1:0] syndrome_data;
  logic                        syndrome_ready;
  logic                        syndrome_busy;
  logic                        syndrome_done;
  logic                        adapter_busy;
  logic                        adapter_done;
  logic                        unused_syndrome_support_re;
  logic   [SUPPORT_ADDR_W-1:0] unused_syndrome_support_raddr;
  logic                        unused_syndrome_last;

  assign store_start = (state_q == ST_IDLE) && i_start;
  assign run_start = state_q == ST_START;
  assign o_busy = state_q != ST_IDLE;

  trike_decaps_input_store #(
      .WORD_W           (WORD_W),
      .M_BYTES          (M_BYTES),
      .MAX_R_BITS       (MAX_R_BITS),
      .MAX_SECRET_WEIGHT(MAX_SECRET_WEIGHT),
      .MAX_R_BYTES      (MAX_R_BYTES),
      .MAX_WORDS        (MAX_WORDS),
      .MAX_SUPPORT_COUNT(MAX_SUPPORT_COUNT),
      .MAX_CT_BYTES     (MAX_CT_BYTES),
      .SUPPORT_ADDR_W   (SUPPORT_ADDR_W),
      .ROW_ADDR_W       (ROW_ADDR_W),
      .WORD_ADDR_W      (WORD_ADDR_W),
      .R_ADDR_W         (R_ADDR_W),
      .CT_ADDR_W        (CT_ADDR_W)
  ) u_input_store (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (store_start),
      .i_param_level     (i_param_level),
      .i_valid           (i_input_valid),
      .i_data            (i_input_data),
      .o_ready           (o_input_ready),
      .i_support_re      (support_re),
      .i_support_raddr   (support_raddr),
      .o_support_rdata   (support_rdata),
      .i_t0_re           (t0_re),
      .i_t0_raddr        (t0_raddr),
      .o_t0_rdata        (t0_rdata),
      .i_r2_re           (i_r2_re),
      .i_r2_raddr        (i_r2_raddr),
      .o_r2_rdata        (o_r2_rdata),
      .i_u_re            (u_re),
      .i_u_raddr         (u_raddr),
      .o_u_rdata         (u_rdata),
      .i_v_re            (v_re),
      .i_v_raddr         (v_raddr),
      .o_v_rdata         (v_rdata),
      .i_ciphertext_re   (i_ciphertext_re),
      .i_ciphertext_raddr(i_ciphertext_raddr),
      .o_ciphertext_rdata(o_ciphertext_rdata),
      .o_sigma2          (o_sigma2),
      .o_param_level     (o_param_level),
      .o_r_bits          (o_r_bits),
      .o_secret_weight   (o_secret_weight),
      .o_error_weight    (o_error_weight),
      .o_r_bytes         (o_r_bytes),
      .o_padded_r_bytes  (o_padded_r_bytes),
      .o_words           (o_words),
      .o_support_count   (o_support_count),
      .o_secret_key_bytes(o_secret_key_bytes),
      .o_ciphertext_bytes(o_ciphertext_bytes),
      .o_input_bytes     (o_input_bytes),
      .o_error_bytes     (o_error_bytes),
      .o_busy            (store_busy),
      .o_done            (store_done)
  );

  trike_decaps_support_prefetch #(
      .BLOCKS           (BLOCKS),
      .MAX_SECRET_WEIGHT(MAX_SECRET_WEIGHT),
      .SUPPORT_ADDR_W   (SUPPORT_ADDR_W),
      .INDEX_W          (ROW_ADDR_W)
  ) u_support_prefetch (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_start        (run_start),
      .i_secret_weight(o_secret_weight),
      .o_support_re   (support_re),
      .o_support_raddr(support_raddr),
      .i_support_rdata(support_rdata),
      .o_h_valid      (h_valid),
      .o_h_index      (h_index),
      .i_h_ready      (h_ready),
      .o_h0_valid     (h0_valid),
      .o_h0_index     (h0_index),
      .i_h0_ready     (h0_ready),
      .o_busy         (support_busy),
      .o_done         (support_done)
  );

  trike_decaps_syndrome_store_core #(
      .WORD_W           (WORD_W),
      .DIGIT_W          (DIGIT_W),
      .MAX_R_BITS       (MAX_R_BITS),
      .MAX_SECRET_WEIGHT(MAX_SECRET_WEIGHT),
      .EXTERNAL_H0      (1'b1),
      .USE_EXTERNAL_MUL (USE_EXTERNAL_MUL),
      .SUPPORT_ADDR_W   (SUPPORT_ADDR_W),
      .WORD_ADDR_W      (WORD_ADDR_W),
      .INDEX_W          (ROW_ADDR_W)
  ) u_syndrome_store (
      .i_clk                      (i_clk),
      .i_rst_n                    (i_rst_n),
      .i_start                    (run_start),
      .i_r_bits                   (o_r_bits),
      .i_secret_weight            (o_secret_weight),
      .i_words                    (o_words),
      .o_support_re               (unused_syndrome_support_re),
      .o_support_raddr            (unused_syndrome_support_raddr),
      .i_support_rdata            ('0),
      .o_t0_re                    (t0_re),
      .o_t0_raddr                 (t0_raddr),
      .i_t0_rdata                 (t0_rdata),
      .o_u_re                     (u_re),
      .o_u_raddr                  (u_raddr),
      .i_u_rdata                  (u_rdata),
      .o_v_re                     (v_re),
      .o_v_raddr                  (v_raddr),
      .i_v_rdata                  (v_rdata),
      .i_h0_valid                 (h0_valid),
      .i_h0_index                 (h0_index),
      .o_h0_ready                 (h0_ready),
      .o_syndrome_valid           (syndrome_valid),
      .o_syndrome_data            (syndrome_data),
      .o_syndrome_last            (unused_syndrome_last),
      .i_syndrome_ready           (syndrome_ready),
      .o_busy                     (syndrome_busy),
      .o_done                     (syndrome_done),
      .o_mul_start                (o_mul_start),
      .o_mul_runtime_r_bits       (o_mul_runtime_r_bits),
      .o_mul_runtime_words        (o_mul_runtime_words),
      .o_mul_runtime_sparse_weight(o_mul_runtime_sparse_weight),
      .o_mul_sparse_a             (o_mul_sparse_a),
      .o_mul_a_valid              (o_mul_a_valid),
      .o_mul_a_data               (o_mul_a_data),
      .i_mul_a_ready              (i_mul_a_ready),
      .o_mul_sparse_index_valid   (o_mul_sparse_index_valid),
      .o_mul_sparse_index         (o_mul_sparse_index),
      .i_mul_sparse_index_ready   (i_mul_sparse_index_ready),
      .o_mul_b_valid              (o_mul_b_valid),
      .o_mul_b_data               (o_mul_b_data),
      .i_mul_b_ready              (i_mul_b_ready),
      .i_mul_result_valid         (i_mul_result_valid),
      .i_mul_result_data          (i_mul_result_data),
      .i_mul_result_last          (i_mul_result_last),
      .o_mul_result_ready         (o_mul_result_ready)
  );

  trike_decoder_load_adapter #(
      .R_BITS          (MAX_R_BITS),
      .BLOCKS          (BLOCKS),
      .WEIGHT          (MAX_SECRET_WEIGHT),
      .WORD_W          (WORD_W),
      .RUNTIME_GEOMETRY(1'b1),
      .ROW_W           (ROW_ADDR_W),
      .BLOCK_W         (BLOCK_W),
      .DIAG_W          (DIAG_W)
  ) u_adapter (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (run_start),
      .i_runtime_r_bits  (o_r_bits),
      .i_runtime_weight  (o_secret_weight),
      .i_h_valid         (h_valid),
      .i_h_index         (h_index),
      .o_h_ready         (h_ready),
      .o_h_we            (o_h_we),
      .o_h_block_idx     (o_h_block_idx),
      .o_h_diag_idx_local(o_h_diag_idx),
      .o_h_base_row_idx  (o_h_index),
      .i_h_loaded        (i_h_loaded),
      .i_h_error         (i_h_error),
      .i_syndrome_valid  (syndrome_valid),
      .i_syndrome_data   (syndrome_data),
      .o_syndrome_ready  (syndrome_ready),
      .o_syndrome_we     (o_syndrome_we),
      .o_syndrome_addr   (o_syndrome_addr),
      .o_syndrome_wdata  (o_syndrome_data),
      .o_decoder_start   (o_decoder_start),
      .i_decoder_done    (i_decoder_done),
      .o_error           (o_error),
      .o_busy            (adapter_busy),
      .o_done            (adapter_done)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      o_done  <= 1'b0;
    end else begin
      o_done <= 1'b0;
      unique case (state_q)
        ST_IDLE:  if (i_start) state_q <= ST_LOAD;
        ST_LOAD:  if (store_done) state_q <= ST_START;
        ST_START: state_q <= ST_RUN;
        ST_RUN: begin
          if (adapter_done) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end
        end
        default:  state_q <= ST_IDLE;
      endcase
    end
  end

  /* verilator lint_off UNUSED */
  logic unused_submodule_status;
  always_comb begin
    unused_submodule_status = store_busy ^ support_busy ^ support_done ^ syndrome_busy ^ syndrome_done ^
        adapter_busy ^ unused_syndrome_support_re ^ (^unused_syndrome_support_raddr) ^
        unused_syndrome_last;
  end
  /* verilator lint_on UNUSED */

endmodule
