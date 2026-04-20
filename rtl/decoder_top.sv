// Top-level BIKE min-sum decoder datapath and module interconnect.
module decoder_top
  import bike_pkg::*;
(
  input  logic i_clk,                           // Core decoder clock.
  input  logic i_rst_n,                         // Active-low reset.
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
  localparam int VNU_SLOT_COUNT = (W + L - 1) / L;

  logic [DEC_STATE_W-1:0] state;
  logic done_ctrl;
  logic success_ctrl;
  logic [ITER_W-1:0] iter_count_ctrl;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [R-1:0] syndrome_hist [0:I_MAX-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic [VAR_W-1:0] c2v_var_idx;
  logic [VAR_W-1:0] v2c_var_idx;
  logic [EDGE_W-1:0] col_slot_idx;
  logic row_state_read_bank;
  logic row_state_write_bank;
  logic c2v_edge_list_buf_sel;
  logic v2c_edge_list_buf_sel;
  /* verilator lint_off UNUSEDSIGNAL */
  logic c2v_v2c_overlap_seen;
  /* verilator lint_on UNUSEDSIGNAL */

  logic start_seed_pending;
  logic start_seed_active;
  logic ctrl_start;
  logic [BANK_W-1:0] start_seed_bank;
  logic [BANK_W-1:0] current_col_bank;
  logic col_state_shift_en;
  logic col_state_wr_en;
  logic [BANK_W-1:0] col_state_wr_bank;
  logic [I_ENTRY_W-1:0] current_col_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] current_col_lane_count [0:L-1];
  logic [I_ENTRY_W-1:0] shifted_col_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] shifted_col_lane_count [0:L-1];
  logic [I_ENTRY_W-1:0] col_state_wr_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] col_state_wr_lane_count [0:L-1];

  logic [LANE_COUNT_W-1:0] c2v_slot_limit;
  logic lane_edge0_present;
  logic lane_edge1_present;
  logic lane_edge0_valid;
  logic lane_edge1_valid;
  logic [ROW_W-1:0] lane_edge0_row_local;
  logic [ROW_W-1:0] lane_edge1_row_local;
  logic [ROW_W-1:0] lane_edge0_row_global;
  logic [ROW_W-1:0] lane_edge1_row_global;
  logic [EDGE_W-1:0] lane_edge0_edge_slot;
  logic [EDGE_W-1:0] lane_edge1_edge_slot;

  logic edge_list_buf_valid [0:1][0:W-1];
  logic [ROW_W-1:0] edge_list_buf_row_local [0:1][0:W-1];
  logic [ROW_W-1:0] edge_list_buf_row_global [0:1][0:W-1];

  logic [EDGE_W-1:0] emit_edge0_slot;
  logic [EDGE_W-1:0] emit_edge1_slot;
  logic emit_edge0_valid;
  logic emit_edge1_valid;
  logic [LANE_IDX_W-1:0] emit_edge0_lane;
  logic [LANE_IDX_W-1:0] emit_edge1_lane;
  logic [ROW_W-1:0] emit_edge0_row_local;
  logic [ROW_W-1:0] emit_edge1_row_local;
  logic [ROW_W-1:0] emit_edge0_row_global;
  logic [ROW_W-1:0] emit_edge1_row_global;

  logic [N-1:0] error_estimate_bits;
  logic error_estimate_rd_unused;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a1;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b1;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr1;
  logic [MSG_W-1:0] u_init_msg0;
  logic [MSG_W-1:0] u_init_msg1;
  logic [MSG_W-1:0] cnu_a_v2c_msg0;
  logic [MSG_W-1:0] cnu_a_v2c_msg1;
  logic v2c_sign0;
  logic v2c_sign1;
  logic v2c_sign_wr0;
  logic v2c_sign_wr1;
  logic cnu_a_out_valid0;
  logic cnu_a_out_valid1;
  logic [MSG_W-1:0] c2v_msg0;
  logic [MSG_W-1:0] c2v_msg1;
  logic c2v_tc_valid0;
  logic c2v_tc_valid1;
  logic signed [MSG_W-1:0] c2v_tc0;
  logic signed [MSG_W-1:0] c2v_tc1;
  logic signed [MSG_W-1:0] t_rd_c2v_tc0;
  logic signed [MSG_W-1:0] t_rd_c2v_tc1;
  logic signed [APP_W-1:0] prior_msg;
  /* verilator lint_off UNUSEDSIGNAL */
  logic vnu_app_valid_unused;
  logic signed [APP_W-1:0] vnu_app_unused;
  /* verilator lint_on UNUSEDSIGNAL */
  logic vnu_bit_out;
  logic vnu_col_start;
  logic vnu_col_end;
  logic vnu_accum_valid0;
  logic vnu_accum_valid1;
  logic vnu_emit_en;
  logic vnu_v2c_tc_valid0;
  logic vnu_v2c_tc_valid1;
  logic signed [VNU_TC_W-1:0] vnu_v2c_tc0;
  logic signed [VNU_TC_W-1:0] vnu_v2c_tc1;
  logic vnu_v2c_msg_valid0;
  logic vnu_v2c_msg_valid1;
  logic [MSG_W-1:0] vnu_v2c_msg0;
  logic [MSG_W-1:0] vnu_v2c_msg1;

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

  logic init_row_accum_active;
  logic c2v_phase_active;
  logic v2c_phase_active;
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
  logic slot_last;
  logic [ITER_W-1:0] next_iter_count;
  logic finish_decode;
  logic continue_iterations;
  logic [R-1:0] residual_syndrome_next;
  assign o_done = done_ctrl;
  assign o_success = success_ctrl;
  assign o_iter_count = iter_count_ctrl;
  assign current_col_bank = BANK_W'(int'(c2v_var_idx) / R);

  assign c2v_slot_limit =
    (current_col_lane_count[0] >= current_col_lane_count[1]) ?
    current_col_lane_count[0] : current_col_lane_count[1];
  assign lane_edge0_present =
    (int'(col_slot_idx) < int'(current_col_lane_count[0]));
  assign lane_edge1_present =
    (int'(col_slot_idx) < int'(current_col_lane_count[1]));
  assign lane_edge0_valid = c2v_phase_active && lane_edge0_present;
  assign lane_edge1_valid = c2v_phase_active && lane_edge1_present;
  assign lane_edge0_row_local =
    current_col_lane_entries[0][col_slot_idx][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
  assign lane_edge1_row_local =
    current_col_lane_entries[1][col_slot_idx][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
  assign lane_edge0_row_global = lane_edge0_row_local;
  assign lane_edge1_row_global = ROW_W'(ROW_SEG_SIZE) + lane_edge1_row_local;
  assign lane_edge0_edge_slot =
    current_col_lane_entries[0][col_slot_idx][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];
  assign lane_edge1_edge_slot =
    current_col_lane_entries[1][col_slot_idx][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];

  assign emit_edge0_slot = EDGE_W'(int'(col_slot_idx) * L);
  assign emit_edge1_slot = EDGE_W'((int'(col_slot_idx) * L) + 1);
  assign emit_edge0_valid =
    v2c_phase_active && ((int'(col_slot_idx) * L) < W) &&
    edge_list_buf_valid[v2c_edge_list_buf_sel][emit_edge0_slot];
  assign emit_edge1_valid =
    v2c_phase_active && (((int'(col_slot_idx) * L) + 1) < W) &&
    edge_list_buf_valid[v2c_edge_list_buf_sel][emit_edge1_slot];
  assign emit_edge0_row_local = edge_list_buf_row_local[v2c_edge_list_buf_sel][emit_edge0_slot];
  assign emit_edge1_row_local = edge_list_buf_row_local[v2c_edge_list_buf_sel][emit_edge1_slot];
  assign emit_edge0_row_global = edge_list_buf_row_global[v2c_edge_list_buf_sel][emit_edge0_slot];
  assign emit_edge1_row_global = edge_list_buf_row_global[v2c_edge_list_buf_sel][emit_edge1_slot];

  assign prior_msg = $signed(APP_W'(C_VAL));
  assign next_iter_count = iter_count_ctrl + 1'b1;
  assign init_row_accum_active = (state == DEC_INIT_ROW_ACCUM) && (int'(col_slot_idx) < int'(c2v_slot_limit));
  assign c2v_phase_active =
    ((state == DEC_ITER_C2V_PRIME) || (state == DEC_ITER_OVERLAP)) && (int'(col_slot_idx) < int'(c2v_slot_limit));
  assign v2c_phase_active =
    ((state == DEC_ITER_OVERLAP) || (state == DEC_ITER_V2C_DRAIN)) && (int'(col_slot_idx) < VNU_SLOT_COUNT);
  assign cnu_a_en0 = init_row_accum_active ? lane_edge0_present : (vnu_v2c_msg_valid0 && emit_edge0_valid);
  assign cnu_a_en1 = init_row_accum_active ? lane_edge1_present : (vnu_v2c_msg_valid1 && emit_edge1_valid);
  assign cnu_a_v2c_msg0 = init_row_accum_active ? u_init_msg0 : vnu_v2c_msg0;
  assign cnu_a_v2c_msg1 = init_row_accum_active ? u_init_msg1 : vnu_v2c_msg1;

  assign vnu_col_start = c2v_phase_active && (col_slot_idx == '0);
  assign vnu_col_end = ((state == DEC_ITER_C2V_PRIME) || (state == DEC_ITER_OVERLAP)) && slot_last;
  assign vnu_accum_valid0 = c2v_tc_valid0;
  assign vnu_accum_valid1 = c2v_tc_valid1;
  assign vnu_emit_en = v2c_phase_active;

  assign c1_wr_en = v2c_phase_active && (col_slot_idx == '0);
  assign m_clear_all_en = (state == DEC_INIT_DECODER);
  assign m_clear_bank_en = (state == DEC_ITER_CHECK) && continue_iterations;
  assign m_wr_en0 = cnu_a_out_valid0;
  assign m_wr_en1 = cnu_a_out_valid1;
  assign s_clear_en = (state == DEC_INIT_DECODER);
  assign s_wr_en0 = cnu_a_out_valid0;
  assign s_wr_en1 = cnu_a_out_valid1;
  assign t_clear_en = (state == DEC_INIT_DECODER);
  assign t_wr_en0 = lane_edge0_valid;
  assign t_wr_en1 = lane_edge1_valid;
  assign u_init_en = (state == DEC_INIT_DECODER);
  assign u_wr_en0 = vnu_v2c_msg_valid0;
  assign u_wr_en1 = vnu_v2c_msg_valid1;
  assign col_state_shift_en =
    ((state == DEC_INIT_ROW_ACCUM) || (state == DEC_ITER_C2V_PRIME) || (state == DEC_ITER_OVERLAP))
    && slot_last;
  assign col_state_wr_en = start_seed_active || col_state_shift_en;
  assign col_state_wr_bank = start_seed_active ? start_seed_bank : current_col_bank;

  function automatic logic [LANE_IDX_W-1:0] edge_lane(
    input logic [ROW_W-1:0] row_global
  );
    begin
      if (row_global < ROW_W'(ROW_SEG_SIZE)) begin
        edge_lane = LANE_IDX_W'(0);
      end else begin
        edge_lane = LANE_IDX_W'(1);
      end
    end
  endfunction

  assign emit_edge0_lane = edge_lane(emit_edge0_row_global);
  assign emit_edge1_lane = edge_lane(emit_edge1_row_global);

  always_comb begin
    integer lane_idx_local;
    integer slot_idx_local;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      col_state_wr_lane_count[lane_idx_local] =
        start_seed_active ?
        QC_FIRST_COL_LANE_COUNT[start_seed_bank][lane_idx_local] :
        shifted_col_lane_count[lane_idx_local];
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        col_state_wr_lane_entries[lane_idx_local][slot_idx_local] =
          start_seed_active ?
          QC_FIRST_COL_LANE_ENTRY[start_seed_bank][lane_idx_local][slot_idx_local] :
          shifted_col_lane_entries[lane_idx_local][slot_idx_local];
      end
    end
  end

  always_comb begin
    integer slot_limit_local;
    integer current_limit_local;
    integer var_idx_local;
    logic [BANK_W-1:0] bank_idx_local;
    integer col_idx_local;
    integer edge_idx_local;
    logic [ROW_W-1:0] row_idx_local;

    current_limit_local = int'(c2v_slot_limit);
    slot_limit_local = 1;
    case (state)
      DEC_INIT_ROW_ACCUM, DEC_ITER_C2V_PRIME: begin
        slot_limit_local = current_limit_local;
      end
      DEC_ITER_OVERLAP: begin
        slot_limit_local = current_limit_local;
        if (slot_limit_local < VNU_SLOT_COUNT) begin
          slot_limit_local = VNU_SLOT_COUNT;
        end
      end
      DEC_ITER_V2C_DRAIN: begin
        slot_limit_local = VNU_SLOT_COUNT;
      end
      default: begin
        slot_limit_local = 1;
      end
    endcase
    if (slot_limit_local <= 0) begin
      slot_limit_local = 1;
    end
    slot_last = ((int'(col_slot_idx) + 1) >= slot_limit_local);

    residual_syndrome_next = i_syndrome;
    bank_idx_local = '0;
    col_idx_local = 0;
    row_idx_local = '0;
    for (var_idx_local = 0; var_idx_local < N; var_idx_local++) begin
      if (error_estimate_bits[var_idx_local]) begin
        bank_idx_local = BANK_W'(var_idx_local / R);
        col_idx_local = var_idx_local % R;
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          row_idx_local = ROW_W'((H_BASE[0][bank_idx_local][edge_idx_local] + col_idx_local) % R);
          residual_syndrome_next[row_idx_local] ^= 1'b1;
        end
      end
    end

    finish_decode = 1'b0;
    continue_iterations = 1'b0;
    if (state == DEC_ITER_CHECK) begin
      finish_decode = (residual_syndrome_next == '0) || (int'(next_iter_count) >= I_MAX);
      continue_iterations = !finish_decode;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      start_seed_pending <= 1'b0;
      start_seed_active <= 1'b0;
      start_seed_bank <= '0;
      ctrl_start <= 1'b0;
    end else begin
      ctrl_start <= 1'b0;

      if ((state == DEC_WAIT_START) && i_start && !start_seed_pending && !start_seed_active) begin
        start_seed_pending <= 1'b1;
        start_seed_active <= 1'b1;
        start_seed_bank <= '0;
      end

      if (start_seed_active) begin
        if (start_seed_bank == BANK_W'(N0 - 1)) begin
          start_seed_pending <= 1'b0;
          start_seed_active <= 1'b0;
          ctrl_start <= 1'b1;
        end else begin
          start_seed_bank <= start_seed_bank + 1'b1;
        end
      end
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer row_idx_local;
    integer edge_idx_local;
    integer buf_idx_local;

    if (!i_rst_n) begin
      o_e <= '0;
      c2v_v2c_overlap_seen <= 1'b0;
      for (buf_idx_local = 0; buf_idx_local < 2; buf_idx_local++) begin
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          edge_list_buf_valid[buf_idx_local][edge_idx_local] <= 1'b0;
          edge_list_buf_row_local[buf_idx_local][edge_idx_local] <= '0;
          edge_list_buf_row_global[buf_idx_local][edge_idx_local] <= '0;
        end
      end
      for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
        syndrome_hist[row_idx_local] <= '0;
      end
    end else begin
      if (((state == DEC_ITER_C2V_PRIME) || (state == DEC_ITER_OVERLAP)) && (col_slot_idx == '0)) begin
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          edge_list_buf_valid[c2v_edge_list_buf_sel][edge_idx_local] <= 1'b0;
          edge_list_buf_row_local[c2v_edge_list_buf_sel][edge_idx_local] <= '0;
          edge_list_buf_row_global[c2v_edge_list_buf_sel][edge_idx_local] <= '0;
        end
      end
      if (lane_edge0_valid) begin
        edge_list_buf_valid[c2v_edge_list_buf_sel][lane_edge0_edge_slot] <= 1'b1;
        edge_list_buf_row_local[c2v_edge_list_buf_sel][lane_edge0_edge_slot] <= lane_edge0_row_local;
        edge_list_buf_row_global[c2v_edge_list_buf_sel][lane_edge0_edge_slot] <= lane_edge0_row_global;
      end
      if (lane_edge1_valid) begin
        edge_list_buf_valid[c2v_edge_list_buf_sel][lane_edge1_edge_slot] <= 1'b1;
        edge_list_buf_row_local[c2v_edge_list_buf_sel][lane_edge1_edge_slot] <= lane_edge1_row_local;
        edge_list_buf_row_global[c2v_edge_list_buf_sel][lane_edge1_edge_slot] <= lane_edge1_row_global;
      end
      if ((state == DEC_ITER_OVERLAP) && c2v_phase_active && v2c_phase_active) begin
        c2v_v2c_overlap_seen <= 1'b1;
      end

      case (state)
        DEC_INIT_DECODER: begin
          o_e <= '0;
          c2v_v2c_overlap_seen <= 1'b0;
          for (buf_idx_local = 0; buf_idx_local < 2; buf_idx_local++) begin
            for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
              edge_list_buf_valid[buf_idx_local][edge_idx_local] <= 1'b0;
              edge_list_buf_row_local[buf_idx_local][edge_idx_local] <= '0;
              edge_list_buf_row_global[buf_idx_local][edge_idx_local] <= '0;
            end
          end
          for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
            syndrome_hist[row_idx_local] <= '0;
          end
        end

        DEC_ITER_V2C_DRAIN: begin
          if (col_slot_idx == '0) begin
            o_e[v2c_var_idx] <= vnu_bit_out;
          end
        end

        DEC_ITER_CHECK: begin
          syndrome_hist[iter_count_ctrl[HIST_IDX_W-1:0]] <= residual_syndrome_next;
          if (finish_decode) begin
            o_e <= error_estimate_bits;
          end
        end

        DEC_DONE: begin
          o_e <= error_estimate_bits;
        end

        default: begin
        end
      endcase
    end
  end

  decoder_ctrl u_decoder_ctrl (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(ctrl_start),
    .i_slot_last(slot_last),
    .i_finish_decode(finish_decode),
    .i_decode_success(residual_syndrome_next == '0),
    .o_state(state),
    .o_c2v_var_idx(c2v_var_idx),
    .o_v2c_var_idx(v2c_var_idx),
    .o_col_slot_idx(col_slot_idx),
    .o_row_state_read_bank(row_state_read_bank),
    .o_row_state_write_bank(row_state_write_bank),
    .o_c2v_edge_list_buf_sel(c2v_edge_list_buf_sel),
    .o_v2c_edge_list_buf_sel(v2c_edge_list_buf_sel),
    .o_done(done_ctrl),
    .o_success(success_ctrl),
    .o_iter_count(iter_count_ctrl)
  );

  ram_i u_i_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_rd_bank(current_col_bank),
    .o_rd_lane_entries(current_col_lane_entries),
    .o_rd_lane_count(current_col_lane_count),
    .i_we(col_state_wr_en),
    .i_wr_bank(col_state_wr_bank),
    .i_wr_lane_entries(col_state_wr_lane_entries),
    .i_wr_lane_count(col_state_wr_lane_count)
  );

  h_shift u_h_shift (
    .i_lane_entries(current_col_lane_entries),
    .i_lane_count(current_col_lane_count),
    .o_lane_entries(shifted_col_lane_entries),
    .o_lane_count(shifted_col_lane_count)
  );

  ram_c u_error_estimate_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(state == DEC_INIT_DECODER),
    .i_load_bits('0),
    .i_we(c1_wr_en),
    .i_w_addr(v2c_var_idx),
    .i_din(vnu_bit_out),
    .i_r_addr(v2c_var_idx),
    .o_dout(error_estimate_rd_unused),
    .o_bits(error_estimate_bits)
  );

  ram_m u_m_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear_all(m_clear_all_en),
    .i_clear_bank(m_clear_bank_en),
    .i_clear_bank_sel(row_state_read_bank),
    .i_r_bank_a(init_row_accum_active ? row_state_read_bank : row_state_write_bank),
    .i_r_lane_a0(init_row_accum_active ? LANE_IDX_W'(0) : emit_edge0_lane),
    .i_r_addr_a0(init_row_accum_active ? lane_edge0_row_local : emit_edge0_row_local),
    .i_r_lane_a1(init_row_accum_active ? LANE_IDX_W'(1) : emit_edge1_lane),
    .i_r_addr_a1(init_row_accum_active ? lane_edge1_row_local : emit_edge1_row_local),
    .i_r_bank_b(row_state_read_bank),
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
    .i_r_var0(c2v_var_idx),
    .i_r_edge0(lane_edge0_edge_slot),
    .i_r_var1(c2v_var_idx),
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
    .i_rd_en0(emit_edge0_valid),
    .i_rd_var_idx0(v2c_var_idx),
    .i_rd_edge_slot0(emit_edge0_slot),
    .o_rd_c2v_tc0(t_rd_c2v_tc0),
    .i_rd_en1(emit_edge1_valid),
    .i_rd_var_idx1(v2c_var_idx),
    .i_rd_edge_slot1(emit_edge1_slot),
    .o_rd_c2v_tc1(t_rd_c2v_tc1),
    .i_wr_en0(t_wr_en0),
    .i_wr_var_idx0(c2v_var_idx),
    .i_wr_edge_slot0(lane_edge0_edge_slot),
    .i_wr_c2v_tc0(c2v_tc0),
    .i_wr_en1(t_wr_en1),
    .i_wr_var_idx1(c2v_var_idx),
    .i_wr_edge_slot1(lane_edge1_edge_slot),
    .i_wr_c2v_tc1(c2v_tc1)
  );

  ram_u u_u_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_init(u_init_en),
    .i_rd_en0(init_row_accum_active && lane_edge0_present),
    .i_rd_var_idx0(c2v_var_idx),
    .i_rd_edge_slot0(lane_edge0_edge_slot),
    .o_rd_v2c_msg0(u_init_msg0),
    .i_rd_en1(init_row_accum_active && lane_edge1_present),
    .i_rd_var_idx1(c2v_var_idx),
    .i_rd_edge_slot1(lane_edge1_edge_slot),
    .o_rd_v2c_msg1(u_init_msg1),
    .i_wr_en0(u_wr_en0),
    .i_wr_var_idx0(v2c_var_idx),
    .i_wr_edge_slot0(emit_edge0_slot),
    .i_wr_v2c_msg0(vnu_v2c_msg0),
    .i_wr_en1(u_wr_en1),
    .i_wr_var_idx1(v2c_var_idx),
    .i_wr_edge_slot1(emit_edge1_slot),
    .i_wr_v2c_msg1(vnu_v2c_msg1)
  );

  cnu_a u_cnu_a_lane0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(state == DEC_INIT_DECODER),
    .i_en(cnu_a_en0),
    .i_v2c(cnu_a_v2c_msg0),
    .i_var_idx(init_row_accum_active ? c2v_var_idx : v2c_var_idx),
    .i_comp_c2v(c2v_compact_msg_rd_a0),
    .o_comp_c2v(c2v_compact_msg_wr0),
    .o_sign(v2c_sign_wr0),
    .o_valid(cnu_a_out_valid0)
  );

  cnu_a u_cnu_a_lane1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(state == DEC_INIT_DECODER),
    .i_en(cnu_a_en1),
    .i_v2c(cnu_a_v2c_msg1),
    .i_var_idx(init_row_accum_active ? c2v_var_idx : v2c_var_idx),
    .i_comp_c2v(c2v_compact_msg_rd_a1),
    .o_comp_c2v(c2v_compact_msg_wr1),
    .o_sign(v2c_sign_wr1),
    .o_valid(cnu_a_out_valid1)
  );

  cnu_b u_cnu_b_lane0 (
    .i_comp_c2v(c2v_compact_msg_rd_b0),
    .i_v2c_sign(v2c_sign0),
    .i_syndrome_bit(i_syndrome[lane_edge0_row_global]),
    .i_var_idx(c2v_var_idx),
    .o_c2v_msg(c2v_msg0)
  );

  cnu_b u_cnu_b_lane1 (
    .i_comp_c2v(c2v_compact_msg_rd_b1),
    .i_v2c_sign(v2c_sign1),
    .i_syndrome_bit(i_syndrome[lane_edge1_row_global]),
    .i_var_idx(c2v_var_idx),
    .o_c2v_msg(c2v_msg1)
  );

  msg_signmag_to_tc u_c2v_tc_codec0 (
    .i_valid(lane_edge0_valid),
    .i_sign(c2v_msg0[MSG_SIGN_BIT]),
    .i_mag(c2v_msg0[MSG_MAG_LSB +: D]),
    .o_valid(c2v_tc_valid0),
    .o_tc(c2v_tc0)
  );

  msg_signmag_to_tc u_c2v_tc_codec1 (
    .i_valid(lane_edge1_valid),
    .i_sign(c2v_msg1[MSG_SIGN_BIT]),
    .i_mag(c2v_msg1[MSG_MAG_LSB +: D]),
    .o_valid(c2v_tc_valid1),
    .o_tc(c2v_tc1)
  );

  vnu u_vnu (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(state == DEC_INIT_DECODER),
    .i_col_start(vnu_col_start),
    .i_col_end(vnu_col_end),
    .i_initial_llr(prior_msg),
    .i_c2v_tc_valid0(vnu_accum_valid0),
    .i_c2v_tc0(c2v_tc0),
    .i_c2v_tc_valid1(vnu_accum_valid1),
    .i_c2v_tc1(c2v_tc1),
    .o_app_valid(vnu_app_valid_unused),
    .o_app(vnu_app_unused),
    .o_bit_decision(vnu_bit_out),
    .i_emit_en(vnu_emit_en),
    .i_prev_c2v_tc_valid0(emit_edge0_valid),
    .i_prev_c2v_tc0(t_rd_c2v_tc0),
    .i_prev_c2v_tc_valid1(emit_edge1_valid),
    .i_prev_c2v_tc1(t_rd_c2v_tc1),
    .o_v2c_tc_valid0(vnu_v2c_tc_valid0),
    .o_v2c_tc0(vnu_v2c_tc0),
    .o_v2c_tc_valid1(vnu_v2c_tc_valid1),
    .o_v2c_tc1(vnu_v2c_tc1)
  );

  msg_tc_to_signmag_sat #(
    .TC_W(VNU_TC_W)
  ) u_vnu_v2c_msg_codec0 (
    .i_valid(vnu_v2c_tc_valid0),
    .i_tc(vnu_v2c_tc0),
    .o_valid(vnu_v2c_msg_valid0),
    .o_msg(vnu_v2c_msg0)
  );

  msg_tc_to_signmag_sat #(
    .TC_W(VNU_TC_W)
  ) u_vnu_v2c_msg_codec1 (
    .i_valid(vnu_v2c_tc_valid1),
    .i_tc(vnu_v2c_tc1),
    .o_valid(vnu_v2c_msg_valid1),
    .o_msg(vnu_v2c_msg1)
  );

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
    end else if (state == DEC_INIT_DECODER) begin
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
        cnu_a_wr_row0 <= init_row_accum_active ? lane_edge0_row_local : emit_edge0_row_local;
        cnu_a_wr_edge0 <= init_row_accum_active ? lane_edge0_edge_slot : emit_edge0_slot;
        cnu_a_wr_var0 <= init_row_accum_active ? c2v_var_idx : v2c_var_idx;
        cnu_a_wr_lane0 <= init_row_accum_active ? LANE_IDX_W'(0) : emit_edge0_lane;
        cnu_a_wr_bank0 <= init_row_accum_active ? row_state_read_bank : row_state_write_bank;
      end
      if (cnu_a_en1) begin
        cnu_a_wr_row1 <= init_row_accum_active ? lane_edge1_row_local : emit_edge1_row_local;
        cnu_a_wr_edge1 <= init_row_accum_active ? lane_edge1_edge_slot : emit_edge1_slot;
        cnu_a_wr_var1 <= init_row_accum_active ? c2v_var_idx : v2c_var_idx;
        cnu_a_wr_lane1 <= init_row_accum_active ? LANE_IDX_W'(1) : emit_edge1_lane;
        cnu_a_wr_bank1 <= init_row_accum_active ? row_state_read_bank : row_state_write_bank;
      end
    end
  end
endmodule
