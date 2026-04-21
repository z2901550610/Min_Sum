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
  // Debug/control visibility exported to the testbench. The real scheduling
  // comes from the explicit control pulses produced by `decoder_ctrl`.
  logic [DEC_STATE_W-1:0] state;
  logic [DEC_PHASE_W-1:0] phase;
  logic [EDGE_W-1:0] work_row_group_pos;
  logic [VAR_W-1:0] work_var;
  logic [VAR_W-1:0] c2v_var_idx;
  logic [VAR_W-1:0] v2c_var_idx;
  logic [EDGE_W-1:0] c2v_row_group_pos;
  logic [EDGE_W-1:0] v2c_row_group_pos;
  logic [EDGE_W-1:0] active_row_group_pos;
  logic c2v_phase_active;
  logic v2c_phase_active;
  logic c2v_v2c_overlap_seen;
  logic capture_v2c_column_now;
  logic capture_v2c_column_next;
  logic promote_v2c_column_next;
  logic [N-1:0] error_estimate_bits;
  logic decision_ram_rdata_unused;
  logic signed [APP_W-1:0] vnu_app_unused;
  logic vnu_app_valid_unused;
  logic [R-1:0] syndrome_hist [0:I_MAX-1];
  logic [ROW_GROUP_COUNT_W-1:0] ram_i_debug_count [0:N0-1][0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] ram_i_rdata_unused [0:L-1];
  logic [ROW_GROUP_COUNT_W-1:0] ram_i_row_group_count [0:L-1];

  logic m_read_pair;
  logic m_write_pair;
  logic seed_active;
  logic [H_BLOCK_W-1:0] seed_h_block_idx;

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

  // Column metadata in the c2v path. The active column comes from RAM-I,
  // while the v2c side keeps its own buffered copies so c2v can stay one
  // column ahead.
  logic [H_BLOCK_W-1:0] c2v_h_block_idx;
  logic [ROW_GROUP_COUNT_W-1:0] c2v_column_row_group_count [0:L-1];
  logic [I_ENTRY_W-1:0] c2v_column_row_group_entries [0:L-1][0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] v2c_column_row_group_count [0:L-1];
  logic [I_ENTRY_W-1:0] v2c_column_row_group_entries [0:L-1][0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] v2c_next_column_row_group_count [0:L-1];
  logic [I_ENTRY_W-1:0] v2c_next_column_row_group_entries [0:L-1][0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] shifted_row_group_count [0:L-1];
  logic [I_ENTRY_W-1:0] shifted_row_group_entries [0:L-1][0:W-1];
  logic c2v_row_group_pos_last;
  logic v2c_row_group_pos_last;
  logic shift_ram_i;

  // Per-edge decoded metadata used to address RAM-M/S/T/U.
  logic c2v_row_group_valid [0:L-1];
  logic [EDGE_W-1:0] c2v_row_group_edge_slot [0:L-1];
  logic [ROW_W-1:0] c2v_row_group_row_local [0:L-1];
  logic [ROW_W-1:0] c2v_row_group_row_global [0:L-1];
  logic v2c_row_group_valid [0:L-1];
  logic [EDGE_W-1:0] v2c_row_group_edge_slot [0:L-1];
  logic [ROW_W-1:0] v2c_row_group_row_local [0:L-1];

  logic c2v_latched_row_group_valid [0:L-1];
  logic [EDGE_W-1:0] c2v_latched_edge_slot [0:L-1];
  logic [ROW_W-1:0] c2v_latched_row_local [0:L-1];
  logic [ROW_W-1:0] c2v_latched_row_global [0:L-1];
  logic [VAR_W-1:0] c2v_latched_var;
  logic c2v_latched_m_read_pair;

  logic v2c_t_latched_row_group_valid [0:L-1];
  logic [EDGE_W-1:0] v2c_t_latched_edge_slot [0:L-1];
  logic v2c_m_latched_row_group_valid [0:L-1];
  logic [EDGE_W-1:0] v2c_m_latched_edge_slot [0:L-1];
  logic [ROW_W-1:0] v2c_m_latched_row_local [0:L-1];
  logic [VAR_W-1:0] v2c_m_latched_var;
  logic v2c_m_latched_m_write_pair;
  logic signed [MSG_W-1:0] c2v_column_cache_tc [0:W-1];
  logic [MSG_W-1:0] u_next_msg_reg [0:L-1];

  logic [R-1:0] residual_syndrome_next;
  logic decode_success;
  logic finish_decode;
  logic [ITER_W:0] next_iter_count_ext;
  logic [HIST_IDX_W-1:0] hist_wr_idx;

  /* verilator lint_off UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] ram_i0_debug_entries_unused [0:N0-1][0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_debug_entries_unused [0:N0-1][0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic [ROW_GROUP_COUNT_W-1:0] ram_i0_debug_count [0:N0-1];
  logic [ROW_GROUP_COUNT_W-1:0] ram_i1_debug_count [0:N0-1];
  logic [I_ENTRY_W-1:0] ram_i0_column_entries [0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_column_entries [0:W-1];
  logic [I_ENTRY_W-1:0] ram_i0_column_entries_wdata [0:W-1];
  logic [I_ENTRY_W-1:0] ram_i1_column_entries_wdata [0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] ram_i0_column_row_group_count_wdata;
  logic [ROW_GROUP_COUNT_W-1:0] ram_i1_column_row_group_count_wdata;
  logic [H_BLOCK_W-1:0] ram_i_column_replace_h_block_idx;
  logic ram_i_column_replace_en;

  // Paper-style RAM port steering. Each block is single-port, so the top
  // centralizes all enables, addresses, and write data here.
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

  logic decision_ram_en;
  logic decision_ram_we;
  logic [VAR_W-1:0] decision_ram_var_idx;
  logic decision_ram_wdata;

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
  logic vnu_v2c_en;
  logic vnu_prev_c2v_valid [0:L-1];
  logic signed [MSG_W-1:0] vnu_prev_c2v [0:L-1];
  logic vnu_bit_out;
  logic vnu_v2c_tc_valid [0:L-1];
  logic signed [VNU_TC_W-1:0] vnu_v2c_tc [0:L-1];
  logic vnu_v2c_msg_valid [0:L-1];
  logic [MSG_W-1:0] vnu_v2c_msg [0:L-1];

  function automatic int m_index(input logic pair, input logic [ROW_GROUP_IDX_W-1:0] row_group);
    begin
      m_index = (pair ? 2 : 0) + int'(row_group);
    end
  endfunction

  assign next_iter_count_ext = {1'b0, o_iter_count} + {{ITER_W{1'b0}}, 1'b1};
  assign hist_wr_idx = o_iter_count[HIST_IDX_W-1:0];
  assign decode_success = (residual_syndrome_next == '0);
  assign finish_decode = decode_success || (next_iter_count_ext >= (ITER_W + 1)'(I_MAX));
  assign c2v_h_block_idx = H_BLOCK_W'(int'(c2v_var_idx) / R);
  assign o_e = error_estimate_bits;

  h_shift u_h_shift (
    .i_row_group_entries(c2v_column_row_group_entries),
    .i_row_group_count(c2v_column_row_group_count),
    .o_row_group_entries(shifted_row_group_entries),
    .o_row_group_count(shifted_row_group_count)
  );

  // Aggregate the two row_group RAM-I debug counts into the shape expected by
  // the testbench.
  always_comb begin
    integer h_block_idx;

    for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      ram_i_debug_count[h_block_idx][0] = ram_i0_debug_count[h_block_idx];
      ram_i_debug_count[h_block_idx][1] = ram_i1_debug_count[h_block_idx];
    end
  end

  // Present the selected c2v column from the two physical RAM-I row_group
  // blocks as one logical column.
  always_comb begin
    integer row_group_pos_idx;

    c2v_column_row_group_count[0] = ram_i_row_group_count[0];
    c2v_column_row_group_count[1] = ram_i_row_group_count[1];
    for (row_group_pos_idx = 0; row_group_pos_idx < W; row_group_pos_idx++) begin
      c2v_column_row_group_entries[0][row_group_pos_idx] = ram_i0_column_entries[row_group_pos_idx];
      c2v_column_row_group_entries[1][row_group_pos_idx] = ram_i1_column_entries[row_group_pos_idx];
    end
  end

  // Decide whether each c2v/v2c column cursor is at the last active row_group
  // list position for the current column.
  always_comb begin
    integer c2v_max_count;
    integer v2c_max_count;

    c2v_max_count = int'(c2v_column_row_group_count[0]);
    if (int'(c2v_column_row_group_count[1]) > c2v_max_count) begin
      c2v_max_count = int'(c2v_column_row_group_count[1]);
    end
    c2v_row_group_pos_last = ((int'(c2v_row_group_pos) + 1) >= c2v_max_count);

    v2c_max_count = int'(v2c_column_row_group_count[0]);
    if (int'(v2c_column_row_group_count[1]) > v2c_max_count) begin
      v2c_max_count = int'(v2c_column_row_group_count[1]);
    end
    v2c_row_group_pos_last = ((int'(v2c_row_group_pos) + 1) >= v2c_max_count);
  end

  // Decode the packed RAM-I entries at the active row_group list position into
  // the addresses consumed by the M/S/T/U memories.
  always_comb begin
    integer row_group_idx;

    for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
      c2v_row_group_valid[row_group_idx] =
        (int'(c2v_row_group_pos) < int'(c2v_column_row_group_count[row_group_idx]));
      c2v_row_group_edge_slot[row_group_idx] =
        c2v_column_row_group_entries[row_group_idx][c2v_row_group_pos][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];
      c2v_row_group_row_local[row_group_idx] =
        c2v_column_row_group_entries[row_group_idx][c2v_row_group_pos][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
      c2v_row_group_row_global[row_group_idx] = ROW_W'((row_group_idx == 0) ?
        int'(c2v_row_group_row_local[row_group_idx]) :
        (ROW_SEG_SIZE + int'(c2v_row_group_row_local[row_group_idx])));
      if (!c2v_row_group_valid[row_group_idx]) begin
        c2v_row_group_edge_slot[row_group_idx] = '0;
        c2v_row_group_row_local[row_group_idx] = '0;
        c2v_row_group_row_global[row_group_idx] = '0;
      end

      v2c_row_group_valid[row_group_idx] =
        (int'(v2c_row_group_pos) < int'(v2c_column_row_group_count[row_group_idx]));
      v2c_row_group_edge_slot[row_group_idx] =
        v2c_column_row_group_entries[row_group_idx][v2c_row_group_pos][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];
      v2c_row_group_row_local[row_group_idx] =
        v2c_column_row_group_entries[row_group_idx][v2c_row_group_pos][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
      if (!v2c_row_group_valid[row_group_idx]) begin
        v2c_row_group_edge_slot[row_group_idx] = '0;
        v2c_row_group_row_local[row_group_idx] = '0;
      end
    end
  end

  // Select the whole-column RAM-I replacement data. The same path seeds the
  // first column and writes the shifted metadata for later columns.
  always_comb begin
    integer row_group_pos_idx;

    shift_ram_i = (init_m_write || c2v_write_t) && c2v_row_group_pos_last;
    ram_i_column_replace_en = seed_active || shift_ram_i;
    ram_i_column_replace_h_block_idx = seed_active ? seed_h_block_idx : c2v_h_block_idx;
    for (row_group_pos_idx = 0; row_group_pos_idx < W; row_group_pos_idx++) begin
      ram_i0_column_entries_wdata[row_group_pos_idx] = seed_active ?
        QC_FIRST_COL_ROW_GROUP_ENTRY[seed_h_block_idx][0][row_group_pos_idx] :
        shifted_row_group_entries[0][row_group_pos_idx];
      ram_i1_column_entries_wdata[row_group_pos_idx] = seed_active ?
        QC_FIRST_COL_ROW_GROUP_ENTRY[seed_h_block_idx][1][row_group_pos_idx] :
        shifted_row_group_entries[1][row_group_pos_idx];
    end
    ram_i0_column_row_group_count_wdata = seed_active ?
      QC_FIRST_COL_ROW_GROUP_COUNT[seed_h_block_idx][0] : shifted_row_group_count[0];
    ram_i1_column_row_group_count_wdata = seed_active ?
      QC_FIRST_COL_ROW_GROUP_COUNT[seed_h_block_idx][1] : shifted_row_group_count[1];
  end

  // Centralized single-port memory steering for RAM-M/S/T/U and the hard
  // decision RAM.
  always_comb begin
    integer port_idx;
    integer row_group_idx;

    for (port_idx = 0; port_idx < 4; port_idx++) begin
      m_clear[port_idx] = 1'b0;
      m_en[port_idx] = 1'b0;
      m_we[port_idx] = 1'b0;
      m_check_row_addr[port_idx] = '0;
      m_wdata[port_idx] = COMP_C2V_INIT;
    end

    for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
      s_en[row_group_idx] = 1'b0;
      s_we[row_group_idx] = 1'b0;
      s_var_idx[row_group_idx] = c2v_var_idx;
      s_edge_slot[row_group_idx] = c2v_row_group_edge_slot[row_group_idx];
      s_wdata[row_group_idx] = 1'b0;

      t_en[row_group_idx] = 1'b0;
      t_we[row_group_idx] = 1'b0;
      t_var_idx[row_group_idx] = c2v_var_idx;
      t_edge_slot[row_group_idx] = c2v_row_group_edge_slot[row_group_idx];
      t_wdata[row_group_idx] = '0;

      u_en[row_group_idx] = 1'b0;
      u_we[row_group_idx] = 1'b0;
      u_var_idx[row_group_idx] = v2c_var_idx;
      u_edge_slot[row_group_idx] = v2c_row_group_edge_slot[row_group_idx];
      u_wdata[row_group_idx] = '0;
    end

    s_clear = init_clear;
    t_clear = init_clear;
    u_init = init_clear;
    decision_ram_en = 1'b0;
    decision_ram_we = 1'b0;
    decision_ram_var_idx = v2c_var_idx;
    decision_ram_wdata = 1'b0;

    if (init_clear) begin
      m_clear[0] = 1'b1;
      m_clear[1] = 1'b1;
      m_clear[2] = 1'b1;
      m_clear[3] = 1'b1;
    end

    if (clear_next_m) begin
      m_clear[m_index(m_write_pair, ROW_GROUP_IDX_W'(0))] = 1'b1;
      m_clear[m_index(m_write_pair, ROW_GROUP_IDX_W'(1))] = 1'b1;
    end

    if (init_m_read || c2v_read) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (c2v_row_group_valid[row_group_idx]) begin
          m_en[m_index(m_read_pair, ROW_GROUP_IDX_W'(row_group_idx))] = 1'b1;
          m_check_row_addr[m_index(m_read_pair, ROW_GROUP_IDX_W'(row_group_idx))] =
            c2v_row_group_row_local[row_group_idx];
        end
      end
    end

    if (vnu_read_next_m) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (v2c_row_group_valid[row_group_idx]) begin
          m_en[m_index(m_write_pair, ROW_GROUP_IDX_W'(row_group_idx))] = 1'b1;
          m_check_row_addr[m_index(m_write_pair, ROW_GROUP_IDX_W'(row_group_idx))] =
            v2c_row_group_row_local[row_group_idx];
        end
      end
    end

    if (init_m_read) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (c2v_row_group_valid[row_group_idx]) begin
          u_en[row_group_idx] = 1'b1;
          u_var_idx[row_group_idx] = c2v_var_idx;
          u_edge_slot[row_group_idx] = c2v_row_group_edge_slot[row_group_idx];
        end
      end
    end

    if (c2v_read) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (c2v_row_group_valid[row_group_idx]) begin
          s_en[row_group_idx] = 1'b1;
          s_var_idx[row_group_idx] = c2v_var_idx;
          s_edge_slot[row_group_idx] = c2v_row_group_edge_slot[row_group_idx];
        end
      end
    end

    if (c2v_write_t) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (c2v_latched_row_group_valid[row_group_idx]) begin
          t_en[row_group_idx] = 1'b1;
          t_we[row_group_idx] = 1'b1;
          t_var_idx[row_group_idx] = c2v_latched_var;
          t_edge_slot[row_group_idx] = c2v_latched_edge_slot[row_group_idx];
          t_wdata[row_group_idx] = c2v_tc[row_group_idx];
        end
      end
    end

    if (vnu_read_t) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (v2c_row_group_valid[row_group_idx]) begin
          t_en[row_group_idx] = 1'b1;
          t_var_idx[row_group_idx] = v2c_var_idx;
          t_edge_slot[row_group_idx] = v2c_row_group_edge_slot[row_group_idx];
        end
      end
    end

    if (init_m_write) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (cnu_a_valid[row_group_idx]) begin
          m_en[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(row_group_idx))] = 1'b1;
          m_we[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(row_group_idx))] = 1'b1;
          m_check_row_addr[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(row_group_idx))] =
            c2v_latched_row_local[row_group_idx];
          m_wdata[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(row_group_idx))] =
            cnu_a_comp_out[row_group_idx];

          s_en[row_group_idx] = 1'b1;
          s_we[row_group_idx] = 1'b1;
          s_var_idx[row_group_idx] = c2v_latched_var;
          s_edge_slot[row_group_idx] = c2v_latched_edge_slot[row_group_idx];
          s_wdata[row_group_idx] = cnu_a_sign[row_group_idx];
        end
      end
    end

    if (vnu_prep_write) begin
      decision_ram_en = 1'b1;
      decision_ram_we = 1'b1;
      decision_ram_var_idx = v2c_var_idx;
      decision_ram_wdata = vnu_bit_out;
    end

    if (vnu_write_next) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        if (cnu_a_valid[row_group_idx]) begin
          u_en[row_group_idx] = 1'b1;
          u_we[row_group_idx] = 1'b1;
          u_var_idx[row_group_idx] = v2c_m_latched_var;
          u_edge_slot[row_group_idx] = v2c_m_latched_edge_slot[row_group_idx];
          u_wdata[row_group_idx] = u_next_msg_reg[row_group_idx];

          m_en[m_index(v2c_m_latched_m_write_pair, ROW_GROUP_IDX_W'(row_group_idx))] = 1'b1;
          m_we[m_index(v2c_m_latched_m_write_pair, ROW_GROUP_IDX_W'(row_group_idx))] = 1'b1;
          m_check_row_addr[m_index(v2c_m_latched_m_write_pair, ROW_GROUP_IDX_W'(row_group_idx))] =
            v2c_m_latched_row_local[row_group_idx];
          m_wdata[m_index(v2c_m_latched_m_write_pair, ROW_GROUP_IDX_W'(row_group_idx))] =
            cnu_a_comp_out[row_group_idx];

          s_en[row_group_idx] = 1'b1;
          s_we[row_group_idx] = 1'b1;
          s_var_idx[row_group_idx] = v2c_m_latched_var;
          s_edge_slot[row_group_idx] = v2c_m_latched_edge_slot[row_group_idx];
          s_wdata[row_group_idx] = cnu_a_sign[row_group_idx];
        end
      end
    end
  end

  // Recompute the residual syndrome from the single hard-decision RAM, which is
  // the source of truth for the exported error estimate.
  always_comb begin
    integer var_idx;
    integer edge_slot;
    logic [H_BLOCK_W-1:0] residual_h_block_idx;
    integer residual_col;
    logic [ROW_W-1:0] residual_row;

    residual_syndrome_next = i_syndrome;
    residual_h_block_idx = '0;
    residual_col = 0;
    residual_row = '0;
    for (var_idx = 0; var_idx < N; var_idx++) begin
      if (error_estimate_bits[var_idx]) begin
        residual_h_block_idx = H_BLOCK_W'(var_idx / R);
        residual_col = var_idx % R;
        for (edge_slot = 0; edge_slot < W; edge_slot++) begin
          residual_row = ROW_W'((H_BASE[0][residual_h_block_idx][edge_slot] + residual_col) % R);
          residual_syndrome_next[residual_row] = residual_syndrome_next[residual_row] ^ 1'b1;
        end
      end
    end
  end

  // Sequential latches/caches that bridge the single-port memories and the
  // multi-cycle control schedule. These registers keep the edge metadata and
  // per-column c2v cache stable across the c2v/v2c handoff.
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer idx;
    integer row_group_idx;

    if (!i_rst_n) begin
      for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
        v2c_column_row_group_count[row_group_idx] <= '0;
        v2c_next_column_row_group_count[row_group_idx] <= '0;
        c2v_latched_row_group_valid[row_group_idx] <= 1'b0;
        c2v_latched_edge_slot[row_group_idx] <= '0;
        c2v_latched_row_local[row_group_idx] <= '0;
        c2v_latched_row_global[row_group_idx] <= '0;
        v2c_t_latched_row_group_valid[row_group_idx] <= 1'b0;
        v2c_t_latched_edge_slot[row_group_idx] <= '0;
        v2c_m_latched_row_group_valid[row_group_idx] <= 1'b0;
        v2c_m_latched_edge_slot[row_group_idx] <= '0;
        v2c_m_latched_row_local[row_group_idx] <= '0;
        u_next_msg_reg[row_group_idx] <= '0;
        for (idx = 0; idx < W; idx++) begin
          v2c_column_row_group_entries[row_group_idx][idx] <= '0;
          v2c_next_column_row_group_entries[row_group_idx][idx] <= '0;
        end
      end
      c2v_latched_var <= '0;
      c2v_latched_m_read_pair <= 1'b0;
      v2c_m_latched_var <= '0;
      v2c_m_latched_m_write_pair <= 1'b0;
      for (idx = 0; idx < W; idx++) begin
        c2v_column_cache_tc[idx] <= '0;
      end
      for (idx = 0; idx < I_MAX; idx++) begin
        syndrome_hist[idx] <= '0;
      end
    end else begin
      if (init_clear) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          v2c_column_row_group_count[row_group_idx] <= '0;
          v2c_next_column_row_group_count[row_group_idx] <= '0;
          c2v_latched_row_group_valid[row_group_idx] <= 1'b0;
          v2c_t_latched_row_group_valid[row_group_idx] <= 1'b0;
          v2c_m_latched_row_group_valid[row_group_idx] <= 1'b0;
          u_next_msg_reg[row_group_idx] <= '0;
          for (idx = 0; idx < W; idx++) begin
            v2c_column_row_group_entries[row_group_idx][idx] <= '0;
            v2c_next_column_row_group_entries[row_group_idx][idx] <= '0;
          end
        end
        c2v_latched_var <= '0;
        c2v_latched_m_read_pair <= 1'b0;
        v2c_m_latched_var <= '0;
        v2c_m_latched_m_write_pair <= 1'b0;
        for (idx = 0; idx < W; idx++) begin
          c2v_column_cache_tc[idx] <= '0;
        end
        for (idx = 0; idx < I_MAX; idx++) begin
          syndrome_hist[idx] <= '0;
        end
      end

      if (init_m_read || c2v_read) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          c2v_latched_row_group_valid[row_group_idx] <= c2v_row_group_valid[row_group_idx];
          c2v_latched_edge_slot[row_group_idx] <= c2v_row_group_edge_slot[row_group_idx];
          c2v_latched_row_local[row_group_idx] <= c2v_row_group_row_local[row_group_idx];
          c2v_latched_row_global[row_group_idx] <= c2v_row_group_row_global[row_group_idx];
        end
        c2v_latched_var <= c2v_var_idx;
        c2v_latched_m_read_pair <= m_read_pair;
      end

      if (capture_v2c_column_now) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          v2c_column_row_group_count[row_group_idx] <= c2v_column_row_group_count[row_group_idx];
          for (idx = 0; idx < W; idx++) begin
            v2c_column_row_group_entries[row_group_idx][idx] <= c2v_column_row_group_entries[row_group_idx][idx];
          end
        end
      end

      if (capture_v2c_column_next) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          v2c_next_column_row_group_count[row_group_idx] <= c2v_column_row_group_count[row_group_idx];
          for (idx = 0; idx < W; idx++) begin
            v2c_next_column_row_group_entries[row_group_idx][idx] <= c2v_column_row_group_entries[row_group_idx][idx];
          end
        end
      end

      if (promote_v2c_column_next) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          v2c_column_row_group_count[row_group_idx] <= v2c_next_column_row_group_count[row_group_idx];
          for (idx = 0; idx < W; idx++) begin
            v2c_column_row_group_entries[row_group_idx][idx] <= v2c_next_column_row_group_entries[row_group_idx][idx];
          end
        end
      end

      if (vnu_read_t) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          v2c_t_latched_row_group_valid[row_group_idx] <= v2c_row_group_valid[row_group_idx];
          v2c_t_latched_edge_slot[row_group_idx] <= v2c_row_group_edge_slot[row_group_idx];
        end
      end

      if (vnu_read_next_m) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          v2c_m_latched_row_group_valid[row_group_idx] <= v2c_row_group_valid[row_group_idx];
          v2c_m_latched_edge_slot[row_group_idx] <= v2c_row_group_edge_slot[row_group_idx];
          v2c_m_latched_row_local[row_group_idx] <= v2c_row_group_row_local[row_group_idx];
        end
        v2c_m_latched_var <= v2c_var_idx;
        v2c_m_latched_m_write_pair <= m_write_pair;
      end

      if (vnu_accum_t) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          if (v2c_t_latched_row_group_valid[row_group_idx]) begin
            c2v_column_cache_tc[v2c_t_latched_edge_slot[row_group_idx]] <= $signed(t_rdata[row_group_idx]);
          end
        end
      end

      if (vnu_cnu_a) begin
        for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
          if (vnu_v2c_msg_valid[row_group_idx]) begin
            u_next_msg_reg[row_group_idx] <= vnu_v2c_msg[row_group_idx];
          end
        end
      end

      if (iter_check) begin
        syndrome_hist[hist_wr_idx] <= residual_syndrome_next;
      end
    end
  end

  assign cnu_a_var_idx = init_cnu_a ? c2v_latched_var : v2c_m_latched_var;
  assign cnu_a_en[0] = (init_cnu_a && c2v_latched_row_group_valid[0]) || (vnu_cnu_a && v2c_m_latched_row_group_valid[0]);
  assign cnu_a_en[1] = (init_cnu_a && c2v_latched_row_group_valid[1]) || (vnu_cnu_a && v2c_m_latched_row_group_valid[1]);
  assign cnu_a_v2c_msg[0] = init_cnu_a ? u_rdata[0] : vnu_v2c_msg[0];
  assign cnu_a_v2c_msg[1] = init_cnu_a ? u_rdata[1] : vnu_v2c_msg[1];
  assign cnu_a_comp_in[0] = init_cnu_a ?
    m_rdata[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(0))] :
    m_rdata[m_index(v2c_m_latched_m_write_pair, ROW_GROUP_IDX_W'(0))];
  assign cnu_a_comp_in[1] = init_cnu_a ?
    m_rdata[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(1))] :
    m_rdata[m_index(v2c_m_latched_m_write_pair, ROW_GROUP_IDX_W'(1))];

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
    .i_comp_c2v(m_rdata[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(0))]),
    .i_v2c_sign(s_rdata[0]),
    .i_syndrome_bit(i_syndrome[c2v_latched_row_global[0]]),
    .i_var_idx(c2v_latched_var),
    .o_c2v_msg(c2v_msg[0])
  );

  cnu_b u_cnu_b1 (
    .i_comp_c2v(m_rdata[m_index(c2v_latched_m_read_pair, ROW_GROUP_IDX_W'(1))]),
    .i_v2c_sign(s_rdata[1]),
    .i_syndrome_bit(i_syndrome[c2v_latched_row_global[1]]),
    .i_var_idx(c2v_latched_var),
    .o_c2v_msg(c2v_msg[1])
  );

  msg_signmag_to_tc u_c2v_tc_codec0 (
    .i_valid(c2v_write_t && c2v_latched_row_group_valid[0]),
    .i_sign(c2v_msg[0][MSG_SIGN_BIT]),
    .i_mag(c2v_msg[0][MSG_MAG_LSB +: D]),
    .o_valid(c2v_tc_valid_unused[0]),
    .o_tc(c2v_tc[0])
  );

  msg_signmag_to_tc u_c2v_tc_codec1 (
    .i_valid(c2v_write_t && c2v_latched_row_group_valid[1]),
    .i_sign(c2v_msg[1][MSG_SIGN_BIT]),
    .i_mag(c2v_msg[1][MSG_MAG_LSB +: D]),
    .o_valid(c2v_tc_valid_unused[1]),
    .o_tc(c2v_tc[1])
  );

  assign vnu_col_start = vnu_accum_t && (v2c_row_group_pos == '0);
  assign vnu_col_end = vnu_accum_t && v2c_row_group_pos_last;
  assign vnu_accum_valid[0] = vnu_accum_t && v2c_t_latched_row_group_valid[0];
  assign vnu_accum_valid[1] = vnu_accum_t && v2c_t_latched_row_group_valid[1];
  assign vnu_v2c_en = vnu_cnu_a;
  assign vnu_prev_c2v_valid[0] = vnu_cnu_a && v2c_m_latched_row_group_valid[0];
  assign vnu_prev_c2v_valid[1] = vnu_cnu_a && v2c_m_latched_row_group_valid[1];
  assign vnu_prev_c2v[0] = c2v_column_cache_tc[v2c_m_latched_edge_slot[0]];
  assign vnu_prev_c2v[1] = c2v_column_cache_tc[v2c_m_latched_edge_slot[1]];

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
    .i_v2c_en(vnu_v2c_en),
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
    .i_c2v_row_group_pos_last(c2v_row_group_pos_last),
    .i_v2c_row_group_pos_last(v2c_row_group_pos_last),
    .o_state(state),
    .o_phase(phase),
    .o_work_var(work_var),
    .o_work_row_group_pos(work_row_group_pos),
    .o_c2v_var_idx(c2v_var_idx),
    .o_v2c_var_idx(v2c_var_idx),
    .o_c2v_row_group_pos(c2v_row_group_pos),
    .o_v2c_row_group_pos(v2c_row_group_pos),
    .o_active_row_group_pos(active_row_group_pos),
    .o_m_read_pair(m_read_pair),
    .o_m_write_pair(m_write_pair),
    .o_seed_active(seed_active),
    .o_seed_h_block_idx(seed_h_block_idx),
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
    .o_capture_v2c_column_now(capture_v2c_column_now),
    .o_capture_v2c_column_next(capture_v2c_column_next),
    .o_promote_v2c_column_next(promote_v2c_column_next),
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
    .i_h_block_idx(c2v_h_block_idx),
    .i_row_group_pos_addr('0),
    .i_wdata('0),
    .i_row_group_count_we(1'b0),
    .i_row_group_count_wdata('0),
    .i_column_replace_en(ram_i_column_replace_en),
    .i_column_replace_h_block_idx(ram_i_column_replace_h_block_idx),
    .i_column_entries_wdata(ram_i0_column_entries_wdata),
    .i_column_row_group_count_wdata(ram_i0_column_row_group_count_wdata),
    .o_rdata(ram_i_rdata_unused[0]),
    .o_row_group_count(ram_i_row_group_count[0]),
    .o_column_entries(ram_i0_column_entries),
    .o_debug_entries(ram_i0_debug_entries_unused),
    .o_debug_row_group_count(ram_i0_debug_count)
  );

  ram_i u_ram_i1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_en(1'b0),
    .i_we(1'b0),
    .i_h_block_idx(c2v_h_block_idx),
    .i_row_group_pos_addr('0),
    .i_wdata('0),
    .i_row_group_count_we(1'b0),
    .i_row_group_count_wdata('0),
    .i_column_replace_en(ram_i_column_replace_en),
    .i_column_replace_h_block_idx(ram_i_column_replace_h_block_idx),
    .i_column_entries_wdata(ram_i1_column_entries_wdata),
    .i_column_row_group_count_wdata(ram_i1_column_row_group_count_wdata),
    .o_rdata(ram_i_rdata_unused[1]),
    .o_row_group_count(ram_i_row_group_count[1]),
    .o_column_entries(ram_i1_column_entries),
    .o_debug_entries(ram_i1_debug_entries_unused),
    .o_debug_row_group_count(ram_i1_debug_count)
  );

  ram_c u_decision_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(1'b0),
    .i_load(init_clear),
    .i_load_wdata('0),
    .i_en(decision_ram_en),
    .i_we(decision_ram_we),
    .i_var_idx(decision_ram_var_idx),
    .i_wdata(decision_ram_wdata),
    .o_rdata(decision_ram_rdata_unused),
    .o_bits(error_estimate_bits)
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
