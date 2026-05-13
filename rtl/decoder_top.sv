`timescale 1ns/1ps
`ifndef BIKE_PKG_EXTERNAL
/* verilator lint_off DECLFILENAME */
// Shared decoder parameters, field layouts, and H-block constants.
package bike_pkg;

  /* verilator lint_off UNUSEDPARAM */

  localparam int N0 = 2;

`ifndef BIKE_TOY_PARAMS
  localparam int R = 12323;
  localparam int W = 71;
  localparam int I_MAX = 6;
  localparam int C_VAL = 7;
  localparam int ALPHA_SHIFT_0 = 4;
  localparam int ALPHA_SHIFT_1 = 0;
`else
  localparam int R = 8;
  localparam int W = 3;
  localparam int I_MAX = 4;
  localparam int C_VAL = 9;
  localparam int ALPHA_SHIFT_0 = 4;
  localparam int ALPHA_SHIFT_1 = 5;
`endif

  localparam int N = N0 * R;
  localparam int L = 2;
  localparam int D = 4;
`ifndef BIKE_TOY_PARAMS
  localparam int RAM_LANE_DEPTH = 40;
`else
  localparam int RAM_LANE_DEPTH = 2;
`endif
  localparam int ENTRY_DEPTH = W;
  localparam int RAM_OVERFLOW_DEPTH = (ENTRY_DEPTH > RAM_LANE_DEPTH) ? (ENTRY_DEPTH - RAM_LANE_DEPTH) : 1;
  localparam int ALPHA_FRAC_W = 6;  //alpha 用6位小数表示
  localparam int MAG_MAX = (1 << D) - 1;
  localparam int MSG_W = D + 1;
  localparam int ROW_SEG_SIZE = (R + L - 1) / L;
  localparam int ROW_GROUP_DEPTH = ROW_SEG_SIZE;
  localparam int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1);
  localparam int COL_W = (N > 1) ? $clog2(N) : 1;
  localparam int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  localparam int H_NUM = 1;

  // Canonical names aligned with h_shift.sv conventions.
  // "one_idx" = index of a "1" within a column (0 .. W-1).
  // "row_idx_global" = global row index (0 .. R-1).
  // "row_idx_group" = row index within a group/lane.
  // "group_idx" = which lane/group (0 .. L-1).
  // "group_count" = number of valid entries in a group's list.
  localparam int ONE_IDX_W   = (W > 1) ? $clog2(W)     : 1;
  localparam int ROW_IDX_W   = (R > 1) ? $clog2(R)     : 1;
  localparam int GROUP_IDX_W = (L > 1) ? $clog2(L)     : 1;
  localparam int ROW_GROUP_W = ROW_IDX_W - GROUP_IDX_W;
  localparam int ENTRY_POS_W = (ENTRY_DEPTH > 1) ? $clog2(ENTRY_DEPTH) : 1;
  localparam int RAM_ENTRY_POS_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH) : 1;
  localparam int RAM_OVERFLOW_POS_W = (RAM_OVERFLOW_DEPTH > 1) ? $clog2(RAM_OVERFLOW_DEPTH) : 1;
  localparam int GROUP_COUNT_W = (ENTRY_DEPTH > 1) ? $clog2(ENTRY_DEPTH + 1) : 1;

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START       = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_C2V_PRIME   = 4'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_OVERLAP     = 4'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_V2C_DRAIN   = 4'd6;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CHECK       = 4'd8;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE             = 4'd9;

  localparam int DEC_PHASE_W = 5;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_WAIT                = 5'd0;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PRIME_READ          = 5'd7;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PRIME_WRITE         = 5'd8;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_ACCUM_READ  = 5'd9;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_ACCUM_USE   = 5'd10;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_PREP        = 5'd11;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_EMIT_READ   = 5'd12;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_EMIT_CNU_A  = 5'd13;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_OVERLAP_EMIT_WRITE  = 5'd14;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PROD_FINISH_READ    = 5'd15;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_PROD_FINISH_WRITE   = 5'd16;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_ACCUM_READ    = 5'd17;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_ACCUM_USE     = 5'd18;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_PREP          = 5'd19;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_EMIT_READ     = 5'd20;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_EMIT_CNU_A    = 5'd21;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DRAIN_EMIT_WRITE    = 5'd22;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_ITER_CHECK          = 5'd23;
  localparam logic [DEC_PHASE_W-1:0] DEC_PH_DONE                = 5'd24;

  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int COMP_C2V_MIN1_LSB = 0;
  localparam int COMP_C2V_MIN2_LSB = COMP_C2V_MIN1_LSB + D;
  localparam int COMP_C2V_MIN_ID_LSB = COMP_C2V_MIN2_LSB + D;
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_ID_LSB + COL_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {
    1'b0,
    COL_W'(0),
    D'(MAG_MAX),
    D'(MAG_MAX)
  };

  localparam int I_ENTRY_ROW_IDX_GROUP_LSB = 0;
  localparam int I_ENTRY_ONE_IDX_LSB = I_ENTRY_ROW_IDX_GROUP_LSB + ROW_GROUP_W;
  localparam int I_ENTRY_W = I_ENTRY_ONE_IDX_LSB + ONE_IDX_W;

