`timescale 1ns / 1ps
// Steers RAM-S/RAM-T edge-message storage and prepares VNU inputs.
module edge_message_pipe
  import bike_pkg::*;
(
    input  logic                            i_clk,
    input  logic                            i_rst_n,
    input  logic                            i_start,
    input  logic                            i_c2v_write_t,
    input  logic                            i_v2c_emit_to_cnu_a,
    input  logic                            i_vnu_accum_t,
    input  logic                            i_cnu_a_writeback,
    input  logic        [        COL_W-1:0] i_c2v_col_idx,
    input  logic        [        COL_W-1:0] i_c2v_read_col_d1,
    input  logic                            i_c2v_read_d1,
    input  logic                            i_v2c_read,
    input  logic        [  ENTRY_POS_W-1:0] i_v2c_entry_pos,
    input  logic        [  ENTRY_POS_W-1:0] i_v2c_read_entry_pos_d1,
    input  logic        [  ENTRY_POS_W-1:0] i_c2v_latched_entry_pos,
    input  logic                            i_c2v_latched_entry_pos_last,
    input  logic        [    ONE_IDX_W-1:0] i_c2v_latched_one_idx[0:L-1],
    input  logic        [        COL_W-1:0] i_v2c_m_latched_col,
    input  logic        [  ENTRY_POS_W-1:0] i_v2c_m_latched_entry_pos,
    input  logic        [    ONE_IDX_W-1:0] i_v2c_m_latched_one_idx[0:L-1],
    input  logic                            i_v2c_m_latched_group_valid[0:L-1],
    input  logic                            i_c2v_latched_group_valid[0:L-1],
    input  logic        [GROUP_COUNT_W-1:0] i_col_meta_slot_count,
    input  logic                            i_cnu_a_valid[0:L-1],
    input  logic                            i_cnu_a_sign[0:L-1],
    input  logic signed [        MSG_W-1:0] i_c2v_tc[0:L-1],
    input  logic        [     S_WORD_W-1:0] i_s_col_rdata,
    input  logic                            i_t_rvalid[0:L-1],
    input  logic        [        MSG_W-1:0] i_t_rdata[0:L-1],
    output logic                            o_s_rdata[0:L-1],
    output logic                            o_s_col_we,
    output logic        [S_WORD_ADDR_W-1:0] o_s_read_col_idx,
    output logic        [S_WORD_ADDR_W-1:0] o_s_write_col_idx,
    output logic        [     S_WORD_W-1:0] o_s_col_wdata,
    output logic                            o_t_push[0:L-1],
    output logic                            o_t_pop[0:L-1],
    output logic                            o_t_valid[0:L-1],
    output logic        [  ENTRY_POS_W-1:0] o_t_write_entry_idx,
    output logic        [  ENTRY_POS_W-1:0] o_t_read_entry_idx,
    output logic        [        MSG_W-1:0] o_t_wdata[0:L-1],
    output logic                            o_vnu_col_start,
    output logic                            o_vnu_col_end,
    output logic                            o_vnu_accum_valid[0:L-1],
    output logic                            o_vnu_prev_c2v_valid[0:L-1],
    output logic signed [        MSG_W-1:0] o_vnu_prev_c2v[0:L-1]
);

  localparam int T_SCALE_W = MSG_W + ALPHA_FRAC_W;

  logic [S_WORD_W-1:0] s_write_col_reg;
  logic [S_WORD_W-1:0] s_write_col_next;
  logic                s_write_col_last;

  function automatic logic signed [MSG_W-1:0] alpha_scale_msg(
      input  logic signed [MSG_W-1:0] tc_value);
    logic signed [   T_SCALE_W-1:0] scale_ext;
    logic signed [   T_SCALE_W-1:0] scaled_full;
    logic signed [       MSG_W-1:0] floor_tc;
    logic signed [       MSG_W-1:0] trunc_tc;
    logic        [ALPHA_FRAC_W-1:0] frac_bits;
    logic        [  ALPHA_FRAC_W:0] neg_frac_mag;
    logic                           frac_nonzero;
    logic                           round_bit;

    begin
      scale_ext   = T_SCALE_W'($signed(tc_value));
      scaled_full = '0;
      if ((ALPHA_SHIFT_0 > 0) && (ALPHA_SHIFT_0 <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_0));
      end
      if ((ALPHA_SHIFT_1 > 0) && (ALPHA_SHIFT_1 <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_1));
      end

      floor_tc = scaled_full[T_SCALE_W-1:ALPHA_FRAC_W];
      frac_bits = scaled_full[ALPHA_FRAC_W-1:0];
      frac_nonzero = |frac_bits;

      if (scaled_full[T_SCALE_W-1]) begin
        trunc_tc = frac_nonzero ? (floor_tc + 1'b1) : floor_tc;
        neg_frac_mag = frac_nonzero ? ({1'b1, {ALPHA_FRAC_W{1'b0}}} - {1'b0, frac_bits}) : '0;
        round_bit = neg_frac_mag[ALPHA_FRAC_W-1];
        alpha_scale_msg = round_bit ? (trunc_tc - 1'b1) : trunc_tc;
      end else begin
        trunc_tc = floor_tc;
        round_bit = frac_bits[ALPHA_FRAC_W-1];
        alpha_scale_msg = round_bit ? (trunc_tc + 1'b1) : trunc_tc;
      end
    end
  endfunction

  assign o_vnu_col_start = i_vnu_accum_t && (i_c2v_latched_entry_pos == '0);
  assign o_vnu_col_end   = i_vnu_accum_t && i_c2v_latched_entry_pos_last;

  always_comb begin
    integer lane_idx;

    o_s_read_col_idx  = S_WORD_ADDR_W'(i_c2v_read_d1 ? i_c2v_read_col_d1 : i_c2v_col_idx);
    o_s_write_col_idx = S_WORD_ADDR_W'(i_v2c_m_latched_col);
    s_write_col_last  = ((int'(i_v2c_m_latched_entry_pos) + 1) >= int'(i_col_meta_slot_count));
    s_write_col_next  = (i_v2c_m_latched_entry_pos == '0) ? '0 : s_write_col_reg;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (i_c2v_latched_group_valid[lane_idx]) begin
        o_s_rdata[lane_idx] = i_s_col_rdata[i_c2v_latched_one_idx[lane_idx]];
      end else begin
        o_s_rdata[lane_idx] = 1'b0;
      end

      if (i_cnu_a_writeback && i_cnu_a_valid[lane_idx] &&
          i_v2c_m_latched_group_valid[lane_idx]) begin
        s_write_col_next[i_v2c_m_latched_one_idx[lane_idx]] = i_cnu_a_sign[lane_idx];
      end
    end

    o_s_col_we = i_cnu_a_writeback && s_write_col_last;
    o_s_col_wdata = s_write_col_next;
  end

  always_comb begin
    integer lane_idx;

    o_t_write_entry_idx = i_c2v_latched_entry_pos;
    o_t_read_entry_idx  = i_v2c_read ? i_v2c_entry_pos : i_v2c_read_entry_pos_d1;
    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_t_push[lane_idx]  = 1'b0;
      o_t_pop[lane_idx]   = 1'b0;
      o_t_valid[lane_idx] = 1'b0;
      o_t_wdata[lane_idx] = '0;
    end

    if (i_c2v_write_t) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        o_t_push[lane_idx] = 1'b1;
        if (i_c2v_latched_group_valid[lane_idx]) begin
          o_t_valid[lane_idx] = 1'b1;
          o_t_wdata[lane_idx] = alpha_scale_msg(i_c2v_tc[lane_idx]);
        end
      end
    end

    if (i_v2c_emit_to_cnu_a) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        o_t_pop[lane_idx] = 1'b1;
      end
    end
  end

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_vnu_accum_valid[lane_idx] = i_vnu_accum_t && i_c2v_latched_group_valid[lane_idx];
      o_vnu_prev_c2v_valid[lane_idx] = i_v2c_emit_to_cnu_a && i_t_rvalid[lane_idx];
      o_vnu_prev_c2v[lane_idx] = $signed(i_t_rdata[lane_idx]);
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      s_write_col_reg <= '0;
    end else if (i_start) begin
      s_write_col_reg <= '0;
    end else if (i_cnu_a_writeback) begin
      s_write_col_reg <= s_write_col_next;
    end
  end
endmodule
