`timescale 1ns / 1ps
// Shared decoder parameters, field layouts, and RAM geometry.
package bike_pkg;

  /* verilator lint_off UNUSEDPARAM */

  localparam int N0 = 2;

`ifndef BIKE_TOY_PARAMS
  localparam int R = 11677;
  localparam int W = 71;
  localparam int I_MAX = 7;
  localparam int C_VAL = 7;
  localparam int ALPHA_SHIFT_0 = 4;
  localparam int ALPHA_SHIFT_1 = 0;
`else
  localparam int R = 8;
  localparam int W = 3;
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
  localparam int D = 4;
  localparam int EDGE_SLOT_DEPTH = (W + L - 1) / L;
  localparam int RAM_LANE_DEPTH = ((EDGE_SLOT_DEPTH + 1) < 3) ? 3 : (EDGE_SLOT_DEPTH + 1);
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
  // "lane_idx" = physical processing lane (0 .. L-1).
  // "row_idx_group" = row index within a virtual row bank.
  // "group_idx" = virtual row-bank index (0 .. L-1).
  // "lane_idx" = edge-index lane; one_idx % L.
  // "group_count" = number of valid edge slots in a lane-local list.
  localparam int ONE_IDX_W = (W > 1) ? $clog2(W) : 1;
  localparam int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  localparam int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  localparam int GROUP_IDX_W = (L > 1) ? $clog2(L) : 1;
  localparam int ROW_GROUP_W = (ROW_GROUP_DEPTH > 1) ? $clog2(ROW_GROUP_DEPTH) : 1;
  localparam int ENTRY_POS_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH) : 1;
  localparam int GROUP_COUNT_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH + 1) : 1;
  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam int S_PACK_W = (L <= 2) ? 8 : ((L <= 4) ? 4 : ((L <= 8) ? 2 : 1));
  localparam int S_WORDS_PER_COL = (RAM_LANE_DEPTH + S_PACK_W - 1) / S_PACK_W;
  localparam int S_WORD_DEPTH = N * S_WORDS_PER_COL;
  localparam int S_WORD_ADDR_W = (S_WORD_DEPTH > 1) ? $clog2(S_WORD_DEPTH) : 1;
  localparam int S_PACK_IDX_W = (S_PACK_W > 1) ? $clog2(S_PACK_W) : 1;
  localparam int M_BANKS = 2 * L;
  localparam int M_BANK_IDX_W = (M_BANKS > 1) ? $clog2(M_BANKS) : 1;

  localparam int DEC_STATE_W = 4;
  localparam logic [DEC_STATE_W-1:0] DEC_WAIT_START = 4'd0;
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
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_ID_LSB + COL_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {1'b0, COL_W'(0), D'(MAG_MAX), D'(MAG_MAX)};
  localparam logic [COMP_C2V_W-1:0] FIRST_ITER_C2V_COMP = {1'b0, COL_W'(0), D'(C_VAL), D'(C_VAL)};

  localparam int I_ENTRY_ROW_IDX_GLOBAL_LSB = 0;
  localparam int I_ENTRY_ROW_IDX_GROUP_LSB = I_ENTRY_ROW_IDX_GLOBAL_LSB;
  localparam int I_ENTRY_ONE_IDX_LSB = I_ENTRY_ROW_IDX_GLOBAL_LSB + ROW_IDX_W;
  localparam int I_ENTRY_W = I_ENTRY_ONE_IDX_LSB + ONE_IDX_W;
  /* verilator lint_on UNUSEDPARAM */
endpackage
