`timescale 1ns / 1ps
// 变量节点单元(VNU)：由累加的校验到变量(C2V)消息和计算后验 LLR 与对外发出的变量到校验(V2C)消息。
module vnu
  import bike_pkg::*;
(
    input  logic                                i_clk,
    input  logic                                i_rst_n,
    input  logic                                i_valid[0:L-1],
    input  logic signed [            ACC_W-1:0] i_c2v_sum[0:L-1],
    input  logic signed [            ACC_W-1:0] i_c2v_edge[0:L-1],
    input  logic        [       CFG_CVAL_W-1:0] i_cfg_c_val,
    input  logic        [CFG_ALPHA_SHIFT_W-1:0] i_cfg_alpha_shift_0,
    input  logic        [CFG_ALPHA_SHIFT_W-1:0] i_cfg_alpha_shift_1,
    output logic signed [            ACC_W-1:0] o_posterior[0:L-1],
    output logic signed [            ACC_W-1:0] o_v2c_tc[0:L-1]
);

  // 定点位宽：ACC_W 位整数加 ALPHA_FRAC_W 位小数，用于 alpha 缩放。
  localparam int SCALE_W = ACC_W + ALPHA_FRAC_W;

  logic                      scale_valid_q[0:L-1];
  logic signed [SCALE_W-1:0] posterior_scaled_q[0:L-1];
  logic signed [SCALE_W-1:0] v2c_scaled_q[0:L-1];
  logic signed [  ACC_W-1:0] posterior_tc[0:L-1];

  // alpha 缩放：对输入 LLR 做移位相加，对应 alpha 的至多两个非零位。
  function automatic logic signed [SCALE_W-1:0] alpha_accum(
      input  logic signed [ACC_W-1:0] tc_value, input  logic [CFG_ALPHA_SHIFT_W-1:0] shift_0,
      input  logic [CFG_ALPHA_SHIFT_W-1:0] shift_1);
    logic signed [SCALE_W-1:0] scale_ext;
    logic signed [SCALE_W-1:0] scaled_full;
    begin
      scale_ext   = SCALE_W'($signed(tc_value));
      scaled_full = '0;
      if ((shift_0 > '0) && (int'(shift_0) <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - int'(shift_0)));
      end
      if ((shift_1 > '0) && (int'(shift_1) <= ALPHA_FRAC_W)) begin
        scaled_full = scaled_full + (scale_ext <<< (ALPHA_FRAC_W - int'(shift_1)));
      end
      alpha_accum = scaled_full;
    end
  endfunction

  // 将 alpha 缩放后的定点 LLR 按就近舍入(遇半远离零、按符号非对称处理)还原为补码。
  function automatic logic signed [ACC_W-1:0] alpha_round(
      input  logic signed [SCALE_W-1:0] scaled_full);
    logic signed [       ACC_W-1:0] floor_tc;
    logic signed [       ACC_W-1:0] trunc_tc;
    logic        [ALPHA_FRAC_W-1:0] frac_bits;
    logic        [  ALPHA_FRAC_W:0] neg_frac_mag;
    logic                           frac_nonzero;
    logic                           round_bit;
    begin
      floor_tc = scaled_full[SCALE_W-1:ALPHA_FRAC_W];
      frac_bits = scaled_full[ALPHA_FRAC_W-1:0];
      frac_nonzero = |frac_bits;
      if (scaled_full[SCALE_W-1]) begin
        trunc_tc = frac_nonzero ? (floor_tc + ACC_W'(1)) : floor_tc;
        neg_frac_mag = frac_nonzero ? ({1'b1, {ALPHA_FRAC_W{1'b0}}} - {1'b0, frac_bits}) : '0;
        round_bit = neg_frac_mag[ALPHA_FRAC_W-1];
        alpha_round = round_bit ? (trunc_tc - ACC_W'(1)) : trunc_tc;
      end else begin
        trunc_tc = floor_tc;
        round_bit = frac_bits[ALPHA_FRAC_W-1];
        alpha_round = round_bit ? (trunc_tc + ACC_W'(1)) : trunc_tc;
      end
    end
  endfunction

  // 有效时生成后验(信道项 c_val 加 alpha 缩放的 C2V 和)与对外 V2C 消息(后验减去当前边)。
  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_posterior[lane_idx] = '0;
      posterior_tc[lane_idx] = '0;
      o_v2c_tc[lane_idx] = '0;
      if (scale_valid_q[lane_idx]) begin
        posterior_tc[lane_idx] = ACC_W'($signed(i_cfg_c_val)) +
            alpha_round(posterior_scaled_q[lane_idx]);
        o_v2c_tc[lane_idx] = ACC_W'($signed(i_cfg_c_val)) + alpha_round(v2c_scaled_q[lane_idx]);
        o_posterior[lane_idx] = posterior_tc[lane_idx];
      end
    end
  end

  // 流水线寄存 alpha 缩放结果：有效时锁存，否则清零。
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        scale_valid_q[lane_idx] <= 1'b0;
        posterior_scaled_q[lane_idx] <= '0;
        v2c_scaled_q[lane_idx] <= '0;
      end
    end else begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        scale_valid_q[lane_idx] <= i_valid[lane_idx];
        if (i_valid[lane_idx]) begin
          // 分别对完整 C2V 和(后验路径)与减去当前边的和(V2C 路径)施加 alpha 修正因子。
          posterior_scaled_q[lane_idx] <= alpha_accum(
              i_c2v_sum[lane_idx], i_cfg_alpha_shift_0, i_cfg_alpha_shift_1
          );
          v2c_scaled_q[lane_idx] <= alpha_accum(
              i_c2v_sum[lane_idx] - i_c2v_edge[lane_idx], i_cfg_alpha_shift_0, i_cfg_alpha_shift_1
          );
        end else begin
          posterior_scaled_q[lane_idx] <= '0;
          v2c_scaled_q[lane_idx] <= '0;
        end
      end
    end
  end
endmodule
