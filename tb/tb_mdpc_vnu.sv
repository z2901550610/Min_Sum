`timescale 1ns/1ps

module tb_mdpc_vnu;
  import mdpc_demo_pkg::*;

  logic clk;
  logic rst_n;
  logic clear_en;
  logic start_var;
  logic last_accum;
  logic signed [APP_W-1:0] prior_msg_in;
  logic accum_valid0;
  logic [MSG_W-1:0] accum_c2v0;
  logic accum_valid1;
  logic [MSG_W-1:0] accum_c2v1;
  logic [MSG_W-1:0] cached_c2v_in [0:W-1];
  logic result_valid;
  logic signed [APP_W-1:0] app_out;
  logic x_out;
  logic [MSG_W-1:0] u_next_out [0:W-1];

  mdpc_vnu dut (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(clear_en),
    .start_var(start_var),
    .last_accum(last_accum),
    .prior_msg_in(prior_msg_in),
    .accum_valid0(accum_valid0),
    .accum_c2v0(accum_c2v0),
    .accum_valid1(accum_valid1),
    .accum_c2v1(accum_c2v1),
    .cached_c2v_in(cached_c2v_in),
    .result_valid(result_valid),
    .app_out(app_out),
    .x_out(x_out),
    .u_next_out(u_next_out)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic load_case0;
    begin
      prior_msg_in = 9;
      cached_c2v_in[0] = {1'b0, D'(15)};
      cached_c2v_in[1] = {1'b0, D'(15)};
      cached_c2v_in[2] = {1'b1, D'(9)};
    end
  endtask

  task automatic load_case1;
    begin
      prior_msg_in = 31;
      cached_c2v_in[0] = {1'b1, D'(15)};
      cached_c2v_in[1] = {1'b1, D'(15)};
      cached_c2v_in[2] = {1'b1, D'(15)};
    end
  endtask

  task automatic run_two_cycle_accum;
    begin
      start_var = 1'b1;
      last_accum = 1'b0;
      accum_valid0 = 1'b1;
      accum_valid1 = 1'b1;
      accum_c2v0 = cached_c2v_in[0];
      accum_c2v1 = cached_c2v_in[1];
      @(posedge clk);
      #1;
      if (result_valid !== 1'b0) $fatal(1, "result_valid should stay low before last accumulation cycle");

      start_var = 1'b0;
      last_accum = 1'b1;
      accum_valid0 = 1'b1;
      accum_valid1 = 1'b0;
      accum_c2v0 = cached_c2v_in[2];
      accum_c2v1 = '0;
      @(posedge clk);
      #1;
      if (result_valid !== 1'b1) $fatal(1, "result_valid should assert on final accumulation cycle");

      start_var = 1'b0;
      last_accum = 1'b0;
      accum_valid0 = 1'b0;
      accum_valid1 = 1'b0;
      accum_c2v0 = '0;
      accum_c2v1 = '0;
    end
  endtask

  initial begin
    rst_n = 1'b0;
    clear_en = 1'b0;
    start_var = 1'b0;
    last_accum = 1'b0;
    prior_msg_in = '0;
    accum_valid0 = 1'b0;
    accum_valid1 = 1'b0;
    accum_c2v0 = '0;
    accum_c2v1 = '0;
    cached_c2v_in[0] = '0;
    cached_c2v_in[1] = '0;
    cached_c2v_in[2] = '0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    load_case0();
    run_two_cycle_accum();
    if (app_out !== 11) $fatal(1, "app_out mismatch: got %0d exp 11", app_out);
    if (x_out !== 0) $fatal(1, "x_out mismatch: got %0d exp 0", x_out);
    if (u_next_out[0] !== {1'b0, D'(10)}) $fatal(1, "u_next[0] mismatch: got %b exp %b", u_next_out[0], {1'b0, D'(10)});
    if (u_next_out[1] !== {1'b0, D'(10)}) $fatal(1, "u_next[1] mismatch: got %b exp %b", u_next_out[1], {1'b0, D'(10)});
    if (u_next_out[2] !== {1'b0, D'(12)}) $fatal(1, "u_next[2] mismatch: got %b exp %b", u_next_out[2], {1'b0, D'(12)});

    clear_en = 1'b1;
    @(posedge clk);
    clear_en = 1'b0;
    #1;

    load_case1();
    run_two_cycle_accum();
    if (app_out !== 27) $fatal(1, "saturation case app_out mismatch: got %0d exp 27", app_out);
    if (x_out !== 0) $fatal(1, "saturation case x_out mismatch: got %0d exp 0", x_out);
    if (u_next_out[0] !== {1'b0, D'(15)}) $fatal(1, "u_next[0] saturation mismatch: got %b exp %b", u_next_out[0], {1'b0, D'(15)});
    if (u_next_out[1] !== {1'b0, D'(15)}) $fatal(1, "u_next[1] saturation mismatch: got %b exp %b", u_next_out[1], {1'b0, D'(15)});
    if (u_next_out[2] !== {1'b0, D'(15)}) $fatal(1, "u_next[2] saturation mismatch: got %b exp %b", u_next_out[2], {1'b0, D'(15)});

    $display("tb_mdpc_vnu PASS");
    $finish;
  end
endmodule
