`timescale 1ns/1ps

import mdpc_demo_pkg::*;

module tb_mdpc_vnu;
  logic signed [APP_W-1:0] gamma_in;
  logic [MSG_W-1:0] c2v_in [0:W-1];
  logic signed [APP_W-1:0] app_out;
  logic x_out;
  logic [MSG_W-1:0] u_next_out [0:W-1];

  mdpc_vnu dut (
    .gamma_in(gamma_in),
    .c2v_in(c2v_in),
    .app_out(app_out),
    .x_out(x_out),
    .u_next_out(u_next_out)
  );

  initial begin
    gamma_in = 9;
    c2v_in[0] = msg_from_signed(15);
    c2v_in[1] = msg_from_signed(15);
    c2v_in[2] = msg_from_signed(-9);
    #1;
    if (app_out !== 11) $fatal(1, "app_out mismatch: got %0d exp 11", app_out);
    if (x_out !== 0) $fatal(1, "x_out mismatch: got %0d exp 0", x_out);
    if (msg_to_signed(u_next_out[0]) !== 10) $fatal(1, "u_next[0] mismatch: got %0d exp 10", msg_to_signed(u_next_out[0]));
    if (msg_to_signed(u_next_out[1]) !== 10) $fatal(1, "u_next[1] mismatch: got %0d exp 10", msg_to_signed(u_next_out[1]));
    if (msg_to_signed(u_next_out[2]) !== 12) $fatal(1, "u_next[2] mismatch: got %0d exp 12", msg_to_signed(u_next_out[2]));

    gamma_in = 31;
    c2v_in[0] = msg_from_signed(-15);
    c2v_in[1] = msg_from_signed(-15);
    c2v_in[2] = msg_from_signed(-15);
    #1;
    if (app_out !== 27) $fatal(1, "saturation case app_out mismatch: got %0d exp 27", app_out);
    if (x_out !== 0) $fatal(1, "saturation case x_out mismatch: got %0d exp 0", x_out);
    if (msg_to_signed(u_next_out[0]) !== 15) $fatal(1, "u_next[0] saturation mismatch: got %0d exp 15", msg_to_signed(u_next_out[0]));
    if (msg_to_signed(u_next_out[1]) !== 15) $fatal(1, "u_next[1] saturation mismatch: got %0d exp 15", msg_to_signed(u_next_out[1]));
    if (msg_to_signed(u_next_out[2]) !== 15) $fatal(1, "u_next[2] saturation mismatch: got %0d exp 15", msg_to_signed(u_next_out[2]));

    $display("tb_mdpc_vnu PASS");
    $finish;
  end
endmodule
