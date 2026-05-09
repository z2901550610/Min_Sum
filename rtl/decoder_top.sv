`timescale 1ns/1ps
// Top-level BIKE min-sum decoder datapath and module interconnect.
module decoder_top
  import bike_pkg::*;
#(
  parameter string RAM_I0_HEX_STEM = "rtl/generated/ram_i0",
  parameter string RAM_I1_HEX_STEM = "rtl/generated/ram_i1",
`ifdef BIKE_L1_PARAMS
  parameter string RAM_I_HEX_TAG = "_l1"
`else
  parameter string RAM_I_HEX_TAG = "_test"
`endif
)
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

  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam int HIST_IDX_W = (I_MAX > 1) ? $clog2(I_MAX) : 1;
  localparam logic [COMP_C2V_W-1:0] FIRST_ITER_C2V_COMP = {
    1'b0,
    COL_W'(0),
    D'(C_VAL),
    D'(C_VAL)
  };

  /* verilator lint_off UNUSEDSIGNAL */
  // Debug/control visibility exported to the testbench. The real scheduling
  // comes from the explicit control pulses produced by `decoder_ctrl`.
  logic [DEC_STATE_W-1:0] state;
  logic [DEC_PHASE_W-1:0] phase;
  logic [ENTRY_POS_W-1:0] work_entry_pos;
  logic [COL_W-1:0] work_col_idx;
  logic [COL_W-1:0] c2v_col_idx;
  logic [COL_W-1:0] v2c_col_idx;
  logic [ENTRY_POS_W-1:0] c2v_entry_pos;
  logic [ENTRY_POS_W-1:0] v2c_entry_pos;
  logic [ENTRY_POS_W-1:0] active_entry_pos;
  logic c2v_phase_active;
  logic v2c_phase_active;
  logic c2v_v2c_overlap_seen;
  logic col_k_meta_advance;
  logic [N-1:0] error_estimate_bits;
  logic [R-1:0] syndrome_hist [0:I_MAX-1];
  logic [GROUP_COUNT_W-1:0] ram_i_debug_count [0:N0-1][0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] ram_i_entry_rdata [0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_count [0:L-1];

  logic m_read_pair;
  logic m_write_pair;

  logic c2v_read;
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
  logic [GROUP_COUNT_W-1:0] col_meta_group_count [0:1][0:L-1];
  logic [I_ENTRY_W-1:0] col_meta_group_entries [0:1][0:L-1][0:RAM_LANE_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_write_ptr [0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_write_ptr_next [0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_commit_count [0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_count_wdata [0:L-1];
  logic [ROW_GROUP_W-1:0] h_shift_row_idx_group_in [0:L-1];
  logic [GROUP_IDX_W-1:0] shifted_group_idx [0:L-1];
  logic [ROW_GROUP_W-1:0] shifted_row_idx_group [0:L-1];
  logic shifted_valid [0:L-1];
  logic shift_ram_i;
  logic shift_ram_i_last;
  logic ram_i_shift_ready;
  logic ram_i_shift_commit_pending;
  logic ram_i_shift_commit_pending_next;
  logic ram_i_shift_count_we;
  logic [1:0] ram_i_shift_pending_count [0:L-1];
  logic [1:0] ram_i_shift_pending_count_next [0:L-1];
  logic [ENTRY_POS_W-1:0] ram_i_shift_pending_addr [0:L-1][0:2];
  logic [ENTRY_POS_W-1:0] ram_i_shift_pending_addr_next [0:L-1][0:2];
  logic [I_ENTRY_W-1:0] ram_i_shift_pending_wdata [0:L-1][0:2];
  logic [I_ENTRY_W-1:0] ram_i_shift_pending_wdata_next [0:L-1][0:2];
  logic ram_i_shift_we [0:L-1];
  logic [ENTRY_POS_W-1:0] ram_i_shift_entry_addr [0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_shift_entry_wdata [0:L-1];
  logic c2v_entry_pos_last;
  logic v2c_entry_pos_last;

  // Per-edge decoded metadata used to address RAM-M/S/T.
  logic c2v_group_valid [0:L-1];
  logic [ONE_IDX_W-1:0] c2v_one_idx [0:L-1];
  logic [ROW_GROUP_W-1:0] c2v_row_idx_group [0:L-1];
  logic [ROW_IDX_W-1:0] c2v_row_idx_global [0:L-1];
  logic v2c_group_valid [0:L-1];
  logic [ROW_GROUP_W-1:0] v2c_row_idx_group [0:L-1];

  logic c2v_latched_group_valid [0:L-1];
  logic [ONE_IDX_W-1:0] c2v_latched_one_idx [0:L-1];
  logic [ROW_GROUP_W-1:0] c2v_latched_row_idx_group [0:L-1];
  logic [ROW_IDX_W-1:0] c2v_latched_row_idx_global [0:L-1];
  logic [ENTRY_POS_W-1:0] c2v_latched_entry_pos;
  logic c2v_latched_entry_pos_last;
  logic [COL_W-1:0] c2v_latched_col;
  logic c2v_latched_m_read_pair;

  logic v2c_m_latched_group_valid [0:L-1];
  logic [ROW_GROUP_W-1:0] v2c_m_latched_row_idx_group [0:L-1];
  logic [ENTRY_POS_W-1:0] v2c_m_latched_entry_pos;
  logic [COL_W-1:0] v2c_m_latched_col;
  logic v2c_m_latched_m_write_pair;

  logic [R-1:0] residual_syndrome_next;
  logic decode_success;
  logic finish_decode;
  logic [ITER_W:0] next_iter_count_ext;
  logic [HIST_IDX_W-1:0] hist_wr_idx;

  logic [GROUP_COUNT_W-1:0] ram_i0_debug_count [0:N0-1];
  logic [GROUP_COUNT_W-1:0] ram_i1_debug_count [0:N0-1];

  // Paper-style RAM port steering. Each block is single-port, so the top
  // centralizes all enables, addresses, and write data here.
  logic m_we [0:3];
  logic [ROW_GROUP_W-1:0] m_read_row_idx_group [0:3];
  logic [ROW_GROUP_W-1:0] m_write_row_idx_group [0:3];
  logic [COMP_C2V_W-1:0] m_wdata [0:3];
  logic [COMP_C2V_W-1:0] m_rdata [0:3];
  logic m_pair_epoch [0:1];
  logic m_row_valid [0:3][0:ROW_GROUP_DEPTH-1];
  logic m_row_epoch [0:3][0:ROW_GROUP_DEPTH-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [COMP_C2V_W-1:0] ram_m0_debug_mem [0:ROW_GROUP_DEPTH-1];
  logic [COMP_C2V_W-1:0] ram_m1_debug_mem [0:ROW_GROUP_DEPTH-1];
  logic [COMP_C2V_W-1:0] ram_m2_debug_mem [0:ROW_GROUP_DEPTH-1];
  logic [COMP_C2V_W-1:0] ram_m3_debug_mem [0:ROW_GROUP_DEPTH-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic s_we [0:L-1];
  logic [COL_W-1:0] s_read_col_idx [0:L-1];
  logic [ENTRY_POS_W-1:0] s_read_entry_idx [0:L-1];
  logic [COL_W-1:0] s_write_col_idx [0:L-1];
  logic [ENTRY_POS_W-1:0] s_write_entry_idx [0:L-1];
  logic s_wdata [0:L-1];
  logic s_rdata [0:L-1];

  logic t_push [0:L-1];
  logic t_pop [0:L-1];
  logic t_valid [0:L-1];
  logic [ENTRY_POS_W-1:0] t_write_entry_idx;
  logic [ENTRY_POS_W-1:0] t_read_entry_idx;
  logic [MSG_W-1:0] t_wdata [0:L-1];
  logic t_rvalid [0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [MSG_W-1:0] t_rdata [0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */

  logic decision_ram_we;
  logic [COL_W-1:0] decision_ram_col_idx;
  logic decision_ram_wdata;

  logic [COL_W-1:0] cnu_a_col_idx;
  logic cnu_a_en [0:L-1];
  logic [MSG_W-1:0] cnu_a_v2c_msg [0:L-1];
  logic [COMP_C2V_W-1:0] cnu_a_comp_in [0:L-1];
  logic [COMP_C2V_W-1:0] cnu_a_comp_out [0:L-1];
  logic cnu_a_sign [0:L-1];
  logic cnu_a_valid [0:L-1];
  logic [COMP_C2V_W-1:0] cnu_b_comp_in [0:L-1];

  logic [MSG_W-1:0] c2v_msg [0:L-1];
  logic signed [MSG_W-1:0] c2v_tc [0:L-1];

  logic vnu_col_start;
  logic vnu_col_end;
  logic vnu_accum_valid [0:L-1];
  logic vnu_prev_c2v_valid [0:L-1];
  logic signed [MSG_W-1:0] vnu_prev_c2v [0:L-1];
  logic vnu_bit_out;
  logic signed [VNU_TC_W-1:0] vnu_v2c_tc [0:L-1];
  logic [MSG_W-1:0] vnu_v2c_msg [0:L-1];

  function automatic int m_index(input logic pair, input logic [GROUP_IDX_W-1:0] group_idx);
    begin
      m_index = (pair ? 2 : 0) + int'(group_idx);
    end
  endfunction

  function automatic logic m_port_pair(input int port_idx);
    begin
      m_port_pair = (port_idx >= L);
    end
  endfunction

  task automatic set_m_read_row(
    input logic pair,
    input logic [GROUP_IDX_W-1:0] group_idx,
    input logic [ROW_GROUP_W-1:0] row_idx_group
  );
    logic [1:0] port_idx;
    begin
      port_idx = 2'(m_index(pair, group_idx));
      m_read_row_idx_group[port_idx] = row_idx_group;
    end
  endtask

  task automatic set_m_write_state(
    input logic pair,
    input logic [GROUP_IDX_W-1:0] group_idx,
    input logic [ROW_GROUP_W-1:0] row_idx_group,
    input logic [COMP_C2V_W-1:0] comp_c2v
  );
    logic [1:0] port_idx;
    begin
      port_idx = 2'(m_index(pair, group_idx));
      m_we[port_idx] = 1'b1;
      m_write_row_idx_group[port_idx] = row_idx_group;
      m_wdata[port_idx] = comp_c2v;
    end
  endtask

  task automatic set_s_write_bit(
    input logic [GROUP_IDX_W-1:0] group_idx,
    input logic [COL_W-1:0] col_idx,
    input logic [ENTRY_POS_W-1:0] entry_idx,
    input logic sign_bit
  );
    begin
      s_we[group_idx] = 1'b1;
      s_write_col_idx[group_idx] = col_idx;
      s_write_entry_idx[group_idx] = entry_idx;
      s_wdata[group_idx] = sign_bit;
    end
  endtask

  function automatic logic [COMP_C2V_W-1:0] m_comp_or_default(
    input logic [1:0] port_idx,
    input logic port_pair,
    input logic [ROW_GROUP_W-1:0] row_addr,
    input logic use_first_iter_default
  );
    begin
      if (m_row_valid[port_idx][row_addr] &&
          (m_row_epoch[port_idx][row_addr] == m_pair_epoch[port_pair])) begin
        m_comp_or_default = m_rdata[port_idx];
      end else if (use_first_iter_default) begin
        m_comp_or_default = FIRST_ITER_C2V_COMP;
      end else begin
        m_comp_or_default = COMP_C2V_INIT;
      end
    end
  endfunction

  assign next_iter_count_ext = {1'b0, o_iter_count} + {{ITER_W{1'b0}}, 1'b1};
  assign hist_wr_idx = o_iter_count[HIST_IDX_W-1:0];
  assign decode_success = (residual_syndrome_next == '0);
  assign finish_decode = decode_success || (next_iter_count_ext >= (ITER_W + 1)'(I_MAX));
  assign c2v_h_block_idx = H_BLOCK_W'(int'(c2v_col_idx) / R);
  assign o_e = error_estimate_bits;

  always_comb begin
    integer group_idx;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      h_shift_row_idx_group_in[group_idx] =
        c2v_latched_row_idx_group[group_idx];
    end
  end

  h_shift #(
    .R(R),
    .L(L),
    .ROW_IDX_W(ROW_IDX_W),
    .GROUP_IDX_W(GROUP_IDX_W)
  ) u_h_shift (
    .i_row_idx_group(h_shift_row_idx_group_in),
    .o_ram_i_target_idx(shifted_group_idx),
    .o_row_idx_group(shifted_row_idx_group)
  );

  // Aggregate the two group RAM-I debug counts into the shape expected by
  // the testbench.
  always_comb begin
    integer h_block_idx;

    for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      ram_i_debug_count[h_block_idx][0] = ram_i0_debug_count[h_block_idx];
      ram_i_debug_count[h_block_idx][1] = ram_i1_debug_count[h_block_idx];
    end
  end

  // Decide whether each c2v/v2c column cursor is at the last active group
  // list position for the current column.
  always_comb begin
    integer c2v_max_count;
    integer v2c_max_count;

    c2v_max_count = int'(ram_i_count[0]);
    if (int'(ram_i_count[1]) > c2v_max_count) begin
      c2v_max_count = int'(ram_i_count[1]);
    end
    c2v_entry_pos_last = ((int'(c2v_entry_pos) + 1) >= c2v_max_count);

    v2c_max_count = int'(col_meta_group_count[col_k_meta_slot][0]);
    if (int'(col_meta_group_count[col_k_meta_slot][1]) > v2c_max_count) begin
      v2c_max_count = int'(col_meta_group_count[col_k_meta_slot][1]);
    end
    v2c_entry_pos_last = ((int'(v2c_entry_pos) + 1) >= v2c_max_count);
  end

  // Decode the active packed RAM-I entry into the addresses consumed by the
  // M/S/T memories.
  always_comb begin
    integer group_idx;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      c2v_group_valid[group_idx] =
        (int'(c2v_entry_pos) < int'(ram_i_count[group_idx]));
      c2v_one_idx[group_idx] =
        ram_i_entry_rdata[group_idx][I_ENTRY_ONE_IDX_LSB +: ONE_IDX_W];
      c2v_row_idx_group[group_idx] =
        ram_i_entry_rdata[group_idx][I_ENTRY_ROW_IDX_GROUP_LSB +: ROW_GROUP_W];
      c2v_row_idx_global[group_idx] = ROW_IDX_W'(
        (int'(c2v_row_idx_group[group_idx]) << 1) | group_idx
      );
      if (!c2v_group_valid[group_idx]) begin
        c2v_one_idx[group_idx] = '0;
        c2v_row_idx_group[group_idx] = '0;
        c2v_row_idx_global[group_idx] = '0;
      end

      v2c_group_valid[group_idx] =
        (int'(v2c_entry_pos) < int'(col_meta_group_count[col_k_meta_slot][group_idx]));
      v2c_row_idx_group[group_idx] =
        col_meta_group_entries[col_k_meta_slot][group_idx][v2c_entry_pos][I_ENTRY_ROW_IDX_GROUP_LSB +: ROW_GROUP_W];
      if (!v2c_group_valid[group_idx]) begin
        v2c_row_idx_group[group_idx] = '0;
      end
    end
  end

  // H shift：使用 RAM-I 单 entry 写口逐项写回下一列 metadata。
  always_comb begin
    integer group_idx;
    logic [GROUP_IDX_W-1:0] target_idx;
    logic [I_ENTRY_W-1:0] shifted_entry;
    logic bank_has_write [0:L-1];
    logic [1:0] enqueue_slot;
    logic entries_empty_current;
    logic entries_empty_next;

    shift_ram_i = c2v_write_t;
    shift_ram_i_last = shift_ram_i && c2v_latched_entry_pos_last;
    ram_i_shift_commit_pending_next = ram_i_shift_commit_pending;
    ram_i_shift_count_we = 1'b0;
    ram_i_shift_ready = 1'b0;
    target_idx = '0;
    shifted_entry = '0;
    enqueue_slot = '0;
    entries_empty_current = 1'b1;
    entries_empty_next = 1'b1;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      entries_empty_current = entries_empty_current && (ram_i_shift_pending_count[group_idx] == 2'd0);
      shifted_valid[group_idx] = shift_ram_i && c2v_latched_group_valid[group_idx];
      ram_i_shift_write_ptr_next[group_idx] =
        (shift_ram_i && (c2v_latched_entry_pos == '0)) ? '0 : ram_i_shift_write_ptr[group_idx];
      ram_i_shift_count_wdata[group_idx] = ram_i_shift_commit_count[group_idx];
      ram_i_shift_pending_count_next[group_idx] = ram_i_shift_pending_count[group_idx];
      ram_i_shift_pending_addr_next[group_idx][0] = ram_i_shift_pending_addr[group_idx][0];
      ram_i_shift_pending_addr_next[group_idx][1] = ram_i_shift_pending_addr[group_idx][1];
      ram_i_shift_pending_addr_next[group_idx][2] = ram_i_shift_pending_addr[group_idx][2];
      ram_i_shift_pending_wdata_next[group_idx][0] = ram_i_shift_pending_wdata[group_idx][0];
      ram_i_shift_pending_wdata_next[group_idx][1] = ram_i_shift_pending_wdata[group_idx][1];
      ram_i_shift_pending_wdata_next[group_idx][2] = ram_i_shift_pending_wdata[group_idx][2];
      ram_i_shift_we[group_idx] = 1'b0;
      ram_i_shift_entry_addr[group_idx] = c2v_latched_entry_pos;
      ram_i_shift_entry_wdata[group_idx] = '0;
      bank_has_write[group_idx] = 1'b0;
    end

    for (group_idx = 0; group_idx < L; group_idx++) begin
      if (ram_i_shift_pending_count[group_idx] != 2'd0) begin
        ram_i_shift_we[group_idx] = 1'b1;
        ram_i_shift_entry_addr[group_idx] = ram_i_shift_pending_addr[group_idx][0];
        ram_i_shift_entry_wdata[group_idx] = ram_i_shift_pending_wdata[group_idx][0];
        ram_i_shift_pending_count_next[group_idx] = ram_i_shift_pending_count[group_idx] - 2'd1;
        ram_i_shift_pending_addr_next[group_idx][0] = ram_i_shift_pending_addr[group_idx][1];
        ram_i_shift_pending_addr_next[group_idx][1] = ram_i_shift_pending_addr[group_idx][2];
        ram_i_shift_pending_wdata_next[group_idx][0] = ram_i_shift_pending_wdata[group_idx][1];
        ram_i_shift_pending_wdata_next[group_idx][1] = ram_i_shift_pending_wdata[group_idx][2];
        ram_i_shift_pending_addr_next[group_idx][2] = '0;
        ram_i_shift_pending_wdata_next[group_idx][2] = '0;
        bank_has_write[group_idx] = 1'b1;
      end
    end

    for (group_idx = 0; group_idx < L; group_idx++) begin
      if (shifted_valid[group_idx]) begin
        target_idx = shifted_group_idx[group_idx];
        shifted_entry = {c2v_latched_one_idx[group_idx], ROW_GROUP_W'(shifted_row_idx_group[group_idx])};

        if (bank_has_write[target_idx]) begin
          enqueue_slot = ram_i_shift_pending_count_next[target_idx];
          ram_i_shift_pending_addr_next[target_idx][enqueue_slot] =
            ENTRY_POS_W'(ram_i_shift_write_ptr_next[target_idx]);
          ram_i_shift_pending_wdata_next[target_idx][enqueue_slot] = shifted_entry;
          ram_i_shift_pending_count_next[target_idx] =
            ram_i_shift_pending_count_next[target_idx] + 2'd1;
        end else begin
          ram_i_shift_we[target_idx] = 1'b1;
          ram_i_shift_entry_addr[target_idx] =
            ENTRY_POS_W'(ram_i_shift_write_ptr_next[target_idx]);
          ram_i_shift_entry_wdata[target_idx] = shifted_entry;
          bank_has_write[target_idx] = 1'b1;
        end

        ram_i_shift_write_ptr_next[target_idx] =
          ram_i_shift_write_ptr_next[target_idx] + 1'b1;
      end
    end

    if (shift_ram_i_last) begin
      ram_i_shift_commit_pending_next = 1'b1;
      for (group_idx = 0; group_idx < L; group_idx++) begin
        ram_i_shift_count_wdata[group_idx] = ram_i_shift_write_ptr_next[group_idx];
      end
    end

    entries_empty_next = 1'b1;
    for (group_idx = 0; group_idx < L; group_idx++) begin
      entries_empty_next = entries_empty_next && (ram_i_shift_pending_count_next[group_idx] == 2'd0);
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
    integer group_idx;

    for (port_idx = 0; port_idx < 4; port_idx++) begin
      m_we[port_idx] = 1'b0;
      m_read_row_idx_group[port_idx] = '0;
      m_write_row_idx_group[port_idx] = '0;
      m_wdata[port_idx] = COMP_C2V_INIT;
    end

    if (c2v_read) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        if (c2v_group_valid[group_idx]) begin
          set_m_read_row(m_read_pair, GROUP_IDX_W'(group_idx), c2v_row_idx_group[group_idx]);
        end
      end
    end

    if (c2v_write_t) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        if (c2v_latched_group_valid[group_idx]) begin
          set_m_read_row(
            c2v_latched_m_read_pair,
            GROUP_IDX_W'(group_idx),
            c2v_latched_row_idx_group[group_idx]
          );
        end
      end
    end

    if (vnu_cnu_a) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        if (v2c_group_valid[group_idx]) begin
          set_m_read_row(m_write_pair, GROUP_IDX_W'(group_idx), v2c_row_idx_group[group_idx]);
        end
      end
    end

    if (vnu_write_next) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        if (cnu_a_valid[group_idx] && v2c_m_latched_group_valid[group_idx]) begin
          set_m_write_state(
            v2c_m_latched_m_write_pair,
            GROUP_IDX_W'(group_idx),
            v2c_m_latched_row_idx_group[group_idx],
            cnu_a_comp_out[group_idx]
          );
        end
      end
    end
  end

  // RAM-S steering for v2c sign bits.
  always_comb begin
    integer group_idx;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      s_we[group_idx] = 1'b0;
      s_read_col_idx[group_idx] = c2v_col_idx;
      s_read_entry_idx[group_idx] = c2v_entry_pos;
      s_write_col_idx[group_idx] = c2v_latched_col;
      s_write_entry_idx[group_idx] = c2v_latched_entry_pos;
      s_wdata[group_idx] = 1'b0;
    end

    if (vnu_write_next) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        if (cnu_a_valid[group_idx] && v2c_m_latched_group_valid[group_idx]) begin
          set_s_write_bit(
            GROUP_IDX_W'(group_idx),
            v2c_m_latched_col,
            v2c_m_latched_entry_pos,
            cnu_a_sign[group_idx]
          );
        end
      end
    end
  end

  // RAM-T steering for producer c2v messages.
  always_comb begin
    integer group_idx;

    t_write_entry_idx = c2v_latched_entry_pos;
    t_read_entry_idx = v2c_entry_pos;
    for (group_idx = 0; group_idx < L; group_idx++) begin
      t_push[group_idx] = 1'b0;
      t_pop[group_idx] = 1'b0;
      t_valid[group_idx] = 1'b0;
      t_wdata[group_idx] = '0;
    end

    if (c2v_write_t) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        t_push[group_idx] = 1'b1;
        if (c2v_latched_group_valid[group_idx]) begin
          t_valid[group_idx] = 1'b1;
          t_wdata[group_idx] = c2v_tc[group_idx];
        end
      end
    end

    if (vnu_cnu_a) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        t_pop[group_idx] = 1'b1;
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

  // Recompute the residual syndrome from the single hard-decision RAM, which is
  // the source of truth for the exported error estimate.
  always_comb begin
    integer col_idx;
    integer one_idx;
    logic [H_BLOCK_W-1:0] residual_h_block_idx;
    integer residual_col;
    logic [ROW_IDX_W-1:0] residual_row;

    residual_syndrome_next = i_syndrome;
    residual_h_block_idx = '0;
    residual_col = 0;
    residual_row = '0;
    for (col_idx = 0; col_idx < N; col_idx++) begin
      if (error_estimate_bits[col_idx]) begin
        residual_h_block_idx = H_BLOCK_W'(col_idx / R);
        residual_col = col_idx % R;
        for (one_idx = 0; one_idx < W; one_idx++) begin
          residual_row = ROW_IDX_W'((H_BASE[0][residual_h_block_idx][one_idx] + residual_col) % R);
          residual_syndrome_next[residual_row] = residual_syndrome_next[residual_row] ^ 1'b1;
        end
      end
    end
  end

  // Sequential latches that bridge the single-port memories and the multi-cycle
  // control schedule. These registers keep the edge metadata stable across the
  // c2v/v2c handoff.
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer idx;
    integer group_idx;

    if (!i_rst_n) begin
      col_k_meta_slot <= 1'b0;
      col_kp1_meta_slot <= 1'b1;
      ram_i_shift_commit_pending <= 1'b0;
      for (group_idx = 0; group_idx < L; group_idx++) begin
        ram_i_shift_write_ptr[group_idx] <= '0;
        ram_i_shift_commit_count[group_idx] <= '0;
        ram_i_shift_pending_count[group_idx] <= '0;
        ram_i_shift_pending_addr[group_idx][0] <= '0;
        ram_i_shift_pending_addr[group_idx][1] <= '0;
        ram_i_shift_pending_addr[group_idx][2] <= '0;
        ram_i_shift_pending_wdata[group_idx][0] <= '0;
        ram_i_shift_pending_wdata[group_idx][1] <= '0;
        ram_i_shift_pending_wdata[group_idx][2] <= '0;
        c2v_latched_group_valid[group_idx] <= 1'b0;
        c2v_latched_one_idx[group_idx] <= '0;
        c2v_latched_row_idx_group[group_idx] <= '0;
        c2v_latched_row_idx_global[group_idx] <= '0;
        v2c_m_latched_group_valid[group_idx] <= 1'b0;
        v2c_m_latched_row_idx_group[group_idx] <= '0;
        for (idx = 0; idx < RAM_LANE_DEPTH; idx++) begin
          col_meta_group_entries[0][group_idx][idx] <= '0;
          col_meta_group_entries[1][group_idx][idx] <= '0;
        end
        col_meta_group_count[0][group_idx] <= '0;
        col_meta_group_count[1][group_idx] <= '0;
      end
      c2v_latched_col <= '0;
      c2v_latched_entry_pos <= '0;
      c2v_latched_entry_pos_last <= 1'b0;
      c2v_latched_m_read_pair <= 1'b0;
      v2c_m_latched_entry_pos <= '0;
      v2c_m_latched_col <= '0;
      v2c_m_latched_m_write_pair <= 1'b0;
      for (idx = 0; idx < I_MAX; idx++) begin
        syndrome_hist[idx] <= '0;
      end
    end else begin
      ram_i_shift_commit_pending <= ram_i_shift_commit_pending_next;
      for (group_idx = 0; group_idx < L; group_idx++) begin
        ram_i_shift_pending_count[group_idx] <= ram_i_shift_pending_count_next[group_idx];
        ram_i_shift_pending_addr[group_idx][0] <= ram_i_shift_pending_addr_next[group_idx][0];
        ram_i_shift_pending_addr[group_idx][1] <= ram_i_shift_pending_addr_next[group_idx][1];
        ram_i_shift_pending_addr[group_idx][2] <= ram_i_shift_pending_addr_next[group_idx][2];
        ram_i_shift_pending_wdata[group_idx][0] <= ram_i_shift_pending_wdata_next[group_idx][0];
        ram_i_shift_pending_wdata[group_idx][1] <= ram_i_shift_pending_wdata_next[group_idx][1];
        ram_i_shift_pending_wdata[group_idx][2] <= ram_i_shift_pending_wdata_next[group_idx][2];
      end

      if (c2v_read) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          c2v_latched_group_valid[group_idx] <= c2v_group_valid[group_idx];
          c2v_latched_one_idx[group_idx] <= c2v_one_idx[group_idx];
          c2v_latched_row_idx_group[group_idx] <= c2v_row_idx_group[group_idx];
          c2v_latched_row_idx_global[group_idx] <= c2v_row_idx_global[group_idx];
          col_meta_group_entries[col_kp1_meta_slot][group_idx][c2v_entry_pos] <=
            ram_i_entry_rdata[group_idx];
        end
        c2v_latched_col <= c2v_col_idx;
        c2v_latched_entry_pos <= c2v_entry_pos;
        c2v_latched_entry_pos_last <= c2v_entry_pos_last;
        c2v_latched_m_read_pair <= m_read_pair;
        if (c2v_entry_pos == '0) begin
          col_meta_group_count[col_kp1_meta_slot][0] <= ram_i_count[0];
          col_meta_group_count[col_kp1_meta_slot][1] <= ram_i_count[1];
        end
      end

      if (shift_ram_i) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          ram_i_shift_write_ptr[group_idx] <= ram_i_shift_write_ptr_next[group_idx];
          if (shift_ram_i_last) begin
            ram_i_shift_commit_count[group_idx] <= ram_i_shift_write_ptr_next[group_idx];
          end
        end
      end

      if (col_k_meta_advance) begin
        col_k_meta_slot <= col_kp1_meta_slot;
        col_kp1_meta_slot <= col_k_meta_slot;
      end

      if (vnu_cnu_a) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          v2c_m_latched_group_valid[group_idx] <= v2c_group_valid[group_idx];
          v2c_m_latched_row_idx_group[group_idx] <= v2c_row_idx_group[group_idx];
        end
        v2c_m_latched_entry_pos <= v2c_entry_pos;
        v2c_m_latched_col <= v2c_col_idx;
        v2c_m_latched_m_write_pair <= m_write_pair;
      end

      if (iter_check) begin
        syndrome_hist[hist_wr_idx] <= residual_syndrome_next;
      end
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (int pair_idx = 0; pair_idx < 2; pair_idx++) begin
        m_pair_epoch[pair_idx] <= 1'b0;
      end
      for (int port_idx = 0; port_idx < 4; port_idx++) begin
        for (int row_idx = 0; row_idx < ROW_GROUP_DEPTH; row_idx++) begin
          m_row_valid[port_idx][row_idx] <= 1'b0;
          m_row_epoch[port_idx][row_idx] <= 1'b0;
        end
      end
    end else begin
      if (iter_check && !finish_decode) begin
        m_pair_epoch[m_read_pair] <= ~m_pair_epoch[m_read_pair];
      end
      for (int port_idx = 0; port_idx < 4; port_idx++) begin
        if (m_we[port_idx]) begin
          m_row_valid[port_idx][m_write_row_idx_group[port_idx]] <= 1'b1;
          m_row_epoch[port_idx][m_write_row_idx_group[port_idx]] <= m_pair_epoch[m_port_pair(port_idx)];
        end
      end
    end
  end

  assign cnu_a_col_idx = v2c_col_idx;
  assign cnu_a_en[0] = vnu_cnu_a && v2c_group_valid[0];
  assign cnu_a_en[1] = vnu_cnu_a && v2c_group_valid[1];
  assign cnu_a_v2c_msg[0] = vnu_v2c_msg[0];
  assign cnu_a_v2c_msg[1] = vnu_v2c_msg[1];

  always_comb begin
    integer group_idx;
    logic [1:0] port_idx;
    logic port_pair;
    logic [ROW_GROUP_W-1:0] row_addr;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      port_pair = m_write_pair;
      row_addr = v2c_row_idx_group[group_idx];
      port_idx = 2'(m_index(port_pair, GROUP_IDX_W'(group_idx)));
      cnu_a_comp_in[group_idx] = m_comp_or_default(port_idx, port_pair, row_addr, 1'b0);
    end
  end

  always_comb begin
    integer group_idx;
    logic [1:0] port_idx;
    logic port_pair;
    logic [ROW_GROUP_W-1:0] row_addr;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      port_pair = c2v_latched_m_read_pair;
      port_idx = 2'(m_index(port_pair, GROUP_IDX_W'(group_idx)));
      row_addr = c2v_latched_row_idx_group[group_idx];
      cnu_b_comp_in[group_idx] =
        m_comp_or_default(port_idx, port_pair, row_addr, (o_iter_count == '0));
    end
  end

  cnu_a u_cnu_a0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_en(cnu_a_en[0]),
    .i_v2c_msg(cnu_a_v2c_msg[0]),
    .i_col_idx(cnu_a_col_idx),
    .i_comp_c2v(cnu_a_comp_in[0]),
    .o_comp_c2v(cnu_a_comp_out[0]),
    .o_sign(cnu_a_sign[0]),
    .o_valid(cnu_a_valid[0])
  );

  cnu_a u_cnu_a1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_en(cnu_a_en[1]),
    .i_v2c_msg(cnu_a_v2c_msg[1]),
    .i_col_idx(cnu_a_col_idx),
    .i_comp_c2v(cnu_a_comp_in[1]),
    .o_comp_c2v(cnu_a_comp_out[1]),
    .o_sign(cnu_a_sign[1]),
    .o_valid(cnu_a_valid[1])
  );

  cnu_b u_cnu_b0 (
    .i_comp_c2v(cnu_b_comp_in[0]),
    .i_v2c_sign(s_rdata[0]),
    .i_syndrome_bit(i_syndrome[c2v_latched_row_idx_global[0]]),
    .i_col_idx(c2v_latched_col),
    .o_c2v_msg(c2v_msg[0])
  );

  cnu_b u_cnu_b1 (
    .i_comp_c2v(cnu_b_comp_in[1]),
    .i_v2c_sign(s_rdata[1]),
    .i_syndrome_bit(i_syndrome[c2v_latched_row_idx_global[1]]),
    .i_col_idx(c2v_latched_col),
    .o_c2v_msg(c2v_msg[1])
  );

  msg_signmag_to_tc #(
    .D(D),
    .MSG_W(MSG_W),
    .MSG_MAG_LSB(MSG_MAG_LSB),
    .MSG_SIGN_BIT(MSG_SIGN_BIT)
  ) u_c2v_tc_codec0 (
    .i_msg(c2v_msg[0]),
    .o_tc(c2v_tc[0])
  );

  msg_signmag_to_tc #(
    .D(D),
    .MSG_W(MSG_W),
    .MSG_MAG_LSB(MSG_MAG_LSB),
    .MSG_SIGN_BIT(MSG_SIGN_BIT)
  ) u_c2v_tc_codec1 (
    .i_msg(c2v_msg[1]),
    .o_tc(c2v_tc[1])
  );

  assign vnu_col_start = vnu_accum_t && (c2v_latched_entry_pos == '0);
  assign vnu_col_end = vnu_accum_t && c2v_latched_entry_pos_last;
  assign vnu_accum_valid[0] = vnu_accum_t && c2v_latched_group_valid[0];
  assign vnu_accum_valid[1] = vnu_accum_t && c2v_latched_group_valid[1];
  assign vnu_prev_c2v_valid[0] = vnu_cnu_a && t_rvalid[0];
  assign vnu_prev_c2v_valid[1] = vnu_cnu_a && t_rvalid[1];
  assign vnu_prev_c2v[0] = $signed(t_rdata[0]);
  assign vnu_prev_c2v[1] = $signed(t_rdata[1]);

  /* verilator lint_off PINCONNECTEMPTY */
  // Open observation pins keep focused module benches able to inspect the
  // submodules while this top-level uses the data-bearing outputs.
  vnu #(
    .W(W),
    .D(D),
    .MSG_W(MSG_W),
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
    .i_c2v0_valid(vnu_accum_valid[0]),
    .i_c2v0(c2v_tc[0]),
    .i_c2v1_valid(vnu_accum_valid[1]),
    .i_c2v1(c2v_tc[1]),
    .o_c2v_t0_valid(),
    .o_c2v_t0(),
    .o_c2v_t1_valid(),
    .o_c2v_t1(),
    .o_bit_decision(vnu_bit_out),
    .i_c2v_t0_valid(vnu_prev_c2v_valid[0]),
    .i_c2v_t0(vnu_prev_c2v[0]),
    .i_c2v_t1_valid(vnu_prev_c2v_valid[1]),
    .i_c2v_t1(vnu_prev_c2v[1]),
    .o_v2c0_valid(),
    .o_v2c0(vnu_v2c_tc[0]),
    .o_v2c1_valid(),
    .o_v2c1(vnu_v2c_tc[1])
  );
  /* verilator lint_on PINCONNECTEMPTY */

  msg_tc_to_signmag_sat #(
    .D(D),
    .MSG_W(MSG_W),
    .VNU_TC_W(VNU_TC_W),
    .MAG_MAX(MAG_MAX)
  ) u_vnu_v2c_msg_codec0 (
    .i_tc(vnu_v2c_tc[0]),
    .o_msg(vnu_v2c_msg[0])
  );

  msg_tc_to_signmag_sat #(
    .D(D),
    .MSG_W(MSG_W),
    .VNU_TC_W(VNU_TC_W),
    .MAG_MAX(MAG_MAX)
  ) u_vnu_v2c_msg_codec1 (
    .i_tc(vnu_v2c_tc[1]),
    .o_msg(vnu_v2c_msg[1])
  );

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
    .o_phase(phase),
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
  // Open observation pins keep focused module benches able to inspect the
  // submodules while this top-level uses the RAM-I counts.
  ram_i #(
    .INIT_HEX_STEM(RAM_I0_HEX_STEM),
    .INIT_HEX_TAG(RAM_I_HEX_TAG)
  ) u_ram_i0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(ram_i_shift_we[0]),
    .i_h_block_idx(c2v_h_block_idx),
    .i_read_entry_idx(c2v_entry_pos),
    .i_write_entry_idx(ram_i_shift_entry_addr[0]),
    .i_entry_wdata(ram_i_shift_entry_wdata[0]),
    .i_count_we(ram_i_shift_count_we),
    .i_count_wdata(ram_i_shift_count_wdata[0]),
    .o_entry_rdata(ram_i_entry_rdata[0]),
    .o_count(ram_i_count[0]),
    .o_debug_list_entries(),
    .o_debug_counts(ram_i0_debug_count)
  );

  ram_i #(
    .INIT_HEX_STEM(RAM_I1_HEX_STEM),
    .INIT_HEX_TAG(RAM_I_HEX_TAG)
  ) u_ram_i1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(ram_i_shift_we[1]),
    .i_h_block_idx(c2v_h_block_idx),
    .i_read_entry_idx(c2v_entry_pos),
    .i_write_entry_idx(ram_i_shift_entry_addr[1]),
    .i_entry_wdata(ram_i_shift_entry_wdata[1]),
    .i_count_we(ram_i_shift_count_we),
    .i_count_wdata(ram_i_shift_count_wdata[1]),
    .o_entry_rdata(ram_i_entry_rdata[1]),
    .o_count(ram_i_count[1]),
    .o_debug_list_entries(),
    .o_debug_counts(ram_i1_debug_count)
  );

  ram_c u_decision_ram (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(decision_ram_we),
    .i_col_idx(decision_ram_col_idx),
    .i_wdata(decision_ram_wdata),
    .o_rdata(),
    .o_bits(error_estimate_bits)
  );

  ram_m u_ram_m0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[0]),
    .i_read_row_idx_group(m_read_row_idx_group[0]),
    .i_write_row_idx_group(m_write_row_idx_group[0]),
    .i_wdata(m_wdata[0]),
    .o_rdata(m_rdata[0]),
    .o_debug_mem(ram_m0_debug_mem)
  );

  ram_m u_ram_m1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[1]),
    .i_read_row_idx_group(m_read_row_idx_group[1]),
    .i_write_row_idx_group(m_write_row_idx_group[1]),
    .i_wdata(m_wdata[1]),
    .o_rdata(m_rdata[1]),
    .o_debug_mem(ram_m1_debug_mem)
  );

  ram_m u_ram_m2 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[2]),
    .i_read_row_idx_group(m_read_row_idx_group[2]),
    .i_write_row_idx_group(m_write_row_idx_group[2]),
    .i_wdata(m_wdata[2]),
    .o_rdata(m_rdata[2]),
    .o_debug_mem(ram_m2_debug_mem)
  );

  ram_m u_ram_m3 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[3]),
    .i_read_row_idx_group(m_read_row_idx_group[3]),
    .i_write_row_idx_group(m_write_row_idx_group[3]),
    .i_wdata(m_wdata[3]),
    .o_rdata(m_rdata[3]),
    .o_debug_mem(ram_m3_debug_mem)
  );

  ram_s u_ram_s0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(s_we[0]),
    .i_read_col_idx(s_read_col_idx[0]),
    .i_read_entry_idx(s_read_entry_idx[0]),
    .i_write_col_idx(s_write_col_idx[0]),
    .i_write_entry_idx(s_write_entry_idx[0]),
    .i_wdata(s_wdata[0]),
    .o_rdata(s_rdata[0]),
    .o_debug_mem()
  );

  ram_s u_ram_s1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(s_we[1]),
    .i_read_col_idx(s_read_col_idx[1]),
    .i_read_entry_idx(s_read_entry_idx[1]),
    .i_write_col_idx(s_write_col_idx[1]),
    .i_write_entry_idx(s_write_entry_idx[1]),
    .i_wdata(s_wdata[1]),
    .o_rdata(s_rdata[1]),
    .o_debug_mem()
  );

  ram_t u_ram_t0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(iter_check),
    .i_push(t_push[0]),
    .i_pop(t_pop[0]),
    .i_write_entry_idx(t_write_entry_idx),
    .i_read_entry_idx(t_read_entry_idx),
    .i_valid(t_valid[0]),
    .i_wdata(t_wdata[0]),
    .o_rdata(t_rdata[0]),
    .o_valid(t_rvalid[0]),
    .o_item_count(),
    .o_debug_mem()
  );

  ram_t u_ram_t1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clear(iter_check),
    .i_push(t_push[1]),
    .i_pop(t_pop[1]),
    .i_write_entry_idx(t_write_entry_idx),
    .i_read_entry_idx(t_read_entry_idx),
    .i_valid(t_valid[1]),
    .i_wdata(t_wdata[1]),
    .o_rdata(t_rdata[1]),
    .o_valid(t_rvalid[1]),
    .o_item_count(),
    .o_debug_mem()
  );
  /* verilator lint_on PINCONNECTEMPTY */
endmodule
