`timescale 1ns/1ps

module tb_msg_codec;
  import bike_pkg::*;

  logic signmag_valid;
  logic signmag_sign;
  logic [D-1:0] signmag_mag;
  logic signmag_tc_valid;
  logic signed [MSG_W-1:0] signmag_tc;

  logic tc_valid;
  logic signed [VNU_TC_W-1:0] tc_in;
  logic tc_msg_valid;
  logic [MSG_W-1:0] tc_msg;

  msg_signmag_to_tc u_signmag_to_tc (
    .i_valid(signmag_valid),
    .i_sign(signmag_sign),
    .i_mag(signmag_mag),
    .o_valid(signmag_tc_valid),
    .o_tc(signmag_tc)
  );

  msg_tc_to_signmag_sat #(
    .TC_W(VNU_TC_W)
  ) u_tc_to_signmag (
    .i_valid(tc_valid),
    .i_tc(tc_in),
    .o_valid(tc_msg_valid),
    .o_msg(tc_msg)
  );

  initial begin
    signmag_valid = 1'b1;
    signmag_sign = 1'b0;
    signmag_mag = D'(7);
    #1;
    if (signmag_tc_valid !== 1'b1 || $signed(signmag_tc) != 7) $fatal(1, "positive signmag->tc mismatch");

    signmag_sign = 1'b1;
    signmag_mag = D'(7);
    #1;
    if ($signed(signmag_tc) != -7) $fatal(1, "negative signmag->tc mismatch");

    signmag_valid = 1'b0;
    #1;
    if (signmag_tc !== '0) $fatal(1, "invalid signmag->tc should zero output");

    tc_valid = 1'b1;
    tc_in = VNU_TC_W'(10);
    #1;
    if (tc_msg_valid !== 1'b1 || tc_msg != {1'b0, D'(10)}) $fatal(1, "tc->signmag positive mismatch");

    tc_in = -VNU_TC_W'(10);
    #1;
    if (tc_msg != {1'b1, D'(10)}) $fatal(1, "tc->signmag negative mismatch");

    tc_in = VNU_TC_W'(28);
    #1;
    if (tc_msg != {1'b0, D'(MAG_MAX)}) $fatal(1, "tc->signmag saturation mismatch");

    tc_valid = 1'b0;
    #1;
    if (tc_msg !== '0) $fatal(1, "invalid tc->signmag should zero output");

    $display("tb_msg_codec PASS");
    $finish;
  end
endmodule
