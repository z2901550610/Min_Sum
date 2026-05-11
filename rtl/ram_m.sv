`timescale 1ns/1ps
// One paper-style RAM M block storing compressed c2v state for one check-row group.
module ram_m
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_we,
  input  logic [ROW_GROUP_W-1:0] i_read_row_idx_group,    // Check-row state read address.
  input  logic [ROW_GROUP_W-1:0] i_write_row_idx_group,   // Check-row state write address.
  input  logic [COMP_C2V_W-1:0] i_wdata,
  output logic [COMP_C2V_W-1:0] o_rdata,
  output logic [COMP_C2V_W-1:0] o_debug_mem [0:ROW_GROUP_DEPTH-1]
);

  (* ram_style = "block" *) logic [COMP_C2V_W-1:0] mem [0:ROW_GROUP_DEPTH-1];

`ifndef SYNTHESIS
  assign o_debug_mem = mem;
`else
  always_comb begin
    for (int row_idx = 0; row_idx < ROW_GROUP_DEPTH; row_idx++) begin
      o_debug_mem[row_idx] = '0;
    end
  end
`endif

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= COMP_C2V_INIT;
`ifndef SYNTHESIS
      for (int row_idx = 0; row_idx < ROW_GROUP_DEPTH; row_idx++) begin
        mem[row_idx] <= COMP_C2V_INIT;
      end
`endif
    end else begin
      if (i_we) begin
        mem[i_write_row_idx_group] <= i_wdata;
      end
      o_rdata <= mem[i_read_row_idx_group];
    end
  end
endmodule
