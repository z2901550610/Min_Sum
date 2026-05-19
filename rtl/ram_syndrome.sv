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

`ifdef BIKE_SIM_DEBUG
  /* verilator lint_off UNUSEDSIGNAL */
  logic debug_mem[0:L-1][0:R-1];
  /* verilator lint_on UNUSEDSIGNAL */
`endif

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_syndrome_lane
    ram_1r1w_sync_read #(
        .DATA_W(1),
        .DEPTH (R),
        .ADDR_W(ROW_IDX_W)
    ) u_mem (
        .i_clk(i_clk),
        .i_rst_n(1'b1),
        .i_clear(1'b0),
        .i_we(i_we),
        .i_write_addr(i_write_row_idx),
        .i_wdata(i_wdata),
        .i_read_addr(i_read_row_idx[lane_idx]),
`ifdef BIKE_SIM_DEBUG
        .o_rdata(o_rdata[lane_idx]),
        .o_debug_mem(debug_mem[lane_idx])
`else
        .o_rdata(o_rdata[lane_idx])
`endif
    );
  end
endmodule
