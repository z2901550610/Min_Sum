`timescale 1ns / 1ps
// VNU：累加 c2v 消息，并生成更新后的 v2c
// VNU 内部数据均用2的补码表示，与符号-幅度之间的转换在VNU外部进行
module vnu #(
    parameter int W = 3,  //矩阵列权重，此处简化
    parameter int D = 4,  //消息的幅度位宽
    parameter int MSG_W = D + 1,
    parameter int L = 2,
    parameter int ALPHA_FRAC_W = 6,
    parameter int ALPHA_SHIFT_0 = 4,
    parameter int ALPHA_SHIFT_1 = 5,
    parameter int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1)
) (
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic                       i_col_start,
    input  logic                       i_col_end,
    input  logic                       i_finalize,
    input  logic signed [   MSG_W-1:0] i_initial_llr,
    input  logic                       i_c2v_valid[0:L-1],
    input  logic signed [   MSG_W-1:0] i_c2v[0:L-1],
    output logic                       o_c2v_t_valid[0:L-1],
    output logic        [   MSG_W-1:0] o_c2v_t[0:L-1],
    output logic                       o_bit_decision,
    input  logic                       i_c2v_t_valid[0:L-1],
    input  logic signed [   MSG_W-1:0] i_c2v_t[0:L-1],
    output logic                       o_v2c_valid[0:L-1],
    output logic signed [VNU_TC_W-1:0] o_v2c[0:L-1]
);

  localparam int SCALE_W = VNU_TC_W + ALPHA_FRAC_W;

  logic signed [VNU_TC_W-1:0] cycle_sum;  // 当前拍收到的 c2v 和
  logic signed [VNU_TC_W-1:0] accum_sum_reg;  // 列内先前累加保存的 c2v 和
  logic signed [VNU_TC_W-1:0] accum_sum_next;  // 本拍更新后的列累加和
  logic signed [VNU_TC_W-1:0] final_sum_reg;  // 列结束时缓存的累加和
  logic signed [VNU_TC_W-1:0] scaled_sum;             // 本拍更新后的累加和经过 alpha 缩放后的结果
  logic signed [VNU_TC_W-1:0] posterior_reg;  // 已锁存的后验值，供下一拍生成 v2c
  logic signed [VNU_TC_W-1:0] posterior_next;  // 本拍组合计算得到的后验值
  logic signed [VNU_TC_W-1:0] prior_msg_sign_extend;  // 符号位扩展的先验 LLR
  logic accum_valid_any;  // 本拍是否至少收到一个有效 c2v

  // 按 alpha 系数缩放二进制补码值，并四舍五入到整数。
  function automatic logic signed [VNU_TC_W-1:0] alpha_scale(
      input  logic signed [VNU_TC_W-1:0] tc_value);
    logic signed [     SCALE_W-1:0] scale_ext;
    logic signed [     SCALE_W-1:0] scaled_full;
    logic signed [    VNU_TC_W-1:0] floor_tc;
    logic signed [    VNU_TC_W-1:0] trunc_tc;
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
        trunc_tc = frac_nonzero ? (floor_tc + 1'b1) : floor_tc;
        neg_frac_mag = frac_nonzero ? ({1'b1, {ALPHA_FRAC_W{1'b0}}} - {1'b0, frac_bits}) : '0;
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
    logic signed [VNU_TC_W-1:0] c2v_ext;
    logic signed [VNU_TC_W-1:0] c2v_t_ext;
    logic signed [VNU_TC_W-1:0] scaled_c2v_t;
    logic signed [VNU_TC_W-1:0] next_u;

    cycle_sum = '0;
    accum_valid_any = 1'b0;
    accum_sum_next = accum_sum_reg;
    scaled_sum = '0;
    c2v_ext = '0;
    c2v_t_ext = '0;
    scaled_c2v_t = '0;
    next_u = '0;
    posterior_next = '0;

    prior_msg_sign_extend = VNU_TC_W'($signed(i_initial_llr));

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_c2v_t_valid[lane_idx] = 1'b0;
      o_c2v_t[lane_idx] = '0;
      o_v2c_valid[lane_idx] = 1'b0;
      o_v2c[lane_idx] = '0;

      c2v_ext = VNU_TC_W'($signed(i_c2v[lane_idx]));
      if (i_c2v_valid[lane_idx]) begin
        cycle_sum = cycle_sum + c2v_ext;
        accum_valid_any = 1'b1;
        o_c2v_t_valid[lane_idx] = 1'b1;
        o_c2v_t[lane_idx] = i_c2v[lane_idx];
      end
    end

    if (i_col_start) begin
      accum_sum_next = cycle_sum;
    end else begin
      accum_sum_next = accum_sum_reg + cycle_sum;
    end

    scaled_sum = alpha_scale((i_finalize && (i_col_start || i_col_end || accum_valid_any)) ?
                             accum_sum_next : final_sum_reg);
    posterior_next = prior_msg_sign_extend + scaled_sum;

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      c2v_t_ext = VNU_TC_W'($signed(i_c2v_t[lane_idx]));
      scaled_c2v_t = alpha_scale(c2v_t_ext);
      next_u = posterior_reg - scaled_c2v_t;
      if (i_c2v_t_valid[lane_idx]) begin
        o_v2c_valid[lane_idx] = 1'b1;
        o_v2c[lane_idx] = next_u;
      end
    end
  end

  assign o_bit_decision = posterior_reg[VNU_TC_W-1];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      accum_sum_reg <= '0;
      final_sum_reg <= '0;
      posterior_reg <= '0;
    end else begin
      if (i_col_end) begin
        final_sum_reg <= accum_sum_next;
      end
      if (i_finalize) begin
        posterior_reg <= posterior_next;
      end
      if ((i_col_start || accum_valid_any) && !i_col_end) begin
        accum_sum_reg <= accum_sum_next;
      end
    end
  end
endmodule
