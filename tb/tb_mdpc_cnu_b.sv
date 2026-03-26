`timescale 1ns/1ps

module tb_mdpc_cnu_b;
  import mdpc_demo_pkg::*;

  logic [ROW_STATE_W-1:0] row_state_in;
  logic u_sign_in;
  logic [VAR_W-1:0] var_idx;
  logic [MSG_W-1:0] v_out;

  mdpc_cnu_b dut (
    .row_state_in(row_state_in),
    .u_sign_in(u_sign_in),
    .var_idx(var_idx),
    .v_out(v_out)
  );

  initial begin
    row_state_in = {2'd3, 1'b1, 4'd4, D'(5), D'(2)};

    u_sign_in = 1;
    var_idx = 4;
    #1;
    if (int'(v_out[MSG_MAG_LSB +: D]) != 5) $fatal(1, "expected min2 path mag=5, got %0d", int'(v_out[MSG_MAG_LSB +: D]));
    if (int'(v_out[MSG_SIGN_BIT]) != 0) $fatal(1, "expected sign xor result 0, got %0d", int'(v_out[MSG_SIGN_BIT]));

    u_sign_in = 0;
    var_idx = 6;
    #1;
    if (int'(v_out[MSG_MAG_LSB +: D]) != 2) $fatal(1, "expected min1 path mag=2, got %0d", int'(v_out[MSG_MAG_LSB +: D]));
    if (int'(v_out[MSG_SIGN_BIT]) != 1) $fatal(1, "expected sign xor result 1, got %0d", int'(v_out[MSG_SIGN_BIT]));

    $display("tb_mdpc_cnu_b PASS");
    $finish;
  end
endmodule
