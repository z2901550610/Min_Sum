// One paper-style RAM T block storing cached c2v messages for one lane.
module ram_t
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_en,
  input  logic i_we,
  input  logic [VAR_W-1:0] i_var_addr,
  input  logic [EDGE_W-1:0] i_edge_addr,
  input  logic signed [MSG_W-1:0] i_din,
  output logic signed [MSG_W-1:0] o_dout,
  output logic signed [MSG_W-1:0] o_debug_mem [0:N-1][0:W-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  logic signed [MSG_W-1:0] mem [0:N-1][0:W-1];

  assign o_debug_mem = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer var_idx;
    integer edge_idx;

    if (!i_rst_n) begin
      o_dout <= '0;
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= '0;
        end
      end
    end else if (i_clear) begin
      o_dout <= '0;
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= '0;
        end
      end
    end else if (i_en) begin
      if (i_we) begin
        mem[i_var_addr][i_edge_addr] <= i_din;
      end
      o_dout <= mem[i_var_addr][i_edge_addr];
    end
  end
endmodule
