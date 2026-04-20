// One paper-style RAM M block storing compressed c2v state for one row segment.
module ram_m
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_en,
  input  logic i_we,
  input  logic [ROW_W-1:0] i_addr,
  input  logic [COMP_C2V_W-1:0] i_din,
  output logic [COMP_C2V_W-1:0] o_dout,
  output logic [COMP_C2V_W-1:0] o_debug_mem [0:R-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [COMP_C2V_W-1:0] mem [0:R-1];

  assign o_debug_mem = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer row_idx;

    if (!i_rst_n) begin
      o_dout <= COMP_C2V_INIT;
      for (row_idx = 0; row_idx < R; row_idx++) begin
        mem[row_idx] <= COMP_C2V_INIT;
      end
    end else if (i_clear) begin
      o_dout <= COMP_C2V_INIT;
      for (row_idx = 0; row_idx < R; row_idx++) begin
        mem[row_idx] <= COMP_C2V_INIT;
      end
    end else if (i_en) begin
      if (i_we) begin
        mem[i_addr] <= i_din;
      end
      o_dout <= mem[i_addr];
    end
  end
endmodule
