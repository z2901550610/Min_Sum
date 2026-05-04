`timescale 1ns/1ps
// VNU：累加 c2v 消息，并生成更新后的 v2c
// VNU 内部数据均用2的补码表示，与符号-幅度之间的转换在VNU外部进行
module vnu
  #(
    parameter int W = 3,  //矩阵列权重，此处简化
    parameter int D = 4,  //消息的幅度位宽
    parameter int MSG_W = D + 1,
    parameter int ALPHA_FRAC_W = 6,
    parameter int ALPHA_SHIFT_0 = 4,
    parameter int ALPHA_SHIFT_1 = 5,
    parameter int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1)
  )
(
  input  logic                       i_clk,
  input  logic                       i_rst_n,

  // 当前列的 c2v 累加控制与先验 LLR
  input  logic                       i_col_start,
  input  logic                       i_col_end,
  input  logic signed [MSG_W-1:0]    i_initial_llr,

  // 来自两个 CNU B 的当前 c2v 输入，使用2的补码表示
  input  logic                       i_c2v0_valid,
  input  logic signed [MSG_W-1:0]    i_c2v0,
  input  logic                       i_c2v1_valid,
  input  logic signed [MSG_W-1:0]    i_c2v1,

  // 写回 RAM-T 的 c2v 消息
  output logic                       o_c2v_t0_valid,
  output logic        [MSG_W-1:0]    o_c2v_t0,
  output logic                       o_c2v_t1_valid,
  output logic        [MSG_W-1:0]    o_c2v_t1,

  // 硬判决输出(一次输出一bit判决)
  output logic                       o_bit_decision,

  // 从 RAM-T 读出的先前 c2v，用于计算 v2c 消息
  input  logic                       i_c2v_t0_valid,
  input  logic signed [MSG_W-1:0]    i_c2v_t0,
  input  logic                       i_c2v_t1_valid,
  input  logic signed [MSG_W-1:0]    i_c2v_t1,

  // 输出给 CNU_A 的 v2c，使用未饱和的2的补码表示
  output logic                       o_v2c0_valid,
  output logic signed [VNU_TC_W-1:0] o_v2c0,
  output logic                       o_v2c1_valid,
  output logic signed [VNU_TC_W-1:0] o_v2c1
);

  localparam int SCALE_W = VNU_TC_W + ALPHA_FRAC_W;

  logic signed [VNU_TC_W-1:0] cycle_sum;              // 当前拍收到的 c2v 和
  logic signed [VNU_TC_W-1:0] accum_sum_reg;          // 列内先前累加保存的 c2v 和
  logic signed [VNU_TC_W-1:0] accum_sum_next;         // 本拍更新后的列累加和
  logic signed [VNU_TC_W-1:0] scaled_sum;             // 本拍更新后的累加和经过 alpha 缩放后的结果
  logic signed [VNU_TC_W-1:0] posterior_reg;          // 已锁存的后验值，供下一拍生成 v2c
  logic signed [VNU_TC_W-1:0] posterior_next;         // 本拍组合计算得到的后验值
  logic signed [VNU_TC_W-1:0] prior_msg_sign_extend;  // 符号位扩展的先验 LLR
  logic                       accum_valid_any;        // 本拍是否至少收到一个有效 c2v

  // 按 alpha 系数缩放二进制补码值，并四舍五入到整数(alpha 由 ALPHA_SHIFT_0 和 ALPHA_SHIFT_1 定义)
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
    logic signed [VNU_TC_W-1:0] c2v0_ext;
    logic signed [VNU_TC_W-1:0] c2v1_ext;
    logic signed [VNU_TC_W-1:0] c2v_t0_ext;
    logic signed [VNU_TC_W-1:0] c2v_t1_ext;
    logic signed [VNU_TC_W-1:0] scaled_c2v_t0;
    logic signed [VNU_TC_W-1:0] scaled_c2v_t1;
    logic signed [VNU_TC_W-1:0] next_u0;
    logic signed [VNU_TC_W-1:0] next_u1;

    o_c2v_t0_valid = 1'b0;
    o_c2v_t1_valid = 1'b0;
    o_c2v_t0 = '0;
    o_c2v_t1 = '0;
    o_v2c0_valid = 1'b0;
    o_v2c1_valid = 1'b0;
    o_v2c0 = '0;
    o_v2c1 = '0;

    cycle_sum = '0;
    accum_valid_any = 1'b0;
    accum_sum_next = accum_sum_reg;
    scaled_sum = '0;
    scaled_c2v_t0 = '0;
    scaled_c2v_t1 = '0;
    next_u0 = '0;
    next_u1 = '0;
    posterior_next = '0;

    c2v0_ext = VNU_TC_W'($signed(i_c2v0));
    c2v1_ext = VNU_TC_W'($signed(i_c2v1));
    c2v_t0_ext = VNU_TC_W'($signed(i_c2v_t0));
    c2v_t1_ext = VNU_TC_W'($signed(i_c2v_t1));
    prior_msg_sign_extend = VNU_TC_W'($signed(i_initial_llr));

    if (i_c2v0_valid) begin
      cycle_sum = cycle_sum + c2v0_ext;
      accum_valid_any = 1'b1;
      o_c2v_t0_valid = 1'b1;
      o_c2v_t0 = i_c2v0;
    end

    if (i_c2v1_valid) begin
      cycle_sum = cycle_sum + c2v1_ext;
      accum_valid_any = 1'b1;
      o_c2v_t1_valid = 1'b1;
      o_c2v_t1 = i_c2v1;
    end

    if (i_col_start) begin
      accum_sum_next = cycle_sum;
    end else begin
      accum_sum_next = accum_sum_reg + cycle_sum;
    end

    scaled_sum = alpha_scale(accum_sum_next);
    posterior_next = prior_msg_sign_extend + scaled_sum;

    scaled_c2v_t0 = alpha_scale(c2v_t0_ext);
    scaled_c2v_t1 = alpha_scale(c2v_t1_ext);
    next_u0 = posterior_reg - scaled_c2v_t0;
    next_u1 = posterior_reg - scaled_c2v_t1;

    if (i_c2v_t0_valid) begin
      o_v2c0_valid = 1'b1;
      o_v2c0 = next_u0;
    end

    if (i_c2v_t1_valid) begin
      o_v2c1_valid = 1'b1;
      o_v2c1 = next_u1;
    end
  end

  assign o_bit_decision = posterior_reg[VNU_TC_W-1];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      accum_sum_reg <= '0;
      posterior_reg <= '0;
    end else begin
      if (i_col_end) begin
        posterior_reg <= posterior_next;
      end
      if ((i_col_start || accum_valid_any) && !i_col_end) begin
        accum_sum_reg <= accum_sum_next;
      end
    end
  end
endmodule
