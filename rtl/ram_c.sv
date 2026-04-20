// Stores the running hard decision / error estimate bits.
module ram_c
  import bike_pkg::*;
(
  input  logic i_clk,                    // Storage clock.
  input  logic i_rst_n,                  // Active-low reset.
  input  logic i_clear,                  // Clears the full estimate vector.
  input  logic i_load,                   // Bulk-load enable for the estimate vector.
  input  logic [N-1:0] i_load_bits,      // Bulk-load data.
  input  logic i_we,                     // Single-bit write enable.
  input  logic [VAR_W-1:0] i_w_addr,     // Write address.
  input  logic i_din,                    // Bit written at i_w_addr.
  input  logic [VAR_W-1:0] i_r_addr,     // Read address.
  output logic o_dout,                   // Bit read from i_r_addr.
  output logic [N-1:0] o_bits            // Entire stored estimate vector.
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [N-1:0] mem;

  assign o_dout = mem[i_r_addr];
  assign o_bits = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      mem <= '0;
    end else if (i_clear) begin
      mem <= '0;
    end else if (i_load) begin
      mem <= i_load_bits;
    end else if (i_we) begin
      mem[i_w_addr] <= i_din;
    end
  end
endmodule
