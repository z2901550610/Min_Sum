module ram_t
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_re0,
  input  logic [VAR_W-1:0] i_r_var0,
  input  logic [EDGE_W-1:0] i_r_edge0,
  output logic signed [MSG_W-1:0] o_dout0,
  input  logic i_re1,
  input  logic [VAR_W-1:0] i_r_var1,
  input  logic [EDGE_W-1:0] i_r_edge1,
  output logic signed [MSG_W-1:0] o_dout1,
  input  logic i_we0,
  input  logic [VAR_W-1:0] i_w_var0,
  input  logic [EDGE_W-1:0] i_w_edge0,
  input  logic signed [MSG_W-1:0] i_din0,
  input  logic i_we1,
  input  logic [VAR_W-1:0] i_w_var1,
  input  logic [EDGE_W-1:0] i_w_edge1,
  input  logic signed [MSG_W-1:0] i_din1
);

  timeunit 1ns;
  timeprecision 1ps;

  // RAM T caches c2v in signed 2's-complement so VNU can accumulate and form
  // u_next without per-cycle sign-magnitude decoding.

  logic signed [MSG_W-1:0] mem [0:N-1][0:W-1];

  assign o_dout0 = i_re0 ? mem[i_r_var0][i_r_edge0] : '0;
  assign o_dout1 = i_re1 ? mem[i_r_var1][i_r_edge1] : '0;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer var_idx_local;
    integer edge_idx_local;

    if (!i_rst_n) begin
      for (var_idx_local = 0; var_idx_local < N; var_idx_local++) begin
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          mem[var_idx_local][edge_idx_local] <= '0;
        end
      end
    end else if (i_clear) begin
      for (var_idx_local = 0; var_idx_local < N; var_idx_local++) begin
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          mem[var_idx_local][edge_idx_local] <= '0;
        end
      end
    end else begin
      if (i_we0) begin
        mem[i_w_var0][i_w_edge0] <= i_din0;
      end
      if (i_we1) begin
        mem[i_w_var1][i_w_edge1] <= i_din1;
      end
    end
  end
endmodule
