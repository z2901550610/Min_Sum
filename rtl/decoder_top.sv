`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module decoder_top (
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_start,
  input  logic [H_SEL_W-1:0] i_h_sel,
  input  logic [N-1:0] i_x,
  output logic o_done,
  output logic o_success,
  output logic [N-1:0] o_x,
  output logic [$clog2(I_MAX + 1)-1:0] o_iter_count
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  localparam logic [VAR_W-1:0] LAST_VAR = VAR_W'(N - 1);
  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam int HIST_IDX_W = (I_MAX > 1) ? $clog2(I_MAX) : 1;
  localparam logic [EDGE_W-1:0] VNU_LAST_SLOT = EDGE_W'(((W + L) - 1) / L - 1);

  logic [DEC_STATE_W-1:0] state;
  logic [R-1:0] syndrome_hist [0:I_MAX-1];

  logic [VAR_W-1:0] active_var_idx;
  logic [EDGE_W-1:0] scan_slot;
  logic [BANK_W-1:0] current_bank;
  logic [I_ENTRY_W-1:0] current_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] current_lane_count [0:L-1];
  logic [LANE_COUNT_W-1:0] current_scan_limit;
  logic [LANE_EDGE_W-1:0] current_lane_edges [0:L-1][0:W-1];
  logic [LANE_EDGE_W-1:0] lane_edge0;
  logic [LANE_EDGE_W-1:0] lane_edge1;
  logic lane_edge0_valid;
  logic lane_edge1_valid;
  logic [ROW_W-1:0] lane_edge0_row_global;
  logic [ROW_W-1:0] lane_edge1_row_global;
  logic [EDGE_W-1:0] lane_edge0_edge_slot;
  logic [EDGE_W-1:0] lane_edge1_edge_slot;

  logic c0_rd_bit;
  logic [N-1:0] c1_bits;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a1;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b1;
  logic [MSG_W-1:0] v2c_msg0;
  logic [MSG_W-1:0] v2c_msg1;
  logic v2c_sign0;
  logic v2c_sign1;
  logic c1_rd_unused;

  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr1;
  logic v2c_sign_wr0;
  logic v2c_sign_wr1;
  logic cnu_a_out_valid0;
  logic cnu_a_out_valid1;
  logic [MSG_W-1:0] c2v_msg0;
  logic [MSG_W-1:0] c2v_msg1;
  logic signed [MSG_W-1:0] c2v_msg_tc0;
  logic signed [MSG_W-1:0] c2v_msg_tc1;
  logic signed [APP_W-1:0] prior_msg;
  logic vnu_x_out;
  logic vnu_col_start;
  logic vnu_col_end;
  logic vnu_accum_valid0;
  logic vnu_accum_valid1;
  logic vnu_accum_sign0;
  logic vnu_accum_sign1;
  logic [D-1:0] vnu_accum_mag0;
  logic [D-1:0] vnu_accum_mag1;
  logic vnu_emit_en;
  logic vnu_v2c_valid0;
  logic vnu_v2c_valid1;
  logic [MSG_W-1:0] vnu_v2c0;
  logic [MSG_W-1:0] vnu_v2c1;
  logic signed [MSG_W-1:0] t_rd_msg0;
  logic signed [MSG_W-1:0] t_rd_msg1;
  logic [EDGE_W-1:0] vnu_edge0_slot;
  logic [EDGE_W-1:0] vnu_edge1_slot;
  logic vnu_edge0_valid;
  logic vnu_edge1_valid;
  logic [R-1:0] syndrome_next;
  logic cnu_a_flush_pending;
  logic cnu_a_issue_phase;
  logic [ROW_W-1:0] cnu_a_wr_row0;
  logic [ROW_W-1:0] cnu_a_wr_row1;
  logic [EDGE_W-1:0] cnu_a_wr_edge0;
  logic [EDGE_W-1:0] cnu_a_wr_edge1;
  logic [VAR_W-1:0] cnu_a_wr_var0;
  logic [VAR_W-1:0] cnu_a_wr_var1;

  logic advance_var;
  logic [ITER_W-1:0] next_iter_count;
  logic stop_decode;
  logic continue_decode;

  logic c0_load_en;
  logic c1_load_en;
  logic c1_wr_en;
  logic m_clear_en;
  logic m_wr_en0;
  logic m_wr_en1;
  logic s_clear_en;
  logic s_wr_en0;
  logic s_wr_en1;
  logic t_clear_en;
  logic t_wr_en0;
  logic t_wr_en1;
  logic u_init_en;
  logic u_wr_en0;
  logic u_wr_en1;
  logic i_load_first_col_en;
  logic i_shift_en;

  assign current_bank = BANK_W'(int'(active_var_idx) / R);
  assign current_scan_limit =
    (current_lane_count[0] >= current_lane_count[1]) ? current_lane_count[0] : current_lane_count[1];
  assign lane_edge0 = current_lane_edges[0][scan_slot];
  assign lane_edge1 = current_lane_edges[1][scan_slot];
  assign lane_edge0_valid = lane_edge0[LANE_EDGE_VALID_BIT];
  assign lane_edge1_valid = lane_edge1[LANE_EDGE_VALID_BIT];
  assign lane_edge0_row_global = lane_edge0[LANE_EDGE_ROW_GLOBAL_LSB +: ROW_W];
  assign lane_edge1_row_global = lane_edge1[LANE_EDGE_ROW_GLOBAL_LSB +: ROW_W];
  assign lane_edge0_edge_slot = lane_edge0[LANE_EDGE_EDGE_SLOT_LSB +: EDGE_W];
  assign lane_edge1_edge_slot = lane_edge1[LANE_EDGE_EDGE_SLOT_LSB +: EDGE_W];
  assign prior_msg = c0_rd_bit ? -$signed(APP_W'(C_VAL)) : $signed(APP_W'(C_VAL));
  assign next_iter_count = o_iter_count + 1'b1;
  assign cnu_a_issue_phase = (state == DEC_CNU_A) && !cnu_a_flush_pending;
  assign c0_load_en = (state == DEC_LOAD);
  assign c1_load_en = (state == DEC_LOAD);
  assign c1_wr_en = (state == DEC_VNU_EMIT) && (scan_slot == '0);
  assign s_clear_en = (state == DEC_LOAD);
  assign t_clear_en = (state == DEC_LOAD);
  assign u_init_en = (state == DEC_LOAD);
  assign i_load_first_col_en = (state == DEC_LOAD);
  assign m_wr_en0 = cnu_a_out_valid0;
  assign m_wr_en1 = cnu_a_out_valid1;
  assign s_wr_en0 = cnu_a_out_valid0;
  assign s_wr_en1 = cnu_a_out_valid1;
  assign t_wr_en0 = (state == DEC_CNU_B) && lane_edge0_valid;
  assign t_wr_en1 = (state == DEC_CNU_B) && lane_edge1_valid;
  assign u_wr_en0 = vnu_v2c_valid0;
  assign u_wr_en1 = vnu_v2c_valid1;
  assign vnu_col_start = (state == DEC_VNU_ACCUM) && (scan_slot == '0);
  assign vnu_col_end = (state == DEC_VNU_ACCUM) && (scan_slot == VNU_LAST_SLOT);
  assign vnu_emit_en = (state == DEC_VNU_EMIT);
  assign vnu_edge0_slot = EDGE_W'(int'(scan_slot) * L);
  assign vnu_edge1_slot = EDGE_W'((int'(scan_slot) * L) + 1);
  assign vnu_edge0_valid = (int'(scan_slot) * L) < W;
  assign vnu_edge1_valid = ((int'(scan_slot) * L) + 1) < W;

  function automatic logic signed [MSG_W-1:0] signmag_to_tc_msg(
    input logic [MSG_W-1:0] signmag_msg
  );
    logic signed [MSG_W-1:0] mag_tc;
    begin
      mag_tc = $signed({1'b0, signmag_msg[MSG_MAG_LSB +: D]});
      if (signmag_msg[MSG_SIGN_BIT] && (signmag_msg[MSG_MAG_LSB +: D] != '0)) begin
        signmag_to_tc_msg = -mag_tc;
      end else begin
        signmag_to_tc_msg = mag_tc;
      end
    end
  endfunction

  function automatic logic [MSG_W-1:0] tc_to_signmag_msg(
    input logic signed [MSG_W-1:0] tc_msg
  );
    logic [D-1:0] abs_mag;
    logic [MSG_W-1:0] abs_full;
    begin
      if (tc_msg[MSG_W-1]) begin
        abs_full = (~tc_msg) + {{(MSG_W - 1){1'b0}}, 1'b1};
        abs_mag = abs_full[D-1:0];
      end else begin
        abs_full = tc_msg[MSG_W-1:0];
        abs_mag = tc_msg[D-1:0];
      end
      tc_to_signmag_msg = {tc_msg[MSG_W-1] && (abs_mag != '0), abs_mag};
    end
  endfunction

  always_comb begin
    integer var_idx_local;
    integer bank_idx_local;
    integer col_idx_local;
    integer edge_idx_local;
    integer row_idx_local;

    syndrome_next = '0;
    bank_idx_local = 0;
    col_idx_local = 0;
    row_idx_local = 0;
    for (var_idx_local = 0; var_idx_local < N; var_idx_local++) begin
      if (c1_bits[var_idx_local]) begin
        bank_idx_local = var_idx_local / R;
        col_idx_local = var_idx_local % R;
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          row_idx_local = (H_BASE[i_h_sel][bank_idx_local][edge_idx_local] + col_idx_local) % R;
          syndrome_next[row_idx_local] ^= 1'b1;
        end
      end
    end
  end

  always_comb begin
    logic [MSG_W-1:0] t_signmag0;
    logic [MSG_W-1:0] t_signmag1;

    advance_var = ((scan_slot + 1'b1) >= current_scan_limit);
    stop_decode = 1'b0;
    continue_decode = 1'b0;
    if (state == DEC_CHECK) begin
      stop_decode = (syndrome_next == '0) || (int'(next_iter_count) >= I_MAX);
      continue_decode = !stop_decode;
    end

    t_signmag0 = tc_to_signmag_msg(t_rd_msg0);
    t_signmag1 = tc_to_signmag_msg(t_rd_msg1);
    vnu_accum_valid0 = (state == DEC_VNU_ACCUM) && vnu_edge0_valid;
    vnu_accum_valid1 = (state == DEC_VNU_ACCUM) && vnu_edge1_valid;
    vnu_accum_sign0 = t_signmag0[MSG_SIGN_BIT];
    vnu_accum_sign1 = t_signmag1[MSG_SIGN_BIT];
    vnu_accum_mag0 = t_signmag0[MSG_MAG_LSB +: D];
    vnu_accum_mag1 = t_signmag1[MSG_MAG_LSB +: D];
  end

  assign c2v_msg_tc0 = signmag_to_tc_msg(c2v_msg0);
  assign c2v_msg_tc1 = signmag_to_tc_msg(c2v_msg1);
  assign m_clear_en = (state == DEC_LOAD) || continue_decode;
  assign i_shift_en = (cnu_a_issue_phase || (state == DEC_CNU_B)) && advance_var;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cnu_a_wr_row0 <= '0;
      cnu_a_wr_row1 <= '0;
      cnu_a_wr_edge0 <= '0;
      cnu_a_wr_edge1 <= '0;
      cnu_a_wr_var0 <= '0;
      cnu_a_wr_var1 <= '0;
    end else if (m_clear_en) begin
      cnu_a_wr_row0 <= '0;
      cnu_a_wr_row1 <= '0;
      cnu_a_wr_edge0 <= '0;
      cnu_a_wr_edge1 <= '0;
      cnu_a_wr_var0 <= '0;
      cnu_a_wr_var1 <= '0;
    end else if (cnu_a_issue_phase) begin
      cnu_a_wr_row0 <= lane_edge0_row_global;
      cnu_a_wr_row1 <= lane_edge1_row_global;
      cnu_a_wr_edge0 <= lane_edge0_edge_slot;
      cnu_a_wr_edge1 <= lane_edge1_edge_slot;
      cnu_a_wr_var0 <= active_var_idx;
      cnu_a_wr_var1 <= active_var_idx;
    end
  end

  ram_i u_i_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_load_first_col(i_load_first_col_en),
    .i_shift(i_shift_en),
    .i_h_sel(i_h_sel),
    .i_bank_sel(current_bank),
    .o_lane_entries(current_lane_entries),
    .o_lane_count(current_lane_count)
  );

  h_shift u_h_shift (
    .i_var_idx(active_var_idx),
    .i_lane_entries(current_lane_entries),
    .i_lane_count(current_lane_count),
    .o_lane_edges(current_lane_edges)
  );

  ram_c u_c0_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(c0_load_en),
    .i_load_bits(i_x),
    .i_we(1'b0),
    .i_w_addr('0),
    .i_din(1'b0),
    .i_r_addr(active_var_idx),
    .o_dout(c0_rd_bit),
    .o_bits()
  );

  ram_c u_c1_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(c1_load_en),
    .i_load_bits(i_x),
    .i_we(c1_wr_en),
    .i_w_addr(active_var_idx),
    .i_din(vnu_x_out),
    .i_r_addr(active_var_idx),
    .o_dout(c1_rd_unused),
    .o_bits(c1_bits)
  );

  ram_m u_m_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear_en),
    .i_r_addr_a0(lane_edge0_row_global),
    .i_r_addr_a1(lane_edge1_row_global),
    .i_r_addr_b0(lane_edge0_row_global),
    .i_r_addr_b1(lane_edge1_row_global),
    .o_dout_a0(c2v_compact_msg_rd_a0),
    .o_dout_a1(c2v_compact_msg_rd_a1),
    .o_dout_b0(c2v_compact_msg_rd_b0),
    .o_dout_b1(c2v_compact_msg_rd_b1),
    .i_we0(m_wr_en0),
    .i_w_addr0(cnu_a_wr_row0),
    .i_din0(c2v_compact_msg_wr0),
    .i_we1(m_wr_en1),
    .i_w_addr1(cnu_a_wr_row1),
    .i_din1(c2v_compact_msg_wr1)
  );

  ram_s u_s_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(s_clear_en),
    .i_r_var0(active_var_idx),
    .i_r_edge0(lane_edge0_edge_slot),
    .i_r_var1(active_var_idx),
    .i_r_edge1(lane_edge1_edge_slot),
    .o_sign0(v2c_sign0),
    .o_sign1(v2c_sign1),
    .i_we0(s_wr_en0),
    .i_w_var0(cnu_a_wr_var0),
    .i_w_edge0(cnu_a_wr_edge0),
    .i_din0(v2c_sign_wr0),
    .i_we1(s_wr_en1),
    .i_w_var1(cnu_a_wr_var1),
    .i_w_edge1(cnu_a_wr_edge1),
    .i_din1(v2c_sign_wr1)
  );

  ram_t u_t_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(t_clear_en),
    .i_re0((state == DEC_VNU_ACCUM || state == DEC_VNU_EMIT) && vnu_edge0_valid),
    .i_r_var0(active_var_idx),
    .i_r_edge0(vnu_edge0_slot),
    .o_dout0(t_rd_msg0),
    .i_re1((state == DEC_VNU_ACCUM || state == DEC_VNU_EMIT) && vnu_edge1_valid),
    .i_r_var1(active_var_idx),
    .i_r_edge1(vnu_edge1_slot),
    .o_dout1(t_rd_msg1),
    .i_we0(t_wr_en0),
    .i_w_var0(active_var_idx),
    .i_w_edge0(lane_edge0_edge_slot),
    .i_din0(c2v_msg_tc0),
    .i_we1(t_wr_en1),
    .i_w_var1(active_var_idx),
    .i_w_edge1(lane_edge1_edge_slot),
    .i_din1(c2v_msg_tc1)
  );

  ram_u u_u_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_init(u_init_en),
    .i_init_bits(i_x),
    .i_re0((state == DEC_CNU_A) && lane_edge0_valid),
    .i_r_var0(active_var_idx),
    .i_r_edge0(lane_edge0_edge_slot),
    .o_dout0(v2c_msg0),
    .i_re1((state == DEC_CNU_A) && lane_edge1_valid),
    .i_r_var1(active_var_idx),
    .i_r_edge1(lane_edge1_edge_slot),
    .o_dout1(v2c_msg1),
    .i_we0(u_wr_en0),
    .i_w_var0(active_var_idx),
    .i_w_edge0(vnu_edge0_slot),
    .i_din0(vnu_v2c0),
    .i_we1(u_wr_en1),
    .i_w_var1(active_var_idx),
    .i_w_edge1(vnu_edge1_slot),
    .i_din1(vnu_v2c1)
  );

  cnu_a u_cnu_a_lane0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear_en),
    .i_en(cnu_a_issue_phase && lane_edge0_valid),
    .i_v2c(v2c_msg0),
    .i_idx(active_var_idx),
    .i_comp_c2v(c2v_compact_msg_rd_a0),
    .o_comp_c2v(c2v_compact_msg_wr0),
    .o_sign(v2c_sign_wr0),
    .o_valid(cnu_a_out_valid0)
  );

  cnu_a u_cnu_a_lane1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear_en),
    .i_en(cnu_a_issue_phase && lane_edge1_valid),
    .i_v2c(v2c_msg1),
    .i_idx(active_var_idx),
    .i_comp_c2v(c2v_compact_msg_rd_a1),
    .o_comp_c2v(c2v_compact_msg_wr1),
    .o_sign(v2c_sign_wr1),
    .o_valid(cnu_a_out_valid1)
  );

  cnu_b u_cnu_b_lane0 (
    .i_comp_c2v(c2v_compact_msg_rd_b0),
    .i_sign(v2c_sign0),
    .i_idx(active_var_idx),
    .o_c2v(c2v_msg0)
  );

  cnu_b u_cnu_b_lane1 (
    .i_comp_c2v(c2v_compact_msg_rd_b1),
    .i_sign(v2c_sign1),
    .i_idx(active_var_idx),
    .o_c2v(c2v_msg1)
  );

  vnu u_vnu (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear((state == DEC_LOAD) || continue_decode),
    .i_col_start(vnu_col_start),
    .i_col_end(vnu_col_end),
    .i_initial_llr(prior_msg),
    .i_c2v_valid0(vnu_accum_valid0),
    .i_c2v_sign0(vnu_accum_sign0),
    .i_c2v_mag0(vnu_accum_mag0),
    .i_c2v_valid1(vnu_accum_valid1),
    .i_c2v_sign1(vnu_accum_sign1),
    .i_c2v_mag1(vnu_accum_mag1),
    .o_app_valid(),
    .o_app(),
    .o_bit_decision(vnu_x_out),
    .i_emit_en(vnu_emit_en),
    .i_c2v_t_valid0(vnu_edge0_valid),
    .i_c2v_t0(t_rd_msg0),
    .i_c2v_t_valid1(vnu_edge1_valid),
    .i_c2v_t1(t_rd_msg1),
    .o_v2c_valid0(vnu_v2c_valid0),
    .o_v2c0(vnu_v2c0),
    .o_v2c_valid1(vnu_v2c_valid1),
    .o_v2c1(vnu_v2c1)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer row_idx_local;

    if (!i_rst_n) begin
      state <= DEC_IDLE;
      o_done <= 1'b0;
      o_success <= 1'b0;
      o_x <= '0;
      o_iter_count <= '0;
      active_var_idx <= '0;
      scan_slot <= '0;
      cnu_a_flush_pending <= 1'b0;

      for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
        syndrome_hist[row_idx_local] <= '0;
      end
    end else begin
      case (state)
        DEC_IDLE: begin
          o_done <= 1'b0;
          o_success <= 1'b0;
          if (i_start) begin
            state <= DEC_LOAD;
          end
        end

        DEC_LOAD: begin
          o_done <= 1'b0;
          o_success <= 1'b0;
          o_x <= i_x;
          o_iter_count <= '0;
          active_var_idx <= '0;
          scan_slot <= '0;
          cnu_a_flush_pending <= 1'b0;
          for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
            syndrome_hist[row_idx_local] <= '0;
          end
          state <= DEC_CNU_A;
        end

        DEC_CNU_A: begin
          if (cnu_a_flush_pending) begin
            cnu_a_flush_pending <= 1'b0;
            active_var_idx <= '0;
            scan_slot <= '0;
            state <= DEC_CNU_B;
          end else if (advance_var) begin
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              cnu_a_flush_pending <= 1'b1;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_CNU_B: begin
          if (advance_var) begin
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_VNU_ACCUM;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_VNU_ACCUM: begin
          if (scan_slot == VNU_LAST_SLOT) begin
            scan_slot <= '0;
            state <= DEC_VNU_EMIT;
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_VNU_EMIT: begin
          if (scan_slot == '0) begin
            o_x[active_var_idx] <= vnu_x_out;
          end
          if (scan_slot == VNU_LAST_SLOT) begin
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_CHECK;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
              state <= DEC_VNU_ACCUM;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_CHECK: begin
          syndrome_hist[o_iter_count[HIST_IDX_W-1:0]] <= syndrome_next;
          o_iter_count <= next_iter_count;

          if (stop_decode) begin
            o_done <= 1'b1;
            o_success <= (syndrome_next == '0);
            o_x <= c1_bits;
            state <= DEC_DONE;
          end else begin
            active_var_idx <= '0;
            scan_slot <= '0;
            cnu_a_flush_pending <= 1'b0;
            state <= DEC_CNU_A;
          end
        end

        DEC_DONE: begin
          o_done <= 1'b1;
          o_x <= c1_bits;
        end

        default: begin
          state <= DEC_IDLE;
          cnu_a_flush_pending <= 1'b0;
        end
      endcase
    end
  end
endmodule
