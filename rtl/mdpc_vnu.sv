module mdpc_vnu (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_en,
  input  logic start_var,
  input  logic last_accum,
  input  logic signed [APP_W-1:0] prior_msg_in,
  input  logic accum_valid0,
  input  logic signed [MSG_W-1:0] accum_c2v0,
  input  logic accum_valid1,
  input  logic signed [MSG_W-1:0] accum_c2v1,
  input  logic signed [MSG_W-1:0] cached_c2v_in [0:W-1],
  output logic result_valid,
  output logic signed [APP_W-1:0] app_out,
  output logic x_out,
  output logic [MSG_W-1:0] u_next_out [0:W-1]
);

  import mdpc_demo_pkg::*;

  // VNU stays in signed 2's-complement: RAM T already holds signed c2v, and
  // only the final u_next values are converted back to sign-magnitude.

  localparam int VNU_TC_W = APP_W + ((W > 1) ? $clog2(W + 1) : 1);
  localparam int SCALE_W = VNU_TC_W + ALPHA_FRAC_W;

  logic signed [VNU_TC_W-1:0] cycle_accum_sum;
  logic signed [VNU_TC_W-1:0] accum_sum_reg;
  logic signed [VNU_TC_W-1:0] accum_sum_next;
  logic signed [VNU_TC_W-1:0] prior_msg_sign_extend;
  logic signed [VNU_TC_W-1:0] scaled_accum_sum;
  logic signed [VNU_TC_W-1:0] posterior_msg;
  logic accum_valid_any;
  logic final_accum_cycle;

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

  // alpha is represented as two fractional shifts plus round-to-nearest bias.
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

  // Preserve sign while scaling the magnitude.
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

  // RAM U has D magnitude bits, so clamp the VNU result before crossing back
  // to sign-magnitude.
  function automatic logic [MSG_W-1:0] tc_to_signmag_sat(
    input logic signed [VNU_TC_W-1:0] tc_value
  );
    logic tc_sign;
    logic [VNU_TC_W-1:0] abs_value;
    logic [D-1:0] sat_mag;
    begin
      tc_sign = tc_value[VNU_TC_W-1];
      if (tc_sign) begin
        abs_value = (~tc_value) + {{(VNU_TC_W - 1){1'b0}}, 1'b1};
      end else begin
        abs_value = tc_value[VNU_TC_W-1:0];
      end

      if (|abs_value[VNU_TC_W-1:D]) begin
        sat_mag = D'(MAG_MAX);
      end else begin
        sat_mag = abs_value[D-1:0];
      end

      tc_to_signmag_sat = {tc_sign && (sat_mag != '0), sat_mag};
    end
  endfunction

  always_comb begin
    integer edge_idx;
    logic signed [VNU_TC_W-1:0] cached_c2v_signed;
    logic signed [VNU_TC_W-1:0] scaled_cached_c2v_signed;
    logic signed [VNU_TC_W-1:0] next_u_signed;

    // Accumulate up to L=2 c2v messages per cycle.
    cycle_accum_sum = '0;
    accum_valid_any = 1'b0;
    if (accum_valid0) begin
      cycle_accum_sum = cycle_accum_sum + sign_extend(accum_c2v0);
      accum_valid_any = 1'b1;
    end
    if (accum_valid1) begin
      cycle_accum_sum = cycle_accum_sum + sign_extend(accum_c2v1);
      accum_valid_any = 1'b1;
    end

    // start_var selects the first cycle of a variable-node accumulation.
    if (start_var) begin
      accum_sum_next = cycle_accum_sum;
    end else begin
      accum_sum_next = accum_sum_reg + cycle_accum_sum;
    end

    // Scale the completed c2v sum once, then add the channel prior gamma_j.
    prior_msg_sign_extend = {{(VNU_TC_W - APP_W){prior_msg_in[APP_W-1]}}, prior_msg_in};
    final_accum_cycle = last_accum && accum_valid_any;
    result_valid = final_accum_cycle;
    scaled_accum_sum = '0;
    posterior_msg = '0;
    cached_c2v_signed = '0;
    scaled_cached_c2v_signed = '0;
    next_u_signed = '0;
    app_out = '0;
    x_out = 1'b0;

    // cached_c2v_in is reused to form u_next = app - alpha * c2v for every edge.
    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      u_next_out[edge_idx] = '0;
    end

    if (final_accum_cycle) begin
      scaled_accum_sum = alpha_scale(accum_sum_next);
      posterior_msg = prior_msg_sign_extend + scaled_accum_sum;
      app_out = posterior_msg[APP_W-1:0];
      x_out = posterior_msg[VNU_TC_W-1];

      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        cached_c2v_signed = sign_extend(cached_c2v_in[edge_idx]);
        scaled_cached_c2v_signed = alpha_scale(cached_c2v_signed);
        next_u_signed = posterior_msg - scaled_cached_c2v_signed;
        u_next_out[edge_idx] = tc_to_signmag_sat(next_u_signed);
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      accum_sum_reg <= '0;
    end else if (clear_en) begin
      accum_sum_reg <= '0;
    // The final cycle consumes accum_sum_next directly; no register writeback.
    end else if ((start_var || accum_valid_any) && !last_accum) begin
      accum_sum_reg <= accum_sum_next;
    end
  end
endmodule
