`timescale 1ns / 1ps
// L-lane edge address generator with fixed guard cycles.
(* use_dsp = "no" *)
module edge_addr_gen
  import bike_pkg::*;
(
    input  logic                   i_phase_valid,
    input  logic [  H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [ TILE_IDX_W-1:0] i_tile_idx,
    input  logic [    Q_SEQ_W-1:0] i_q_seq,
    input  logic [  ROW_IDX_W-1:0] i_base_row,
    input  logic [  EDGE_ID_W-1:0] i_edge_id,
    input  logic [    CFG_R_W-1:0] i_cfg_r,
    output logic                   o_valid[0:L-1],
    output logic [  ROW_IDX_W-1:0] o_row_idx[0:L-1],
    output logic [      COL_W-1:0] o_col_idx[0:L-1],
    output logic [  EDGE_ID_W-1:0] o_edge_id[0:L-1],
    output logic [ LANE_IDX_W-1:0] o_row_bank[0:L-1],
    output logic [ROW_BANK_AW-1:0] o_row_addr[0:L-1],
    output logic [ TILE_OFF_W-1:0] o_tile_offset[0:L-1]
);

  localparam int ROW_CALC_W = ROW_IDX_W + 1;
  localparam int OFF_CNT_W = TILE_OFF_W + 1;
  localparam int LANE_SUM_W = LANE_IDX_W + 2;
  localparam logic [OFF_CNT_W-1:0] C_TILE_OFF = OFF_CNT_W'(C_TILE);

  always_comb begin
    logic [ ROW_CALC_W-1:0] tile_base;
    logic [ ROW_CALC_W-1:0] tile_end;
    logic [  OFF_CNT_W-1:0] tile_cols;
    logic [ ROW_CALC_W-1:0] wrap_col;
    logic [ ROW_CALC_W-1:0] wrap_offset;
    logic [    Q_SEQ_W-1:0] wrap_q;
    logic [ LANE_IDX_W-1:0] wrap_lane;
    logic [    Q_SEQ_W-1:0] q_idx;
    logic [ROW_BANK_AW-1:0] base_addr;
    logic [ROW_BANK_AW-1:0] tile_addr_base;
    logic [ROW_BANK_AW-1:0] cfg_r_addr;
    logic [ LANE_IDX_W-1:0] base_bank;
    logic [ LANE_IDX_W-1:0] cfg_r_low;
    logic [ LANE_IDX_W-1:0] cfg_r_borrow_min;
    logic [ LANE_IDX_W-1:0] post_bank_adjust;
    logic [ ROW_CALC_W-1:0] cfg_r_calc;
    logic                   has_wrap;
    logic                   split_en;
    logic                   post_region;

    cfg_r_calc = ROW_CALC_W'(i_cfg_r);
    cfg_r_low = LANE_IDX_W'(int'(i_cfg_r) & (L - 1));
    cfg_r_borrow_min = (cfg_r_low == '0) ? '0 : LANE_IDX_W'(L - int'(cfg_r_low));
    cfg_r_addr = ROW_BANK_AW'(i_cfg_r >> L_SHIFT);
    tile_base = ROW_CALC_W'(i_tile_idx) * ROW_CALC_W'(C_TILE);
    tile_cols = ((tile_base + ROW_CALC_W'(C_TILE)) > cfg_r_calc) ?
                OFF_CNT_W'(cfg_r_calc - tile_base) : C_TILE_OFF;
    tile_end = tile_base + ROW_CALC_W'(tile_cols);
    wrap_col = cfg_r_calc - ROW_CALC_W'(i_base_row);
    wrap_offset = (wrap_col >= tile_base) ? (wrap_col - tile_base) : '0;
    wrap_q = Q_SEQ_W'(wrap_offset >> L_SHIFT);
    wrap_lane = LANE_IDX_W'(wrap_offset[LANE_IDX_W-1:0]);
    has_wrap = (tile_base < wrap_col) && (wrap_col < tile_end);
    split_en = has_wrap && (wrap_lane != '0);
    q_idx = i_q_seq;

    if (split_en) begin
      if (i_q_seq > (wrap_q + Q_SEQ_W'(1))) begin
        q_idx = i_q_seq - Q_SEQ_W'(1);
      end else begin
        q_idx = (i_q_seq <= wrap_q) ? i_q_seq : wrap_q;
      end
    end

    post_region = (tile_base >= wrap_col) ||
                  (has_wrap && ((!split_en && (q_idx >= wrap_q)) ||
                   (split_en && (i_q_seq > wrap_q))));
    base_bank = i_base_row[LANE_IDX_W-1:0];
    base_addr = ROW_BANK_AW'(i_base_row >> L_SHIFT);
    tile_addr_base = ROW_BANK_AW'(i_tile_idx) * ROW_BANK_AW'(Q_BASE);
    post_bank_adjust = post_region ? cfg_r_low : '0;

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_valid[lane_idx] = 1'b0;
      o_row_idx[lane_idx] = '0;
      o_col_idx[lane_idx] = '0;
      o_edge_id[lane_idx] = '0;
      o_row_bank[lane_idx] = '0;
      o_row_addr[lane_idx] = '0;
      o_tile_offset[lane_idx] = '0;
    end

    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      logic [ LANE_IDX_W-1:0] lane_idx;
      logic [  OFF_CNT_W-1:0] offset;
      logic [    OFF_CNT_W:0] offset_sum;
      logic [ ROW_CALC_W-1:0] col_local;
      logic [ROW_BANK_AW-1:0] raw_row_addr;
      logic [ROW_BANK_AW-1:0] row_addr;
      logic [  ROW_IDX_W-1:0] row_idx;
      logic [ LANE_SUM_W-1:0] low_sum;
      logic                   carry_low;
      logic                   borrow_low;
      logic                   lane_valid;

      lane_idx = LANE_IDX_W'(LANE_SUM_W'(bank_idx) + LANE_SUM_W'(post_bank_adjust) +
                              LANE_SUM_W'(L) - LANE_SUM_W'(base_bank));
      offset_sum = {1'b0, OFF_CNT_W'({q_idx, {L_SHIFT{1'b0}}})} + {1'b0, OFF_CNT_W'(lane_idx)};
      offset = OFF_CNT_W'(offset_sum);
      col_local = tile_base + ROW_CALC_W'(offset);
      low_sum = LANE_SUM_W'(base_bank) + LANE_SUM_W'(lane_idx);
      carry_low = low_sum >= LANE_SUM_W'(L);
      borrow_low = (cfg_r_low != '0) && (LANE_IDX_W'(bank_idx) >= cfg_r_borrow_min);
      raw_row_addr = base_addr + tile_addr_base + ROW_BANK_AW'(q_idx) + ROW_BANK_AW'(carry_low);
      row_addr = post_region ? (raw_row_addr - cfg_r_addr - ROW_BANK_AW'(borrow_low)) :
          raw_row_addr;
      row_idx = ROW_IDX_W'(({row_addr, {L_SHIFT{1'b0}}}) + ROW_IDX_W'(bank_idx));
      lane_valid = i_phase_valid && (q_idx < Q_SEQ_W'(Q_BASE)) && !offset_sum[OFF_CNT_W] &&
          (offset < tile_cols);

      if (split_en && (i_q_seq == wrap_q)) begin
        lane_valid &= lane_idx < wrap_lane;
      end else if (split_en && (i_q_seq == (wrap_q + Q_SEQ_W'(1)))) begin
        lane_valid &= lane_idx >= wrap_lane;
      end else if (!split_en && (i_q_seq >= Q_SEQ_W'(Q_BASE))) begin
        lane_valid = 1'b0;
      end

      if (lane_valid) begin
        o_valid[bank_idx] = 1'b1;
        o_row_idx[bank_idx] = ROW_IDX_W'(row_idx);
        o_col_idx[bank_idx] = COL_W'(int'(i_h_block_idx) * int'(i_cfg_r) + int'(col_local));
        o_edge_id[bank_idx] = i_edge_id;
        o_row_bank[bank_idx] = LANE_IDX_W'(bank_idx);
        o_row_addr[bank_idx] = row_addr;
        o_tile_offset[bank_idx] = TILE_OFF_W'(offset);
      end
    end
  end
endmodule
