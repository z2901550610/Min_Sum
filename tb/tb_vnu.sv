`timescale 1ns/1ps

module tb_vnu;
  import bike_pkg::*;

  logic clk;
  logic rst_n;
  logic clear_en;
  logic col_start;
  logic col_end;
  logic signed [APP_W-1:0] initial_llr;
  logic c2v_tc_valid0;
  logic signed [MSG_W-1:0] c2v_tc0;
  logic c2v_tc_valid1;
  logic signed [MSG_W-1:0] c2v_tc1;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [MSG_W-1:0] c2v_to_ram_t0;
  logic [MSG_W-1:0] c2v_to_ram_t1;
  /* verilator lint_on UNUSEDSIGNAL */
  logic app_valid;
  logic signed [APP_W-1:0] app;
  logic bit_decision;
  logic prev_c2v_tc_valid0;
  logic signed [MSG_W-1:0] prev_c2v_tc0;
  logic prev_c2v_tc_valid1;
  logic signed [MSG_W-1:0] prev_c2v_tc1;
  logic v2c_tc_valid0;
  logic signed [VNU_TC_W-1:0] v2c_tc0;
  logic v2c_tc_valid1;
  logic signed [VNU_TC_W-1:0] v2c_tc1;

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

  function automatic int alpha_scale_ref(input int value);
    int abs_value;
    int scaled_abs;
    begin
      abs_value = (value < 0) ? -value : value;
      scaled_abs = 0;
      scaled_abs += abs_value << (ALPHA_FRAC_W - ALPHA_SHIFT_0);
      scaled_abs += abs_value << (ALPHA_FRAC_W - ALPHA_SHIFT_1);
      scaled_abs += 1 << (ALPHA_FRAC_W - 1);
      scaled_abs = scaled_abs >> ALPHA_FRAC_W;
      alpha_scale_ref = (value < 0) ? -scaled_abs : scaled_abs;
    end
  endfunction

  vnu dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(clear_en),
    .i_col_start(col_start),
    .i_col_end(col_end),
    .i_initial_llr(initial_llr),
    .i_c2v0_valid(c2v_tc_valid0),
    .i_c2v0(c2v_tc0),
    .i_c2v1_valid(c2v_tc_valid1),
    .i_c2v1(c2v_tc1),
    .o_c2v_to_ram_t0(c2v_to_ram_t0),
    .o_c2v_to_ram_t1(c2v_to_ram_t1),
    .o_app_valid(app_valid),
    .o_app(app),
    .o_bit_decision(bit_decision),
    .i_c2v_from_ram_t0_valid(prev_c2v_tc_valid0),
    .i_c2v_from_ram_t0(prev_c2v_tc0),
    .i_c2v_from_ram_t1_valid(prev_c2v_tc_valid1),
    .i_c2v_from_ram_t1(prev_c2v_tc1),
    .o_v2c_valid0(v2c_tc_valid0),
    .o_v2c0(v2c_tc0),
    .o_v2c_valid1(v2c_tc_valid1),
    .o_v2c1(v2c_tc1)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic idle_inputs;
    begin
      col_start = 1'b0;
      col_end = 1'b0;
      c2v_tc_valid0 = 1'b0;
      c2v_tc_valid1 = 1'b0;
      c2v_tc0 = '0;
      c2v_tc1 = '0;
      prev_c2v_tc_valid0 = 1'b0;
      prev_c2v_tc_valid1 = 1'b0;
      prev_c2v_tc0 = '0;
      prev_c2v_tc1 = '0;
    end
  endtask

  task automatic drive_accum_pair(
    input logic start_i,
    input logic end_i,
    input logic signed [MSG_W-1:0] msg0_i,
    input logic valid1_i,
    input logic signed [MSG_W-1:0] msg1_i
  );
    begin
      col_start = start_i;
      col_end = end_i;
      c2v_tc_valid0 = 1'b1;
      c2v_tc0 = msg0_i;
      c2v_tc_valid1 = valid1_i;
      c2v_tc1 = msg1_i;
      @(posedge clk);
      #1;
    end
  endtask

  task automatic check_scale_pair(
    input logic signed [MSG_W-1:0] msg0_i,
    input logic valid1_i,
    input logic signed [MSG_W-1:0] msg1_i
  );
    int sum_i;
    int expected_scale;
    begin
      idle_inputs();
      col_start = 1'b1;
      c2v_tc_valid0 = 1'b1;
      c2v_tc0 = msg0_i;
      c2v_tc_valid1 = valid1_i;
      c2v_tc1 = msg1_i;
      #1;
      sum_i = int'($signed(msg0_i)) + (valid1_i ? int'($signed(msg1_i)) : 0);
      expected_scale = alpha_scale_ref(sum_i);
      if (int'($signed(dut.scaled_sum)) != expected_scale) begin
        $fatal(1, "scale mismatch for sum %0d: got %0d exp %0d",
               sum_i, $signed(dut.scaled_sum), expected_scale);
      end
      idle_inputs();
    end
  endtask

  task automatic run_scale_checks;
    begin
      check_scale_pair(msg_tc(1'b0, D'(15)), 1'b0, '0);
      check_scale_pair(msg_tc(1'b1, D'(15)), 1'b0, '0);
      check_scale_pair(msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(15)));
      check_scale_pair(msg_tc(1'b1, D'(15)), 1'b1, msg_tc(1'b1, D'(15)));
      check_scale_pair(msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(1)));
      check_scale_pair(msg_tc(1'b1, D'(15)), 1'b1, msg_tc(1'b1, D'(1)));
      check_scale_pair(msg_tc(1'b0, D'(9)), 1'b1, msg_tc(1'b0, D'(8)));
      check_scale_pair(msg_tc(1'b1, D'(9)), 1'b1, msg_tc(1'b1, D'(8)));
    end
  endtask

  task automatic run_case0;
    logic signed [VNU_TC_W-1:0] expected_partial_sum;
    begin
      initial_llr = 9;
      drive_accum_pair(1'b1, 1'b0, msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(15)));
      expected_partial_sum = VNU_TC_W'(30);
      if (app_valid !== 1'b0) $fatal(1, "case0 app_valid should stay low before end");
      if (dut.accum_sum_reg !== expected_partial_sum) $fatal(1, "case0 partial accumulation mismatch: got %0d exp %0d", dut.accum_sum_reg, expected_partial_sum);

      drive_accum_pair(1'b0, 1'b1, msg_tc(1'b1, D'(9)), 1'b0, '0);
      if (app_valid !== 1'b1) $fatal(1, "case0 app_valid should assert after final accumulation");
      if (app !== 11) $fatal(1, "case0 app mismatch: got %0d exp 11", app);
      if (bit_decision !== 0) $fatal(1, "case0 bit decision mismatch");

      idle_inputs();
      prev_c2v_tc_valid0 = 1'b1;
      prev_c2v_tc_valid1 = 1'b1;
      prev_c2v_tc0 = msg_tc(1'b0, D'(15));
      prev_c2v_tc1 = msg_tc(1'b0, D'(15));
      #1;
      if (v2c_tc_valid0 !== 1'b1 || $signed(v2c_tc0) != 10) $fatal(1, "case0 v2c0 mismatch");
      if (v2c_tc_valid1 !== 1'b1 || $signed(v2c_tc1) != 10) $fatal(1, "case0 v2c1 mismatch");

      prev_c2v_tc_valid0 = 1'b1;
      prev_c2v_tc_valid1 = 1'b0;
      prev_c2v_tc0 = msg_tc(1'b1, D'(9));
      prev_c2v_tc1 = '0;
      #1;
      if (v2c_tc_valid0 !== 1'b1 || $signed(v2c_tc0) != 12) $fatal(1, "case0 v2c2 mismatch");
      if (v2c_tc_valid1 !== 1'b0) $fatal(1, "case0 v2c1 should be invalid on odd edge");
      idle_inputs();
    end
  endtask

  task automatic run_case1;
    begin
      initial_llr = 31;
      drive_accum_pair(1'b1, 1'b0, msg_tc(1'b1, D'(15)), 1'b1, msg_tc(1'b1, D'(15)));
      drive_accum_pair(1'b0, 1'b1, msg_tc(1'b1, D'(15)), 1'b0, '0);
      if (app_valid !== 1'b1) $fatal(1, "case1 app_valid should assert after final accumulation");
      if (app !== 27) $fatal(1, "case1 app mismatch: got %0d exp 27", app);
      if (bit_decision !== 0) $fatal(1, "case1 bit decision mismatch");

      idle_inputs();
      prev_c2v_tc_valid0 = 1'b1;
      prev_c2v_tc_valid1 = 1'b1;
      prev_c2v_tc0 = msg_tc(1'b1, D'(15));
      prev_c2v_tc1 = msg_tc(1'b1, D'(15));
      #1;
      if ($signed(v2c_tc0) != 28) $fatal(1, "case1 v2c0 tc mismatch");
      if ($signed(v2c_tc1) != 28) $fatal(1, "case1 v2c1 tc mismatch");
      idle_inputs();
    end
  endtask

  task automatic run_overlap_case;
    begin
      initial_llr = 9;
      drive_accum_pair(1'b1, 1'b0, msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(15)));
      drive_accum_pair(1'b0, 1'b1, msg_tc(1'b1, D'(9)), 1'b0, '0);
      if (app !== 11) $fatal(1, "overlap setup app mismatch: got %0d exp 11", app);

      idle_inputs();
      col_start = 1'b1;
      col_end = 1'b0;
      c2v_tc_valid0 = 1'b1;
      c2v_tc0 = msg_tc(1'b0, D'(15));
      c2v_tc_valid1 = 1'b1;
      c2v_tc1 = msg_tc(1'b0, D'(15));
      prev_c2v_tc_valid0 = 1'b1;
      prev_c2v_tc0 = msg_tc(1'b0, D'(15));
      prev_c2v_tc_valid1 = 1'b0;
      #1;
      if (v2c_tc_valid0 !== 1'b1 || $signed(v2c_tc0) != 10) $fatal(1, "overlap v2c update used wrong posterior");
      @(posedge clk);
      #1;

      idle_inputs();
      col_end = 1'b1;
      @(posedge clk);
      #1;
      if (app_valid !== 1'b1) $fatal(1, "overlap delayed col_end should assert app_valid");
      if (app !== 12) $fatal(1, "overlap delayed posterior mismatch: got %0d exp 12", app);
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

    run_scale_checks();
    run_case0();

    clear_en = 1'b1;
    @(posedge clk);
    clear_en = 1'b0;
    #1;

    run_overlap_case();

    clear_en = 1'b1;
    @(posedge clk);
    clear_en = 1'b0;
    #1;

    run_case1();

    $display("tb_vnu PASS");
    $finish;
  end
endmodule
