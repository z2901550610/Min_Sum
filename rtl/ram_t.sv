// One paper-style RAM T block storing cached c2v messages for one lane.
module ram_t
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_en,
  input  logic i_we,
  input  logic [VAR_W-1:0] i_var_idx,                      // Which variable column j to access.
  input  logic [EDGE_W-1:0] i_edge_slot,                   // Which "1" in this variable column, range 0..W-1.
  input  logic [MSG_W-1:0] i_wdata,
  output logic [MSG_W-1:0] o_rdata,
  output logic [MSG_W-1:0] o_debug_mem [0:N-1][0:W-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [MSG_W-1:0] mem [0:N-1][0:W-1];

  assign o_debug_mem = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= '0;
      for (int var_idx = 0; var_idx < N; var_idx++) begin
        for (int edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= '0;
        end
      end
    end else if (i_clear) begin
      o_rdata <= '0;
      for (int var_idx = 0; var_idx < N; var_idx++) begin
        for (int edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= '0;
        end
      end
    end else if (i_en) begin
      if (i_we) begin
        mem[i_var_idx][i_edge_slot] <= i_wdata;
      end
      o_rdata <= mem[i_var_idx][i_edge_slot];
    end
  end
endmodule
