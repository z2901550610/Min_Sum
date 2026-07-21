`timescale 1ns / 1ps
// Shared decoder parameters, field layouts, and RAM geometry.
`ifndef BIKE_TOY_PARAMS
`ifndef BIKE_UNIFIED_PARAMS
`ifndef TRIKE_UNIFIED_PARAMS
`ifndef BIKE_128_PARAMS
`ifndef BIKE_192_PARAMS
`ifndef BIKE_256_PARAMS
`ifndef TRIKE_128_PARAMS
`ifndef TRIKE_160_PARAMS
`ifndef TRIKE_256_PARAMS
`ifndef TRIKE_384_PARAMS
`ifndef TRIKE_512_PARAMS
`define BIKE_UNIFIED_PARAMS
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif
`endif

`ifdef TRIKE_UNIFIED_PARAMS
`define DECODER_TRIKE_FAMILY
`endif
`ifdef TRIKE_128_PARAMS
`define DECODER_TRIKE_FAMILY
`endif
`ifdef TRIKE_160_PARAMS
`define DECODER_TRIKE_FAMILY
`endif
`ifdef TRIKE_256_PARAMS
`define DECODER_TRIKE_FAMILY
`endif
`ifdef TRIKE_384_PARAMS
`define DECODER_TRIKE_FAMILY
`endif
`ifdef TRIKE_512_PARAMS
`define DECODER_TRIKE_FAMILY
`endif

package bike_pkg;

  /* verilator lint_off UNUSEDPARAM */

`ifdef DECODER_TRIKE_FAMILY
  // TRIKE profile values indexed [0:4] = {128, 160, 256, 384, 512}.
  localparam int P_R_VALS[0:4] = '{8117, 12739, 29501, 61283, 108587};
  localparam int P_W_VALS[0:4] = '{27, 35, 55, 83, 111};
  localparam int P_T_VALS[0:4] = '{201, 263, 429, 659, 877};
  localparam int P_C_VALS[0:4] = '{5, 5, 5, 5, 7};
  localparam int P_ASH0_VALS[0:4] = '{3, 3, 3, 3, 4};
  localparam int P_ASH1_VALS[0:4] = '{4, 4, 4, 6, 0};
  localparam int P_COLS_PER_TILE_VALS[0:4] = '{256, 256, 288, 464, 1168};
`else
  // BIKE profile values indexed [0:2] = {128, 192, 256}.
  localparam int P_R_VALS[0:2] = '{12323, 24659, 40973};
  localparam int P_W_VALS[0:2] = '{71, 103, 137};
  localparam int P_T_VALS[0:2] = '{134, 199, 264};
  localparam int P_C_VALS[0:2] = '{5, 5, 5};
  localparam int P_ASH0_VALS[0:2] = '{3, 3, 3};
  localparam int P_ASH1_VALS[0:2] = '{4, 4, 4};
  localparam int P_COLS_PER_TILE_VALS[0:2] = '{256, 512, 576};
`endif

`ifndef BIKE_TOY_PARAMS
  localparam int I_MAX = 7;
`ifdef DECODER_TRIKE_FAMILY
  localparam int N0 = 3;
`ifdef TRIKE_128_PARAMS
  localparam int PROF_IDX = 0;
`elsif TRIKE_160_PARAMS
  localparam int PROF_IDX = 1;
`elsif TRIKE_256_PARAMS
  localparam int PROF_IDX = 2;
`elsif TRIKE_384_PARAMS
  localparam int PROF_IDX = 3;
`elsif TRIKE_512_PARAMS
  localparam int PROF_IDX = 4;
`else
  localparam int PROF_IDX = 4;
`endif
`else
  localparam int N0 = 2;
`ifdef BIKE_128_PARAMS
  localparam int PROF_IDX = 0;
`elsif BIKE_192_PARAMS
  localparam int PROF_IDX = 1;
`elsif BIKE_256_PARAMS
  localparam int PROF_IDX = 2;
