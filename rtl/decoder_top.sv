// Top-level BIKE min-sum decoder datapath and module interconnect.
module decoder_top
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_start,                         // Starts a new decode operation.
  input  logic [R-1:0] i_syndrome,              // Input syndrome to be cancelled by the estimate.
  output logic o_done,                          // High when decoding has finished.
  output logic o_success,                       // High when the final residual syndrome is zero.
  output logic [N-1:0] o_e,                     // Final error estimate vector.
  output logic [$clog2(I_MAX + 1)-1:0] o_iter_count  // Number of iterations that completed.
);

  timeunit 1ns;
  timeprecision 1ps;

  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam int HIST_IDX_W = (I_MAX > 1) ? $clog2(I_MAX) : 1;

  /* verilator lint_off UNUSEDSIGNAL */
  logic [DEC_STATE_W-1:0] state;
  logic [DEC_PHASE_W-1:0] phase;
  /* verilator lint_on UNUSEDSIGNAL */
  logic [VAR_W-1:0] work_var;
  logic [EDGE_W-1:0] work_edge;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [VAR_W-1:0] c2v_var_idx;
  logic [EDGE_W-1:0] col_slot_idx;
  /* verilator lint_on UNUSEDSIGNAL */
  logic comp_c2v_read_bank;
  logic comp_c2v_write_bank;
  logic seed_active;
  logic [BANK_W-1:0] seed_bank;

  logic init_clear;
  logic clear_next_m;
  logic init_m_read;
  logic init_cnu_a;
  logic init_m_write;
  logic c2v_read;
  logic c2v_write_t;
  logic vnu_read_t;
  logic vnu_accum_t;
  logic vnu_prep_write;
  logic vnu_read_next_m;
  logic vnu_cnu_a;
  logic vnu_write_next;
  logic iter_check;
  /* verilator lint_off UNUSEDSIGNAL */
  logic c2v_phase_active;
  logic v2c_phase_active;
  logic c2v_v2c_overlap_seen;
  /* verilator lint_on UNUSEDSIGNAL */

  logic [ROW_W-1:0] edge_row_global;
  logic [ROW_W-1:0] edge_row_local;
  logic [LANE_IDX_W-1:0] edge_lane_idx;

  logic [ROW_W-1:0] latched_row_global;
  logic [ROW_W-1:0] latched_row_local;
  logic [LANE_IDX_W-1:0] latched_lane_idx;
  logic [EDGE_W-1:0] latched_edge;
  logic [VAR_W-1:0] latched_var;
  logic latched_m_pair;
  logic signed [MSG_W-1:0] c2v_col_tc [0:W-1];
  logic [MSG_W-1:0] u_next_msg_reg;

  logic [R-1:0] residual_syndrome_next;
  logic decode_success;
  logic finish_decode;
  logic [ITER_W:0] next_iter_count_ext;
  logic [HIST_IDX_W-1:0] hist_wr_idx;

  /* verilator lint_off UNUSEDSIGNAL */
  logic [R-1:0] syndrome_hist [0:I_MAX-1];
  logic [I_ENTRY_W-1:0] ram_i_debug_mem [0:N0-1][0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] ram_i_debug_count [0:N0-1][0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_dout_unused [0:L-1];
  logic [LANE_COUNT_W-1:0] ram_i_count_unused [0:L-1];
  logic error_estimate_rd_unused;
  logic error_estimate_c1_dout_unused;
  logic [N-1:0] error_estimate_c0_bits_unused;
  logic [N-1:0] error_estimate_bits;
  logic signed [APP_W-1:0] vnu_app_unused;
  logic vnu_app_valid_unused;
  logic vnu_v2c_tc_valid_unused;
  logic signed [VNU_TC_W-1:0] vnu_v2c_tc_unused;
  logic vnu_v2c_msg_valid_unused;
  logic [MSG_W-1:0] vnu_v2c_msg_unused;
  logic c2v_tc_valid_unused;
  logic [VAR_W-1:0] v2c_var_idx;
  logic active_m_pair;
  logic next_m_pair;
  logic [BANK_W-1:0] edge_bank_idx;
  logic [ROW_W-1:0] edge_col_idx;
  /* verilator lint_on UNUSEDSIGNAL */

  logic [I_ENTRY_W-1:0] ram_i0_debug_entries [0:N0-1][0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_debug_entries [0:N0-1][0:W-1];
  logic [LANE_COUNT_W-1:0] ram_i0_debug_count [0:N0-1];
  logic [LANE_COUNT_W-1:0] ram_i1_debug_count [0:N0-1];
  logic [I_ENTRY_W-1:0] ram_i0_load_entries [0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_load_entries [0:W-1];
  logic [LANE_COUNT_W-1:0] ram_i0_load_count;
  logic [LANE_COUNT_W-1:0] ram_i1_load_count;

  logic m_clear [0:3];
  logic m_en [0:3];
  logic m_we [0:3];
  logic [ROW_W-1:0] m_addr [0:3];
  logic [COMP_C2V_W-1:0] m_din [0:3];
  logic [COMP_C2V_W-1:0] m_dout [0:3];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [COMP_C2V_W-1:0] ram_m0_debug_mem [0:R-1];
  logic [COMP_C2V_W-1:0] ram_m1_debug_mem [0:R-1];
  logic [COMP_C2V_W-1:0] ram_m2_debug_mem [0:R-1];
  logic [COMP_C2V_W-1:0] ram_m3_debug_mem [0:R-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic s_clear;
  logic s_en [0:L-1];
  logic s_we [0:L-1];
  logic [VAR_W-1:0] s_var_addr [0:L-1];
  logic [EDGE_W-1:0] s_edge_addr [0:L-1];
  logic s_din [0:L-1];
  logic s_dout [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic ram_s0_debug_mem [0:N-1][0:W-1];
  logic ram_s1_debug_mem [0:N-1][0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic t_clear;
  logic t_en [0:L-1];
  logic t_we [0:L-1];
  logic [VAR_W-1:0] t_var_addr [0:L-1];
  logic [EDGE_W-1:0] t_edge_addr [0:L-1];
  logic signed [MSG_W-1:0] t_din [0:L-1];
  logic signed [MSG_W-1:0] t_dout [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic signed [MSG_W-1:0] ram_t0_debug_mem [0:N-1][0:W-1];
  logic signed [MSG_W-1:0] ram_t1_debug_mem [0:N-1][0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic u_init;
  logic u_en [0:L-1];
  logic u_we [0:L-1];
  logic [VAR_W-1:0] u_var_addr [0:L-1];
  logic [EDGE_W-1:0] u_edge_addr [0:L-1];
  logic [MSG_W-1:0] u_din [0:L-1];
  logic [MSG_W-1:0] u_dout [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [MSG_W-1:0] ram_u0_debug_mem [0:N-1][0:W-1];
  logic [MSG_W-1:0] ram_u1_debug_mem [0:N-1][0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic c1_en;
  logic c1_we;
  logic [VAR_W-1:0] c1_addr;
  logic c1_din;

  logic cnu_a_en;
  logic [MSG_W-1:0] cnu_a_v2c_msg;
  logic [COMP_C2V_W-1:0] cnu_a_comp_in;
  logic [COMP_C2V_W-1:0] cnu_a_comp_out;
  logic cnu_a_sign;
  logic cnu_a_valid;

  logic [MSG_W-1:0] c2v_msg;
  logic signed [MSG_W-1:0] c2v_tc;

  logic vnu_col_start;
  logic vnu_col_end;
  logic vnu_accum_valid;
  logic signed [MSG_W-1:0] vnu_accum_c2v;
  logic vnu_emit_en;
  logic vnu_prev_c2v_valid;
  logic signed [MSG_W-1:0] vnu_prev_c2v;
  logic vnu_bit_out;
  logic vnu_v2c_tc_valid;
  logic signed [VNU_TC_W-1:0] vnu_v2c_tc;
  logic vnu_v2c_msg_valid;
  logic [MSG_W-1:0] vnu_v2c_msg;

  function automatic int m_index(input logic pair, input logic [LANE_IDX_W-1:0] lane);
    begin
      m_index = (pair ? 2 : 0) + int'(lane);
    end
  endfunction

  assign next_iter_count_ext = {1'b0, o_iter_count} + {{ITER_W{1'b0}}, 1'b1};
  assign hist_wr_idx = o_iter_count[HIST_IDX_W-1:0];
  assign decode_success = (residual_syndrome_next == '0);
  assign finish_decode = decode_success || (next_iter_count_ext >= (ITER_W + 1)'(I_MAX));

  decoder_edge_meta u_edge_meta (
    .i_var_idx(work_var),
    .i_edge_idx(work_edge),
    .o_bank_idx(edge_bank_idx),
    .o_col_idx(edge_col_idx),
    .o_row_global(edge_row_global),
    .o_row_local(edge_row_local),
    .o_lane_idx(edge_lane_idx)
  );

  always_comb begin
    integer bank_idx;
    integer slot_idx;
    integer lane_idx;
    integer var_idx;
    integer edge_idx;
    logic [BANK_W-1:0] residual_bank;
    integer residual_col;
    logic [ROW_W-1:0] residual_row;

    for (bank_idx = 0; bank_idx < N0; bank_idx++) begin
      ram_i_debug_count[bank_idx][0] = ram_i0_debug_count[bank_idx];
      ram_i_debug_count[bank_idx][1] = ram_i1_debug_count[bank_idx];
      for (slot_idx = 0; slot_idx < W; slot_idx++) begin
        ram_i_debug_mem[bank_idx][0][slot_idx] = ram_i0_debug_entries[bank_idx][slot_idx];
        ram_i_debug_mem[bank_idx][1][slot_idx] = ram_i1_debug_entries[bank_idx][slot_idx];
      end
    end

    for (slot_idx = 0; slot_idx < W; slot_idx++) begin
      ram_i0_load_entries[slot_idx] = QC_FIRST_COL_LANE_ENTRY[seed_bank][0][slot_idx];
      ram_i1_load_entries[slot_idx] = QC_FIRST_COL_LANE_ENTRY[seed_bank][1][slot_idx];
    end
    ram_i0_load_count = QC_FIRST_COL_LANE_COUNT[seed_bank][0];
    ram_i1_load_count = QC_FIRST_COL_LANE_COUNT[seed_bank][1];

    for (slot_idx = 0; slot_idx < 4; slot_idx++) begin
      m_clear[slot_idx] = 1'b0;
      m_en[slot_idx] = 1'b0;
      m_we[slot_idx] = 1'b0;
      m_addr[slot_idx] = edge_row_local;
      m_din[slot_idx] = COMP_C2V_INIT;
    end

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      s_en[lane_idx] = 1'b0;
      s_we[lane_idx] = 1'b0;
      s_var_addr[lane_idx] = work_var;
      s_edge_addr[lane_idx] = work_edge;
      s_din[lane_idx] = 1'b0;

      t_en[lane_idx] = 1'b0;
      t_we[lane_idx] = 1'b0;
      t_var_addr[lane_idx] = work_var;
      t_edge_addr[lane_idx] = work_edge;
      t_din[lane_idx] = '0;

      u_en[lane_idx] = 1'b0;
      u_we[lane_idx] = 1'b0;
      u_var_addr[lane_idx] = work_var;
      u_edge_addr[lane_idx] = work_edge;
      u_din[lane_idx] = '0;
    end

    s_clear = init_clear;
    t_clear = init_clear;
    u_init = init_clear;
    c1_en = 1'b0;
    c1_we = 1'b0;
    c1_addr = work_var;
    c1_din = 1'b0;

    if (init_clear) begin
      m_clear[0] = 1'b1;
      m_clear[1] = 1'b1;
      m_clear[2] = 1'b1;
      m_clear[3] = 1'b1;
    end

    if (clear_next_m) begin
      m_clear[m_index(comp_c2v_write_bank, LANE_IDX_W'(0))] = 1'b1;
      m_clear[m_index(comp_c2v_write_bank, LANE_IDX_W'(1))] = 1'b1;
    end

    if (init_m_read || c2v_read || vnu_read_next_m) begin
      m_en[m_index(vnu_read_next_m ? comp_c2v_write_bank : comp_c2v_read_bank, edge_lane_idx)] = 1'b1;
      m_addr[m_index(vnu_read_next_m ? comp_c2v_write_bank : comp_c2v_read_bank, edge_lane_idx)] = edge_row_local;
    end

    if (init_m_read) begin
      u_en[edge_lane_idx] = 1'b1;
      u_var_addr[edge_lane_idx] = work_var;
      u_edge_addr[edge_lane_idx] = work_edge;
    end

    if (c2v_read) begin
      s_en[edge_lane_idx] = 1'b1;
      s_var_addr[edge_lane_idx] = work_var;
      s_edge_addr[edge_lane_idx] = work_edge;
    end

    if (c2v_write_t) begin
      t_en[latched_lane_idx] = 1'b1;
      t_we[latched_lane_idx] = 1'b1;
      t_var_addr[latched_lane_idx] = latched_var;
      t_edge_addr[latched_lane_idx] = latched_edge;
      t_din[latched_lane_idx] = c2v_tc;
    end

    if (vnu_read_t) begin
      t_en[edge_lane_idx] = 1'b1;
      t_var_addr[edge_lane_idx] = work_var;
      t_edge_addr[edge_lane_idx] = work_edge;
    end

    if (init_m_write && cnu_a_valid) begin
      m_en[m_index(latched_m_pair, latched_lane_idx)] = 1'b1;
      m_we[m_index(latched_m_pair, latched_lane_idx)] = 1'b1;
      m_addr[m_index(latched_m_pair, latched_lane_idx)] = latched_row_local;
      m_din[m_index(latched_m_pair, latched_lane_idx)] = cnu_a_comp_out;

      s_en[latched_lane_idx] = 1'b1;
      s_we[latched_lane_idx] = 1'b1;
      s_var_addr[latched_lane_idx] = latched_var;
      s_edge_addr[latched_lane_idx] = latched_edge;
      s_din[latched_lane_idx] = cnu_a_sign;
    end

    if (vnu_prep_write) begin
      c1_en = 1'b1;
      c1_we = 1'b1;
      c1_addr = work_var;
      c1_din = vnu_bit_out;
    end

    if (vnu_write_next && cnu_a_valid) begin
      u_en[latched_lane_idx] = 1'b1;
      u_we[latched_lane_idx] = 1'b1;
      u_var_addr[latched_lane_idx] = latched_var;
      u_edge_addr[latched_lane_idx] = latched_edge;
      u_din[latched_lane_idx] = u_next_msg_reg;

      m_en[m_index(latched_m_pair, latched_lane_idx)] = 1'b1;
      m_we[m_index(latched_m_pair, latched_lane_idx)] = 1'b1;
      m_addr[m_index(latched_m_pair, latched_lane_idx)] = latched_row_local;
      m_din[m_index(latched_m_pair, latched_lane_idx)] = cnu_a_comp_out;

      s_en[latched_lane_idx] = 1'b1;
      s_we[latched_lane_idx] = 1'b1;
      s_var_addr[latched_lane_idx] = latched_var;
      s_edge_addr[latched_lane_idx] = latched_edge;
      s_din[latched_lane_idx] = cnu_a_sign;
    end

    residual_syndrome_next = i_syndrome;
    residual_bank = '0;
    residual_col = 0;
    residual_row = '0;
    for (var_idx = 0; var_idx < N; var_idx++) begin
      if (o_e[var_idx]) begin
        residual_bank = BANK_W'(var_idx / R);
        residual_col = var_idx % R;
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          residual_row = ROW_W'((H_BASE[0][residual_bank][edge_idx] + residual_col) % R);
          residual_syndrome_next[residual_row] = residual_syndrome_next[residual_row] ^ 1'b1;
        end
      end
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer idx;

    if (!i_rst_n) begin
      o_e <= '0;
      latched_row_global <= '0;
      latched_row_local <= '0;
      latched_lane_idx <= '0;
      latched_edge <= '0;
      latched_var <= '0;
      latched_m_pair <= 1'b0;
      u_next_msg_reg <= '0;
      for (idx = 0; idx < W; idx++) begin
        c2v_col_tc[idx] <= '0;
      end
      for (idx = 0; idx < I_MAX; idx++) begin
        syndrome_hist[idx] <= '0;
      end
    end else begin
      if (init_clear) begin
        o_e <= '0;
        u_next_msg_reg <= '0;
        for (idx = 0; idx < W; idx++) begin
          c2v_col_tc[idx] <= '0;
        end
        for (idx = 0; idx < I_MAX; idx++) begin
          syndrome_hist[idx] <= '0;
        end
      end

      if (init_m_read || c2v_read || vnu_read_t || vnu_read_next_m) begin
        latched_var <= work_var;
        latched_edge <= work_edge;
        latched_row_global <= edge_row_global;
        latched_row_local <= edge_row_local;
        latched_lane_idx <= edge_lane_idx;
        latched_m_pair <= vnu_read_next_m ? comp_c2v_write_bank : comp_c2v_read_bank;
      end

      if (vnu_accum_t) begin
        c2v_col_tc[latched_edge] <= t_dout[latched_lane_idx];
      end

      if (vnu_cnu_a && vnu_v2c_msg_valid) begin
        u_next_msg_reg <= vnu_v2c_msg;
      end

      if (vnu_prep_write) begin
        o_e[work_var] <= vnu_bit_out;
      end

      if (iter_check) begin
        syndrome_hist[hist_wr_idx] <= residual_syndrome_next;
      end
    end
  end

  assign cnu_a_en = init_cnu_a || vnu_cnu_a;
  assign cnu_a_v2c_msg = init_cnu_a ? u_dout[latched_lane_idx] : vnu_v2c_msg;
  assign cnu_a_comp_in = m_dout[m_index(latched_m_pair, latched_lane_idx)];

  cnu_a u_cnu_a (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(init_clear),
    .i_en(cnu_a_en),
    .i_v2c(cnu_a_v2c_msg),
    .i_var_idx(latched_var),
    .i_comp_c2v(cnu_a_comp_in),
    .o_comp_c2v(cnu_a_comp_out),
    .o_sign(cnu_a_sign),
    .o_valid(cnu_a_valid)
  );

  cnu_b u_cnu_b (
    .i_comp_c2v(m_dout[m_index(latched_m_pair, latched_lane_idx)]),
    .i_v2c_sign(s_dout[latched_lane_idx]),
    .i_syndrome_bit(i_syndrome[latched_row_global]),
    .i_var_idx(latched_var),
    .o_c2v_msg(c2v_msg)
  );

  msg_signmag_to_tc u_c2v_tc_codec (
    .i_valid(c2v_write_t),
    .i_sign(c2v_msg[MSG_SIGN_BIT]),
    .i_mag(c2v_msg[MSG_MAG_LSB +: D]),
    .o_valid(c2v_tc_valid_unused),
    .o_tc(c2v_tc)
  );

  assign vnu_col_start = vnu_accum_t && (latched_edge == '0);
  assign vnu_col_end = vnu_accum_t && (latched_edge == EDGE_W'(W - 1));
  assign vnu_accum_valid = vnu_accum_t;
  assign vnu_accum_c2v = t_dout[latched_lane_idx];
  assign vnu_emit_en = vnu_cnu_a;
  assign vnu_prev_c2v_valid = vnu_cnu_a;
  assign vnu_prev_c2v = c2v_col_tc[work_edge];

  vnu u_vnu (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(init_clear),
    .i_col_start(vnu_col_start),
    .i_col_end(vnu_col_end),
    .i_initial_llr($signed(APP_W'(C_VAL))),
    .i_c2v_tc_valid0(vnu_accum_valid),
    .i_c2v_tc0(vnu_accum_c2v),
    .i_c2v_tc_valid1(1'b0),
    .i_c2v_tc1('0),
    .o_app_valid(vnu_app_valid_unused),
    .o_app(vnu_app_unused),
    .o_bit_decision(vnu_bit_out),
    .i_emit_en(vnu_emit_en),
    .i_prev_c2v_tc_valid0(vnu_prev_c2v_valid),
    .i_prev_c2v_tc0(vnu_prev_c2v),
    .i_prev_c2v_tc_valid1(1'b0),
    .i_prev_c2v_tc1('0),
    .o_v2c_tc_valid0(vnu_v2c_tc_valid),
    .o_v2c_tc0(vnu_v2c_tc),
    .o_v2c_tc_valid1(vnu_v2c_tc_valid_unused),
    .o_v2c_tc1(vnu_v2c_tc_unused)
  );

  msg_tc_to_signmag_sat #(
    .TC_W(VNU_TC_W)
  ) u_vnu_v2c_msg_codec (
    .i_valid(vnu_v2c_tc_valid),
    .i_tc(vnu_v2c_tc),
    .o_valid(vnu_v2c_msg_valid),
    .o_msg(vnu_v2c_msg)
  );

  msg_tc_to_signmag_sat #(
    .TC_W(VNU_TC_W)
  ) u_vnu_v2c_msg_codec_unused (
    .i_valid(vnu_v2c_tc_valid_unused),
    .i_tc(vnu_v2c_tc_unused),
    .o_valid(vnu_v2c_msg_valid_unused),
    .o_msg(vnu_v2c_msg_unused)
  );

  decoder_ctrl u_decoder_ctrl (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(i_start),
    .i_finish_decode(finish_decode),
    .i_decode_success(decode_success),
    .o_state(state),
    .o_phase(phase),
    .o_work_var(work_var),
    .o_work_edge(work_edge),
    .o_c2v_var_idx(c2v_var_idx),
    .o_v2c_var_idx(v2c_var_idx),
    .o_col_slot_idx(col_slot_idx),
    .o_active_m_pair(active_m_pair),
    .o_next_m_pair(next_m_pair),
    .o_comp_c2v_read_bank(comp_c2v_read_bank),
    .o_comp_c2v_write_bank(comp_c2v_write_bank),
    .o_seed_active(seed_active),
    .o_seed_bank(seed_bank),
    .o_init_clear(init_clear),
    .o_clear_next_m(clear_next_m),
    .o_init_m_read(init_m_read),
    .o_init_cnu_a(init_cnu_a),
    .o_init_m_write(init_m_write),
    .o_c2v_read(c2v_read),
    .o_c2v_write_t(c2v_write_t),
    .o_vnu_read_t(vnu_read_t),
    .o_vnu_accum_t(vnu_accum_t),
    .o_vnu_prep_write(vnu_prep_write),
    .o_vnu_read_next_m(vnu_read_next_m),
    .o_vnu_cnu_a(vnu_cnu_a),
    .o_vnu_write_next(vnu_write_next),
    .o_iter_check(iter_check),
    .o_c2v_pipe_valid(c2v_phase_active),
    .o_v2c_pipe_valid(v2c_phase_active),
    .o_c2v_v2c_overlap_seen(c2v_v2c_overlap_seen),
    .o_done(o_done),
    .o_success(o_success),
    .o_iter_count(o_iter_count)
  );

  ram_i u_ram_i0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_en(1'b0),
    .i_we(1'b0),
    .i_bank(seed_bank),
    .i_addr('0),
    .i_din('0),
    .i_count_we(1'b0),
    .i_count_din('0),
    .i_load(seed_active),
    .i_load_bank(seed_bank),
    .i_load_entries(ram_i0_load_entries),
    .i_load_count(ram_i0_load_count),
    .o_dout(ram_i_dout_unused[0]),
    .o_count(ram_i_count_unused[0]),
    .o_debug_entries(ram_i0_debug_entries),
    .o_debug_count(ram_i0_debug_count)
  );

  ram_i u_ram_i1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_en(1'b0),
    .i_we(1'b0),
    .i_bank(seed_bank),
    .i_addr('0),
    .i_din('0),
    .i_count_we(1'b0),
    .i_count_din('0),
    .i_load(seed_active),
    .i_load_bank(seed_bank),
    .i_load_entries(ram_i1_load_entries),
    .i_load_count(ram_i1_load_count),
    .o_dout(ram_i_dout_unused[1]),
    .o_count(ram_i_count_unused[1]),
    .o_debug_entries(ram_i1_debug_entries),
    .o_debug_count(ram_i1_debug_count)
  );

  ram_c u_ram_c0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(init_clear),
    .i_load_bits('0),
    .i_en(1'b0),
    .i_we(1'b0),
    .i_addr(work_var),
    .i_din(1'b0),
    .o_dout(error_estimate_rd_unused),
    .o_debug_bits(error_estimate_c0_bits_unused)
  );

  ram_c u_ram_c1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(init_clear),
    .i_load_bits('0),
    .i_en(c1_en),
    .i_we(c1_we),
    .i_addr(c1_addr),
    .i_din(c1_din),
    .o_dout(error_estimate_c1_dout_unused),
    .o_debug_bits(error_estimate_bits)
  );

  ram_m u_ram_m0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[0]),
    .i_en(m_en[0]),
    .i_we(m_we[0]),
    .i_addr(m_addr[0]),
    .i_din(m_din[0]),
    .o_dout(m_dout[0]),
    .o_debug_mem(ram_m0_debug_mem)
  );

  ram_m u_ram_m1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[1]),
    .i_en(m_en[1]),
    .i_we(m_we[1]),
    .i_addr(m_addr[1]),
    .i_din(m_din[1]),
    .o_dout(m_dout[1]),
    .o_debug_mem(ram_m1_debug_mem)
  );

  ram_m u_ram_m2 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[2]),
    .i_en(m_en[2]),
    .i_we(m_we[2]),
    .i_addr(m_addr[2]),
    .i_din(m_din[2]),
    .o_dout(m_dout[2]),
    .o_debug_mem(ram_m2_debug_mem)
  );

  ram_m u_ram_m3 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[3]),
    .i_en(m_en[3]),
    .i_we(m_we[3]),
    .i_addr(m_addr[3]),
    .i_din(m_din[3]),
    .o_dout(m_dout[3]),
    .o_debug_mem(ram_m3_debug_mem)
  );

  ram_s u_ram_s0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(s_clear),
    .i_en(s_en[0]),
    .i_we(s_we[0]),
    .i_var_addr(s_var_addr[0]),
    .i_edge_addr(s_edge_addr[0]),
    .i_din(s_din[0]),
    .o_dout(s_dout[0]),
    .o_debug_mem(ram_s0_debug_mem)
  );

  ram_s u_ram_s1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(s_clear),
    .i_en(s_en[1]),
    .i_we(s_we[1]),
    .i_var_addr(s_var_addr[1]),
    .i_edge_addr(s_edge_addr[1]),
    .i_din(s_din[1]),
    .o_dout(s_dout[1]),
    .o_debug_mem(ram_s1_debug_mem)
  );

  ram_t u_ram_t0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(t_clear),
    .i_en(t_en[0]),
    .i_we(t_we[0]),
    .i_var_addr(t_var_addr[0]),
    .i_edge_addr(t_edge_addr[0]),
    .i_din(t_din[0]),
    .o_dout(t_dout[0]),
    .o_debug_mem(ram_t0_debug_mem)
  );

  ram_t u_ram_t1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(t_clear),
    .i_en(t_en[1]),
    .i_we(t_we[1]),
    .i_var_addr(t_var_addr[1]),
    .i_edge_addr(t_edge_addr[1]),
    .i_din(t_din[1]),
    .o_dout(t_dout[1]),
    .o_debug_mem(ram_t1_debug_mem)
  );

  ram_u u_ram_u0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_init(u_init),
    .i_en(u_en[0]),
    .i_we(u_we[0]),
    .i_var_addr(u_var_addr[0]),
    .i_edge_addr(u_edge_addr[0]),
    .i_din(u_din[0]),
    .o_dout(u_dout[0]),
    .o_debug_mem(ram_u0_debug_mem)
  );

  ram_u u_ram_u1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_init(u_init),
    .i_en(u_en[1]),
    .i_we(u_we[1]),
    .i_var_addr(u_var_addr[1]),
    .i_edge_addr(u_edge_addr[1]),
    .i_din(u_din[1]),
    .o_dout(u_dout[1]),
    .o_debug_mem(ram_u1_debug_mem)
  );
endmodule
