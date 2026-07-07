`timescale 1ns / 1ps

module tb_cnu_b;
  import bike_pkg::*;

  logic [   COMP_C2V_W-1:0] c2v_comp_in;
  logic                     v2c_sign_in;
  logic                     syndrome_bit;
  logic [DIAG_GLOBAL_W-1:0] diag_idx_global;
  logic [        MSG_W-1:0] c2v_msg_out;

  cnu_b dut (
      .i_c2v_comp(c2v_comp_in),
      .i_v2c_sign(v2c_sign_in),
      .i_syndrome_bit(syndrome_bit),
      .i_diag_idx_global(diag_idx_global),
      .o_c2v_msg(c2v_msg_out)
  );

  initial begin
    #10000;
    $fatal(1, "tb_cnu_b timeout");
  end

  initial begin
    c2v_comp_in     = {1'b1, DIAG_GLOBAL_W'(4), D'(5), D'(2)};

    v2c_sign_in     = 1;
    syndrome_bit    = 0;
    diag_idx_global = 4;
    #1;
    if (int'(c2v_msg_out[MSG_MAG_LSB+:D]) != 5)
      $fatal(1, "expected min2 path mag=5, got %0d", int'(c2v_msg_out[MSG_MAG_LSB+:D]));
    if (int'(c2v_msg_out[MSG_SIGN_BIT]) != 0)
      $fatal(1, "expected sign xor result 0, got %0d", int'(c2v_msg_out[MSG_SIGN_BIT]));

    v2c_sign_in     = 0;
    syndrome_bit    = 0;
    diag_idx_global = 6;
    #1;
    if (int'(c2v_msg_out[MSG_MAG_LSB+:D]) != 2)
      $fatal(1, "expected min1 path mag=2, got %0d", int'(c2v_msg_out[MSG_MAG_LSB+:D]));
    if (int'(c2v_msg_out[MSG_SIGN_BIT]) != 1)
      $fatal(1, "expected sign xor result 1, got %0d", int'(c2v_msg_out[MSG_SIGN_BIT]));

    syndrome_bit = 1;
    #1;
    if (int'(c2v_msg_out[MSG_MAG_LSB+:D]) != 2) $fatal(1, "syndrome must not change magnitude");
    if (int'(c2v_msg_out[MSG_SIGN_BIT]) != 0)
      $fatal(1, "expected syndrome-flipped sign 0, got %0d", int'(c2v_msg_out[MSG_SIGN_BIT]));

    $display("tb_cnu_b PASS");
    $finish;
  end
endmodule
