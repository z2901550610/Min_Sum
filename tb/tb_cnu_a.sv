`timescale 1ns / 1ps

module tb_cnu_a;
  import bike_pkg::*;

  logic                  clk;
  logic                  rst_n;
  logic                  in_valid;
  logic [     MSG_W-1:0] v2c_msg_in;
  logic [ EDGE_ID_W-1:0] edge_id;
  logic [COMP_C2V_W-1:0] comp_c2v_in;
  logic [COMP_C2V_W-1:0] comp_c2v_out;
  logic                  v2c_sign_out;
  logic                  out_valid;

  cnu_a dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_en(in_valid),
      .i_v2c_msg(v2c_msg_in),
      .i_edge_id(edge_id),
      .i_comp_c2v(comp_c2v_in),
      .o_comp_c2v(comp_c2v_out),
      .o_sign(v2c_sign_out),
      .o_valid(out_valid)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic drive_step(input  logic [COMP_C2V_W-1:0] comp_c2v_state_in,
                            input  logic [MSG_W-1:0] msg_in, input  logic [EDGE_ID_W-1:0] edge_id_i);
    begin
      comp_c2v_in = comp_c2v_state_in;
      v2c_msg_in = msg_in;
      edge_id = edge_id_i;
      in_valid = 1'b1;
      @(posedge clk);
      #1;
      if (out_valid !== 1'b1) $fatal(1, "expected out_valid=1");
    end
  endtask

  task automatic expect_state(input int exp_min1, input int exp_min2, input int exp_min_id,
                              input int exp_sign_xor, input int exp_sign_bit);
    begin
      if (int'(comp_c2v_out[COMP_C2V_MIN1_LSB+:D]) != exp_min1)
        $fatal(
            1, "min1 mismatch: got %0d exp %0d", int'(comp_c2v_out[COMP_C2V_MIN1_LSB+:D]), exp_min1
        );
      if (int'(comp_c2v_out[COMP_C2V_MIN2_LSB+:D]) != exp_min2)
        $fatal(
            1, "min2 mismatch: got %0d exp %0d", int'(comp_c2v_out[COMP_C2V_MIN2_LSB+:D]), exp_min2
        );
      if (int'(comp_c2v_out[COMP_C2V_MIN_ID_LSB+:EDGE_ID_W]) != exp_min_id)
        $fatal(
            1,
            "min_id mismatch: got %0d exp %0d",
            int'(comp_c2v_out[COMP_C2V_MIN_ID_LSB+:EDGE_ID_W]),
            exp_min_id
        );
      if (int'(comp_c2v_out[COMP_C2V_SIGN_XOR_BIT]) != exp_sign_xor)
        $fatal(
            1,
            "sign_xor mismatch: got %0d exp %0d",
            int'(comp_c2v_out[COMP_C2V_SIGN_XOR_BIT]),
            exp_sign_xor
        );
      if (int'(v2c_sign_out) != exp_sign_bit)
        $fatal(1, "sign_bit mismatch: got %0d exp %0d", int'(v2c_sign_out), exp_sign_bit);
    end
  endtask

  initial begin
    rst_n = 1'b0;
    in_valid = 1'b0;
    v2c_msg_in = '0;
    edge_id = '0;
    comp_c2v_in = COMP_C2V_INIT;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    drive_step(COMP_C2V_INIT, {1'b0, D'(5)}, EDGE_ID_W'(4));
    expect_state(5, MAG_MAX, 4, 0, 0);

    drive_step(comp_c2v_out, {1'b1, D'(2)}, EDGE_ID_W'(3));
    expect_state(2, 5, 3, 1, 1);

    drive_step(comp_c2v_out, {1'b0, D'(2)}, EDGE_ID_W'(7));
    expect_state(2, 2, 7, 1, 0);

    in_valid = 1'b0;
    @(posedge clk);
    #1;
    if (out_valid !== 1'b0) $fatal(1, "expected out_valid=0 after idle cycle");

    $display("tb_cnu_a PASS");
    $finish;
  end
endmodule
