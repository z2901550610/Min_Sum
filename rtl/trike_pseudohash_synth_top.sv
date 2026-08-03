`timescale 1ns / 1ps

// Fixed 32-byte pseudohash512 wrapper for shared-SM3 implementation reports.
module trike_pseudohash_synth_top (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic         i_input_valid,
    input  logic [  7:0] i_input_data,
    output logic         o_input_ready,
    output logic         o_input_pass,
    output logic         o_busy,
    output logic         o_done,
    output logic [511:0] o_digest
);

  logic rst_n_sync;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  trike_pseudohash512_stream #(
      .MESSAGE_BYTES(32)
  ) u_pseudohash (
      .i_clk           (i_clk),
      .i_rst_n         (rst_n_sync),
      .i_start         (i_start),
      .i_input_valid   (i_input_valid),
      .i_input_data    (i_input_data),
      .o_input_ready   (o_input_ready),
      .o_input_pass    (o_input_pass),
      .o_busy          (o_busy),
      .o_done          (o_done),
      .o_digest        (o_digest),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

endmodule
