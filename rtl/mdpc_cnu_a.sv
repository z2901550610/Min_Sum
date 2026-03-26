//  row_state说明：
//  ROW_STATE_W = 15 (D=4, VAR_W=4)
//  bit [14:13] valid_count  (2 bits, 0=empty, 1..W=已处理边数，上限W=3)
//  bit [12]    sign_xor    (1 bit, 累积符号异或，CNU_B 输出符号用该值 ^ u_sign_in)
//  bits[11:8]  min_id      (4 bits, 记录 min1 对应的 var_idx)
//  bits[7:4]   min2        (4 bits, 绝对值第二小 magnitude，非符号+数值)
//  bits[3:0]   min1        (4 bits, 绝对值最小 magnitude，非符号+数值)
//  说明：min1/min2 存储绝对值（mag），sign_xor 处理符号。
//  msg 格式 MSG_W=5：bit[4]=sign，bits[3:0]=mag。

module mdpc_cnu_a (
  input  logic [MSG_W-1:0] u_in,
  input  logic [VAR_W-1:0] var_idx,
  input  logic [ROW_STATE_W-1:0] row_state_in,
  output logic [ROW_STATE_W-1:0] row_state_out,
  output logic sign_bit_out
);

  import mdpc_demo_pkg::*;

  logic               u_sign;
  logic [D-1:0]       u_mag;
  logic [D-1:0]       state_min1;
  logic [D-1:0]       state_min2;
  logic               state_sign_xor;
  logic [1:0]         state_valid_count;
  logic [ROW_STATE_W-1:0] next_state;
  int next_count;

  assign u_sign = u_in[MSG_SIGN_BIT];
  assign u_mag = u_in[MSG_MAG_LSB +: D];

  assign state_min1 = row_state_in[ROW_STATE_MIN1_LSB +: D];
  assign state_min2 = row_state_in[ROW_STATE_MIN2_LSB +: D];
  assign state_sign_xor = row_state_in[ROW_STATE_SIGN_XOR_BIT];
  assign state_valid_count = row_state_in[ROW_STATE_VALID_COUNT_LSB +: 2];

  always_comb begin
    next_state = row_state_in;
    sign_bit_out = u_sign;
    next_count = int'(state_valid_count);

    if (state_valid_count == 0) begin
      next_state[ROW_STATE_MIN1_LSB +: D] = u_mag;
      next_state[ROW_STATE_MIN2_LSB +: D] = MAG_MAX[D-1:0];
      next_state[ROW_STATE_MIN_ID_LSB +: VAR_W] = var_idx;
      next_state[ROW_STATE_SIGN_XOR_BIT] = u_sign;
      next_state[ROW_STATE_VALID_COUNT_LSB +: 2] = 2'd1;
    end else begin
      next_count = int'(state_valid_count) + 1;
      if (next_count > W) begin
        next_count = W;
      end

      next_state[ROW_STATE_SIGN_XOR_BIT] = state_sign_xor ^ u_sign;
      next_state[ROW_STATE_VALID_COUNT_LSB +: 2] = next_count[1:0];

      if (u_mag < state_min1) begin
        next_state[ROW_STATE_MIN2_LSB +: D] = state_min1;
        next_state[ROW_STATE_MIN1_LSB +: D] = u_mag;
        next_state[ROW_STATE_MIN_ID_LSB +: VAR_W] = var_idx;
      end else if (u_mag < state_min2) begin
        next_state[ROW_STATE_MIN2_LSB +: D] = u_mag;
      end
    end
  end

  assign row_state_out = next_state;
endmodule
