`timescale 1ns / 1ps
// Top-level tiled min-sum decoder.
module decoder_top
  import bike_pkg::*;
(
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    input  logic                    i_start,
    input  logic [PROFILE_ID_W-1:0] i_profile_sel,
    input  logic                    i_syndrome_we,
    input  logic [   ROW_IDX_W-1:0] i_syndrome_addr,
    input  logic                    i_syndrome_wdata,
    input  logic                    i_h_we,
    input  logic [   H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [  DIAG_IDX_W-1:0] i_h_diag_idx,
    input  logic [   ROW_IDX_W-1:0] i_h_base_row,
    input  logic [       COL_W-1:0] i_e_read_col_idx,
    output logic                    o_h_loaded,
    output logic                    o_h_error,
    output logic                    o_done,
    output logic                    o_e_rdata,
    output logic [      ITER_W-1:0] o_iter_count
);

  localparam bit C2V_WRITE_PIPELINE = (Q_BASE > 1);

`ifndef SYNTHESIS
  initial begin
    if ((L <= 0) || ((L & (L - 1)) != 0)) begin
      $fatal(1, "decoder_top requires L to be a power of two");
    end
    if ((COLS_PER_TILE <= 0) || ((COLS_PER_TILE >= L) && ((COLS_PER_TILE % L) != 0))) begin
      $fatal(
          1,
          "decoder_top requires COLS_PER_TILE to be positive and aligned to L when COLS_PER_TILE >= L");
    end
  end
