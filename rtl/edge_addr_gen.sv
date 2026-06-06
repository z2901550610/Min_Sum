`timescale 1ns / 1ps
// L-lane edge address generator with one fixed guard cycle.
module edge_addr_gen
  import bike_pkg::*;
(
    input  logic                   i_phase_valid,
    input  logic [  H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [ TILE_IDX_W-1:0] i_tile_idx,
    input  logic [    Q_SEQ_W-1:0] i_q_seq,
    input  logic [  ROW_IDX_W-1:0] i_base_row,
    input  logic [  EDGE_ID_W-1:0] i_edge_id,
    output logic                   o_valid[0:L-1],
    output logic [  ROW_IDX_W-1:0] o_row_idx[0:L-1],
    output logic [      COL_W-1:0] o_col_idx[0:L-1],
    output logic [  EDGE_ID_W-1:0] o_edge_id[0:L-1],
    output logic [ LANE_IDX_W-1:0] o_row_bank[0:L-1],
    output logic [ROW_BANK_AW-1:0] o_row_addr[0:L-1],
    output logic [ TILE_OFF_W-1:0] o_tile_offset[0:L-1]
);

  always_comb begin
    int tile_base;
    int tile_cols;
    int tile_end;
    int wrap_col;
    int wrap_offset;
    int wrap_q;
    int wrap_lane;
    int q_idx;
    bit has_wrap;
    bit split_en;
    tile_base = int'(i_tile_idx) * C_TILE;
    tile_cols = (tile_base + C_TILE > R) ? (R - tile_base) : C_TILE;
    tile_end = tile_base + tile_cols;
    wrap_col = R - int'(i_base_row);
    wrap_offset = wrap_col - tile_base;
    wrap_q = (wrap_offset >= 0) ? (wrap_offset / L) : 0;
    wrap_lane = (wrap_offset >= 0) ? (wrap_offset % L) : 0;
    has_wrap = (tile_base < wrap_col) && (wrap_col < tile_end);
    split_en = has_wrap && (wrap_lane != 0);
    q_idx = int'(i_q_seq);

    if (split_en) begin
      if (int'(i_q_seq) > (wrap_q + 1)) begin
        q_idx = int'(i_q_seq) - 1;
      end else begin
        q_idx = (int'(i_q_seq) <= wrap_q) ? int'(i_q_seq) : wrap_q;
      end
    end

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_valid[lane_idx] = 1'b0;
      o_row_idx[lane_idx] = '0;
      o_col_idx[lane_idx] = '0;
      o_edge_id[lane_idx] = '0;
      o_row_bank[lane_idx] = '0;
      o_row_addr[lane_idx] = '0;
      o_tile_offset[lane_idx] = '0;
    end

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      int                    offset;
      int                    col_local;
      int                    row_raw;
      int                    row_idx;
      logic [LANE_IDX_W-1:0] out_bank;
      bit                    lane_valid;

      offset = q_idx * L + lane_idx;
      col_local = tile_base + offset;
      row_raw = col_local + int'(i_base_row);
      row_idx = (row_raw >= R) ? (row_raw - R) : row_raw;
      out_bank = LANE_IDX_W'(row_idx % L);
      lane_valid = i_phase_valid && (int'(i_q_seq) < Q_TILE) && (q_idx < Q_BASE) &&
                   (offset < tile_cols);

      if (split_en && (int'(i_q_seq) == wrap_q)) begin
        lane_valid &= lane_idx < wrap_lane;
      end else if (split_en && (int'(i_q_seq) == (wrap_q + 1))) begin
        lane_valid &= lane_idx >= wrap_lane;
      end else if (!split_en && (int'(i_q_seq) >= Q_BASE)) begin
        lane_valid = 1'b0;
      end

      if (lane_valid) begin
        o_valid[out_bank] = 1'b1;
        o_row_idx[out_bank] = ROW_IDX_W'(row_idx);
        o_col_idx[out_bank] = COL_W'(int'(i_h_block_idx) * R + col_local);
        o_edge_id[out_bank] = i_edge_id;
        o_row_bank[out_bank] = out_bank;
        o_row_addr[out_bank] = ROW_BANK_AW'(row_idx / L);
        o_tile_offset[out_bank] = TILE_OFF_W'(offset);
      end
    end
  end
endmodule
