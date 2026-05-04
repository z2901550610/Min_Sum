`timescale 1ns/1ps
// RAM U — stores v2c/u messages for one processing group.
module ram_u
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_en,
  input  logic i_we,
  input  logic [COL_W-1:0] i_col_idx,
  input  logic [ONE_IDX_W-1:0] i_one_idx_global,
  input  logic [MSG_W-1:0] i_wdata,
  output logic [MSG_W-1:0] o_rdata,
  output logic [MSG_W-1:0] o_debug_mem [0:N-1][0:W-1]
);

  localparam logic [MSG_W-1:0] INIT_VALUE = {1'b0, D'(C_VAL)};

  logic [MSG_W-1:0] mem [0:N-1][0:W-1];

  assign o_debug_mem = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= '0;
      for (int col_idx = 0; col_idx < N; col_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          mem[col_idx][one_idx] <= INIT_VALUE;
        end
      end
    end else if (i_en) begin
      if (i_we) begin
        mem[i_col_idx][i_one_idx_global] <= i_wdata;
      end
      o_rdata <= mem[i_col_idx][i_one_idx_global];
    end
  end
endmodule
