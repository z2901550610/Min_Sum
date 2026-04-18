`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module ram_m (
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear_all,
  input  logic i_clear_bank,
  input  logic i_clear_bank_sel,
  input  logic i_r_bank_a,
  input  logic [LANE_IDX_W-1:0] i_r_lane_a0,
  input  logic [ROW_W-1:0] i_r_addr_a0,
  input  logic [LANE_IDX_W-1:0] i_r_lane_a1,
  input  logic [ROW_W-1:0] i_r_addr_a1,
  input  logic i_r_bank_b,
  input  logic [LANE_IDX_W-1:0] i_r_lane_b0,
  input  logic [ROW_W-1:0] i_r_addr_b0,
  input  logic [LANE_IDX_W-1:0] i_r_lane_b1,
  input  logic [ROW_W-1:0] i_r_addr_b1,
  output logic [ROW_STATE_W-1:0] o_dout_a0,
  output logic [ROW_STATE_W-1:0] o_dout_a1,
  output logic [ROW_STATE_W-1:0] o_dout_b0,
  output logic [ROW_STATE_W-1:0] o_dout_b1,
  input  logic i_we0,
  input  logic i_w_bank0,
  input  logic [LANE_IDX_W-1:0] i_w_lane0,
  input  logic [ROW_W-1:0] i_w_addr0,
  input  logic [ROW_STATE_W-1:0] i_din0,
  input  logic i_we1,
  input  logic i_w_bank1,
  input  logic [LANE_IDX_W-1:0] i_w_lane1,
  input  logic [ROW_W-1:0] i_w_addr1,
  input  logic [ROW_STATE_W-1:0] i_din1
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  logic [ROW_STATE_W-1:0] mem [0:1][0:L-1][0:R-1];
  integer bank_idx;
  integer lane_idx;
  integer row_idx;

  assign o_dout_a0 = mem[i_r_bank_a][i_r_lane_a0][i_r_addr_a0];
  assign o_dout_a1 = mem[i_r_bank_a][i_r_lane_a1][i_r_addr_a1];
  assign o_dout_b0 = mem[i_r_bank_b][i_r_lane_b0][i_r_addr_b0];
  assign o_dout_b1 = mem[i_r_bank_b][i_r_lane_b1][i_r_addr_b1];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (bank_idx = 0; bank_idx < 2; bank_idx++) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          for (row_idx = 0; row_idx < R; row_idx++) begin
            mem[bank_idx][lane_idx][row_idx] <= ROW_STATE_INIT;
          end
        end
      end
    end else if (i_clear_all) begin
      for (bank_idx = 0; bank_idx < 2; bank_idx++) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          for (row_idx = 0; row_idx < R; row_idx++) begin
            mem[bank_idx][lane_idx][row_idx] <= ROW_STATE_INIT;
          end
        end
      end
    end else if (i_clear_bank) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        for (row_idx = 0; row_idx < R; row_idx++) begin
          mem[i_clear_bank_sel][lane_idx][row_idx] <= ROW_STATE_INIT;
        end
      end
    end else begin
      if (i_we0) begin
        mem[i_w_bank0][i_w_lane0][i_w_addr0] <= i_din0;
      end
      if (i_we1) begin
        mem[i_w_bank1][i_w_lane1][i_w_addr1] <= i_din1;
      end
    end
  end
endmodule