`ifndef BIKE_TOY_PARAMS
  localparam int unsigned H_BASE [0:H_NUM-1][0:N0-1][0:W-1] = '{
    '{
      '{
        142, 389, 492, 630, 744, 1009, 1245, 1264, 1371, 1458,
        1627, 2227, 2691, 2732, 2779, 2861, 2893, 3031, 3103, 3719,
        3768, 3838, 4146, 4173, 4303, 4328, 4406, 4578, 4604, 4723,
        4815, 4835, 4909, 4977, 5202, 5239, 5320, 5577, 5641, 5878,
        6568, 6586, 6674, 6821, 6936, 7185, 7340, 7386, 7445, 8036,
        8091, 8219, 8453, 8551, 9062, 9387, 9442, 9991, 10526, 10595,
        10650, 10781, 11467, 11539, 11571, 11872, 12050, 12120, 12128, 12228,
        12250
      },
      '{
        393, 407, 445, 464, 537, 568, 1230, 1336, 1575, 1602,
        1647, 1713, 1749, 1800, 1802, 1817, 1868, 1986, 2065, 2498,
        2744, 2747, 3097, 3290, 3395, 3460, 3526, 3755, 3843, 3848,
        3850, 3856, 4580, 4790, 5558, 6127, 6417, 6758, 6866, 7017,
        7038, 7065, 7269, 7564, 8075, 8681, 8734, 8796, 8917, 9011,
        9311, 9401, 9545, 9637, 9698, 9776, 9886, 10026, 10270, 10310,
        10385, 10444, 10608, 10711, 11034, 11171, 11301, 11475, 11578, 12091,
        12130
      }
    }
  };
`else
  localparam int unsigned H_BASE [0:H_NUM-1][0:N0-1][0:W-1] = '{
    '{
      '{0, 1, 3},
      '{0, 2, 5}
    }
  };
`endif
  /* verilator lint_on UNUSEDPARAM */
endpackage
/* verilator lint_on DECLFILENAME */
`endif

// Top-level BIKE min-sum decoder datapath and module interconnect.
module decoder_top
  import bike_pkg::*;
#(
  parameter string RAM_I0_HEX_STEM = "rtl/generated/ram_i0",
  parameter string RAM_I1_HEX_STEM = "rtl/generated/ram_i1",
`ifndef BIKE_TOY_PARAMS
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
  input  logic [COL_W-1:0] i_e_read_col_idx,    // Column address for serial error-estimate readout.
  output logic o_done,                          // High when decoding has finished.
  output logic o_success,                       // High when the final residual syndrome is zero.
  output logic o_e_rdata,                       // Error-estimate bit at i_e_read_col_idx.
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
  localparam int S_PACK_W = 8;
  localparam int S_WORDS_PER_COL = (ENTRY_DEPTH + S_PACK_W - 1) / S_PACK_W;
  localparam int S_WORD_DEPTH = N * S_WORDS_PER_COL;
  localparam int S_WORD_ADDR_W = (S_WORD_DEPTH > 1) ? $clog2(S_WORD_DEPTH) : 1;
  localparam int S_PACK_IDX_W = (S_PACK_W > 1) ? $clog2(S_PACK_W) : 1;

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
`ifdef BIKE_SIM_DEBUG
  logic [R-1:0] syndrome_hist [0:I_MAX-1];
  logic [GROUP_COUNT_W-1:0] ram_i_debug_count [0:N0-1][0:L-1];
`endif
  /* verilator lint_on UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] ram_i_entry_rdata [0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_count [0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_overflow_count [0:N0-1][0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_overflow_entries [0:N0-1][0:L-1][0:RAM_OVERFLOW_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] ram_i_total_count [0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_selected_entry [0:L-1];
  logic ram_i_read_overflow_d1 [0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_overflow_entry_d1 [0:L-1];

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
  logic [GROUP_COUNT_W-1:0] col_meta_group_count [0:1][0:L-1];
  logic [I_ENTRY_W-1:0] col_meta_group_entries [0:1][0:L-1][0:ENTRY_DEPTH-1];
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
  logic [RAM_ENTRY_POS_W-1:0] ram_i_shift_entry_addr [0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_shift_entry_wdata [0:L-1];
  logic ram_i_shift_overflow_we [0:L-1];
  logic [RAM_OVERFLOW_POS_W-1:0] ram_i_shift_overflow_addr [0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_shift_overflow_wdata [0:L-1];
  logic [GROUP_COUNT_W-1:0] ram_i_shift_overflow_count_wdata [0:L-1];
  logic c2v_read_d1;
  logic [COL_W-1:0] c2v_read_col_d1;
  logic [ENTRY_POS_W-1:0] c2v_read_entry_pos_d1;
  logic c2v_read_entry_pos_last_d1;
  logic c2v_read_m_read_pair_d1;
  logic [GROUP_COUNT_W-1:0] c2v_read_count_d1 [0:L-1];
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
  logic [COL_W-1:0] v2c_read_col_d1;
  logic [ENTRY_POS_W-1:0] v2c_read_entry_pos_d1;
  logic v2c_read_m_write_pair_d1;
  logic v2c_read_group_valid_d1 [0:L-1];
  logic [ROW_GROUP_W-1:0] v2c_read_row_idx_group_d1 [0:L-1];

  logic [R-1:0] residual_syndrome_next;
  logic [R-1:0] residual_syndrome;
  logic decode_success;
  logic finish_decode;
  logic decision_ram_old_bit;
  logic decision_update_pending;
  logic [COL_W-1:0] decision_update_col;
  logic decision_update_new_bit;
  logic [ITER_W:0] next_iter_count_ext;
`ifdef BIKE_SIM_DEBUG
  logic [HIST_IDX_W-1:0] hist_wr_idx;
