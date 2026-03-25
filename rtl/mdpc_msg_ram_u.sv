import mdpc_demo_pkg::*;

module mdpc_msg_ram_u (
  input  logic clk,
  input  logic rst_n,
  input  logic init_en,
  input  logic [N-1:0] init_bits,
  input  logic [VAR_W-1:0] rd_var0,
  input  logic [EDGE_W-1:0] rd_edge0,
  input  logic [VAR_W-1:0] rd_var1,
  input  logic [EDGE_W-1:0] rd_edge1,
  output logic [MSG_W-1:0] rd_msg0,
  output logic [MSG_W-1:0] rd_msg1,
  input  logic wr_en,
  input  logic [VAR_W-1:0] wr_var,
  input  logic [MSG_W-1:0] wr_msgs [0:W-1]
);

  logic [MSG_W-1:0] mem [0:N-1][0:W-1];
  integer var_idx;
  integer edge_idx;

  assign rd_msg0 = mem[rd_var0][rd_edge0];
  assign rd_msg1 = mem[rd_var1][rd_edge1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= msg_from_signed(0);
        end
      end
    end else if (init_en) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= msg_from_signed(gamma_from_bit(init_bits[var_idx]));
        end
      end
    end else if (wr_en) begin
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        mem[wr_var][edge_idx] <= wr_msgs[edge_idx];
      end
    end
  end
endmodule