`else
  localparam int PROF_IDX = 2;
`endif
`endif
  localparam int R = P_R_VALS[PROF_IDX];
  localparam int W = P_W_VALS[PROF_IDX];
  localparam int T = P_T_VALS[PROF_IDX];
  localparam int C_VAL = P_C_VALS[PROF_IDX];
  localparam int ALPHA_SHIFT_0 = P_ASH0_VALS[PROF_IDX];
  localparam int ALPHA_SHIFT_1 = P_ASH1_VALS[PROF_IDX];
`else
  localparam int N0 = 2;
  localparam int I_MAX = 4;
  localparam int PROF_IDX = 0;
  localparam int R = 8;
  localparam int W = 3;
  localparam int T = 1;
  localparam int C_VAL = 2;
  localparam int ALPHA_SHIFT_0 = 1;
  localparam int ALPHA_SHIFT_1 = 3;
`endif

  localparam int N = N0 * R;
`ifndef BIKE_PARALLEL_L
  localparam int L = 32;
`else
  localparam int L = `BIKE_PARALLEL_L;
`endif
`ifndef BIKE_MSG_BITS
  localparam int MSG_BITS_CONFIG = 5;
`else
  localparam int MSG_BITS_CONFIG = `BIKE_MSG_BITS;
`endif
`ifndef BIKE_K_SIGN_K
  localparam int K_SIGN_K_CONFIG = 4;
`else
  localparam int K_SIGN_K_CONFIG = `BIKE_K_SIGN_K;
`endif
`ifdef DECODER_TRIKE_FAMILY
  localparam bit K_SIGN_ENABLE = 1'b1;
`else
  localparam bit K_SIGN_ENABLE = 1'b0;
`endif
  localparam int D = (MSG_BITS_CONFIG > 1) ? (MSG_BITS_CONFIG - 1) : 1;
  // L is constrained to a power of two so lane-local tile windows map cleanly
  // to row banks.
  localparam int ALPHA_FRAC_W = 6;
  localparam int MAG_MAX = (1 << D) - 1;
  localparam int MSG_W = D + 1;
  localparam int ROW_SEG_SIZE = (R + L - 1) / L;
  localparam int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1);
`ifdef BIKE_COLS_PER_TILE
  localparam int COLS_PER_TILE_CONFIG = `BIKE_COLS_PER_TILE;
`elsif BIKE_UNIFIED_PARAMS
  localparam int COLS_PER_TILE_CONFIG = 576;
`elsif TRIKE_UNIFIED_PARAMS
  localparam int COLS_PER_TILE_CONFIG = 1152;
`elsif BIKE_TOY_PARAMS
  localparam int COLS_PER_TILE_CONFIG = 288;
`else
  localparam int COLS_PER_TILE_CONFIG = P_COLS_PER_TILE_VALS[PROF_IDX];
