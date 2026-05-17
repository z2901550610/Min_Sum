`timescale 1ns / 1ps
// Top-level BIKE min-sum decoder datapath and module interconnect.
module decoder_top
  import bike_pkg::*;
#(
    parameter string RAM_I_HEX_PREFIX = "rtl/generated/ram_i",
`ifndef BIKE_TOY_PARAMS
    parameter string RAM_I_HEX_TAG    = "_l1"
`else
    parameter string RAM_I_HEX_TAG    = "_test"
`endif
) (
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_start,
    input  logic                 i_syndrome_we,
    input  logic [ROW_IDX_W-1:0] i_syndrome_addr,
    input  logic                 i_syndrome_wdata,
    input  logic [    COL_W-1:0] i_e_read_col_idx,
    output logic                 o_done,
    output logic                 o_success,
    output logic                 o_e_rdata,
    output logic [   ITER_W-1:0] o_iter_count
);

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
  logic [            R-1:0] syndrome_hist[0:I_MAX-1];
  logic [GROUP_COUNT_W-1:0] ram_i_debug_count[   0:N0-1] [0:B-1];
`endif
  /* verilator lint_on UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] ram_i_entry_rdata[0:B-1];
  logic [GROUP_COUNT_W-1:0] ram_i_count[0:B-1];

  logic m_read_pair;
  logic m_write_pair;

  logic c2v_read;
  logic v2c_read;
  logic c2v_write_t;
  logic vnu_accum_t;
  logic vnu_prep_write;
  logic vnu_cnu_a;
  logic vnu_write_next;
  logic iter_check;

  // Column metadata in the c2v path. The active column comes from RAM-I,
  // while the v2c side keeps its own buffered copies so c2v can stay one
  // column ahead.
  logic [H_BLOCK_W-1:0] c2v_h_block_idx;
  logic col_k_meta_slot;
  logic col_kp1_meta_slot;
  logic [GROUP_COUNT_W-1:0] col_meta_slot_count[0:1];
  logic col_meta_lane_valid[0:1][0:L-1][0:RAM_LANE_DEPTH-1];
  logic [GROUP_IDX_W-1:0] col_meta_lane_group_idx[0:1][0:L-1][0:RAM_LANE_DEPTH-1];
  logic [I_ENTRY_W-1:0] col_meta_lane_entries[0:1][0:L-1][0:RAM_LANE_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] ram_i_read_ptr[0:B-1];
  logic [GROUP_COUNT_W-1:0] ram_i_read_ptr_next[0:B-1];
  logic [ENTRY_POS_W-1:0] ram_i_read_entry_addr[0:B-1];
  logic c2v_sched_group_valid[0:L-1];
  logic [GROUP_IDX_W-1:0] c2v_sched_group_idx[0:L-1];
  logic c2v_sched_group_valid_d1[0:L-1];
  logic [GROUP_IDX_W-1:0] c2v_sched_group_idx_d1[0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_write_ptr[0:B-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_write_ptr_next[0:B-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_commit_count[0:B-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_count_wdata[0:B-1];
  logic [GROUP_IDX_W-1:0] h_shift_group_idx_in[0:L-1];
  logic [ROW_GROUP_W-1:0] h_shift_row_idx_group_in[0:L-1];
  logic [GROUP_IDX_W-1:0] shifted_group_idx[0:L-1];
  logic [ROW_GROUP_W-1:0] shifted_row_idx_group[0:L-1];
  logic shifted_valid[0:L-1];
  logic shift_ram_i;
  logic shift_ram_i_last;
  logic ram_i_shift_ready;
  logic ram_i_shift_commit_pending;
  logic ram_i_shift_commit_pending_next;
  logic ram_i_shift_count_we;
  logic [SHIFT_PENDING_COUNT_W-1:0] ram_i_shift_pending_count[0:B-1];
  logic [SHIFT_PENDING_COUNT_W-1:0] ram_i_shift_pending_count_next[0:B-1];
  logic [ENTRY_POS_W-1:0] ram_i_shift_pending_addr[0:B-1][0:SHIFT_PENDING_DEPTH-1];
  logic [ENTRY_POS_W-1:0] ram_i_shift_pending_addr_next[0:B-1][0:SHIFT_PENDING_DEPTH-1];
  logic [I_ENTRY_W-1:0] ram_i_shift_pending_wdata[0:B-1][0:SHIFT_PENDING_DEPTH-1];
  logic [I_ENTRY_W-1:0] ram_i_shift_pending_wdata_next[0:B-1][0:SHIFT_PENDING_DEPTH-1];
  logic ram_i_shift_we[0:B-1];
  logic [ENTRY_POS_W-1:0] ram_i_shift_entry_addr[0:B-1];
  logic [I_ENTRY_W-1:0] ram_i_shift_entry_wdata[0:B-1];
  logic c2v_read_d1;
  logic [COL_W-1:0] c2v_read_col_d1;
  logic [ENTRY_POS_W-1:0] c2v_read_entry_pos_d1;
  logic c2v_read_entry_pos_last_d1;
  logic c2v_read_m_read_pair_d1;
  logic c2v_entry_pos_last;
  logic v2c_entry_pos_last;

  // Per-edge decoded metadata used to address RAM-M/S/T.
  logic c2v_group_valid[0:L-1];
  logic [GROUP_IDX_W-1:0] c2v_group_idx[0:L-1];
  logic [ONE_IDX_W-1:0] c2v_one_idx[0:L-1];
  logic [ROW_GROUP_W-1:0] c2v_row_idx_group[0:L-1];
  logic [ROW_IDX_W-1:0] c2v_row_idx_global[0:L-1];
  logic v2c_group_valid[0:L-1];
  logic [GROUP_IDX_W-1:0] v2c_group_idx[0:L-1];
  logic [ROW_GROUP_W-1:0] v2c_row_idx_group[0:L-1];

  logic c2v_latched_group_valid[0:L-1];
  logic [GROUP_IDX_W-1:0] c2v_latched_group_idx[0:L-1];
  logic [ONE_IDX_W-1:0] c2v_latched_one_idx[0:L-1];
  logic [ROW_GROUP_W-1:0] c2v_latched_row_idx_group[0:L-1];
  logic [ENTRY_POS_W-1:0] c2v_latched_entry_pos;
  logic c2v_latched_entry_pos_last;
  logic [COL_W-1:0] c2v_latched_col;
  logic c2v_latched_m_read_pair;

  logic v2c_m_latched_group_valid[0:L-1];
  logic [GROUP_IDX_W-1:0] v2c_m_latched_group_idx[0:L-1];
  logic [ROW_GROUP_W-1:0] v2c_m_latched_row_idx_group[0:L-1];
  logic [ENTRY_POS_W-1:0] v2c_m_latched_entry_pos;
  logic [COL_W-1:0] v2c_m_latched_col;
  logic v2c_m_latched_m_write_pair;
  logic [COL_W-1:0] v2c_read_col_d1;
  logic [ENTRY_POS_W-1:0] v2c_read_entry_pos_d1;
  logic v2c_read_m_write_pair_d1;
  logic v2c_read_group_valid_d1[0:L-1];
  logic [GROUP_IDX_W-1:0] v2c_read_group_idx_d1[0:L-1];
  logic [ROW_GROUP_W-1:0] v2c_read_row_idx_group_d1[0:L-1];

  logic decode_success;
  logic finish_decode;
  logic decision_ram_old_bit;
  logic [ITER_W:0] next_iter_count_ext;
`ifdef BIKE_SIM_DEBUG
  logic [HIST_IDX_W-1:0] hist_wr_idx;
