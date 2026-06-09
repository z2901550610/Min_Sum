`timescale 1ns / 1ps
// Shared decoder parameters, field layouts, and RAM geometry.
package bike_pkg;

  /* verilator lint_off UNUSEDPARAM */

`ifndef BIKE_TOY_PARAMS
`ifdef BIKE_128_PARAMS
  localparam int N0 = 3;
  localparam int R = 8117;
  localparam int W = 27;
  localparam int T = 201;
  localparam int I_MAX = 7;
  localparam int C_VAL = 5;
  localparam int ALPHA_SHIFT_0 = 3;
  localparam int ALPHA_SHIFT_1 = 4;
`elsif BIKE_160_PARAMS
  localparam int N0 = 3;
  localparam int R = 12739;
  localparam int W = 35;
  localparam int T = 263;
  localparam int I_MAX = 7;
  localparam int C_VAL = 5;
  localparam int ALPHA_SHIFT_0 = 3;
  localparam int ALPHA_SHIFT_1 = 4;
`elsif BIKE_256_PARAMS
  localparam int N0 = 3;
  localparam int R = 29501;
  localparam int W = 55;
  localparam int T = 429;
  localparam int I_MAX = 7;
  localparam int C_VAL = 5;
  localparam int ALPHA_SHIFT_0 = 3;
  localparam int ALPHA_SHIFT_1 = 4;
`elsif BIKE_384_PARAMS
  localparam int N0 = 3;
  localparam int R = 59069;
  localparam int W = 83;
  localparam int T = 659;
  localparam int I_MAX = 7;
  localparam int C_VAL = 5;
  localparam int ALPHA_SHIFT_0 = 3;
  localparam int ALPHA_SHIFT_1 = 6;
`elsif BIKE_512_PARAMS
  localparam int N0 = 3;
  localparam int R = 156011;
  localparam int W = 111;
  localparam int T = 877;
  localparam int I_MAX = 7;
  localparam int C_VAL = 5;
  localparam int ALPHA_SHIFT_0 = 3;
  localparam int ALPHA_SHIFT_1 = 6;
`else
  localparam int N0 = 3;
  localparam int R = 8117;
  localparam int W = 27;
  localparam int T = 201;
  localparam int I_MAX = 7;
  localparam int C_VAL = 5;
  localparam int ALPHA_SHIFT_0 = 3;
  localparam int ALPHA_SHIFT_1 = 4;
`endif
`else
  localparam int N0 = 2;
  localparam int R = 8;
  localparam int W = 3;
  localparam int T = 1;
  localparam int I_MAX = 4;
  localparam int C_VAL = 2;
  localparam int ALPHA_SHIFT_0 = 1;
  localparam int ALPHA_SHIFT_1 = 3;
`endif

  localparam int N = N0 * R;
`ifndef BIKE_PARALLEL_L
  localparam int L = 8;
`else
  localparam int L = `BIKE_PARALLEL_L;
`endif
`ifndef BIKE_MSG_BITS
  localparam int MSG_BITS_CONFIG = 5;
`else
  localparam int MSG_BITS_CONFIG = `BIKE_MSG_BITS;
`endif
  localparam int D = (MSG_BITS_CONFIG > 1) ? (MSG_BITS_CONFIG - 1) : 1;
  // L is constrained to a power of two so lane-local tile windows map cleanly
  // to row banks.
  localparam int ALPHA_FRAC_W = 6;
  localparam int MAG_MAX = (1 << D) - 1;
  localparam int MSG_W = D + 1;
  localparam int ROW_SEG_SIZE = (R + L - 1) / L;
  localparam int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1);
`ifndef BIKE_C_TILE
  localparam int C_TILE_CONFIG = 256;
`else
  localparam int C_TILE_CONFIG = `BIKE_C_TILE;
`endif
  localparam int C_TILE = (C_TILE_CONFIG > R) ? R : C_TILE_CONFIG;
  localparam int Q_BASE = (C_TILE + L - 1) / L;
  localparam int Q_TILE = Q_BASE + 1;
  localparam int TILE_COUNT = (R + C_TILE - 1) / C_TILE;
  localparam int TILES_TOTAL = N0 * TILE_COUNT;
  localparam int TILE_ID_W = (TILES_TOTAL > 1) ? $clog2(TILES_TOTAL) : 1;
  localparam int TILE_IDX_W = (TILE_COUNT > 1) ? $clog2(TILE_COUNT) : 1;
  localparam int TILE_OFF_W = (C_TILE > 1) ? $clog2(C_TILE) : 1;
  localparam int Q_SEQ_W = (Q_TILE > 1) ? $clog2(Q_TILE) : 1;
  localparam int ROW_BANK_AW = (ROW_SEG_SIZE > 1) ? $clog2(ROW_SEG_SIZE) : 1;
  localparam int ACC_W = VNU_TC_W;
  localparam int COL_W = (N > 1) ? $clog2(N) : 1;
  localparam int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  localparam int ROW_EDGE_COUNT = N0 * W;

  localparam int ONE_IDX_W = (W > 1) ? $clog2(W) : 1;
  localparam int EDGE_ID_W = (ROW_EDGE_COUNT > 1) ? $clog2(ROW_EDGE_COUNT) : 1;
  localparam int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  localparam int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  localparam int L_SHIFT = (L > 1) ? $clog2(L) : 0;
  localparam int ITER_W = $clog2(I_MAX + 1);

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START = 4'd0;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CLEAR = 4'd3;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_C2V_PRIME = 4'd4;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_OVERLAP = 4'd5;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_V2C_DRAIN = 4'd6;
  localparam logic [DEC_STATE_W-1:0] DEC_ITER_CHECK = 4'd8;
  localparam logic [DEC_STATE_W-1:0] DEC_DONE = 4'd9;

  localparam int MSG_MAG_LSB = 0;
  localparam int MSG_SIGN_BIT = D;

  localparam int COMP_C2V_MIN1_LSB = 0;
  localparam int COMP_C2V_MIN2_LSB = COMP_C2V_MIN1_LSB + D;
  localparam int COMP_C2V_MIN_ID_LSB = COMP_C2V_MIN2_LSB + D;
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_ID_LSB + EDGE_ID_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {1'b0, EDGE_ID_W'(0), D'(MAG_MAX), D'(MAG_MAX)};
  localparam logic [COMP_C2V_W-1:0] FIRST_ITER_C2V_COMP = {
    1'b0, EDGE_ID_W'(0), D'(C_VAL), D'(C_VAL)
  };

  /* verilator lint_on UNUSEDPARAM */
endpackage
