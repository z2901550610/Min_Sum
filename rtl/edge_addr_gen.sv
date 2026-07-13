`timescale 1ns / 1ps
// L-lane edge address generator with fixed guard cycles.
(* use_dsp = "no" *)
module edge_addr_gen
  import bike_pkg::*;
(
    input  logic                        i_clk,
    input  logic                        i_rst_n,
    input  logic                        i_phase_valid,
    input  logic [       H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [      TILE_IDX_W-1:0] i_tile_idx,
    input  logic [LANE_GROUP_IDX_W-1:0] i_lane_group_idx,
    input  logic [       ROW_IDX_W-1:0] i_base_row_idx,
    input  logic [      DIAG_IDX_W-1:0] i_diag_idx_local,
    input  logic [         CFG_R_W-1:0] i_cfg_r,
    input  logic [         CFG_W_W-1:0] i_cfg_w,
    output logic                        o_valid[0:L-1],
    output logic [       ROW_IDX_W-1:0] o_check_row_idx[0:L-1],
    output logic [           COL_W-1:0] o_col_idx[0:L-1],
    output logic [   DIAG_GLOBAL_W-1:0] o_diag_idx_global_base,
    output logic [   DIAG_GLOBAL_W-1:0] o_diag_idx_global[0:L-1],
    output logic [      LANE_IDX_W-1:0] o_row_bank[0:L-1],
    output logic [     ROW_BANK_AW-1:0] o_row_addr[0:L-1],
    output logic [      TILE_OFF_W-1:0] o_tile_offset[0:L-1]
);

  localparam int ROW_CALC_W = ROW_IDX_W + 1;
  localparam int OFF_CNT_W = TILE_OFF_W + 1;
  localparam int LANE_SUM_W = LANE_IDX_W + 2;
  localparam logic [OFF_CNT_W-1:0] COLS_PER_TILE_OFF = OFF_CNT_W'(COLS_PER_TILE);

  function automatic logic [DIAG_GLOBAL_W-1:0] h_block_diag_base(
      input  logic [H_BLOCK_W-1:0] h_block_idx, input  logic [CFG_W_W-1:0] cfg_w);
    logic [DIAG_GLOBAL_W-1:0] cfg_w_ext;
    begin
      cfg_w_ext = DIAG_GLOBAL_W'(cfg_w);
      unique case (h_block_idx)
        H_BLOCK_W'(0): h_block_diag_base = '0;
        H_BLOCK_W'(1): h_block_diag_base = cfg_w_ext;
        default:       h_block_diag_base = cfg_w_ext + cfg_w_ext;
      endcase
    end
  endfunction

  function automatic logic [COL_W-1:0] h_block_col_base(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                                        input  logic [CFG_R_W-1:0] cfg_r);
    logic [COL_W-1:0] cfg_r_ext;
    begin
      cfg_r_ext = COL_W'(cfg_r);
      unique case (h_block_idx)
        H_BLOCK_W'(0): h_block_col_base = '0;
        H_BLOCK_W'(1): h_block_col_base = cfg_r_ext;
        default:       h_block_col_base = cfg_r_ext + cfg_r_ext;
      endcase
    end
  endfunction

  logic                        phase_valid_d;
  logic                        phase_valid_q;
  logic [       OFF_CNT_W-1:0] cols_per_tile_d;
  logic [       OFF_CNT_W-1:0] cols_per_tile_q;
  logic [LANE_GROUP_IDX_W-1:0] lane_group_idx_eff_d;
  logic [LANE_GROUP_IDX_W-1:0] lane_group_idx_eff_q;
  logic [     ROW_BANK_AW-1:0] base_addr_d;
  logic [     ROW_BANK_AW-1:0] base_addr_q;
  logic [     ROW_BANK_AW-1:0] tile_addr_base_d;
  logic [     ROW_BANK_AW-1:0] tile_addr_base_q;
  logic [     ROW_BANK_AW-1:0] cfg_r_addr_d;
  logic [     ROW_BANK_AW-1:0] cfg_r_addr_q;
  logic [      LANE_IDX_W-1:0] base_bank_d;
  logic [      LANE_IDX_W-1:0] base_bank_q;
  logic [      LANE_IDX_W-1:0] cfg_r_low_d;
  logic [      LANE_IDX_W-1:0] cfg_r_low_q;
  logic [      LANE_IDX_W-1:0] cfg_r_borrow_min_d;
  logic [      LANE_IDX_W-1:0] cfg_r_borrow_min_q;
  logic [      LANE_IDX_W-1:0] post_bank_adjust_d;
  logic [      LANE_IDX_W-1:0] post_bank_adjust_q;
  logic [      LANE_IDX_W-1:0] wrap_lane_d;
  logic [      LANE_IDX_W-1:0] wrap_lane_q;
  logic [           COL_W-1:0] col_base_d;
  logic [           COL_W-1:0] col_base_q;
  logic [   DIAG_GLOBAL_W-1:0] diag_idx_global_base_d;
  logic [   DIAG_GLOBAL_W-1:0] diag_idx_global_base_q;
  logic                        post_region_d;
  logic                        post_region_q;
  logic                        split_pre_group_d;
  logic                        split_pre_group_q;
  logic                        split_post_group_d;
  logic                        split_post_group_q;

  always_comb begin
    logic [      ROW_CALC_W-1:0] tile_base;
    logic [      ROW_CALC_W-1:0] tile_end;
    logic [       OFF_CNT_W-1:0] cols_per_tile;
    logic [      ROW_CALC_W-1:0] wrap_col;
    logic [      ROW_CALC_W-1:0] wrap_offset;
    logic [LANE_GROUP_IDX_W-1:0] wrap_lane_group_idx;
    logic [      LANE_IDX_W-1:0] wrap_lane;
    logic [LANE_GROUP_IDX_W-1:0] lane_group_idx_eff;
    logic [      LANE_IDX_W-1:0] cfg_r_low;
    logic [      LANE_IDX_W-1:0] cfg_r_borrow_min;
    logic [      ROW_CALC_W-1:0] cfg_r_calc;
    logic                        has_wrap;
    logic                        split_en;
    logic                        post_region;

    cfg_r_calc = ROW_CALC_W'(i_cfg_r);
    diag_idx_global_base_d = h_block_diag_base(i_h_block_idx, i_cfg_w) +
        DIAG_GLOBAL_W'(i_diag_idx_local);
    cfg_r_low = LANE_IDX_W'(i_cfg_r & CFG_R_W'(L - 1));
    cfg_r_borrow_min = (cfg_r_low == '0) ? '0 :
        LANE_IDX_W'(LANE_SUM_W'(L) - LANE_SUM_W'(cfg_r_low));
    tile_base = ROW_CALC_W'(i_tile_idx) * ROW_CALC_W'(COLS_PER_TILE);
    cols_per_tile = ((tile_base + ROW_CALC_W'(COLS_PER_TILE)) > cfg_r_calc) ?
                OFF_CNT_W'(cfg_r_calc - tile_base) : COLS_PER_TILE_OFF;
    tile_end = tile_base + ROW_CALC_W'(cols_per_tile);
    wrap_col = cfg_r_calc - ROW_CALC_W'(i_base_row_idx);
    wrap_offset = (wrap_col >= tile_base) ? (wrap_col - tile_base) : '0;
    wrap_lane_group_idx = LANE_GROUP_IDX_W'(wrap_offset >> L_SHIFT);
    wrap_lane = LANE_IDX_W'(wrap_offset[LANE_IDX_W-1:0]);
    has_wrap = (tile_base < wrap_col) && (wrap_col < tile_end);
    split_en = has_wrap && (wrap_lane != '0);
    lane_group_idx_eff = i_lane_group_idx;

    if (split_en) begin
      if (i_lane_group_idx > (wrap_lane_group_idx + LANE_GROUP_IDX_W'(1))) begin
        lane_group_idx_eff = i_lane_group_idx - LANE_GROUP_IDX_W'(1);
      end else begin
        lane_group_idx_eff = (i_lane_group_idx <= wrap_lane_group_idx) ? i_lane_group_idx :
            wrap_lane_group_idx;
      end
    end

    post_region = (tile_base >= wrap_col) ||
                  (has_wrap && ((!split_en && (lane_group_idx_eff >= wrap_lane_group_idx)) ||
                   (split_en && (i_lane_group_idx > wrap_lane_group_idx))));
    phase_valid_d = i_phase_valid;
    cols_per_tile_d = cols_per_tile;
    lane_group_idx_eff_d = lane_group_idx_eff;
    base_addr_d = ROW_BANK_AW'(i_base_row_idx >> L_SHIFT);
    tile_addr_base_d = ROW_BANK_AW'(tile_base >> L_SHIFT);
    cfg_r_addr_d = ROW_BANK_AW'(i_cfg_r >> L_SHIFT);
    base_bank_d = LANE_IDX_W'(i_base_row_idx);
    cfg_r_low_d = cfg_r_low;
    cfg_r_borrow_min_d = cfg_r_borrow_min;
    post_bank_adjust_d = post_region ? cfg_r_low : '0;
    wrap_lane_d = wrap_lane;
    col_base_d = h_block_col_base(i_h_block_idx, i_cfg_r) + COL_W'(tile_base);
    post_region_d = post_region;
    split_pre_group_d = split_en && (i_lane_group_idx == wrap_lane_group_idx);
    split_post_group_d =
        split_en && (i_lane_group_idx == (wrap_lane_group_idx + LANE_GROUP_IDX_W'(1)));
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      phase_valid_q <= 1'b0;
      cols_per_tile_q <= '0;
      lane_group_idx_eff_q <= '0;
      base_addr_q <= '0;
      tile_addr_base_q <= '0;
      cfg_r_addr_q <= '0;
      base_bank_q <= '0;
      cfg_r_low_q <= '0;
      cfg_r_borrow_min_q <= '0;
      post_bank_adjust_q <= '0;
      wrap_lane_q <= '0;
      col_base_q <= '0;
      diag_idx_global_base_q <= '0;
      post_region_q <= 1'b0;
      split_pre_group_q <= 1'b0;
      split_post_group_q <= 1'b0;
    end else begin
      phase_valid_q <= phase_valid_d;
      cols_per_tile_q <= cols_per_tile_d;
      lane_group_idx_eff_q <= lane_group_idx_eff_d;
      base_addr_q <= base_addr_d;
      tile_addr_base_q <= tile_addr_base_d;
      cfg_r_addr_q <= cfg_r_addr_d;
      base_bank_q <= base_bank_d;
      cfg_r_low_q <= cfg_r_low_d;
      cfg_r_borrow_min_q <= cfg_r_borrow_min_d;
      post_bank_adjust_q <= post_bank_adjust_d;
      wrap_lane_q <= wrap_lane_d;
      col_base_q <= col_base_d;
      diag_idx_global_base_q <= diag_idx_global_base_d;
      post_region_q <= post_region_d;
      split_pre_group_q <= split_pre_group_d;
      split_post_group_q <= split_post_group_d;
    end
  end

  always_comb begin
    o_diag_idx_global_base = diag_idx_global_base_q;

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_valid[lane_idx] = 1'b0;
      o_check_row_idx[lane_idx] = '0;
      o_col_idx[lane_idx] = '0;
      o_diag_idx_global[lane_idx] = '0;
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
      logic [  ROW_IDX_W-1:0] check_row_idx;
      logic [ LANE_SUM_W-1:0] low_sum;
      logic                   carry_low;
      logic                   borrow_low;
      logic                   lane_valid;

      lane_idx = LANE_IDX_W'(LANE_SUM_W'(bank_idx) + LANE_SUM_W'(post_bank_adjust_q) +
                              LANE_SUM_W'(L) - LANE_SUM_W'(base_bank_q));
      offset_sum = {1'b0, OFF_CNT_W'({lane_group_idx_eff_q, {L_SHIFT{1'b0}}})} +
          {1'b0, OFF_CNT_W'(lane_idx)};
      offset = OFF_CNT_W'(offset_sum);
      col_local = ROW_CALC_W'(offset);
      low_sum = LANE_SUM_W'(base_bank_q) + LANE_SUM_W'(lane_idx);
      carry_low = low_sum >= LANE_SUM_W'(L);
      borrow_low = (cfg_r_low_q != '0) && (LANE_IDX_W'(bank_idx) >= cfg_r_borrow_min_q);
      raw_row_addr = base_addr_q + tile_addr_base_q + ROW_BANK_AW'(lane_group_idx_eff_q) +
          ROW_BANK_AW'(carry_low);
      row_addr = post_region_q ?
          (raw_row_addr - cfg_r_addr_q - ROW_BANK_AW'(borrow_low)) :
          raw_row_addr;
      check_row_idx = ROW_IDX_W'(({row_addr, {L_SHIFT{1'b0}}}) + ROW_IDX_W'(bank_idx));
      lane_valid = phase_valid_q &&
          (lane_group_idx_eff_q < LANE_GROUP_IDX_W'(Q_BASE)) &&
          !offset_sum[OFF_CNT_W] &&
          (offset < cols_per_tile_q);

      if (split_pre_group_q) begin
        lane_valid &= lane_idx < wrap_lane_q;
      end else if (split_post_group_q) begin
        lane_valid &= lane_idx >= wrap_lane_q;
      end

      o_valid[bank_idx] = lane_valid;
      o_check_row_idx[bank_idx] = ROW_IDX_W'(check_row_idx);
      o_col_idx[bank_idx] = col_base_q + COL_W'(col_local);
      o_diag_idx_global[bank_idx] = diag_idx_global_base_q;
      o_row_bank[bank_idx] = LANE_IDX_W'(bank_idx);
      o_row_addr[bank_idx] = row_addr;
      o_tile_offset[bank_idx] = TILE_OFF_W'(offset);
    end
  end
endmodule