`endif

`ifdef BIKE_SIM_DEBUG
  logic [GROUP_COUNT_W-1:0] ram_i_bank_debug_count[0:B-1][0:N0-1];
`endif

  // Paper-style RAM port steering. Each block is single-port, so the top
  // centralizes all enables, addresses, and write data here.
  logic                   m_we[0:M_BANKS-1];
  logic [ROW_GROUP_W-1:0] m_read_row_idx_group[0:M_BANKS-1];
  logic [ROW_GROUP_W-1:0] m_write_row_idx_group[0:M_BANKS-1];
  logic [ COMP_C2V_W-1:0] m_wdata[0:M_BANKS-1];
  logic [ COMP_C2V_W-1:0] m_rdata[0:M_BANKS-1];
  logic                   m_repoch[0:M_BANKS-1];
  logic                   m_pair_epoch[        0:1];
`ifdef BIKE_SIM_DEBUG
  /* verilator lint_off UNUSEDSIGNAL */
  logic [COMP_C2V_W-1:0] ram_m_debug_mem[0:M_BANKS-1][0:ROW_GROUP_DEPTH-1];
  /* verilator lint_on UNUSEDSIGNAL */
`endif

  logic                     s_we[0:L-1];
  logic [        COL_W-1:0] s_read_col_idx[0:L-1];
  logic [  ENTRY_POS_W-1:0] s_read_entry_idx[0:L-1];
  logic [  ENTRY_POS_W-1:0] s_write_entry_idx[0:L-1];
  logic                     s_wdata[0:L-1];
  logic                     s_rdata[0:L-1];
  logic                     s_word_we[0:L-1];
  logic [S_WORD_ADDR_W-1:0] s_read_word_addr[0:L-1];
  logic [S_WORD_ADDR_W-1:0] s_write_word_addr[0:L-1];
  logic [     S_PACK_W-1:0] s_word_wdata[0:L-1];
  logic [     S_PACK_W-1:0] s_word_rdata[0:L-1];
  logic [     S_PACK_W-1:0] s_read_shift[0:L-1];
  logic [     S_PACK_W-1:0] s_write_shift[0:L-1];
  logic                     s_read_word_load_pending[0:L-1];

  logic                     t_push[0:L-1];
  logic                     t_pop[0:L-1];
  logic                     t_valid[0:L-1];
  logic [  ENTRY_POS_W-1:0] t_write_entry_idx;
  logic [  ENTRY_POS_W-1:0] t_read_entry_idx;
  logic [        MSG_W-1:0] t_wdata[0:L-1];
  logic                     t_rvalid[0:L-1];
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

  logic        [     COL_W-1:0] cnu_a_col_idx;
  logic                         cnu_a_en[0:L-1];
  logic        [     MSG_W-1:0] cnu_a_v2c_msg[0:L-1];
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

  function automatic int m_index(input  logic pair, input  logic [GROUP_IDX_W-1:0] group_idx);
    begin
      m_index = (pair ? B : 0) + int'(group_idx);
    end
  endfunction

  task automatic set_m_read_row(input  logic pair, input  logic [GROUP_IDX_W-1:0] group_idx,
                                input  logic [ROW_GROUP_W-1:0] row_idx_group);
    logic [M_BANK_IDX_W-1:0] port_idx;
    begin
      port_idx = M_BANK_IDX_W'(m_index(pair, group_idx));
      m_read_row_idx_group[port_idx] = row_idx_group;
    end
  endtask

  task automatic set_m_write_state(input  logic pair, input  logic [GROUP_IDX_W-1:0] group_idx,
                                   input  logic [ROW_GROUP_W-1:0] row_idx_group,
                                   input  logic [COMP_C2V_W-1:0] comp_c2v);
    logic [M_BANK_IDX_W-1:0] port_idx;
    begin
      port_idx = M_BANK_IDX_W'(m_index(pair, group_idx));
      m_we[port_idx] = 1'b1;
      m_write_row_idx_group[port_idx] = row_idx_group;
      m_wdata[port_idx] = comp_c2v;
    end
  endtask

  task automatic set_s_write_bit(input  logic [LANE_IDX_W-1:0] lane_idx,
                                 input  logic [ENTRY_POS_W-1:0] entry_idx, input  logic sign_bit);
    begin
      s_we[lane_idx] = 1'b1;
      s_write_entry_idx[lane_idx] = entry_idx;
      s_wdata[lane_idx] = sign_bit;
    end
  endtask

  function automatic logic [S_WORD_ADDR_W-1:0] s_word_addr(input  logic [COL_W-1:0] col_idx,
                                                           input  logic [ENTRY_POS_W-1:0] entry_idx);
    begin
      s_word_addr = S_WORD_ADDR_W'(int'(col_idx) * S_WORDS_PER_COL + int'(entry_idx) / S_PACK_W);
    end
  endfunction

  function automatic logic [S_PACK_IDX_W-1:0] s_word_bit_idx(
      input  logic [ENTRY_POS_W-1:0] entry_idx);
    begin
      s_word_bit_idx = S_PACK_IDX_W'(int'(entry_idx) % S_PACK_W);
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] m_write_comp_or_init(
      input  logic [M_BANK_IDX_W-1:0] port_idx);
    begin
      if (m_repoch[port_idx] == m_pair_epoch[(int'(port_idx)>=B)?1 : 0]) begin
        m_write_comp_or_init = m_rdata[port_idx];
      end else begin
        m_write_comp_or_init = COMP_C2V_INIT;
      end
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] m_read_comp_or_first(
      input  logic [M_BANK_IDX_W-1:0] port_idx, input  logic use_first_iter_default);
    begin
      if (use_first_iter_default) begin
        m_read_comp_or_first = FIRST_ITER_C2V_COMP;
      end else begin
        m_read_comp_or_first = m_rdata[port_idx];
      end
    end
  endfunction

  assign next_iter_count_ext = {1'b0, o_iter_count} + {{ITER_W{1'b0}}, 1'b1};
`ifdef BIKE_SIM_DEBUG
  assign hist_wr_idx = o_iter_count[HIST_IDX_W-1:0];