`endif

`ifdef BIKE_SIM_DEBUG
  logic [GROUP_COUNT_W-1:0] ram_i0_debug_count [0:N0-1];
  logic [GROUP_COUNT_W-1:0] ram_i1_debug_count [0:N0-1];
`endif

  // Paper-style RAM port steering. Each block is single-port, so the top
  // centralizes all enables, addresses, and write data here.
  logic m_we [0:3];
  logic [ROW_GROUP_W-1:0] m_read_row_idx_group [0:3];
  logic [ROW_GROUP_W-1:0] m_write_row_idx_group [0:3];
  logic [COMP_C2V_W-1:0] m_wdata [0:3];
  logic [COMP_C2V_W-1:0] m_rdata [0:3];
  logic m_repoch [0:3];
  logic m_pair_epoch [0:1];
`ifdef BIKE_SIM_DEBUG
  /* verilator lint_off UNUSEDSIGNAL */
  logic [COMP_C2V_W-1:0] ram_m0_debug_mem [0:ROW_GROUP_DEPTH-1];
  logic [COMP_C2V_W-1:0] ram_m1_debug_mem [0:ROW_GROUP_DEPTH-1];
  logic [COMP_C2V_W-1:0] ram_m2_debug_mem [0:ROW_GROUP_DEPTH-1];
  logic [COMP_C2V_W-1:0] ram_m3_debug_mem [0:ROW_GROUP_DEPTH-1];
  /* verilator lint_on UNUSEDSIGNAL */
`endif

  logic s_we [0:L-1];
  logic [COL_W-1:0] s_read_col_idx [0:L-1];
  logic [ENTRY_POS_W-1:0] s_read_entry_idx [0:L-1];
  logic [ENTRY_POS_W-1:0] s_write_entry_idx [0:L-1];
  logic s_wdata [0:L-1];
  logic s_rdata [0:L-1];
  logic s_word_we [0:L-1];
  logic [S_WORD_ADDR_W-1:0] s_read_word_addr [0:L-1];
  logic [S_WORD_ADDR_W-1:0] s_write_word_addr [0:L-1];
  logic [S_PACK_W-1:0] s_word_wdata [0:L-1];
  logic [S_PACK_W-1:0] s_word_rdata [0:L-1];
  logic [S_PACK_W-1:0] s_read_shift [0:L-1];
  logic [S_PACK_W-1:0] s_write_shift [0:L-1];
  logic s_read_word_load_pending [0:L-1];

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
  logic [COL_W-1:0] decision_ram_access_col_idx;
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
    input logic [ENTRY_POS_W-1:0] entry_idx,
    input logic sign_bit
  );
    begin
      s_we[group_idx] = 1'b1;
      s_write_entry_idx[group_idx] = entry_idx;
      s_wdata[group_idx] = sign_bit;
    end
  endtask

  function automatic logic [S_WORD_ADDR_W-1:0] s_word_addr(
    input logic [COL_W-1:0] col_idx,
    input logic [ENTRY_POS_W-1:0] entry_idx
  );
    begin
      s_word_addr = S_WORD_ADDR_W'(int'(col_idx) * S_WORDS_PER_COL + int'(entry_idx) / S_PACK_W);
    end
  endfunction

  function automatic logic [S_PACK_IDX_W-1:0] s_word_bit_idx(
    input logic [ENTRY_POS_W-1:0] entry_idx
  );
    begin
      s_word_bit_idx = S_PACK_IDX_W'(int'(entry_idx) % S_PACK_W);
    end
  endfunction

  function automatic logic entry_in_ram_i_main(
    input logic [ENTRY_POS_W-1:0] entry_idx
  );
    begin
      entry_in_ram_i_main = (int'(entry_idx) < RAM_LANE_DEPTH);
    end
  endfunction

  function automatic logic [RAM_ENTRY_POS_W-1:0] ram_i_main_addr(
    input logic [ENTRY_POS_W-1:0] entry_idx
  );
    begin
      ram_i_main_addr = RAM_ENTRY_POS_W'(int'(entry_idx));
    end
  endfunction

  function automatic logic [RAM_OVERFLOW_POS_W-1:0] ram_i_overflow_addr(
    input logic [ENTRY_POS_W-1:0] entry_idx
  );
    begin
      ram_i_overflow_addr = RAM_OVERFLOW_POS_W'(int'(entry_idx) - RAM_LANE_DEPTH);
    end
  endfunction

  function automatic logic [GROUP_COUNT_W-1:0] ram_i_main_count_from_total(
    input logic [GROUP_COUNT_W-1:0] total_count
  );
    begin
      if (int'(total_count) > RAM_LANE_DEPTH) begin
        ram_i_main_count_from_total = GROUP_COUNT_W'(RAM_LANE_DEPTH);
      end else begin
        ram_i_main_count_from_total = total_count;
      end
    end
  endfunction

  function automatic logic [GROUP_COUNT_W-1:0] ram_i_overflow_count_from_total(
    input logic [GROUP_COUNT_W-1:0] total_count
  );
    begin
      if (int'(total_count) > RAM_LANE_DEPTH) begin
        ram_i_overflow_count_from_total = GROUP_COUNT_W'(int'(total_count) - RAM_LANE_DEPTH);
      end else begin
        ram_i_overflow_count_from_total = '0;
      end
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] m_write_comp_or_init(
    input logic [1:0] port_idx
  );
    begin
      if (m_repoch[port_idx] == m_pair_epoch[port_idx[1]]) begin
        m_write_comp_or_init = m_rdata[port_idx];
      end else begin
        m_write_comp_or_init = COMP_C2V_INIT;
      end
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] m_read_comp_or_first(
    input logic [1:0] port_idx,
    input logic use_first_iter_default
  );
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
  assign decode_success = (residual_syndrome_next == '0);
  assign finish_decode = decode_success || (next_iter_count_ext >= (ITER_W + 1)'(I_MAX));
  assign c2v_h_block_idx = H_BLOCK_W'(int'(c2v_col_idx) / R);
  assign decision_ram_access_col_idx = decision_ram_we ? decision_ram_col_idx : i_e_read_col_idx;

  always_comb begin
    integer group_idx;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      ram_i_total_count[group_idx] =
        ram_i_count[group_idx] + ram_i_overflow_count[c2v_h_block_idx][group_idx];
      ram_i_selected_entry[group_idx] =
        ram_i_read_overflow_d1[group_idx] ? ram_i_overflow_entry_d1[group_idx] : ram_i_entry_rdata[group_idx];
    end
  end

  always_comb begin
    integer group_idx;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      s_rdata[group_idx] =
        s_read_word_load_pending[group_idx] ? s_word_rdata[group_idx][0] : s_read_shift[group_idx][0];
    end
  end

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

`ifdef BIKE_SIM_DEBUG
  // Aggregate the two group RAM-I debug counts into the shape expected by
  // the testbench.
  always_comb begin
    integer h_block_idx;

    for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      ram_i_debug_count[h_block_idx][0] = ram_i0_debug_count[h_block_idx];
      ram_i_debug_count[h_block_idx][1] = ram_i1_debug_count[h_block_idx];
    end
  end
