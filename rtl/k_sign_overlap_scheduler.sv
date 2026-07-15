`timescale 1ns / 1ps
// Fixed-rate tile correction scheduler overlapped with the following V2C tile.
module k_sign_overlap_scheduler
  import bike_pkg::*;
(
    input  logic                        i_clk,
    input  logic                        i_rst_n,
    input  logic                        i_start,
    input  logic [         CFG_W_W-1:0] i_cfg_w,
    input  logic [      TILE_IDX_W-1:0] i_cfg_tile_count,
    output logic                        o_phase_valid,
    output logic [       H_BLOCK_W-1:0] o_h_block_idx,
    output logic [      TILE_IDX_W-1:0] o_tile_idx,
    output logic [      DIAG_IDX_W-1:0] o_diag_idx_local,
    output logic [LANE_GROUP_IDX_W-1:0] o_lane_group_idx,
    output logic                        o_tile_buf_sel,
    output logic                        o_done
);

  localparam int DRAIN_CYCLES = 7;
  localparam int DRAIN_W = $clog2(DRAIN_CYCLES + 1);

  logic                        active_q;
  logic [       H_BLOCK_W-1:0] h_block_idx_q;
  logic [      TILE_IDX_W-1:0] tile_idx_q;
  logic [      DIAG_IDX_W-1:0] diag_idx_local_q;
  logic [LANE_GROUP_IDX_W-1:0] lane_group_idx_q;
  logic [         DRAIN_W-1:0] drain_q;
  logic                        done_q;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      active_q <= 1'b0;
      h_block_idx_q <= '0;
      tile_idx_q <= '0;
      diag_idx_local_q <= '0;
      lane_group_idx_q <= '0;
      drain_q <= '0;
      done_q <= 1'b0;
    end else if (i_start) begin
      active_q <= 1'b1;
      h_block_idx_q <= '0;
      tile_idx_q <= '0;
      diag_idx_local_q <= '0;
      lane_group_idx_q <= '0;
      drain_q <= '0;
      done_q <= 1'b0;
    end else if (active_q) begin
      if (lane_group_idx_q == LANE_GROUP_IDX_W'(Q_TILE - 1)) begin
        lane_group_idx_q <= '0;
        if (diag_idx_local_q == DIAG_IDX_W'(i_cfg_w - CFG_W_W'(1))) begin
          diag_idx_local_q <= '0;
          if (tile_idx_q == TILE_IDX_W'(i_cfg_tile_count - TILE_IDX_W'(1))) begin
            tile_idx_q <= '0;
            if (h_block_idx_q == H_BLOCK_W'(N0 - 1)) begin
              active_q <= 1'b0;
              h_block_idx_q <= '0;
              drain_q <= DRAIN_W'(DRAIN_CYCLES);
            end else begin
              h_block_idx_q <= h_block_idx_q + H_BLOCK_W'(1);
            end
          end else begin
            tile_idx_q <= tile_idx_q + TILE_IDX_W'(1);
          end
        end else begin
          diag_idx_local_q <= diag_idx_local_q + DIAG_IDX_W'(1);
        end
      end else begin
        lane_group_idx_q <= lane_group_idx_q + LANE_GROUP_IDX_W'(1);
      end
    end else if (drain_q != '0) begin
      drain_q <= drain_q - DRAIN_W'(1);
      if (drain_q == DRAIN_W'(1)) begin
        done_q <= 1'b1;
      end
    end
  end

  always_comb begin
    o_phase_valid = active_q;
    o_h_block_idx = h_block_idx_q;
    o_tile_idx = tile_idx_q;
    o_diag_idx_local = diag_idx_local_q;
    o_lane_group_idx = lane_group_idx_q;
    o_tile_buf_sel = (h_block_idx_q[0] & i_cfg_tile_count[0]) ^ tile_idx_q[0];
    o_done = done_q;
  end
endmodule
