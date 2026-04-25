`timescale 1ns/1ps

module tb_vnu;
  import bike_pkg::*;

  // Testbench scope:
  // 1) alpha 缩放/舍入
  // 2) 列内 c2v 多拍累加与后验值更新
  // 3) 基于后验值的 v2c 外信息生成
  // 4) 相邻两列交替计算的调度下新旧列数据不混用
  // 5) 0/极值/单拍结束列等边界情况

  logic clk;
  logic rst_n;
  logic col_start;
  logic col_end;
  logic signed [MSG_W-1:0] initial_llr;
  logic c2v_tc_valid0;
  logic signed [MSG_W-1:0] c2v_tc0;
  logic c2v_tc_valid1;
  logic signed [MSG_W-1:0] c2v_tc1;
  /* verilator lint_off UNUSEDSIGNAL */
  logic c2v_to_ram_t0_valid;
  logic [MSG_W-1:0] c2v_to_ram_t0;
  logic c2v_to_ram_t1_valid;
  logic [MSG_W-1:0] c2v_to_ram_t1;
  /* verilator lint_on UNUSEDSIGNAL */
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

  vnu #(
    .W(W),
    .D(D),
    .MSG_W(MSG_W),
    .ALPHA_FRAC_W(ALPHA_FRAC_W),
    .ALPHA_SHIFT_0(ALPHA_SHIFT_0),
    .ALPHA_SHIFT_1(ALPHA_SHIFT_1),
    .VNU_TC_W(VNU_TC_W)
  ) dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_col_start(col_start),
    .i_col_end(col_end),
    .i_initial_llr(initial_llr),
    .i_c2v0_valid(c2v_tc_valid0),
    .i_c2v0(c2v_tc0),
    .i_c2v1_valid(c2v_tc_valid1),
    .i_c2v1(c2v_tc1),
    .o_c2v_t0_valid(c2v_to_ram_t0_valid),
    .o_c2v_t0(c2v_to_ram_t0),
    .o_c2v_t1_valid(c2v_to_ram_t1_valid),
    .o_c2v_t1(c2v_to_ram_t1),
    .o_bit_decision(bit_decision),
    .i_c2v_t0_valid(prev_c2v_tc_valid0),
    .i_c2v_t0(prev_c2v_tc0),
    .i_c2v_t1_valid(prev_c2v_tc_valid1),
    .i_c2v_t1(prev_c2v_tc1),
    .o_v2c0_valid(v2c_tc_valid0),
    .o_v2c0(v2c_tc0),
    .o_v2c1_valid(v2c_tc_valid1),
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

  // 驱动一次列累加输入。用于模拟论文/RTL中的“每拍累加最多 L=2 个 c2v”。
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

  // 检查 alpha_scale 的组合结果是否与参考模型一致。
  // 这里只看“当前拍列和 -> alpha 缩放”的纯组合行为。
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

  // 覆盖缩放路径的常见组合：
  // 单输入、双输入、正负号、大小不同的求和。
  task automatic run_scale_checks;
    begin
      // 零输入边界：结果应保持为 0。
      check_scale_pair('0, 1'b0, '0);
      // 单路最大正/负输入。
      check_scale_pair(msg_tc(1'b0, D'(15)), 1'b0, '0);
      check_scale_pair(msg_tc(1'b1, D'(15)), 1'b0, '0);
      // 双路同号最大值。
      check_scale_pair(msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(15)));
      check_scale_pair(msg_tc(1'b1, D'(15)), 1'b1, msg_tc(1'b1, D'(15)));
      // 双路大小不等，覆盖舍入边界附近的和。
      check_scale_pair(msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(1)));
      check_scale_pair(msg_tc(1'b1, D'(15)), 1'b1, msg_tc(1'b1, D'(1)));
      check_scale_pair(msg_tc(1'b0, D'(9)), 1'b1, msg_tc(1'b0, D'(8)));
      check_scale_pair(msg_tc(1'b1, D'(9)), 1'b1, msg_tc(1'b1, D'(8)));
    end
  endtask

  // 检查写回 RAM-T 的 c2v 透传接口：
  // valid 应直接透传，invalid 时数据清零。
  task automatic run_passthrough_checks;
    begin
      idle_inputs();
      c2v_tc_valid0 = 1'b1;
      c2v_tc0 = msg_tc(1'b0, D'(15));
      c2v_tc_valid1 = 1'b0;
      c2v_tc1 = msg_tc(1'b1, D'(7));
      #1;
      if (c2v_to_ram_t0_valid !== 1'b1 || $signed(c2v_to_ram_t0) != 15) begin
        $fatal(1, "passthrough t0 mismatch");
      end
      if (c2v_to_ram_t1_valid !== 1'b0 || c2v_to_ram_t1 != '0) begin
        $fatal(1, "passthrough t1 invalid path mismatch");
      end

      idle_inputs();
      c2v_tc_valid0 = 1'b1;
      c2v_tc0 = '0;
      c2v_tc_valid1 = 1'b1;
      c2v_tc1 = msg_tc(1'b1, D'(15));
      #1;
      if (c2v_to_ram_t0_valid !== 1'b1 || $signed(c2v_to_ram_t0) != 0) begin
        $fatal(1, "passthrough zero-path mismatch");
      end
      if (c2v_to_ram_t1_valid !== 1'b1 || $signed(c2v_to_ram_t1) != -15) begin
        $fatal(1, "passthrough t1 negative mismatch");
      end
      idle_inputs();
    end
  endtask

  // 基本功能用例：
  // 两拍完成一列，检查部分和、最终后验值、bit decision 和 v2c。
  task automatic run_case0;
    logic signed [VNU_TC_W-1:0] expected_partial_sum;
    begin
      initial_llr = 9;
      drive_accum_pair(1'b1, 1'b0, msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(15)));
      expected_partial_sum = VNU_TC_W'(30);
      if (dut.accum_sum_reg !== expected_partial_sum) $fatal(1, "case0 partial accumulation mismatch: got %0d exp %0d", dut.accum_sum_reg, expected_partial_sum);

      drive_accum_pair(1'b0, 1'b1, msg_tc(1'b1, D'(9)), 1'b0, '0);
      if ($signed(dut.posterior_reg) != 11) $fatal(1, "case0 posterior mismatch: got %0d exp 11", $signed(dut.posterior_reg));
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

  // 负消息累加但仍保持正后验的情况，覆盖不同符号组合下的 v2c。
  task automatic run_case1;
    begin
      initial_llr = MSG_W'(MAG_MAX);
      drive_accum_pair(1'b1, 1'b0, msg_tc(1'b1, D'(15)), 1'b1, msg_tc(1'b1, D'(15)));
      drive_accum_pair(1'b0, 1'b1, msg_tc(1'b1, D'(15)), 1'b0, '0);
      if ($signed(dut.posterior_reg) != 11) $fatal(1, "case1 posterior mismatch: got %0d exp 11", $signed(dut.posterior_reg));
      if (bit_decision !== 0) $fatal(1, "case1 bit decision mismatch");

      idle_inputs();
      prev_c2v_tc_valid0 = 1'b1;
      prev_c2v_tc_valid1 = 1'b1;
      prev_c2v_tc0 = msg_tc(1'b1, D'(15));
      prev_c2v_tc1 = msg_tc(1'b1, D'(15));
      #1;
      if ($signed(v2c_tc0) != 12) $fatal(1, "case1 v2c0 tc mismatch");
      if ($signed(v2c_tc1) != 12) $fatal(1, "case1 v2c1 tc mismatch");
      idle_inputs();
    end
  endtask

  // 关键调度用例：
  // 新一列开始累加时，同时发射上一列 v2c，v2c 必须使用旧 posterior。
  task automatic run_overlap_case;
    begin
      initial_llr = 9;
      drive_accum_pair(1'b1, 1'b0, msg_tc(1'b0, D'(15)), 1'b1, msg_tc(1'b0, D'(15)));
      drive_accum_pair(1'b0, 1'b1, msg_tc(1'b1, D'(9)), 1'b0, '0);
      if ($signed(dut.posterior_reg) != 11) $fatal(1, "overlap setup posterior mismatch: got %0d exp 11", $signed(dut.posterior_reg));

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
      if ($signed(dut.posterior_reg) != 12) $fatal(1, "overlap delayed posterior mismatch: got %0d exp 12", $signed(dut.posterior_reg));
      idle_inputs();
    end
  endtask

  // 边界用例 1：
  // 单拍同时 start+end 完成一列，覆盖“只有一个累加拍”的列调度。
  task automatic run_single_cycle_column_case;
    begin
      idle_inputs();
      initial_llr = MSG_W'(MAG_MAX);
      c2v_tc_valid0 = 1'b1;
      c2v_tc0 = msg_tc(1'b0, D'(15));
      c2v_tc_valid1 = 1'b1;
      c2v_tc1 = msg_tc(1'b0, D'(15));
      col_start = 1'b1;
      col_end = 1'b1;
      @(posedge clk);
      #1;
      if ($signed(dut.posterior_reg) != 18) begin
        $fatal(1, "single-cycle posterior mismatch: got %0d exp 18", $signed(dut.posterior_reg));
      end
      if (bit_decision !== 1'b0) begin
        $fatal(1, "single-cycle bit decision mismatch");
      end
      idle_inputs();
    end
  endtask

  // 边界用例 2：
  // 最小先验 + 最大负 c2v，检查负后验与 sign bit。
  task automatic run_negative_boundary_case;
    begin
      initial_llr = -MSG_W'(MAG_MAX + 1);
      drive_accum_pair(1'b1, 1'b1, msg_tc(1'b1, D'(15)), 1'b1, msg_tc(1'b1, D'(15)));
      if ($signed(dut.posterior_reg) != -19) begin
        $fatal(1, "negative-boundary posterior mismatch: got %0d exp -19", $signed(dut.posterior_reg));
      end
      if (bit_decision !== 1'b1) begin
        $fatal(1, "negative-boundary bit decision mismatch");
      end

      idle_inputs();
      prev_c2v_tc_valid0 = 1'b1;
      prev_c2v_tc0 = msg_tc(1'b1, D'(15));
      prev_c2v_tc_valid1 = 1'b1;
      prev_c2v_tc1 = '0;
      #1;
      if ($signed(v2c_tc0) != -18) begin
        $fatal(1, "negative-boundary v2c0 mismatch: got %0d exp -18", $signed(v2c_tc0));
      end
      if ($signed(v2c_tc1) != -19) begin
        $fatal(1, "negative-boundary v2c1 mismatch: got %0d exp -19", $signed(v2c_tc1));
      end
      idle_inputs();
    end
  endtask

  initial begin
    rst_n = 1'b0;
    initial_llr = '0;
    idle_inputs();

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    // 先验证组合缩放和 RAM-T 透传。
    run_scale_checks();
    run_passthrough_checks();

    // 再验证常规两拍列处理。
    run_case0();

    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    #1;

    // 验证 overlap 调度不破坏旧列 v2c。
    run_overlap_case();

    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    #1;

    // 验证另一组常规输入与边界场景。
    run_case1();
    run_single_cycle_column_case();
    run_negative_boundary_case();

    $display("tb_vnu PASS");
    $finish;
  end
endmodule
