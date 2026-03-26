//  c2v_compact_msg 说明：
//  ROW_STATE_W = 15 (D=4, VAR_W=4)
//  bit [14:13] valid_count  (2 bits, 0=empty, 1..W=已处理边数，上限W=3)
//  bit [12]    sign_xor    (1 bit, 累积符号异或，CNU_B 输出符号用该值 ^ v2c_sign_in)
//  bits[11:8]  min_id      (4 bits, 记录 min1 对应的 var_idx)
//  bits[7:4]   min2        (4 bits, 绝对值第二小 magnitude，非符号+数值)
//  bits[3:0]   min1        (4 bits, 绝对值最小 magnitude，非符号+数值)
//  说明：min1/min2 存储绝对值（mag），sign_xor 处理符号。
//  msg 格式 MSG_W=5：bit[4]=sign，bits[3:0]=mag。

module mdpc_cnu_a (
  input  logic [MSG_W-1:0] v2c_msg_in,
  input  logic [VAR_W-1:0] src_var_idx,
  input  logic [ROW_STATE_W-1:0] c2v_compact_msg_in,
  output logic [ROW_STATE_W-1:0] c2v_compact_msg_out,
  output logic v2c_sign_out
);

  import mdpc_demo_pkg::*;

  logic               v2c_sign;
  logic [D-1:0]       v2c_mag;
  logic [D-1:0]       c2v_min_mag1;
  logic [D-1:0]       c2v_min_mag2;
  logic               c2v_sign_xor;
  logic [1:0]         c2v_valid_count;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_next;
  int next_valid_count;

  assign v2c_sign = v2c_msg_in[MSG_SIGN_BIT];
  assign v2c_mag = v2c_msg_in[MSG_MAG_LSB +: D];

  assign c2v_min_mag1 = c2v_compact_msg_in[ROW_STATE_MIN1_LSB +: D];
  assign c2v_min_mag2 = c2v_compact_msg_in[ROW_STATE_MIN2_LSB +: D];
  assign c2v_sign_xor = c2v_compact_msg_in[ROW_STATE_SIGN_XOR_BIT];
  assign c2v_valid_count = c2v_compact_msg_in[ROW_STATE_VALID_COUNT_LSB +: 2];

  always_comb begin
    c2v_compact_msg_next = c2v_compact_msg_in;
    v2c_sign_out = v2c_sign;
    next_valid_count = int'(c2v_valid_count);

    if (c2v_valid_count == 0) begin
      c2v_compact_msg_next[ROW_STATE_MIN1_LSB +: D] = v2c_mag;
      c2v_compact_msg_next[ROW_STATE_MIN2_LSB +: D] = MAG_MAX[D-1:0];
      c2v_compact_msg_next[ROW_STATE_MIN_ID_LSB +: VAR_W] = src_var_idx;
      c2v_compact_msg_next[ROW_STATE_SIGN_XOR_BIT] = v2c_sign;
      c2v_compact_msg_next[ROW_STATE_VALID_COUNT_LSB +: 2] = 2'd1;
    end else begin
      next_valid_count = int'(c2v_valid_count) + 1;
      if (next_valid_count > W) begin
        next_valid_count = W;
      end

      c2v_compact_msg_next[ROW_STATE_SIGN_XOR_BIT] = c2v_sign_xor ^ v2c_sign;
      c2v_compact_msg_next[ROW_STATE_VALID_COUNT_LSB +: 2] = next_valid_count[1:0];

      if (v2c_mag < c2v_min_mag1) begin
        c2v_compact_msg_next[ROW_STATE_MIN2_LSB +: D] = c2v_min_mag1;
        c2v_compact_msg_next[ROW_STATE_MIN1_LSB +: D] = v2c_mag;
        c2v_compact_msg_next[ROW_STATE_MIN_ID_LSB +: VAR_W] = src_var_idx;
      end else if (v2c_mag < c2v_min_mag2) begin
        c2v_compact_msg_next[ROW_STATE_MIN2_LSB +: D] = v2c_mag;
      end
    end
  end

  assign c2v_compact_msg_out = c2v_compact_msg_next;
endmodule
