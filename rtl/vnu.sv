// Variable-node unit that accumulates c2v messages and emits updated v2c.
module vnu
  import bike_pkg::*;
(
  input  logic i_clk,                               // Sequential update clock.
  input  logic i_rst_n,                             // Active-low reset.
  input  logic i_clear,                             // Clears the running accumulation state.
  input  logic i_col_start,                         // Marks the first c2v input slot of a variable column.
  input  logic i_col_end,                           // Marks the final c2v input slot of a variable column.
  input  logic signed [APP_W-1:0] i_initial_llr,    // Prior LLR contribution for the variable node.
  input  logic i_c2v_tc_valid0,                     // Valid qualifier for c2v input lane 0.
  input  logic signed [MSG_W-1:0] i_c2v_tc0,        // c2v input from lane 0 in two's-complement.
  input  logic i_c2v_tc_valid1,                     // Valid qualifier for c2v input lane 1.
  input  logic signed [MSG_W-1:0] i_c2v_tc1,        // c2v input from lane 1 in two's-complement.
  output logic o_app_valid,                         // Posterior APP valid qualifier.
  output logic signed [APP_W-1:0] o_app,            // Posterior APP value after accumulation.
  output logic o_bit_decision,                      // Hard decision derived from the posterior APP.
  input  logic i_emit_en,                           // Enables v2c emission using cached previous c2v.
  input  logic i_prev_c2v_tc_valid0,                // Valid qualifier for previous c2v on emit lane 0.
  input  logic signed [MSG_W-1:0] i_prev_c2v_tc0,   // Previous c2v value for emit lane 0.
  input  logic i_prev_c2v_tc_valid1,                // Valid qualifier for previous c2v on emit lane 1.
  input  logic signed [MSG_W-1:0] i_prev_c2v_tc1,   // Previous c2v value for emit lane 1.
  output logic o_v2c_tc_valid0,                     // Valid qualifier for v2c output lane 0.
  output logic signed [VNU_TC_W-1:0] o_v2c_tc0,     // v2c output on lane 0 in two's-complement.
  output logic o_v2c_tc_valid1,                     // Valid qualifier for v2c output lane 1.
  output logic signed [VNU_TC_W-1:0] o_v2c_tc1      // v2c output on lane 1 in two's-complement.
);

  timeunit 1ns;
  timeprecision 1ps;

  localparam int SCALE_W = VNU_TC_W + ALPHA_FRAC_W;

  logic signed [VNU_TC_W-1:0] cycle_accum_sum;
  logic signed [VNU_TC_W-1:0] accum_sum_reg;
  logic signed [VNU_TC_W-1:0] accum_sum_next;
  logic signed [VNU_TC_W-1:0] posterior_reg;
  logic signed [VNU_TC_W-1:0] posterior_next;
  logic signed [VNU_TC_W-1:0] prior_msg_sign_extend;
  logic accum_valid_any;

  function automatic logic [VNU_TC_W-1:0] tc_abs(
    input logic signed [VNU_TC_W-1:0] tc_value
  );
    begin
      if (tc_value[VNU_TC_W-1]) begin
        tc_abs = (~tc_value) + {{(VNU_TC_W - 1){1'b0}}, 1'b1};
      end else begin
        tc_abs = tc_value[VNU_TC_W-1:0];
      end
    end
  endfunction

  function automatic logic signed [VNU_TC_W-1:0] mag_to_signed(
    input logic tc_sign,
    input logic [VNU_TC_W-1:0] mag_value
  );
    logic signed [VNU_TC_W-1:0] mag_signed;
    begin
      mag_signed = $signed(mag_value);
      if (tc_sign && (mag_value != '0)) begin
        mag_to_signed = -mag_signed;
      end else begin
        mag_to_signed = mag_signed;
      end
    end
  endfunction

  function automatic logic signed [VNU_TC_W-1:0] sign_extend(
    input logic signed [MSG_W-1:0] tc_value
  );
    begin
      sign_extend = {{(VNU_TC_W - MSG_W){tc_value[MSG_W-1]}}, tc_value};
    end
  endfunction

  function automatic logic [VNU_TC_W-1:0] alpha_scale_mag(
    input logic [VNU_TC_W-1:0] mag_value
  );
    logic [SCALE_W-1:0] mag_ext;
    logic [SCALE_W-1:0] scaled_abs_full;
    logic [SCALE_W-1:0] rounding_bias;
    begin
      mag_ext = {{(SCALE_W - VNU_TC_W){1'b0}}, mag_value};
      scaled_abs_full = '0;
      scaled_abs_full = scaled_abs_full + (mag_ext << (ALPHA_FRAC_W - ALPHA_SHIFT_0));
      scaled_abs_full = scaled_abs_full + (mag_ext << (ALPHA_FRAC_W - ALPHA_SHIFT_1));
      rounding_bias = '0;
      rounding_bias[ALPHA_FRAC_W-1] = 1'b1;
      scaled_abs_full = (scaled_abs_full + rounding_bias) >> ALPHA_FRAC_W;
      alpha_scale_mag = scaled_abs_full[VNU_TC_W-1:0];
    end
  endfunction

  function automatic logic signed [VNU_TC_W-1:0] alpha_scale(
    input logic signed [VNU_TC_W-1:0] tc_value
  );
    logic tc_sign;
    logic [VNU_TC_W-1:0] scaled_abs_value;
    begin
      tc_sign = tc_value[VNU_TC_W-1];
      scaled_abs_value = alpha_scale_mag(tc_abs(tc_value));
      alpha_scale = mag_to_signed(tc_sign, scaled_abs_value);
    end
  endfunction

  always_comb begin
    logic signed [VNU_TC_W-1:0] scaled_sum;
    logic signed [VNU_TC_W-1:0] next_u0;
    logic signed [VNU_TC_W-1:0] next_u1;

    cycle_accum_sum = '0;
    accum_valid_any = 1'b0;
    if (i_c2v_tc_valid0) begin
      cycle_accum_sum = cycle_accum_sum + sign_extend(i_c2v_tc0);
      accum_valid_any = 1'b1;
    end
    if (i_c2v_tc_valid1) begin
      cycle_accum_sum = cycle_accum_sum + sign_extend(i_c2v_tc1);
      accum_valid_any = 1'b1;
    end

    if (i_col_start) begin
      accum_sum_next = cycle_accum_sum;
    end else begin
      accum_sum_next = accum_sum_reg + cycle_accum_sum;
    end

    prior_msg_sign_extend = {{(VNU_TC_W - APP_W){i_initial_llr[APP_W-1]}}, i_initial_llr};
    scaled_sum = alpha_scale(accum_sum_next);
    posterior_next = prior_msg_sign_extend + scaled_sum;

    next_u0 = posterior_reg - alpha_scale(sign_extend(i_prev_c2v_tc0));
    next_u1 = posterior_reg - alpha_scale(sign_extend(i_prev_c2v_tc1));
    o_v2c_tc_valid0 = i_emit_en && i_prev_c2v_tc_valid0;
    o_v2c_tc_valid1 = i_emit_en && i_prev_c2v_tc_valid1;
    o_v2c_tc0 = o_v2c_tc_valid0 ? next_u0 : '0;
    o_v2c_tc1 = o_v2c_tc_valid1 ? next_u1 : '0;
  end

  assign o_app = posterior_reg[APP_W-1:0];
  assign o_bit_decision = posterior_reg[VNU_TC_W-1];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      accum_sum_reg <= '0;
      posterior_reg <= '0;
      o_app_valid <= 1'b0;
    end else if (i_clear) begin
      accum_sum_reg <= '0;
      posterior_reg <= '0;
      o_app_valid <= 1'b0;
    end else begin
      o_app_valid <= i_col_end;
      if (i_col_end) begin
        posterior_reg <= posterior_next;
      end
      if ((i_col_start || accum_valid_any) && !i_col_end) begin
        accum_sum_reg <= accum_sum_next;
      end
    end
  end
endmodule
