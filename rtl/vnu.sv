`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module vnu (
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_col_start,
  input  logic i_col_end,
  input  logic signed [APP_W-1:0] i_initial_llr,
  input  logic i_c2v_valid0,
  input  logic i_c2v_sign0,
  input  logic [D-1:0] i_c2v_mag0,
  input  logic i_c2v_valid1,
  input  logic i_c2v_sign1,
  input  logic [D-1:0] i_c2v_mag1,
  output logic o_app_valid,
  output logic signed [APP_W-1:0] o_app,
  output logic o_bit_decision,
  input  logic i_emit_en,
  input  logic i_c2v_t_valid0,
  input  logic signed [MSG_W-1:0] i_c2v_t0,
  input  logic i_c2v_t_valid1,
  input  logic signed [MSG_W-1:0] i_c2v_t1,
  output logic o_v2c_valid0,
  output logic [MSG_W-1:0] o_v2c0,
  output logic o_v2c_valid1,
  output logic [MSG_W-1:0] o_v2c1
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  localparam int VNU_TC_W = APP_W + ((W > 1) ? $clog2(W + 1) : 1);
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

  function automatic logic signed [MSG_W-1:0] signmag_to_tc_msg(
    input logic msg_sign,
    input logic [D-1:0] msg_mag
  );
    logic signed [MSG_W-1:0] mag_tc;
    begin
      mag_tc = $signed({1'b0, msg_mag});
      if (msg_sign && (msg_mag != '0)) begin
        signmag_to_tc_msg = -mag_tc;
      end else begin
        signmag_to_tc_msg = mag_tc;
      end
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
    logic signed [VNU_TC_W-1:0] scaled_sum;
    logic signed [VNU_TC_W-1:0] next_u0;
    logic signed [VNU_TC_W-1:0] next_u1;

    cycle_accum_sum = '0;
    accum_valid_any = 1'b0;
    if (i_c2v_valid0) begin
      cycle_accum_sum = cycle_accum_sum + sign_extend(signmag_to_tc_msg(i_c2v_sign0, i_c2v_mag0));
      accum_valid_any = 1'b1;
    end
    if (i_c2v_valid1) begin
      cycle_accum_sum = cycle_accum_sum + sign_extend(signmag_to_tc_msg(i_c2v_sign1, i_c2v_mag1));
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

    next_u0 = posterior_reg - alpha_scale(sign_extend(i_c2v_t0));
    next_u1 = posterior_reg - alpha_scale(sign_extend(i_c2v_t1));
    o_v2c_valid0 = i_emit_en && i_c2v_t_valid0;
    o_v2c_valid1 = i_emit_en && i_c2v_t_valid1;
    o_v2c0 = o_v2c_valid0 ? tc_to_signmag_sat(next_u0) : '0;
    o_v2c1 = o_v2c_valid1 ? tc_to_signmag_sat(next_u1) : '0;
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
