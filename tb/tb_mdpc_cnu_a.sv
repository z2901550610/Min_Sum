`timescale 1ns/1ps

module tb_mdpc_cnu_a;
  import mdpc_demo_pkg::*;

  logic clk;
  logic rst_n;
  logic clear_en;
  logic in_valid;
  logic [MSG_W-1:0] v2c_msg_in;
  logic [VAR_W-1:0] src_var_idx;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_in;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_out;
  logic v2c_sign_out;
  logic out_valid;

  mdpc_cnu_a dut (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(clear_en),
    .in_valid(in_valid),
    .v2c_msg_in(v2c_msg_in),
    .src_var_idx(src_var_idx),
    .c2v_compact_msg_in(c2v_compact_msg_in),
    .c2v_compact_msg_out(c2v_compact_msg_out),
    .v2c_sign_out(v2c_sign_out),
    .out_valid(out_valid)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic drive_step(
    input logic [ROW_STATE_W-1:0] row_state_in,
    input logic [MSG_W-1:0] msg_in,
    input logic [VAR_W-1:0] var_idx
  );
    begin
      c2v_compact_msg_in = row_state_in;
      v2c_msg_in = msg_in;
      src_var_idx = var_idx;
      in_valid = 1'b1;
      @(posedge clk);
      #1;
      if (out_valid !== 1'b1) $fatal(1, "expected out_valid=1");
    end
  endtask

  task automatic expect_state(
    input int exp_min1,
    input int exp_min2,
    input int exp_min_id,
    input int exp_sign_xor,
    input int exp_sign_bit
  );
    begin
      if (int'(c2v_compact_msg_out[ROW_STATE_MIN1_LSB +: D]) != exp_min1) $fatal(1, "min1 mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_MIN1_LSB +: D]), exp_min1);
      if (int'(c2v_compact_msg_out[ROW_STATE_MIN2_LSB +: D]) != exp_min2) $fatal(1, "min2 mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_MIN2_LSB +: D]), exp_min2);
      if (int'(c2v_compact_msg_out[ROW_STATE_MIN_ID_LSB +: VAR_W]) != exp_min_id) $fatal(1, "min_id mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_MIN_ID_LSB +: VAR_W]), exp_min_id);
      if (int'(c2v_compact_msg_out[ROW_STATE_SIGN_XOR_BIT]) != exp_sign_xor) $fatal(1, "sign_xor mismatch: got %0d exp %0d", int'(c2v_compact_msg_out[ROW_STATE_SIGN_XOR_BIT]), exp_sign_xor);
      if (int'(v2c_sign_out) != exp_sign_bit) $fatal(1, "sign_bit mismatch: got %0d exp %0d", int'(v2c_sign_out), exp_sign_bit);
    end
  endtask

  initial begin
    rst_n = 1'b0;
    clear_en = 1'b0;
    in_valid = 1'b0;
    v2c_msg_in = '0;
    src_var_idx = '0;
    c2v_compact_msg_in = ROW_STATE_INIT;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    drive_step(ROW_STATE_INIT, {1'b0, D'(5)}, VAR_W'(4));
    expect_state(5, MAG_MAX, 4, 0, 0);

    drive_step(c2v_compact_msg_out, {1'b1, D'(2)}, VAR_W'(3));
    expect_state(2, 5, 3, 1, 1);

    drive_step(c2v_compact_msg_out, {1'b0, D'(2)}, VAR_W'(7));
    expect_state(2, 2, 7, 1, 0);

    in_valid = 1'b0;
    @(posedge clk);
    #1;
    if (out_valid !== 1'b0) $fatal(1, "expected out_valid=0 after idle cycle");

    $display("tb_mdpc_cnu_a PASS");
    $finish;
  end
endmodule
