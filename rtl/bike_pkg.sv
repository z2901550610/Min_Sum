`timescale 1ns/1ps
// Shared decoder parameters, field layouts, and H-block constants.
package bike_pkg;

  /* verilator lint_off UNUSEDPARAM */

  parameter int N0 = 2;

`ifdef BIKE_L1_PARAMS
  parameter int R = 12323;
  parameter int W = 71;
  parameter int I_MAX = 6;
  parameter int C_VAL = 7;
  parameter int ALPHA_SHIFT_0 = 4;  //对应论文中使用最多两位1表示
  parameter int ALPHA_SHIFT_1 = 6;  //ALPHA_SHIFT_0 与 ALPHA_SHIFT_1 表示"1"的位置，即 alpha=0.000101b
`else
  parameter int R = 8;
  parameter int W = 3;
  parameter int I_MAX = 4;
  parameter int C_VAL = 9;
  parameter int ALPHA_SHIFT_0 = 4;
  parameter int ALPHA_SHIFT_1 = 5;
`endif

  parameter int N = N0 * R;
  parameter int L = 2;
  parameter int D = 4;
`ifdef BIKE_L1_PARAMS
  parameter int RAM_LANE_DEPTH = 37;
`else
  parameter int RAM_LANE_DEPTH = 2;
`endif
  parameter int ALPHA_FRAC_W = 6;  //alpha 用6位小数表示
  parameter int MAG_MAX = (1 << D) - 1;
  parameter int MSG_W = D + 1;
  parameter int ROW_SEG_SIZE = (R + L - 1) / L;
  parameter int ROW_GROUP_DEPTH = ROW_SEG_SIZE;
  parameter int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1);
  parameter int COL_W = (N > 1) ? $clog2(N) : 1;
  parameter int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  parameter int H_NUM = 1;

  // Canonical names aligned with h_shift.sv conventions.
  // "one_idx" = index of a "1" within a column (0 .. W-1).
  // "row_idx_global" = global row index (0 .. R-1).
  // "row_idx_group" = row index within a group/lane.
  // "group_idx" = which lane/group (0 .. L-1).
  // "group_count" = number of valid entries in a group's list.
  parameter int ONE_IDX_W   = (W > 1) ? $clog2(W)     : 1;
  parameter int ROW_IDX_W   = (R > 1) ? $clog2(R)     : 1;
  parameter int GROUP_IDX_W = (L > 1) ? $clog2(L)     : 1;
  parameter int ROW_GROUP_W = ROW_IDX_W - GROUP_IDX_W;
  parameter int ENTRY_POS_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH) : 1;
  parameter int GROUP_COUNT_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH + 1) : 1;

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

`ifdef BIKE_L1_PARAMS
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
