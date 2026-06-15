`timescale 1ns / 1ps
// Public BIKE parameter profile decoder for the tiled decoder.
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

`ifndef BIKE_UNIFIED_PARAMS
  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_profile_sel;
  assign unused_profile_sel = ^i_profile_sel;
  /* verilator lint_on UNUSEDSIGNAL */
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
    unique case (i_profile_sel)
      PROFILE_BIKE_128: begin
        o_r = CFG_R_W'(8117);
        o_w = CFG_W_W'(27);
        o_tile_count = TILE_IDX_W'((8117 + C_TILE - 1) / C_TILE);
        o_row_seg_size = ROW_BANK_AW'((8117 + L - 1) / L);
        o_c_val = CFG_CVAL_W'(5);
        o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(3);
        o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(4);
      end
      PROFILE_BIKE_160: begin
        o_r = CFG_R_W'(12739);
        o_w = CFG_W_W'(35);
        o_tile_count = TILE_IDX_W'((12739 + C_TILE - 1) / C_TILE);
        o_row_seg_size = ROW_BANK_AW'((12739 + L - 1) / L);
        o_c_val = CFG_CVAL_W'(5);
        o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(3);
        o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(4);
      end
      PROFILE_BIKE_256: begin
        o_r = CFG_R_W'(29501);
        o_w = CFG_W_W'(55);
        o_tile_count = TILE_IDX_W'((29501 + C_TILE - 1) / C_TILE);
        o_row_seg_size = ROW_BANK_AW'((29501 + L - 1) / L);
        o_c_val = CFG_CVAL_W'(5);
        o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(3);
        o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(4);
      end
      PROFILE_BIKE_384: begin
        o_r = CFG_R_W'(59069);
        o_w = CFG_W_W'(83);
        o_tile_count = TILE_IDX_W'((59069 + C_TILE - 1) / C_TILE);
        o_row_seg_size = ROW_BANK_AW'((59069 + L - 1) / L);
        o_c_val = CFG_CVAL_W'(5);
        o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(3);
        o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(6);
      end
      PROFILE_BIKE_512: begin
        o_r = CFG_R_W'(108587);
        o_w = CFG_W_W'(111);
        o_tile_count = TILE_IDX_W'((108587 + C_TILE - 1) / C_TILE);
        o_row_seg_size = ROW_BANK_AW'((108587 + L - 1) / L);
        o_c_val = CFG_CVAL_W'(7);
        o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(4);
        o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(0);
      end
      default: begin
        o_r = CFG_R_W'(8117);
        o_w = CFG_W_W'(27);
        o_tile_count = TILE_IDX_W'((8117 + C_TILE - 1) / C_TILE);
        o_row_seg_size = ROW_BANK_AW'((8117 + L - 1) / L);
        o_c_val = CFG_CVAL_W'(5);
        o_alpha_shift_0 = CFG_ALPHA_SHIFT_W'(3);
        o_alpha_shift_1 = CFG_ALPHA_SHIFT_W'(4);
      end
    endcase
`endif
  end
endmodule
