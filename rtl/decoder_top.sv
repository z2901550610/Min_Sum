`timescale 1ns / 1ps
// Top-level tiled min-sum decoder.
module decoder_top
  import bike_pkg::*;
(
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_start,
    input  logic                 i_syndrome_we,
    input  logic [ROW_IDX_W-1:0] i_syndrome_addr,
    input  logic                 i_syndrome_wdata,
    input  logic                 i_h_we,
    input  logic [H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_h_one_idx,
    input  logic [ROW_IDX_W-1:0] i_h_base_row,
    input  logic [    COL_W-1:0] i_e_read_col_idx,
    output logic                 o_h_loaded,
    output logic                 o_h_error,
    output logic                 o_done,
    output logic                 o_e_rdata,
    output logic [   ITER_W-1:0] o_iter_count
);

`ifndef SYNTHESIS
  initial begin
    if ((L <= 0) || ((L & (L - 1)) != 0)) begin
      $fatal(1, "decoder_top requires L to be a power of two");
    end
    if ((C_TILE <= 0) || ((C_TILE % L) != 0)) begin
      $fatal(1, "decoder_top requires C_TILE to be a positive multiple of L");
    end
  end
`endif

  /* verilator lint_off UNUSEDSIGNAL */
  logic        [DEC_STATE_W-1:0] state;
  logic        [  TILE_ID_W-1:0] unused_c2v_tile_linear;
  logic        [  TILE_ID_W-1:0] unused_v2c_tile_linear;
  logic                          unused_iter_first_cycle;
  logic        [      COL_W-1:0] unused_c2v_col_idx[0:L-1];
  logic        [  ROW_IDX_W-1:0] unused_c2v_row_idx[0:L-1];
  logic        [  ROW_IDX_W-1:0] unused_v2c_row_idx[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic                          c2v_phase_active;
  logic                          v2c_phase_active;
  logic        [  H_BLOCK_W-1:0] c2v_h_block_idx;
  logic        [ TILE_IDX_W-1:0] c2v_tile_idx;
  logic        [  H_BLOCK_W-1:0] v2c_h_block_idx;
  logic        [ TILE_IDX_W-1:0] v2c_tile_idx;
  logic        [  ONE_IDX_W-1:0] active_one_idx;
  logic        [    Q_SEQ_W-1:0] active_q_seq;
  logic                          fill_buf;
  logic                          active_buf;
  logic                          final_iter;
  logic                          iter_last_cycle;
  logic                          decode_start;
  logic                          rst_n_sync;

  logic        [  ROW_IDX_W-1:0] c2v_h_base_row;
  logic        [  EDGE_ID_W-1:0] c2v_h_edge_id;
  logic        [  ROW_IDX_W-1:0] v2c_h_base_row;
  logic        [  EDGE_ID_W-1:0] v2c_h_edge_id;

  logic                          c2v_phase_e;
  logic        [  H_BLOCK_W-1:0] c2v_h_block_idx_e;
  logic        [ TILE_IDX_W-1:0] c2v_tile_idx_e;
  logic        [  ONE_IDX_W-1:0] c2v_one_idx_e;
  logic        [    Q_SEQ_W-1:0] c2v_q_seq_e;
  logic                          c2v_fill_buf_e;
  logic                          c2v_iter_zero_e;
  logic        [  ROW_IDX_W-1:0] c2v_h_base_row_e;
  logic        [  EDGE_ID_W-1:0] c2v_h_edge_id_e;
  logic                          comp_read_pair_sel_e;
  logic                          comp_read_epoch_e;

  logic                          c2v_valid[0:L-1];
  logic        [  EDGE_ID_W-1:0] c2v_edge_id[0:L-1];
  logic        [ LANE_IDX_W-1:0] c2v_row_bank[0:L-1];
  logic        [ROW_BANK_AW-1:0] c2v_row_addr[0:L-1];
  logic        [ TILE_OFF_W-1:0] c2v_tile_offset[0:L-1];
  logic                          c2v_valid_r[0:L-1];
  logic        [  EDGE_ID_W-1:0] c2v_edge_id_r[0:L-1];
  logic        [ROW_BANK_AW-1:0] c2v_row_addr_r[0:L-1];
  logic        [ TILE_OFF_W-1:0] c2v_tile_offset_r[0:L-1];
  logic        [  ONE_IDX_W-1:0] c2v_one_idx_r;
  logic        [    Q_SEQ_W-1:0] c2v_q_seq_r;
  logic                          c2v_fill_buf_r;
  logic                          c2v_iter_zero_r;
  logic                          comp_read_pair_sel_r;
  logic                          comp_read_epoch_r;
  logic                          c2v_valid_q[0:L-1];
  logic        [  EDGE_ID_W-1:0] c2v_edge_id_q[0:L-1];
  logic        [ TILE_OFF_W-1:0] c2v_tile_offset_q[0:L-1];
  logic signed [      ACC_W-1:0] c2v_accum_rdata_q[0:L-1];
  logic                          c2v_syndrome_q[0:L-1];
  logic        [  ONE_IDX_W-1:0] c2v_one_idx_q;
  logic        [    Q_SEQ_W-1:0] c2v_q_seq_q;
  logic                          c2v_fill_buf_q;
  logic                          c2v_iter_zero_q;

  logic                          v2c_phase_e;
  logic        [  H_BLOCK_W-1:0] v2c_h_block_idx_e;
  logic        [ TILE_IDX_W-1:0] v2c_tile_idx_e;
  logic        [  ONE_IDX_W-1:0] v2c_one_idx_e;
  logic        [    Q_SEQ_W-1:0] v2c_q_seq_e;
  logic                          v2c_active_buf_e;
  logic                          v2c_final_iter_e;
  logic        [  ROW_IDX_W-1:0] v2c_h_base_row_e;
  logic        [  EDGE_ID_W-1:0] v2c_h_edge_id_e;
  logic                          comp_write_pair_sel_e;
  logic                          comp_write_epoch_e;

  logic                          v2c_valid[0:L-1];
  logic        [      COL_W-1:0] v2c_col_idx[0:L-1];
  logic        [  EDGE_ID_W-1:0] v2c_edge_id[0:L-1];
  logic        [ LANE_IDX_W-1:0] v2c_row_bank[0:L-1];
  logic        [ROW_BANK_AW-1:0] v2c_row_addr[0:L-1];
  logic        [ TILE_OFF_W-1:0] v2c_tile_offset[0:L-1];
  logic                          v2c_valid_r[0:L-1];
  logic        [      COL_W-1:0] v2c_col_idx_r[0:L-1];
  logic        [  EDGE_ID_W-1:0] v2c_edge_id_r[0:L-1];
  logic        [ROW_BANK_AW-1:0] v2c_row_addr_r[0:L-1];
  logic        [ TILE_OFF_W-1:0] v2c_tile_offset_r[0:L-1];
  logic        [  ONE_IDX_W-1:0] v2c_one_idx_r;
  logic        [    Q_SEQ_W-1:0] v2c_q_seq_r;
  logic                          v2c_active_buf_r;
  logic                          v2c_final_iter_r;
  logic                          comp_write_pair_sel_r;
  logic                          comp_write_epoch_r;
  logic                          v2c_valid_q[0:L-1];
  logic        [      COL_W-1:0] v2c_col_idx_q[0:L-1];
  logic        [  EDGE_ID_W-1:0] v2c_edge_id_q[0:L-1];
  logic        [ROW_BANK_AW-1:0] v2c_row_addr_q[0:L-1];
  logic signed [      ACC_W-1:0] v2c_raw_sum_q[0:L-1];
  logic        [  ONE_IDX_W-1:0] v2c_one_idx_q;
  logic                          v2c_final_iter_q;
  logic                          v2c_write_pair_sel_q;
  logic                          v2c_write_epoch_q;

  logic                          syndrome_rdata[0:L-1];
  logic                          comp_read_pair_sel;
  logic                          comp_write_pair_sel;
  logic                          pair_epoch[  0:1];
  logic        [ COMP_C2V_W-1:0] c2v_comp_mem[0:L-1];
  logic        [ COMP_C2V_W-1:0] v2c_comp_mem[0:L-1];
  logic                          c2v_sign_mem[0:L-1];
  logic                          v2c_sign_wdata[0:L-1];
  logic signed [      ACC_W-1:0] c2v_accum_rdata[0:L-1];
  logic signed [      ACC_W-1:0] v2c_raw_sum[0:L-1];
  logic signed [      ACC_W-1:0] v2c_raw_c2v[0:L-1];
  /* verilator lint_off UNOPTFLAT */
  logic signed [      ACC_W-1:0] c2v_accum_next[0:L-1];
  /* verilator lint_on UNOPTFLAT */
  logic signed [      ACC_W-1:0] c2v_raw_next[0:L-1];
  logic signed [      ACC_W-1:0] v2c_posterior_next[0:L-1];
  logic        [      MSG_W-1:0] v2c_msg_next[0:L-1];
  logic        [ COMP_C2V_W-1:0] v2c_comp_next[0:L-1];
  logic                          decision_we[0:L-1];
  logic                          decision_wdata[0:L-1];
  logic                          ctrl_done;
  logic                          ctrl_done_r;
  logic                          ctrl_done_q;

  function automatic logic signed [MSG_W-1:0] signmag_to_tc(input  logic [MSG_W-1:0] msg);
    logic [D-1:0] mag;
    begin
      mag = msg[MSG_MAG_LSB+:D];
      if (msg[MSG_SIGN_BIT] && (mag != '0)) begin
        signmag_to_tc = -MSG_W'($signed({1'b0, mag}));
      end else begin
        signmag_to_tc = MSG_W'($signed({1'b0, mag}));
      end
    end
  endfunction

  function automatic logic [LANE_IDX_W-1:0] row_bank_of(input  logic [ROW_IDX_W-1:0] row_idx);
    begin
      row_bank_of = LANE_IDX_W'(int'(row_idx) & (L - 1));
    end
  endfunction

  function automatic logic [ROW_BANK_AW-1:0] row_addr_of(input  logic [ROW_IDX_W-1:0] row_idx);
    begin
      row_addr_of = ROW_BANK_AW'(row_idx >> L_SHIFT);
    end
  endfunction

  function automatic logic [MSG_W-1:0] cnu_b_msg(input  logic [COMP_C2V_W-1:0] comp,
                                                 input  logic v2c_sign, input  logic syndrome_bit,
                                                 input  logic [EDGE_ID_W-1:0] edge_id);
    logic [        D-1:0] min1_mag;
    logic [        D-1:0] min2_mag;
    logic [EDGE_ID_W-1:0] min_edge_id;
    logic                 sign_xor;
    logic                 msg_sign;
    logic [        D-1:0] msg_mag;
    begin
      min1_mag = comp[COMP_C2V_MIN1_LSB+:D];
      min2_mag = comp[COMP_C2V_MIN2_LSB+:D];
      min_edge_id = comp[COMP_C2V_MIN_ID_LSB+:EDGE_ID_W];
      sign_xor = comp[COMP_C2V_SIGN_XOR_BIT];
      msg_mag = (edge_id == min_edge_id) ? min2_mag : min1_mag;
      msg_sign = sign_xor ^ v2c_sign ^ syndrome_bit;
      cnu_b_msg = {msg_sign, msg_mag};
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] cnu_a_comp(input  logic [COMP_C2V_W-1:0] comp,
                                                       input  logic [MSG_W-1:0] v2c_msg,
                                                       input  logic [EDGE_ID_W-1:0] edge_id);
    logic [         D-1:0] v2c_mag;
    logic                  v2c_sign;
    logic [         D-1:0] min1_mag;
    logic [         D-1:0] min2_mag;
    logic [COMP_C2V_W-1:0] comp_next;
    begin
      v2c_sign = v2c_msg[MSG_SIGN_BIT];
      v2c_mag = v2c_msg[MSG_MAG_LSB+:D];
      min1_mag = comp[COMP_C2V_MIN1_LSB+:D];
      min2_mag = comp[COMP_C2V_MIN2_LSB+:D];
      comp_next = comp;
      comp_next[COMP_C2V_SIGN_XOR_BIT] = comp[COMP_C2V_SIGN_XOR_BIT] ^ v2c_sign;
      if (v2c_mag <= min1_mag) begin
        comp_next[COMP_C2V_MIN2_LSB+:D] = min1_mag;
        comp_next[COMP_C2V_MIN1_LSB+:D] = v2c_mag;
        comp_next[COMP_C2V_MIN_ID_LSB+:EDGE_ID_W] = edge_id;
      end else if (v2c_mag < min2_mag) begin
        comp_next[COMP_C2V_MIN2_LSB+:D] = v2c_mag;
      end
      cnu_a_comp = comp_next;
    end
  endfunction

  assign decode_start = i_start && o_h_loaded && !o_h_error;
  assign o_done = ctrl_done_q;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      logic        [COMP_C2V_W-1:0] c2v_comp_in;
      logic        [     MSG_W-1:0] c2v_msg;
      logic signed [     ACC_W-1:0] c2v_tc;
      logic signed [     ACC_W-1:0] c2v_accum_base;
      logic        [COMP_C2V_W-1:0] v2c_comp_in;

      c2v_accum_next[lane_idx] = '0;
      c2v_raw_next[lane_idx] = '0;
      v2c_comp_next[lane_idx] = COMP_C2V_INIT;
      v2c_sign_wdata[lane_idx] = v2c_msg_next[lane_idx][MSG_SIGN_BIT];
      decision_we[lane_idx] = v2c_valid_q[lane_idx] && v2c_final_iter_q && (v2c_one_idx_q == '0);
      decision_wdata[lane_idx] = v2c_posterior_next[lane_idx][ACC_W-1];
      c2v_comp_in = COMP_C2V_INIT;
      c2v_msg = '0;
      c2v_tc = '0;
      c2v_accum_base = '0;
      v2c_comp_in = COMP_C2V_INIT;

      if (c2v_valid_q[lane_idx]) begin
        c2v_comp_in = c2v_iter_zero_q ? FIRST_ITER_C2V_COMP : c2v_comp_mem[lane_idx];
        c2v_msg = cnu_b_msg(
          c2v_comp_in,
          c2v_iter_zero_q ? 1'b0 : c2v_sign_mem[lane_idx],
          c2v_syndrome_q[lane_idx],
          c2v_edge_id_q[lane_idx]
        );
        c2v_tc = ACC_W'($signed(signmag_to_tc(c2v_msg)));
        c2v_raw_next[lane_idx] = c2v_tc;
        c2v_accum_base = (c2v_one_idx_q == '0) ? '0 : c2v_accum_rdata_q[lane_idx];
        c2v_accum_next[lane_idx] = c2v_accum_base + c2v_raw_next[lane_idx];
      end

      if (v2c_valid_q[lane_idx]) begin
        v2c_comp_in = v2c_comp_mem[lane_idx];
        v2c_comp_next[lane_idx] =
            cnu_a_comp(v2c_comp_in, v2c_msg_next[lane_idx], v2c_edge_id_q[lane_idx]);
      end
    end
  end

  h_matrix_mem u_h_mem (
      .i_clk(i_clk),
      .i_rst_n(rst_n_sync),
      .i_clear(1'b0),
      .i_we(i_h_we),
      .i_h_block_idx(i_h_block_idx),
      .i_one_idx(i_h_one_idx),
      .i_base_row(i_h_base_row),
      .i_c2v_h_block_idx(c2v_h_block_idx),
      .i_c2v_one_idx(active_one_idx),
      .i_v2c_h_block_idx(v2c_h_block_idx),
      .i_v2c_one_idx(active_one_idx),
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
      .o_state(state),
      .o_c2v_valid(c2v_phase_active),
      .o_v2c_valid(v2c_phase_active),
      .o_c2v_tile_linear(unused_c2v_tile_linear),
      .o_v2c_tile_linear(unused_v2c_tile_linear),
      .o_c2v_h_block_idx(c2v_h_block_idx),
      .o_c2v_tile_idx(c2v_tile_idx),
      .o_v2c_h_block_idx(v2c_h_block_idx),
      .o_v2c_tile_idx(v2c_tile_idx),
      .o_one_idx(active_one_idx),
      .o_q_seq(active_q_seq),
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
      .o_valid(c2v_valid),
      .o_row_idx(unused_c2v_row_idx),
      .o_col_idx(unused_c2v_col_idx),
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
      .o_valid(v2c_valid),
      .o_row_idx(unused_v2c_row_idx),
      .o_col_idx(v2c_col_idx),
      .o_edge_id(v2c_edge_id),
      .o_row_bank(v2c_row_bank),
      .o_row_addr(v2c_row_addr),
      .o_tile_offset(v2c_tile_offset)
  );

  check_state_ram u_check_state_ram (
      .i_clk(i_clk),
      .i_rst_n(rst_n_sync),
      .i_c2v_pair_sel(comp_read_pair_sel_r),
      .i_c2v_epoch(comp_read_epoch_r),
      .i_c2v_valid(c2v_valid_r),
      .i_c2v_row_addr(c2v_row_addr_r),
      .o_c2v_comp(c2v_comp_mem),
      .i_v2c_pair_sel(comp_write_pair_sel_r),
      .i_v2c_epoch(comp_write_epoch_r),
      .i_v2c_valid(v2c_valid_r),
      .i_v2c_row_addr(v2c_row_addr_r),
      .o_v2c_comp(v2c_comp_mem),
      .i_v2c_write_pair_sel(v2c_write_pair_sel_q),
      .i_v2c_write_epoch(v2c_write_epoch_q),
      .i_v2c_write_valid(v2c_valid_q),
      .i_v2c_write_row_addr(v2c_row_addr_q),
      .i_v2c_write_data(v2c_comp_next)
  );

  msg_sign_ram u_msg_sign_ram (
      .i_clk(i_clk),
      .i_c2v_valid(c2v_valid_r),
      .i_c2v_row_addr(c2v_row_addr_r),
      .i_c2v_edge_id(c2v_edge_id_r),
      .o_c2v_sign(c2v_sign_mem),
      .i_v2c_write_valid(v2c_valid_q),
      .i_v2c_row_addr(v2c_row_addr_q),
      .i_v2c_edge_id(v2c_edge_id_q),
      .i_v2c_sign(v2c_sign_wdata)
  );

  tile_accum_ram u_tile_accum_ram (
      .i_clk(i_clk),
      .i_c2v_read_buf(c2v_fill_buf_r),
      .i_c2v_read_valid(c2v_valid_r),
      .i_c2v_read_tile_offset(c2v_tile_offset_r),
      .o_c2v_rdata(c2v_accum_rdata),
      .i_c2v_write_buf(c2v_fill_buf_q),
      .i_c2v_write_valid(c2v_valid_q),
      .i_c2v_write_tile_offset(c2v_tile_offset_q),
      .i_c2v_wdata(c2v_accum_next),
      .i_active_buf(v2c_active_buf_r),
      .i_v2c_valid(v2c_valid_r),
      .i_v2c_tile_offset(v2c_tile_offset_r),
      .o_v2c_rdata(v2c_raw_sum)
  );

  c2v_cache_ram u_c2v_cache_ram (
      .i_clk(i_clk),
      .i_fill_buf(c2v_fill_buf_q),
      .i_c2v_write_valid(c2v_valid_q),
      .i_c2v_write_one_idx(c2v_one_idx_q),
      .i_c2v_write_q_seq(c2v_q_seq_q),
      .i_c2v_write_data(c2v_raw_next),
      .i_active_buf(v2c_active_buf_r),
      .i_v2c_valid(v2c_valid_r),
      .i_v2c_one_idx(v2c_one_idx_r),
      .i_v2c_q_seq(v2c_q_seq_r),
      .o_v2c_rdata(v2c_raw_c2v)
  );

  vnu_update u_vnu_update (
      .i_valid(v2c_valid_q),
      .i_raw_sum(v2c_raw_sum_q),
      .i_raw_c2v(v2c_raw_c2v),
      .o_posterior(v2c_posterior_next),
      .o_v2c_msg(v2c_msg_next)
  );

  decision_ram u_decision_ram (
      .i_clk(i_clk),
      .i_we(decision_we),
      .i_write_col_idx(v2c_col_idx_q),
      .i_wdata(decision_wdata),
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
      c2v_one_idx_q <= '0;
      c2v_q_seq_q <= '0;
      c2v_fill_buf_q <= 1'b0;
      c2v_iter_zero_q <= 1'b0;
      c2v_phase_e <= 1'b0;
      c2v_h_block_idx_e <= '0;
      c2v_tile_idx_e <= '0;
      c2v_one_idx_e <= '0;
      c2v_q_seq_e <= '0;
      c2v_fill_buf_e <= 1'b0;
      c2v_iter_zero_e <= 1'b0;
      c2v_h_base_row_e <= '0;
      c2v_h_edge_id_e <= '0;
      comp_read_pair_sel_e <= 1'b0;
      comp_read_epoch_e <= 1'b0;
      c2v_one_idx_r <= '0;
      c2v_q_seq_r <= '0;
      c2v_fill_buf_r <= 1'b0;
      c2v_iter_zero_r <= 1'b0;
      comp_read_pair_sel_r <= 1'b0;
      comp_read_epoch_r <= 1'b0;
      v2c_one_idx_q <= '0;
      v2c_final_iter_q <= 1'b0;
      v2c_phase_e <= 1'b0;
      v2c_h_block_idx_e <= '0;
      v2c_tile_idx_e <= '0;
      v2c_one_idx_e <= '0;
      v2c_q_seq_e <= '0;
      v2c_active_buf_e <= 1'b0;
      v2c_final_iter_e <= 1'b0;
      v2c_h_base_row_e <= '0;
      v2c_h_edge_id_e <= '0;
      comp_write_pair_sel_e <= 1'b0;
      comp_write_epoch_e <= 1'b0;
      v2c_one_idx_r <= '0;
      v2c_q_seq_r <= '0;
      v2c_active_buf_r <= 1'b0;
      v2c_final_iter_r <= 1'b0;
      comp_write_pair_sel_r <= 1'b0;
      comp_write_epoch_r <= 1'b0;
      v2c_write_pair_sel_q <= 1'b0;
      v2c_write_epoch_q <= 1'b0;
      ctrl_done_r <= 1'b0;
      ctrl_done_q <= 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_valid_r[lane_idx] <= 1'b0;
        c2v_edge_id_r[lane_idx] <= '0;
        c2v_row_addr_r[lane_idx] <= '0;
        c2v_tile_offset_r[lane_idx] <= '0;
        c2v_valid_q[lane_idx] <= 1'b0;
        c2v_edge_id_q[lane_idx] <= '0;
        c2v_tile_offset_q[lane_idx] <= '0;
        c2v_accum_rdata_q[lane_idx] <= '0;
        c2v_syndrome_q[lane_idx] <= 1'b0;
        v2c_valid_r[lane_idx] <= 1'b0;
        v2c_col_idx_r[lane_idx] <= '0;
        v2c_edge_id_r[lane_idx] <= '0;
        v2c_row_addr_r[lane_idx] <= '0;
        v2c_tile_offset_r[lane_idx] <= '0;
        v2c_valid_q[lane_idx] <= 1'b0;
        v2c_col_idx_q[lane_idx] <= '0;
        v2c_edge_id_q[lane_idx] <= '0;
        v2c_row_addr_q[lane_idx] <= '0;
        v2c_raw_sum_q[lane_idx] <= '0;
      end
    end else begin
      c2v_phase_e <= c2v_phase_active;
      c2v_h_block_idx_e <= c2v_h_block_idx;
      c2v_tile_idx_e <= c2v_tile_idx;
      c2v_one_idx_e <= active_one_idx;
      c2v_q_seq_e <= active_q_seq;
      c2v_fill_buf_e <= fill_buf;
      c2v_iter_zero_e <= o_iter_count == '0;
      c2v_h_base_row_e <= c2v_h_base_row;
      c2v_h_edge_id_e <= c2v_h_edge_id;
      comp_read_pair_sel_e <= comp_read_pair_sel;
      comp_read_epoch_e <= pair_epoch[comp_read_pair_sel];
      c2v_one_idx_r <= c2v_one_idx_e;
      c2v_q_seq_r <= c2v_q_seq_e;
      c2v_fill_buf_r <= c2v_fill_buf_e;
      c2v_iter_zero_r <= c2v_iter_zero_e;
      comp_read_pair_sel_r <= comp_read_pair_sel_e;
      comp_read_epoch_r <= comp_read_epoch_e;
      c2v_one_idx_q <= c2v_one_idx_r;
      c2v_q_seq_q <= c2v_q_seq_r;
      c2v_fill_buf_q <= c2v_fill_buf_r;
      c2v_iter_zero_q <= c2v_iter_zero_r;

      v2c_phase_e <= v2c_phase_active;
      v2c_h_block_idx_e <= v2c_h_block_idx;
      v2c_tile_idx_e <= v2c_tile_idx;
      v2c_one_idx_e <= active_one_idx;
      v2c_q_seq_e <= active_q_seq;
      v2c_active_buf_e <= active_buf;
      v2c_final_iter_e <= final_iter;
      v2c_h_base_row_e <= v2c_h_base_row;
      v2c_h_edge_id_e <= v2c_h_edge_id;
      comp_write_pair_sel_e <= comp_write_pair_sel;
      comp_write_epoch_e <= pair_epoch[comp_write_pair_sel];
      v2c_one_idx_r <= v2c_one_idx_e;
      v2c_q_seq_r <= v2c_q_seq_e;
      v2c_active_buf_r <= v2c_active_buf_e;
      v2c_final_iter_r <= v2c_final_iter_e;
      comp_write_pair_sel_r <= comp_write_pair_sel_e;
      comp_write_epoch_r <= comp_write_epoch_e;
      v2c_one_idx_q <= v2c_one_idx_r;
      v2c_final_iter_q <= v2c_final_iter_r;
      v2c_write_pair_sel_q <= comp_write_pair_sel_r;
      v2c_write_epoch_q <= comp_write_epoch_r;
      ctrl_done_r <= ctrl_done;
      ctrl_done_q <= ctrl_done_r;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_valid_r[lane_idx] <= c2v_valid[lane_idx];
        c2v_edge_id_r[lane_idx] <= c2v_edge_id[lane_idx];
        c2v_row_addr_r[lane_idx] <= c2v_row_addr[lane_idx];
        c2v_tile_offset_r[lane_idx] <= c2v_tile_offset[lane_idx];
        c2v_valid_q[lane_idx] <= c2v_valid_r[lane_idx];
        c2v_edge_id_q[lane_idx] <= c2v_edge_id_r[lane_idx];
        c2v_tile_offset_q[lane_idx] <= c2v_tile_offset_r[lane_idx];
        c2v_accum_rdata_q[lane_idx] <= c2v_accum_rdata[lane_idx];
        c2v_syndrome_q[lane_idx] <= syndrome_rdata[lane_idx];
        v2c_valid_r[lane_idx] <= v2c_valid[lane_idx];
        v2c_col_idx_r[lane_idx] <= v2c_col_idx[lane_idx];
        v2c_edge_id_r[lane_idx] <= v2c_edge_id[lane_idx];
        v2c_row_addr_r[lane_idx] <= v2c_row_addr[lane_idx];
        v2c_tile_offset_r[lane_idx] <= v2c_tile_offset[lane_idx];
        v2c_valid_q[lane_idx] <= v2c_valid_r[lane_idx];
        v2c_col_idx_q[lane_idx] <= v2c_col_idx_r[lane_idx];
        v2c_edge_id_q[lane_idx] <= v2c_edge_id_r[lane_idx];
        v2c_row_addr_q[lane_idx] <= v2c_row_addr_r[lane_idx];
        v2c_raw_sum_q[lane_idx] <= v2c_raw_sum[lane_idx];
      end
    end
  end

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_syndrome_bank
      (* ram_style = "distributed" *) logic mem[0:ROW_SEG_SIZE-1];

      assign syndrome_rdata[bank_idx] =
          c2v_valid_r[bank_idx] ? mem[c2v_row_addr_r[bank_idx]] : 1'b0;

      always_ff @(posedge i_clk) begin
        if (i_syndrome_we && (int'(row_bank_of(i_syndrome_addr)) == bank_idx)) begin
          mem[row_addr_of(i_syndrome_addr)] <= i_syndrome_wdata;
        end
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge rst_n_sync) begin
    if (!rst_n_sync) begin
      comp_read_pair_sel <= 1'b0;
      comp_write_pair_sel <= 1'b1;
      pair_epoch[0] <= 1'b0;
      pair_epoch[1] <= 1'b0;
    end else begin
      if (decode_start) begin
        comp_read_pair_sel <= 1'b0;
        comp_write_pair_sel <= 1'b1;
        pair_epoch[1] <= ~pair_epoch[1];
      end

      if (iter_last_cycle && !final_iter) begin
        comp_read_pair_sel <= comp_write_pair_sel;
        comp_write_pair_sel <= comp_read_pair_sel;
        pair_epoch[comp_read_pair_sel] <= ~pair_epoch[comp_read_pair_sel];
      end
    end
  end
endmodule
