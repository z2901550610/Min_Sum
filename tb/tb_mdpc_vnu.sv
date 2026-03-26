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
    c2v_in[0] = {1'b0, D'(15)};
    c2v_in[1] = {1'b0, D'(15)};
    c2v_in[2] = {1'b1, D'(9)};
    #1;
    if (app_out !== 11) $fatal(1, "app_out mismatch: got %0d exp 11", app_out);
    if (x_out !== 0) $fatal(1, "x_out mismatch: got %0d exp 0", x_out);
    if (u_next_out[0] !== {1'b0, D'(10)}) $fatal(1, "u_next[0] mismatch: got %b exp %b", u_next_out[0], {1'b0, D'(10)});
    if (u_next_out[1] !== {1'b0, D'(10)}) $fatal(1, "u_next[1] mismatch: got %b exp %b", u_next_out[1], {1'b0, D'(10)});
    if (u_next_out[2] !== {1'b0, D'(12)}) $fatal(1, "u_next[2] mismatch: got %b exp %b", u_next_out[2], {1'b0, D'(12)});

    gamma_in = 31;
    c2v_in[0] = {1'b1, D'(15)};
    c2v_in[1] = {1'b1, D'(15)};
    c2v_in[2] = {1'b1, D'(15)};
    #1;
    if (app_out !== 27) $fatal(1, "saturation case app_out mismatch: got %0d exp 27", app_out);
    if (x_out !== 0) $fatal(1, "saturation case x_out mismatch: got %0d exp 0", x_out);
    if (u_next_out[0] !== {1'b0, D'(15)}) $fatal(1, "u_next[0] saturation mismatch: got %b exp %b", u_next_out[0], {1'b0, D'(15)});
    if (u_next_out[1] !== {1'b0, D'(15)}) $fatal(1, "u_next[1] saturation mismatch: got %b exp %b", u_next_out[1], {1'b0, D'(15)});
    if (u_next_out[2] !== {1'b0, D'(15)}) $fatal(1, "u_next[2] saturation mismatch: got %b exp %b", u_next_out[2], {1'b0, D'(15)});

    $display("tb_mdpc_vnu PASS");
    $finish;
  end
endmodule
