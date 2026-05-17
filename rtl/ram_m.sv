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

  (* ram_style = "block" *) logic [M_WORD_W-1:0] mem[0:ROW_GROUP_DEPTH-1];
  logic [M_WORD_W-1:0] rword;

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    for (int row_idx = 0; row_idx < ROW_GROUP_DEPTH; row_idx++) begin
      o_debug_mem[row_idx] = mem[row_idx][COMP_C2V_W-1:0];
    end
  end
`endif

  assign o_rdata = rword[COMP_C2V_W-1:0];
  assign o_epoch = rword[M_WORD_EPOCH_BIT];

  initial begin
    rword = {1'b0, COMP_C2V_INIT};
    for (int row_idx = 0; row_idx < ROW_GROUP_DEPTH; row_idx++) begin
      mem[row_idx] = {1'b0, COMP_C2V_INIT};
    end
  end

`ifdef BIKE_SIM_DEBUG
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      rword <= {1'b0, COMP_C2V_INIT};
      for (int row_idx = 0; row_idx < ROW_GROUP_DEPTH; row_idx++) begin
        mem[row_idx] <= {1'b0, COMP_C2V_INIT};
      end
    end else begin
      if (i_we) begin
        mem[i_write_row_idx_group] <= {i_epoch, i_wdata};
      end
      rword <= mem[i_read_row_idx_group];
    end
  end
`else
  always_ff @(posedge i_clk) begin
    if (i_we) begin
      mem[i_write_row_idx_group] <= {i_epoch, i_wdata};
    end
    rword <= mem[i_read_row_idx_group];
  end
`endif
endmodule
