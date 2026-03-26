`timescale 1ns/1ps

module tb_mdpc_cnu_a;
  import mdpc_demo_pkg::*;

  logic [MSG_W-1:0] v2c_msg_in;
  logic [VAR_W-1:0] src_var_idx;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_in;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_out;
  logic v2c_sign_out;

  mdpc_cnu_a dut (
    .v2c_msg_in(v2c_msg_in),
    .src_var_idx(src_var_idx),
    .c2v_compact_msg_in(c2v_compact_msg_in),
    .c2v_compact_msg_out(c2v_compact_msg_out),
    .v2c_sign_out(v2c_sign_out)
  );

  task automatic expect_state(
    input int exp_min1,
    input int exp_min2,
    input int exp_min_id,
    input int exp_sign_xor,
    input int exp_valid_count,
    input int exp_sign_bit
  );
    if (int'(c2v_compact_msg_out[ROW_STATE_MIN1_LSB +: D]) != exp_min1) $fatal(1, "min1 mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_MIN1_LSB +: D]), exp_min1);
    if (int'(c2v_compact_msg_out[ROW_STATE_MIN2_LSB +: D]) != exp_min2) $fatal(1, "min2 mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_MIN2_LSB +: D]), exp_min2);
    if (int'(c2v_compact_msg_out[ROW_STATE_MIN_ID_LSB +: VAR_W]) != exp_min_id) $fatal(1, "min_id mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_MIN_ID_LSB +: VAR_W]), exp_min_id);
    if (int'(c2v_compact_msg_out[ROW_STATE_SIGN_XOR_BIT]) != exp_sign_xor) $fatal(1, "sign_xor mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_SIGN_XOR_BIT]), exp_sign_xor);
    if (int'(c2v_compact_msg_out[ROW_STATE_VALID_COUNT_LSB +: 2]) != exp_valid_count) $fatal(1, "valid_count mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_VALID_COUNT_LSB +: 2]), exp_valid_count);
    if (int'(v2c_sign_out) != exp_sign_bit) $fatal(1, "sign_bit mismatch: got %0d exp %0d", int'(v2c_sign_out), exp_sign_bit);
  endtask

  initial begin
    c2v_compact_msg_in = {2'd0, 1'b0, {VAR_W{1'b0}}, D'(MAG_MAX), D'(MAG_MAX)};
    v2c_msg_in = {1'b0, D'(5)};
    src_var_idx = 4;
    #1;
    expect_state(5, 15, 4, 0, 1, 0);

    c2v_compact_msg_in = c2v_compact_msg_out;
    v2c_msg_in = {1'b1, D'(2)};
    src_var_idx = 3;
    #1;
    expect_state(2, 5, 3, 1, 2, 1);

    c2v_compact_msg_in = c2v_compact_msg_out;
    v2c_msg_in = {1'b0, D'(2)};
    src_var_idx = 7;
    #1;
    expect_state(2, 2, 3, 1, 3, 0);

    $display("tb_mdpc_cnu_a PASS");
    $finish;
  end
endmodule
