module mdpc_vnu (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_en,
  input  logic start_var,
  input  logic last_accum,
  input  logic signed [APP_W-1:0] prior_msg_in,
  input  logic accum_valid0,
  input  logic [MSG_W-1:0] accum_c2v0,
  input  logic accum_valid1,
  input  logic [MSG_W-1:0] accum_c2v1,
  input  logic [MSG_W-1:0] cached_c2v_in [0:W-1],
  output logic result_valid,
  output logic signed [APP_W-1:0] app_out,
  output logic x_out,
  output logic [MSG_W-1:0] u_next_out [0:W-1]
);

  import mdpc_demo_pkg::*;

  localparam int VNU_TC_W = APP_W + ((W > 1) ? $clog2(W + 1) : 1);
  localparam int SCALE_W = VNU_TC_W + $clog2(ALPHA_NUM + 1) + 1;

  logic signed [VNU_TC_W-1:0] accum_delta;
  logic signed [VNU_TC_W-1:0] running_sum_reg;
  logic signed [VNU_TC_W-1:0] running_sum_next;
  logic signed [VNU_TC_W-1:0] prior_msg_tc;
  logic signed [VNU_TC_W-1:0] scaled_sum_tc;
  logic signed [VNU_TC_W-1:0] app_tc;
  logic accum_valid_any;

  // Convert one sign-magnitude message into a signed 2's-complement value
  // so the per-cycle c2v accumulation can use ordinary adders.
  function automatic logic signed [VNU_TC_W-1:0] signmag_to_tc(
    input logic [MSG_W-1:0] signmag_value
  );
    logic [VNU_TC_W-1:0] mag_ext;
    logic signed [VNU_TC_W-1:0] mag_tc;
    begin
      mag_ext = {{(VNU_TC_W - D){1'b0}}, signmag_value[MSG_MAG_LSB +: D]};
      mag_tc = $signed(mag_ext);
      if (signmag_value[MSG_SIGN_BIT]) begin
        signmag_to_tc = ~mag_tc + {{(VNU_TC_W - 1){1'b0}}, 1'b1};
      end else begin
        signmag_to_tc = mag_tc;
      end
    end
  endfunction

  // Apply the paper's alpha scaling with rounding in 2's-complement domain.
  // This is used both for alpha*sum(v) and for alpha*v_ij.
  function automatic logic signed [VNU_TC_W-1:0] alpha_scale_tc(
    input logic signed [VNU_TC_W-1:0] tc_value
  );
    logic tc_sign;
    logic [VNU_TC_W-1:0] abs_value;
    logic [SCALE_W-1:0] abs_value_ext;
    logic [SCALE_W-1:0] alpha_num_ext;
    logic [SCALE_W-1:0] scaled_abs_full;
    logic [SCALE_W-1:0] rounding_bias;
    begin
      tc_sign = tc_value[VNU_TC_W-1];
      if (tc_sign) begin
        abs_value = (~tc_value) + {{(VNU_TC_W - 1){1'b0}}, 1'b1};
      end else begin
        abs_value = tc_value[VNU_TC_W-1:0];
      end

      abs_value_ext = {{(SCALE_W - VNU_TC_W){1'b0}}, abs_value};
      alpha_num_ext = ALPHA_NUM;
      rounding_bias = '0;
      rounding_bias[ALPHA_SHIFT-1] = 1'b1;
      scaled_abs_full = (alpha_num_ext * abs_value_ext) + rounding_bias;
      scaled_abs_full = scaled_abs_full >> ALPHA_SHIFT;

      if (tc_sign) begin
        alpha_scale_tc = ~$signed(scaled_abs_full[VNU_TC_W-1:0]) + {{(VNU_TC_W - 1){1'b0}}, 1'b1};
      end else begin
        alpha_scale_tc = $signed(scaled_abs_full[VNU_TC_W-1:0]);
      end
    end
  endfunction

  // Convert a signed 2's-complement result back to sign-magnitude and
  // saturate the magnitude before writing u_ij back to RAM U.
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
    logic signed [VNU_TC_W-1:0] c2v_tc;
    logic signed [VNU_TC_W-1:0] scaled_c2v_tc;
    logic signed [VNU_TC_W-1:0] u_tc;

    // Accumulate up to two c2v messages per cycle, matching the paper's
    // 2-parallel VNU datapath.
    accum_delta = '0;
    accum_valid_any = 1'b0;
    if (accum_valid0) begin
      accum_delta = accum_delta + signmag_to_tc(accum_c2v0);
      accum_valid_any = 1'b1;
    end
    if (accum_valid1) begin
      accum_delta = accum_delta + signmag_to_tc(accum_c2v1);
      accum_valid_any = 1'b1;
    end

    // Start a fresh variable-node accumulation on the first cycle; otherwise
    // keep accumulating on top of the registered partial sum.
    if (start_var) begin
      running_sum_next = accum_delta;
    end else begin
      running_sum_next = running_sum_reg + accum_delta;
    end

    // Compute the a-posteriori message app = prior + alpha * sum(v).
    prior_msg_tc = {{(VNU_TC_W - APP_W){prior_msg_in[APP_W-1]}}, prior_msg_in};
    scaled_sum_tc = alpha_scale_tc(running_sum_next);
    app_tc = prior_msg_tc + scaled_sum_tc;

    result_valid = last_accum && accum_valid_any;
    app_out = app_tc[APP_W-1:0];
    x_out = app_tc[VNU_TC_W-1];

    // Reuse the cached c2v messages from RAM T to form every next-iteration
    // u_ij = app - alpha * v_ij, then convert back to sign-magnitude.
    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      c2v_tc = signmag_to_tc(cached_c2v_in[edge_idx]);
      scaled_c2v_tc = alpha_scale_tc(c2v_tc);
      u_tc = app_tc - scaled_c2v_tc;
      u_next_out[edge_idx] = tc_to_signmag_sat(u_tc);
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      running_sum_reg <= '0;
    end else if (clear_en) begin
      running_sum_reg <= '0;
    // The last accumulation cycle consumes the current partial sum directly,
    // so there is no need to write it back into the running-sum register.
    end else if ((start_var || accum_valid_any) && !last_accum) begin
      running_sum_reg <= running_sum_next;
    end
  end
endmodule
