`timescale 1ns / 1ps
// Public parameter profile decoder for the tiled decoder.
module decoder_profile_config
  import bike_pkg::*;
(
    input  logic [     PROFILE_ID_W-1:0] i_profile_sel,
    output logic [          CFG_R_W-1:0] o_r,
    output logic [          CFG_W_W-1:0] o_w,
    output logic [       TILE_IDX_W-1:0] o_tile_count,
    output logic [      ROW_BANK_AW-1:0] o_row_seg_size,
    output logic [       CFG_CVAL_W-1:0] o_c_val,
    output logic [CFG_ALPHA_SHIFT_W-1:0] o_alpha_shift_0,
    output logic [CFG_ALPHA_SHIFT_W-1:0] o_alpha_shift_1
);

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_profile_sel;
  assign unused_profile_sel = PROFILE_RUNTIME_SELECT ? 1'b0 : ^i_profile_sel;
  /* verilator lint_on UNUSEDSIGNAL */

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
      unique case (i_profile_sel)
        PROFILE_BIKE_128: idx = PROFILE_BIKE_128;
        PROFILE_BIKE_192: idx = PROFILE_BIKE_192;
        default:          idx = PROFILE_BIKE_256;
      endcase
      o_r = CFG_R_W'(P_R_VALS[idx]);
      o_w = CFG_W_W'(P_W_VALS[idx]);
      o_tile_count = TILE_IDX_W'((P_R_VALS[idx] + C_TILE - 1) / C_TILE);
      o_row_seg_size = ROW_BANK_AW'((P_R_VALS[idx] + L - 1) / L);
      o_c_val = CFG_CVAL_W'(P_C_VALS[idx]);
      o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(P_ASH0_VALS[idx]);
      o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(P_ASH1_VALS[idx]);
    end
`elsif TRIKE_UNIFIED_PARAMS
    if (PROFILE_RUNTIME_SELECT) begin
      logic [PROFILE_ID_W-1:0] idx;
      unique case (i_profile_sel)
        PROFILE_TRIKE_128: idx = PROFILE_TRIKE_128;
        PROFILE_TRIKE_160: idx = PROFILE_TRIKE_160;
        PROFILE_TRIKE_256: idx = PROFILE_TRIKE_256;
        PROFILE_TRIKE_384: idx = PROFILE_TRIKE_384;
        default:           idx = PROFILE_TRIKE_512;
      endcase
      o_r = CFG_R_W'(P_R_VALS[idx]);
      o_w = CFG_W_W'(P_W_VALS[idx]);
      o_tile_count = TILE_IDX_W'((P_R_VALS[idx] + C_TILE - 1) / C_TILE);
      o_row_seg_size = ROW_BANK_AW'((P_R_VALS[idx] + L - 1) / L);
      o_c_val = CFG_CVAL_W'(P_C_VALS[idx]);
      o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(P_ASH0_VALS[idx]);
      o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(P_ASH1_VALS[idx]);
    end
`endif
  end
endmodule
