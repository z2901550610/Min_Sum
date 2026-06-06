`timescale 1ns / 1ps
// Variable-node update for raw C2V tile sums.
module vnu_update
  import bike_pkg::*;
(
    input  logic                    i_valid[0:L-1],
    input  logic signed [ACC_W-1:0] i_raw_sum[0:L-1],
    input  logic signed [ACC_W-1:0] i_raw_c2v[0:L-1],
    output logic signed [ACC_W-1:0] o_posterior[0:L-1],
    output logic        [MSG_W-1:0] o_v2c_msg[0:L-1]
);

  function automatic logic signed [ACC_W-1:0] alpha_scale(input  logic signed [ACC_W-1:0] tc_value);
    localparam int SCALE_W = ACC_W + ALPHA_FRAC_W;
    logic signed [     SCALE_W-1:0] scale_ext;
    logic signed [     SCALE_W-1:0] scaled_full;
    logic signed [       ACC_W-1:0] floor_tc;
    logic signed [       ACC_W-1:0] trunc_tc;
    logic        [ALPHA_FRAC_W-1:0] frac_bits;
    logic        [  ALPHA_FRAC_W:0] neg_frac_mag;
    logic                           frac_nonzero;
    logic                           round_bit;
    begin
      scale_ext   = SCALE_W'($signed(tc_value));
      scaled_full = '0;
      if ((ALPHA_SHIFT_0 > 0) && (ALPHA_SHIFT_0 <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_0));
      end
      if ((ALPHA_SHIFT_1 > 0) && (ALPHA_SHIFT_1 <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_1));
      end

      floor_tc = scaled_full[SCALE_W-1:ALPHA_FRAC_W];
      frac_bits = scaled_full[ALPHA_FRAC_W-1:0];
      frac_nonzero = |frac_bits;
      if (scaled_full[SCALE_W-1]) begin
        trunc_tc = frac_nonzero ? (floor_tc + ACC_W'(1)) : floor_tc;
        neg_frac_mag = frac_nonzero ? ({1'b1, {ALPHA_FRAC_W{1'b0}}} - {1'b0, frac_bits}) : '0;
        round_bit = neg_frac_mag[ALPHA_FRAC_W-1];
        alpha_scale = round_bit ? (trunc_tc - ACC_W'(1)) : trunc_tc;
      end else begin
        trunc_tc = floor_tc;
        round_bit = frac_bits[ALPHA_FRAC_W-1];
        alpha_scale = round_bit ? (trunc_tc + ACC_W'(1)) : trunc_tc;
      end
    end
  endfunction

  function automatic logic [MSG_W-1:0] tc_to_signmag_sat(input  logic signed [ACC_W-1:0] tc_value);
    logic                    sign_bit;
    logic signed [ACC_W-1:0] mag_signed;
    int                      mag_int;
    begin
      sign_bit = tc_value[ACC_W-1];
      mag_signed = sign_bit ? -tc_value : tc_value;
      mag_int = int'(mag_signed);
      if (mag_int > MAG_MAX) begin
        mag_int = MAG_MAX;
      end
      tc_to_signmag_sat = {sign_bit && (mag_int != 0), D'(mag_int)};
    end
  endfunction

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      logic signed [ACC_W-1:0] v2c_tc;

      o_posterior[lane_idx] = '0;
      o_v2c_msg[lane_idx] = '0;
      v2c_tc = '0;
      if (i_valid[lane_idx]) begin
        o_posterior[lane_idx] = ACC_W'($signed(C_VAL)) + alpha_scale(i_raw_sum[lane_idx]);
        v2c_tc = ACC_W'($signed(C_VAL)) + alpha_scale(i_raw_sum[lane_idx] - i_raw_c2v[lane_idx]);
        o_v2c_msg[lane_idx] = tc_to_signmag_sat(v2c_tc);
      end
    end
  end
endmodule
