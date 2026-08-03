`timescale 1ns / 1ps

// Single-command SM3 compression service.
//
// Block builders submit one public-schedule command at a time. Composite
// HMAC, DF, DRNG, and pseudohash controllers multiplex their sequential
// clients onto this boundary.
module trike_sm3_service (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic [511:0] i_block,
    input  logic [255:0] i_state,
    output logic         o_busy,
    output logic         o_done,
    output logic [255:0] o_state
);

  sm3_compress u_sm3_compress (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .i_start(i_start),
      .i_block(i_block),
      .i_state(i_state),
      .o_busy (o_busy),
      .o_done (o_done),
      .o_state(o_state)
  );

endmodule
