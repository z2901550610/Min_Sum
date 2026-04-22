// 变量节点单元：累加 c2v 消息，并生成更新后的 v2c。
module vnu
  import bike_pkg::*;
(
  input  logic                          i_clk,
  input  logic                          i_rst_n,
  input  logic                          i_clear,

  // 当前变量列的 c2v 累加控制与先验 LLR。
  input  logic                          i_col_start,
  input  logic                          i_col_end,
  input  logic signed [APP_W-1:0]        i_initial_llr,

  // 来自两个 row_group 的当前 c2v 输入，使用二进制补码表示。
  input  logic                          i_c2v0_valid,
  input  logic signed [MSG_W-1:0]        i_c2v0,
  input  logic                          i_c2v1_valid,
  input  logic signed [MSG_W-1:0]        i_c2v1,

  // 写回 RAM-T 的 c2v 透传数据；无效输入被清零。
  output logic        [MSG_W-1:0]        o_c2v_to_ram_t0,
  output logic        [MSG_W-1:0]        o_c2v_to_ram_t1,

  // 后验 APP 与硬判决输出。
  output logic                          o_app_valid,
  output logic signed [APP_W-1:0]        o_app,
  output logic                          o_bit_decision,

  // 从 RAM-T 读出的上一轮 c2v；valid 已包含 v2c 发射阶段门控。
  input  logic                          i_c2v_from_ram_t0_valid,
  input  logic signed [MSG_W-1:0]        i_c2v_from_ram_t0,
  input  logic                          i_c2v_from_ram_t1_valid,
  input  logic signed [MSG_W-1:0]        i_c2v_from_ram_t1,

  // 输出给 CNU_A 的 v2c，使用未饱和的二进制补码表示。
  output logic                          o_v2c_valid0,
  output logic signed [VNU_TC_W-1:0]     o_v2c0,
  output logic                          o_v2c_valid1,
  output logic signed [VNU_TC_W-1:0]     o_v2c1
);

  timeunit 1ns;
  timeprecision 1ps;

  localparam int SCALE_W = VNU_TC_W + ALPHA_FRAC_W;

  assign o_c2v_to_ram_t0 = i_c2v0_valid ? i_c2v0 : '0;
  assign o_c2v_to_ram_t1 = i_c2v1_valid ? i_c2v1 : '0;

  logic signed [VNU_TC_W-1:0] cycle_sum;
  logic signed [VNU_TC_W-1:0] scaled_sum;
  logic signed [VNU_TC_W-1:0] accum_sum_reg;
  logic signed [VNU_TC_W-1:0] accum_sum_next;
  logic signed [VNU_TC_W-1:0] posterior_reg;
  logic signed [VNU_TC_W-1:0] posterior_next;
  logic signed [VNU_TC_W-1:0] prior_msg_sign_extend;
  logic                       accum_valid_any;

  // 按配置的 alpha 系数缩放二进制补码值，并四舍五入到整数。
  function automatic logic signed [VNU_TC_W-1:0] alpha_scale(
    input logic signed [VNU_TC_W-1:0] tc_value
  );
    logic signed [SCALE_W-1:0]      scale_ext;
    logic signed [SCALE_W-1:0]      scaled_full;
    logic signed [VNU_TC_W-1:0]     floor_tc;
    logic signed [VNU_TC_W-1:0]     trunc_tc;
    logic        [ALPHA_FRAC_W-1:0] frac_bits;
    logic        [ALPHA_FRAC_W:0]   neg_frac_mag;
    logic                           frac_nonzero;
    logic                           round_bit;

    begin
      scale_ext = SCALE_W'($signed(tc_value));
      scaled_full = '0;
      scaled_full =
        scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_0));
      scaled_full =
        scaled_full + (scale_ext <<< (ALPHA_FRAC_W - ALPHA_SHIFT_1));

      floor_tc = scaled_full[SCALE_W-1:ALPHA_FRAC_W];
      frac_bits = scaled_full[ALPHA_FRAC_W-1:0];
      frac_nonzero = |frac_bits;

      if (scaled_full[SCALE_W-1]) begin
        trunc_tc = frac_nonzero ? (floor_tc + 1'b1) : floor_tc;
        neg_frac_mag = frac_nonzero ?
          ({1'b1, {ALPHA_FRAC_W{1'b0}}} - {1'b0, frac_bits}) :
          '0;
        round_bit = neg_frac_mag[ALPHA_FRAC_W-1];
        alpha_scale = round_bit ? (trunc_tc - 1'b1) : trunc_tc;
      end else begin
        trunc_tc = floor_tc;
        round_bit = frac_bits[ALPHA_FRAC_W-1];
        alpha_scale = round_bit ? (trunc_tc + 1'b1) : trunc_tc;
      end
    end
  endfunction

  always_comb begin
    logic signed [VNU_TC_W-1:0] c2v_tc0_ext;
    logic signed [VNU_TC_W-1:0] c2v_tc1_ext;
    logic signed [VNU_TC_W-1:0] prev_c2v_tc0_ext;
    logic signed [VNU_TC_W-1:0] prev_c2v_tc1_ext;
    logic signed [VNU_TC_W-1:0] scaled_prev_c2v0;
    logic signed [VNU_TC_W-1:0] scaled_prev_c2v1;
    logic signed [VNU_TC_W-1:0] next_u0;
    logic signed [VNU_TC_W-1:0] next_u1;

    cycle_sum = '0;
    accum_valid_any = 1'b0;
    c2v_tc0_ext = VNU_TC_W'($signed(i_c2v0));
    c2v_tc1_ext = VNU_TC_W'($signed(i_c2v1));
    prev_c2v_tc0_ext = VNU_TC_W'($signed(i_c2v_from_ram_t0));
    prev_c2v_tc1_ext = VNU_TC_W'($signed(i_c2v_from_ram_t1));
    scaled_sum = '0;
    scaled_prev_c2v0 = '0;
    scaled_prev_c2v1 = '0;
    next_u0 = '0;
    next_u1 = '0;
    posterior_next = '0;
    o_v2c_valid0 = 1'b0;
    o_v2c_valid1 = 1'b0;
    o_v2c0 = '0;
    o_v2c1 = '0;

    if (i_c2v0_valid) begin
      cycle_sum = cycle_sum + c2v_tc0_ext;
      accum_valid_any = 1'b1;
    end
    if (i_c2v1_valid) begin
      cycle_sum = cycle_sum + c2v_tc1_ext;
      accum_valid_any = 1'b1;
    end

    if (i_col_start) begin
      accum_sum_next = cycle_sum;
    end else begin
      accum_sum_next = accum_sum_reg + cycle_sum;
    end

    prior_msg_sign_extend = VNU_TC_W'($signed(i_initial_llr));
    scaled_sum = alpha_scale(accum_sum_next);
    scaled_prev_c2v0 = alpha_scale(prev_c2v_tc0_ext);
    scaled_prev_c2v1 = alpha_scale(prev_c2v_tc1_ext);
    posterior_next = prior_msg_sign_extend + scaled_sum;

    next_u0 = posterior_reg - scaled_prev_c2v0;
    next_u1 = posterior_reg - scaled_prev_c2v1;
    o_v2c_valid0 = i_c2v_from_ram_t0_valid;
    o_v2c_valid1 = i_c2v_from_ram_t1_valid;
    o_v2c0 = o_v2c_valid0 ? next_u0 : '0;
    o_v2c1 = o_v2c_valid1 ? next_u1 : '0;
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
