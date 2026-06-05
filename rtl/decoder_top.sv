`timescale 1ns / 1ps
// Top-level support-major tile min-sum decoder.
module decoder_top
  import bike_pkg::*;
(
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_start,
    input  logic                 i_syndrome_we,
    input  logic [ROW_IDX_W-1:0] i_syndrome_addr,
    input  logic                 i_syndrome_wdata,
    input  logic                 i_support_we,
    input  logic [H_BLOCK_W-1:0] i_support_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_support_one_idx,
    input  logic [ROW_IDX_W-1:0] i_support_row,
    input  logic [    COL_W-1:0] i_e_read_col_idx,
    output logic                 o_support_loaded,
    output logic                 o_support_error,
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

  localparam int T_DEPTH = W * Q_TILE;
  localparam int T_ADDR_W = (T_DEPTH > 1) ? $clog2(T_DEPTH) : 1;

  /* verilator lint_off UNUSEDSIGNAL */
  logic [DEC_STATE_W-1:0] state;
  logic [TILE_ID_W-1:0] unused_c2v_tile_linear;
  logic [TILE_ID_W-1:0] unused_v2c_tile_linear;
  logic unused_iter_first_cycle;
  logic [COL_W-1:0] unused_c2v_col_idx[0:L-1];
  logic [ROW_BANK_AW-1:0] unused_c2v_row_addr[0:L-1];
  logic [ROW_BANK_AW-1:0] unused_v2c_row_addr[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic c2v_phase_active;
  logic v2c_phase_active;
  logic [H_BLOCK_W-1:0] c2v_h_block_idx;
  logic [TILE_IDX_W-1:0] c2v_tile_idx;
  logic [H_BLOCK_W-1:0] v2c_h_block_idx;
  logic [TILE_IDX_W-1:0] v2c_tile_idx;
  logic [ONE_IDX_W-1:0] active_one_idx;
  logic [Q_SEQ_W-1:0] active_q_seq;
  logic fill_buf;
  logic active_buf;
  logic final_iter;
  logic iter_last_cycle;
  logic decode_start;

  logic [ROW_IDX_W-1:0] c2v_support_row;
  logic [EDGE_ID_W-1:0] c2v_support_edge_id;
  logic [ROW_IDX_W-1:0] v2c_support_row;
  logic [EDGE_ID_W-1:0] v2c_support_edge_id;

  logic c2v_valid[0:L-1];
  logic [ROW_IDX_W-1:0] c2v_row_idx[0:L-1];
  logic [EDGE_ID_W-1:0] c2v_edge_id[0:L-1];
  logic [LANE_IDX_W-1:0] c2v_row_bank[0:L-1];
  logic [TILE_OFF_W-1:0] c2v_tile_offset[0:L-1];

  logic v2c_valid[0:L-1];
  logic [ROW_IDX_W-1:0] v2c_row_idx[0:L-1];
  logic [COL_W-1:0] v2c_col_idx[0:L-1];
  logic [EDGE_ID_W-1:0] v2c_edge_id[0:L-1];
  logic [LANE_IDX_W-1:0] v2c_row_bank[0:L-1];
  logic [TILE_OFF_W-1:0] v2c_tile_offset[0:L-1];

  logic syndrome_mem[0:R-1];
  logic decision_mem[0:N-1];
  logic [COMP_C2V_W-1:0] comp_pair[0:1][0:R-1];
  logic comp_epoch[0:1][0:R-1];
  logic pair_epoch[0:1];
  logic comp_read_pair_sel;
  logic comp_write_pair_sel;
  logic sign_mem[0:ROW_EDGE_COUNT-1][0:R-1];
  logic signed [ACC_W-1:0] tile_accum[0:1][0:C_TILE-1];
  logic signed [ACC_W-1:0] tile_t[0:1][0:L-1][0:T_DEPTH-1];
  logic signed [ACC_W-1:0] c2v_accum_next[0:L-1];
  logic signed [ACC_W-1:0] c2v_raw_next[0:L-1];
  logic signed [ACC_W-1:0] v2c_posterior_next[0:L-1];
  logic [MSG_W-1:0] v2c_msg_next[0:L-1];
  logic [COMP_C2V_W-1:0] v2c_comp_next[0:L-1];
  logic ctrl_done;

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

  function automatic logic [MSG_W-1:0] tc_to_signmag_sat(input  logic signed [ACC_W-1:0] tc_value);
    logic                    sign_bit;
    logic signed [ACC_W-1:0] mag_signed;
    int                      mag_int;
    begin
      sign_bit = tc_value[ACC_W-1];
      mag_signed = sign_bit ? -tc_value : tc_value;
      mag_int = int'(mag_signed);
      if (mag_int > MAG_MAX) begin
        mag_int = MAG_MAX;
      end
      tc_to_signmag_sat = {sign_bit && (mag_int != 0), D'(mag_int)};
    end
  endfunction

  function automatic logic signed [ACC_W-1:0] alpha_scale(input  logic signed [ACC_W-1:0] tc_value);
    localparam int SCALE_W = ACC_W + ALPHA_FRAC_W;
    logic signed [     SCALE_W-1:0] scale_ext;
    logic signed [     SCALE_W-1:0] scaled_full;
    logic signed [       ACC_W-1:0] floor_tc;
    logic signed [       ACC_W-1:0] trunc_tc;
    logic        [ALPHA_FRAC_W-1:0] frac_bits;
    logic        [  ALPHA_FRAC_W:0] neg_frac_mag;
    logic                           frac_nonzero;
    logic                           round_bit;
    begin
      scale_ext   = SCALE_W'($signed(tc_value));
      scaled_full = '0;
      if ((ALPHA_SHIFT_0 > 0) && (ALPHA_SHIFT_0 <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_0));
      end
      if ((ALPHA_SHIFT_1 > 0) && (ALPHA_SHIFT_1 <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_1));
      end

      floor_tc = scaled_full[SCALE_W-1:ALPHA_FRAC_W];
      frac_bits = scaled_full[ALPHA_FRAC_W-1:0];
      frac_nonzero = |frac_bits;
      if (scaled_full[SCALE_W-1]) begin
        trunc_tc = frac_nonzero ? (floor_tc + ACC_W'(1)) : floor_tc;
        neg_frac_mag = frac_nonzero ? ({1'b1, {ALPHA_FRAC_W{1'b0}}} - {1'b0, frac_bits}) : '0;
        round_bit = neg_frac_mag[ALPHA_FRAC_W-1];
        alpha_scale = round_bit ? (trunc_tc - ACC_W'(1)) : trunc_tc;
      end else begin
        trunc_tc = floor_tc;
        round_bit = frac_bits[ALPHA_FRAC_W-1];
        alpha_scale = round_bit ? (trunc_tc + ACC_W'(1)) : trunc_tc;
      end
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

  function automatic logic [COMP_C2V_W-1:0] comp_or_init(input  logic pair_sel,
                                                         input  logic [ROW_IDX_W-1:0] row_idx);
    begin
      comp_or_init = (comp_epoch[pair_sel][int'(row_idx)] == pair_epoch[pair_sel]) ?
                     comp_pair[pair_sel][int'(row_idx)] : COMP_C2V_INIT;
    end
  endfunction

  function automatic logic [T_ADDR_W-1:0] t_addr(input  logic [ONE_IDX_W-1:0] one_idx,
                                                 input  logic [Q_SEQ_W-1:0] q_seq);
    begin
      t_addr = T_ADDR_W'(int'(one_idx) * Q_TILE + int'(q_seq));
    end
  endfunction

  assign decode_start = i_start && o_support_loaded && !o_support_error;
  assign o_e_rdata = decision_mem[int'(i_e_read_col_idx)];
  assign o_done = ctrl_done;

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      logic        [COMP_C2V_W-1:0] c2v_comp_in;
      logic        [     MSG_W-1:0] c2v_msg;
      logic signed [     ACC_W-1:0] c2v_tc;
      logic signed [     ACC_W-1:0] c2v_accum_base;
      logic signed [     ACC_W-1:0] v2c_raw_c2v;
      logic signed [     ACC_W-1:0] v2c_raw_sum;
      logic signed [     ACC_W-1:0] v2c_tc;
      logic        [COMP_C2V_W-1:0] v2c_comp_in;

      c2v_accum_next[lane_idx] = '0;
      c2v_raw_next[lane_idx] = '0;
      v2c_posterior_next[lane_idx] = '0;
      v2c_msg_next[lane_idx] = '0;
      v2c_comp_next[lane_idx] = COMP_C2V_INIT;
      c2v_comp_in = COMP_C2V_INIT;
      c2v_msg = '0;
      c2v_tc = '0;
      c2v_accum_base = '0;
      v2c_raw_c2v = '0;
      v2c_raw_sum = '0;
      v2c_tc = '0;
      v2c_comp_in = COMP_C2V_INIT;

      if (c2v_valid[lane_idx]) begin
        c2v_comp_in = (o_iter_count == '0) ? FIRST_ITER_C2V_COMP :
            comp_or_init(comp_read_pair_sel, c2v_row_idx[lane_idx]);
        c2v_msg = cnu_b_msg(
          c2v_comp_in,
          (o_iter_count == '0) ? 1'b0 :
            sign_mem[int'(c2v_edge_id[lane_idx])][int'(c2v_row_idx[lane_idx])],
          syndrome_mem[int'(c2v_row_idx[lane_idx])],
          c2v_edge_id[lane_idx]
        );
        c2v_tc = ACC_W'($signed(signmag_to_tc(c2v_msg)));
        c2v_raw_next[lane_idx] = c2v_tc;
        c2v_accum_base = (active_one_idx == '0) ? '0 :
            tile_accum[fill_buf][int'(c2v_tile_offset[lane_idx])];
        c2v_accum_next[lane_idx] = c2v_accum_base + c2v_raw_next[lane_idx];
      end

      if (v2c_valid[lane_idx]) begin
        v2c_raw_sum = tile_accum[active_buf][int'(v2c_tile_offset[lane_idx])];
        v2c_posterior_next[lane_idx] = ACC_W'($signed(C_VAL)) + alpha_scale(v2c_raw_sum);
        v2c_raw_c2v = tile_t[active_buf][lane_idx][int'(t_addr(active_one_idx, active_q_seq))];
        v2c_tc = ACC_W'($signed(C_VAL)) + alpha_scale(v2c_raw_sum - v2c_raw_c2v);
        v2c_msg_next[lane_idx] = tc_to_signmag_sat(v2c_tc);
        v2c_comp_in = comp_or_init(comp_write_pair_sel, v2c_row_idx[lane_idx]);
        v2c_comp_next[lane_idx] =
            cnu_a_comp(v2c_comp_in, v2c_msg_next[lane_idx], v2c_edge_id[lane_idx]);
      end
    end
  end

  support_mem u_support_mem (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_clear(1'b0),
      .i_we(i_support_we),
      .i_h_block_idx(i_support_h_block_idx),
      .i_one_idx(i_support_one_idx),
      .i_support_row(i_support_row),
      .i_c2v_h_block_idx(c2v_h_block_idx),
      .i_c2v_one_idx(active_one_idx),
      .i_v2c_h_block_idx(v2c_h_block_idx),
      .i_v2c_one_idx(active_one_idx),
      .o_c2v_support_row(c2v_support_row),
      .o_c2v_edge_id(c2v_support_edge_id),
      .o_v2c_support_row(v2c_support_row),
      .o_v2c_edge_id(v2c_support_edge_id),
      .o_loaded(o_support_loaded),
      .o_error(o_support_error)
  );

  support_major_ctrl u_support_major_ctrl (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
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

  support_row_col_gen u_c2v_row_col_gen (
      .i_phase_valid(c2v_phase_active),
      .i_h_block_idx(c2v_h_block_idx),
      .i_tile_idx(c2v_tile_idx),
      .i_q_seq(active_q_seq),
      .i_support_row(c2v_support_row),
      .i_edge_id(c2v_support_edge_id),
      .o_valid(c2v_valid),
      .o_row_idx(c2v_row_idx),
      .o_col_idx(unused_c2v_col_idx),
      .o_edge_id(c2v_edge_id),
      .o_row_bank(c2v_row_bank),
      .o_row_addr(unused_c2v_row_addr),
      .o_tile_offset(c2v_tile_offset)
  );

  support_row_col_gen u_v2c_row_col_gen (
      .i_phase_valid(v2c_phase_active),
      .i_h_block_idx(v2c_h_block_idx),
      .i_tile_idx(v2c_tile_idx),
      .i_q_seq(active_q_seq),
      .i_support_row(v2c_support_row),
      .i_edge_id(v2c_support_edge_id),
      .o_valid(v2c_valid),
      .o_row_idx(v2c_row_idx),
      .o_col_idx(v2c_col_idx),
      .o_edge_id(v2c_edge_id),
      .o_row_bank(v2c_row_bank),
      .o_row_addr(unused_v2c_row_addr),
      .o_tile_offset(v2c_tile_offset)
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

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      comp_read_pair_sel <= 1'b0;
      comp_write_pair_sel <= 1'b1;
      pair_epoch[0] <= 1'b0;
      pair_epoch[1] <= 1'b0;
      for (int row_idx = 0; row_idx < R; row_idx++) begin
        syndrome_mem[row_idx]  <= 1'b0;
        comp_epoch[0][row_idx] <= 1'b0;
        comp_epoch[1][row_idx] <= 1'b0;
      end
    end else begin
      if (i_syndrome_we) begin
        syndrome_mem[int'(i_syndrome_addr)] <= i_syndrome_wdata;
      end

      if (decode_start) begin
        comp_read_pair_sel <= 1'b0;
        comp_write_pair_sel <= 1'b1;
        pair_epoch[1] <= ~pair_epoch[1];
      end

      if (c2v_phase_active) begin
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (c2v_valid[lane_idx]) begin
            tile_accum[fill_buf][int'(c2v_tile_offset[lane_idx])] <= c2v_accum_next[lane_idx];
            tile_t[fill_buf][lane_idx][int'(t_addr(
                active_one_idx, active_q_seq
            ))] <= c2v_raw_next[lane_idx];
          end
        end
      end

      if (v2c_phase_active) begin
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (v2c_valid[lane_idx]) begin
            comp_pair[comp_write_pair_sel][int'(v2c_row_idx[lane_idx])] <= v2c_comp_next[lane_idx];
            comp_epoch[comp_write_pair_sel][int'(v2c_row_idx[lane_idx])] <=
              pair_epoch[comp_write_pair_sel];
            sign_mem[int'(v2c_edge_id[lane_idx])][int'(v2c_row_idx[lane_idx])] <=
              v2c_msg_next[lane_idx][MSG_SIGN_BIT];
            if (final_iter && (active_one_idx == '0)) begin
              decision_mem[int'(v2c_col_idx[lane_idx])] <= v2c_posterior_next[lane_idx][ACC_W-1];
            end
          end
        end
      end

      if (iter_last_cycle && !final_iter) begin
        comp_read_pair_sel <= comp_write_pair_sel;
        comp_write_pair_sel <= comp_read_pair_sel;
        pair_epoch[comp_read_pair_sel] <= ~pair_epoch[comp_read_pair_sel];
      end
    end
  end
endmodule
