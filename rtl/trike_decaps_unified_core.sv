`timescale 1ns / 1ps

// Complete four-profile TRIKE Decaps core. Public profile selection configures
// the fixed decoder schedule and the active ranges in maximum-size KEM RAMs.
module trike_decaps_unified_core
  import bike_pkg::*;
(
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    input  logic                    i_start,
    input  logic [PROFILE_ID_W-1:0] i_param_level,
    input  logic                    i_input_valid,
    input  logic [             7:0] i_input_data,
    output logic                    o_input_ready,
    output logic                    o_residual_zero,
    output logic [   ROW_IDX_W-1:0] o_residual_weight,
    output logic                    o_ciphertext_equal,
    output logic                    o_shared_secret_valid,
    output logic [             4:0] o_shared_secret_index,
    output logic [             7:0] o_shared_secret_data,
    output logic                    o_shared_secret_last,
    input  logic                    i_shared_secret_ready,
    output logic                    o_error,
    output logic                    o_busy,
    output logic                    o_done
);

  logic                    decoder_h_we;
  logic [   H_BLOCK_W-1:0] decoder_h_block_idx;
  logic [  DIAG_IDX_W-1:0] decoder_h_diag_idx;
  logic [   ROW_IDX_W-1:0] decoder_h_index;
  logic                    decoder_h_loaded;
  logic                    decoder_h_error;
  logic                    decoder_syndrome_we;
  logic [   ROW_IDX_W-1:0] decoder_syndrome_addr;
  logic                    decoder_syndrome_data;
  logic                    decoder_start;
  logic                    decoder_done;
  logic [       COL_W-1:0] decoder_decision_col;
  logic [       COL_W-1:0] decoder_decision_col_1;
  logic                    decoder_decision_valid_1;
  logic                    decoder_decision_data;
  logic                    decoder_decision_data_1;
  logic [PROFILE_ID_W-1:0] selected_level;
  logic [            31:0] runtime_r_bits;
  logic [            31:0] runtime_secret_weight;
  logic [            31:0] runtime_error_weight;
  logic [            31:0] runtime_r_bytes;
  logic [            31:0] runtime_padded_r_bytes;
  logic [            31:0] runtime_ciphertext_bytes;
  logic [            31:0] runtime_input_bytes;
  logic [      ITER_W-1:0] decoder_iter_count;

  trike_decaps_runtime_pipeline_core u_runtime_pipeline (
      .i_clk                     (i_clk),
      .i_rst_n                   (i_rst_n),
      .i_start                   (i_start),
      .i_param_level             (i_param_level),
      .i_input_valid             (i_input_valid),
      .i_input_data              (i_input_data),
      .o_input_ready             (o_input_ready),
      .o_decoder_h_we            (decoder_h_we),
      .o_decoder_h_block_idx     (decoder_h_block_idx),
      .o_decoder_h_diag_idx      (decoder_h_diag_idx),
      .o_decoder_h_index         (decoder_h_index),
      .i_decoder_h_loaded        (decoder_h_loaded),
      .i_decoder_h_error         (decoder_h_error),
      .o_decoder_syndrome_we     (decoder_syndrome_we),
      .o_decoder_syndrome_addr   (decoder_syndrome_addr),
      .o_decoder_syndrome_data   (decoder_syndrome_data),
      .o_decoder_start           (decoder_start),
      .i_decoder_done            (decoder_done),
      .o_decoder_decision_col    (decoder_decision_col),
      .o_decoder_decision_col_1  (decoder_decision_col_1),
      .o_decoder_decision_valid_1(decoder_decision_valid_1),
      .i_decoder_decision_data   (decoder_decision_data),
      .i_decoder_decision_data_1 (decoder_decision_data_1),
      .o_param_level             (selected_level),
      .o_r_bits                  (runtime_r_bits),
      .o_secret_weight           (runtime_secret_weight),
      .o_error_weight            (runtime_error_weight),
      .o_r_bytes                 (runtime_r_bytes),
      .o_padded_r_bytes          (runtime_padded_r_bytes),
      .o_ciphertext_bytes        (runtime_ciphertext_bytes),
      .o_input_bytes             (runtime_input_bytes),
      .o_residual_zero           (o_residual_zero),
      .o_residual_weight         (o_residual_weight),
      .o_ciphertext_equal        (o_ciphertext_equal),
      .o_shared_secret_valid     (o_shared_secret_valid),
      .o_shared_secret_index     (o_shared_secret_index),
      .o_shared_secret_data      (o_shared_secret_data),
      .o_shared_secret_last      (o_shared_secret_last),
      .i_shared_secret_ready     (i_shared_secret_ready),
      .o_error                   (o_error),
      .o_busy                    (o_busy),
      .o_done                    (o_done)
  );

  decoder_top u_decoder (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (decoder_start),
      .i_param_level     (selected_level),
      .i_syndrome_we     (decoder_syndrome_we),
      .i_syndrome_addr   (decoder_syndrome_addr),
      .i_syndrome_wdata  (decoder_syndrome_data),
      .i_h_we            (decoder_h_we),
      .i_h_block_idx     (decoder_h_block_idx),
      .i_h_diag_idx_local(decoder_h_diag_idx),
      .i_h_base_row_idx  (decoder_h_index),
      .i_e_read_col_idx  (decoder_decision_col),
      .i_e_read_col_idx_1(decoder_decision_col_1),
      .i_e_read_valid_1  (decoder_decision_valid_1),
      .o_h_loaded        (decoder_h_loaded),
      .o_h_error         (decoder_h_error),
      .o_done            (decoder_done),
      .o_e_rdata         (decoder_decision_data),
      .o_e_rdata_1       (decoder_decision_data_1),
      .o_iter_count      (decoder_iter_count)
  );

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_runtime_status;
  assign unused_runtime_status =
      ^{runtime_r_bits, runtime_secret_weight, runtime_error_weight, runtime_r_bytes,
        runtime_padded_r_bytes, runtime_ciphertext_bytes, runtime_input_bytes, decoder_iter_count};
  /* verilator lint_on UNUSEDSIGNAL */

endmodule