`endif

  // Decide whether each c2v/v2c column cursor is at the last active group
  // list position for the current column.
  always_comb begin
    integer c2v_max_count;
    integer v2c_max_count;

    c2v_max_count = int'(ram_i_total_count[0]);
    if (int'(ram_i_total_count[1]) > c2v_max_count) begin
      c2v_max_count = int'(ram_i_total_count[1]);
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
        c2v_read_d1 && (int'(c2v_read_entry_pos_d1) < int'(c2v_read_count_d1[group_idx]));
      c2v_one_idx[group_idx] =
        ram_i_selected_entry[group_idx][I_ENTRY_ONE_IDX_LSB +: ONE_IDX_W];
      c2v_row_idx_group[group_idx] =
        ram_i_selected_entry[group_idx][I_ENTRY_ROW_IDX_GROUP_LSB +: ROW_GROUP_W];
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
      ram_i_shift_entry_addr[group_idx] = ram_i_main_addr(c2v_latched_entry_pos);
      ram_i_shift_entry_wdata[group_idx] = '0;
      ram_i_shift_overflow_we[group_idx] = 1'b0;
      ram_i_shift_overflow_addr[group_idx] = '0;
      ram_i_shift_overflow_wdata[group_idx] = '0;
      ram_i_shift_overflow_count_wdata[group_idx] =
        ram_i_overflow_count_from_total(ram_i_shift_commit_count[group_idx]);
      bank_has_write[group_idx] = 1'b0;
    end

    for (group_idx = 0; group_idx < L; group_idx++) begin
      if (ram_i_shift_pending_count[group_idx] != 2'd0) begin
        if (entry_in_ram_i_main(ram_i_shift_pending_addr[group_idx][0])) begin
          ram_i_shift_we[group_idx] = 1'b1;
          ram_i_shift_entry_addr[group_idx] =
            ram_i_main_addr(ram_i_shift_pending_addr[group_idx][0]);
          ram_i_shift_entry_wdata[group_idx] = ram_i_shift_pending_wdata[group_idx][0];
        end else begin
          ram_i_shift_overflow_we[group_idx] = 1'b1;
          ram_i_shift_overflow_addr[group_idx] =
            ram_i_overflow_addr(ram_i_shift_pending_addr[group_idx][0]);
          ram_i_shift_overflow_wdata[group_idx] = ram_i_shift_pending_wdata[group_idx][0];
        end
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
          if (entry_in_ram_i_main(ENTRY_POS_W'(ram_i_shift_write_ptr_next[target_idx]))) begin
            ram_i_shift_we[target_idx] = 1'b1;
            ram_i_shift_entry_addr[target_idx] =
              ram_i_main_addr(ENTRY_POS_W'(ram_i_shift_write_ptr_next[target_idx]));
            ram_i_shift_entry_wdata[target_idx] = shifted_entry;
          end else begin
            ram_i_shift_overflow_we[target_idx] = 1'b1;
            ram_i_shift_overflow_addr[target_idx] =
              ram_i_overflow_addr(ENTRY_POS_W'(ram_i_shift_write_ptr_next[target_idx]));
            ram_i_shift_overflow_wdata[target_idx] = shifted_entry;
          end
          bank_has_write[target_idx] = 1'b1;
        end

        ram_i_shift_write_ptr_next[target_idx] =
          ram_i_shift_write_ptr_next[target_idx] + 1'b1;
      end
    end

    if (shift_ram_i_last) begin
      ram_i_shift_commit_pending_next = 1'b1;
      for (group_idx = 0; group_idx < L; group_idx++) begin
        ram_i_shift_count_wdata[group_idx] =
          ram_i_main_count_from_total(ram_i_shift_write_ptr_next[group_idx]);
        ram_i_shift_overflow_count_wdata[group_idx] =
          ram_i_overflow_count_from_total(ram_i_shift_write_ptr_next[group_idx]);
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

    if (c2v_read_d1) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        if (c2v_group_valid[group_idx]) begin
          set_m_read_row(c2v_read_m_read_pair_d1, GROUP_IDX_W'(group_idx), c2v_row_idx_group[group_idx]);
        end
      end
    end

    if (v2c_read) begin
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
    logic [S_PACK_IDX_W-1:0] write_bit_idx;
    logic write_group_last;

    write_bit_idx = '0;
    write_group_last = 1'b0;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      s_we[group_idx] = 1'b0;
      s_read_col_idx[group_idx] = c2v_read_d1 ? c2v_read_col_d1 : c2v_col_idx;
      s_read_entry_idx[group_idx] = c2v_read_d1 ? c2v_read_entry_pos_d1 : c2v_entry_pos;
      s_write_entry_idx[group_idx] = c2v_latched_entry_pos;
      s_wdata[group_idx] = 1'b0;
      s_word_we[group_idx] = 1'b0;
      s_read_word_addr[group_idx] =
        s_word_addr(s_read_col_idx[group_idx], s_read_entry_idx[group_idx]);
      s_write_word_addr[group_idx] = '0;
      s_word_wdata[group_idx] = '0;
    end

    if (vnu_write_next) begin
      for (group_idx = 0; group_idx < L; group_idx++) begin
        if (cnu_a_valid[group_idx] && v2c_m_latched_group_valid[group_idx]) begin
          set_s_write_bit(
            GROUP_IDX_W'(group_idx),
            v2c_m_latched_entry_pos,
            cnu_a_sign[group_idx]
          );
          write_bit_idx = s_word_bit_idx(v2c_m_latched_entry_pos);
          write_group_last =
            ((int'(v2c_m_latched_entry_pos) + 1) >=
             int'(col_meta_group_count[col_k_meta_slot][group_idx]));
          s_write_word_addr[group_idx] =
            s_word_addr(v2c_m_latched_col, v2c_m_latched_entry_pos);
          s_word_wdata[group_idx] = s_write_shift[group_idx];
          s_word_wdata[group_idx][write_bit_idx] = cnu_a_sign[group_idx];
          s_word_we[group_idx] = (write_bit_idx == S_PACK_IDX_W'(S_PACK_W - 1)) || write_group_last;
        end
      end
    end
  end

  // RAM-T steering for producer c2v messages.
  always_comb begin
    integer group_idx;

    t_write_entry_idx = c2v_latched_entry_pos;
    t_read_entry_idx = v2c_read ? v2c_entry_pos : v2c_read_entry_pos_d1;
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

  // Track the residual syndrome incrementally when a hard-decision bit changes.
  always_comb begin
    integer one_idx;
    logic [H_BLOCK_W-1:0] residual_h_block_idx;
    integer residual_col;
    logic [ROW_IDX_W-1:0] residual_row;

    residual_syndrome_next = residual_syndrome;
    residual_h_block_idx = '0;
    residual_col = 0;
    residual_row = '0;

    if (decision_update_pending &&
        (((o_iter_count == '0) ? 1'b0 : decision_ram_old_bit) != decision_update_new_bit)) begin
      residual_h_block_idx = H_BLOCK_W'(int'(decision_update_col) / R);
      residual_col = int'(decision_update_col) % R;
      for (one_idx = 0; one_idx < W; one_idx++) begin
        residual_row = ROW_IDX_W'((H_BASE[0][residual_h_block_idx][one_idx] + residual_col) % R);
        residual_syndrome_next[residual_row] = residual_syndrome_next[residual_row] ^ 1'b1;
      end
    end
  end

  // Sequential latches that bridge the single-port memories and the multi-cycle
  // control schedule. These registers keep the edge metadata stable across the
  // c2v/v2c handoff.
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer idx;
    integer group_idx;
    integer h_block_idx;
    integer one_idx;
    integer init_entry_idx [0:N0-1][0:L-1];

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
      residual_syndrome <= '0;
      decision_update_pending <= 1'b0;
      decision_update_col <= '0;
      decision_update_new_bit <= 1'b0;
      for (group_idx = 0; group_idx < L; group_idx++) begin
        c2v_read_count_d1[group_idx] <= '0;
        ram_i_read_overflow_d1[group_idx] <= 1'b0;
        ram_i_overflow_entry_d1[group_idx] <= '0;
        v2c_read_group_valid_d1[group_idx] <= 1'b0;
        v2c_read_row_idx_group_d1[group_idx] <= '0;
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
        s_read_shift[group_idx] <= '0;
        s_write_shift[group_idx] <= '0;
        s_read_word_load_pending[group_idx] <= 1'b0;
        for (idx = 0; idx < ENTRY_DEPTH; idx++) begin
          col_meta_group_entries[0][group_idx][idx] <= '0;
          col_meta_group_entries[1][group_idx][idx] <= '0;
        end
        col_meta_group_count[0][group_idx] <= '0;
        col_meta_group_count[1][group_idx] <= '0;
      end
      for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          init_entry_idx[h_block_idx][group_idx] = 0;
          ram_i_overflow_count[h_block_idx][group_idx] <= '0;
          for (idx = 0; idx < RAM_OVERFLOW_DEPTH; idx++) begin
            ram_i_overflow_entries[h_block_idx][group_idx][idx] <= '0;
          end
        end
      end
      for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (one_idx = 0; one_idx < W; one_idx++) begin
          group_idx = H_BASE[0][h_block_idx][one_idx] & 1;
          if (init_entry_idx[h_block_idx][group_idx] >= RAM_LANE_DEPTH) begin
            ram_i_overflow_entries
              [h_block_idx]
              [group_idx]
              [init_entry_idx[h_block_idx][group_idx] - RAM_LANE_DEPTH] <= {
                ONE_IDX_W'(one_idx),
                ROW_GROUP_W'(H_BASE[0][h_block_idx][one_idx] >> 1)
              };
          end
          init_entry_idx[h_block_idx][group_idx] =
            init_entry_idx[h_block_idx][group_idx] + 1;
        end
      end
      for (h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          if (init_entry_idx[h_block_idx][group_idx] > RAM_LANE_DEPTH) begin
            ram_i_overflow_count[h_block_idx][group_idx] <=
              GROUP_COUNT_W'(init_entry_idx[h_block_idx][group_idx] - RAM_LANE_DEPTH);
          end
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
      residual_syndrome <= residual_syndrome_next;
      decision_update_pending <= decision_ram_we;
      if (decision_ram_we) begin
        decision_update_col <= decision_ram_col_idx;
        decision_update_new_bit <= decision_ram_wdata;
      end
      if (i_start) begin
        residual_syndrome <= i_syndrome;
        decision_update_pending <= 1'b0;
        for (group_idx = 0; group_idx < L; group_idx++) begin
          s_read_shift[group_idx] <= '0;
          s_write_shift[group_idx] <= '0;
          s_read_word_load_pending[group_idx] <= 1'b0;
        end
      end

      c2v_read_d1 <= c2v_read;
      if (c2v_read) begin
        c2v_read_col_d1 <= c2v_col_idx;
        c2v_read_entry_pos_d1 <= c2v_entry_pos;
        c2v_read_entry_pos_last_d1 <= c2v_entry_pos_last;
        c2v_read_m_read_pair_d1 <= m_read_pair;
        for (group_idx = 0; group_idx < L; group_idx++) begin
          c2v_read_count_d1[group_idx] <= ram_i_total_count[group_idx];
          ram_i_read_overflow_d1[group_idx] <=
            entry_in_ram_i_main(c2v_entry_pos) ? 1'b0 :
            (int'(c2v_entry_pos) < int'(ram_i_total_count[group_idx]));
          if (int'(c2v_entry_pos) >= RAM_LANE_DEPTH) begin
            ram_i_overflow_entry_d1[group_idx] <=
              ram_i_overflow_entries[c2v_h_block_idx][group_idx][ram_i_overflow_addr(c2v_entry_pos)];
          end else begin
            ram_i_overflow_entry_d1[group_idx] <= '0;
          end
        end
      end

      if (v2c_read) begin
        v2c_read_col_d1 <= v2c_col_idx;
        v2c_read_entry_pos_d1 <= v2c_entry_pos;
        v2c_read_m_write_pair_d1 <= m_write_pair;
        for (group_idx = 0; group_idx < L; group_idx++) begin
          v2c_read_group_valid_d1[group_idx] <= v2c_group_valid[group_idx];
          v2c_read_row_idx_group_d1[group_idx] <= v2c_row_idx_group[group_idx];
        end
      end

      ram_i_shift_commit_pending <= ram_i_shift_commit_pending_next;
      for (group_idx = 0; group_idx < L; group_idx++) begin
        s_read_word_load_pending[group_idx] <=
          c2v_read_d1 && (s_word_bit_idx(s_read_entry_idx[group_idx]) == '0);
        if (s_read_word_load_pending[group_idx]) begin
          s_read_shift[group_idx] <= {{1{1'b0}}, s_word_rdata[group_idx][S_PACK_W-1:1]};
        end else if (c2v_write_t) begin
          s_read_shift[group_idx] <= {{1{1'b0}}, s_read_shift[group_idx][S_PACK_W-1:1]};
        end
        if (s_we[group_idx]) begin
          s_write_shift[group_idx][s_word_bit_idx(s_write_entry_idx[group_idx])] <=
            s_wdata[group_idx];
          if (s_word_we[group_idx]) begin
            s_write_shift[group_idx] <= '0;
          end
        end
        ram_i_shift_pending_count[group_idx] <= ram_i_shift_pending_count_next[group_idx];
        ram_i_shift_pending_addr[group_idx][0] <= ram_i_shift_pending_addr_next[group_idx][0];
        ram_i_shift_pending_addr[group_idx][1] <= ram_i_shift_pending_addr_next[group_idx][1];
        ram_i_shift_pending_addr[group_idx][2] <= ram_i_shift_pending_addr_next[group_idx][2];
        ram_i_shift_pending_wdata[group_idx][0] <= ram_i_shift_pending_wdata_next[group_idx][0];
        ram_i_shift_pending_wdata[group_idx][1] <= ram_i_shift_pending_wdata_next[group_idx][1];
        ram_i_shift_pending_wdata[group_idx][2] <= ram_i_shift_pending_wdata_next[group_idx][2];
      end

      if (c2v_read_d1) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          c2v_latched_group_valid[group_idx] <= c2v_group_valid[group_idx];
          c2v_latched_one_idx[group_idx] <= c2v_one_idx[group_idx];
          c2v_latched_row_idx_group[group_idx] <= c2v_row_idx_group[group_idx];
          c2v_latched_row_idx_global[group_idx] <= c2v_row_idx_global[group_idx];
          col_meta_group_entries[col_kp1_meta_slot][group_idx][c2v_read_entry_pos_d1] <=
            ram_i_selected_entry[group_idx];
        end
        c2v_latched_col <= c2v_read_col_d1;
        c2v_latched_entry_pos <= c2v_read_entry_pos_d1;
        c2v_latched_entry_pos_last <= c2v_read_entry_pos_last_d1;
        c2v_latched_m_read_pair <= c2v_read_m_read_pair_d1;
        if (c2v_read_entry_pos_d1 == '0) begin
          col_meta_group_count[col_kp1_meta_slot][0] <= c2v_read_count_d1[0];
          col_meta_group_count[col_kp1_meta_slot][1] <= c2v_read_count_d1[1];
        end
      end

      if (shift_ram_i) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          ram_i_shift_write_ptr[group_idx] <= ram_i_shift_write_ptr_next[group_idx];
          if (ram_i_shift_overflow_we[group_idx]) begin
            ram_i_overflow_entries[c2v_h_block_idx][group_idx][ram_i_shift_overflow_addr[group_idx]] <=
              ram_i_shift_overflow_wdata[group_idx];
          end
          if (shift_ram_i_last) begin
            ram_i_shift_commit_count[group_idx] <= ram_i_shift_write_ptr_next[group_idx];
          end
        end
      end

      if (ram_i_shift_count_we) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          ram_i_overflow_count[c2v_h_block_idx][group_idx] <=
            ram_i_shift_overflow_count_wdata[group_idx];
        end
      end

      if (col_k_meta_advance) begin
        col_k_meta_slot <= col_kp1_meta_slot;
        col_kp1_meta_slot <= col_k_meta_slot;
      end

      if (vnu_cnu_a) begin
        for (group_idx = 0; group_idx < L; group_idx++) begin
          v2c_m_latched_group_valid[group_idx] <= v2c_read_group_valid_d1[group_idx];
          v2c_m_latched_row_idx_group[group_idx] <= v2c_read_row_idx_group_d1[group_idx];
        end
        v2c_m_latched_entry_pos <= v2c_read_entry_pos_d1;
        v2c_m_latched_col <= v2c_read_col_d1;
        v2c_m_latched_m_write_pair <= v2c_read_m_write_pair_d1;
      end

`ifdef BIKE_SIM_DEBUG
      if (iter_check) begin
        syndrome_hist[hist_wr_idx] <= residual_syndrome_next;
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
  assign cnu_a_en[0] = vnu_cnu_a && v2c_read_group_valid_d1[0];
  assign cnu_a_en[1] = vnu_cnu_a && v2c_read_group_valid_d1[1];
  assign cnu_a_v2c_msg[0] = vnu_v2c_msg[0];
  assign cnu_a_v2c_msg[1] = vnu_v2c_msg[1];

  always_comb begin
    integer group_idx;
    logic [1:0] port_idx;
    logic port_pair;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      port_pair = v2c_read_m_write_pair_d1;
      port_idx = 2'(m_index(port_pair, GROUP_IDX_W'(group_idx)));
      cnu_a_comp_in[group_idx] = m_write_comp_or_init(port_idx);
    end
  end

  always_comb begin
    integer group_idx;
    logic [1:0] port_idx;
    logic port_pair;

    for (group_idx = 0; group_idx < L; group_idx++) begin
      port_pair = c2v_latched_m_read_pair;
      port_idx = 2'(m_index(port_pair, GROUP_IDX_W'(group_idx)));
      cnu_b_comp_in[group_idx] =
        m_read_comp_or_first(port_idx, (o_iter_count == '0));
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
    .i_read_entry_idx(ram_i_main_addr(c2v_entry_pos)),
    .i_write_entry_idx(ram_i_shift_entry_addr[0]),
    .i_entry_wdata(ram_i_shift_entry_wdata[0]),
    .i_count_we(ram_i_shift_count_we),
    .i_count_wdata(ram_i_shift_count_wdata[0]),
    .o_entry_rdata(ram_i_entry_rdata[0]),
    .o_count(ram_i_count[0])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_list_entries(),
    .o_debug_counts(ram_i0_debug_count)
`endif
  );

  ram_i #(
    .INIT_HEX_STEM(RAM_I1_HEX_STEM),
    .INIT_HEX_TAG(RAM_I_HEX_TAG)
  ) u_ram_i1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(ram_i_shift_we[1]),
    .i_h_block_idx(c2v_h_block_idx),
    .i_read_entry_idx(ram_i_main_addr(c2v_entry_pos)),
    .i_write_entry_idx(ram_i_shift_entry_addr[1]),
    .i_entry_wdata(ram_i_shift_entry_wdata[1]),
    .i_count_we(ram_i_shift_count_we),
    .i_count_wdata(ram_i_shift_count_wdata[1]),
    .o_entry_rdata(ram_i_entry_rdata[1]),
    .o_count(ram_i_count[1])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_list_entries(),
    .o_debug_counts(ram_i1_debug_count)
`endif
  );

  ram_c u_decision_ram (
    .i_clk(i_clk),
    .i_we(decision_ram_we),
    .i_col_idx(decision_ram_access_col_idx),
    .i_wdata(decision_ram_wdata),
    .o_rdata(decision_ram_old_bit)
  );

  assign o_e_rdata = decision_ram_old_bit;

  ram_m u_ram_m0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[0]),
    .i_read_row_idx_group(m_read_row_idx_group[0]),
    .i_write_row_idx_group(m_write_row_idx_group[0]),
    .i_epoch(m_pair_epoch[0]),
    .i_wdata(m_wdata[0]),
    .o_rdata(m_rdata[0]),
    .o_epoch(m_repoch[0])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_mem(ram_m0_debug_mem)
