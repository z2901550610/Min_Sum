`timescale 1ns / 1ps
// Public parameter profile decoder for the tiled decoder.
module decoder_profile_config
  import bike_pkg::*;
(
    input  logic [     PROFILE_ID_W-1:0] i_param_level,
    output logic [          CFG_R_W-1:0] o_r,
    output logic [          CFG_W_W-1:0] o_w,
    output logic [       TILE_IDX_W-1:0] o_tile_count,
    output logic [      ROW_BANK_AW-1:0] o_row_seg_size,
    output logic [       CFG_CVAL_W-1:0] o_c_val,
    output logic [CFG_ALPHA_SHIFT_W-1:0] o_alpha_shift_0,
    output logic [CFG_ALPHA_SHIFT_W-1:0] o_alpha_shift_1
);

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_param_level;
  assign unused_param_level = PROFILE_RUNTIME_SELECT ? 1'b0 : ^i_param_level;
  /* verilator lint_on UNUSEDSIGNAL */

`ifdef BIKE_UNIFIED_PARAMS
  localparam int PROFILE_TILE_COUNT_VALS[0:2] = '{
      (P_R_VALS[0] + COLS_PER_TILE - 1) / COLS_PER_TILE,
      (P_R_VALS[1] + COLS_PER_TILE - 1) / COLS_PER_TILE,
      (P_R_VALS[2] + COLS_PER_TILE - 1) / COLS_PER_TILE
  };
  localparam int PROFILE_ROW_SEG_SIZE_VALS[0:2] = '{
      (P_R_VALS[0] + L - 1) / L,
      (P_R_VALS[1] + L - 1) / L,
      (P_R_VALS[2] + L - 1) / L
  };
`elsif TRIKE_UNIFIED_PARAMS
  localparam int PROFILE_TILE_COUNT_VALS[0:4] = '{
      (P_R_VALS[0] + COLS_PER_TILE - 1) / COLS_PER_TILE,
      (P_R_VALS[1] + COLS_PER_TILE - 1) / COLS_PER_TILE,
      (P_R_VALS[2] + COLS_PER_TILE - 1) / COLS_PER_TILE,
      (P_R_VALS[3] + COLS_PER_TILE - 1) / COLS_PER_TILE,
      (P_R_VALS[4] + COLS_PER_TILE - 1) / COLS_PER_TILE
  };
  localparam int PROFILE_ROW_SEG_SIZE_VALS[0:4] = '{
      (P_R_VALS[0] + L - 1) / L,
      (P_R_VALS[1] + L - 1) / L,
      (P_R_VALS[2] + L - 1) / L,
      (P_R_VALS[3] + L - 1) / L,
      (P_R_VALS[4] + L - 1) / L
  };
`endif

  always_comb begin
    o_r = CFG_R_W'(R);
    o_w = CFG_W_W'(W);
    o_tile_count = TILE_IDX_W'(TILE_COUNT);
    o_row_seg_size = ROW_BANK_AW'(ROW_SEG_SIZE);
    o_c_val = CFG_CVAL_W'(C_VAL);
    o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(ALPHA_SHIFT_0);
    o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(ALPHA_SHIFT_1);

`ifdef BIKE_UNIFIED_PARAMS
    if (PROFILE_RUNTIME_SELECT) begin
      logic [PROFILE_ID_W-1:0] idx;
      unique case (i_param_level)
        PROFILE_BIKE_128: idx = PROFILE_BIKE_128;
        PROFILE_BIKE_192: idx = PROFILE_BIKE_192;
        default:          idx = PROFILE_BIKE_256;
      endcase
      o_r = CFG_R_W'(P_R_VALS[idx]);
      o_w = CFG_W_W'(P_W_VALS[idx]);
      o_tile_count = TILE_IDX_W'(PROFILE_TILE_COUNT_VALS[idx]);
      o_row_seg_size = ROW_BANK_AW'(PROFILE_ROW_SEG_SIZE_VALS[idx]);
      o_c_val = CFG_CVAL_W'(P_C_VALS[idx]);
      o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(P_ASH0_VALS[idx]);
      o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(P_ASH1_VALS[idx]);
    end
`elsif TRIKE_UNIFIED_PARAMS
    if (PROFILE_RUNTIME_SELECT) begin
      logic [PROFILE_ID_W-1:0] idx;
      unique case (i_param_level)
        PROFILE_TRIKE_128: idx = PROFILE_TRIKE_128;
        PROFILE_TRIKE_160: idx = PROFILE_TRIKE_160;
        PROFILE_TRIKE_256: idx = PROFILE_TRIKE_256;
        PROFILE_TRIKE_384: idx = PROFILE_TRIKE_384;
        default:           idx = PROFILE_TRIKE_512;
      endcase
      o_r = CFG_R_W'(P_R_VALS[idx]);
      o_w = CFG_W_W'(P_W_VALS[idx]);
      o_tile_count = TILE_IDX_W'(PROFILE_TILE_COUNT_VALS[idx]);
      o_row_seg_size = ROW_BANK_AW'(PROFILE_ROW_SEG_SIZE_VALS[idx]);
      o_c_val = CFG_CVAL_W'(P_C_VALS[idx]);
      o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(P_ASH0_VALS[idx]);
      o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(P_ASH1_VALS[idx]);
    end
`endif
  end
endmodule
