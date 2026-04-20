// Stores v2c/u messages in sign-magnitude form for the next iteration.
module ram_u
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_init,
  input  logic i_rd_en0,                      // Read enable for port 0.
  input  logic [VAR_W-1:0] i_rd_var_idx0,     // Variable index for read port 0.
  input  logic [EDGE_W-1:0] i_rd_edge_slot0,  // Edge slot for read port 0.
  output logic [MSG_W-1:0] o_rd_v2c_msg0,     // v2c/u data returned on read port 0.
  input  logic i_rd_en1,                      // Read enable for port 1.
  input  logic [VAR_W-1:0] i_rd_var_idx1,     // Variable index for read port 1.
  input  logic [EDGE_W-1:0] i_rd_edge_slot1,  // Edge slot for read port 1.
  output logic [MSG_W-1:0] o_rd_v2c_msg1,     // v2c/u data returned on read port 1.
  input  logic i_wr_en0,                      // Write enable for port 0.
  input  logic [VAR_W-1:0] i_wr_var_idx0,     // Variable index for write port 0.
  input  logic [EDGE_W-1:0] i_wr_edge_slot0,  // Edge slot for write port 0.
  input  logic [MSG_W-1:0] i_wr_v2c_msg0,     // v2c/u data written by port 0.
  input  logic i_wr_en1,                      // Write enable for port 1.
  input  logic [VAR_W-1:0] i_wr_var_idx1,     // Variable index for write port 1.
  input  logic [EDGE_W-1:0] i_wr_edge_slot1,  // Edge slot for write port 1.
  input  logic [MSG_W-1:0] i_wr_v2c_msg1      // v2c/u data written by port 1.
);

  timeunit 1ns;
  timeprecision 1ps;

  // RAM U stores v2c/u in sign-magnitude, matching CNU_A's sign_xor and
  // min-magnitude datapath.

  logic [MSG_W-1:0] mem [0:N-1][0:W-1];
  integer var_idx;
  integer edge_idx;

  assign o_rd_v2c_msg0 = i_rd_en0 ? mem[i_rd_var_idx0][i_rd_edge_slot0] : '0;
  assign o_rd_v2c_msg1 = i_rd_en1 ? mem[i_rd_var_idx1][i_rd_edge_slot1] : '0;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= '0;
        end
      end
    end else if (i_init) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= {1'b0, D'(C_VAL)};
        end
      end
    end else begin
      if (i_wr_en0) begin
        mem[i_wr_var_idx0][i_wr_edge_slot0] <= i_wr_v2c_msg0;
      end
      if (i_wr_en1) begin
        mem[i_wr_var_idx1][i_wr_edge_slot1] <= i_wr_v2c_msg1;
      end
    end
  end
endmodule
