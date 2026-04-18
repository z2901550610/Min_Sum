`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module ram_m (
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic [ROW_W-1:0] i_r_addr_a0,
  input  logic [ROW_W-1:0] i_r_addr_a1,
  input  logic [ROW_W-1:0] i_r_addr_b0,
  input  logic [ROW_W-1:0] i_r_addr_b1,
  output logic [ROW_STATE_W-1:0] o_dout_a0,
  output logic [ROW_STATE_W-1:0] o_dout_a1,
  output logic [ROW_STATE_W-1:0] o_dout_b0,
  output logic [ROW_STATE_W-1:0] o_dout_b1,
  input  logic i_we0,
  input  logic [ROW_W-1:0] i_w_addr0,
  input  logic [ROW_STATE_W-1:0] i_din0,
  input  logic i_we1,
  input  logic [ROW_W-1:0] i_w_addr1,
  input  logic [ROW_STATE_W-1:0] i_din1
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  logic [ROW_STATE_W-1:0] mem [0:R-1];
  integer row_idx;

  assign o_dout_a0 = mem[i_r_addr_a0];
  assign o_dout_a1 = mem[i_r_addr_a1];
  assign o_dout_b0 = mem[i_r_addr_b0];
  assign o_dout_b1 = mem[i_r_addr_b1];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (row_idx = 0; row_idx < R; row_idx++) begin
        mem[row_idx] <= ROW_STATE_INIT;
      end
    end else if (i_clear) begin
      for (row_idx = 0; row_idx < R; row_idx++) begin
        mem[row_idx] <= ROW_STATE_INIT;
      end
    end else begin
      if (i_we0) begin
        mem[i_w_addr0] <= i_din0;
      end
      if (i_we1) begin
        mem[i_w_addr1] <= i_din1;
      end
    end
  end
endmodule
