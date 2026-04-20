package bike_pkg;
  timeunit 1ns;
  timeprecision 1ps;

  /* verilator lint_off UNUSEDPARAM */

  parameter int N0 = 2;

`ifdef BIKE_L1_PARAMS
  parameter int R = 12323;
  parameter int W = 71;
  parameter int I_MAX = 6;
  parameter int C_VAL = 7;
  parameter int ALPHA_SHIFT_0 = 4;
  parameter int ALPHA_SHIFT_1 = 6;
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
  parameter int ALPHA_FRAC_W = 6;
  parameter int MAG_MAX = (1 << D) - 1;
  parameter int ROW_SEG_SIZE = (R + L - 1) / L;
  parameter int APP_W = 8;
  parameter int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  parameter int VAR_W = (N > 1) ? $clog2(N) : 1;
  parameter int ROW_W = (R > 1) ? $clog2(R) : 1;
  parameter int EDGE_W = (W > 1) ? $clog2(W) : 1;
  parameter int BANK_W = (N0 > 1) ? $clog2(N0) : 1;
  parameter int LANE_COUNT_W = (W > 1) ? $clog2(W + 1) : 1;
  parameter int H_NUM = 1;
  parameter int H_SEL_W = (H_NUM > 1) ? $clog2(H_NUM) : 1;

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START       = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_INIT_DECODER     = 4'd1;
  localparam logic [DEC_STATE_W-1:0] DEC_INIT_ROW_ACCUM   = 4'd2;
  localparam logic [DEC_STATE_W-1:0] DEC_INIT_ROW_FLUSH   = 4'd3;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_C2V_PRIME   = 4'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_OVERLAP     = 4'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_V2C_DRAIN   = 4'd6;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_WRITE_FLUSH = 4'd7;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CHECK       = 4'd8;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE             = 4'd9;

  localparam int MSG_W = D + 1;
  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int ROW_STATE_MIN1_LSB = 0;
  localparam int ROW_STATE_MIN2_LSB = ROW_STATE_MIN1_LSB + D;
  localparam int ROW_STATE_MIN_ID_LSB = ROW_STATE_MIN2_LSB + D;
  localparam int ROW_STATE_SIGN_XOR_BIT = ROW_STATE_MIN_ID_LSB + VAR_W;
  localparam int ROW_STATE_W = ROW_STATE_SIGN_XOR_BIT + 1;
  localparam logic [ROW_STATE_W-1:0] ROW_STATE_INIT = {
    1'b0,
    VAR_W'(0),
    D'(MAG_MAX),
    D'(MAG_MAX)
  };

  localparam int LANE_EDGE_VALID_BIT = 0;
  localparam int LANE_EDGE_ROW_LOCAL_LSB = LANE_EDGE_VALID_BIT + 1;
  localparam int LANE_EDGE_ROW_GLOBAL_LSB = LANE_EDGE_ROW_LOCAL_LSB + ROW_W;
  localparam int LANE_EDGE_VAR_IDX_LSB = LANE_EDGE_ROW_GLOBAL_LSB + ROW_W;
  localparam int LANE_EDGE_EDGE_SLOT_LSB = LANE_EDGE_VAR_IDX_LSB + VAR_W;
  localparam int LANE_EDGE_W = LANE_EDGE_EDGE_SLOT_LSB + EDGE_W;
  localparam int I_ENTRY_ROW_LOCAL_LSB = 0;
  localparam int I_ENTRY_EDGE_SLOT_LSB = I_ENTRY_ROW_LOCAL_LSB + ROW_W;
  localparam int I_ENTRY_W = I_ENTRY_EDGE_SLOT_LSB + EDGE_W;

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
