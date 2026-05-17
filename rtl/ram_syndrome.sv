`timescale 1ns / 1ps
// Syndrome bit store with one load/write port and L registered read ports.
module ram_syndrome
  import bike_pkg::*;
(
    input  logic                 i_clk,
    input  logic                 i_we,
    input  logic [ROW_IDX_W-1:0] i_write_row_idx,
    input  logic                 i_wdata,
    input  logic [ROW_IDX_W-1:0] i_read_row_idx[0:L-1],
    output logic                 o_rdata[0:L-1]
);

  (* ram_style = "block" *) logic mem[0:L-1][0:R-1];

  always_ff @(posedge i_clk) begin
    if (i_we) begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        mem[lane_idx][i_write_row_idx] <= i_wdata;
      end
    end

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_rdata[lane_idx] <= mem[lane_idx][i_read_row_idx[lane_idx]];
    end
  end
endmodule
