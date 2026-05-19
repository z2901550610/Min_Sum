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

`ifdef BIKE_SIM_DEBUG
  /* verilator lint_off UNUSEDSIGNAL */
  logic debug_mem[0:N-1];
  /* verilator lint_on UNUSEDSIGNAL */
`endif

  ram_1r1w_sync_read #(
      .DATA_W(1),
      .DEPTH (N),
      .ADDR_W(COL_W)
  ) u_mem (
      .i_clk(i_clk),
      .i_rst_n(1'b1),
      .i_clear(1'b0),
      .i_we(i_we),
      .i_write_addr(i_col_idx),
      .i_wdata(i_wdata),
      .i_read_addr(i_col_idx),
`ifdef BIKE_SIM_DEBUG
      .o_rdata(o_rdata),
      .o_debug_mem(debug_mem)
`else
      .o_rdata(o_rdata)
`endif
  );
endmodule
