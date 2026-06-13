`timescale 1ns / 1ps

module tb_cnu_a;
  import bike_pkg::*;

  logic [     MSG_W-1:0] v2c_msg_in;
  logic [ EDGE_ID_W-1:0] edge_id;
  logic [COMP_C2V_W-1:0] comp_c2v_in;
  logic [COMP_C2V_W-1:0] comp_c2v_out;
  logic                  v2c_sign_out;

  cnu_a dut (
      .i_v2c_msg(v2c_msg_in),
      .i_edge_id(edge_id),
      .i_comp_c2v(comp_c2v_in),
      .o_comp_c2v(comp_c2v_out),
      .o_sign(v2c_sign_out)
  );

  initial begin
    #10000;
    $fatal(1, "tb_cnu_a timeout");
  end

  task automatic drive_step(input  logic [COMP_C2V_W-1:0] comp_c2v_state_in,
                            input  logic [MSG_W-1:0] msg_in, input  logic [EDGE_ID_W-1:0] edge_id_i);
    begin
      comp_c2v_in = comp_c2v_state_in;
      v2c_msg_in = msg_in;
      edge_id = edge_id_i;
      #1;
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
    v2c_msg_in = '0;
    edge_id = '0;
    comp_c2v_in = COMP_C2V_INIT;

    drive_step(COMP_C2V_INIT, {1'b0, D'(5)}, EDGE_ID_W'(4));
    expect_state(5, MAG_MAX, 4, 0, 0);

    drive_step(comp_c2v_out, {1'b1, D'(2)}, EDGE_ID_W'(3));
    expect_state(2, 5, 3, 1, 1);

    drive_step(comp_c2v_out, {1'b0, D'(2)}, EDGE_ID_W'(7));
    expect_state(2, 2, 7, 1, 0);

    $display("tb_cnu_a PASS");
    $finish;
  end
endmodule
