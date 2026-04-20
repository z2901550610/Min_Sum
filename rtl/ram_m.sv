// Dual-bank row-state RAM holding compressed check-node state.
module ram_m
  import bike_pkg::*;
(
  input  logic i_clk,                               // Storage clock.
  input  logic i_rst_n,                             // Active-low reset.
  input  logic i_clear_all,                         // Clears both ping-pong banks.
  input  logic i_clear_bank,                        // Clears only the selected bank.
  input  logic i_clear_bank_sel,                    // Bank index used by i_clear_bank.
  input  logic i_r_bank_a,                          // Bank select for read port group A.
  input  logic [LANE_IDX_W-1:0] i_r_lane_a0,        // Lane select for read port A0.
  input  logic [ROW_W-1:0] i_r_addr_a0,             // Row address for read port A0.
  input  logic [LANE_IDX_W-1:0] i_r_lane_a1,        // Lane select for read port A1.
  input  logic [ROW_W-1:0] i_r_addr_a1,             // Row address for read port A1.
  input  logic i_r_bank_b,                          // Bank select for read port group B.
  input  logic [LANE_IDX_W-1:0] i_r_lane_b0,        // Lane select for read port B0.
  input  logic [ROW_W-1:0] i_r_addr_b0,             // Row address for read port B0.
  input  logic [LANE_IDX_W-1:0] i_r_lane_b1,        // Lane select for read port B1.
  input  logic [ROW_W-1:0] i_r_addr_b1,             // Row address for read port B1.
  output logic [ROW_STATE_W-1:0] o_dout_a0,         // Data returned by read port A0.
  output logic [ROW_STATE_W-1:0] o_dout_a1,         // Data returned by read port A1.
  output logic [ROW_STATE_W-1:0] o_dout_b0,         // Data returned by read port B0.
  output logic [ROW_STATE_W-1:0] o_dout_b1,         // Data returned by read port B1.
  input  logic i_we0,                               // Write enable for write port 0.
  input  logic i_w_bank0,                           // Bank select for write port 0.
  input  logic [LANE_IDX_W-1:0] i_w_lane0,          // Lane select for write port 0.
  input  logic [ROW_W-1:0] i_w_addr0,               // Row address for write port 0.
  input  logic [ROW_STATE_W-1:0] i_din0,            // Row-state data for write port 0.
  input  logic i_we1,                               // Write enable for write port 1.
  input  logic i_w_bank1,                           // Bank select for write port 1.
  input  logic [LANE_IDX_W-1:0] i_w_lane1,          // Lane select for write port 1.
  input  logic [ROW_W-1:0] i_w_addr1,               // Row address for write port 1.
  input  logic [ROW_STATE_W-1:0] i_din1             // Row-state data for write port 1.
);

  timeunit 1ns;
  timeprecision 1ps;

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
