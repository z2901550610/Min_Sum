`timescale 1ns / 1ps
// Top-level BIKE min-sum decoder datapath and module interconnect.
//
// The controller owns column scheduling. This shell wires the RAM-I metadata
// reader, RAM-M compressed c2v state, RAM-S sign storage, RAM-T edge-message
// FIFO lanes, CNU/VNU lanes, and the external decision/syndrome memories into
// one overlapped c2v/v2c pipeline.
module decoder_top
  import bike_pkg::*;
#(
    parameter string RAM_I_HEX_PREFIX = "ram_i",
`ifndef BIKE_TOY_PARAMS
    parameter string RAM_I_HEX_TAG    = "_l1"
`else
    parameter string RAM_I_HEX_TAG    = "_test"
`endif
) (
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_start,
    input  logic                   i_syndrome_we,
    input  logic [  ROW_IDX_W-1:0] i_syndrome_addr,
    input  logic                   i_syndrome_wdata,
    input  logic                   i_h_load_start,
    input  logic                   i_h_load_valid,
    input  logic [  ROW_IDX_W-1:0] i_h_load_row_idx_global[0:L-1],
    input  logic [      COL_W-1:0] i_e_read_col_idx,
    output logic                   o_h_load_ready,
    output logic                   o_h_load_busy,
    output logic                   o_h_load_done,
    output logic [  H_BLOCK_W-1:0] o_h_load_request_h_block_idx,
    output logic [ENTRY_POS_W-1:0] o_h_load_request_entry_pos,
    output logic                   o_done,
    output logic                   o_e_rdata,
    output logic [     ITER_W-1:0] o_iter_count
);

`ifndef SYNTHESIS
  initial begin
    if ((L <= 0) || ((L & (L - 1)) != 0)) begin
      $fatal(1, "decoder_top requires L to be a power of two");
    end
    if (RAM_LANE_DEPTH < 3) begin
      $fatal(1, "decoder_top requires RAM_LANE_DEPTH >= 3");
    end
  end
`endif

  /* verilator lint_off UNUSEDSIGNAL */
  // Debug/control visibility exported to the testbench. The real scheduling
  // comes from the explicit control pulses produced by `decoder_ctrl`.
  logic [DEC_STATE_W-1:0] state;
  logic [ENTRY_POS_W-1:0] work_entry_pos;
  logic [      COL_W-1:0] work_col_idx;
  logic [      COL_W-1:0] c2v_col_idx;
  logic [      COL_W-1:0] v2c_col_idx;
  logic [ENTRY_POS_W-1:0] c2v_entry_pos;
  logic [ENTRY_POS_W-1:0] v2c_entry_pos;
  logic [ENTRY_POS_W-1:0] active_entry_pos;
  logic                   c2v_phase_active;
  logic                   v2c_phase_active;
  logic                   c2v_v2c_overlap_seen;
  logic                   col_k_meta_advance;
