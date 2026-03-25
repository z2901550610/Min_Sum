import mdpc_demo_pkg::*;

module mdpc_msg_ram_t (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_en,
  input  logic [VAR_W-1:0] rd_var,
  output logic [MSG_W-1:0] rd_msgs [0:W-1],
  input  logic wr_en0,
  input  logic [VAR_W-1:0] wr_var0,
  input  logic [EDGE_W-1:0] wr_edge0,
  input  logic [MSG_W-1:0] wr_msg0,
  input  logic wr_en1,
  input  logic [VAR_W-1:0] wr_var1,
  input  logic [EDGE_W-1:0] wr_edge1,
  input  logic [MSG_W-1:0] wr_msg1
);

  logic [MSG_W-1:0] mem [0:N-1][0:W-1];
  always_comb begin
    integer edge_idx_local;

    for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
      rd_msgs[edge_idx_local] = mem[rd_var][edge_idx_local];
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    integer var_idx_local;
    integer edge_idx_local;

    if (!rst_n) begin
      for (var_idx_local = 0; var_idx_local < N; var_idx_local++) begin
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          mem[var_idx_local][edge_idx_local] <= msg_from_signed(0);
        end
      end
    end else if (clear_en) begin
      for (var_idx_local = 0; var_idx_local < N; var_idx_local++) begin
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          mem[var_idx_local][edge_idx_local] <= msg_from_signed(0);
        end
      end
    end else begin
      if (wr_en0) begin
        mem[wr_var0][wr_edge0] <= wr_msg0;
      end
      if (wr_en1) begin
        mem[wr_var1][wr_edge1] <= wr_msg1;
      end
    end
  end
endmodule
