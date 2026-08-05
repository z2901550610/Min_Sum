`timescale 1ns / 1ps

// Narrow-I/O TRIKE-2 Encaps wrapper for Vivado synthesis and implementation.
module trike_encaps_synth_top (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_start,
    input  logic       i_input_valid,
    input  logic [7:0] i_input_data,
    output logic       o_input_ready,
    output logic       o_ciphertext_valid,
    output logic [7:0] o_ciphertext_data,
    output logic       o_ciphertext_last,
    input  logic       i_ciphertext_ready,
    output logic       o_shared_secret_valid,
    output logic [7:0] o_shared_secret_data,
    output logic       o_shared_secret_last,
    input  logic       i_shared_secret_ready,
    output logic       o_busy,
    output logic       o_done
);

  logic rst_n_sync;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  trike_encaps_core #(
      .M_BYTES     (32),
      .R_BITS      (15581),
      .ERROR_WEIGHT(263),
      .WORD_W      (64)
  ) u_encaps (
      .i_clk                (i_clk),
      .i_rst_n              (rst_n_sync),
      .i_start              (i_start),
      .i_input_valid        (i_input_valid),
      .i_input_data         (i_input_data),
      .o_input_ready        (o_input_ready),
      .o_ciphertext_valid   (o_ciphertext_valid),
      .o_ciphertext_data    (o_ciphertext_data),
      .o_ciphertext_last    (o_ciphertext_last),
      .i_ciphertext_ready   (i_ciphertext_ready),
      .o_shared_secret_valid(o_shared_secret_valid),
      .o_shared_secret_data (o_shared_secret_data),
      .o_shared_secret_last (o_shared_secret_last),
      .i_shared_secret_ready(i_shared_secret_ready),
      .o_busy               (o_busy),
      .o_done               (o_done)
  );

endmodule
