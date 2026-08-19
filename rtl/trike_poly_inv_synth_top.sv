`timescale 1ns / 1ps

// TRIKE-2 polynomial-inversion implementation wrapper for Vivado measurement.
module trike_poly_inv_synth_top (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_start,
    input  logic        i_input_valid,
    input  logic [63:0] i_input_data,
    output logic        o_input_ready,
    output logic        o_result_valid,
    output logic [63:0] o_result_data,
    output logic        o_result_last,
    input  logic        i_result_ready,
    output logic        o_busy,
    output logic        o_done
);

  logic rst_n_sync;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  trike_poly_inv_core #(
      .R_BITS (15581),
      .WORD_W (64),
      .DIGIT_W(16)
  ) u_inv (
      .i_clk         (i_clk),
      .i_rst_n       (rst_n_sync),
      .i_start       (i_start),
      .i_input_valid (i_input_valid),
      .i_input_data  (i_input_data),
      .o_input_ready (o_input_ready),
      .o_result_valid(o_result_valid),
      .o_result_data (o_result_data),
      .o_result_last (o_result_last),
      .i_result_ready(i_result_ready),
      .o_busy        (o_busy),
      .o_done        (o_done)
  );

endmodule
