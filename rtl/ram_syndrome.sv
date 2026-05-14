`timescale 1ns/1ps
// Syndrome bit store with one load/write port and two registered read ports.
module ram_syndrome
  import bike_pkg::*;
(
  input  logic                 i_clk,
  input  logic                 i_we,
  input  logic [ROW_IDX_W-1:0] i_write_row_idx,
  input  logic                 i_wdata,
  input  logic [ROW_IDX_W-1:0] i_read_row_idx0,
  input  logic [ROW_IDX_W-1:0] i_read_row_idx1,
  output logic                 o_rdata0,
  output logic                 o_rdata1
);

  (* ram_style = "block" *) logic mem0 [0:R-1];
  (* ram_style = "block" *) logic mem1 [0:R-1];

  always_ff @(posedge i_clk) begin
    if (i_we) begin
      mem0[i_write_row_idx] <= i_wdata;
      mem1[i_write_row_idx] <= i_wdata;
    end

    o_rdata0 <= mem0[i_read_row_idx0];
    o_rdata1 <= mem1[i_read_row_idx1];
  end
endmodule
