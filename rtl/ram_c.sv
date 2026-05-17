`timescale 1ns / 1ps
// One paper-style RAM C block storing hard decisions/error-estimate bits.
module ram_c
  import bike_pkg::*;
(
    input  logic             i_clk,
    input  logic             i_we,
    input  logic [COL_W-1:0] i_col_idx,  // Which variable column j / hard-decision bit to access.
    input  logic             i_wdata,
    output logic             o_rdata
);

  (* ram_style = "block" *) logic mem[0:N-1];

  always_ff @(posedge i_clk) begin
    if (i_we) begin
      mem[i_col_idx] <= i_wdata;
    end
    o_rdata <= mem[i_col_idx];
  end
endmodule
