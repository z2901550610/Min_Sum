`timescale 1ns/1ps

module tb_vnu;
  import mdpc_demo_pkg::*;

  localparam int VNU_TC_W = APP_W + ((W > 1) ? $clog2(W + 1) : 1);

  logic clk;
  logic rst_n;
  logic clear_en;
  logic col_start;
  logic col_end;
  logic signed [APP_W-1:0] initial_llr;
  logic c2v_valid0;
  logic c2v_sign0;
  logic [D-1:0] c2v_mag0;
  logic c2v_valid1;
  logic c2v_sign1;
  logic [D-1:0] c2v_mag1;
  logic app_valid;
  logic signed [APP_W-1:0] app;
  logic bit_decision;
  logic emit_en;
  logic c2v_t_valid0;
  logic signed [MSG_W-1:0] c2v_t0;
  logic c2v_t_valid1;
  logic signed [MSG_W-1:0] c2v_t1;
  logic v2c_valid0;
  logic [MSG_W-1:0] v2c0;
  logic v2c_valid1;
  logic [MSG_W-1:0] v2c1;

  function automatic logic signed [MSG_W-1:0] msg_tc(
    input logic msg_sign,
    input logic [D-1:0] msg_mag
  );
    logic signed [MSG_W-1:0] mag_tc;
    begin
      mag_tc = $signed({1'b0, msg_mag});
      if (msg_sign && (msg_mag != '0)) begin
        msg_tc = -mag_tc;
      end else begin
        msg_tc = mag_tc;
      end
    end
  endfunction

  vnu dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(clear_en),
    .i_col_start(col_start),
    .i_col_end(col_end),
    .i_initial_llr(initial_llr),
    .i_c2v_valid0(c2v_valid0),
    .i_c2v_sign0(c2v_sign0),
    .i_c2v_mag0(c2v_mag0),
    .i_c2v_valid1(c2v_valid1),
    .i_c2v_sign1(c2v_sign1),
    .i_c2v_mag1(c2v_mag1),
    .o_app_valid(app_valid),
    .o_app(app),
    .o_bit_decision(bit_decision),
    .i_emit_en(emit_en),
    .i_c2v_t_valid0(c2v_t_valid0),
    .i_c2v_t0(c2v_t0),
    .i_c2v_t_valid1(c2v_t_valid1),
    .i_c2v_t1(c2v_t1),
    .o_v2c_valid0(v2c_valid0),
    .o_v2c0(v2c0),
    .o_v2c_valid1(v2c_valid1),
    .o_v2c1(v2c1)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic idle_inputs;
    begin
      col_start = 1'b0;
      col_end = 1'b0;
      c2v_valid0 = 1'b0;
      c2v_valid1 = 1'b0;
      c2v_sign0 = 1'b0;
      c2v_sign1 = 1'b0;
      c2v_mag0 = '0;
      c2v_mag1 = '0;
      emit_en = 1'b0;
      c2v_t_valid0 = 1'b0;
      c2v_t_valid1 = 1'b0;
      c2v_t0 = '0;
      c2v_t1 = '0;
    end
  endtask

  task automatic drive_accum_pair(
    input logic start_i,
    input logic end_i,
    input logic sign0_i,
    input logic [D-1:0] mag0_i,
    input logic valid1_i,
    input logic sign1_i,
    input logic [D-1:0] mag1_i
  );
    begin
      col_start = start_i;
      col_end = end_i;
      c2v_valid0 = 1'b1;
      c2v_sign0 = sign0_i;
      c2v_mag0 = mag0_i;
      c2v_valid1 = valid1_i;
      c2v_sign1 = sign1_i;
      c2v_mag1 = mag1_i;
      @(posedge clk);
      #1;
    end
  endtask

  task automatic run_case0;
    logic signed [VNU_TC_W-1:0] expected_partial_sum;
    begin
      initial_llr = 9;
      drive_accum_pair(1'b1, 1'b0, 1'b0, D'(15), 1'b1, 1'b0, D'(15));
      expected_partial_sum = VNU_TC_W'(30);
      if (app_valid !== 1'b0) $fatal(1, "case0 app_valid should stay low before end");
      if (dut.accum_sum_reg !== expected_partial_sum) $fatal(1, "case0 partial accumulation mismatch: got %0d exp %0d", dut.accum_sum_reg, expected_partial_sum);

      drive_accum_pair(1'b0, 1'b1, 1'b1, D'(9), 1'b0, 1'b0, '0);
      if (app_valid !== 1'b1) $fatal(1, "case0 app_valid should assert after final accumulation");
      if (app !== 11) $fatal(1, "case0 app mismatch: got %0d exp 11", app);
      if (bit_decision !== 0) $fatal(1, "case0 bit decision mismatch");

      idle_inputs();
      emit_en = 1'b1;
      c2v_t_valid0 = 1'b1;
      c2v_t_valid1 = 1'b1;
      c2v_t0 = msg_tc(1'b0, D'(15));
      c2v_t1 = msg_tc(1'b0, D'(15));
      #1;
      if (v2c_valid0 !== 1'b1 || v2c0 !== {1'b0, D'(10)}) $fatal(1, "case0 v2c0 mismatch");
      if (v2c_valid1 !== 1'b1 || v2c1 !== {1'b0, D'(10)}) $fatal(1, "case0 v2c1 mismatch");

      c2v_t_valid0 = 1'b1;
      c2v_t_valid1 = 1'b0;
      c2v_t0 = msg_tc(1'b1, D'(9));
      c2v_t1 = '0;
      #1;
      if (v2c_valid0 !== 1'b1 || v2c0 !== {1'b0, D'(12)}) $fatal(1, "case0 v2c2 mismatch");
      if (v2c_valid1 !== 1'b0) $fatal(1, "case0 v2c1 should be invalid on odd edge");
      idle_inputs();
    end
  endtask

  task automatic run_case1;
    begin
      initial_llr = 31;
      drive_accum_pair(1'b1, 1'b0, 1'b1, D'(15), 1'b1, 1'b1, D'(15));
      drive_accum_pair(1'b0, 1'b1, 1'b1, D'(15), 1'b0, 1'b0, '0);
      if (app_valid !== 1'b1) $fatal(1, "case1 app_valid should assert after final accumulation");
      if (app !== 27) $fatal(1, "case1 app mismatch: got %0d exp 27", app);
      if (bit_decision !== 0) $fatal(1, "case1 bit decision mismatch");

      idle_inputs();
      emit_en = 1'b1;
      c2v_t_valid0 = 1'b1;
      c2v_t_valid1 = 1'b1;
      c2v_t0 = msg_tc(1'b1, D'(15));
      c2v_t1 = msg_tc(1'b1, D'(15));
      #1;
      if (v2c0 !== {1'b0, D'(15)}) $fatal(1, "case1 v2c0 saturation mismatch");
      if (v2c1 !== {1'b0, D'(15)}) $fatal(1, "case1 v2c1 saturation mismatch");
      idle_inputs();
    end
  endtask

  initial begin
    rst_n = 1'b0;
    clear_en = 1'b0;
    initial_llr = '0;
    idle_inputs();

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    run_case0();

    clear_en = 1'b1;
    @(posedge clk);
    clear_en = 1'b0;
    #1;

    run_case1();

    $display("tb_vnu PASS");
    $finish;
  end
endmodule
