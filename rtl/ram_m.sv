// One paper-style RAM M block storing compressed c2v state for one check-row group.
module ram_m
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_en,
  input  logic i_we,
  input  logic [ROW_IDX_W-1:0] i_check_row_addr,           // Which check-row state to access inside this RAM-M group.
  input  logic [COMP_C2V_W-1:0] i_wdata,
  output logic [COMP_C2V_W-1:0] o_rdata,
  output logic [COMP_C2V_W-1:0] o_debug_mem [0:R-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [COMP_C2V_W-1:0] mem [0:R-1];

  assign o_debug_mem = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= COMP_C2V_INIT;
      for (int row_idx = 0; row_idx < R; row_idx++) begin
        mem[row_idx] <= COMP_C2V_INIT;
      end
    end else if (i_en) begin
      if (i_we) begin
        mem[i_check_row_addr] <= i_wdata;
      end
      o_rdata <= mem[i_check_row_addr];
    end
  end
endmodule
