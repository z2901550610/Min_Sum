`timescale 1ns / 1ps
// One paper-style RAM M block storing compressed c2v state for one check-row group.
module ram_m
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_we,
    input  logic [ROW_GROUP_W-1:0] i_read_row_idx_group,
    input  logic [ROW_GROUP_W-1:0] i_write_row_idx_group,
    input  logic                   i_epoch,
`ifdef BIKE_SIM_DEBUG
    input  logic [ COMP_C2V_W-1:0] i_wdata,
    output logic [ COMP_C2V_W-1:0] o_rdata,
    output logic                   o_epoch,
    output logic [ COMP_C2V_W-1:0] o_debug_mem[0:ROW_GROUP_DEPTH-1]
`else
    input  logic [ COMP_C2V_W-1:0] i_wdata,
    output logic [ COMP_C2V_W-1:0] o_rdata,
    output logic                   o_epoch
`endif
);

  localparam int M_WORD_EPOCH_BIT = COMP_C2V_W;
  localparam int M_WORD_W = COMP_C2V_W + 1;

  logic [M_WORD_W-1:0] rword;
`ifdef BIKE_SIM_DEBUG
  logic [M_WORD_W-1:0] debug_words[0:ROW_GROUP_DEPTH-1];

  always_comb begin
    for (int row_idx = 0; row_idx < ROW_GROUP_DEPTH; row_idx++) begin
      o_debug_mem[row_idx] = debug_words[row_idx][COMP_C2V_W-1:0];
    end
  end
`endif

  assign o_rdata = rword[COMP_C2V_W-1:0];
  assign o_epoch = rword[M_WORD_EPOCH_BIT];

  ram_1r1w_sync_read #(
      .DATA_W(M_WORD_W),
      .DEPTH(ROW_GROUP_DEPTH),
      .ADDR_W(ROW_GROUP_W),
      .RAM_STYLE("block"),
      .INIT_TO_VALUE(1'b1),
`ifdef BIKE_SIM_DEBUG
      .RESET_MEM(1'b1),
`else
      .RESET_MEM(1'b0),
`endif
      .RESET_VALUE({1'b0, COMP_C2V_INIT})
  ) u_mem (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_clear(1'b0),
      .i_we(i_we),
      .i_write_addr(i_write_row_idx_group),
      .i_wdata({i_epoch, i_wdata}),
      .i_read_addr(i_read_row_idx_group),
`ifdef BIKE_SIM_DEBUG
      .o_rdata(rword),
      .o_debug_mem(debug_words)
`else
      .o_rdata(rword)
`endif
  );
endmodule
