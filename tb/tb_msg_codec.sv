`timescale 1ns/1ps

module tb_msg_codec;
  import bike_pkg::*;

  // Testbench scope:
  // 1) sign-magnitude -> two's-complement 的基本转换
  // 2) two's-complement -> sign-magnitude 的符号/绝对值/饱和行为
  // 3) 关键边界值：0、-0、±MAG_MAX、刚好越界时的饱和

  logic [MSG_W-1:0] signmag_msg;
  logic signed [MSG_W-1:0] signmag_tc;

  logic signed [VNU_TC_W-1:0] tc_in;
  logic [MSG_W-1:0] tc_msg;

  msg_signmag_to_tc #(
    .D(D),
    .MSG_W(MSG_W),
    .MSG_MAG_LSB(MSG_MAG_LSB),
    .MSG_SIGN_BIT(MSG_SIGN_BIT)
  ) u_signmag_to_tc (
    .i_msg(signmag_msg),
    .o_tc(signmag_tc)
  );

  msg_tc_to_signmag_sat #(
    .D(D),
    .MSG_W(MSG_W),
    .VNU_TC_W(VNU_TC_W),
    .MAG_MAX(MAG_MAX)
  ) u_tc_to_signmag (
    .i_tc(tc_in),
    .o_msg(tc_msg)
  );

  // 参考模型：把 sign-magnitude 解释为有符号整数。
  function automatic int signmag_to_int(
    input logic sign_i,
    input logic [D-1:0] mag_i
  );
    begin
      if (sign_i && (mag_i != '0)) begin
        signmag_to_int = -int'(mag_i);
      end else begin
        signmag_to_int = int'(mag_i);
      end
    end
  endfunction

  // 参考模型：把有符号整数编码成带饱和的 sign-magnitude。
  function automatic logic [MSG_W-1:0] int_to_signmag_sat(input int value_i);
    int abs_value;
    logic sign_bit;
    logic [D-1:0] mag_bits;
    begin
      sign_bit = (value_i < 0);
      abs_value = (value_i < 0) ? -value_i : value_i;
      if (abs_value > MAG_MAX) begin
        mag_bits = D'(MAG_MAX);
      end else begin
        mag_bits = D'(abs_value);
      end
      int_to_signmag_sat = {(sign_bit && (mag_bits != '0)), mag_bits};
    end
  endfunction

  // 检查 sign-magnitude -> tc：-0 必须规范化为 0。
  task automatic check_signmag_to_tc(
    input logic sign_i,
    input logic [D-1:0] mag_i
  );
    int expected_value;
    begin
      signmag_msg = {sign_i, mag_i};
      #1;

      expected_value = signmag_to_int(sign_i, mag_i);
      if (int'($signed(signmag_tc)) != expected_value) begin
        $fatal(1, "signmag->tc value mismatch: sign=%0b mag=%0d got=%0d exp=%0d",
               sign_i, mag_i, int'($signed(signmag_tc)), expected_value);
      end
    end
  endtask

  // 检查 tc -> sign-magnitude：超出 MAG_MAX 时饱和。
  task automatic check_tc_to_signmag(
    input logic signed [VNU_TC_W-1:0] value_i
  );
    logic [MSG_W-1:0] expected_msg;
    begin
      tc_in = value_i;
      #1;

      expected_msg = int_to_signmag_sat(int'($signed(value_i)));
      if (tc_msg != expected_msg) begin
        $fatal(1, "tc->signmag value mismatch: in=%0d got=%b exp=%b",
               $signed(value_i), tc_msg, expected_msg);
      end
    end
  endtask

  // 基本和边界值检查：
  // 0、-0、±MAG_MAX。
  task automatic run_signmag_to_tc_smoke_checks;
    begin
      check_signmag_to_tc(1'b0, '0);
      check_signmag_to_tc(1'b1, '0);
      check_signmag_to_tc(1'b0, D'(7));
      check_signmag_to_tc(1'b1, D'(7));
      check_signmag_to_tc(1'b0, D'(MAG_MAX));
      check_signmag_to_tc(1'b1, D'(MAG_MAX));
    end
  endtask

  // 穷举全部 sign-magnitude 输入，验证编码规则完整正确。
  task automatic run_signmag_to_tc_exhaustive_checks;
    int sign_i;
    int mag_i;
    begin
      for (sign_i = 0; sign_i <= 1; sign_i++) begin
        for (mag_i = 0; mag_i <= MAG_MAX; mag_i++) begin
          check_signmag_to_tc(logic'(sign_i), D'(mag_i));
        end
      end
    end
  endtask

  // tc -> sign-magnitude 的典型与边界值：
  // 0、±MAG_MAX、刚好越界时的饱和、较大正负数。
  task automatic run_tc_to_signmag_smoke_checks;
    begin
      check_tc_to_signmag('0);
      check_tc_to_signmag(VNU_TC_W'(10));
      check_tc_to_signmag(-VNU_TC_W'(10));
      check_tc_to_signmag(VNU_TC_W'(MAG_MAX));
      check_tc_to_signmag(-VNU_TC_W'(MAG_MAX));
      check_tc_to_signmag(VNU_TC_W'(MAG_MAX + 1));
      check_tc_to_signmag(-VNU_TC_W'(MAG_MAX + 1));
      check_tc_to_signmag(VNU_TC_W'(28));
      check_tc_to_signmag(-VNU_TC_W'(28));
      check_tc_to_signmag($signed({1'b1, {(VNU_TC_W-1){1'b0}}}));
    end
  endtask

  // 穷举一小段 tc 输入，覆盖不饱和区和两侧饱和区。
  task automatic run_tc_to_signmag_range_checks;
    int value_i;
    begin
      for (value_i = -20; value_i <= 20; value_i++) begin
        check_tc_to_signmag(VNU_TC_W'(value_i));
      end
    end
  endtask

  initial begin
    signmag_msg = '0;
    tc_in = '0;

    // 先测 sign-magnitude -> tc，再测 tc -> sign-magnitude。
    run_signmag_to_tc_smoke_checks();
    run_signmag_to_tc_exhaustive_checks();
    run_tc_to_signmag_smoke_checks();
    run_tc_to_signmag_range_checks();

    $display("tb_msg_codec PASS");
    $finish;
  end
endmodule
