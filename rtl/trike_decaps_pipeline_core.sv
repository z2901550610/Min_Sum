`timescale 1ns / 1ps

// Complete fixed-schedule TRIKE Min-Sum Decaps pipeline.
//
// H loading and syndrome generation overlap. After the fixed-iteration decoder
// finishes, its single decision read port is assigned in sequence to the
// padded error-vector writer and the residual checker. Post-processing then
// performs L, H4 verification, implicit-rejection selection, and K derivation.
module trike_decaps_pipeline_core #(
    parameter int M_BYTES          = 32,
    parameter int WORD_W           = 64,
    parameter int DIGIT_W          = 16,
    parameter int PADDED_R_BYTES   = ((bike_pkg::R + 511) / 512) * 64,
    parameter int CIPHERTEXT_BYTES = (2 * ((bike_pkg::R + 7) / 8)) + M_BYTES,
    parameter int DATA_W           = 8 * M_BYTES,
    parameter int ERROR_BYTES      = bike_pkg::N0 * PADDED_R_BYTES,
    parameter int ERROR_ADDR_W     = ((ERROR_BYTES > 1) ? $clog2(ERROR_BYTES) : 1),
    parameter int R_BYTES          = (bike_pkg::R + 7) / 8,
    parameter int R_ADDR_W         = ((R_BYTES > 1) ? $clog2(R_BYTES) : 1),
    parameter int CT_ADDR_W        = ((CIPHERTEXT_BYTES > 1) ? $clog2(CIPHERTEXT_BYTES) : 1),
    parameter int SS_IDX_W         = ((M_BYTES > 1) ? $clog2(M_BYTES) : 1)
) (
    input  logic                           i_clk,
    input  logic                           i_rst_n,
    input  logic                           i_start,
    input  logic                           i_h_valid,
    input  logic [bike_pkg::ROW_IDX_W-1:0] i_h_index,
    output logic                           o_h_ready,
    input  logic                           i_t0_valid,
    input  logic [             WORD_W-1:0] i_t0_data,
    output logic                           o_t0_ready,
    input  logic                           i_u_valid,
    input  logic [             WORD_W-1:0] i_u_data,
    output logic                           o_u_ready,
    input  logic                           i_v_valid,
    input  logic [             WORD_W-1:0] i_v_data,
    output logic                           o_v_ready,
    input  logic [             DATA_W-1:0] i_sigma2,
    input  logic                           i_c2_valid,
    input  logic [                    7:0] i_c2_data,
    output logic                           o_c2_ready,
    output logic                           o_r2_re,
    output logic [           R_ADDR_W-1:0] o_r2_raddr,
    input  logic [                    7:0] i_r2_rdata,
    output logic                           o_ciphertext_re,
    output logic [          CT_ADDR_W-1:0] o_ciphertext_raddr,
    input  logic [                    7:0] i_ciphertext_rdata,
    output logic                           o_residual_zero,
    output logic [bike_pkg::ROW_IDX_W-1:0] o_residual_weight,
    output logic                           o_ciphertext_equal,
    output logic                           o_shared_secret_valid,
    output logic [           SS_IDX_W-1:0] o_shared_secret_index,
    output logic [                    7:0] o_shared_secret_data,
    output logic                           o_shared_secret_last,
    input  logic                           i_shared_secret_ready,
    output logic                           o_busy,
    output logic                           o_done
);
  import bike_pkg::*;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_DECODE_RUN,
    ST_ERROR_START,
    ST_ERROR_RUN,
    ST_RESIDUAL_START,
    ST_RESIDUAL_RUN,
    ST_POST_START,
    ST_POST_RUN
  } state_t;

  state_t                    state_q;
  integer                    support_count_q;
  logic   [      DATA_W-1:0] sigma2_q;
  logic                      syndrome_complete_q;

  logic                      syndrome_start;
  logic                      syndrome_h_ready;
  logic                      syndrome_h_valid;
  logic                      syndrome_valid;
  logic   [      WORD_W-1:0] syndrome_data;
  logic                      syndrome_last;
  logic                      syndrome_ready;
  logic                      syndrome_busy;
  logic                      syndrome_done;

  logic                      adapter_h_ready;
  logic                      adapter_h_valid;
  logic                      adapter_h_we;
  logic   [   H_BLOCK_W-1:0] adapter_h_block;
  logic   [  DIAG_IDX_W-1:0] adapter_h_diag;
  logic   [   ROW_IDX_W-1:0] adapter_h_index;
  logic                      adapter_syndrome_we;
  logic   [   ROW_IDX_W-1:0] adapter_syndrome_addr;
  logic                      adapter_syndrome_data;
  logic                      adapter_decoder_start;
  logic                      adapter_error;
  logic                      adapter_busy;
  logic                      adapter_done;

  logic                      decoder_h_loaded;
  logic                      decoder_h_error;
  logic                      decoder_done;
  logic                      decoder_e_data;
  logic                      decoder_e_data_1;
  logic   [      ITER_W-1:0] decoder_iter_count;
  logic   [       COL_W-1:0] decoder_e_addr;
  logic   [       COL_W-1:0] decoder_e_addr_1;
  logic                      decoder_e_valid_1;

  logic   [       COL_W-1:0] error_decision_addr;
  logic                      error_reference_re;
  logic   [ERROR_ADDR_W-1:0] error_reference_addr;
  logic   [             7:0] error_reference_data;
  logic                      error_busy;
  logic                      error_done;

  logic   [       COL_W-1:0] residual_decision_addr;
  logic   [       COL_W-1:0] residual_decision_addr_1;
  logic                      residual_decision_valid_1;
  logic                      residual_busy;
  logic                      residual_done;

  logic                      post_busy;
  logic                      post_done;

  logic                      first_h_block_c;
  assign first_h_block_c = support_count_q < W;
  assign syndrome_start = (state_q == ST_IDLE) && i_start;

  // The first W support entries are accepted simultaneously by the H0 RAM and
  // the complete-H sorter. Remaining support entries feed only the sorter.
  assign o_h_ready = adapter_h_ready && (!first_h_block_c || syndrome_h_ready);
  assign adapter_h_valid = i_h_valid && (!first_h_block_c || syndrome_h_ready);
  assign syndrome_h_valid = i_h_valid && first_h_block_c && adapter_h_ready;

  assign decoder_e_addr = (state_q == ST_ERROR_RUN) ? error_decision_addr :
                          (state_q == ST_RESIDUAL_RUN) ? residual_decision_addr : '0;
  assign decoder_e_addr_1 = (state_q == ST_RESIDUAL_RUN) ? residual_decision_addr_1 : '0;
  assign decoder_e_valid_1 = (state_q == ST_RESIDUAL_RUN) && residual_decision_valid_1;
  assign o_busy = state_q != ST_IDLE;

  trike_decaps_syndrome_core #(
      .R_BITS       (R),
      .SECRET_WEIGHT(W),
      .WORD_W       (WORD_W),
      .DIGIT_W      (DIGIT_W)
  ) u_syndrome (
      .i_clk                      (i_clk),
      .i_rst_n                    (i_rst_n),
      .i_start                    (syndrome_start),
      .i_runtime_r_bits           ('0),
      .i_runtime_secret_weight    ('0),
      .i_runtime_words            ('0),
      .i_h0_valid                 (syndrome_h_valid),
      .i_h0_index                 (i_h_index),
      .o_h0_ready                 (syndrome_h_ready),
      .i_t0_valid                 (i_t0_valid),
      .i_t0_data                  (i_t0_data),
      .o_t0_ready                 (o_t0_ready),
      .i_u_valid                  (i_u_valid),
      .i_u_data                   (i_u_data),
      .o_u_ready                  (o_u_ready),
      .i_v_valid                  (i_v_valid),
      .i_v_data                   (i_v_data),
      .o_v_ready                  (o_v_ready),
      .o_syndrome_valid           (syndrome_valid),
      .o_syndrome_data            (syndrome_data),
      .o_syndrome_last            (syndrome_last),
      .i_syndrome_ready           (syndrome_ready),
      .o_busy                     (syndrome_busy),
      .o_done                     (syndrome_done),
      .o_mul_start                (),
      .o_mul_runtime_r_bits       (),
      .o_mul_runtime_words        (),
      .o_mul_runtime_sparse_weight(),
      .o_mul_sparse_a             (),
      .o_mul_a_valid              (),
      .o_mul_a_data               (),
      .i_mul_a_ready              (1'b0),
      .o_mul_sparse_index_valid   (),
      .o_mul_sparse_index         (),
      .i_mul_sparse_index_ready   (1'b0),
      .o_mul_b_valid              (),
      .o_mul_b_data               (),
      .i_mul_b_ready              (1'b0),
      .i_mul_result_valid         (1'b0),
      .i_mul_result_data          ('0),
      .i_mul_result_last          (1'b0),
      .o_mul_result_ready         ()
  );

  trike_decoder_load_adapter #(
      .R_BITS(R),
      .BLOCKS(N0),
      .WEIGHT(W),
      .WORD_W(WORD_W)
  ) u_adapter (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (syndrome_start),
      .i_runtime_r_bits  ('0),
      .i_runtime_weight  ('0),
      .i_h_valid         (adapter_h_valid),
      .i_h_index         (i_h_index),
      .o_h_ready         (adapter_h_ready),
      .o_h_we            (adapter_h_we),
      .o_h_block_idx     (adapter_h_block),
      .o_h_diag_idx_local(adapter_h_diag),
      .o_h_base_row_idx  (adapter_h_index),
      .i_h_loaded        (decoder_h_loaded),
      .i_h_error         (decoder_h_error),
      .i_syndrome_valid  (syndrome_valid),
      .i_syndrome_data   (syndrome_data),
      .o_syndrome_ready  (syndrome_ready),
      .o_syndrome_we     (adapter_syndrome_we),
      .o_syndrome_addr   (adapter_syndrome_addr),
      .o_syndrome_wdata  (adapter_syndrome_data),
      .o_decoder_start   (adapter_decoder_start),
      .i_decoder_done    (decoder_done),
      .o_error           (adapter_error),
      .o_busy            (adapter_busy),
      .o_done            (adapter_done)
  );

  decoder_top u_decoder (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (adapter_decoder_start),
      .i_param_level     (PROFILE_DEFAULT),
      .i_syndrome_we     (adapter_syndrome_we),
      .i_syndrome_addr   (adapter_syndrome_addr),
      .i_syndrome_wdata  (adapter_syndrome_data),
      .i_h_we            (adapter_h_we),
      .i_h_block_idx     (adapter_h_block),
      .i_h_diag_idx_local(adapter_h_diag),
      .i_h_base_row_idx  (adapter_h_index),
      .i_e_read_col_idx  (decoder_e_addr),
      .i_e_read_col_idx_1(decoder_e_addr_1),
      .i_e_read_valid_1  (decoder_e_valid_1),
      .o_h_loaded        (decoder_h_loaded),
      .o_h_error         (decoder_h_error),
      .o_done            (decoder_done),
      .o_e_rdata         (decoder_e_data),
      .o_e_rdata_1       (decoder_e_data_1),
      .o_iter_count      (decoder_iter_count)
  );

  trike_decoder_error_vector #(
      .R_BITS        (R),
      .BLOCKS        (N0),
      .PADDED_R_BYTES(PADDED_R_BYTES)
  ) u_error_vector (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (state_q == ST_ERROR_START),
      .i_runtime_r_bits  ('0),
      .o_decision_col_idx(error_decision_addr),
      .i_decision_data   (decoder_e_data),
      .i_error_re        (error_reference_re),
      .i_error_raddr     (error_reference_addr),
      .o_error_rdata     (error_reference_data),
      .o_busy            (error_busy),
      .o_done            (error_done)
  );

  trike_decoder_residual_check #(
      .R_BITS(R),
      .BLOCKS(N0),
      .WEIGHT(W)
  ) u_residual (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_h_we              (adapter_h_we),
      .i_h_block_idx       (adapter_h_block),
      .i_h_diag_idx        (adapter_h_diag),
      .i_h_index           (adapter_h_index),
      .i_syndrome_we       (adapter_syndrome_we),
      .i_syndrome_addr     (adapter_syndrome_addr),
      .i_syndrome_data     (adapter_syndrome_data),
      .i_start             (state_q == ST_RESIDUAL_START),
      .i_runtime_r_bits    ('0),
      .i_runtime_weight    ('0),
      .o_decision_col_idx  (residual_decision_addr),
      .o_decision_col_idx_1(residual_decision_addr_1),
      .o_decision_valid_1  (residual_decision_valid_1),
      .i_decision_data     (decoder_e_data),
      .i_decision_data_1   (decoder_e_data_1),
      .o_residual_zero     (o_residual_zero),
      .o_residual_weight   (o_residual_weight),
      .o_busy              (residual_busy),
      .o_done              (residual_done)
  );

  trike_decaps_postprocess_core #(
      .M_BYTES         (M_BYTES),
      .R_BITS          (R),
      .ERROR_WEIGHT    (T),
      .PADDED_R_BYTES  (PADDED_R_BYTES),
      .CIPHERTEXT_BYTES(CIPHERTEXT_BYTES)
  ) u_postprocess (
      .i_clk                     (i_clk),
      .i_rst_n                   (i_rst_n),
      .i_start                   (state_q == ST_POST_START),
      .i_runtime_r_bits          ('0),
      .i_runtime_error_weight    ('0),
      .i_runtime_r_bytes         ('0),
      .i_runtime_padded_r_bytes  ('0),
      .i_runtime_error_bytes     ('0),
      .i_runtime_ciphertext_bytes('0),
      .i_decoder_ok              (o_residual_zero),
      .i_sigma2                  (sigma2_q),
      .i_c2_valid                (i_c2_valid),
      .i_c2_data                 (i_c2_data),
      .o_c2_ready                (o_c2_ready),
      .o_reference_re            (error_reference_re),
      .o_reference_raddr         (error_reference_addr),
      .i_reference_rdata         (error_reference_data),
      .o_r2_re                   (o_r2_re),
      .o_r2_raddr                (o_r2_raddr),
      .i_r2_rdata                (i_r2_rdata),
      .o_ciphertext_re           (o_ciphertext_re),
      .o_ciphertext_raddr        (o_ciphertext_raddr),
      .i_ciphertext_rdata        (i_ciphertext_rdata),
      .o_ciphertext_equal        (o_ciphertext_equal),
      .o_shared_secret_valid     (o_shared_secret_valid),
      .o_shared_secret_index     (o_shared_secret_index),
      .o_shared_secret_data      (o_shared_secret_data),
      .o_shared_secret_last      (o_shared_secret_last),
      .i_shared_secret_ready     (i_shared_secret_ready),
      .o_busy                    (post_busy),
      .o_done                    (post_done),
      .o_compress_start          (),
      .o_compress_block          (),
      .o_compress_state          (),
      .i_compress_busy           (1'b0),
      .i_compress_done           (1'b0),
      .i_compress_state          ('0),
      .o_sampler_start           (),
      .o_sampler_runtime_length  (),
      .o_sampler_runtime_weight  (),
      .o_sampler_v               (),
      .o_sampler_c               (),
      .o_sampler_reseed_counter  (),
      .i_sampler_index_valid     (1'b0),
      .i_sampler_index_position  ('0),
      .i_sampler_index           ('0),
      .o_sampler_index_ready     (),
      .i_sampler_done            (1'b0),
      .i_sampler_v               ('0),
      .i_sampler_c               ('0),
      .i_sampler_reseed_counter  ('0)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      support_count_q <= 0;
      sigma2_q <= '0;
      syndrome_complete_q <= 1'b0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;
      if (syndrome_done) syndrome_complete_q <= 1'b1;
      if ((state_q == ST_DECODE_RUN) && i_h_valid && o_h_ready)
        support_count_q <= support_count_q + 1;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            support_count_q <= 0;
            sigma2_q <= i_sigma2;
            syndrome_complete_q <= 1'b0;
            state_q <= ST_DECODE_RUN;
          end
        end
        ST_DECODE_RUN: begin
          if (adapter_done) state_q <= ST_ERROR_START;
        end
        ST_ERROR_START: state_q <= ST_ERROR_RUN;
        ST_ERROR_RUN: begin
          if (error_done) state_q <= ST_RESIDUAL_START;
        end
        ST_RESIDUAL_START: state_q <= ST_RESIDUAL_RUN;
        ST_RESIDUAL_RUN: begin
          if (residual_done) state_q <= ST_POST_START;
        end
        ST_POST_START: state_q <= ST_POST_RUN;
        ST_POST_RUN: begin
          if (post_done) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end
        end
        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && adapter_done && (adapter_error || !syndrome_complete_q))
      $fatal(1, "trike_decaps_pipeline_core decode load failed");
    if (i_rst_n && adapter_decoder_start && !syndrome_complete_q)
      $fatal(1, "trike_decaps_pipeline_core decoder started before syndrome completion");
  end
`endif

  initial begin
    if (N0 != 3) $fatal(1, "trike_decaps_pipeline_core requires three TRIKE blocks");
    if (WORD_W != 64) $fatal(1, "trike_decaps_pipeline_core requires 64-bit syndrome words");
  end

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_status;
  assign unused_status = syndrome_last ^ syndrome_busy ^ adapter_busy ^ decoder_iter_count[0] ^
                         error_busy ^ residual_busy ^ post_busy;
  /* verilator lint_on UNUSEDSIGNAL */

endmodule
