`timescale 1ns/1ps

module tb_mdpc_cnu_a;
  import mdpc_demo_pkg::*;

  logic [MSG_W-1:0] u_in;
  logic [VAR_W-1:0] var_idx;
  logic [ROW_STATE_W-1:0] row_state_in;
  logic [ROW_STATE_W-1:0] row_state_out;
  logic sign_bit_out;

  mdpc_cnu_a dut (
    .u_in(u_in),
    .var_idx(var_idx),
    .row_state_in(row_state_in),
    .row_state_out(row_state_out),
    .sign_bit_out(sign_bit_out)
  );

  task automatic expect_state(
    input int exp_min1,
    input int exp_min2,
    input int exp_min_id,
    input int exp_sign_xor,
    input int exp_valid_count,
    input int exp_sign_bit
  );
    if (int'(row_state_out[ROW_STATE_MIN1_LSB +: D]) != exp_min1) $fatal(1, "min1 mismatch: got %0d exp %0d", int'(row_state_out[ROW_STATE_MIN1_LSB +: D]), exp_min1);
    if (int'(row_state_out[ROW_STATE_MIN2_LSB +: D]) != exp_min2) $fatal(1, "min2 mismatch: got %0d exp %0d", int'(row_state_out[ROW_STATE_MIN2_LSB +: D]), exp_min2);
    if (int'(row_state_out[ROW_STATE_MIN_ID_LSB +: VAR_W]) != exp_min_id) $fatal(1, "min_id mismatch: got %0d exp %0d", int'(row_state_out[ROW_STATE_MIN_ID_LSB +: VAR_W]), exp_min_id);
    if (int'(row_state_out[ROW_STATE_SIGN_XOR_BIT]) != exp_sign_xor) $fatal(1, "sign_xor mismatch: got %0d exp %0d", int'(row_state_out[ROW_STATE_SIGN_XOR_BIT]), exp_sign_xor);
    if (int'(row_state_out[ROW_STATE_VALID_COUNT_LSB +: 2]) != exp_valid_count) $fatal(1, "valid_count mismatch: got %0d exp %0d", int'(row_state_out[ROW_STATE_VALID_COUNT_LSB +: 2]), exp_valid_count);
    if (int'(sign_bit_out) != exp_sign_bit) $fatal(1, "sign_bit mismatch: got %0d exp %0d", int'(sign_bit_out), exp_sign_bit);
  endtask

  initial begin
    row_state_in = {2'd0, 1'b0, {VAR_W{1'b0}}, D'(MAG_MAX), D'(MAG_MAX)};
    u_in = {1'b0, D'(5)};
    var_idx = 4;
    #1;
    expect_state(5, 15, 4, 0, 1, 0);

    row_state_in = row_state_out;
    u_in = {1'b1, D'(2)};
    var_idx = 3;
    #1;
    expect_state(2, 5, 3, 1, 2, 1);

    row_state_in = row_state_out;
    u_in = {1'b0, D'(2)};
    var_idx = 7;
    #1;
    expect_state(2, 2, 3, 1, 3, 0);

    $display("tb_mdpc_cnu_a PASS");
    $finish;
  end
endmodule
