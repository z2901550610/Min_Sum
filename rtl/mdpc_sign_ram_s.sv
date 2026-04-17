`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module mdpc_sign_ram_s (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_en,
  input  logic [VAR_W-1:0] rd_var0,
  input  logic [EDGE_W-1:0] rd_edge0,
  input  logic [VAR_W-1:0] rd_var1,
  input  logic [EDGE_W-1:0] rd_edge1,
  output logic rd_sign0,
  output logic rd_sign1,
  input  logic wr_en0,
  input  logic [VAR_W-1:0] wr_var0,
  input  logic [EDGE_W-1:0] wr_edge0,
  input  logic wr_sign0,
  input  logic wr_en1,
  input  logic [VAR_W-1:0] wr_var1,
  input  logic [EDGE_W-1:0] wr_edge1,
  input  logic wr_sign1
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  logic mem [0:N-1][0:W-1];
  integer var_idx;
  integer edge_idx;

  assign rd_sign0 = mem[rd_var0][rd_edge0];
  assign rd_sign1 = mem[rd_var1][rd_edge1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= 1'b0;
        end
      end
    end else if (clear_en) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= 1'b0;
        end
      end
    end else begin
      if (wr_en0) begin
        mem[wr_var0][wr_edge0] <= wr_sign0;
      end
      if (wr_en1) begin
        mem[wr_var1][wr_edge1] <= wr_sign1;
      end
    end
  end
endmodule