`ifdef BIKE_SIM_DEBUG
  logic [GROUP_COUNT_W-1:0] ram_i_debug_count[0:N0-1][0:L-1];
`endif
  /* verilator lint_on UNUSEDSIGNAL */
  logic [    I_ENTRY_W-1:0] ram_i_list_entries[0:L-1][0:N0-1][0:RAM_LANE_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] ram_i_list_counts[0:L-1][0:N0-1];
  logic                     ram_i_load_lane_we[0:L-1];
  logic                     ram_i_load_count_we[0:L-1];
  logic [    H_BLOCK_W-1:0] ram_i_load_write_h_block_idx;
  logic [  ENTRY_POS_W-1:0] ram_i_load_write_entry_idx;
  logic [    I_ENTRY_W-1:0] ram_i_load_entry_wdata[0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_load_count_wdata[0:L-1];

  logic                     ram_m_read_pair_sel;
  logic                     ram_m_write_pair_sel;

  logic                     c2v_read;
  logic                     v2c_read;
  logic                     c2v_write_t;
  logic                     vnu_accum_t;
  logic                     vnu_finalize;
  logic                     decision_write;
  logic                     v2c_emit_to_cnu_a;
  logic                     cnu_a_writeback;
  logic                     iter_check;
  logic                     merge_done;
  /* verilator lint_off UNUSEDSIGNAL */
  logic                     merge_read_unused;
  logic                     merge_write_unused;
  logic [    ROW_IDX_W-1:0] merge_row_idx_unused;
  /* verilator lint_on UNUSEDSIGNAL */

  // Column metadata slots. c2v fills next_meta_slot from RAM-I reads; v2c
  // consumes active_meta_slot while issuing CNU_A/VNU work for the previous
  // completed column.
  logic [    H_BLOCK_W-1:0] c2v_col_h_block_idx;
  logic                     active_meta_slot;
  logic                     next_meta_slot;
  logic [GROUP_COUNT_W-1:0] col_meta_slot_count[  0:1];
  logic                     col_meta_lane_valid[  0:1][ 0:L-1][0:RAM_LANE_DEPTH-1];
  logic [    ROW_IDX_W-1:0] col_meta_lane_entries[  0:1][ 0:L-1][0:RAM_LANE_DEPTH-1];
  logic [    ONE_IDX_W-1:0] col_meta_lane_one_idx[  0:1][ 0:L-1][0:RAM_LANE_DEPTH-1];
  logic [    EDGE_ID_W-1:0] col_meta_lane_edge_id[  0:1][ 0:L-1][0:RAM_LANE_DEPTH-1];
  logic [  ENTRY_POS_W-1:0] ram_i_read_entry_addr[0:L-1];
  logic                     c2v_read_d1;
  logic [        COL_W-1:0] c2v_read_col_d1;
  logic [  ENTRY_POS_W-1:0] c2v_read_entry_pos_d1;
  logic                     c2v_read_entry_pos_last_d1;
  logic                     c2v_read_ram_m_pair_sel_d1;
  logic                     c2v_read_meta_slot_d1;
  logic                     c2v_entry_pos_last;
  logic                     v2c_entry_pos_last;

  // Per-edge decoded metadata used to address RAM-M/S/T.
  logic                     c2v_group_valid[0:L-1];
  logic [    ROW_IDX_W-1:0] c2v_row_idx_global[0:L-1];
  logic [    ONE_IDX_W-1:0] c2v_one_idx[0:L-1];
  logic [    EDGE_ID_W-1:0] c2v_edge_id[0:L-1];
  logic                     v2c_group_valid[0:L-1];
  logic [    ROW_IDX_W-1:0] v2c_row_idx_global[0:L-1];
  logic [    ONE_IDX_W-1:0] v2c_one_idx[0:L-1];
  logic [    EDGE_ID_W-1:0] v2c_edge_id[0:L-1];

  logic                     c2v_latched_group_valid[0:L-1];
  logic [    ONE_IDX_W-1:0] c2v_latched_one_idx[0:L-1];
  logic [    EDGE_ID_W-1:0] c2v_latched_edge_id[0:L-1];
  logic [  ENTRY_POS_W-1:0] c2v_latched_entry_pos;
  logic                     c2v_latched_entry_pos_last;
  logic                     c2v_latched_ram_m_pair_sel;

  logic                     v2c_m_latched_group_valid[0:L-1];
  logic [    ROW_IDX_W-1:0] v2c_m_latched_row_idx_global[0:L-1];
  logic [    ONE_IDX_W-1:0] v2c_m_latched_one_idx[0:L-1];
  logic [  ENTRY_POS_W-1:0] v2c_m_latched_entry_pos;
  logic [        COL_W-1:0] v2c_m_latched_col;
  logic                     v2c_m_latched_ram_m_pair_sel;
  logic [        COL_W-1:0] v2c_read_col_d1;
  logic [  ENTRY_POS_W-1:0] v2c_read_entry_pos_d1;
  logic                     v2c_read_ram_m_pair_sel_d1;
  logic                     v2c_read_group_valid_d1[0:L-1];
  logic [    ROW_IDX_W-1:0] v2c_read_row_idx_global_d1[0:L-1];
  logic [    ONE_IDX_W-1:0] v2c_read_one_idx_d1[0:L-1];
  logic [    EDGE_ID_W-1:0] v2c_read_edge_id_d1[0:L-1];
  logic                     c2v_sched_issued[0:W-1];
  logic                     c2v_sched_issued_next[0:W-1];

  logic                     finish_decode;
  logic                     decision_ram_old_bit;
  logic [         ITER_W:0] next_iter_count_ext;
`ifdef BIKE_SIM_DEBUG
  logic [GROUP_COUNT_W-1:0] ram_i_bank_debug_count[0:L-1][0:N0-1];
`endif

  // RAM-M pair steering. ram_m_read_pair_sel provides the previous iteration's
  // compressed c2v state for CNU_B; ram_m_write_pair_sel collects CNU_A
  // writeback for the next iteration. Per-pair epochs make stale rows read as
  // COMP_C2V_INIT without clearing the full RAM contents.
  logic                     m_pair_read_valid[  0:1][0:L-1];
  logic [    ROW_IDX_W-1:0] m_pair_read_row_idx_global[  0:1][0:L-1];
  logic                     m_pair_we[  0:1][0:L-1];
  logic [    ROW_IDX_W-1:0] m_pair_write_row_idx_global[  0:1] [0:L-1];
  logic [   COMP_C2V_W-1:0] m_pair_wdata[  0:1][0:L-1];
  logic [   COMP_C2V_W-1:0] m_pair_rdata[  0:1][0:L-1];
  logic                     m_pair_repoch[  0:1][0:L-1];
  logic                     m_pair_epoch[  0:1];

  logic                     s_rdata[0:L-1];
  logic                     s_col_we;
  logic [S_WORD_ADDR_W-1:0] s_read_col_idx;
  logic [S_WORD_ADDR_W-1:0] s_write_col_idx;
  logic [     S_WORD_W-1:0] s_col_wdata;
  logic [     S_WORD_W-1:0] s_col_rdata;

  logic                     t_push[0:L-1];
  logic                     t_pop[0:L-1];
  logic                     t_valid[0:L-1];
  logic [  ENTRY_POS_W-1:0] t_write_entry_idx;
  logic [  ENTRY_POS_W-1:0] t_read_entry_idx;
  logic [        MSG_W-1:0] t_wdata[0:L-1];
  logic                     t_metadata_rvalid[0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [        MSG_W-1:0] t_rdata[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
`ifdef BIKE_SIM_DEBUG
  /* verilator lint_off UNUSEDSIGNAL */
  logic [GROUP_COUNT_W-1:0] ram_t_debug_item_count[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
`endif

  logic                         decision_ram_we;
  logic        [     COL_W-1:0] decision_ram_col_idx;
  logic        [     COL_W-1:0] decision_ram_access_col_idx;
  logic                         decision_ram_wdata;
  logic        [ ROW_IDX_W-1:0] syndrome_read_row_idx[0:L-1];
  logic                         syndrome_rdata[0:L-1];

  logic                         cnu_a_en[0:L-1];
  logic        [     MSG_W-1:0] cnu_a_v2c_msg[0:L-1];
  logic        [ EDGE_ID_W-1:0] cnu_a_edge_id[0:L-1];
  logic        [COMP_C2V_W-1:0] cnu_a_comp_in[0:L-1];
  logic        [COMP_C2V_W-1:0] cnu_a_comp_out[0:L-1];
  logic                         cnu_a_sign[0:L-1];
  logic                         cnu_a_valid[0:L-1];
  logic        [COMP_C2V_W-1:0] cnu_b_comp_in[0:L-1];

  logic        [     MSG_W-1:0] c2v_msg[0:L-1];
  logic signed [     MSG_W-1:0] c2v_tc[0:L-1];

  logic                         vnu_col_start;
  logic                         vnu_col_end;
  logic                         vnu_accum_valid[0:L-1];
  logic                         vnu_prev_c2v_valid[0:L-1];
  logic signed [     MSG_W-1:0] vnu_prev_c2v[0:L-1];
  logic                         vnu_bit_out;
  logic signed [  VNU_TC_W-1:0] vnu_v2c_tc[0:L-1];
  logic        [     MSG_W-1:0] vnu_v2c_msg[0:L-1];

  function automatic logic [M_ROW_BANK_IDX_W-1:0] row_bank(
      input  logic [ROW_IDX_W-1:0] row_idx_global);
    begin
      if (M_ROW_BANKS == 1) begin
        row_bank = '0;
      end else begin
        row_bank = M_ROW_BANK_IDX_W'(int'(row_idx_global) % M_ROW_BANKS);
      end
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] m_write_comp_or_init(
      input  logic pair, input  logic [LANE_IDX_W-1:0] lane_idx);
    begin
      if (m_pair_repoch[pair][lane_idx] == m_pair_epoch[pair]) begin
        m_write_comp_or_init = m_pair_rdata[pair][lane_idx];
      end else begin
        m_write_comp_or_init = COMP_C2V_INIT;
      end
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] m_read_comp_or_first(
      input  logic pair, input  logic [LANE_IDX_W-1:0] lane_idx, input  logic use_first_iter_default);
    begin
      if (use_first_iter_default) begin
        m_read_comp_or_first = FIRST_ITER_C2V_COMP;
      end else begin
        m_read_comp_or_first = m_pair_rdata[pair][lane_idx];
      end
    end
  endfunction

  assign next_iter_count_ext = {1'b0, o_iter_count} + {{ITER_W{1'b0}}, 1'b1};
  assign finish_decode = (next_iter_count_ext >= (ITER_W + 1)'(I_MAX));
  assign c2v_col_h_block_idx = H_BLOCK_W'(int'(c2v_col_idx) / R);
  assign decision_ram_access_col_idx = decision_ram_we ? decision_ram_col_idx : i_e_read_col_idx;

  always_comb begin
    integer lane_idx;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      syndrome_read_row_idx[lane_idx] = c2v_row_idx_global[lane_idx];
    end
  end

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    integer h_block_idx;
    integer group_idx;

    for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        ram_i_debug_count[h_block_idx][group_idx] = ram_i_bank_debug_count[group_idx][h_block_idx];
      end
    end
  end
