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
  logic [EDGE_W-1:0] work_edge_slot;
  /* verilator lint_on UNUSEDSIGNAL */
  logic [VAR_W-1:0] work_var;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [VAR_W-1:0] c2v_var_idx;
  logic [VAR_W-1:0] v2c_var_idx;
  logic [EDGE_W-1:0] c2v_slot_idx;
  logic [EDGE_W-1:0] v2c_slot_idx;
  logic [EDGE_W-1:0] col_slot_idx;
  logic active_m_pair;
  logic next_m_pair;
  logic c2v_phase_active;
  logic v2c_phase_active;
  logic c2v_v2c_overlap_seen;
  logic capture_consumer_col_now;
  logic capture_consumer_col_next;
  logic promote_consumer_col_next;
  logic [N-1:0] error_estimate_bits;
  logic [N-1:0] error_estimate_c0_bits_unused;
  logic error_estimate_rd_unused;
  logic error_estimate_c1_dout_unused;
  logic signed [APP_W-1:0] vnu_app_unused;
  logic vnu_app_valid_unused;
  logic [R-1:0] syndrome_hist [0:I_MAX-1];
  logic [I_ENTRY_W-1:0] ram_i_debug_mem [0:N0-1][0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] ram_i_debug_count [0:N0-1][0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_rdata_unused [0:L-1];
  logic [LANE_COUNT_W-1:0] ram_i_lane_count [0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic comp_c2v_read_bank;
  logic comp_c2v_write_bank;
  logic seed_active;
  logic [BANK_W-1:0] seed_circ_idx;

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

  logic [BANK_W-1:0] c2v_circ_idx;
  logic [LANE_COUNT_W-1:0] c2v_column_lane_count [0:L-1];
  logic [I_ENTRY_W-1:0] c2v_column_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] v2c_column_lane_count [0:L-1];
  logic [I_ENTRY_W-1:0] v2c_column_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] v2c_next_column_lane_count [0:L-1];
  logic [I_ENTRY_W-1:0] v2c_next_column_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] shifted_lane_count [0:L-1];
  logic [I_ENTRY_W-1:0] shifted_lane_entries [0:L-1][0:W-1];
  logic c2v_column_slot_last;
  logic v2c_column_slot_last;
  logic shift_ram_i;

  logic c2v_lane_valid [0:L-1];
  logic [EDGE_W-1:0] c2v_lane_edge_slot [0:L-1];
  logic [ROW_W-1:0] c2v_lane_row_local [0:L-1];
  logic [ROW_W-1:0] c2v_lane_row_global [0:L-1];
  logic v2c_lane_valid [0:L-1];
  logic [EDGE_W-1:0] v2c_lane_edge_slot [0:L-1];
  logic [ROW_W-1:0] v2c_lane_row_local [0:L-1];

  logic c2v_latched_lane_valid [0:L-1];
  logic [EDGE_W-1:0] c2v_latched_edge_slot [0:L-1];
  logic [ROW_W-1:0] c2v_latched_row_local [0:L-1];
  logic [ROW_W-1:0] c2v_latched_row_global [0:L-1];
  logic [VAR_W-1:0] c2v_latched_var;
  logic c2v_latched_m_pair;

  logic v2c_t_latched_lane_valid [0:L-1];
  logic [EDGE_W-1:0] v2c_t_latched_edge_slot [0:L-1];
  logic v2c_m_latched_lane_valid [0:L-1];
  logic [EDGE_W-1:0] v2c_m_latched_edge_slot [0:L-1];
  logic [ROW_W-1:0] v2c_m_latched_row_local [0:L-1];
  logic [VAR_W-1:0] v2c_m_latched_var;
  logic v2c_m_latched_m_pair;
  logic signed [MSG_W-1:0] c2v_col_tc [0:W-1];
  logic [MSG_W-1:0] u_next_msg_reg [0:L-1];

  logic [R-1:0] residual_syndrome_next;
  logic decode_success;
  logic finish_decode;
  logic [ITER_W:0] next_iter_count_ext;
  logic [HIST_IDX_W-1:0] hist_wr_idx;

  logic [I_ENTRY_W-1:0] ram_i0_debug_entries [0:N0-1][0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_debug_entries [0:N0-1][0:W-1];
  logic [LANE_COUNT_W-1:0] ram_i0_debug_count [0:N0-1];
  logic [LANE_COUNT_W-1:0] ram_i1_debug_count [0:N0-1];
  logic [I_ENTRY_W-1:0] ram_i0_column_entries [0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_column_entries [0:W-1];
  logic [I_ENTRY_W-1:0] ram_i0_write_entries [0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_write_entries [0:W-1];
  logic [LANE_COUNT_W-1:0] ram_i0_write_lane_count;
  logic [LANE_COUNT_W-1:0] ram_i1_write_lane_count;
  logic [BANK_W-1:0] ram_i_write_circ_idx;
  logic ram_i_write_all;

  logic m_clear [0:3];
  logic m_en [0:3];
  logic m_we [0:3];
  logic [ROW_W-1:0] m_check_row_addr [0:3];
  logic [COMP_C2V_W-1:0] m_wdata [0:3];
  logic [COMP_C2V_W-1:0] m_rdata [0:3];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [COMP_C2V_W-1:0] ram_m0_debug_mem [0:R-1];
  logic [COMP_C2V_W-1:0] ram_m1_debug_mem [0:R-1];
  logic [COMP_C2V_W-1:0] ram_m2_debug_mem [0:R-1];
  logic [COMP_C2V_W-1:0] ram_m3_debug_mem [0:R-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic s_clear;
  logic s_en [0:L-1];
  logic s_we [0:L-1];
  logic [VAR_W-1:0] s_var_idx [0:L-1];
  logic [EDGE_W-1:0] s_edge_slot [0:L-1];
  logic s_wdata [0:L-1];
  logic s_rdata [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic ram_s0_debug_mem [0:N-1][0:W-1];
  logic ram_s1_debug_mem [0:N-1][0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic t_clear;
  logic t_en [0:L-1];
  logic t_we [0:L-1];
  logic [VAR_W-1:0] t_var_idx [0:L-1];
  logic [EDGE_W-1:0] t_edge_slot [0:L-1];
  logic [MSG_W-1:0] t_wdata [0:L-1];
  logic [MSG_W-1:0] t_rdata [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [MSG_W-1:0] ram_t0_debug_mem [0:N-1][0:W-1];
  logic [MSG_W-1:0] ram_t1_debug_mem [0:N-1][0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic u_init;
  logic u_en [0:L-1];
  logic u_we [0:L-1];
  logic [VAR_W-1:0] u_var_idx [0:L-1];
  logic [EDGE_W-1:0] u_edge_slot [0:L-1];
  logic [MSG_W-1:0] u_wdata [0:L-1];
  logic [MSG_W-1:0] u_rdata [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [MSG_W-1:0] ram_u0_debug_mem [0:N-1][0:W-1];
  logic [MSG_W-1:0] ram_u1_debug_mem [0:N-1][0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic c1_en;
  logic c1_we;
  logic [VAR_W-1:0] c1_var_idx;
  logic c1_wdata;

  logic [VAR_W-1:0] cnu_a_var_idx;
  logic cnu_a_en [0:L-1];
  logic [MSG_W-1:0] cnu_a_v2c_msg [0:L-1];
  logic [COMP_C2V_W-1:0] cnu_a_comp_in [0:L-1];
  logic [COMP_C2V_W-1:0] cnu_a_comp_out [0:L-1];
  logic cnu_a_sign [0:L-1];
  logic cnu_a_valid [0:L-1];

  logic [MSG_W-1:0] c2v_msg [0:L-1];
  logic signed [MSG_W-1:0] c2v_tc [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic c2v_tc_valid_unused [0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic vnu_col_start;
  logic vnu_col_end;
  logic vnu_accum_valid [0:L-1];
  logic vnu_emit_en;
  logic vnu_prev_c2v_valid [0:L-1];
  logic signed [MSG_W-1:0] vnu_prev_c2v [0:L-1];
  logic vnu_bit_out;
  logic vnu_v2c_tc_valid [0:L-1];
  logic signed [VNU_TC_W-1:0] vnu_v2c_tc [0:L-1];
  logic vnu_v2c_msg_valid [0:L-1];
  logic [MSG_W-1:0] vnu_v2c_msg [0:L-1];

  function automatic int m_index(input logic pair, input logic [LANE_IDX_W-1:0] lane);
    begin
      m_index = (pair ? 2 : 0) + int'(lane);
    end
  endfunction

  assign next_iter_count_ext = {1'b0, o_iter_count} + {{ITER_W{1'b0}}, 1'b1};
  assign hist_wr_idx = o_iter_count[HIST_IDX_W-1:0];
  assign decode_success = (residual_syndrome_next == '0);
  assign finish_decode = decode_success || (next_iter_count_ext >= (ITER_W + 1)'(I_MAX));
  assign c2v_circ_idx = BANK_W'(int'(c2v_var_idx) / R);
  assign o_e = error_estimate_bits;

  h_shift u_h_shift (
    .i_lane_entries(c2v_column_lane_entries),
    .i_lane_count(c2v_column_lane_count),
    .o_lane_entries(shifted_lane_entries),
    .o_lane_count(shifted_lane_count)
  );

  always_comb begin
    integer circ_idx;
    integer slot_idx;
    integer lane_idx;
    integer var_idx;
    integer edge_idx;
    integer c2v_max_count;
    integer v2c_max_count;
    logic [BANK_W-1:0] residual_bank;
    integer residual_col;
    logic [ROW_W-1:0] residual_row;

    for (circ_idx = 0; circ_idx < N0; circ_idx++) begin
      ram_i_debug_count[circ_idx][0] = ram_i0_debug_count[circ_idx];
      ram_i_debug_count[circ_idx][1] = ram_i1_debug_count[circ_idx];
      for (slot_idx = 0; slot_idx < W; slot_idx++) begin
        ram_i_debug_mem[circ_idx][0][slot_idx] = ram_i0_debug_entries[circ_idx][slot_idx];
        ram_i_debug_mem[circ_idx][1][slot_idx] = ram_i1_debug_entries[circ_idx][slot_idx];
      end
    end

    c2v_column_lane_count[0] = ram_i_lane_count[0];
    c2v_column_lane_count[1] = ram_i_lane_count[1];
    for (slot_idx = 0; slot_idx < W; slot_idx++) begin
      c2v_column_lane_entries[0][slot_idx] = ram_i0_column_entries[slot_idx];
      c2v_column_lane_entries[1][slot_idx] = ram_i1_column_entries[slot_idx];
    end

    c2v_max_count = int'(c2v_column_lane_count[0]);
    if (int'(c2v_column_lane_count[1]) > c2v_max_count) begin
      c2v_max_count = int'(c2v_column_lane_count[1]);
    end
    c2v_column_slot_last = ((int'(c2v_slot_idx) + 1) >= c2v_max_count);

    v2c_max_count = int'(v2c_column_lane_count[0]);
    if (int'(v2c_column_lane_count[1]) > v2c_max_count) begin
      v2c_max_count = int'(v2c_column_lane_count[1]);
    end
    v2c_column_slot_last = ((int'(v2c_slot_idx) + 1) >= v2c_max_count);

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_lane_valid[lane_idx] = (int'(c2v_slot_idx) < int'(c2v_column_lane_count[lane_idx]));
      c2v_lane_edge_slot[lane_idx] = c2v_column_lane_entries[lane_idx][c2v_slot_idx][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];
      c2v_lane_row_local[lane_idx] = c2v_column_lane_entries[lane_idx][c2v_slot_idx][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
      c2v_lane_row_global[lane_idx] = ROW_W'((lane_idx == 0) ? int'(c2v_lane_row_local[lane_idx]) :
        (ROW_SEG_SIZE + int'(c2v_lane_row_local[lane_idx])));
      if (!c2v_lane_valid[lane_idx]) begin
        c2v_lane_edge_slot[lane_idx] = '0;
        c2v_lane_row_local[lane_idx] = '0;
        c2v_lane_row_global[lane_idx] = '0;
      end

      v2c_lane_valid[lane_idx] = (int'(v2c_slot_idx) < int'(v2c_column_lane_count[lane_idx]));
      v2c_lane_edge_slot[lane_idx] = v2c_column_lane_entries[lane_idx][v2c_slot_idx][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];
      v2c_lane_row_local[lane_idx] = v2c_column_lane_entries[lane_idx][v2c_slot_idx][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
      if (!v2c_lane_valid[lane_idx]) begin
        v2c_lane_edge_slot[lane_idx] = '0;
        v2c_lane_row_local[lane_idx] = '0;
      end
    end

    shift_ram_i = (init_m_write || c2v_write_t) && c2v_column_slot_last;
    ram_i_write_all = seed_active || shift_ram_i;
    ram_i_write_circ_idx = seed_active ? seed_circ_idx : c2v_circ_idx;
    for (slot_idx = 0; slot_idx < W; slot_idx++) begin
      ram_i0_write_entries[slot_idx] = seed_active ?
        QC_FIRST_COL_LANE_ENTRY[seed_circ_idx][0][slot_idx] : shifted_lane_entries[0][slot_idx];
      ram_i1_write_entries[slot_idx] = seed_active ?
        QC_FIRST_COL_LANE_ENTRY[seed_circ_idx][1][slot_idx] : shifted_lane_entries[1][slot_idx];
    end
    ram_i0_write_lane_count = seed_active ?
      QC_FIRST_COL_LANE_COUNT[seed_circ_idx][0] : shifted_lane_count[0];
    ram_i1_write_lane_count = seed_active ?
      QC_FIRST_COL_LANE_COUNT[seed_circ_idx][1] : shifted_lane_count[1];

    for (slot_idx = 0; slot_idx < 4; slot_idx++) begin
      m_clear[slot_idx] = 1'b0;
      m_en[slot_idx] = 1'b0;
      m_we[slot_idx] = 1'b0;
      m_check_row_addr[slot_idx] = '0;
      m_wdata[slot_idx] = COMP_C2V_INIT;
    end

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      s_en[lane_idx] = 1'b0;
      s_we[lane_idx] = 1'b0;
      s_var_idx[lane_idx] = c2v_var_idx;
      s_edge_slot[lane_idx] = c2v_lane_edge_slot[lane_idx];
      s_wdata[lane_idx] = 1'b0;

      t_en[lane_idx] = 1'b0;
      t_we[lane_idx] = 1'b0;
      t_var_idx[lane_idx] = c2v_var_idx;
      t_edge_slot[lane_idx] = c2v_lane_edge_slot[lane_idx];
      t_wdata[lane_idx] = '0;

      u_en[lane_idx] = 1'b0;
      u_we[lane_idx] = 1'b0;
      u_var_idx[lane_idx] = v2c_var_idx;
      u_edge_slot[lane_idx] = v2c_lane_edge_slot[lane_idx];
      u_wdata[lane_idx] = '0;
    end

    s_clear = init_clear;
    t_clear = init_clear;
    u_init = init_clear;
    c1_en = 1'b0;
    c1_we = 1'b0;
    c1_var_idx = v2c_var_idx;
    c1_wdata = 1'b0;

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

    if (init_m_read || c2v_read) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_lane_valid[lane_idx]) begin
          m_en[m_index(comp_c2v_read_bank, LANE_IDX_W'(lane_idx))] = 1'b1;
          m_check_row_addr[m_index(comp_c2v_read_bank, LANE_IDX_W'(lane_idx))] = c2v_lane_row_local[lane_idx];
        end
      end
    end

    if (vnu_read_next_m) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (v2c_lane_valid[lane_idx]) begin
          m_en[m_index(comp_c2v_write_bank, LANE_IDX_W'(lane_idx))] = 1'b1;
          m_check_row_addr[m_index(comp_c2v_write_bank, LANE_IDX_W'(lane_idx))] = v2c_lane_row_local[lane_idx];
        end
      end
    end

    if (init_m_read) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_lane_valid[lane_idx]) begin
          u_en[lane_idx] = 1'b1;
          u_var_idx[lane_idx] = c2v_var_idx;
          u_edge_slot[lane_idx] = c2v_lane_edge_slot[lane_idx];
        end
      end
    end

    if (c2v_read) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_lane_valid[lane_idx]) begin
          s_en[lane_idx] = 1'b1;
          s_var_idx[lane_idx] = c2v_var_idx;
          s_edge_slot[lane_idx] = c2v_lane_edge_slot[lane_idx];
        end
      end
    end

    if (c2v_write_t) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_latched_lane_valid[lane_idx]) begin
          t_en[lane_idx] = 1'b1;
          t_we[lane_idx] = 1'b1;
          t_var_idx[lane_idx] = c2v_latched_var;
          t_edge_slot[lane_idx] = c2v_latched_edge_slot[lane_idx];
          t_wdata[lane_idx] = c2v_tc[lane_idx];
        end
      end
    end

    if (vnu_read_t) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (v2c_lane_valid[lane_idx]) begin
          t_en[lane_idx] = 1'b1;
          t_var_idx[lane_idx] = v2c_var_idx;
          t_edge_slot[lane_idx] = v2c_lane_edge_slot[lane_idx];
        end
      end
    end

    if (init_m_write) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (cnu_a_valid[lane_idx]) begin
          m_en[m_index(c2v_latched_m_pair, LANE_IDX_W'(lane_idx))] = 1'b1;
          m_we[m_index(c2v_latched_m_pair, LANE_IDX_W'(lane_idx))] = 1'b1;
          m_check_row_addr[m_index(c2v_latched_m_pair, LANE_IDX_W'(lane_idx))] = c2v_latched_row_local[lane_idx];
          m_wdata[m_index(c2v_latched_m_pair, LANE_IDX_W'(lane_idx))] = cnu_a_comp_out[lane_idx];

          s_en[lane_idx] = 1'b1;
          s_we[lane_idx] = 1'b1;
          s_var_idx[lane_idx] = c2v_latched_var;
          s_edge_slot[lane_idx] = c2v_latched_edge_slot[lane_idx];
          s_wdata[lane_idx] = cnu_a_sign[lane_idx];
        end
      end
    end

    if (vnu_prep_write) begin
      c1_en = 1'b1;
      c1_we = 1'b1;
      c1_var_idx = work_var;
      c1_wdata = vnu_bit_out;
    end

    if (vnu_write_next) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (cnu_a_valid[lane_idx]) begin
          u_en[lane_idx] = 1'b1;
          u_we[lane_idx] = 1'b1;
          u_var_idx[lane_idx] = v2c_m_latched_var;
          u_edge_slot[lane_idx] = v2c_m_latched_edge_slot[lane_idx];
          u_wdata[lane_idx] = u_next_msg_reg[lane_idx];

          m_en[m_index(v2c_m_latched_m_pair, LANE_IDX_W'(lane_idx))] = 1'b1;
          m_we[m_index(v2c_m_latched_m_pair, LANE_IDX_W'(lane_idx))] = 1'b1;
          m_check_row_addr[m_index(v2c_m_latched_m_pair, LANE_IDX_W'(lane_idx))] = v2c_m_latched_row_local[lane_idx];
          m_wdata[m_index(v2c_m_latched_m_pair, LANE_IDX_W'(lane_idx))] = cnu_a_comp_out[lane_idx];

          s_en[lane_idx] = 1'b1;
          s_we[lane_idx] = 1'b1;
          s_var_idx[lane_idx] = v2c_m_latched_var;
          s_edge_slot[lane_idx] = v2c_m_latched_edge_slot[lane_idx];
          s_wdata[lane_idx] = cnu_a_sign[lane_idx];
        end
      end
    end

    residual_syndrome_next = i_syndrome;
    residual_bank = '0;
    residual_col = 0;
    residual_row = '0;
    for (var_idx = 0; var_idx < N; var_idx++) begin
      if (error_estimate_bits[var_idx]) begin
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
    integer lane_idx;

    if (!i_rst_n) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        v2c_column_lane_count[lane_idx] <= '0;
        v2c_next_column_lane_count[lane_idx] <= '0;
        c2v_latched_lane_valid[lane_idx] <= 1'b0;
        c2v_latched_edge_slot[lane_idx] <= '0;
        c2v_latched_row_local[lane_idx] <= '0;
        c2v_latched_row_global[lane_idx] <= '0;
        v2c_t_latched_lane_valid[lane_idx] <= 1'b0;
        v2c_t_latched_edge_slot[lane_idx] <= '0;
        v2c_m_latched_lane_valid[lane_idx] <= 1'b0;
        v2c_m_latched_edge_slot[lane_idx] <= '0;
        v2c_m_latched_row_local[lane_idx] <= '0;
        u_next_msg_reg[lane_idx] <= '0;
        for (idx = 0; idx < W; idx++) begin
          v2c_column_lane_entries[lane_idx][idx] <= '0;
          v2c_next_column_lane_entries[lane_idx][idx] <= '0;
        end
      end
      c2v_latched_var <= '0;
      c2v_latched_m_pair <= 1'b0;
      v2c_m_latched_var <= '0;
      v2c_m_latched_m_pair <= 1'b0;
      for (idx = 0; idx < W; idx++) begin
        c2v_col_tc[idx] <= '0;
      end
      for (idx = 0; idx < I_MAX; idx++) begin
        syndrome_hist[idx] <= '0;
      end
    end else begin
      if (init_clear) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_column_lane_count[lane_idx] <= '0;
          v2c_next_column_lane_count[lane_idx] <= '0;
          c2v_latched_lane_valid[lane_idx] <= 1'b0;
          v2c_t_latched_lane_valid[lane_idx] <= 1'b0;
          v2c_m_latched_lane_valid[lane_idx] <= 1'b0;
          u_next_msg_reg[lane_idx] <= '0;
          for (idx = 0; idx < W; idx++) begin
            v2c_column_lane_entries[lane_idx][idx] <= '0;
            v2c_next_column_lane_entries[lane_idx][idx] <= '0;
          end
        end
        c2v_latched_var <= '0;
        c2v_latched_m_pair <= 1'b0;
        v2c_m_latched_var <= '0;
        v2c_m_latched_m_pair <= 1'b0;
        for (idx = 0; idx < W; idx++) begin
          c2v_col_tc[idx] <= '0;
        end
        for (idx = 0; idx < I_MAX; idx++) begin
          syndrome_hist[idx] <= '0;
        end
      end

      if (init_m_read || c2v_read) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          c2v_latched_lane_valid[lane_idx] <= c2v_lane_valid[lane_idx];
          c2v_latched_edge_slot[lane_idx] <= c2v_lane_edge_slot[lane_idx];
          c2v_latched_row_local[lane_idx] <= c2v_lane_row_local[lane_idx];
          c2v_latched_row_global[lane_idx] <= c2v_lane_row_global[lane_idx];
        end
        c2v_latched_var <= c2v_var_idx;
        c2v_latched_m_pair <= comp_c2v_read_bank;
      end

      if (capture_consumer_col_now) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_column_lane_count[lane_idx] <= c2v_column_lane_count[lane_idx];
          for (idx = 0; idx < W; idx++) begin
            v2c_column_lane_entries[lane_idx][idx] <= c2v_column_lane_entries[lane_idx][idx];
          end
        end
      end

      if (capture_consumer_col_next) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_next_column_lane_count[lane_idx] <= c2v_column_lane_count[lane_idx];
          for (idx = 0; idx < W; idx++) begin
            v2c_next_column_lane_entries[lane_idx][idx] <= c2v_column_lane_entries[lane_idx][idx];
          end
        end
      end

      if (promote_consumer_col_next) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_column_lane_count[lane_idx] <= v2c_next_column_lane_count[lane_idx];
          for (idx = 0; idx < W; idx++) begin
            v2c_column_lane_entries[lane_idx][idx] <= v2c_next_column_lane_entries[lane_idx][idx];
          end
        end
      end

      if (vnu_read_t) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_t_latched_lane_valid[lane_idx] <= v2c_lane_valid[lane_idx];
          v2c_t_latched_edge_slot[lane_idx] <= v2c_lane_edge_slot[lane_idx];
        end
      end

      if (vnu_read_next_m) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_m_latched_lane_valid[lane_idx] <= v2c_lane_valid[lane_idx];
          v2c_m_latched_edge_slot[lane_idx] <= v2c_lane_edge_slot[lane_idx];
          v2c_m_latched_row_local[lane_idx] <= v2c_lane_row_local[lane_idx];
        end
        v2c_m_latched_var <= v2c_var_idx;
        v2c_m_latched_m_pair <= comp_c2v_write_bank;
      end

      if (vnu_accum_t) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (v2c_t_latched_lane_valid[lane_idx]) begin
            c2v_col_tc[v2c_t_latched_edge_slot[lane_idx]] <= $signed(t_rdata[lane_idx]);
          end
        end
      end

      if (vnu_cnu_a) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (vnu_v2c_msg_valid[lane_idx]) begin
            u_next_msg_reg[lane_idx] <= vnu_v2c_msg[lane_idx];
          end
        end
      end

      if (iter_check) begin
        syndrome_hist[hist_wr_idx] <= residual_syndrome_next;
      end
    end
  end

  assign cnu_a_var_idx = init_cnu_a ? c2v_latched_var : v2c_m_latched_var;
  assign cnu_a_en[0] = (init_cnu_a && c2v_latched_lane_valid[0]) || (vnu_cnu_a && v2c_m_latched_lane_valid[0]);
  assign cnu_a_en[1] = (init_cnu_a && c2v_latched_lane_valid[1]) || (vnu_cnu_a && v2c_m_latched_lane_valid[1]);
  assign cnu_a_v2c_msg[0] = init_cnu_a ? u_rdata[0] : vnu_v2c_msg[0];
  assign cnu_a_v2c_msg[1] = init_cnu_a ? u_rdata[1] : vnu_v2c_msg[1];
  assign cnu_a_comp_in[0] = init_cnu_a ?
    m_rdata[m_index(c2v_latched_m_pair, LANE_IDX_W'(0))] :
    m_rdata[m_index(v2c_m_latched_m_pair, LANE_IDX_W'(0))];
  assign cnu_a_comp_in[1] = init_cnu_a ?
    m_rdata[m_index(c2v_latched_m_pair, LANE_IDX_W'(1))] :
    m_rdata[m_index(v2c_m_latched_m_pair, LANE_IDX_W'(1))];

  cnu_a u_cnu_a0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(init_clear),
    .i_en(cnu_a_en[0]),
    .i_v2c(cnu_a_v2c_msg[0]),
    .i_var_idx(cnu_a_var_idx),
    .i_comp_c2v(cnu_a_comp_in[0]),
    .o_comp_c2v(cnu_a_comp_out[0]),
    .o_sign(cnu_a_sign[0]),
    .o_valid(cnu_a_valid[0])
  );

  cnu_a u_cnu_a1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(init_clear),
    .i_en(cnu_a_en[1]),
    .i_v2c(cnu_a_v2c_msg[1]),
    .i_var_idx(cnu_a_var_idx),
    .i_comp_c2v(cnu_a_comp_in[1]),
    .o_comp_c2v(cnu_a_comp_out[1]),
    .o_sign(cnu_a_sign[1]),
    .o_valid(cnu_a_valid[1])
  );

  cnu_b u_cnu_b0 (
    .i_comp_c2v(m_rdata[m_index(c2v_latched_m_pair, LANE_IDX_W'(0))]),
    .i_v2c_sign(s_rdata[0]),
    .i_syndrome_bit(i_syndrome[c2v_latched_row_global[0]]),
    .i_var_idx(c2v_latched_var),
    .o_c2v_msg(c2v_msg[0])
  );

  cnu_b u_cnu_b1 (
    .i_comp_c2v(m_rdata[m_index(c2v_latched_m_pair, LANE_IDX_W'(1))]),
    .i_v2c_sign(s_rdata[1]),
    .i_syndrome_bit(i_syndrome[c2v_latched_row_global[1]]),
    .i_var_idx(c2v_latched_var),
    .o_c2v_msg(c2v_msg[1])
  );

  msg_signmag_to_tc u_c2v_tc_codec0 (
    .i_valid(c2v_write_t && c2v_latched_lane_valid[0]),
    .i_sign(c2v_msg[0][MSG_SIGN_BIT]),
    .i_mag(c2v_msg[0][MSG_MAG_LSB +: D]),
    .o_valid(c2v_tc_valid_unused[0]),
    .o_tc(c2v_tc[0])
  );

  msg_signmag_to_tc u_c2v_tc_codec1 (
    .i_valid(c2v_write_t && c2v_latched_lane_valid[1]),
    .i_sign(c2v_msg[1][MSG_SIGN_BIT]),
    .i_mag(c2v_msg[1][MSG_MAG_LSB +: D]),
    .o_valid(c2v_tc_valid_unused[1]),
    .o_tc(c2v_tc[1])
  );

  assign vnu_col_start = vnu_accum_t && (v2c_slot_idx == '0);
  assign vnu_col_end = vnu_accum_t && v2c_column_slot_last;
  assign vnu_accum_valid[0] = vnu_accum_t && v2c_t_latched_lane_valid[0];
  assign vnu_accum_valid[1] = vnu_accum_t && v2c_t_latched_lane_valid[1];
  assign vnu_emit_en = vnu_cnu_a;
  assign vnu_prev_c2v_valid[0] = vnu_cnu_a && v2c_m_latched_lane_valid[0];
  assign vnu_prev_c2v_valid[1] = vnu_cnu_a && v2c_m_latched_lane_valid[1];
  assign vnu_prev_c2v[0] = c2v_col_tc[v2c_m_latched_edge_slot[0]];
  assign vnu_prev_c2v[1] = c2v_col_tc[v2c_m_latched_edge_slot[1]];

  vnu u_vnu (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(init_clear),
    .i_col_start(vnu_col_start),
    .i_col_end(vnu_col_end),
    .i_initial_llr($signed(APP_W'(C_VAL))),
    .i_c2v_tc_valid0(vnu_accum_valid[0]),
    .i_c2v_tc0($signed(t_rdata[0])),
    .i_c2v_tc_valid1(vnu_accum_valid[1]),
    .i_c2v_tc1($signed(t_rdata[1])),
    .o_app_valid(vnu_app_valid_unused),
    .o_app(vnu_app_unused),
    .o_bit_decision(vnu_bit_out),
    .i_emit_en(vnu_emit_en),
    .i_prev_c2v_tc_valid0(vnu_prev_c2v_valid[0]),
    .i_prev_c2v_tc0(vnu_prev_c2v[0]),
    .i_prev_c2v_tc_valid1(vnu_prev_c2v_valid[1]),
    .i_prev_c2v_tc1(vnu_prev_c2v[1]),
    .o_v2c_tc_valid0(vnu_v2c_tc_valid[0]),
    .o_v2c_tc0(vnu_v2c_tc[0]),
    .o_v2c_tc_valid1(vnu_v2c_tc_valid[1]),
    .o_v2c_tc1(vnu_v2c_tc[1])
  );

  msg_tc_to_signmag_sat #(
    .TC_W(VNU_TC_W)
  ) u_vnu_v2c_msg_codec0 (
    .i_valid(vnu_v2c_tc_valid[0]),
    .i_tc(vnu_v2c_tc[0]),
    .o_valid(vnu_v2c_msg_valid[0]),
    .o_msg(vnu_v2c_msg[0])
  );

  msg_tc_to_signmag_sat #(
    .TC_W(VNU_TC_W)
  ) u_vnu_v2c_msg_codec1 (
    .i_valid(vnu_v2c_tc_valid[1]),
    .i_tc(vnu_v2c_tc[1]),
    .o_valid(vnu_v2c_msg_valid[1]),
    .o_msg(vnu_v2c_msg[1])
  );

  decoder_ctrl u_decoder_ctrl (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(i_start),
    .i_finish_decode(finish_decode),
    .i_decode_success(decode_success),
    .i_c2v_column_slot_last(c2v_column_slot_last),
    .i_v2c_column_slot_last(v2c_column_slot_last),
    .o_state(state),
    .o_phase(phase),
    .o_work_var(work_var),
    .o_work_edge_slot(work_edge_slot),
    .o_c2v_var_idx(c2v_var_idx),
    .o_v2c_var_idx(v2c_var_idx),
    .o_c2v_slot_idx(c2v_slot_idx),
    .o_v2c_slot_idx(v2c_slot_idx),
    .o_col_slot_idx(col_slot_idx),
    .o_active_m_pair(active_m_pair),
    .o_next_m_pair(next_m_pair),
    .o_comp_c2v_read_bank(comp_c2v_read_bank),
    .o_comp_c2v_write_bank(comp_c2v_write_bank),
    .o_seed_active(seed_active),
    .o_seed_circ_idx(seed_circ_idx),
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
    .o_capture_consumer_col_now(capture_consumer_col_now),
    .o_capture_consumer_col_next(capture_consumer_col_next),
    .o_promote_consumer_col_next(promote_consumer_col_next),
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
    .i_circ_idx(c2v_circ_idx),
    .i_edge_slot_addr('0),
    .i_wdata('0),
    .i_lane_count_we(1'b0),
    .i_lane_count_wdata('0),
    .i_seed_en(ram_i_write_all),
    .i_seed_circ_idx(ram_i_write_circ_idx),
    .i_seed_entries(ram_i0_write_entries),
    .i_seed_lane_count(ram_i0_write_lane_count),
    .o_rdata(ram_i_rdata_unused[0]),
    .o_lane_count(ram_i_lane_count[0]),
    .o_column_entries(ram_i0_column_entries),
    .o_debug_entries(ram_i0_debug_entries),
    .o_debug_lane_count(ram_i0_debug_count)
  );

  ram_i u_ram_i1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_en(1'b0),
    .i_we(1'b0),
    .i_circ_idx(c2v_circ_idx),
    .i_edge_slot_addr('0),
    .i_wdata('0),
    .i_lane_count_we(1'b0),
    .i_lane_count_wdata('0),
    .i_seed_en(ram_i_write_all),
    .i_seed_circ_idx(ram_i_write_circ_idx),
    .i_seed_entries(ram_i1_write_entries),
    .i_seed_lane_count(ram_i1_write_lane_count),
    .o_rdata(ram_i_rdata_unused[1]),
    .o_lane_count(ram_i_lane_count[1]),
    .o_column_entries(ram_i1_column_entries),
    .o_debug_entries(ram_i1_debug_entries),
    .o_debug_lane_count(ram_i1_debug_count)
  );

  ram_c u_ram_c0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(init_clear),
    .i_load_wdata('0),
    .i_en(1'b0),
    .i_we(1'b0),
    .i_var_idx(work_var),
    .i_wdata(1'b0),
    .o_rdata(error_estimate_rd_unused),
    .o_debug_bits(error_estimate_c0_bits_unused)
  );

  ram_c u_ram_c1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(init_clear),
    .i_load_wdata('0),
    .i_en(c1_en),
    .i_we(c1_we),
    .i_var_idx(c1_var_idx),
    .i_wdata(c1_wdata),
    .o_rdata(error_estimate_c1_dout_unused),
    .o_debug_bits(error_estimate_bits)
  );

  ram_m u_ram_m0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[0]),
    .i_en(m_en[0]),
    .i_we(m_we[0]),
    .i_check_row_addr(m_check_row_addr[0]),
    .i_wdata(m_wdata[0]),
    .o_rdata(m_rdata[0]),
    .o_debug_mem(ram_m0_debug_mem)
  );

  ram_m u_ram_m1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[1]),
    .i_en(m_en[1]),
    .i_we(m_we[1]),
    .i_check_row_addr(m_check_row_addr[1]),
    .i_wdata(m_wdata[1]),
    .o_rdata(m_rdata[1]),
    .o_debug_mem(ram_m1_debug_mem)
  );

  ram_m u_ram_m2 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[2]),
    .i_en(m_en[2]),
    .i_we(m_we[2]),
    .i_check_row_addr(m_check_row_addr[2]),
    .i_wdata(m_wdata[2]),
    .o_rdata(m_rdata[2]),
    .o_debug_mem(ram_m2_debug_mem)
  );

  ram_m u_ram_m3 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(m_clear[3]),
    .i_en(m_en[3]),
    .i_we(m_we[3]),
    .i_check_row_addr(m_check_row_addr[3]),
    .i_wdata(m_wdata[3]),
    .o_rdata(m_rdata[3]),
    .o_debug_mem(ram_m3_debug_mem)
  );

  ram_s u_ram_s0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(s_clear),
    .i_en(s_en[0]),
    .i_we(s_we[0]),
    .i_var_idx(s_var_idx[0]),
    .i_edge_slot(s_edge_slot[0]),
    .i_wdata(s_wdata[0]),
    .o_rdata(s_rdata[0]),
    .o_debug_mem(ram_s0_debug_mem)
  );

  ram_s u_ram_s1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(s_clear),
    .i_en(s_en[1]),
    .i_we(s_we[1]),
    .i_var_idx(s_var_idx[1]),
    .i_edge_slot(s_edge_slot[1]),
    .i_wdata(s_wdata[1]),
    .o_rdata(s_rdata[1]),
    .o_debug_mem(ram_s1_debug_mem)
  );

  ram_t u_ram_t0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(t_clear),
    .i_en(t_en[0]),
    .i_we(t_we[0]),
    .i_var_idx(t_var_idx[0]),
    .i_edge_slot(t_edge_slot[0]),
    .i_wdata(t_wdata[0]),
    .o_rdata(t_rdata[0]),
    .o_debug_mem(ram_t0_debug_mem)
  );

  ram_t u_ram_t1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(t_clear),
    .i_en(t_en[1]),
    .i_we(t_we[1]),
    .i_var_idx(t_var_idx[1]),
    .i_edge_slot(t_edge_slot[1]),
    .i_wdata(t_wdata[1]),
    .o_rdata(t_rdata[1]),
    .o_debug_mem(ram_t1_debug_mem)
  );

  ram_u u_ram_u0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_init(u_init),
    .i_en(u_en[0]),
    .i_we(u_we[0]),
    .i_var_idx(u_var_idx[0]),
    .i_edge_slot(u_edge_slot[0]),
    .i_wdata(u_wdata[0]),
    .o_rdata(u_rdata[0]),
    .o_debug_mem(ram_u0_debug_mem)
  );

  ram_u u_ram_u1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_init(u_init),
    .i_en(u_en[1]),
    .i_we(u_we[1]),
    .i_var_idx(u_var_idx[1]),
    .i_edge_slot(u_edge_slot[1]),
    .i_wdata(u_wdata[1]),
    .o_rdata(u_rdata[1]),
    .o_debug_mem(ram_u1_debug_mem)
  );
endmodule
