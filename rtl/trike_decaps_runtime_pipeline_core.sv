`timescale 1ns / 1ps

// Runtime-profile Decaps transaction boundary around an external fixed-schedule
// decoder. Maximum-size input, ciphertext, and error memories are shared by all
// public profiles; active geometry is latched by the input loader at i_start.
// Decoder H validation state makes this a one-transaction-per-reset boundary.
module trike_decaps_runtime_pipeline_core #(
    parameter int WORD_W                = 64,
    parameter int DIGIT_W               = 16,
    parameter int BLOCKS                = 3,
    parameter int M_BYTES               = 32,
    parameter int MAX_R_BITS            = bike_pkg::P_R_VALS             [3],
    parameter int MAX_SECRET_WEIGHT     = bike_pkg::P_W_VALS             [3],
    parameter int MAX_ERROR_WEIGHT      = bike_pkg::P_T_VALS             [3],
    parameter int MAX_R_BYTES           = (MAX_R_BITS + 7) / 8,
    parameter int MAX_PADDED_R_BYTES    = ((MAX_R_BITS + 511) / 512) * 64,
    parameter int MAX_ERROR_BYTES       = BLOCKS * MAX_PADDED_R_BYTES,
    parameter int MAX_CT_BYTES          = (2 * MAX_R_BYTES) + M_BYTES,
    parameter int ROW_W                 = $clog2(MAX_R_BITS),
    parameter int COL_W                 = $clog2(BLOCKS * MAX_R_BITS),
    parameter int BLOCK_W               = $clog2(BLOCKS),
    parameter int DIAG_W                = $clog2(MAX_SECRET_WEIGHT),
    parameter int ERROR_ADDR_W          = $clog2(MAX_ERROR_BYTES),
    parameter int R_ADDR_W              = $clog2(MAX_R_BYTES),
    parameter int CT_ADDR_W             = $clog2(MAX_CT_BYTES),
    parameter int SS_IDX_W              = $clog2(M_BYTES),
    parameter int RESIDUAL_WEIGHT_W     = $clog2(MAX_R_BITS + 1),
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0,
    parameter bit USE_EXTERNAL_MUL      = 1'b0,
    parameter bit USE_EXTERNAL_SAMPLER  = 1'b0,
    parameter bit USE_EXTERNAL_H4_STORE = 1'b0
) (
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_start,
    input  logic [bike_pkg::PROFILE_ID_W-1:0] i_param_level,
    input  logic i_input_valid,
    input  logic [7:0] i_input_data,
    output logic o_input_ready,
    output logic o_decoder_h_we,
    output logic [BLOCK_W-1:0] o_decoder_h_block_idx,
    output logic [DIAG_W-1:0] o_decoder_h_diag_idx,
    output logic [ROW_W-1:0] o_decoder_h_index,
    input  logic i_decoder_h_loaded,
    input  logic i_decoder_h_error,
    output logic o_decoder_syndrome_we,
    output logic [ROW_W-1:0] o_decoder_syndrome_addr,
    output logic o_decoder_syndrome_data,
    output logic o_decoder_start,
    input  logic i_decoder_done,
    output logic [COL_W-1:0] o_decoder_decision_col,
    output logic [COL_W-1:0] o_decoder_decision_col_1,
    output logic o_decoder_decision_valid_1,
    input  logic i_decoder_decision_data,
    input  logic i_decoder_decision_data_1,
    output logic [bike_pkg::PROFILE_ID_W-1:0] o_param_level,
    output logic [31:0] o_r_bits,
    output logic [31:0] o_secret_weight,
    output logic [31:0] o_error_weight,
    output logic [31:0] o_r_bytes,
    output logic [31:0] o_padded_r_bytes,
    output logic [31:0] o_ciphertext_bytes,
    output logic [31:0] o_input_bytes,
    output logic o_residual_zero,
    output logic [RESIDUAL_WEIGHT_W-1:0] o_residual_weight,
    output logic o_ciphertext_equal,
    output logic o_shared_secret_valid,
    output logic [SS_IDX_W-1:0] o_shared_secret_index,
    output logic [7:0] o_shared_secret_data,
    output logic o_shared_secret_last,
    input  logic i_shared_secret_ready,
    output logic o_error,
    output logic o_busy,
    output logic o_done,
    output logic o_compress_start,
    output logic [511:0] o_compress_block,
    output logic [255:0] o_compress_state,
    input  logic i_compress_busy,
    input  logic i_compress_done,
    input  logic [255:0] i_compress_state,
    output logic o_mul_start,
    output logic [31:0] o_mul_runtime_r_bits,
    output logic [31:0] o_mul_runtime_words,
    output logic [31:0] o_mul_runtime_sparse_weight,
    output logic o_mul_sparse_a,
    output logic o_mul_a_valid,
    output logic [WORD_W-1:0] o_mul_a_data,
    input  logic i_mul_a_ready,
    output logic o_mul_sparse_index_valid,
    output logic [ROW_W-1:0] o_mul_sparse_index,
    input  logic i_mul_sparse_index_ready,
    output logic o_mul_b_valid,
    output logic [WORD_W-1:0] o_mul_b_data,
    input  logic i_mul_b_ready,
    input  logic i_mul_result_valid,
    input  logic [WORD_W-1:0] i_mul_result_data,
    input  logic i_mul_result_last,
    output logic o_mul_result_ready,
    output logic o_sampler_start,
    output logic [31:0] o_sampler_runtime_length,
    output logic [31:0] o_sampler_runtime_weight,
    output logic [439:0] o_sampler_v,
    output logic [439:0] o_sampler_c,
    output logic [439:0] o_sampler_reseed_counter,
    input  logic i_sampler_index_valid,
    input  logic [((MAX_ERROR_WEIGHT > 1) ? $clog2(
MAX_ERROR_WEIGHT
) : 1)-1:0] i_sampler_index_position,
    input  logic [(((3 * MAX_R_BITS) > 1) ? $clog2(3 * MAX_R_BITS) : 1)-1:0] i_sampler_index,
    output logic o_sampler_index_ready,
    input  logic i_sampler_done,
    input  logic [439:0] i_sampler_v,
    input  logic [439:0] i_sampler_c,
    input  logic [439:0] i_sampler_reseed_counter,
    output logic o_h4_store_start,
    output logic [31:0] o_h4_store_runtime_r_bits,
    output logic [31:0] o_h4_store_runtime_error_weight,
    output logic [31:0] o_h4_store_runtime_padded_r_bytes,
    output logic o_h4_store_index_valid,
    output logic [((MAX_ERROR_WEIGHT > 1) ? $clog2(
MAX_ERROR_WEIGHT
) : 1)-1:0] o_h4_store_index_position,
    output logic [(((3 * MAX_R_BITS) > 1) ? $clog2(3 * MAX_R_BITS) : 1)-1:0] o_h4_store_index,
    input  logic i_h4_store_index_ready,
    output logic o_h4_store_support_re,
    output logic [((MAX_ERROR_WEIGHT > 1) ? $clog2(
MAX_ERROR_WEIGHT
) : 1)-1:0] o_h4_store_support_raddr,
    input  logic [(((3 * MAX_R_BITS) > 1) ? $clog2(
3 * MAX_R_BITS
) : 1)-1:0] i_h4_store_support_rdata,
    output logic o_h4_store_error_re,
    output logic [((MAX_ERROR_BYTES > 1) ? $clog2(MAX_ERROR_BYTES) : 1)-1:0] o_h4_store_error_raddr,
    input  logic [7:0] i_h4_store_error_rdata,
    input  logic i_h4_store_done
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_INPUT_RUN,
    ST_POSTCHECK_START,
    ST_POSTCHECK_RUN,
    ST_POSTPROCESS_START,
    ST_POSTPROCESS_RUN
  } state_t;

  state_t                    state_q;
  logic                      transaction_complete_q;
  logic                      input_error;
  logic                      input_busy;
  logic                      input_done;
  logic   [            31:0] words;
  logic   [            31:0] support_count;
  logic   [            31:0] secret_key_bytes;
  logic   [            31:0] error_bytes;
  logic   [   8*M_BYTES-1:0] sigma2;
  logic                      postcheck_error_re;
  logic   [ERROR_ADDR_W-1:0] postcheck_error_raddr;
  logic   [             7:0] postcheck_error_rdata;
  logic                      postcheck_done;
  logic                      postcheck_busy;
  logic                      postprocess_r2_re;
  logic   [    R_ADDR_W-1:0] postprocess_r2_raddr;
  logic   [             7:0] input_r2_rdata;
  logic                      postprocess_ct_re;
  logic   [   CT_ADDR_W-1:0] postprocess_ct_raddr;
  logic                      input_ct_re;
  logic   [   CT_ADDR_W-1:0] input_ct_raddr;
  logic   [             7:0] input_ct_rdata;
  logic                      postprocess_c2_ready;
  logic                      postprocess_done;
  logic                      postprocess_busy;
  logic                      c2_fetch_request_c;
  logic                      c2_fetch_pending_q;
  logic                      c2_valid_q;
  logic   [             7:0] c2_data_q;
  integer                    c2_issue_count_q;

  assign o_busy = state_q != ST_IDLE;
  assign c2_fetch_request_c =
      ((state_q == ST_POSTCHECK_RUN) || (state_q == ST_POSTPROCESS_START) ||
       (state_q == ST_POSTPROCESS_RUN)) &&
      (c2_issue_count_q < M_BYTES) && !c2_fetch_pending_q && !c2_valid_q && !postprocess_ct_re;
  assign input_ct_re = c2_fetch_request_c || postprocess_ct_re;
  assign input_ct_raddr = c2_fetch_request_c ?
      CT_ADDR_W'((2 * int'(o_r_bytes)) + c2_issue_count_q) : postprocess_ct_raddr;

  trike_decaps_input_decoder_load_core #(
      .WORD_W           (WORD_W),
      .DIGIT_W          (DIGIT_W),
      .BLOCKS           (BLOCKS),
      .M_BYTES          (M_BYTES),
      .USE_EXTERNAL_MUL (USE_EXTERNAL_MUL),
      .MAX_R_BITS       (MAX_R_BITS),
      .MAX_SECRET_WEIGHT(MAX_SECRET_WEIGHT)
  ) u_input_decoder_load (
      .i_clk                      (i_clk),
      .i_rst_n                    (i_rst_n),
      .i_start                    ((state_q == ST_IDLE) && i_start && !transaction_complete_q),
      .i_param_level              (i_param_level),
      .i_input_valid              (i_input_valid),
      .i_input_data               (i_input_data),
      .o_input_ready              (o_input_ready),
      .o_h_we                     (o_decoder_h_we),
      .o_h_block_idx              (o_decoder_h_block_idx),
      .o_h_diag_idx               (o_decoder_h_diag_idx),
      .o_h_index                  (o_decoder_h_index),
      .i_h_loaded                 (i_decoder_h_loaded),
      .i_h_error                  (i_decoder_h_error),
      .o_syndrome_we              (o_decoder_syndrome_we),
      .o_syndrome_addr            (o_decoder_syndrome_addr),
      .o_syndrome_data            (o_decoder_syndrome_data),
      .o_decoder_start            (o_decoder_start),
      .i_decoder_done             (i_decoder_done),
      .i_r2_re                    (postprocess_r2_re),
      .i_r2_raddr                 (postprocess_r2_raddr),
      .o_r2_rdata                 (input_r2_rdata),
      .i_ciphertext_re            (input_ct_re),
      .i_ciphertext_raddr         (input_ct_raddr),
      .o_ciphertext_rdata         (input_ct_rdata),
      .o_sigma2                   (sigma2),
      .o_param_level              (o_param_level),
      .o_r_bits                   (o_r_bits),
      .o_secret_weight            (o_secret_weight),
      .o_error_weight             (o_error_weight),
      .o_r_bytes                  (o_r_bytes),
      .o_padded_r_bytes           (o_padded_r_bytes),
      .o_words                    (words),
      .o_support_count            (support_count),
      .o_secret_key_bytes         (secret_key_bytes),
      .o_ciphertext_bytes         (o_ciphertext_bytes),
      .o_input_bytes              (o_input_bytes),
      .o_error_bytes              (error_bytes),
      .o_error                    (input_error),
      .o_busy                     (input_busy),
      .o_done                     (input_done),
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

  trike_decaps_decoder_postcheck_core #(
      .R_BITS           (MAX_R_BITS),
      .BLOCKS           (BLOCKS),
      .WEIGHT           (MAX_SECRET_WEIGHT),
      .PADDED_R_BYTES   (MAX_PADDED_R_BYTES),
      .ROW_W            (ROW_W),
      .COL_W            (COL_W),
      .BLOCK_W          (BLOCK_W),
      .DIAG_W           (DIAG_W),
      .ERROR_ADDR_W     (ERROR_ADDR_W),
      .RESIDUAL_WEIGHT_W(RESIDUAL_WEIGHT_W)
  ) u_postcheck (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_h_we              (o_decoder_h_we),
      .i_h_block_idx       (o_decoder_h_block_idx),
      .i_h_diag_idx        (o_decoder_h_diag_idx),
      .i_h_index           (o_decoder_h_index),
      .i_syndrome_we       (o_decoder_syndrome_we),
      .i_syndrome_addr     (o_decoder_syndrome_addr),
      .i_syndrome_data     (o_decoder_syndrome_data),
      .i_start             (state_q == ST_POSTCHECK_START),
      .i_runtime_r_bits    (o_r_bits),
      .i_runtime_weight    (o_secret_weight),
      .o_decision_col_idx  (o_decoder_decision_col),
      .o_decision_col_idx_1(o_decoder_decision_col_1),
      .o_decision_valid_1  (o_decoder_decision_valid_1),
      .i_decision_data     (i_decoder_decision_data),
      .i_decision_data_1   (i_decoder_decision_data_1),
      .i_error_re          (postcheck_error_re),
      .i_error_raddr       (postcheck_error_raddr),
      .o_error_rdata       (postcheck_error_rdata),
      .o_residual_zero     (o_residual_zero),
      .o_residual_weight   (o_residual_weight),
      .o_busy              (postcheck_busy),
      .o_done              (postcheck_done)
  );

  trike_decaps_postprocess_core #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (MAX_R_BITS),
      .ERROR_WEIGHT         (MAX_ERROR_WEIGHT),
      .PADDED_R_BYTES       (MAX_PADDED_R_BYTES),
      .CIPHERTEXT_BYTES     (MAX_CT_BYTES),
      .RUNTIME_GEOMETRY     (1'b1),
      .USE_EXTERNAL_COMPRESS(USE_EXTERNAL_COMPRESS),
      .USE_EXTERNAL_SAMPLER (USE_EXTERNAL_SAMPLER),
      .USE_EXTERNAL_H4_STORE(USE_EXTERNAL_H4_STORE)
  ) u_postprocess (
      .i_clk                            (i_clk),
      .i_rst_n                          (i_rst_n),
      .i_start                          (state_q == ST_POSTPROCESS_START),
      .i_runtime_r_bits                 (o_r_bits),
      .i_runtime_error_weight           (o_error_weight),
      .i_runtime_r_bytes                (o_r_bytes),
      .i_runtime_padded_r_bytes         (o_padded_r_bytes),
      .i_runtime_error_bytes            (error_bytes),
      .i_runtime_ciphertext_bytes       (o_ciphertext_bytes),
      .i_decoder_ok                     (o_residual_zero),
      .i_sigma2                         (sigma2),
      .i_c2_valid                       (c2_valid_q && (state_q == ST_POSTPROCESS_RUN)),
      .i_c2_data                        (c2_data_q),
      .o_c2_ready                       (postprocess_c2_ready),
      .o_reference_re                   (postcheck_error_re),
      .o_reference_raddr                (postcheck_error_raddr),
      .i_reference_rdata                (postcheck_error_rdata),
      .o_r2_re                          (postprocess_r2_re),
      .o_r2_raddr                       (postprocess_r2_raddr),
      .i_r2_rdata                       (input_r2_rdata),
      .o_ciphertext_re                  (postprocess_ct_re),
      .o_ciphertext_raddr               (postprocess_ct_raddr),
      .i_ciphertext_rdata               (input_ct_rdata),
      .o_ciphertext_equal               (o_ciphertext_equal),
      .o_shared_secret_valid            (o_shared_secret_valid),
      .o_shared_secret_index            (o_shared_secret_index),
      .o_shared_secret_data             (o_shared_secret_data),
      .o_shared_secret_last             (o_shared_secret_last),
      .i_shared_secret_ready            (i_shared_secret_ready),
      .o_busy                           (postprocess_busy),
      .o_done                           (postprocess_done),
      .o_compress_start                 (o_compress_start),
      .o_compress_block                 (o_compress_block),
      .o_compress_state                 (o_compress_state),
      .i_compress_busy                  (i_compress_busy),
      .i_compress_done                  (i_compress_done),
      .i_compress_state                 (i_compress_state),
      .o_sampler_start                  (o_sampler_start),
      .o_sampler_runtime_length         (o_sampler_runtime_length),
      .o_sampler_runtime_weight         (o_sampler_runtime_weight),
      .o_sampler_v                      (o_sampler_v),
      .o_sampler_c                      (o_sampler_c),
      .o_sampler_reseed_counter         (o_sampler_reseed_counter),
      .i_sampler_index_valid            (i_sampler_index_valid),
      .i_sampler_index_position         (i_sampler_index_position),
      .i_sampler_index                  (i_sampler_index),
      .o_sampler_index_ready            (o_sampler_index_ready),
      .i_sampler_done                   (i_sampler_done),
      .i_sampler_v                      (i_sampler_v),
      .i_sampler_c                      (i_sampler_c),
      .i_sampler_reseed_counter         (i_sampler_reseed_counter),
      .o_h4_store_start                 (o_h4_store_start),
      .o_h4_store_runtime_r_bits        (o_h4_store_runtime_r_bits),
      .o_h4_store_runtime_error_weight  (o_h4_store_runtime_error_weight),
      .o_h4_store_runtime_padded_r_bytes(o_h4_store_runtime_padded_r_bytes),
      .o_h4_store_index_valid           (o_h4_store_index_valid),
      .o_h4_store_index_position        (o_h4_store_index_position),
      .o_h4_store_index                 (o_h4_store_index),
      .i_h4_store_index_ready           (i_h4_store_index_ready),
      .o_h4_store_support_re            (o_h4_store_support_re),
      .o_h4_store_support_raddr         (o_h4_store_support_raddr),
      .i_h4_store_support_rdata         (i_h4_store_support_rdata),
      .o_h4_store_error_re              (o_h4_store_error_re),
      .o_h4_store_error_raddr           (o_h4_store_error_raddr),
      .i_h4_store_error_rdata           (i_h4_store_error_rdata),
      .i_h4_store_done                  (i_h4_store_done)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      transaction_complete_q <= 1'b0;
      c2_fetch_pending_q <= 1'b0;
      c2_valid_q <= 1'b0;
      c2_data_q <= '0;
      c2_issue_count_q <= 0;
      o_error <= 1'b0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      if (c2_fetch_request_c) c2_fetch_pending_q <= 1'b1;
      if (c2_fetch_pending_q) begin
        c2_fetch_pending_q <= 1'b0;
        c2_valid_q <= 1'b1;
        c2_data_q <= input_ct_rdata;
      end
      if (c2_valid_q && postprocess_c2_ready && (state_q == ST_POSTPROCESS_RUN)) begin
        c2_valid_q <= 1'b0;
        c2_issue_count_q <= c2_issue_count_q + 1;
      end

      unique case (state_q)
        ST_IDLE: begin
          if (i_start && !transaction_complete_q) begin
            c2_fetch_pending_q <= 1'b0;
            c2_valid_q <= 1'b0;
            c2_issue_count_q <= 0;
            o_error <= 1'b0;
            state_q <= ST_INPUT_RUN;
          end
        end

        ST_INPUT_RUN: begin
          if (input_done) begin
            if (input_error) begin
              o_error <= 1'b1;
              o_done <= 1'b1;
              transaction_complete_q <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              state_q <= ST_POSTCHECK_START;
            end
          end
        end

        ST_POSTCHECK_START: state_q <= ST_POSTCHECK_RUN;

        ST_POSTCHECK_RUN: begin
          if (postcheck_done) state_q <= ST_POSTPROCESS_START;
        end

        ST_POSTPROCESS_START: state_q <= ST_POSTPROCESS_RUN;

        ST_POSTPROCESS_RUN: begin
          if (postprocess_done) begin
            o_done <= 1'b1;
            transaction_complete_q <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && postprocess_ct_re && c2_fetch_request_c)
      $fatal(1, "trike_decaps_runtime_pipeline_core ciphertext read collision");
    if (i_rst_n && postprocess_done && (c2_issue_count_q != M_BYTES))
      $fatal(1, "trike_decaps_runtime_pipeline_core incomplete c2 replay");
  end
`endif

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_descriptor;
  assign unused_descriptor =
      ^{words, support_count, secret_key_bytes, input_busy, postcheck_busy, postprocess_busy};
  /* verilator lint_on UNUSEDSIGNAL */

endmodule