`endif

  // Keep c2v/v2c slot counters on a fixed-depth schedule.
  always_comb begin
    integer lane_idx;

    c2v_entry_pos_last = ((int'(c2v_entry_pos) + 1) >= RAM_LANE_DEPTH);

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      ram_i_read_entry_addr[lane_idx] = c2v_entry_pos;
    end

    v2c_entry_pos_last = ((int'(v2c_entry_pos) + 1) >= RAM_LANE_DEPTH);
  end

  logic c2v_schedule_complete;

  // Decode first-column RAM-I entries into row-bank issue lanes. The scheduler
  // keeps a per-column issued mask, so each cycle selects only the next slot.
  always_comb begin
    integer                        edge_count;
    integer                        edge_idx;
    integer                        issue_lane_idx;
    integer                        lane_idx;
    integer                        prev_lane_idx;
    integer                        source_entry_idx;
    integer                        source_lane_idx;
    logic   [         ROW_IDX_W:0] row_idx_sum;
    logic   [       H_BLOCK_W-1:0] c2v_read_h_block_idx;
    logic   [       ROW_IDX_W-1:0] base_row_idx_global;
    logic   [       ROW_IDX_W-1:0] c2v_col_idx_local;
    logic   [       ROW_IDX_W-1:0] edge_row_idx_global[0:W-1];
    logic   [       ONE_IDX_W-1:0] edge_one_idx[0:W-1];
    logic   [       EDGE_ID_W-1:0] edge_id[0:W-1];
    logic   [M_ROW_BANK_IDX_W-1:0] edge_bank_idx[0:W-1];
    logic   [M_ROW_BANK_IDX_W-1:0] slot_bank_idx[0:L-1];
    logic   [       I_ENTRY_W-1:0] active_entry;
    logic                          bank_conflict;
    logic                          edge_issued_base[0:W-1];
    logic                          edge_valid[0:W-1];
    logic                          source_valid;

    row_idx_sum = '0;
    base_row_idx_global = '0;
    c2v_col_idx_local = ROW_IDX_W'(int'(c2v_read_col_d1) % R);
    c2v_read_h_block_idx = H_BLOCK_W'(int'(c2v_read_col_d1) / R);
    active_entry = '0;
    source_valid = 1'b0;
    edge_count = 0;
    c2v_schedule_complete = 1'b1;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      slot_bank_idx[lane_idx] = '0;
      c2v_group_valid[lane_idx] = 1'b0;
      c2v_row_idx_global[lane_idx] = '0;
      c2v_one_idx[lane_idx] = '0;
      c2v_edge_id[lane_idx] = '0;
    end

    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      edge_valid[edge_idx] = 1'b0;
      edge_issued_base[edge_idx] =
        (c2v_read_entry_pos_d1 == '0) ? 1'b0 : c2v_sched_issued[edge_idx];
      c2v_sched_issued_next[edge_idx] = edge_issued_base[edge_idx];
      edge_row_idx_global[edge_idx] = '0;
      edge_one_idx[edge_idx] = '0;
      edge_id[edge_idx] = '0;
      edge_bank_idx[edge_idx] = '0;
    end

    for (source_lane_idx = 0; source_lane_idx < L; source_lane_idx++) begin
      for (source_entry_idx = 0; source_entry_idx < RAM_LANE_DEPTH; source_entry_idx++) begin
        source_valid =
          c2v_read_d1 &&
          (source_entry_idx < int'(ram_i_list_counts[source_lane_idx][c2v_read_h_block_idx]));
        active_entry = ram_i_list_entries[source_lane_idx][c2v_read_h_block_idx][source_entry_idx];
        base_row_idx_global = active_entry[I_ENTRY_ROW_IDX_GLOBAL_LSB+:ROW_IDX_W];
        row_idx_sum = {1'b0, base_row_idx_global} + {1'b0, c2v_col_idx_local};

        if (source_valid) begin
          if (edge_count < W) begin
            edge_valid[edge_count] = 1'b1;
            edge_row_idx_global[edge_count] =
              (row_idx_sum >= (ROW_IDX_W + 1)'(R)) ? ROW_IDX_W'(row_idx_sum - (ROW_IDX_W + 1)'(R)) :
              ROW_IDX_W'(row_idx_sum);
            edge_one_idx[edge_count] = ONE_IDX_W'(source_entry_idx * L + source_lane_idx);
            edge_id[edge_count] =
              EDGE_ID_W'(int'(c2v_read_h_block_idx) * W + source_entry_idx * L +
                         source_lane_idx);
            edge_bank_idx[edge_count] = row_bank(edge_row_idx_global[edge_count]);
            edge_count = edge_count + 1;
          end
        end
      end
    end

    issue_lane_idx = 0;
    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      bank_conflict = 1'b0;
      for (prev_lane_idx = 0; prev_lane_idx < L; prev_lane_idx++) begin
        if ((prev_lane_idx < issue_lane_idx) &&
            (slot_bank_idx[prev_lane_idx] == edge_bank_idx[edge_idx])) begin
          bank_conflict = 1'b1;
        end
      end

      if (edge_valid[edge_idx] && !edge_issued_base[edge_idx] && (issue_lane_idx < L) &&
          !bank_conflict) begin
        c2v_group_valid[issue_lane_idx] = 1'b1;
        c2v_row_idx_global[issue_lane_idx] = edge_row_idx_global[edge_idx];
        c2v_one_idx[issue_lane_idx] = edge_one_idx[edge_idx];
        c2v_edge_id[issue_lane_idx] = edge_id[edge_idx];
        slot_bank_idx[issue_lane_idx] = edge_bank_idx[edge_idx];
        c2v_sched_issued_next[edge_idx] = 1'b1;
        issue_lane_idx = issue_lane_idx + 1;
      end
    end

    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      if (c2v_read_entry_pos_last_d1 && edge_valid[edge_idx] &&
          !c2v_sched_issued_next[edge_idx]) begin
        c2v_schedule_complete = 1'b0;
      end
    end

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      v2c_group_valid[lane_idx] =
        (int'(v2c_entry_pos) < int'(col_meta_slot_count[active_meta_slot])) &&
        col_meta_lane_valid[active_meta_slot][lane_idx][v2c_entry_pos];
      v2c_row_idx_global[lane_idx] = col_meta_lane_entries[active_meta_slot][lane_idx][v2c_entry_pos];
      v2c_one_idx[lane_idx] = col_meta_lane_one_idx[active_meta_slot][lane_idx][v2c_entry_pos];
      v2c_edge_id[lane_idx] = col_meta_lane_edge_id[active_meta_slot][lane_idx][v2c_entry_pos];
      if (!v2c_group_valid[lane_idx]) begin
        v2c_row_idx_global[lane_idx] = '0;
        v2c_one_idx[lane_idx] = '0;
        v2c_edge_id[lane_idx] = '0;
      end
    end
  end

  // RAM-M port steering for the single-cycle read/write windows requested by
  // the controller.
  always_comb begin
    integer pair_idx;
    integer lane_idx;

    for (pair_idx = 0; pair_idx < 2; pair_idx++) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        m_pair_read_valid[pair_idx][lane_idx] = 1'b0;
        m_pair_read_row_idx_global[pair_idx][lane_idx] = '0;
        m_pair_we[pair_idx][lane_idx] = 1'b0;
        m_pair_write_row_idx_global[pair_idx][lane_idx] = '0;
        m_pair_wdata[pair_idx][lane_idx] = COMP_C2V_INIT;
      end
    end

    if (c2v_read_d1) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_group_valid[lane_idx]) begin
          m_pair_read_valid[c2v_read_ram_m_pair_sel_d1][lane_idx] = 1'b1;
          m_pair_read_row_idx_global[c2v_read_ram_m_pair_sel_d1][lane_idx] =
            c2v_row_idx_global[lane_idx];
        end
      end
    end

    if (v2c_read) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (v2c_group_valid[lane_idx]) begin
          m_pair_read_valid[ram_m_write_pair_sel][lane_idx] = 1'b1;
          m_pair_read_row_idx_global[ram_m_write_pair_sel][lane_idx] = v2c_row_idx_global[lane_idx];
        end
      end
    end

    if (cnu_a_writeback) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (cnu_a_valid[lane_idx] && v2c_m_latched_group_valid[lane_idx]) begin
          m_pair_we[v2c_m_latched_ram_m_pair_sel][lane_idx] = 1'b1;
          m_pair_write_row_idx_global[v2c_m_latched_ram_m_pair_sel][lane_idx] =
            v2c_m_latched_row_idx_global[lane_idx];
          m_pair_wdata[v2c_m_latched_ram_m_pair_sel][lane_idx] = cnu_a_comp_out[lane_idx];
        end
      end
    end
  end

  // Decision RAM steering for hard decisions.
  always_comb begin
    decision_ram_we = 1'b0;
    decision_ram_col_idx = v2c_col_idx;
    decision_ram_wdata = 1'b0;

    if (decision_write) begin
      decision_ram_we = 1'b1;
      decision_ram_col_idx = v2c_col_idx;
      decision_ram_wdata = vnu_bit_out;
    end
  end

  // Pipeline latches that bridge single-port memory timing and the multi-cycle
  // control schedule. c2v captures decoded RAM-I metadata, stores it in the
  // next metadata slot, and keeps the RAM-M pair selection alongside the edge.
  // v2c captures the RAM-M writeback address one cycle before CNU_A returns.
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer edge_idx;
    integer idx;
    integer lane_idx;

    if (!i_rst_n) begin
      active_meta_slot <= 1'b0;
      next_meta_slot <= 1'b1;
      c2v_read_d1 <= 1'b0;
      c2v_read_col_d1 <= '0;
      c2v_read_entry_pos_d1 <= '0;
      c2v_read_entry_pos_last_d1 <= 1'b0;
      c2v_read_ram_m_pair_sel_d1 <= 1'b0;
      c2v_read_meta_slot_d1 <= 1'b0;
      v2c_read_col_d1 <= '0;
      v2c_read_entry_pos_d1 <= '0;
      v2c_read_ram_m_pair_sel_d1 <= 1'b0;
      col_meta_slot_count[0] <= '0;
      col_meta_slot_count[1] <= '0;
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        c2v_sched_issued[edge_idx] <= 1'b0;
      end
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        v2c_read_group_valid_d1[lane_idx] <= 1'b0;
        v2c_read_row_idx_global_d1[lane_idx] <= '0;
        v2c_read_one_idx_d1[lane_idx] <= '0;
        v2c_read_edge_id_d1[lane_idx] <= '0;
        c2v_latched_group_valid[lane_idx] <= 1'b0;
        c2v_latched_one_idx[lane_idx] <= '0;
        c2v_latched_edge_id[lane_idx] <= '0;
        v2c_m_latched_group_valid[lane_idx] <= 1'b0;
        v2c_m_latched_row_idx_global[lane_idx] <= '0;
        v2c_m_latched_one_idx[lane_idx] <= '0;
        for (idx = 0; idx < RAM_LANE_DEPTH; idx++) begin
          col_meta_lane_valid[0][lane_idx][idx]   <= 1'b0;
          col_meta_lane_valid[1][lane_idx][idx]   <= 1'b0;
          col_meta_lane_entries[0][lane_idx][idx] <= '0;
          col_meta_lane_entries[1][lane_idx][idx] <= '0;
          col_meta_lane_one_idx[0][lane_idx][idx] <= '0;
          col_meta_lane_one_idx[1][lane_idx][idx] <= '0;
          col_meta_lane_edge_id[0][lane_idx][idx] <= '0;
          col_meta_lane_edge_id[1][lane_idx][idx] <= '0;
        end
      end
      c2v_latched_entry_pos <= '0;
      c2v_latched_entry_pos_last <= 1'b0;
      c2v_latched_ram_m_pair_sel <= 1'b0;
      v2c_m_latched_entry_pos <= '0;
      v2c_m_latched_col <= '0;
      v2c_m_latched_ram_m_pair_sel <= 1'b0;
    end else begin
      c2v_read_d1 <= c2v_read;
      if (c2v_read) begin
        c2v_read_col_d1 <= c2v_col_idx;
        c2v_read_entry_pos_d1 <= c2v_entry_pos;
        c2v_read_entry_pos_last_d1 <= c2v_entry_pos_last;
        c2v_read_ram_m_pair_sel_d1 <= ram_m_read_pair_sel;
        c2v_read_meta_slot_d1 <= next_meta_slot;
      end

      if (v2c_read) begin
        v2c_read_col_d1 <= v2c_col_idx;
        v2c_read_entry_pos_d1 <= v2c_entry_pos;
        v2c_read_ram_m_pair_sel_d1 <= ram_m_write_pair_sel;
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_read_group_valid_d1[lane_idx] <= v2c_group_valid[lane_idx];
          v2c_read_row_idx_global_d1[lane_idx] <= v2c_row_idx_global[lane_idx];
          v2c_read_one_idx_d1[lane_idx] <= v2c_one_idx[lane_idx];
          v2c_read_edge_id_d1[lane_idx] <= v2c_edge_id[lane_idx];
        end
      end

      if (c2v_read_d1) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          c2v_sched_issued[edge_idx] <= c2v_sched_issued_next[edge_idx];
        end
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          c2v_latched_group_valid[lane_idx] <= c2v_group_valid[lane_idx];
          c2v_latched_one_idx[lane_idx] <= c2v_one_idx[lane_idx];
          c2v_latched_edge_id[lane_idx] <= c2v_edge_id[lane_idx];
          col_meta_lane_valid[c2v_read_meta_slot_d1][lane_idx][c2v_read_entry_pos_d1] <=
            c2v_group_valid[lane_idx];
          col_meta_lane_entries[c2v_read_meta_slot_d1][lane_idx][c2v_read_entry_pos_d1] <=
            c2v_row_idx_global[lane_idx];
          col_meta_lane_one_idx[c2v_read_meta_slot_d1][lane_idx][c2v_read_entry_pos_d1] <=
            c2v_one_idx[lane_idx];
          col_meta_lane_edge_id[c2v_read_meta_slot_d1][lane_idx][c2v_read_entry_pos_d1] <=
            c2v_edge_id[lane_idx];
        end
        c2v_latched_entry_pos <= c2v_read_entry_pos_d1;
        c2v_latched_entry_pos_last <= c2v_read_entry_pos_last_d1;
        c2v_latched_ram_m_pair_sel <= c2v_read_ram_m_pair_sel_d1;
        if (c2v_read_entry_pos_last_d1) begin
          col_meta_slot_count[c2v_read_meta_slot_d1] <= GROUP_COUNT_W'(RAM_LANE_DEPTH);
        end
      end

      if (col_k_meta_advance) begin
        col_meta_slot_count[next_meta_slot] <= GROUP_COUNT_W'(RAM_LANE_DEPTH);
        active_meta_slot <= next_meta_slot;
        next_meta_slot <= active_meta_slot;
      end

      if (v2c_emit_to_cnu_a) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_m_latched_group_valid[lane_idx] <= v2c_read_group_valid_d1[lane_idx];
          v2c_m_latched_row_idx_global[lane_idx] <= v2c_read_row_idx_global_d1[lane_idx];
          v2c_m_latched_one_idx[lane_idx] <= v2c_read_one_idx_d1[lane_idx];
        end
        v2c_m_latched_entry_pos <= v2c_read_entry_pos_d1;
        v2c_m_latched_col <= v2c_read_col_d1;
        v2c_m_latched_ram_m_pair_sel <= v2c_read_ram_m_pair_sel_d1;
      end

    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      m_pair_epoch[0] <= 1'b0;
      m_pair_epoch[1] <= 1'b0;
    end else begin
      if (i_start) begin
        m_pair_epoch[1] <= ~m_pair_epoch[1];
      end
      if (merge_done) begin
        m_pair_epoch[ram_m_read_pair_sel] <= ~m_pair_epoch[ram_m_read_pair_sel];
      end
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (c2v_read_d1 && !c2v_schedule_complete) begin
      $fatal(1, "decoder_top row-bank schedule overflow");
    end
  end
`endif

  always_comb begin
    integer lane_idx;
    logic   port_pair;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      t_metadata_rvalid[lane_idx] = v2c_read_group_valid_d1[lane_idx];
      port_pair = v2c_read_ram_m_pair_sel_d1;
      cnu_a_comp_in[lane_idx] = m_write_comp_or_init(port_pair, LANE_IDX_W'(lane_idx));
      cnu_a_en[lane_idx] = v2c_emit_to_cnu_a && v2c_read_group_valid_d1[lane_idx];
      cnu_a_v2c_msg[lane_idx] = vnu_v2c_msg[lane_idx];
      cnu_a_edge_id[lane_idx] = v2c_read_edge_id_d1[lane_idx];
    end
  end

  always_comb begin
    integer lane_idx;
    logic   port_pair;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      port_pair = c2v_latched_ram_m_pair_sel;
      cnu_b_comp_in[lane_idx] =
          m_read_comp_or_first(port_pair, LANE_IDX_W'(lane_idx), (o_iter_count == '0));
    end
  end

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane_cnu_a
    cnu_a u_cnu_a (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(cnu_a_en[lane_idx]),
        .i_v2c_msg(cnu_a_v2c_msg[lane_idx]),
        .i_edge_id(cnu_a_edge_id[lane_idx]),
        .i_comp_c2v(cnu_a_comp_in[lane_idx]),
        .o_comp_c2v(cnu_a_comp_out[lane_idx]),
        .o_sign(cnu_a_sign[lane_idx]),
        .o_valid(cnu_a_valid[lane_idx])
    );
  end

  ram_syndrome u_syndrome_ram (
      .i_clk(i_clk),
      .i_we(i_syndrome_we),
      .i_write_row_idx(i_syndrome_addr),
      .i_wdata(i_syndrome_wdata),
      .i_read_valid(c2v_group_valid),
      .i_read_row_idx(syndrome_read_row_idx),
      .o_rdata(syndrome_rdata)
  );

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane_cnu_b
    cnu_b u_cnu_b (
        .i_comp_c2v(cnu_b_comp_in[lane_idx]),
        .i_v2c_sign((o_iter_count == '0) ? 1'b0 : s_rdata[lane_idx]),
        .i_syndrome_bit(syndrome_rdata[lane_idx]),
        .i_edge_id(c2v_latched_edge_id[lane_idx]),
        .o_c2v_msg(c2v_msg[lane_idx])
    );

    msg_signmag_to_tc #(
        .D(D),
        .MSG_W(MSG_W),
        .MSG_MAG_LSB(MSG_MAG_LSB),
        .MSG_SIGN_BIT(MSG_SIGN_BIT)
    ) u_c2v_tc_codec (
        .i_msg(c2v_msg[lane_idx]),
        .o_tc (c2v_tc[lane_idx])
    );
  end

  edge_message_pipe u_edge_message_pipe (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_start(i_start),
      .i_c2v_write_t(c2v_write_t),
      .i_v2c_emit_to_cnu_a(v2c_emit_to_cnu_a),
      .i_vnu_accum_t(vnu_accum_t),
      .i_cnu_a_writeback(cnu_a_writeback),
      .i_c2v_col_idx(c2v_col_idx),
      .i_c2v_read_col_d1(c2v_read_col_d1),
      .i_c2v_read_d1(c2v_read_d1),
      .i_v2c_read(v2c_read),
      .i_v2c_entry_pos(v2c_entry_pos),
      .i_v2c_read_entry_pos_d1(v2c_read_entry_pos_d1),
      .i_c2v_latched_entry_pos(c2v_latched_entry_pos),
      .i_c2v_latched_entry_pos_last(c2v_latched_entry_pos_last),
      .i_c2v_latched_one_idx(c2v_latched_one_idx),
      .i_v2c_m_latched_col(v2c_m_latched_col),
      .i_v2c_m_latched_entry_pos(v2c_m_latched_entry_pos),
      .i_v2c_m_latched_one_idx(v2c_m_latched_one_idx),
      .i_v2c_m_latched_group_valid(v2c_m_latched_group_valid),
      .i_c2v_latched_group_valid(c2v_latched_group_valid),
      .i_col_meta_slot_count(col_meta_slot_count[active_meta_slot]),
      .i_cnu_a_valid(cnu_a_valid),
      .i_cnu_a_sign(cnu_a_sign),
      .i_c2v_tc(c2v_tc),
      .i_s_col_rdata(s_col_rdata),
      .i_t_rvalid(t_metadata_rvalid),
      .i_t_rdata(t_rdata),
      .o_s_rdata(s_rdata),
      .o_s_col_we(s_col_we),
      .o_s_read_col_idx(s_read_col_idx),
      .o_s_write_col_idx(s_write_col_idx),
      .o_s_col_wdata(s_col_wdata),
      .o_t_push(t_push),
      .o_t_pop(t_pop),
      .o_t_valid(t_valid),
      .o_t_write_entry_idx(t_write_entry_idx),
      .o_t_read_entry_idx(t_read_entry_idx),
      .o_t_wdata(t_wdata),
      .o_vnu_col_start(vnu_col_start),
      .o_vnu_col_end(vnu_col_end),
      .o_vnu_accum_valid(vnu_accum_valid),
      .o_vnu_prev_c2v_valid(vnu_prev_c2v_valid),
      .o_vnu_prev_c2v(vnu_prev_c2v)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  // Open observation pins keep focused module benches able to inspect the
  // submodules while this top-level uses the data-bearing outputs.
  vnu #(
      .W(W),
      .D(D),
      .MSG_W(MSG_W),
      .L(L),
      .ALPHA_FRAC_W(ALPHA_FRAC_W),
      .ALPHA_SHIFT_0(ALPHA_SHIFT_0),
      .ALPHA_SHIFT_1(ALPHA_SHIFT_1),
      .VNU_TC_W(VNU_TC_W)
  ) u_vnu (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_col_start(vnu_col_start),
      .i_col_end(vnu_col_end),
      .i_finalize(vnu_finalize),
      .i_initial_llr($signed(MSG_W'(C_VAL))),
      .i_c2v_valid(vnu_accum_valid),
      .i_c2v(c2v_tc),
      .o_c2v_t_valid(),
      .o_c2v_t(),
      .o_bit_decision(vnu_bit_out),
      .i_c2v_t_valid(vnu_prev_c2v_valid),
      .i_c2v_t(vnu_prev_c2v),
      .o_v2c_valid(),
      .o_v2c(vnu_v2c_tc)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane_v2c_codec
    msg_tc_to_signmag_sat #(
        .D(D),
        .MSG_W(MSG_W),
        .VNU_TC_W(VNU_TC_W),
        .MAG_MAX(MAG_MAX)
    ) u_vnu_v2c_msg_codec (
        .i_tc (vnu_v2c_tc[lane_idx]),
        .o_msg(vnu_v2c_msg[lane_idx])
    );
  end

  decoder_ctrl u_decoder_ctrl (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_start(i_start),
      .i_finish_decode(finish_decode),
      .i_c2v_entry_pos_last(c2v_entry_pos_last),
      .i_v2c_entry_pos_last(v2c_entry_pos_last),
      .o_state(state),
      .o_work_col_idx(work_col_idx),
      .o_work_entry_pos(work_entry_pos),
      .o_c2v_col_idx(c2v_col_idx),
      .o_v2c_col_idx(v2c_col_idx),
      .o_c2v_entry_pos(c2v_entry_pos),
      .o_v2c_entry_pos(v2c_entry_pos),
      .o_active_entry_pos(active_entry_pos),
      .o_ram_m_read_pair_sel(ram_m_read_pair_sel),
      .o_ram_m_write_pair_sel(ram_m_write_pair_sel),
      .o_c2v_read(c2v_read),
      .o_v2c_read(v2c_read),
      .o_c2v_write_t(c2v_write_t),
      .o_vnu_accum_t(vnu_accum_t),
      .o_vnu_finalize(vnu_finalize),
      .o_decision_write(decision_write),
      .o_v2c_emit_to_cnu_a(v2c_emit_to_cnu_a),
      .o_cnu_a_writeback(cnu_a_writeback),
      .o_iter_check(iter_check),
      .o_merge_read(merge_read_unused),
      .o_merge_write(merge_write_unused),
      .o_merge_done(merge_done),
      .o_merge_row_idx(merge_row_idx_unused),
      .o_col_k_meta_advance(col_k_meta_advance),
      .o_c2v_pipe_valid(c2v_phase_active),
      .o_v2c_pipe_valid(v2c_phase_active),
      .o_c2v_v2c_overlap_seen(c2v_v2c_overlap_seen),
      .o_done(o_done),
      .o_iter_count(o_iter_count)
  );

  ram_i_idx_loader u_ram_i_idx_loader (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_start(i_h_load_start),
      .i_valid(i_h_load_valid),
      .i_row_idx_global(i_h_load_row_idx_global),
      .o_ready(o_h_load_ready),
      .o_busy(o_h_load_busy),
      .o_done(o_h_load_done),
      .o_request_h_block_idx(o_h_load_request_h_block_idx),
      .o_request_entry_pos(o_h_load_request_entry_pos),
      .o_lane_we(ram_i_load_lane_we),
      .o_write_h_block_idx(ram_i_load_write_h_block_idx),
      .o_write_entry_idx(ram_i_load_write_entry_idx),
      .o_entry_wdata(ram_i_load_entry_wdata),
      .o_count_we(ram_i_load_count_we),
      .o_count_wdata(ram_i_load_count_wdata)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  for (genvar ram_i_bank_idx = 0; ram_i_bank_idx < L; ram_i_bank_idx++) begin : g_ram_i
    ram_i #(
        .INIT_HEX_STEM(""),
        .INIT_HEX_PREFIX(RAM_I_HEX_PREFIX),
        .BANK_IDX(ram_i_bank_idx),
        .INIT_HEX_TAG(RAM_I_HEX_TAG)
    ) u_ram_i (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_we(ram_i_load_lane_we[ram_i_bank_idx]),
        .i_read_h_block_idx(c2v_col_h_block_idx),
        .i_write_h_block_idx(ram_i_load_write_h_block_idx),
        .i_read_entry_idx(ram_i_read_entry_addr[ram_i_bank_idx]),
        .i_write_entry_idx(ram_i_load_write_entry_idx),
        .i_entry_wdata(ram_i_load_entry_wdata[ram_i_bank_idx]),
        .i_count_we(ram_i_load_count_we[ram_i_bank_idx]),
        .i_count_wdata(ram_i_load_count_wdata[ram_i_bank_idx]),
        .o_entry_rdata(),
`ifdef BIKE_SIM_DEBUG
        .o_count(),
        .o_list_entries(ram_i_list_entries[ram_i_bank_idx]),
        .o_list_counts(ram_i_list_counts[ram_i_bank_idx]),
        .o_debug_list_entries(),
        .o_debug_counts(ram_i_bank_debug_count[ram_i_bank_idx])
`else
        .o_count(),
        .o_list_entries(ram_i_list_entries[ram_i_bank_idx]),
        .o_list_counts(ram_i_list_counts[ram_i_bank_idx])
`endif
    );
  end

  ram_c u_decision_ram (
      .i_clk(i_clk),
      .i_we(decision_ram_we),
      .i_col_idx(decision_ram_access_col_idx),
      .i_wdata(decision_ram_wdata),
      .o_rdata(decision_ram_old_bit)
  );

  assign o_e_rdata = decision_ram_old_bit;

  for (genvar ram_m_pair_idx = 0; ram_m_pair_idx < 2; ram_m_pair_idx++) begin : g_ram_m_pair
    ram_m_bank_array u_ram_m_pair (
        .i_clk(i_clk),
        .i_read_valid(m_pair_read_valid[ram_m_pair_idx]),
        .i_read_row_idx_global(m_pair_read_row_idx_global[ram_m_pair_idx]),
        .i_we(m_pair_we[ram_m_pair_idx]),
        .i_write_row_idx_global(m_pair_write_row_idx_global[ram_m_pair_idx]),
        .i_epoch(m_pair_epoch[ram_m_pair_idx]),
        .i_wdata(m_pair_wdata[ram_m_pair_idx]),
        .o_rdata(m_pair_rdata[ram_m_pair_idx]),
        .o_epoch(m_pair_repoch[ram_m_pair_idx])
    );
  end

  ram_s u_ram_s (
      .i_clk(i_clk),
      .i_we(s_col_we),
      .i_read_col_idx(s_read_col_idx),
      .i_write_col_idx(s_write_col_idx),
      .i_wdata(s_col_wdata),
`ifdef BIKE_SIM_DEBUG
      .o_rdata(s_col_rdata),
      .o_debug_mem()
`else
      .o_rdata(s_col_rdata)
`endif
  );

  for (genvar ram_t_lane_idx = 0; ram_t_lane_idx < L; ram_t_lane_idx++) begin : g_ram_t
    ram_t #(
        .TRACK_VALID(1'b0)
    ) u_ram_t (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_clear(iter_check),
        .i_push(t_push[ram_t_lane_idx]),
        .i_pop(t_pop[ram_t_lane_idx]),
        .i_write_entry_idx(t_write_entry_idx),
        .i_read_entry_idx(t_read_entry_idx),
        .i_valid(t_valid[ram_t_lane_idx]),
        .i_wdata(t_wdata[ram_t_lane_idx]),
        .o_rdata(t_rdata[ram_t_lane_idx]),
`ifdef BIKE_SIM_DEBUG
        .o_valid(),
        .o_item_count(ram_t_debug_item_count[ram_t_lane_idx]),
        .o_debug_mem()
`else
        .o_valid()
`endif
    );
  end
  /* verilator lint_on PINCONNECTEMPTY */
endmodule
