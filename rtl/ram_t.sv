// Stores c2v messages in signed two's-complement form for VNU reuse.
module ram_t
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_rd_en0,                           // Read enable for port 0.
  input  logic [VAR_W-1:0] i_rd_var_idx0,          // Variable index for read port 0.
  input  logic [EDGE_W-1:0] i_rd_edge_slot0,       // Edge slot for read port 0.
  output logic signed [MSG_W-1:0] o_rd_c2v_tc0,    // c2v data returned on read port 0.
  input  logic i_rd_en1,                           // Read enable for port 1.
  input  logic [VAR_W-1:0] i_rd_var_idx1,          // Variable index for read port 1.
  input  logic [EDGE_W-1:0] i_rd_edge_slot1,       // Edge slot for read port 1.
  output logic signed [MSG_W-1:0] o_rd_c2v_tc1,    // c2v data returned on read port 1.
  input  logic i_wr_en0,                           // Write enable for port 0.
  input  logic [VAR_W-1:0] i_wr_var_idx0,          // Variable index for write port 0.
  input  logic [EDGE_W-1:0] i_wr_edge_slot0,       // Edge slot for write port 0.
  input  logic signed [MSG_W-1:0] i_wr_c2v_tc0,    // c2v data written by port 0.
  input  logic i_wr_en1,                           // Write enable for port 1.
  input  logic [VAR_W-1:0] i_wr_var_idx1,          // Variable index for write port 1.
  input  logic [EDGE_W-1:0] i_wr_edge_slot1,       // Edge slot for write port 1.
  input  logic signed [MSG_W-1:0] i_wr_c2v_tc1     // c2v data written by port 1.
);

  timeunit 1ns;
  timeprecision 1ps;

  // RAM T caches c2v in signed 2's-complement so VNU can accumulate and form
  // u_next without per-cycle sign-magnitude decoding.

  logic signed [MSG_W-1:0] mem [0:N-1][0:W-1];

  assign o_rd_c2v_tc0 = i_rd_en0 ? mem[i_rd_var_idx0][i_rd_edge_slot0] : '0;
  assign o_rd_c2v_tc1 = i_rd_en1 ? mem[i_rd_var_idx1][i_rd_edge_slot1] : '0;

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
      if (i_wr_en0) begin
        mem[i_wr_var_idx0][i_wr_edge_slot0] <= i_wr_c2v_tc0;
      end
      if (i_wr_en1) begin
        mem[i_wr_var_idx1][i_wr_edge_slot1] <= i_wr_c2v_tc1;
      end
    end
  end
endmodule
