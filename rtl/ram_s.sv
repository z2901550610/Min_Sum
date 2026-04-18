`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module ram_s (
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic [VAR_W-1:0] i_r_var0,
  input  logic [EDGE_W-1:0] i_r_edge0,
  input  logic [VAR_W-1:0] i_r_var1,
  input  logic [EDGE_W-1:0] i_r_edge1,
  output logic o_sign0,
  output logic o_sign1,
  input  logic i_we0,
  input  logic [VAR_W-1:0] i_w_var0,
  input  logic [EDGE_W-1:0] i_w_edge0,
  input  logic i_din0,
  input  logic i_we1,
  input  logic [VAR_W-1:0] i_w_var1,
  input  logic [EDGE_W-1:0] i_w_edge1,
  input  logic i_din1
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  logic mem [0:N-1][0:W-1];
  integer var_idx;
  integer edge_idx;

  assign o_sign0 = mem[i_r_var0][i_r_edge0];
  assign o_sign1 = mem[i_r_var1][i_r_edge1];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= 1'b0;
        end
      end
    end else if (i_clear) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= 1'b0;
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