`endif

  /* verilator lint_off UNUSEDSIGNAL */
  logic        [      DEC_STATE_W-1:0] state;
  logic        [        TILE_ID_W-1:0] unused_c2v_tile_linear;
  logic        [        TILE_ID_W-1:0] unused_v2c_tile_linear;
  logic                                unused_iter_first_cycle;
  logic        [        ROW_IDX_W-1:0] unused_c2v_row_idx[0:L-1];
  logic        [        ROW_IDX_W-1:0] unused_v2c_row_idx[0:L-1];
  logic        [        ROW_IDX_W-1:0] unused_ksign_corr_row_idx[0:L-1];
  logic        [        EDGE_ID_W-1:0] unused_ksign_corr_edge_id[0:L-1];
  logic        [       LANE_IDX_W-1:0] unused_ksign_corr_row_bank[0:L-1];
  logic        [       TILE_OFF_W-1:0] unused_ksign_corr_tile_offset[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic                                c2v_phase_active;
  logic                                v2c_phase_active;
  logic                                ksign_corr_phase_active;
  logic        [        H_BLOCK_W-1:0] c2v_h_block_idx;
  logic        [       TILE_IDX_W-1:0] c2v_tile_idx;
  logic        [        H_BLOCK_W-1:0] v2c_h_block_idx;
  logic        [       TILE_IDX_W-1:0] v2c_tile_idx;
  logic        [       DIAG_IDX_W-1:0] active_diag_idx;
  logic        [          Q_SEQ_W-1:0] active_q_seq;
  logic                                fill_buf;
  logic                                active_buf;
  logic                                final_iter;
  logic                                iter_last_cycle;
  logic                                comp_clear_valid;
  logic        [      ROW_BANK_AW-1:0] comp_clear_addr;
  logic                                decode_start;
  logic                                rst_n_sync;
  logic        [          CFG_R_W-1:0] cfg_r;
  logic        [          CFG_W_W-1:0] cfg_w;
  logic        [       TILE_IDX_W-1:0] cfg_tile_count;
  logic        [      ROW_BANK_AW-1:0] cfg_row_seg_size;
  logic        [       CFG_CVAL_W-1:0] cfg_c_val;
  logic        [CFG_ALPHA_SHIFT_W-1:0] cfg_alpha_shift_0;
  logic        [CFG_ALPHA_SHIFT_W-1:0] cfg_alpha_shift_1;
  logic        [     PROFILE_ID_W-1:0] profile_sel;
  logic        [     PROFILE_ID_W-1:0] profile_sel_in;

  logic        [        ROW_IDX_W-1:0] c2v_h_base_row;
  logic        [        EDGE_ID_W-1:0] c2v_h_edge_id;
  logic        [        ROW_IDX_W-1:0] v2c_h_base_row;
  logic        [        EDGE_ID_W-1:0] v2c_h_edge_id;
  logic        [        ROW_IDX_W-1:0] ksign_corr_h_base_row_e;

  logic                                c2v_phase_h;
  logic        [        H_BLOCK_W-1:0] c2v_h_block_idx_h;
  logic        [       TILE_IDX_W-1:0] c2v_tile_idx_h;
  logic        [       DIAG_IDX_W-1:0] c2v_diag_idx_h;
  logic        [          Q_SEQ_W-1:0] c2v_q_seq_h;
  logic                                c2v_fill_buf_h;
  logic                                c2v_iter_zero_h;
  logic                                comp_read_pair_sel_h;
  logic                                c2v_phase_e;
  logic        [        H_BLOCK_W-1:0] c2v_h_block_idx_e;
  logic        [       TILE_IDX_W-1:0] c2v_tile_idx_e;
  logic        [       DIAG_IDX_W-1:0] c2v_diag_idx_e;
  logic        [          Q_SEQ_W-1:0] c2v_q_seq_e;
  logic                                c2v_fill_buf_e;
  logic                                c2v_iter_zero_e;
  logic        [        ROW_IDX_W-1:0] c2v_h_base_row_e;
  logic        [        EDGE_ID_W-1:0] c2v_h_edge_id_e;
  logic                                comp_read_pair_sel_e;

  logic                                c2v_valid[0:L-1];
  logic        [            COL_W-1:0] c2v_col_idx[0:L-1];
  logic        [        EDGE_ID_W-1:0] c2v_edge_id[0:L-1];
  logic        [       LANE_IDX_W-1:0] c2v_row_bank[0:L-1];
  logic        [      ROW_BANK_AW-1:0] c2v_row_addr[0:L-1];
  logic        [       TILE_OFF_W-1:0] c2v_tile_offset[0:L-1];
  logic                                c2v_valid_r[0:L-1];
  logic        [            COL_W-1:0] c2v_col_idx_r[0:L-1];
  logic        [        EDGE_ID_W-1:0] c2v_edge_id_r[0:L-1];
  logic        [      ROW_BANK_AW-1:0] c2v_row_addr_r[0:L-1];
  logic        [       TILE_OFF_W-1:0] c2v_tile_offset_r[0:L-1];
  logic        [       TILE_IDX_W-1:0] c2v_tile_idx_r;
  logic        [       DIAG_IDX_W-1:0] c2v_diag_idx_r;
  logic        [          Q_SEQ_W-1:0] c2v_q_seq_r;
  logic                                c2v_fill_buf_r;
  logic                                c2v_iter_zero_r;
  logic                                comp_read_pair_sel_r;
  logic                                c2v_valid_q[0:L-1];
  logic        [        EDGE_ID_W-1:0] c2v_edge_id_q[0:L-1];
  logic        [       TILE_OFF_W-1:0] c2v_tile_offset_q[0:L-1];
  logic signed [            ACC_W-1:0] c2v_accum_rdata_q[0:L-1];
  logic                                c2v_syndrome_q[0:L-1];
  logic        [       DIAG_IDX_W-1:0] c2v_diag_idx_q;
  logic        [          Q_SEQ_W-1:0] c2v_q_seq_q;
  logic                                c2v_fill_buf_q;
  logic                                c2v_iter_zero_q;
  logic                                c2v_valid_s[0:L-1];
  logic        [        EDGE_ID_W-1:0] c2v_edge_id_s[0:L-1];
  logic        [       TILE_OFF_W-1:0] c2v_tile_offset_s[0:L-1];
  logic signed [            ACC_W-1:0] c2v_accum_rdata_s[0:L-1];
  logic        [       COMP_C2V_W-1:0] c2v_comp_s[0:L-1];
  logic                                c2v_syndrome_s[0:L-1];
  logic        [       DIAG_IDX_W-1:0] c2v_diag_idx_s;
  logic        [          Q_SEQ_W-1:0] c2v_q_seq_s;
  logic                                c2v_fill_buf_s;
  logic                                c2v_iter_zero_s;
  logic                                c2v_valid_c[0:L-1];
  logic        [        EDGE_ID_W-1:0] c2v_edge_id_c[0:L-1];
  logic        [       TILE_OFF_W-1:0] c2v_tile_offset_c[0:L-1];
  logic signed [            ACC_W-1:0] c2v_accum_rdata_c[0:L-1];
  logic        [       COMP_C2V_W-1:0] c2v_comp_c[0:L-1];
  logic                                c2v_sign_c[0:L-1];
  logic                                c2v_syndrome_c[0:L-1];
  logic        [       DIAG_IDX_W-1:0] c2v_diag_idx_c;
  logic        [          Q_SEQ_W-1:0] c2v_q_seq_c;
  logic                                c2v_fill_buf_c;
  logic                                c2v_iter_zero_c;
  logic                                c2v_valid_p[0:L-1];
  logic        [       TILE_OFF_W-1:0] c2v_tile_offset_p[0:L-1];
  logic        [       DIAG_IDX_W-1:0] c2v_diag_idx_p;
  logic        [          Q_SEQ_W-1:0] c2v_q_seq_p;
  logic                                c2v_fill_buf_p;
  logic        [            MSG_W-1:0] c2v_msg_p[0:L-1];
  logic signed [            ACC_W-1:0] c2v_accum_base_p[0:L-1];
  logic signed [            ACC_W-1:0] c2v_raw_next_p[0:L-1];
  logic signed [            ACC_W-1:0] c2v_accum_next_p[0:L-1];
  logic                                c2v_write_valid[0:L-1];
  logic        [       TILE_OFF_W-1:0] c2v_write_tile_offset[0:L-1];
  logic        [       DIAG_IDX_W-1:0] c2v_write_diag_idx;
  logic        [          Q_SEQ_W-1:0] c2v_write_q_seq;
  logic                                c2v_write_fill_buf;
  logic        [            MSG_W-1:0] c2v_write_msg[0:L-1];
  logic signed [            ACC_W-1:0] c2v_write_accum[0:L-1];

  logic                                v2c_phase_h;
  logic        [        H_BLOCK_W-1:0] v2c_h_block_idx_h;
  logic        [       TILE_IDX_W-1:0] v2c_tile_idx_h;
  logic        [       DIAG_IDX_W-1:0] v2c_diag_idx_h;
  logic        [          Q_SEQ_W-1:0] v2c_q_seq_h;
  logic                                v2c_active_buf_h;
  logic                                v2c_final_iter_h;
  logic                                comp_write_pair_sel_h;
  logic                                v2c_phase_e;
  logic        [        H_BLOCK_W-1:0] v2c_h_block_idx_e;
  logic        [       TILE_IDX_W-1:0] v2c_tile_idx_e;
  logic        [       DIAG_IDX_W-1:0] v2c_diag_idx_e;
  logic        [          Q_SEQ_W-1:0] v2c_q_seq_e;
  logic                                v2c_active_buf_e;
  logic                                v2c_final_iter_e;
  logic        [        ROW_IDX_W-1:0] v2c_h_base_row_e;
  logic        [        EDGE_ID_W-1:0] v2c_h_edge_id_e;
  logic                                comp_write_pair_sel_e;

  logic                                v2c_valid[0:L-1];
  logic        [            COL_W-1:0] v2c_col_idx[0:L-1];
  logic        [        EDGE_ID_W-1:0] v2c_edge_id[0:L-1];
  logic        [       LANE_IDX_W-1:0] v2c_row_bank[0:L-1];
  logic        [      ROW_BANK_AW-1:0] v2c_row_addr[0:L-1];
  logic        [       TILE_OFF_W-1:0] v2c_tile_offset[0:L-1];
  logic                                v2c_valid_r[0:L-1];
  logic        [            COL_W-1:0] v2c_col_idx_r[0:L-1];
  logic        [        EDGE_ID_W-1:0] v2c_edge_id_r[0:L-1];
  logic        [      ROW_BANK_AW-1:0] v2c_row_addr_r[0:L-1];
  logic        [       TILE_OFF_W-1:0] v2c_tile_offset_r[0:L-1];
  logic                                v2c_phase_r;
  logic        [       TILE_IDX_W-1:0] v2c_tile_idx_r;
  logic        [        EDGE_ID_W-1:0] v2c_h_edge_id_r;
  logic        [       DIAG_IDX_W-1:0] v2c_diag_idx_r;
  logic        [          Q_SEQ_W-1:0] v2c_q_seq_r;
  logic                                v2c_active_buf_r;
  logic                                v2c_final_iter_r;
  logic                                comp_write_pair_sel_r;
  logic                                v2c_valid_q[0:L-1];
  logic        [            COL_W-1:0] v2c_col_idx_q[0:L-1];
  logic        [        EDGE_ID_W-1:0] v2c_edge_id_q[0:L-1];
  logic        [      ROW_BANK_AW-1:0] v2c_row_addr_q[0:L-1];
  logic        [       TILE_OFF_W-1:0] v2c_tile_offset_q[0:L-1];
  logic signed [            ACC_W-1:0] v2c_raw_sum_q[0:L-1];
  logic                                v2c_phase_q;
  logic        [       TILE_IDX_W-1:0] v2c_tile_idx_q;
  logic        [        EDGE_ID_W-1:0] v2c_h_edge_id_q;
  logic        [       DIAG_IDX_W-1:0] v2c_diag_idx_q;
  logic        [          Q_SEQ_W-1:0] v2c_q_seq_q;
  logic                                v2c_final_iter_q;
  logic                                v2c_write_pair_sel_q;
  logic                                v2c_phase_s;
  logic        [       TILE_IDX_W-1:0] v2c_tile_idx_s;
  logic        [        EDGE_ID_W-1:0] v2c_h_edge_id_s;
  logic        [       DIAG_IDX_W-1:0] v2c_diag_idx_s;
  logic        [          Q_SEQ_W-1:0] v2c_q_seq_s;
  logic                                v2c_write_pair_sel_s;
  logic                                decision_we_s[0:L-1];
  logic                                v2c_valid_s[0:L-1];
  logic        [            COL_W-1:0] v2c_col_idx_s[0:L-1];
  logic        [        EDGE_ID_W-1:0] v2c_edge_id_s[0:L-1];
  logic        [      ROW_BANK_AW-1:0] v2c_row_addr_s[0:L-1];
  logic        [       TILE_OFF_W-1:0] v2c_tile_offset_s[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_comp_s[0:L-1];
  logic                                v2c_phase_c;
  logic        [       TILE_IDX_W-1:0] v2c_tile_idx_c;
  logic        [        EDGE_ID_W-1:0] v2c_h_edge_id_c;
  logic        [       DIAG_IDX_W-1:0] v2c_diag_idx_c;
  logic        [          Q_SEQ_W-1:0] v2c_q_seq_c;
  logic                                v2c_write_pair_sel_c;
  logic                                v2c_valid_c[0:L-1];
  logic        [            COL_W-1:0] v2c_col_idx_c[0:L-1];
  logic        [        EDGE_ID_W-1:0] v2c_edge_id_c[0:L-1];
  logic        [      ROW_BANK_AW-1:0] v2c_row_addr_c[0:L-1];
  logic        [       TILE_OFF_W-1:0] v2c_tile_offset_c[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_comp_c[0:L-1];
  logic        [            MSG_W-1:0] v2c_msg_c[0:L-1];
  logic                                decision_we_c[0:L-1];
  logic                                decision_wdata_c[0:L-1];
  logic                                v2c_write_phase_p;
  logic        [       TILE_IDX_W-1:0] v2c_write_tile_idx_p;
  logic        [        EDGE_ID_W-1:0] v2c_write_h_edge_id_p;
  logic        [          Q_SEQ_W-1:0] v2c_write_q_seq_p;
  logic                                v2c_write_pair_sel_p;
  logic                                v2c_valid_p[0:L-1];
  logic        [            COL_W-1:0] v2c_col_idx_p[0:L-1];
  logic        [      ROW_BANK_AW-1:0] v2c_row_addr_p[0:L-1];
  logic        [       TILE_OFF_W-1:0] v2c_tile_offset_p[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_comp_p[0:L-1];
  logic                                v2c_sign_p[0:L-1];
  logic                                decision_we_p[0:L-1];
  logic                                decision_wdata_p[0:L-1];
  logic                                v2c_bypass_pair_sel_b;
  logic                                v2c_bypass_valid_b[0:L-1];
  logic        [      ROW_BANK_AW-1:0] v2c_bypass_row_addr_b[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_bypass_comp_b[0:L-1];
  logic                                ksign_corr_phase_h;
  logic        [        H_BLOCK_W-1:0] ksign_corr_h_block_idx_h;
  logic        [       TILE_IDX_W-1:0] ksign_corr_tile_idx_h;
  logic        [       DIAG_IDX_W-1:0] ksign_corr_diag_idx_h;
  logic        [          Q_SEQ_W-1:0] ksign_corr_q_seq_h;
  logic                                ksign_corr_phase_e;
  logic        [        H_BLOCK_W-1:0] ksign_corr_h_block_idx_e;
  logic        [       TILE_IDX_W-1:0] ksign_corr_tile_idx_e;
  logic        [       DIAG_IDX_W-1:0] ksign_corr_diag_idx_e;
  logic        [          Q_SEQ_W-1:0] ksign_corr_q_seq_e;
  logic                                ksign_corr_phase_r;
  logic        [       DIAG_IDX_W-1:0] ksign_corr_diag_idx_r;
  logic                                ksign_corr_valid[0:L-1];
  logic        [            COL_W-1:0] ksign_corr_col_idx[0:L-1];
  logic        [      ROW_BANK_AW-1:0] ksign_corr_row_addr[0:L-1];
  logic                                ksign_corr_valid_r[0:L-1];
  logic        [            COL_W-1:0] ksign_corr_col_idx_r[0:L-1];
  logic        [      ROW_BANK_AW-1:0] ksign_corr_row_addr_r[0:L-1];
  logic                                ksign_corr_valid_q[0:L-1];
  logic        [      ROW_BANK_AW-1:0] ksign_corr_row_addr_q[0:L-1];
  logic                                ksign_corr_hit[0:L-1];
  logic                                comp_flip_valid[0:L-1];
  logic        [      ROW_BANK_AW-1:0] comp_flip_row_addr[0:L-1];

  logic                                syndrome_rdata[0:L-1];
  logic                                comp_read_pair_sel;
  logic                                comp_write_pair_sel;
  logic        [       COMP_C2V_W-1:0] c2v_comp_mem[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_comp_mem[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_comp_eff[0:L-1];
  logic                                c2v_sign_mem[0:L-1];
  logic                                c2v_ksign_sign_mem[0:L-1];
  logic                                c2v_ksign_hit_mem[0:L-1];
  logic                                c2v_ksign_sign_q[0:L-1];
  logic                                ksign_read_pair_sel;
  logic                                ksign_read_valid[0:L-1];
  logic        [            COL_W-1:0] ksign_read_col_idx[0:L-1];
  logic        [       DIAG_IDX_W-1:0] ksign_read_diag_idx;
  logic                                v2c_sign_wdata[0:L-1];
  logic                                v2c_ksign_base_sign[0:L-1];
  logic signed [            ACC_W-1:0] c2v_accum_rdata[0:L-1];
  logic signed [            ACC_W-1:0] v2c_raw_sum[0:L-1];
  logic signed [            ACC_W-1:0] v2c_raw_c2v[0:L-1];
  logic        [            MSG_W-1:0] v2c_c2v_msg[0:L-1];
  logic signed [            MSG_W-1:0] v2c_c2v_tc[0:L-1];
  logic signed [            ACC_W-1:0] c2v_raw_next[0:L-1];
  logic signed [            ACC_W-1:0] v2c_posterior_next[0:L-1];
  logic        [            MSG_W-1:0] v2c_msg_next[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_comp_next[0:L-1];
  logic        [       COMP_C2V_W-1:0] c2v_cnu_b_comp[0:L-1];
  logic        [       COMP_C2V_W-1:0] first_iter_c2v_comp;
  logic                                c2v_cnu_b_sign[0:L-1];
  logic                                c2v_cnu_b_syndrome[0:L-1];
  logic        [            MSG_W-1:0] c2v_msg[0:L-1];
  logic signed [            MSG_W-1:0] c2v_tc[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_cnu_a_comp_in[0:L-1];
  logic        [       COMP_C2V_W-1:0] v2c_cnu_a_comp_out[0:L-1];
  logic        [            MSG_W-1:0] v2c_cnu_a_msg[0:L-1];
  logic                                v2c_cnu_a_sign[0:L-1];
  logic                                decision_we[0:L-1];
  logic                                decision_wdata[0:L-1];
  logic                                ctrl_done;
  logic                                ctrl_done_r;
  logic                                ctrl_done_q;
  logic                                ctrl_done_s;
  logic                                ctrl_done_p;

  assign profile_sel_in = PROFILE_RUNTIME_SELECT ? i_profile_sel : PROFILE_DEFAULT;

  assign decode_start = i_start && o_h_loaded && !o_h_error;
  assign o_done = ctrl_done_p;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  decoder_profile_config u_decoder_profile_config (
      .i_profile_sel(profile_sel),
      .o_r(cfg_r),
      .o_w(cfg_w),
      .o_tile_count(cfg_tile_count),
      .o_row_seg_size(cfg_row_seg_size),
      .o_c_val(cfg_c_val),
      .o_alpha_shift_0(cfg_alpha_shift_0),
      .o_alpha_shift_1(cfg_alpha_shift_1)
  );

  generate
    for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane_cnu
      cnu_b u_cnu_b (
          .i_comp_c2v    (c2v_cnu_b_comp[lane_idx]),
          .i_v2c_sign    (c2v_cnu_b_sign[lane_idx]),
          .i_syndrome_bit(c2v_cnu_b_syndrome[lane_idx]),
          .i_edge_id     (c2v_edge_id_c[lane_idx]),
          .o_c2v_msg     (c2v_msg[lane_idx])
      );

      msg_signmag_to_tc #(
          .D           (D),
          .MSG_W       (MSG_W),
          .MSG_MAG_LSB (MSG_MAG_LSB),
          .MSG_SIGN_BIT(MSG_SIGN_BIT)
      ) u_c2v_msg_to_tc (
          .i_msg(c2v_msg[lane_idx]),
          .o_tc (c2v_tc[lane_idx])
      );

      msg_signmag_to_tc #(
          .D           (D),
          .MSG_W       (MSG_W),
          .MSG_MAG_LSB (MSG_MAG_LSB),
          .MSG_SIGN_BIT(MSG_SIGN_BIT)
      ) u_v2c_c2v_msg_to_tc (
          .i_msg(v2c_c2v_msg[lane_idx]),
          .o_tc (v2c_c2v_tc[lane_idx])
      );

      assign v2c_raw_c2v[lane_idx] = ACC_W'($signed(v2c_c2v_tc[lane_idx]));

      cnu_a u_cnu_a (
          .i_v2c_msg (v2c_cnu_a_msg[lane_idx]),
          .i_edge_id (v2c_edge_id_c[lane_idx]),
          .i_comp_c2v(v2c_cnu_a_comp_in[lane_idx]),
          .o_comp_c2v(v2c_cnu_a_comp_out[lane_idx]),
          .o_sign    (v2c_cnu_a_sign[lane_idx])
      );
    end
  endgenerate

  always_comb begin
    first_iter_c2v_comp = {1'b0, EDGE_ID_W'(0), D'(cfg_c_val), D'(cfg_c_val)};
    ksign_read_pair_sel = ksign_corr_phase_r ? comp_write_pair_sel : comp_read_pair_sel_r;
    ksign_read_diag_idx = ksign_corr_phase_r ? ksign_corr_diag_idx_r : c2v_diag_idx_r;

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      ksign_read_valid[lane_idx] = ksign_corr_phase_r ? ksign_corr_valid_r[lane_idx] :
          c2v_valid_r[lane_idx];
      ksign_read_col_idx[lane_idx] = ksign_corr_phase_r ? ksign_corr_col_idx_r[lane_idx] :
          c2v_col_idx_r[lane_idx];
      ksign_corr_hit[lane_idx] = c2v_ksign_hit_mem[lane_idx];
      c2v_raw_next[lane_idx] = '0;
      v2c_comp_next[lane_idx] = COMP_C2V_INIT;
      v2c_sign_wdata[lane_idx] = v2c_cnu_a_sign[lane_idx];
      v2c_ksign_base_sign[lane_idx] = decision_wdata_c[lane_idx];
      v2c_cnu_a_msg[lane_idx] = v2c_msg_c[lane_idx];
      comp_flip_valid[lane_idx] = ksign_corr_valid_q[lane_idx] && ksign_corr_hit[lane_idx];
      comp_flip_row_addr[lane_idx] = ksign_corr_row_addr_q[lane_idx];
      if (K_SIGN_ENABLE) begin
        v2c_cnu_a_msg[lane_idx][MSG_SIGN_BIT] = decision_wdata_c[lane_idx];
      end
      decision_we[lane_idx] = v2c_valid_q[lane_idx] && v2c_final_iter_q && (v2c_diag_idx_q == '0);
      decision_wdata[lane_idx] = v2c_posterior_next[lane_idx][ACC_W-1];
      c2v_cnu_b_comp[lane_idx] = c2v_iter_zero_c ? first_iter_c2v_comp : c2v_comp_c[lane_idx];
      c2v_cnu_b_sign[lane_idx] = c2v_iter_zero_c ? 1'b0 : c2v_sign_c[lane_idx];
      c2v_cnu_b_syndrome[lane_idx] = c2v_syndrome_c[lane_idx];
      v2c_cnu_a_comp_in[lane_idx] = v2c_valid_c[lane_idx] ? v2c_comp_c[lane_idx] : COMP_C2V_INIT;
      if (v2c_valid_c[lane_idx]) begin
        v2c_comp_next[lane_idx] = v2c_cnu_a_comp_out[lane_idx];
      end

      v2c_comp_eff[lane_idx] = v2c_comp_mem[lane_idx];
      if (v2c_valid_q[lane_idx] && v2c_valid_c[lane_idx] &&
          (v2c_write_pair_sel_c == v2c_write_pair_sel_q) &&
          (v2c_row_addr_c[lane_idx] == v2c_row_addr_q[lane_idx])) begin
        v2c_comp_eff[lane_idx] = v2c_comp_next[lane_idx];
      end else if (v2c_valid_q[lane_idx] && v2c_valid_p[lane_idx] &&
                   (v2c_write_pair_sel_p == v2c_write_pair_sel_q) &&
                   (v2c_row_addr_p[lane_idx] == v2c_row_addr_q[lane_idx])) begin
        v2c_comp_eff[lane_idx] = v2c_comp_p[lane_idx];
      end else if (v2c_valid_q[lane_idx] && v2c_bypass_valid_b[lane_idx] &&
          (v2c_bypass_pair_sel_b == v2c_write_pair_sel_q) &&
          (v2c_bypass_row_addr_b[lane_idx] == v2c_row_addr_q[lane_idx])) begin
        v2c_comp_eff[lane_idx] = v2c_bypass_comp_b[lane_idx];
      end

      if (c2v_valid_c[lane_idx]) begin
        c2v_raw_next[lane_idx] = ACC_W'($signed(c2v_tc[lane_idx]));
      end

      c2v_accum_next_p[lane_idx] = c2v_accum_base_p[lane_idx] + c2v_raw_next_p[lane_idx];
      if (C2V_WRITE_PIPELINE) begin
        c2v_write_valid[lane_idx] = c2v_valid_p[lane_idx];
        c2v_write_tile_offset[lane_idx] = c2v_tile_offset_p[lane_idx];
        c2v_write_msg[lane_idx] = c2v_msg_p[lane_idx];
        c2v_write_accum[lane_idx] = c2v_accum_next_p[lane_idx];
      end else begin
        c2v_write_valid[lane_idx] = c2v_valid_c[lane_idx];
        c2v_write_tile_offset[lane_idx] = c2v_tile_offset_c[lane_idx];
        c2v_write_msg[lane_idx] = c2v_msg[lane_idx];
        c2v_write_accum[lane_idx] =
            ((c2v_diag_idx_c == '0) ? '0 : c2v_accum_rdata_c[lane_idx]) + c2v_raw_next[lane_idx];
      end

    end

    if (C2V_WRITE_PIPELINE) begin
      c2v_write_fill_buf = c2v_fill_buf_p;
      c2v_write_diag_idx = c2v_diag_idx_p;
      c2v_write_q_seq = c2v_q_seq_p;
    end else begin
      c2v_write_fill_buf = c2v_fill_buf_c;
      c2v_write_diag_idx = c2v_diag_idx_c;
      c2v_write_q_seq = c2v_q_seq_c;
    end
  end

  ram_i u_ram_i (
      .i_clk(i_clk),
      .i_rst_n(rst_n_sync),
      .i_clear(1'b0),
      .i_we(i_h_we),
      .i_h_block_idx(i_h_block_idx),
      .i_diag_idx(i_h_diag_idx),
      .i_base_row(i_h_base_row),
      .i_c2v_h_block_idx(c2v_h_block_idx),
      .i_c2v_diag_idx(active_diag_idx),
      .i_v2c_h_block_idx(v2c_h_block_idx),
      .i_v2c_diag_idx(active_diag_idx),
      .i_cfg_r(cfg_r),
      .i_cfg_w(cfg_w),
      .o_c2v_base_row(c2v_h_base_row),
      .o_c2v_edge_id(c2v_h_edge_id),
      .o_v2c_base_row(v2c_h_base_row),
      .o_v2c_edge_id(v2c_h_edge_id),
      .o_loaded(o_h_loaded),
      .o_error(o_h_error)
  );

  tile_scheduler u_tile_scheduler (
      .i_clk(i_clk),
      .i_rst_n(rst_n_sync),
      .i_start(decode_start),
      .i_cfg_w(cfg_w),
      .i_cfg_tile_count(cfg_tile_count),
      .i_cfg_row_seg_size(cfg_row_seg_size),
      .o_state(state),
      .o_c2v_valid(c2v_phase_active),
      .o_v2c_valid(v2c_phase_active),
      .o_ksign_corr_valid(ksign_corr_phase_active),
      .o_c2v_tile_linear(unused_c2v_tile_linear),
      .o_v2c_tile_linear(unused_v2c_tile_linear),
      .o_c2v_h_block_idx(c2v_h_block_idx),
      .o_c2v_tile_idx(c2v_tile_idx),
      .o_v2c_h_block_idx(v2c_h_block_idx),
      .o_v2c_tile_idx(v2c_tile_idx),
      .o_diag_idx(active_diag_idx),
      .o_q_seq(active_q_seq),
      .o_clear_valid(comp_clear_valid),
      .o_clear_addr(comp_clear_addr),
      .o_fill_buf(fill_buf),
      .o_active_buf(active_buf),
      .o_final_iter(final_iter),
      .o_iter_first_cycle(unused_iter_first_cycle),
      .o_iter_last_cycle(iter_last_cycle),
      .o_done(ctrl_done),
      .o_iter_count(o_iter_count)
  );

  edge_addr_gen u_c2v_addr_gen (
      .i_phase_valid(c2v_phase_e),
      .i_h_block_idx(c2v_h_block_idx_e),
      .i_tile_idx(c2v_tile_idx_e),
      .i_q_seq(c2v_q_seq_e),
      .i_base_row(c2v_h_base_row_e),
      .i_edge_id(c2v_h_edge_id_e),
      .i_cfg_r(cfg_r),
      .o_valid(c2v_valid),
      .o_row_idx(unused_c2v_row_idx),
      .o_col_idx(c2v_col_idx),
      .o_edge_id(c2v_edge_id),
      .o_row_bank(c2v_row_bank),
      .o_row_addr(c2v_row_addr),
      .o_tile_offset(c2v_tile_offset)
  );

  edge_addr_gen u_v2c_addr_gen (
      .i_phase_valid(v2c_phase_e),
      .i_h_block_idx(v2c_h_block_idx_e),
      .i_tile_idx(v2c_tile_idx_e),
      .i_q_seq(v2c_q_seq_e),
      .i_base_row(v2c_h_base_row_e),
      .i_edge_id(v2c_h_edge_id_e),
      .i_cfg_r(cfg_r),
      .o_valid(v2c_valid),
      .o_row_idx(unused_ksign_corr_row_idx),
      .o_col_idx(v2c_col_idx),
      .o_edge_id(v2c_edge_id),
      .o_row_bank(v2c_row_bank),
      .o_row_addr(v2c_row_addr),
      .o_tile_offset(v2c_tile_offset)
  );

  edge_addr_gen u_ksign_corr_addr_gen (
      .i_phase_valid(ksign_corr_phase_e),
      .i_h_block_idx(ksign_corr_h_block_idx_e),
      .i_tile_idx(ksign_corr_tile_idx_e),
      .i_q_seq(ksign_corr_q_seq_e),
      .i_base_row(ksign_corr_h_base_row_e),
      .i_edge_id('0),
      .i_cfg_r(cfg_r),
      .o_valid(ksign_corr_valid),
      .o_row_idx(unused_ksign_corr_row_idx),
      .o_col_idx(ksign_corr_col_idx),
      .o_edge_id(unused_ksign_corr_edge_id),
      .o_row_bank(unused_ksign_corr_row_bank),
      .o_row_addr(ksign_corr_row_addr),
      .o_tile_offset(unused_ksign_corr_tile_offset)
  );

  ram_m u_ram_m (
      .i_clk(i_clk),
      .i_rst_n(rst_n_sync),
      .i_clear_valid(comp_clear_valid),
      .i_clear_pair_sel(comp_write_pair_sel),
      .i_clear_row_addr(comp_clear_addr),
      .i_c2v_pair_sel(comp_read_pair_sel_r),
      .i_c2v_valid(c2v_valid_r),
      .i_c2v_row_addr(c2v_row_addr_r),
      .o_c2v_comp(c2v_comp_mem),
      .i_v2c_pair_sel(comp_write_pair_sel_r),
      .i_v2c_valid(v2c_valid_r),
      .i_v2c_row_addr(v2c_row_addr_r),
      .o_v2c_comp(v2c_comp_mem),
      .i_v2c_write_pair_sel(v2c_write_pair_sel_p),
      .i_v2c_write_valid(v2c_valid_p),
      .i_v2c_write_row_addr(v2c_row_addr_p),
      .i_v2c_write_data(v2c_comp_p),
      .i_flip_pair_sel(comp_write_pair_sel),
      .i_flip_valid(comp_flip_valid),
      .i_flip_row_addr(comp_flip_row_addr)
  );

  ram_s u_ram_s (
      .i_clk(i_clk),
      .i_rst_n(rst_n_sync),
      .i_c2v_valid(c2v_valid_r),
      .i_c2v_tile_idx(c2v_tile_idx_r),
      .i_c2v_tile_offset(c2v_tile_offset_r),
      .i_c2v_edge_id(c2v_edge_id_r),
      .o_c2v_sign(c2v_sign_mem),
      .i_v2c_phase_valid(v2c_write_phase_p),
      .i_v2c_tile_idx(v2c_write_tile_idx_p),
      .i_v2c_q_seq(v2c_write_q_seq_p),
      .i_v2c_edge_id(v2c_write_h_edge_id_p),
      .i_v2c_write_valid(v2c_valid_p),
      .i_v2c_tile_offset(v2c_tile_offset_p),
      .i_v2c_sign(v2c_sign_p)
  );

  ram_k_sign u_ram_k_sign (
      .i_clk          (i_clk),
      .i_rst_n        (rst_n_sync),
      .i_c2v_pair_sel (ksign_read_pair_sel),
      .i_c2v_valid    (ksign_read_valid),
      .i_c2v_col_idx  (ksign_read_col_idx),
      .i_c2v_diag_idx (ksign_read_diag_idx),
      .o_c2v_sign     (c2v_ksign_sign_mem),
      .o_c2v_hit      (c2v_ksign_hit_mem),
      .i_v2c_pair_sel (v2c_write_pair_sel_c),
      .i_v2c_valid    (v2c_valid_c),
      .i_v2c_col_idx  (v2c_col_idx_c),
      .i_v2c_diag_idx (v2c_diag_idx_c),
      .i_v2c_msg      (v2c_msg_c),
      .i_v2c_base_sign(v2c_ksign_base_sign)
  );

  ram_t_accum u_ram_t_accum (
      .i_clk(i_clk),
      .i_c2v_read_buf(c2v_fill_buf_r),
      .i_c2v_read_valid(c2v_valid_r),
      .i_c2v_read_tile_offset(c2v_tile_offset_r),
      .o_c2v_rdata(c2v_accum_rdata),
      .i_c2v_write_buf(c2v_write_fill_buf),
      .i_c2v_write_valid(c2v_write_valid),
      .i_c2v_write_tile_offset(c2v_write_tile_offset),
      .i_c2v_wdata(c2v_write_accum),
      .i_active_buf(v2c_active_buf_r),
      .i_v2c_valid(v2c_valid_r),
      .i_v2c_tile_offset(v2c_tile_offset_r),
      .o_v2c_rdata(v2c_raw_sum)
  );

  ram_t u_ram_t (
      .i_clk(i_clk),
      .i_fill_buf(c2v_write_fill_buf),
      .i_c2v_write_valid(c2v_write_valid),
      .i_c2v_write_diag_idx(c2v_write_diag_idx),
      .i_c2v_write_q_seq(c2v_write_q_seq),
      .i_c2v_write_data(c2v_write_msg),
      .i_active_buf(v2c_active_buf_r),
      .i_v2c_valid(v2c_valid_r),
      .i_v2c_diag_idx(v2c_diag_idx_r),
      .i_v2c_q_seq(v2c_q_seq_r),
      .o_v2c_rdata(v2c_c2v_msg)
  );

  vnu_update u_vnu_update (
      .i_clk(i_clk),
      .i_rst_n(rst_n_sync),
      .i_valid(v2c_valid_q),
      .i_raw_sum(v2c_raw_sum_q),
      .i_raw_c2v(v2c_raw_c2v),
      .i_cfg_c_val(cfg_c_val),
      .i_cfg_alpha_shift_0(cfg_alpha_shift_0),
      .i_cfg_alpha_shift_1(cfg_alpha_shift_1),
      .o_posterior(v2c_posterior_next),
      .o_v2c_msg(v2c_msg_next)
  );

  ram_c1 u_ram_c1 (
      .i_clk(i_clk),
      .i_we(decision_we_p),
      .i_write_col_idx(v2c_col_idx_p),
      .i_wdata(decision_wdata_p),
      .i_read_col_idx(i_e_read_col_idx),
      .o_rdata(o_e_rdata)
  );

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    for (int lhs = 0; lhs < L; lhs++) begin
      for (int rhs = lhs + 1; rhs < L; rhs++) begin
        if (c2v_valid[lhs] && c2v_valid[rhs] && (c2v_row_bank[lhs] == c2v_row_bank[rhs])) begin
          $fatal(1, "decoder_top c2v row-bank conflict bank=%0d", c2v_row_bank[lhs]);
        end
        if (v2c_valid[lhs] && v2c_valid[rhs] && (v2c_row_bank[lhs] == v2c_row_bank[rhs])) begin
          $fatal(1, "decoder_top v2c row-bank conflict bank=%0d", v2c_row_bank[lhs]);
        end
      end
    end
  end

`endif

  always_ff @(posedge i_clk or negedge rst_n_sync) begin
    if (!rst_n_sync) begin
      profile_sel <= PROFILE_DEFAULT;
      c2v_diag_idx_q <= '0;
      c2v_q_seq_q <= '0;
      c2v_fill_buf_q <= 1'b0;
      c2v_iter_zero_q <= 1'b0;
      c2v_diag_idx_s <= '0;
      c2v_q_seq_s <= '0;
      c2v_fill_buf_s <= 1'b0;
      c2v_iter_zero_s <= 1'b0;
      c2v_diag_idx_c <= '0;
      c2v_q_seq_c <= '0;
      c2v_fill_buf_c <= 1'b0;
      c2v_iter_zero_c <= 1'b0;
      c2v_diag_idx_p <= '0;
      c2v_q_seq_p <= '0;
      c2v_fill_buf_p <= 1'b0;
      c2v_phase_h <= 1'b0;
      c2v_h_block_idx_h <= '0;
      c2v_tile_idx_h <= '0;
      c2v_diag_idx_h <= '0;
      c2v_q_seq_h <= '0;
      c2v_fill_buf_h <= 1'b0;
      c2v_iter_zero_h <= 1'b0;
      comp_read_pair_sel_h <= 1'b0;
      c2v_phase_e <= 1'b0;
      c2v_h_block_idx_e <= '0;
      c2v_tile_idx_e <= '0;
      c2v_diag_idx_e <= '0;
      c2v_q_seq_e <= '0;
      c2v_fill_buf_e <= 1'b0;
      c2v_iter_zero_e <= 1'b0;
      c2v_h_base_row_e <= '0;
      c2v_h_edge_id_e <= '0;
      comp_read_pair_sel_e <= 1'b0;
      c2v_diag_idx_r <= '0;
      c2v_q_seq_r <= '0;
      c2v_tile_idx_r <= '0;
      c2v_fill_buf_r <= 1'b0;
      c2v_iter_zero_r <= 1'b0;
      comp_read_pair_sel_r <= 1'b0;
      v2c_diag_idx_q <= '0;
      v2c_q_seq_q <= '0;
      v2c_phase_h <= 1'b0;
      v2c_h_block_idx_h <= '0;
      v2c_tile_idx_h <= '0;
      v2c_diag_idx_h <= '0;
      v2c_q_seq_h <= '0;
      v2c_active_buf_h <= 1'b0;
      v2c_final_iter_h <= 1'b0;
      comp_write_pair_sel_h <= 1'b0;
      v2c_phase_q <= 1'b0;
      v2c_tile_idx_q <= '0;
      v2c_h_edge_id_q <= '0;
      v2c_final_iter_q <= 1'b0;
      v2c_phase_s <= 1'b0;
      v2c_tile_idx_s <= '0;
      v2c_h_edge_id_s <= '0;
      v2c_diag_idx_s <= '0;
      v2c_q_seq_s <= '0;
      v2c_write_pair_sel_s <= 1'b0;
      v2c_phase_c <= 1'b0;
      v2c_tile_idx_c <= '0;
      v2c_h_edge_id_c <= '0;
      v2c_diag_idx_c <= '0;
      v2c_q_seq_c <= '0;
      v2c_write_pair_sel_c <= 1'b0;
      v2c_write_phase_p <= 1'b0;
      v2c_write_tile_idx_p <= '0;
      v2c_write_h_edge_id_p <= '0;
      v2c_write_q_seq_p <= '0;
      v2c_write_pair_sel_p <= 1'b0;
      v2c_bypass_pair_sel_b <= 1'b0;
      ksign_corr_phase_h <= 1'b0;
      ksign_corr_h_block_idx_h <= '0;
      ksign_corr_tile_idx_h <= '0;
      ksign_corr_diag_idx_h <= '0;
      ksign_corr_q_seq_h <= '0;
      ksign_corr_phase_e <= 1'b0;
      ksign_corr_h_block_idx_e <= '0;
      ksign_corr_tile_idx_e <= '0;
      ksign_corr_diag_idx_e <= '0;
      ksign_corr_q_seq_e <= '0;
      ksign_corr_h_base_row_e <= '0;
      ksign_corr_phase_r <= 1'b0;
      ksign_corr_diag_idx_r <= '0;
      v2c_phase_e <= 1'b0;
      v2c_h_block_idx_e <= '0;
      v2c_tile_idx_e <= '0;
      v2c_diag_idx_e <= '0;
      v2c_q_seq_e <= '0;
      v2c_active_buf_e <= 1'b0;
      v2c_final_iter_e <= 1'b0;
      v2c_h_base_row_e <= '0;
      v2c_h_edge_id_e <= '0;
      comp_write_pair_sel_e <= 1'b0;
      v2c_phase_r <= 1'b0;
      v2c_tile_idx_r <= '0;
      v2c_h_edge_id_r <= '0;
      v2c_diag_idx_r <= '0;
      v2c_q_seq_r <= '0;
      v2c_active_buf_r <= 1'b0;
      v2c_final_iter_r <= 1'b0;
      comp_write_pair_sel_r <= 1'b0;
      v2c_write_pair_sel_q <= 1'b0;
      ctrl_done_r <= 1'b0;
      ctrl_done_q <= 1'b0;
      ctrl_done_s <= 1'b0;
      ctrl_done_p <= 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_valid_r[lane_idx] <= 1'b0;
        c2v_col_idx_r[lane_idx] <= '0;
        c2v_edge_id_r[lane_idx] <= '0;
        c2v_row_addr_r[lane_idx] <= '0;
        c2v_tile_offset_r[lane_idx] <= '0;
        c2v_valid_q[lane_idx] <= 1'b0;
        c2v_edge_id_q[lane_idx] <= '0;
        c2v_tile_offset_q[lane_idx] <= '0;
        c2v_accum_rdata_q[lane_idx] <= '0;
        c2v_syndrome_q[lane_idx] <= 1'b0;
        c2v_valid_s[lane_idx] <= 1'b0;
        c2v_edge_id_s[lane_idx] <= '0;
        c2v_tile_offset_s[lane_idx] <= '0;
        c2v_accum_rdata_s[lane_idx] <= '0;
        c2v_comp_s[lane_idx] <= COMP_C2V_INIT;
        c2v_syndrome_s[lane_idx] <= 1'b0;
        c2v_valid_c[lane_idx] <= 1'b0;
        c2v_edge_id_c[lane_idx] <= '0;
        c2v_tile_offset_c[lane_idx] <= '0;
        c2v_accum_rdata_c[lane_idx] <= '0;
        c2v_comp_c[lane_idx] <= COMP_C2V_INIT;
        c2v_sign_c[lane_idx] <= 1'b0;
        c2v_syndrome_c[lane_idx] <= 1'b0;
        c2v_valid_p[lane_idx] <= 1'b0;
        c2v_tile_offset_p[lane_idx] <= '0;
        c2v_msg_p[lane_idx] <= '0;
        c2v_accum_base_p[lane_idx] <= '0;
        c2v_raw_next_p[lane_idx] <= '0;
        c2v_ksign_sign_q[lane_idx] <= 1'b0;
        v2c_valid_r[lane_idx] <= 1'b0;
        v2c_col_idx_r[lane_idx] <= '0;
        v2c_edge_id_r[lane_idx] <= '0;
        v2c_row_addr_r[lane_idx] <= '0;
        v2c_tile_offset_r[lane_idx] <= '0;
        v2c_valid_q[lane_idx] <= 1'b0;
        v2c_col_idx_q[lane_idx] <= '0;
        v2c_edge_id_q[lane_idx] <= '0;
        v2c_row_addr_q[lane_idx] <= '0;
        v2c_tile_offset_q[lane_idx] <= '0;
        v2c_raw_sum_q[lane_idx] <= '0;
        v2c_valid_s[lane_idx] <= 1'b0;
        v2c_col_idx_s[lane_idx] <= '0;
        v2c_edge_id_s[lane_idx] <= '0;
        v2c_row_addr_s[lane_idx] <= '0;
        v2c_tile_offset_s[lane_idx] <= '0;
        v2c_comp_s[lane_idx] <= COMP_C2V_INIT;
        decision_we_s[lane_idx] <= 1'b0;
        v2c_valid_c[lane_idx] <= 1'b0;
        v2c_col_idx_c[lane_idx] <= '0;
        v2c_edge_id_c[lane_idx] <= '0;
        v2c_row_addr_c[lane_idx] <= '0;
        v2c_tile_offset_c[lane_idx] <= '0;
        v2c_comp_c[lane_idx] <= COMP_C2V_INIT;
        v2c_msg_c[lane_idx] <= '0;
        decision_we_c[lane_idx] <= 1'b0;
        decision_wdata_c[lane_idx] <= 1'b0;
        v2c_valid_p[lane_idx] <= 1'b0;
        v2c_col_idx_p[lane_idx] <= '0;
        v2c_row_addr_p[lane_idx] <= '0;
        v2c_tile_offset_p[lane_idx] <= '0;
        v2c_comp_p[lane_idx] <= COMP_C2V_INIT;
        v2c_sign_p[lane_idx] <= 1'b0;
        decision_we_p[lane_idx] <= 1'b0;
        decision_wdata_p[lane_idx] <= 1'b0;
        v2c_bypass_valid_b[lane_idx] <= 1'b0;
        v2c_bypass_row_addr_b[lane_idx] <= '0;
        v2c_bypass_comp_b[lane_idx] <= COMP_C2V_INIT;
        ksign_corr_valid_r[lane_idx] <= 1'b0;
        ksign_corr_col_idx_r[lane_idx] <= '0;
        ksign_corr_row_addr_r[lane_idx] <= '0;
        ksign_corr_valid_q[lane_idx] <= 1'b0;
        ksign_corr_row_addr_q[lane_idx] <= '0;
      end
    end else begin
      if ((state == DEC_WAIT_START) || ((state == DEC_DONE) && ctrl_done_p)) begin
        profile_sel <= profile_sel_in;
      end

      c2v_phase_h <= c2v_phase_active;
      c2v_h_block_idx_h <= c2v_h_block_idx;
      c2v_tile_idx_h <= c2v_tile_idx;
      c2v_diag_idx_h <= active_diag_idx;
      c2v_q_seq_h <= active_q_seq;
      c2v_fill_buf_h <= fill_buf;
      c2v_iter_zero_h <= o_iter_count == '0;
      comp_read_pair_sel_h <= comp_read_pair_sel;
      c2v_phase_e <= c2v_phase_h;
      c2v_h_block_idx_e <= c2v_h_block_idx_h;
      c2v_tile_idx_e <= c2v_tile_idx_h;
      c2v_diag_idx_e <= c2v_diag_idx_h;
      c2v_q_seq_e <= c2v_q_seq_h;
      c2v_fill_buf_e <= c2v_fill_buf_h;
      c2v_iter_zero_e <= c2v_iter_zero_h;
      c2v_h_base_row_e <= c2v_h_base_row;
      c2v_h_edge_id_e <= c2v_h_edge_id;
      comp_read_pair_sel_e <= comp_read_pair_sel_h;
      c2v_diag_idx_r <= c2v_diag_idx_e;
      c2v_q_seq_r <= c2v_q_seq_e;
      c2v_tile_idx_r <= c2v_tile_idx_e;
      c2v_fill_buf_r <= c2v_fill_buf_e;
      c2v_iter_zero_r <= c2v_iter_zero_e;
      comp_read_pair_sel_r <= comp_read_pair_sel_e;
      c2v_diag_idx_q <= c2v_diag_idx_r;
      c2v_q_seq_q <= c2v_q_seq_r;
      c2v_fill_buf_q <= c2v_fill_buf_r;
      c2v_iter_zero_q <= c2v_iter_zero_r;
      c2v_diag_idx_s <= c2v_diag_idx_q;
      c2v_q_seq_s <= c2v_q_seq_q;
      c2v_fill_buf_s <= c2v_fill_buf_q;
      c2v_iter_zero_s <= c2v_iter_zero_q;
      c2v_diag_idx_c <= c2v_diag_idx_s;
      c2v_q_seq_c <= c2v_q_seq_s;
      c2v_fill_buf_c <= c2v_fill_buf_s;
      c2v_iter_zero_c <= c2v_iter_zero_s;
      c2v_diag_idx_p <= c2v_diag_idx_c;
      c2v_q_seq_p <= c2v_q_seq_c;
      c2v_fill_buf_p <= c2v_fill_buf_c;

      v2c_phase_h <= v2c_phase_active;
      v2c_h_block_idx_h <= v2c_h_block_idx;
      v2c_tile_idx_h <= v2c_tile_idx;
      v2c_diag_idx_h <= active_diag_idx;
      v2c_q_seq_h <= active_q_seq;
      v2c_active_buf_h <= active_buf;
      v2c_final_iter_h <= final_iter;
      comp_write_pair_sel_h <= comp_write_pair_sel;
      v2c_phase_e <= v2c_phase_h;
      v2c_h_block_idx_e <= v2c_h_block_idx_h;
      v2c_tile_idx_e <= v2c_tile_idx_h;
      v2c_diag_idx_e <= v2c_diag_idx_h;
      v2c_q_seq_e <= v2c_q_seq_h;
      v2c_active_buf_e <= v2c_active_buf_h;
      v2c_final_iter_e <= v2c_final_iter_h;
      v2c_h_base_row_e <= v2c_h_base_row;
      v2c_h_edge_id_e <= v2c_h_edge_id;
      comp_write_pair_sel_e <= comp_write_pair_sel_h;
      v2c_phase_r <= v2c_phase_e;
      v2c_tile_idx_r <= v2c_tile_idx_e;
      v2c_h_edge_id_r <= v2c_h_edge_id_e;
      v2c_diag_idx_r <= v2c_diag_idx_e;
      v2c_q_seq_r <= v2c_q_seq_e;
      v2c_active_buf_r <= v2c_active_buf_e;
      v2c_final_iter_r <= v2c_final_iter_e;
      comp_write_pair_sel_r <= comp_write_pair_sel_e;
      v2c_phase_q <= v2c_phase_r;
      v2c_tile_idx_q <= v2c_tile_idx_r;
      v2c_h_edge_id_q <= v2c_h_edge_id_r;
      v2c_diag_idx_q <= v2c_diag_idx_r;
      v2c_q_seq_q <= v2c_q_seq_r;
      v2c_final_iter_q <= v2c_final_iter_r;
      v2c_write_pair_sel_q <= comp_write_pair_sel_r;
      v2c_phase_s <= v2c_phase_q;
      v2c_tile_idx_s <= v2c_tile_idx_q;
      v2c_h_edge_id_s <= v2c_h_edge_id_q;
      v2c_diag_idx_s <= v2c_diag_idx_q;
      v2c_q_seq_s <= v2c_q_seq_q;
      v2c_write_pair_sel_s <= v2c_write_pair_sel_q;
      v2c_phase_c <= v2c_phase_s;
      v2c_tile_idx_c <= v2c_tile_idx_s;
      v2c_h_edge_id_c <= v2c_h_edge_id_s;
      v2c_diag_idx_c <= v2c_diag_idx_s;
      v2c_q_seq_c <= v2c_q_seq_s;
      v2c_write_pair_sel_c <= v2c_write_pair_sel_s;
      v2c_write_phase_p <= v2c_phase_c;
      v2c_write_tile_idx_p <= v2c_tile_idx_c;
      v2c_write_h_edge_id_p <= v2c_h_edge_id_c;
      v2c_write_q_seq_p <= v2c_q_seq_c;
      v2c_write_pair_sel_p <= v2c_write_pair_sel_c;
      v2c_bypass_pair_sel_b <= v2c_write_pair_sel_p;
      ksign_corr_phase_h <= ksign_corr_phase_active;
      ksign_corr_h_block_idx_h <= c2v_h_block_idx;
      ksign_corr_tile_idx_h <= c2v_tile_idx;
      ksign_corr_diag_idx_h <= active_diag_idx;
      ksign_corr_q_seq_h <= active_q_seq;
      ksign_corr_phase_e <= ksign_corr_phase_h;
      ksign_corr_h_block_idx_e <= ksign_corr_h_block_idx_h;
      ksign_corr_tile_idx_e <= ksign_corr_tile_idx_h;
      ksign_corr_diag_idx_e <= ksign_corr_diag_idx_h;
      ksign_corr_q_seq_e <= ksign_corr_q_seq_h;
      ksign_corr_h_base_row_e <= c2v_h_base_row;
      ksign_corr_phase_r <= ksign_corr_phase_e;
      ksign_corr_diag_idx_r <= ksign_corr_diag_idx_e;
      ctrl_done_r <= ctrl_done;
      ctrl_done_q <= ctrl_done_r;
      ctrl_done_s <= ctrl_done_q;
      ctrl_done_p <= ctrl_done_s;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_valid_r[lane_idx] <= c2v_valid[lane_idx];
        c2v_col_idx_r[lane_idx] <= c2v_col_idx[lane_idx];
        c2v_edge_id_r[lane_idx] <= c2v_edge_id[lane_idx];
        c2v_row_addr_r[lane_idx] <= c2v_row_addr[lane_idx];
        c2v_tile_offset_r[lane_idx] <= c2v_tile_offset[lane_idx];
        c2v_valid_q[lane_idx] <= c2v_valid_r[lane_idx];
        c2v_edge_id_q[lane_idx] <= c2v_edge_id_r[lane_idx];
        c2v_tile_offset_q[lane_idx] <= c2v_tile_offset_r[lane_idx];
        c2v_accum_rdata_q[lane_idx] <= c2v_accum_rdata[lane_idx];
        c2v_syndrome_q[lane_idx] <= syndrome_rdata[lane_idx];
        c2v_valid_s[lane_idx] <= c2v_valid_q[lane_idx];
        c2v_edge_id_s[lane_idx] <= c2v_edge_id_q[lane_idx];
        c2v_tile_offset_s[lane_idx] <= c2v_tile_offset_q[lane_idx];
        c2v_accum_rdata_s[lane_idx] <= c2v_accum_rdata_q[lane_idx];
        c2v_comp_s[lane_idx] <= c2v_comp_mem[lane_idx];
        c2v_syndrome_s[lane_idx] <= c2v_syndrome_q[lane_idx];
        c2v_valid_c[lane_idx] <= c2v_valid_s[lane_idx];
        c2v_edge_id_c[lane_idx] <= c2v_edge_id_s[lane_idx];
        c2v_tile_offset_c[lane_idx] <= c2v_tile_offset_s[lane_idx];
        c2v_accum_rdata_c[lane_idx] <= c2v_accum_rdata_s[lane_idx];
        c2v_comp_c[lane_idx] <= c2v_comp_s[lane_idx];
        c2v_sign_c[lane_idx] <= K_SIGN_ENABLE ? c2v_ksign_sign_q[lane_idx] : c2v_sign_mem[lane_idx];
        c2v_syndrome_c[lane_idx] <= c2v_syndrome_s[lane_idx];
        c2v_valid_p[lane_idx] <= c2v_valid_c[lane_idx];
        c2v_tile_offset_p[lane_idx] <= c2v_tile_offset_c[lane_idx];
        c2v_msg_p[lane_idx] <= c2v_msg[lane_idx];
        c2v_accum_base_p[lane_idx] <= (c2v_diag_idx_c == '0) ? '0 : c2v_accum_rdata_c[lane_idx];
        c2v_raw_next_p[lane_idx] <= c2v_raw_next[lane_idx];
        c2v_ksign_sign_q[lane_idx] <= c2v_ksign_sign_mem[lane_idx];
        v2c_valid_r[lane_idx] <= v2c_valid[lane_idx];
        v2c_col_idx_r[lane_idx] <= v2c_col_idx[lane_idx];
        v2c_edge_id_r[lane_idx] <= v2c_edge_id[lane_idx];
        v2c_row_addr_r[lane_idx] <= v2c_row_addr[lane_idx];
        v2c_tile_offset_r[lane_idx] <= v2c_tile_offset[lane_idx];
        v2c_valid_q[lane_idx] <= v2c_valid_r[lane_idx];
        v2c_col_idx_q[lane_idx] <= v2c_col_idx_r[lane_idx];
        v2c_edge_id_q[lane_idx] <= v2c_edge_id_r[lane_idx];
        v2c_row_addr_q[lane_idx] <= v2c_row_addr_r[lane_idx];
        v2c_tile_offset_q[lane_idx] <= v2c_tile_offset_r[lane_idx];
        v2c_raw_sum_q[lane_idx] <= v2c_raw_sum[lane_idx];
        v2c_valid_s[lane_idx] <= v2c_valid_q[lane_idx];
        v2c_col_idx_s[lane_idx] <= v2c_col_idx_q[lane_idx];
        v2c_edge_id_s[lane_idx] <= v2c_edge_id_q[lane_idx];
        v2c_row_addr_s[lane_idx] <= v2c_row_addr_q[lane_idx];
        v2c_tile_offset_s[lane_idx] <= v2c_tile_offset_q[lane_idx];
        v2c_comp_s[lane_idx] <= v2c_valid_q[lane_idx] ? v2c_comp_eff[lane_idx] : COMP_C2V_INIT;
        decision_we_s[lane_idx] <= decision_we[lane_idx];
        v2c_valid_c[lane_idx] <= v2c_valid_s[lane_idx];
        v2c_col_idx_c[lane_idx] <= v2c_col_idx_s[lane_idx];
        v2c_edge_id_c[lane_idx] <= v2c_edge_id_s[lane_idx];
        v2c_row_addr_c[lane_idx] <= v2c_row_addr_s[lane_idx];
        v2c_tile_offset_c[lane_idx] <= v2c_tile_offset_s[lane_idx];
        v2c_comp_c[lane_idx] <= v2c_comp_s[lane_idx];
        v2c_msg_c[lane_idx] <= v2c_msg_next[lane_idx];
        decision_we_c[lane_idx] <= decision_we_s[lane_idx];
        decision_wdata_c[lane_idx] <= decision_wdata[lane_idx];
        v2c_valid_p[lane_idx] <= v2c_valid_c[lane_idx];
        v2c_col_idx_p[lane_idx] <= v2c_col_idx_c[lane_idx];
        v2c_row_addr_p[lane_idx] <= v2c_row_addr_c[lane_idx];
        v2c_tile_offset_p[lane_idx] <= v2c_tile_offset_c[lane_idx];
        v2c_comp_p[lane_idx] <= v2c_comp_next[lane_idx];
        v2c_sign_p[lane_idx] <= v2c_sign_wdata[lane_idx];
        decision_we_p[lane_idx] <= decision_we_c[lane_idx];
        decision_wdata_p[lane_idx] <= decision_wdata_c[lane_idx];
        v2c_bypass_valid_b[lane_idx] <= v2c_valid_p[lane_idx];
        v2c_bypass_row_addr_b[lane_idx] <= v2c_row_addr_p[lane_idx];
        v2c_bypass_comp_b[lane_idx] <= v2c_comp_p[lane_idx];
        ksign_corr_valid_r[lane_idx] <= ksign_corr_valid[lane_idx];
        ksign_corr_col_idx_r[lane_idx] <= ksign_corr_col_idx[lane_idx];
        ksign_corr_row_addr_r[lane_idx] <= ksign_corr_row_addr[lane_idx];
        ksign_corr_valid_q[lane_idx] <= ksign_corr_valid_r[lane_idx];
        ksign_corr_row_addr_q[lane_idx] <= ksign_corr_row_addr_r[lane_idx];
      end
    end
  end

  ram_syndrome u_ram_syndrome (
      .i_clk        (i_clk),
      .i_we         (i_syndrome_we),
      .i_wr_addr    (i_syndrome_addr),
      .i_wr_data    (i_syndrome_wdata),
      .i_rd_valid   (c2v_valid_r),
      .i_rd_row_addr(c2v_row_addr_r),
      .o_rd_data    (syndrome_rdata)
  );

  always_ff @(posedge i_clk or negedge rst_n_sync) begin
    if (!rst_n_sync) begin
      comp_read_pair_sel  <= 1'b0;
      comp_write_pair_sel <= 1'b1;
    end else begin
      if (decode_start) begin
        comp_read_pair_sel  <= 1'b0;
        comp_write_pair_sel <= 1'b1;
      end

      if (iter_last_cycle && !final_iter) begin
        comp_read_pair_sel  <= comp_write_pair_sel;
        comp_write_pair_sel <= comp_read_pair_sel;
      end
    end
  end
endmodule
