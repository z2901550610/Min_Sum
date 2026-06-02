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
  localparam int R = 73421;
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
  localparam int D = 4;
  // L is constrained to a power of two so lane-local one_idx generation uses
  // shifts and low-bit concatenation.
  localparam int EDGE_SLOT_DEPTH = (W + L - 1) / L;
`ifndef BIKE_RAM_LANE_MIN_DEPTH
  localparam int RAM_LANE_MIN_DEPTH = 3;
`else
  localparam int RAM_LANE_MIN_DEPTH = `BIKE_RAM_LANE_MIN_DEPTH;
`endif
`ifndef BIKE_RAM_LANE_DEPTH
  localparam int RAM_LANE_DEPTH =
    (EDGE_SLOT_DEPTH < RAM_LANE_MIN_DEPTH) ? RAM_LANE_MIN_DEPTH : EDGE_SLOT_DEPTH;
`else
  localparam int RAM_LANE_DEPTH = `BIKE_RAM_LANE_DEPTH;
`endif
  localparam int ALPHA_FRAC_W = 6;  //alpha 用6位小数表示
  localparam int MAG_MAX = (1 << D) - 1;
  localparam int MSG_W = D + 1;
  localparam int ROW_SEG_SIZE = (R + L - 1) / L;
  localparam int ROW_GROUP_DEPTH = ROW_SEG_SIZE;
  localparam int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1);
  localparam int COL_W = (N > 1) ? $clog2(N) : 1;
  localparam int H_BLOCK_W = (N0 > 1) ? $clog2(N0) : 1;
  localparam int H_NUM = 1;
  localparam int ROW_EDGE_COUNT = N0 * W;

  // Canonical names aligned with h_shift.sv conventions.
  // "one_idx" = index of a "1" within a column (0 .. W-1).
  // "edge_id" = row-local edge identity h_block_idx * W + one_idx.
  // "row_idx_global" = global row index (0 .. R-1).
  // "lane_idx" = physical processing lane selected from one_idx and L.
  // "row_idx_group" = row index within a virtual row bank.
  // "group_idx" = virtual row-bank index (0 .. L-1).
  // "group_count" = number of valid edge slots in a lane-local list.
  localparam int ONE_IDX_W = (W > 1) ? $clog2(W) : 1;
  localparam int EDGE_ID_W = (ROW_EDGE_COUNT > 1) ? $clog2(ROW_EDGE_COUNT) : 1;
  localparam int ROW_IDX_W = (R > 1) ? $clog2(R) : 1;
  localparam int LANE_IDX_W = (L > 1) ? $clog2(L) : 1;
  localparam int GROUP_IDX_W = (L > 1) ? $clog2(L) : 1;
  localparam int ROW_GROUP_W = (ROW_GROUP_DEPTH > 1) ? $clog2(ROW_GROUP_DEPTH) : 1;
  localparam int ENTRY_POS_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH) : 1;
  localparam int GROUP_COUNT_W = (RAM_LANE_DEPTH > 1) ? $clog2(RAM_LANE_DEPTH + 1) : 1;
  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam int S_WORD_W = W;
  localparam int S_WORD_DEPTH = N;
  localparam int S_WORD_ADDR_W = COL_W;
  localparam int DEFAULT_M_ROW_BANKS =
    (L <= 1) ? 1 :
    ((N0 == 2 && R == 8 && W == 3) ? 1 :
    ((N0 == 3 && R == 8117 && W == 27) ?
     ((L <= 2) ? 16 : ((L <= 4) ? 32 : ((L <= 8) ? 128 : ((L <= 16) ? 256 : 512)))) :
     ((L <= 2) ? 16 : 512)));
`ifndef BIKE_RAM_M_ROW_BANKS
  localparam int M_ROW_BANKS = (DEFAULT_M_ROW_BANKS > R) ? R : DEFAULT_M_ROW_BANKS;
`else
  localparam int M_ROW_BANKS = (`BIKE_RAM_M_ROW_BANKS > R) ? R : `BIKE_RAM_M_ROW_BANKS;
`endif
  localparam int M_ROW_BANK_IDX_W = (M_ROW_BANKS > 1) ? $clog2(M_ROW_BANKS) : 1;
  localparam int M_ROW_BANK_DEPTH = (R + M_ROW_BANKS - 1) / M_ROW_BANKS;
  localparam int M_ROW_BANK_ADDR_W = (M_ROW_BANK_DEPTH > 1) ? $clog2(M_ROW_BANK_DEPTH) : 1;
  localparam int M_BANKS = 2 * M_ROW_BANKS;
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
  localparam int COMP_C2V_SIGN_XOR_BIT = COMP_C2V_MIN_ID_LSB + EDGE_ID_W;
  localparam int COMP_C2V_W = COMP_C2V_SIGN_XOR_BIT + 1;
  localparam logic [COMP_C2V_W-1:0] COMP_C2V_INIT = {1'b0, EDGE_ID_W'(0), D'(MAG_MAX), D'(MAG_MAX)};
  localparam logic [COMP_C2V_W-1:0] FIRST_ITER_C2V_COMP = {
    1'b0, EDGE_ID_W'(0), D'(C_VAL), D'(C_VAL)
  };

  localparam int I_ENTRY_ROW_IDX_GLOBAL_LSB = 0;
  localparam int I_ENTRY_ROW_IDX_GROUP_LSB = I_ENTRY_ROW_IDX_GLOBAL_LSB;
  localparam int I_ENTRY_W = ROW_IDX_W;
  /* verilator lint_on UNUSEDPARAM */
endpackage
