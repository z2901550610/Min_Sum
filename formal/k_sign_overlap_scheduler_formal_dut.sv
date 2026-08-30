`timescale 1ns / 1ps

// Slang-elaborated adapter for the toy public geometry. Keeping package types
// on this side lets the assertion harness use Yosys's native formal clock.
module k_sign_overlap_scheduler_formal_dut (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    output logic       phase_valid,
    output logic [0:0] h_block_idx,
    output logic [1:0] tile_idx,
    output logic [1:0] diag_idx_local,
    output logic [2:0] lane_group_idx,
    output logic       done
);
  import bike_pkg::*;

  k_sign_overlap_scheduler dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_cfg_w         (CFG_W_W'(W)),
      .i_cfg_tile_count(TILE_IDX_W'(TILE_COUNT)),
      .o_phase_valid   (phase_valid),
      .o_h_block_idx   (h_block_idx),
      .o_tile_idx      (tile_idx),
      .o_diag_idx_local(diag_idx_local),
      .o_lane_group_idx(lane_group_idx),
      .o_done          (done)
  );
endmodule