`endif
  assign decode_success = 1'b0;
  assign finish_decode = (next_iter_count_ext >= (ITER_W + 1)'(I_MAX));
  assign c2v_h_block_idx = H_BLOCK_W'(int'(c2v_col_idx) / R);
  assign decision_ram_access_col_idx = decision_ram_we ? decision_ram_col_idx : i_e_read_col_idx;

  always_comb begin
    integer lane_idx;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      syndrome_read_row_idx[lane_idx] = c2v_row_idx_global[lane_idx];
    end
  end

  always_comb begin
    integer lane_idx;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      s_rdata[lane_idx] =
        s_read_word_load_pending[lane_idx] ? s_word_rdata[lane_idx][0] : s_read_shift[lane_idx][0];
    end
  end

  always_comb begin
    integer lane_idx;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      h_shift_group_idx_in[lane_idx] = c2v_latched_group_idx[lane_idx];
      h_shift_row_idx_group_in[lane_idx] = c2v_latched_row_idx_group[lane_idx];
    end
  end

  h_shift #(
      .R(R),
      .L(L),
      .B(B),
      .ROW_IDX_W(ROW_IDX_W),
      .GROUP_IDX_W(GROUP_IDX_W),
      .ROW_GROUP_DEPTH(ROW_GROUP_DEPTH),
      .ROW_GROUP_W(ROW_GROUP_W)
  ) u_h_shift (
      .i_group_idx(h_shift_group_idx_in),
      .i_row_idx_group(h_shift_row_idx_group_in),
      .o_ram_i_target_idx(shifted_group_idx),
      .o_row_idx_group(shifted_row_idx_group)
  );

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    integer h_block_idx;
    integer group_idx;

    for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      for (group_idx = 0; group_idx < B; group_idx++) begin
        ram_i_debug_count[h_block_idx][group_idx] = ram_i_bank_debug_count[group_idx][h_block_idx];
      end
    end
  end
`endif

  // Select up to L non-empty virtual banks for the next c2v issue slot.
  always_comb begin
    integer group_idx;
    integer lane_idx;
    integer selected_count;

    selected_count = 0;
    c2v_entry_pos_last = 1'b1;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_sched_group_valid[lane_idx] = 1'b0;
      c2v_sched_group_idx[lane_idx]   = '0;
    end

    for (group_idx = 0; group_idx < B; group_idx++) begin
      ram_i_read_ptr_next[group_idx]   = ram_i_read_ptr[group_idx];
      ram_i_read_entry_addr[group_idx] = ENTRY_POS_W'(ram_i_read_ptr[group_idx]);
    end

    for (group_idx = 0; group_idx < B; group_idx++) begin
      if ((selected_count < L) &&
          (int'(ram_i_read_ptr[group_idx]) < int'(ram_i_count[group_idx]))) begin
        c2v_sched_group_valid[selected_count] = 1'b1;
        c2v_sched_group_idx[selected_count] = GROUP_IDX_W'(group_idx);
        ram_i_read_entry_addr[group_idx] = ENTRY_POS_W'(ram_i_read_ptr[group_idx]);
        ram_i_read_ptr_next[group_idx] = ram_i_read_ptr[group_idx] + GROUP_COUNT_W'(1);
        selected_count++;
      end
    end

    for (group_idx = 0; group_idx < B; group_idx++) begin
      if (int'(ram_i_read_ptr_next[group_idx]) < int'(ram_i_count[group_idx])) begin
        c2v_entry_pos_last = 1'b0;
      end
    end

    v2c_entry_pos_last = ((int'(v2c_entry_pos) + 1) >= int'(col_meta_slot_count[col_k_meta_slot]));
  end

  // Decode the active packed RAM-I entry into the addresses consumed by the
  // M/S/T memories.
  always_comb begin
    integer                 lane_idx;
    logic   [I_ENTRY_W-1:0] active_entry;

    active_entry = '0;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      active_entry = ram_i_entry_rdata[c2v_sched_group_idx_d1[lane_idx]];
      c2v_group_valid[lane_idx] = c2v_read_d1 && c2v_sched_group_valid_d1[lane_idx];
      c2v_group_idx[lane_idx] = c2v_sched_group_idx_d1[lane_idx];
      c2v_one_idx[lane_idx] = active_entry[I_ENTRY_ONE_IDX_LSB+:ONE_IDX_W];
      c2v_row_idx_group[lane_idx] = active_entry[I_ENTRY_ROW_IDX_GROUP_LSB+:ROW_GROUP_W];
      c2v_row_idx_global[lane_idx] = ROW_IDX_W'(
        int'(c2v_row_idx_group[lane_idx]) * B + int'(c2v_group_idx[lane_idx])
      );
      if (!c2v_group_valid[lane_idx]) begin
        c2v_group_idx[lane_idx] = '0;
        c2v_one_idx[lane_idx] = '0;
        c2v_row_idx_group[lane_idx] = '0;
        c2v_row_idx_global[lane_idx] = '0;
      end

      v2c_group_valid[lane_idx] =
        (int'(v2c_entry_pos) < int'(col_meta_slot_count[col_k_meta_slot])) &&
        col_meta_lane_valid[col_k_meta_slot][lane_idx][v2c_entry_pos];
      v2c_group_idx[lane_idx] = col_meta_lane_group_idx[col_k_meta_slot][lane_idx][v2c_entry_pos];
      v2c_row_idx_group[lane_idx] =
        col_meta_lane_entries[col_k_meta_slot][lane_idx][v2c_entry_pos][I_ENTRY_ROW_IDX_GROUP_LSB +: ROW_GROUP_W];
      if (!v2c_group_valid[lane_idx]) begin
        v2c_group_idx[lane_idx] = '0;
        v2c_row_idx_group[lane_idx] = '0;
      end
    end
  end

  // H shift：使用 RAM-I 单 entry 写口逐项写回下一列 metadata。
  always_comb begin
    integer                             group_idx;
    integer                             lane_idx;
    integer                             pending_idx;
    logic   [          GROUP_IDX_W-1:0] target_idx;
    logic   [            I_ENTRY_W-1:0] shifted_entry;
    logic                               bank_has_write[0:B-1];
    logic   [SHIFT_PENDING_COUNT_W-1:0] enqueue_slot;
    logic   [  SHIFT_PENDING_IDX_W-1:0] enqueue_slot_idx;
    logic                               entries_empty_current;
    logic                               entries_empty_next;

    shift_ram_i = c2v_write_t;
    shift_ram_i_last = shift_ram_i && c2v_latched_entry_pos_last;
    ram_i_shift_commit_pending_next = ram_i_shift_commit_pending;
    ram_i_shift_count_we = 1'b0;
    ram_i_shift_ready = 1'b0;
    target_idx = '0;
    shifted_entry = '0;
    enqueue_slot = '0;
    enqueue_slot_idx = '0;
    entries_empty_current = 1'b1;
    entries_empty_next = 1'b1;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      shifted_valid[lane_idx] = shift_ram_i && c2v_latched_group_valid[lane_idx];
    end

    for (group_idx = 0; group_idx < B; group_idx++) begin
      entries_empty_current = entries_empty_current && (ram_i_shift_pending_count[group_idx] == '0);
      ram_i_shift_write_ptr_next[group_idx] =
        (shift_ram_i && (c2v_latched_entry_pos == '0)) ? '0 : ram_i_shift_write_ptr[group_idx];
      ram_i_shift_count_wdata[group_idx] = ram_i_shift_commit_count[group_idx];
      ram_i_shift_pending_count_next[group_idx] = ram_i_shift_pending_count[group_idx];
      for (pending_idx = 0; pending_idx < SHIFT_PENDING_DEPTH; pending_idx++) begin
        ram_i_shift_pending_addr_next[group_idx][pending_idx] =
          ram_i_shift_pending_addr[group_idx][pending_idx];
        ram_i_shift_pending_wdata_next[group_idx][pending_idx] =
          ram_i_shift_pending_wdata[group_idx][pending_idx];
      end
      ram_i_shift_we[group_idx] = 1'b0;
      ram_i_shift_entry_addr[group_idx] = c2v_latched_entry_pos;
      ram_i_shift_entry_wdata[group_idx] = '0;
      bank_has_write[group_idx] = 1'b0;
    end

    for (group_idx = 0; group_idx < B; group_idx++) begin
      if (ram_i_shift_pending_count[group_idx] != '0) begin
        ram_i_shift_we[group_idx] = 1'b1;
        ram_i_shift_entry_addr[group_idx] = ram_i_shift_pending_addr[group_idx][0];
        ram_i_shift_entry_wdata[group_idx] = ram_i_shift_pending_wdata[group_idx][0];
        ram_i_shift_pending_count_next[group_idx] =
          ram_i_shift_pending_count[group_idx] - SHIFT_PENDING_COUNT_W'(1);
        for (pending_idx = 0; pending_idx < SHIFT_PENDING_DEPTH - 1; pending_idx++) begin
          ram_i_shift_pending_addr_next[group_idx][pending_idx] =
            ram_i_shift_pending_addr[group_idx][pending_idx + 1];
          ram_i_shift_pending_wdata_next[group_idx][pending_idx] =
            ram_i_shift_pending_wdata[group_idx][pending_idx + 1];
        end
        ram_i_shift_pending_addr_next[group_idx][SHIFT_PENDING_DEPTH-1] = '0;
        ram_i_shift_pending_wdata_next[group_idx][SHIFT_PENDING_DEPTH-1] = '0;
        bank_has_write[group_idx] = 1'b1;
      end
    end

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (shifted_valid[lane_idx]) begin
        target_idx = shifted_group_idx[lane_idx];
        shifted_entry = {
          c2v_latched_one_idx[lane_idx], ROW_GROUP_W'(shifted_row_idx_group[lane_idx])
        };

        if (bank_has_write[target_idx]) begin
          enqueue_slot = ram_i_shift_pending_count_next[target_idx];
          enqueue_slot_idx = SHIFT_PENDING_IDX_W'(enqueue_slot);
          if (int'(enqueue_slot) < SHIFT_PENDING_DEPTH) begin
            ram_i_shift_pending_addr_next[target_idx][enqueue_slot_idx] =
              ENTRY_POS_W'(ram_i_shift_write_ptr_next[target_idx]);
            ram_i_shift_pending_wdata_next[target_idx][enqueue_slot_idx] = shifted_entry;
            ram_i_shift_pending_count_next[target_idx] =
              ram_i_shift_pending_count_next[target_idx] + SHIFT_PENDING_COUNT_W'(1);
          end
        end else begin
          ram_i_shift_we[target_idx] = 1'b1;
          ram_i_shift_entry_addr[target_idx] = ENTRY_POS_W'(ram_i_shift_write_ptr_next[target_idx]);
          ram_i_shift_entry_wdata[target_idx] = shifted_entry;
          bank_has_write[target_idx] = 1'b1;
        end

        ram_i_shift_write_ptr_next[target_idx] = ram_i_shift_write_ptr_next[target_idx] + 1'b1;
      end
    end

    if (shift_ram_i_last) begin
      ram_i_shift_commit_pending_next = 1'b1;
      for (group_idx = 0; group_idx < B; group_idx++) begin
        ram_i_shift_count_wdata[group_idx] = ram_i_shift_write_ptr_next[group_idx];
      end
    end

    entries_empty_next = 1'b1;
    for (group_idx = 0; group_idx < B; group_idx++) begin
      entries_empty_next = entries_empty_next && (ram_i_shift_pending_count_next[group_idx] == '0);
    end

    if (ram_i_shift_commit_pending_next && entries_empty_next) begin
      ram_i_shift_count_we = 1'b1;
      ram_i_shift_commit_pending_next = 1'b0;
    end

    ram_i_shift_ready =
      entries_empty_current && entries_empty_next &&
      !ram_i_shift_commit_pending && !ram_i_shift_commit_pending_next;
  end

  // RAM-M steering for compressed c2v state.
  always_comb begin
    integer port_idx;
    integer lane_idx;

    for (port_idx = 0; port_idx < M_BANKS; port_idx++) begin
      m_we[port_idx] = 1'b0;
      m_read_row_idx_group[port_idx] = '0;
      m_write_row_idx_group[port_idx] = '0;
      m_wdata[port_idx] = COMP_C2V_INIT;
    end

    if (c2v_read_d1) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (c2v_group_valid[lane_idx]) begin
          set_m_read_row(c2v_read_m_read_pair_d1, c2v_group_idx[lane_idx],
                         c2v_row_idx_group[lane_idx]);
        end
      end
    end

    if (v2c_read) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (v2c_group_valid[lane_idx]) begin
          set_m_read_row(m_write_pair, v2c_group_idx[lane_idx], v2c_row_idx_group[lane_idx]);
        end
      end
    end

    if (vnu_write_next) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (cnu_a_valid[lane_idx] && v2c_m_latched_group_valid[lane_idx]) begin
          set_m_write_state(v2c_m_latched_m_write_pair, v2c_m_latched_group_idx[lane_idx],
                            v2c_m_latched_row_idx_group[lane_idx], cnu_a_comp_out[lane_idx]);
        end
      end
    end
  end

  // RAM-S steering for v2c sign bits.
  always_comb begin
    integer                    lane_idx;
    logic   [S_PACK_IDX_W-1:0] write_bit_idx;
    logic                      write_lane_last;

    write_bit_idx   = '0;
    write_lane_last = 1'b0;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      s_we[lane_idx] = 1'b0;
      s_read_col_idx[lane_idx] = c2v_read_d1 ? c2v_read_col_d1 : c2v_col_idx;
      s_read_entry_idx[lane_idx] = c2v_read_d1 ? c2v_read_entry_pos_d1 : c2v_entry_pos;
      s_write_entry_idx[lane_idx] = c2v_latched_entry_pos;
      s_wdata[lane_idx] = 1'b0;
      s_word_we[lane_idx] = 1'b0;
      s_read_word_addr[lane_idx] =
          s_word_addr(s_read_col_idx[lane_idx], s_read_entry_idx[lane_idx]);
      s_write_word_addr[lane_idx] = '0;
      s_word_wdata[lane_idx] = '0;
    end

    if (vnu_write_next) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (cnu_a_valid[lane_idx] && v2c_m_latched_group_valid[lane_idx]) begin
          set_s_write_bit(LANE_IDX_W'(lane_idx), v2c_m_latched_entry_pos, cnu_a_sign[lane_idx]);
          write_bit_idx = s_word_bit_idx(v2c_m_latched_entry_pos);
          write_lane_last =
            ((int'(v2c_m_latched_entry_pos) + 1) >=
             int'(col_meta_slot_count[col_k_meta_slot]));
          s_write_word_addr[lane_idx] = s_word_addr(v2c_m_latched_col, v2c_m_latched_entry_pos);
          s_word_wdata[lane_idx] = s_write_shift[lane_idx];
          s_word_wdata[lane_idx][write_bit_idx] = cnu_a_sign[lane_idx];
          s_word_we[lane_idx] = (write_bit_idx == S_PACK_IDX_W'(S_PACK_W - 1)) || write_lane_last;
        end
      end
    end
  end

  // RAM-T steering for producer c2v messages.
  always_comb begin
    integer lane_idx;

    t_write_entry_idx = c2v_latched_entry_pos;
    t_read_entry_idx  = v2c_read ? v2c_entry_pos : v2c_read_entry_pos_d1;
    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      t_push[lane_idx]  = 1'b0;
      t_pop[lane_idx]   = 1'b0;
      t_valid[lane_idx] = 1'b0;
      t_wdata[lane_idx] = '0;
    end

    if (c2v_write_t) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        t_push[lane_idx] = 1'b1;
        if (c2v_latched_group_valid[lane_idx]) begin
          t_valid[lane_idx] = 1'b1;
          t_wdata[lane_idx] = c2v_tc[lane_idx];
        end
      end
    end

    if (vnu_cnu_a) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        t_pop[lane_idx] = 1'b1;
      end
    end
  end

  // Decision RAM steering for hard decisions.
  always_comb begin
    decision_ram_we = 1'b0;
    decision_ram_col_idx = v2c_col_idx;
    decision_ram_wdata = 1'b0;

    if (vnu_prep_write) begin
      decision_ram_we = 1'b1;
      decision_ram_col_idx = v2c_col_idx;
      decision_ram_wdata = vnu_bit_out;
    end
  end

  // Sequential latches that bridge the single-port memories and the multi-cycle
  // control schedule. These registers keep the edge metadata stable across the
  // c2v/v2c handoff.
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer idx;
    integer group_idx;
    integer lane_idx;
    integer pending_idx;

    if (!i_rst_n) begin
      col_k_meta_slot <= 1'b0;
      col_kp1_meta_slot <= 1'b1;
      ram_i_shift_commit_pending <= 1'b0;
      c2v_read_d1 <= 1'b0;
      c2v_read_col_d1 <= '0;
      c2v_read_entry_pos_d1 <= '0;
      c2v_read_entry_pos_last_d1 <= 1'b0;
      c2v_read_m_read_pair_d1 <= 1'b0;
      v2c_read_col_d1 <= '0;
      v2c_read_entry_pos_d1 <= '0;
      v2c_read_m_write_pair_d1 <= 1'b0;
      col_meta_slot_count[0] <= '0;
      col_meta_slot_count[1] <= '0;
      for (group_idx = 0; group_idx < B; group_idx++) begin
        ram_i_read_ptr[group_idx] <= '0;
        ram_i_shift_write_ptr[group_idx] <= '0;
        ram_i_shift_commit_count[group_idx] <= '0;
        ram_i_shift_pending_count[group_idx] <= '0;
        for (pending_idx = 0; pending_idx < SHIFT_PENDING_DEPTH; pending_idx++) begin
          ram_i_shift_pending_addr[group_idx][pending_idx]  <= '0;
          ram_i_shift_pending_wdata[group_idx][pending_idx] <= '0;
        end
      end
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_sched_group_valid_d1[lane_idx] <= 1'b0;
        c2v_sched_group_idx_d1[lane_idx] <= '0;
        v2c_read_group_valid_d1[lane_idx] <= 1'b0;
        v2c_read_group_idx_d1[lane_idx] <= '0;
        v2c_read_row_idx_group_d1[lane_idx] <= '0;
        c2v_latched_group_valid[lane_idx] <= 1'b0;
        c2v_latched_group_idx[lane_idx] <= '0;
        c2v_latched_one_idx[lane_idx] <= '0;
        c2v_latched_row_idx_group[lane_idx] <= '0;
        v2c_m_latched_group_valid[lane_idx] <= 1'b0;
        v2c_m_latched_group_idx[lane_idx] <= '0;
        v2c_m_latched_row_idx_group[lane_idx] <= '0;
        s_read_shift[lane_idx] <= '0;
        s_write_shift[lane_idx] <= '0;
        s_read_word_load_pending[lane_idx] <= 1'b0;
        for (idx = 0; idx < RAM_LANE_DEPTH; idx++) begin
          col_meta_lane_valid[0][lane_idx][idx] <= 1'b0;
          col_meta_lane_valid[1][lane_idx][idx] <= 1'b0;
          col_meta_lane_group_idx[0][lane_idx][idx] <= '0;
          col_meta_lane_group_idx[1][lane_idx][idx] <= '0;
          col_meta_lane_entries[0][lane_idx][idx] <= '0;
          col_meta_lane_entries[1][lane_idx][idx] <= '0;
        end
      end
      c2v_latched_col <= '0;
      c2v_latched_entry_pos <= '0;
      c2v_latched_entry_pos_last <= 1'b0;
      c2v_latched_m_read_pair <= 1'b0;
      v2c_m_latched_entry_pos <= '0;
      v2c_m_latched_col <= '0;
      v2c_m_latched_m_write_pair <= 1'b0;
`ifdef BIKE_SIM_DEBUG
      for (idx = 0; idx < I_MAX; idx++) begin
        syndrome_hist[idx] <= '0;
      end
`endif
    end else begin
      if (i_start) begin
        for (group_idx = 0; group_idx < B; group_idx++) begin
          ram_i_read_ptr[group_idx] <= '0;
        end
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          s_read_shift[lane_idx] <= '0;
          s_write_shift[lane_idx] <= '0;
          s_read_word_load_pending[lane_idx] <= 1'b0;
        end
      end

      c2v_read_d1 <= c2v_read;
      if (c2v_read) begin
        c2v_read_col_d1 <= c2v_col_idx;
        c2v_read_entry_pos_d1 <= c2v_entry_pos;
        c2v_read_entry_pos_last_d1 <= c2v_entry_pos_last;
        c2v_read_m_read_pair_d1 <= m_read_pair;
        for (group_idx = 0; group_idx < B; group_idx++) begin
          ram_i_read_ptr[group_idx] <= c2v_entry_pos_last ? '0 : ram_i_read_ptr_next[group_idx];
        end
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          c2v_sched_group_valid_d1[lane_idx] <= c2v_sched_group_valid[lane_idx];
          c2v_sched_group_idx_d1[lane_idx]   <= c2v_sched_group_idx[lane_idx];
        end
      end

      if (v2c_read) begin
        v2c_read_col_d1 <= v2c_col_idx;
        v2c_read_entry_pos_d1 <= v2c_entry_pos;
        v2c_read_m_write_pair_d1 <= m_write_pair;
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_read_group_valid_d1[lane_idx] <= v2c_group_valid[lane_idx];
          v2c_read_group_idx_d1[lane_idx] <= v2c_group_idx[lane_idx];
          v2c_read_row_idx_group_d1[lane_idx] <= v2c_row_idx_group[lane_idx];
        end
      end

      ram_i_shift_commit_pending <= ram_i_shift_commit_pending_next;
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        s_read_word_load_pending[lane_idx] <= c2v_read_d1 && (s_word_bit_idx(
            s_read_entry_idx[lane_idx]
        ) == '0);
        if (s_read_word_load_pending[lane_idx]) begin
          s_read_shift[lane_idx] <= {{1{1'b0}}, s_word_rdata[lane_idx][S_PACK_W-1:1]};
        end else if (c2v_write_t) begin
          s_read_shift[lane_idx] <= {{1{1'b0}}, s_read_shift[lane_idx][S_PACK_W-1:1]};
        end
        if (s_we[lane_idx]) begin
          s_write_shift[lane_idx][s_word_bit_idx(s_write_entry_idx[lane_idx])] <= s_wdata[lane_idx];
          if (s_word_we[lane_idx]) begin
            s_write_shift[lane_idx] <= '0;
          end
        end
      end
      for (group_idx = 0; group_idx < B; group_idx++) begin
        ram_i_shift_pending_count[group_idx] <= ram_i_shift_pending_count_next[group_idx];
        for (pending_idx = 0; pending_idx < SHIFT_PENDING_DEPTH; pending_idx++) begin
          ram_i_shift_pending_addr[group_idx][pending_idx] <=
            ram_i_shift_pending_addr_next[group_idx][pending_idx];
          ram_i_shift_pending_wdata[group_idx][pending_idx] <=
            ram_i_shift_pending_wdata_next[group_idx][pending_idx];
        end
      end

      if (c2v_read_d1) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          c2v_latched_group_valid[lane_idx] <= c2v_group_valid[lane_idx];
          c2v_latched_group_idx[lane_idx] <= c2v_group_idx[lane_idx];
          c2v_latched_one_idx[lane_idx] <= c2v_one_idx[lane_idx];
          c2v_latched_row_idx_group[lane_idx] <= c2v_row_idx_group[lane_idx];
          col_meta_lane_valid[col_kp1_meta_slot][lane_idx][c2v_read_entry_pos_d1] <=
            c2v_group_valid[lane_idx];
          col_meta_lane_group_idx[col_kp1_meta_slot][lane_idx][c2v_read_entry_pos_d1] <=
            c2v_group_idx[lane_idx];
          col_meta_lane_entries[col_kp1_meta_slot][lane_idx][c2v_read_entry_pos_d1] <=
            ram_i_entry_rdata[c2v_sched_group_idx_d1[lane_idx]];
        end
        c2v_latched_col <= c2v_read_col_d1;
        c2v_latched_entry_pos <= c2v_read_entry_pos_d1;
        c2v_latched_entry_pos_last <= c2v_read_entry_pos_last_d1;
        c2v_latched_m_read_pair <= c2v_read_m_read_pair_d1;
        if (c2v_read_entry_pos_last_d1) begin
          col_meta_slot_count[col_kp1_meta_slot] <= c2v_read_entry_pos_d1 + GROUP_COUNT_W'(1);
        end
      end

      if (shift_ram_i) begin
        for (group_idx = 0; group_idx < B; group_idx++) begin
          ram_i_shift_write_ptr[group_idx] <= ram_i_shift_write_ptr_next[group_idx];
          if (shift_ram_i_last) begin
            ram_i_shift_commit_count[group_idx] <= ram_i_shift_write_ptr_next[group_idx];
          end
        end
      end

      if (col_k_meta_advance) begin
        col_k_meta_slot   <= col_kp1_meta_slot;
        col_kp1_meta_slot <= col_k_meta_slot;
      end

      if (vnu_cnu_a) begin
        for (lane_idx = 0; lane_idx < L; lane_idx++) begin
          v2c_m_latched_group_valid[lane_idx] <= v2c_read_group_valid_d1[lane_idx];
          v2c_m_latched_group_idx[lane_idx] <= v2c_read_group_idx_d1[lane_idx];
          v2c_m_latched_row_idx_group[lane_idx] <= v2c_read_row_idx_group_d1[lane_idx];
        end
        v2c_m_latched_entry_pos <= v2c_read_entry_pos_d1;
        v2c_m_latched_col <= v2c_read_col_d1;
        v2c_m_latched_m_write_pair <= v2c_read_m_write_pair_d1;
      end

`ifdef BIKE_SIM_DEBUG
      if (iter_check) begin
        syndrome_hist[hist_wr_idx] <= '0;
      end
`endif
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
      if (iter_check && !finish_decode) begin
        m_pair_epoch[m_read_pair] <= ~m_pair_epoch[m_read_pair];
      end
    end
  end

  assign cnu_a_col_idx = v2c_read_col_d1;

  always_comb begin
    integer                    lane_idx;
    logic   [M_BANK_IDX_W-1:0] port_idx;
    logic                      port_pair;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      port_pair = v2c_read_m_write_pair_d1;
      port_idx = M_BANK_IDX_W'(m_index(port_pair, v2c_read_group_idx_d1[lane_idx]));
      cnu_a_comp_in[lane_idx] = m_write_comp_or_init(port_idx);
      cnu_a_en[lane_idx] = vnu_cnu_a && v2c_read_group_valid_d1[lane_idx];
      cnu_a_v2c_msg[lane_idx] = vnu_v2c_msg[lane_idx];
    end
  end

  always_comb begin
    integer                    lane_idx;
    logic   [M_BANK_IDX_W-1:0] port_idx;
    logic                      port_pair;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      port_pair = c2v_latched_m_read_pair;
      port_idx = M_BANK_IDX_W'(m_index(port_pair, c2v_latched_group_idx[lane_idx]));
      cnu_b_comp_in[lane_idx] = m_read_comp_or_first(port_idx, (o_iter_count == '0));
    end
  end

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane_cnu_a
    cnu_a u_cnu_a (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(cnu_a_en[lane_idx]),
        .i_v2c_msg(cnu_a_v2c_msg[lane_idx]),
        .i_col_idx(cnu_a_col_idx),
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
      .i_read_row_idx(syndrome_read_row_idx),
      .o_rdata(syndrome_rdata)
  );

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane_cnu_b
    cnu_b u_cnu_b (
        .i_comp_c2v(cnu_b_comp_in[lane_idx]),
        .i_v2c_sign(s_rdata[lane_idx]),
        .i_syndrome_bit(syndrome_rdata[lane_idx]),
        .i_col_idx(c2v_latched_col),
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

  assign vnu_col_start = vnu_accum_t && (c2v_latched_entry_pos == '0);
  assign vnu_col_end   = vnu_accum_t && c2v_latched_entry_pos_last;

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      vnu_accum_valid[lane_idx] = vnu_accum_t && c2v_latched_group_valid[lane_idx];
      vnu_prev_c2v_valid[lane_idx] = vnu_cnu_a && t_rvalid[lane_idx];
      vnu_prev_c2v[lane_idx] = $signed(t_rdata[lane_idx]);
    end
  end

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
      .i_decode_success(decode_success),
      .i_c2v_entry_pos_last(c2v_entry_pos_last),
      .i_v2c_entry_pos_last(v2c_entry_pos_last),
      .i_ram_i_shift_ready(ram_i_shift_ready),
      .o_state(state),
      .o_work_col_idx(work_col_idx),
      .o_work_entry_pos(work_entry_pos),
      .o_c2v_col_idx(c2v_col_idx),
      .o_v2c_col_idx(v2c_col_idx),
      .o_c2v_entry_pos(c2v_entry_pos),
      .o_v2c_entry_pos(v2c_entry_pos),
      .o_active_entry_pos(active_entry_pos),
      .o_m_read_pair(m_read_pair),
      .o_m_write_pair(m_write_pair),
      .o_c2v_read(c2v_read),
      .o_v2c_read(v2c_read),
      .o_c2v_write_t(c2v_write_t),
      .o_vnu_accum_t(vnu_accum_t),
      .o_vnu_prep_write(vnu_prep_write),
      .o_vnu_cnu_a(vnu_cnu_a),
      .o_vnu_write_next(vnu_write_next),
      .o_iter_check(iter_check),
      .o_col_k_meta_advance(col_k_meta_advance),
      .o_c2v_pipe_valid(c2v_phase_active),
      .o_v2c_pipe_valid(v2c_phase_active),
      .o_c2v_v2c_overlap_seen(c2v_v2c_overlap_seen),
      .o_done(o_done),
      .o_success(o_success),
      .o_iter_count(o_iter_count)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  for (genvar ram_i_bank_idx = 0; ram_i_bank_idx < B; ram_i_bank_idx++) begin : g_ram_i
    ram_i #(
        .INIT_HEX_STEM(""),
        .INIT_HEX_PREFIX(RAM_I_HEX_PREFIX),
        .BANK_IDX(ram_i_bank_idx),
        .INIT_HEX_TAG(RAM_I_HEX_TAG)
    ) u_ram_i (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_we(ram_i_shift_we[ram_i_bank_idx]),
        .i_h_block_idx(c2v_h_block_idx),
        .i_read_entry_idx(ram_i_read_entry_addr[ram_i_bank_idx]),
        .i_write_entry_idx(ram_i_shift_entry_addr[ram_i_bank_idx]),
        .i_entry_wdata(ram_i_shift_entry_wdata[ram_i_bank_idx]),
        .i_count_we(ram_i_shift_count_we),
        .i_count_wdata(ram_i_shift_count_wdata[ram_i_bank_idx]),
        .o_entry_rdata(ram_i_entry_rdata[ram_i_bank_idx]),
`ifdef BIKE_SIM_DEBUG
        .o_count(ram_i_count[ram_i_bank_idx]),
        .o_debug_list_entries(),
        .o_debug_counts(ram_i_bank_debug_count[ram_i_bank_idx])
`else
        .o_count(ram_i_count[ram_i_bank_idx])
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

  for (genvar ram_m_idx = 0; ram_m_idx < M_BANKS; ram_m_idx++) begin : g_ram_m
    ram_m u_ram_m (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_we(m_we[ram_m_idx]),
        .i_read_row_idx_group(m_read_row_idx_group[ram_m_idx]),
        .i_write_row_idx_group(m_write_row_idx_group[ram_m_idx]),
        .i_epoch(m_pair_epoch[(ram_m_idx>=B)?1 : 0]),
        .i_wdata(m_wdata[ram_m_idx]),
        .o_rdata(m_rdata[ram_m_idx]),
`ifdef BIKE_SIM_DEBUG
        .o_epoch(m_repoch[ram_m_idx]),
        .o_debug_mem(ram_m_debug_mem[ram_m_idx])
`else
        .o_epoch(m_repoch[ram_m_idx])
`endif
    );
  end

  for (genvar ram_s_lane_idx = 0; ram_s_lane_idx < L; ram_s_lane_idx++) begin : g_ram_s
    ram_s #(
        .RAM_S_PACK_W(S_PACK_W),
        .RAM_S_WORDS_PER_COL(S_WORDS_PER_COL),
        .RAM_S_WORD_DEPTH(S_WORD_DEPTH),
        .RAM_S_WORD_ADDR_W(S_WORD_ADDR_W)
    ) u_ram_s (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_we(s_word_we[ram_s_lane_idx]),
        .i_read_word_addr(s_read_word_addr[ram_s_lane_idx]),
        .i_write_word_addr(s_write_word_addr[ram_s_lane_idx]),
        .i_wdata(s_word_wdata[ram_s_lane_idx]),
`ifdef BIKE_SIM_DEBUG
        .o_rdata(s_word_rdata[ram_s_lane_idx]),
        .o_debug_mem()
`else
        .o_rdata(s_word_rdata[ram_s_lane_idx])
`endif
    );
  end

  for (genvar ram_t_lane_idx = 0; ram_t_lane_idx < L; ram_t_lane_idx++) begin : g_ram_t
    ram_t u_ram_t (
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
        .o_valid(t_rvalid[ram_t_lane_idx]),
        .o_item_count(ram_t_debug_item_count[ram_t_lane_idx]),
        .o_debug_mem()
`else
        .o_valid(t_rvalid[ram_t_lane_idx])
`endif
    );
  end
  /* verilator lint_on PINCONNECTEMPTY */
endmodule
