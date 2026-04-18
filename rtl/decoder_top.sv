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
  localparam int VNU_SLOT_COUNT = (W + L - 1) / L;

  logic [DEC_STATE_W-1:0] state;
  logic [R-1:0] syndrome_hist [0:I_MAX-1];

  logic [VAR_W-1:0] active_var_idx;
  logic [VAR_W-1:0] emit_var_idx;
  logic [EDGE_W-1:0] scan_slot;
  logic m_read_bank;
  logic m_write_bank;
  logic fill_edge_buf_sel;
  logic emit_edge_buf_sel;
  logic pipeline_overlap_seen;

  logic [BANK_W-1:0] current_bank;
  logic [I_ENTRY_W-1:0] current_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] current_lane_count [0:L-1];
  logic [LANE_COUNT_W-1:0] current_scan_limit;
  logic [LANE_EDGE_W-1:0] current_lane_edges [0:L-1][0:W-1];
  logic [LANE_EDGE_W-1:0] edge_buf [0:1][0:W-1];

  logic [LANE_EDGE_W-1:0] lane_edge0;
  logic [LANE_EDGE_W-1:0] lane_edge1;
  logic lane_edge0_present;
  logic lane_edge1_present;
  logic lane_edge0_valid;
  logic lane_edge1_valid;
  logic [ROW_W-1:0] lane_edge0_row_local;
  logic [ROW_W-1:0] lane_edge1_row_local;
  logic [EDGE_W-1:0] lane_edge0_edge_slot;
  logic [EDGE_W-1:0] lane_edge1_edge_slot;

  logic [EDGE_W-1:0] emit_edge0_slot;
  logic [EDGE_W-1:0] emit_edge1_slot;
  logic [LANE_EDGE_W-1:0] emit_edge0;
  logic [LANE_EDGE_W-1:0] emit_edge1;
  logic emit_edge0_valid;
  logic emit_edge1_valid;
  logic [LANE_IDX_W-1:0] emit_edge0_lane;
  logic [LANE_IDX_W-1:0] emit_edge1_lane;
  logic [ROW_W-1:0] emit_edge0_row_local;
  logic [ROW_W-1:0] emit_edge1_row_local;

  logic c0_rd_bit;
  logic [N-1:0] c1_bits;
  logic c1_rd_unused;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a1;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b1;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr1;
  logic [MSG_W-1:0] u_init_msg0;
  logic [MSG_W-1:0] u_init_msg1;
  logic [MSG_W-1:0] cnu_a_v2c0;
  logic [MSG_W-1:0] cnu_a_v2c1;
  logic v2c_sign0;
  logic v2c_sign1;
  logic v2c_sign_wr0;
  logic v2c_sign_wr1;
  logic cnu_a_out_valid0;
  logic cnu_a_out_valid1;
  logic [MSG_W-1:0] c2v_msg0;
  logic [MSG_W-1:0] c2v_msg1;
  logic signed [MSG_W-1:0] c2v_msg_tc0;
  logic signed [MSG_W-1:0] c2v_msg_tc1;
  logic signed [MSG_W-1:0] t_rd_msg0;
  logic signed [MSG_W-1:0] t_rd_msg1;
  logic signed [APP_W-1:0] prior_msg;
  logic vnu_x_out;
  logic vnu_col_start;
  logic vnu_col_end;
  logic vnu_accum_valid0;
  logic vnu_accum_valid1;
  logic vnu_emit_en;
  logic vnu_v2c_valid0;
  logic vnu_v2c_valid1;
  logic [MSG_W-1:0] vnu_v2c0;
  logic [MSG_W-1:0] vnu_v2c1;

  logic [ROW_W-1:0] cnu_a_wr_row0;
  logic [ROW_W-1:0] cnu_a_wr_row1;
  logic [EDGE_W-1:0] cnu_a_wr_edge0;
  logic [EDGE_W-1:0] cnu_a_wr_edge1;
  logic [VAR_W-1:0] cnu_a_wr_var0;
  logic [VAR_W-1:0] cnu_a_wr_var1;
  logic [LANE_IDX_W-1:0] cnu_a_wr_lane0;
  logic [LANE_IDX_W-1:0] cnu_a_wr_lane1;
  logic cnu_a_wr_bank0;
  logic cnu_a_wr_bank1;

  logic init_cnu_a_active;
  logic cnu_b_active;
  logic emit_active;
  logic cnu_a_en0;
  logic cnu_a_en1;
  logic c1_wr_en;
  logic m_clear_all_en;
  logic m_clear_bank_en;
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
  logic slot_last;
  logic [ITER_W-1:0] next_iter_count;
  logic stop_decode;
  logic continue_decode;
  logic [R-1:0] syndrome_next;

  assign current_bank = BANK_W'(int'(active_var_idx) / R);
  assign current_scan_limit =
    (current_lane_count[0] >= current_lane_count[1]) ? current_lane_count[0] : current_lane_count[1];
  assign lane_edge0 = current_lane_edges[0][scan_slot];
  assign lane_edge1 = current_lane_edges[1][scan_slot];
  assign lane_edge0_present = lane_edge0[LANE_EDGE_VALID_BIT];
  assign lane_edge1_present = lane_edge1[LANE_EDGE_VALID_BIT];
  assign lane_edge0_valid = cnu_b_active && lane_edge0_present;
  assign lane_edge1_valid = cnu_b_active && lane_edge1_present;
  assign lane_edge0_row_local = lane_edge0[LANE_EDGE_ROW_LOCAL_LSB +: ROW_W];
  assign lane_edge1_row_local = lane_edge1[LANE_EDGE_ROW_LOCAL_LSB +: ROW_W];
  assign lane_edge0_edge_slot = lane_edge0[LANE_EDGE_EDGE_SLOT_LSB +: EDGE_W];
  assign lane_edge1_edge_slot = lane_edge1[LANE_EDGE_EDGE_SLOT_LSB +: EDGE_W];

  assign emit_edge0_slot = EDGE_W'(int'(scan_slot) * L);
  assign emit_edge1_slot = EDGE_W'((int'(scan_slot) * L) + 1);
  assign emit_edge0 = edge_buf[emit_edge_buf_sel][emit_edge0_slot];
  assign emit_edge1 = edge_buf[emit_edge_buf_sel][emit_edge1_slot];
  assign emit_edge0_valid = emit_active && ((int'(scan_slot) * L) < W) && emit_edge0[LANE_EDGE_VALID_BIT];
  assign emit_edge1_valid = emit_active && (((int'(scan_slot) * L) + 1) < W) && emit_edge1[LANE_EDGE_VALID_BIT];
  assign emit_edge0_lane = edge_lane(emit_edge0);
  assign emit_edge1_lane = edge_lane(emit_edge1);
  assign emit_edge0_row_local = emit_edge0[LANE_EDGE_ROW_LOCAL_LSB +: ROW_W];
  assign emit_edge1_row_local = emit_edge1[LANE_EDGE_ROW_LOCAL_LSB +: ROW_W];

  assign prior_msg = c0_rd_bit ? -$signed(APP_W'(C_VAL)) : $signed(APP_W'(C_VAL));
  assign next_iter_count = o_iter_count + 1'b1;
  assign init_cnu_a_active = (state == DEC_INIT_CNU_A) && (int'(scan_slot) < int'(current_scan_limit));
  assign cnu_b_active =
    ((state == DEC_PIPE_PREP) || (state == DEC_PIPE)) && (int'(scan_slot) < int'(current_scan_limit));
  assign emit_active =
    ((state == DEC_PIPE) || (state == DEC_PIPE_DRAIN)) && (int'(scan_slot) < VNU_SLOT_COUNT);
  assign cnu_a_en0 = init_cnu_a_active ? lane_edge0_present : (vnu_v2c_valid0 && emit_edge0_valid);
  assign cnu_a_en1 = init_cnu_a_active ? lane_edge1_present : (vnu_v2c_valid1 && emit_edge1_valid);
  assign cnu_a_v2c0 = init_cnu_a_active ? u_init_msg0 : vnu_v2c0;
  assign cnu_a_v2c1 = init_cnu_a_active ? u_init_msg1 : vnu_v2c1;

  assign vnu_col_start = cnu_b_active && (scan_slot == '0);
  assign vnu_col_end = ((state == DEC_PIPE_PREP) || (state == DEC_PIPE)) && slot_last;
  assign vnu_accum_valid0 = lane_edge0_valid;
  assign vnu_accum_valid1 = lane_edge1_valid;
  assign vnu_emit_en = emit_active;

  assign c1_wr_en = emit_active && (scan_slot == '0);
  assign m_clear_all_en = (state == DEC_LOAD);
  assign m_clear_bank_en = (state == DEC_CHECK) && continue_decode;
  assign m_wr_en0 = cnu_a_out_valid0;
  assign m_wr_en1 = cnu_a_out_valid1;
  assign s_clear_en = (state == DEC_LOAD);
  assign s_wr_en0 = cnu_a_out_valid0;
  assign s_wr_en1 = cnu_a_out_valid1;
  assign t_clear_en = (state == DEC_LOAD);
  assign t_wr_en0 = lane_edge0_valid;
  assign t_wr_en1 = lane_edge1_valid;
  assign u_init_en = (state == DEC_LOAD);
  assign u_wr_en0 = vnu_v2c_valid0;
  assign u_wr_en1 = vnu_v2c_valid1;
  assign i_load_first_col_en =
    (state == DEC_LOAD) || (state == DEC_INIT_CNU_A_FLUSH) ||
    ((state == DEC_CHECK) && continue_decode);
  assign i_shift_en =
    ((state == DEC_INIT_CNU_A) || (state == DEC_PIPE_PREP) || (state == DEC_PIPE)) &&
    slot_last && (active_var_idx != LAST_VAR);

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

  function automatic logic [LANE_IDX_W-1:0] edge_lane(
    input logic [LANE_EDGE_W-1:0] edge_desc
  );
    logic [ROW_W-1:0] row_global;
    begin
      row_global = edge_desc[LANE_EDGE_ROW_GLOBAL_LSB +: ROW_W];
      if (row_global < ROW_W'(ROW_SEG_SIZE)) begin
        edge_lane = LANE_IDX_W'(0);
      end else begin
        edge_lane = LANE_IDX_W'(1);
      end
    end
  endfunction

  always_comb begin
    integer slot_limit_local;
    integer current_limit_local;
    integer var_idx_local;
    integer bank_idx_local;
    integer col_idx_local;
    integer edge_idx_local;
    integer row_idx_local;

    current_limit_local = int'(current_scan_limit);
    slot_limit_local = 1;
    case (state)
      DEC_INIT_CNU_A, DEC_PIPE_PREP: begin
        slot_limit_local = current_limit_local;
      end
      DEC_PIPE: begin
        slot_limit_local = current_limit_local;
        if (slot_limit_local < VNU_SLOT_COUNT) begin
          slot_limit_local = VNU_SLOT_COUNT;
        end
      end
      DEC_PIPE_DRAIN: begin
        slot_limit_local = VNU_SLOT_COUNT;
      end
      default: begin
        slot_limit_local = 1;
      end
    endcase
    if (slot_limit_local <= 0) begin
      slot_limit_local = 1;
    end
    slot_last = ((int'(scan_slot) + 1) >= slot_limit_local);

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

    stop_decode = 1'b0;
    continue_decode = 1'b0;
    if (state == DEC_CHECK) begin
      stop_decode = (syndrome_next == '0) || (int'(next_iter_count) >= I_MAX);
      continue_decode = !stop_decode;
    end
  end

  assign c2v_msg_tc0 = signmag_to_tc_msg(c2v_msg0);
  assign c2v_msg_tc1 = signmag_to_tc_msg(c2v_msg1);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      cnu_a_wr_row0 <= '0;
      cnu_a_wr_row1 <= '0;
      cnu_a_wr_edge0 <= '0;
      cnu_a_wr_edge1 <= '0;
      cnu_a_wr_var0 <= '0;
      cnu_a_wr_var1 <= '0;
      cnu_a_wr_lane0 <= '0;
      cnu_a_wr_lane1 <= '0;
      cnu_a_wr_bank0 <= 1'b0;
      cnu_a_wr_bank1 <= 1'b0;
    end else if (state == DEC_LOAD) begin
      cnu_a_wr_row0 <= '0;
      cnu_a_wr_row1 <= '0;
      cnu_a_wr_edge0 <= '0;
      cnu_a_wr_edge1 <= '0;
      cnu_a_wr_var0 <= '0;
      cnu_a_wr_var1 <= '0;
      cnu_a_wr_lane0 <= '0;
      cnu_a_wr_lane1 <= '0;
      cnu_a_wr_bank0 <= 1'b0;
      cnu_a_wr_bank1 <= 1'b0;
    end else begin
      if (cnu_a_en0) begin
        cnu_a_wr_row0 <= init_cnu_a_active ? lane_edge0_row_local : emit_edge0_row_local;
        cnu_a_wr_edge0 <= init_cnu_a_active ? lane_edge0_edge_slot : emit_edge0_slot;
        cnu_a_wr_var0 <= init_cnu_a_active ? active_var_idx : emit_var_idx;
        cnu_a_wr_lane0 <= init_cnu_a_active ? LANE_IDX_W'(0) : emit_edge0_lane;
        cnu_a_wr_bank0 <= init_cnu_a_active ? m_read_bank : m_write_bank;
      end
      if (cnu_a_en1) begin
        cnu_a_wr_row1 <= init_cnu_a_active ? lane_edge1_row_local : emit_edge1_row_local;
        cnu_a_wr_edge1 <= init_cnu_a_active ? lane_edge1_edge_slot : emit_edge1_slot;
        cnu_a_wr_var1 <= init_cnu_a_active ? active_var_idx : emit_var_idx;
        cnu_a_wr_lane1 <= init_cnu_a_active ? LANE_IDX_W'(1) : emit_edge1_lane;
        cnu_a_wr_bank1 <= init_cnu_a_active ? m_read_bank : m_write_bank;
      end
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
    .i_load(state == DEC_LOAD),
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
    .i_load(state == DEC_LOAD),
    .i_load_bits(i_x),
    .i_we(c1_wr_en),
    .i_w_addr(emit_var_idx),
    .i_din(vnu_x_out),
    .i_r_addr(emit_var_idx),
    .o_dout(c1_rd_unused),
    .o_bits(c1_bits)
  );

  ram_m u_m_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear_all(m_clear_all_en),
    .i_clear_bank(m_clear_bank_en),
    .i_clear_bank_sel(m_read_bank),
    .i_r_bank_a(init_cnu_a_active ? m_read_bank : m_write_bank),
    .i_r_lane_a0(init_cnu_a_active ? LANE_IDX_W'(0) : emit_edge0_lane),
    .i_r_addr_a0(init_cnu_a_active ? lane_edge0_row_local : emit_edge0_row_local),
    .i_r_lane_a1(init_cnu_a_active ? LANE_IDX_W'(1) : emit_edge1_lane),
    .i_r_addr_a1(init_cnu_a_active ? lane_edge1_row_local : emit_edge1_row_local),
    .i_r_bank_b(m_read_bank),
    .i_r_lane_b0(LANE_IDX_W'(0)),
    .i_r_addr_b0(lane_edge0_row_local),
    .i_r_lane_b1(LANE_IDX_W'(1)),
    .i_r_addr_b1(lane_edge1_row_local),
    .o_dout_a0(c2v_compact_msg_rd_a0),
    .o_dout_a1(c2v_compact_msg_rd_a1),
    .o_dout_b0(c2v_compact_msg_rd_b0),
    .o_dout_b1(c2v_compact_msg_rd_b1),
    .i_we0(m_wr_en0),
    .i_w_bank0(cnu_a_wr_bank0),
    .i_w_lane0(cnu_a_wr_lane0),
    .i_w_addr0(cnu_a_wr_row0),
    .i_din0(c2v_compact_msg_wr0),
    .i_we1(m_wr_en1),
    .i_w_bank1(cnu_a_wr_bank1),
    .i_w_lane1(cnu_a_wr_lane1),
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
    .i_re0(emit_edge0_valid),
    .i_r_var0(emit_var_idx),
    .i_r_edge0(emit_edge0_slot),
    .o_dout0(t_rd_msg0),
    .i_re1(emit_edge1_valid),
    .i_r_var1(emit_var_idx),
    .i_r_edge1(emit_edge1_slot),
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
    .i_re0(init_cnu_a_active && lane_edge0_present),
    .i_r_var0(active_var_idx),
    .i_r_edge0(lane_edge0_edge_slot),
    .o_dout0(u_init_msg0),
    .i_re1(init_cnu_a_active && lane_edge1_present),
    .i_r_var1(active_var_idx),
    .i_r_edge1(lane_edge1_edge_slot),
    .o_dout1(u_init_msg1),
    .i_we0(u_wr_en0),
    .i_w_var0(emit_var_idx),
    .i_w_edge0(emit_edge0_slot),
    .i_din0(vnu_v2c0),
    .i_we1(u_wr_en1),
    .i_w_var1(emit_var_idx),
    .i_w_edge1(emit_edge1_slot),
    .i_din1(vnu_v2c1)
  );

  cnu_a u_cnu_a_lane0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(state == DEC_LOAD),
    .i_en(cnu_a_en0),
    .i_v2c(cnu_a_v2c0),
    .i_idx(init_cnu_a_active ? active_var_idx : emit_var_idx),
    .i_comp_c2v(c2v_compact_msg_rd_a0),
    .o_comp_c2v(c2v_compact_msg_wr0),
    .o_sign(v2c_sign_wr0),
    .o_valid(cnu_a_out_valid0)
  );

  cnu_a u_cnu_a_lane1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(state == DEC_LOAD),
    .i_en(cnu_a_en1),
    .i_v2c(cnu_a_v2c1),
    .i_idx(init_cnu_a_active ? active_var_idx : emit_var_idx),
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
    .i_clear(state == DEC_LOAD),
    .i_col_start(vnu_col_start),
    .i_col_end(vnu_col_end),
    .i_initial_llr(prior_msg),
    .i_c2v_valid0(vnu_accum_valid0),
    .i_c2v_sign0(c2v_msg0[MSG_SIGN_BIT]),
    .i_c2v_mag0(c2v_msg0[MSG_MAG_LSB +: D]),
    .i_c2v_valid1(vnu_accum_valid1),
    .i_c2v_sign1(c2v_msg1[MSG_SIGN_BIT]),
    .i_c2v_mag1(c2v_msg1[MSG_MAG_LSB +: D]),
    .o_app_valid(),
    .o_app(),
    .o_bit_decision(vnu_x_out),
    .i_emit_en(vnu_emit_en),
    .i_c2v_t_valid0(emit_edge0_valid),
    .i_c2v_t0(t_rd_msg0),
    .i_c2v_t_valid1(emit_edge1_valid),
    .i_c2v_t1(t_rd_msg1),
    .o_v2c_valid0(vnu_v2c_valid0),
    .o_v2c0(vnu_v2c0),
    .o_v2c_valid1(vnu_v2c_valid1),
    .o_v2c1(vnu_v2c1)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer row_idx_local;
    integer edge_idx_local;

    if (!i_rst_n) begin
      state <= DEC_IDLE;
      o_done <= 1'b0;
      o_success <= 1'b0;
      o_x <= '0;
      o_iter_count <= '0;
      active_var_idx <= '0;
      emit_var_idx <= '0;
      scan_slot <= '0;
      m_read_bank <= 1'b0;
      m_write_bank <= 1'b1;
      fill_edge_buf_sel <= 1'b0;
      emit_edge_buf_sel <= 1'b0;
      pipeline_overlap_seen <= 1'b0;
      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        edge_buf[0][edge_idx_local] <= '0;
        edge_buf[1][edge_idx_local] <= '0;
      end
      for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
        syndrome_hist[row_idx_local] <= '0;
      end
    end else begin
      if (((state == DEC_PIPE_PREP) || (state == DEC_PIPE)) && (scan_slot == '0)) begin
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          edge_buf[fill_edge_buf_sel][edge_idx_local] <= '0;
        end
      end
      if (lane_edge0_valid) begin
        edge_buf[fill_edge_buf_sel][lane_edge0_edge_slot] <= lane_edge0;
      end
      if (lane_edge1_valid) begin
        edge_buf[fill_edge_buf_sel][lane_edge1_edge_slot] <= lane_edge1;
      end
      if ((state == DEC_PIPE) && cnu_b_active && emit_active) begin
        pipeline_overlap_seen <= 1'b1;
      end

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
          emit_var_idx <= '0;
          scan_slot <= '0;
          m_read_bank <= 1'b0;
          m_write_bank <= 1'b1;
          fill_edge_buf_sel <= 1'b0;
          emit_edge_buf_sel <= 1'b0;
          pipeline_overlap_seen <= 1'b0;
          for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
            edge_buf[0][edge_idx_local] <= '0;
            edge_buf[1][edge_idx_local] <= '0;
          end
          for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
            syndrome_hist[row_idx_local] <= '0;
          end
          state <= DEC_INIT_CNU_A;
        end

        DEC_INIT_CNU_A: begin
          if (slot_last) begin
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_INIT_CNU_A_FLUSH;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_INIT_CNU_A_FLUSH: begin
          active_var_idx <= '0;
          emit_var_idx <= '0;
          scan_slot <= '0;
          fill_edge_buf_sel <= 1'b0;
          emit_edge_buf_sel <= 1'b0;
          state <= DEC_PIPE_PREP;
        end

        DEC_PIPE_PREP: begin
          if (slot_last) begin
            scan_slot <= '0;
            emit_var_idx <= active_var_idx;
            emit_edge_buf_sel <= fill_edge_buf_sel;
            fill_edge_buf_sel <= ~fill_edge_buf_sel;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_PIPE_DRAIN;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
              state <= DEC_PIPE;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_PIPE: begin
          if (slot_last) begin
            scan_slot <= '0;
            emit_var_idx <= active_var_idx;
            emit_edge_buf_sel <= fill_edge_buf_sel;
            fill_edge_buf_sel <= ~fill_edge_buf_sel;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_PIPE_DRAIN;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_PIPE_DRAIN: begin
          if (scan_slot == '0) begin
            o_x[emit_var_idx] <= vnu_x_out;
          end
          if (slot_last) begin
            scan_slot <= '0;
            state <= DEC_PIPE_FLUSH;
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_PIPE_FLUSH: begin
          state <= DEC_CHECK;
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
            emit_var_idx <= '0;
            scan_slot <= '0;
            m_read_bank <= m_write_bank;
            m_write_bank <= m_read_bank;
            fill_edge_buf_sel <= 1'b0;
            emit_edge_buf_sel <= 1'b0;
            state <= DEC_PIPE_PREP;
          end
        end

        DEC_DONE: begin
          o_done <= 1'b1;
          o_x <= c1_bits;
        end

        default: begin
          state <= DEC_IDLE;
        end
      endcase
    end
  end
endmodule
