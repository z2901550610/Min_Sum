`timescale 1ns/1ps

module tb_mdpc_cnu_b;
  import mdpc_demo_pkg::*;

  logic [ROW_STATE_W-1:0] c2v_compact_msg_in;
  logic v2c_sign_in;
  logic [VAR_W-1:0] src_var_idx;
  logic [MSG_W-1:0] c2v_msg_out;

  mdpc_cnu_b dut (
    .c2v_compact_msg_in(c2v_compact_msg_in),
    .v2c_sign_in(v2c_sign_in),
    .src_var_idx(src_var_idx),
    .c2v_msg_out(c2v_msg_out)
  );

  initial begin
    c2v_compact_msg_in = {1'b1, 4'd4, D'(5), D'(2)};

    v2c_sign_in = 1;
    src_var_idx = 4;
    #1;
    if (int'(c2v_msg_out[MSG_MAG_LSB +: D]) != 5) $fatal(1, "expected min2 path mag=5, got %0d", int'(c2v_msg_out[MSG_MAG_LSB +: D]));
    if (int'(c2v_msg_out[MSG_SIGN_BIT]) != 0) $fatal(1, "expected sign xor result 0, got %0d", int'(c2v_msg_out[MSG_SIGN_BIT]));

    v2c_sign_in = 0;
    src_var_idx = 6;
    #1;
    if (int'(c2v_msg_out[MSG_MAG_LSB +: D]) != 2) $fatal(1, "expected min1 path mag=2, got %0d", int'(c2v_msg_out[MSG_MAG_LSB +: D]));
    if (int'(c2v_msg_out[MSG_SIGN_BIT]) != 1) $fatal(1, "expected sign xor result 1, got %0d", int'(c2v_msg_out[MSG_SIGN_BIT]));

    $display("tb_mdpc_cnu_b PASS");
    $finish;
  end
endmodule