`endif
  );

  ram_m u_ram_m1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[1]),
    .i_read_row_idx_group(m_read_row_idx_group[1]),
    .i_write_row_idx_group(m_write_row_idx_group[1]),
    .i_epoch(m_pair_epoch[0]),
    .i_wdata(m_wdata[1]),
    .o_rdata(m_rdata[1]),
    .o_epoch(m_repoch[1])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_mem(ram_m1_debug_mem)
`endif
  );

  ram_m u_ram_m2 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[2]),
    .i_read_row_idx_group(m_read_row_idx_group[2]),
    .i_write_row_idx_group(m_write_row_idx_group[2]),
    .i_epoch(m_pair_epoch[1]),
    .i_wdata(m_wdata[2]),
    .o_rdata(m_rdata[2]),
    .o_epoch(m_repoch[2])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_mem(ram_m2_debug_mem)
`endif
  );

  ram_m u_ram_m3 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(m_we[3]),
    .i_read_row_idx_group(m_read_row_idx_group[3]),
    .i_write_row_idx_group(m_write_row_idx_group[3]),
    .i_epoch(m_pair_epoch[1]),
    .i_wdata(m_wdata[3]),
    .o_rdata(m_rdata[3]),
    .o_epoch(m_repoch[3])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_mem(ram_m3_debug_mem)
`endif
  );

  ram_s #(
    .S_PACK_W(S_PACK_W),
    .S_WORDS_PER_COL(S_WORDS_PER_COL),
    .S_WORD_DEPTH(S_WORD_DEPTH),
    .S_WORD_ADDR_W(S_WORD_ADDR_W)
  ) u_ram_s0 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(s_word_we[0]),
    .i_read_word_addr(s_read_word_addr[0]),
    .i_write_word_addr(s_write_word_addr[0]),
    .i_wdata(s_word_wdata[0]),
    .o_rdata(s_word_rdata[0])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_mem()
`endif
  );

  ram_s #(
    .S_PACK_W(S_PACK_W),
    .S_WORDS_PER_COL(S_WORDS_PER_COL),
    .S_WORD_DEPTH(S_WORD_DEPTH),
    .S_WORD_ADDR_W(S_WORD_ADDR_W)
  ) u_ram_s1 (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_we(s_word_we[1]),
    .i_read_word_addr(s_read_word_addr[1]),
    .i_write_word_addr(s_write_word_addr[1]),
    .i_wdata(s_word_wdata[1]),
    .o_rdata(s_word_rdata[1])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_debug_mem()
`endif
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
    .o_valid(t_rvalid[0])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_item_count(),
    .o_debug_mem()
`endif
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
    .o_valid(t_rvalid[1])
`ifdef BIKE_SIM_DEBUG
    ,
    .o_item_count(),
    .o_debug_mem()
`endif
  );
  /* verilator lint_on PINCONNECTEMPTY */
endmodule