`endif
  localparam int COLS_PER_TILE = (COLS_PER_TILE_CONFIG > R) ? R : COLS_PER_TILE_CONFIG;
  localparam int Q_BASE = (COLS_PER_TILE + L - 1) / L;
  localparam int Q_TILE = Q_BASE + 3;
  localparam int TILE_COUNT = (R + COLS_PER_TILE - 1) / COLS_PER_TILE;
  localparam int TILES_TOTAL = N0 * TILE_COUNT;
  localparam int TILE_ID_W = (TILES_TOTAL > 1) ? $clog2(TILES_TOTAL + 1) : 1;
  localparam int TILE_IDX_W = (TILE_COUNT > 1) ? $clog2(TILE_COUNT + 1) : 1;
  localparam int TILE_OFF_W = (COLS_PER_TILE > 1) ? $clog2(COLS_PER_TILE) : 1;
  localparam int LANE_GROUP_IDX_W = (Q_TILE > 1) ? $clog2(Q_TILE) : 1;
  localparam int ROW_BANK_AW = (ROW_SEG_SIZE > 1) ? $clog2(ROW_SEG_SIZE) : 1;
  localparam int ACC_W = VNU_TC_W;
  localparam int COL_W = (N > 1) ? $clog2(N) : 1;
  localparam int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  localparam int DIAG_GLOBAL_COUNT = N0 * W;

  localparam int DIAG_IDX_W = (W > 1) ? $clog2(W) : 1;
  localparam int K_SIGN_K = K_SIGN_K_CONFIG;
  localparam int K_SIGN_SLOT_IDX_W = (K_SIGN_K > 1) ? $clog2(K_SIGN_K) : 1;
  localparam int K_SIGN_WORK_SLOT_W = DIAG_IDX_W + D;
  localparam int K_SIGN_WORK_RECORD_W = 1 + (K_SIGN_K * K_SIGN_WORK_SLOT_W);
  localparam int K_SIGN_RECORD_W = 1 + (K_SIGN_K * DIAG_IDX_W);
  localparam int K_SIGN_POS_RECORD_W = K_SIGN_K * DIAG_IDX_W;
  localparam int K_SIGN_WORK_DEPTH = Q_BASE;
  localparam int K_SIGN_WORK_AW = (K_SIGN_WORK_DEPTH > 1) ? $clog2(K_SIGN_WORK_DEPTH) : 1;
  localparam int K_SIGN_OVERLAP_DRAIN_CYCLES = 7;
  localparam logic [DIAG_IDX_W-1:0] K_SIGN_DIAG_INVALID = '1;
  localparam int DIAG_GLOBAL_W = (DIAG_GLOBAL_COUNT > 1) ? $clog2(DIAG_GLOBAL_COUNT) : 1;
  localparam int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  localparam int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  localparam int L_SHIFT = (L > 1) ? $clog2(L) : 0;
  localparam int ITER_W = $clog2(I_MAX + 1);

`ifdef DECODER_TRIKE_FAMILY
  localparam int PROFILE_COUNT = 5;
  localparam int PROFILE_ID_W = 3;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_128 = 3'd0;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_160 = 3'd1;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_256 = 3'd2;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_384 = 3'd3;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_TRIKE_512 = 3'd4;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_DEFAULT = PROFILE_TRIKE_512;
`else
  localparam int PROFILE_COUNT = 3;
  localparam int PROFILE_ID_W = 2;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_BIKE_128 = 2'd0;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_BIKE_192 = 2'd1;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_BIKE_256 = 2'd2;
  localparam logic [PROFILE_ID_W-1:0] PROFILE_DEFAULT = PROFILE_BIKE_128;
`endif
`ifdef BIKE_UNIFIED_PARAMS
  localparam bit PROFILE_RUNTIME_SELECT = 1'b1;
`elsif TRIKE_UNIFIED_PARAMS
  localparam bit PROFILE_RUNTIME_SELECT = 1'b1;
`else
  localparam bit PROFILE_RUNTIME_SELECT = 1'b0;
`endif
  localparam int CFG_R_W = ROW_IDX_W + 1;
  localparam int CFG_W_W = DIAG_IDX_W + 1;
  localparam int CFG_CVAL_W = MSG_W;
  localparam int CFG_ALPHA_SHIFT_W = 3;

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CLEAR = 4'd3;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_C2V_PRIME = 4'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_OVERLAP = 4'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_V2C_DRAIN = 4'd6;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_KSIGN_CORR = 4'd7;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CHECK = 4'd8;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE = 4'd9;

  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int COMP_C2V_MIN1_LSB = 0;
  localparam int COMP_C2V_MIN2_LSB = COMP_C2V_MIN1_LSB + D;
  localparam int COMP_C2V_MIN_DIAG_GLOBAL_LSB = COMP_C2V_MIN2_LSB + D;
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_DIAG_GLOBAL_LSB + DIAG_GLOBAL_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {
    1'b0, DIAG_GLOBAL_W'(0), D'(MAG_MAX), D'(MAG_MAX)
  };
  localparam logic [COMP_C2V_W-1:0] FIRST_ITER_C2V_COMP = {
    1'b0, DIAG_GLOBAL_W'(0), D'(C_VAL), D'(C_VAL)
  };

  /* verilator lint_on UNUSEDPARAM */
endpackage

`ifdef DECODER_TRIKE_FAMILY
`undef DECODER_TRIKE_FAMILY
`endif
