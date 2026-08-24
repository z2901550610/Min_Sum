`timescale 1ns / 1ps

// Narrow-I/O implementation entrypoint for the four-profile Decaps core.
// One transaction is accepted after each reset.
module trike_decaps_runtime_synth_top
  import bike_pkg::*;
(
                       input  logic                    i_clk,
                       input  logic                    i_rst_n,
                       input  logic                    i_start,
                       input  logic [PROFILE_ID_W-1:0] i_param_level,
                       input  logic                    i_input_valid,
                       input  logic [             7:0] i_input_data,
    (* IOB = "TRUE" *) output logic                    o_input_ready,
    (* IOB = "TRUE" *) output logic                    o_shared_secret_valid,
    (* IOB = "TRUE" *) output logic [             7:0] o_shared_secret_data,
    (* IOB = "TRUE" *) output logic                    o_shared_secret_last,
                       input  logic                    i_shared_secret_ready,
    (* IOB = "TRUE" *) output logic                    o_residual_zero,
    (* IOB = "TRUE" *) output logic                    o_ciphertext_equal,
    (* IOB = "TRUE" *) output logic                    o_error,
    (* IOB = "TRUE" *) output logic                    o_busy,
    (* IOB = "TRUE" *) output logic                    o_done
);

  logic [ROW_IDX_W-1:0] residual_weight;
  logic [          4:0] shared_secret_index;

  trike_decaps_unified_core u_core (
      .i_clk                            (i_clk),
      .i_rst_n                          (i_rst_n),
      .i_start                          (i_start),
      .i_param_level                    (i_param_level),
      .i_input_valid                    (i_input_valid),
      .i_input_data                     (i_input_data),
      .o_input_ready                    (o_input_ready),
      .o_residual_zero                  (o_residual_zero),
      .o_residual_weight                (residual_weight),
      .o_ciphertext_equal               (o_ciphertext_equal),
      .o_shared_secret_valid            (o_shared_secret_valid),
      .o_shared_secret_index            (shared_secret_index),
      .o_shared_secret_data             (o_shared_secret_data),
      .o_shared_secret_last             (o_shared_secret_last),
      .i_shared_secret_ready            (i_shared_secret_ready),
      .o_error                          (o_error),
      .o_busy                           (o_busy),
      .o_done                           (o_done),
      .o_compress_start                 (),
      .o_compress_block                 (),
      .o_compress_state                 (),
      .i_compress_busy                  (1'b0),
      .i_compress_done                  (1'b0),
      .i_compress_state                 ('0),
      .o_mul_start                      (),
      .o_mul_runtime_r_bits             (),
      .o_mul_runtime_words              (),
      .o_mul_runtime_sparse_weight      (),
      .o_mul_sparse_a                   (),
      .o_mul_a_valid                    (),
      .o_mul_a_data                     (),
      .i_mul_a_ready                    (1'b0),
      .o_mul_sparse_index_valid         (),
      .o_mul_sparse_index               (),
      .i_mul_sparse_index_ready         (1'b0),
      .o_mul_b_valid                    (),
      .o_mul_b_data                     (),
      .i_mul_b_ready                    (1'b0),
      .i_mul_result_valid               (1'b0),
      .i_mul_result_data                ('0),
      .i_mul_result_last                (1'b0),
      .o_mul_result_ready               (),
      .o_sampler_start                  (),
      .o_sampler_runtime_length         (),
      .o_sampler_runtime_weight         (),
      .o_sampler_v                      (),
      .o_sampler_c                      (),
      .o_sampler_reseed_counter         (),
      .i_sampler_index_valid            (1'b0),
      .i_sampler_index_position         ('0),
      .i_sampler_index                  ('0),
      .o_sampler_index_ready            (),
      .i_sampler_done                   (1'b0),
      .i_sampler_v                      ('0),
      .i_sampler_c                      ('0),
      .i_sampler_reseed_counter         ('0),
      .o_h4_store_start                 (),
      .o_h4_store_runtime_r_bits        (),
      .o_h4_store_runtime_error_weight  (),
      .o_h4_store_runtime_padded_r_bytes(),
      .o_h4_store_index_valid           (),
      .o_h4_store_index_position        (),
      .o_h4_store_index                 (),
      .i_h4_store_index_ready           (1'b0),
      .o_h4_store_support_re            (),
      .o_h4_store_support_raddr         (),
      .i_h4_store_support_rdata         ('0),
      .o_h4_store_error_re              (),
      .o_h4_store_error_raddr           (),
      .i_h4_store_error_rdata           ('0),
      .i_h4_store_done                  (1'b0)
  );

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_status;
  assign unused_status = ^{residual_weight, shared_secret_index};
  /* verilator lint_on UNUSEDSIGNAL */

endmodule
