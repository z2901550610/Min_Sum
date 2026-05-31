`timescale 1ns / 1ps

module tb_cnu_b;
  import bike_pkg::*;

  logic [COMP_C2V_W-1:0] comp_c2v_in;
  logic                  v2c_sign_in;
  logic                  syndrome_bit;
  logic [ EDGE_ID_W-1:0] edge_id;
  logic [     MSG_W-1:0] c2v_msg_out;

  cnu_b dut (
      .i_comp_c2v(comp_c2v_in),
      .i_v2c_sign(v2c_sign_in),
      .i_syndrome_bit(syndrome_bit),
      .i_edge_id(edge_id),
      .o_c2v_msg(c2v_msg_out)
  );

  initial begin
    comp_c2v_in  = {1'b1, EDGE_ID_W'(4), D'(5), D'(2)};

    v2c_sign_in  = 1;
    syndrome_bit = 0;
    edge_id      = 4;
    #1;
    if (int'(c2v_msg_out[MSG_MAG_LSB+:D]) != 5)
      $fatal(1, "expected min2 path mag=5, got %0d", int'(c2v_msg_out[MSG_MAG_LSB+:D]));
    if (int'(c2v_msg_out[MSG_SIGN_BIT]) != 0)
      $fatal(1, "expected sign xor result 0, got %0d", int'(c2v_msg_out[MSG_SIGN_BIT]));

    v2c_sign_in  = 0;
    syndrome_bit = 0;
    edge_id      = 6;
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
