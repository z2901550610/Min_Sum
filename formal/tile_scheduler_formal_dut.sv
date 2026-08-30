`timescale 1ns / 1ps

// Slang-elaborated adapter for the toy public geometry. Keeping package types
// on this side lets the assertion harness use Yosys's native formal clock.
module tile_scheduler_formal_dut (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    output logic [3:0] state,
    output logic       c2v_valid,
    output logic       v2c_valid,
    output logic       ksign_corr_valid,
    output logic [2:0] c2v_tile_linear,
    output logic [2:0] v2c_tile_linear,
    output logic [0:0] c2v_h_block_idx,
    output logic [1:0] c2v_tile_idx,
    output logic [0:0] v2c_h_block_idx,
    output logic [1:0] v2c_tile_idx,
    output logic [1:0] diag_idx_local,
    output logic [2:0] lane_group_idx,
    output logic       clear_valid,
    output logic [1:0] clear_addr,
    output logic       done,
    output logic [2:0] iter_count
);
  import bike_pkg::*;

  tile_scheduler dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_ksign_corr_done (1'b0),
      .i_cfg_w           (CFG_W_W'(W)),
      .i_cfg_tile_count  (TILE_IDX_W'(TILE_COUNT)),
      .i_cfg_row_seg_size(ROW_BANK_AW'(ROW_SEG_SIZE)),
      .o_state           (state),
      .o_c2v_valid       (c2v_valid),
      .o_v2c_valid       (v2c_valid),
      .o_ksign_corr_valid(ksign_corr_valid),
      .o_c2v_tile_linear (c2v_tile_linear),
      .o_v2c_tile_linear (v2c_tile_linear),
      .o_c2v_h_block_idx (c2v_h_block_idx),
      .o_c2v_tile_idx    (c2v_tile_idx),
      .o_v2c_h_block_idx (v2c_h_block_idx),
      .o_v2c_tile_idx    (v2c_tile_idx),
      .o_diag_idx_local  (diag_idx_local),
      .o_lane_group_idx  (lane_group_idx),
      .o_clear_valid     (clear_valid),
      .o_clear_addr      (clear_addr),
      .o_fill_buf        (),
      .o_active_buf      (),
      .o_final_iter      (),
      .o_iter_first_cycle(),
      .o_iter_last_cycle (),
      .o_done            (done),
      .o_iter_count      (iter_count)
  );
endmodule
