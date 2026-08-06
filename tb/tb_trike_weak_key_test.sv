`timescale 1ns / 1ps

module tb_trike_weak_key_test;

  localparam int R_BITS = 13;
  localparam int WEIGHT = 4;
  localparam int INDEX_W = $clog2(R_BITS);
  localparam int POSITION_W = $clog2(WEIGHT);
  localparam int EXPECTED_CYCLES = 330;

  logic                  clk;
  logic                  rst_n;
  logic                  support_valid;
  logic [           1:0] support_block;
  logic [POSITION_W-1:0] support_position;
  logic [   INDEX_W-1:0] support_index;
  logic                  support_ready;
  logic                  start;
  logic                  busy;
  logic                  done;
  logic                  weak_result;
  logic [         191:0] scores;

  int                    busy_cycles;

  trike_weak_key_test #(
      .R_BITS         (R_BITS),
      .WEIGHT         (WEIGHT),
      .SELF_THRESHOLD (4),
      .CROSS_THRESHOLD(10)
  ) dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_support_valid   (support_valid),
      .i_support_block   (support_block),
      .i_support_position(support_position),
      .i_support_index   (support_index),
      .o_support_ready   (support_ready),
      .i_start           (start),
      .o_busy            (busy),
      .o_done            (done),
      .o_weak            (weak_result),
      .o_scores          (scores)
  );

  always #5 clk = ~clk;

  always_ff @(posedge clk) begin
    if (!rst_n || start) begin
      busy_cycles <= 0;
    end else if (busy) begin
      busy_cycles <= busy_cycles + 1;
    end
  end

  task automatic load_case(input bit weak_case);
    int values[0:2][0:3];
    if (weak_case) begin
      values[0] = '{0, 1, 2, 3};
      values[1] = '{0, 1, 2, 3};
      values[2] = '{0, 1, 2, 3};
    end else begin
      values[0] = '{0, 1, 4, 9};
      values[1] = '{0, 2, 5, 10};
      values[2] = '{1, 3, 7, 12};
    end
    for (int block_index = 0; block_index < 3; block_index++) begin
      for (int position = 0; position < WEIGHT; position++) begin
        @(negedge clk);
        support_valid = 1'b1;
        support_block = 2'(block_index);
        support_position = POSITION_W'(position);
        support_index = INDEX_W'(values[block_index][position]);
        if (!support_ready) $fatal(1, "support load was not accepted");
      end
    end
    @(negedge clk);
    support_valid = 1'b0;
  endtask

  task automatic run_case(input bit weak_case);
    int expected[0:5];
    if (weak_case) expected = '{4, 4, 4, 14, 14, 14};
    else expected = '{2, 4, 2, 8, 5, 6};
    load_case(weak_case);
    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;
    wait (done);
    if (weak_result != weak_case) begin
      $fatal(1, "weak result mismatch got=%0d expected=%0d", weak_result, weak_case);
    end
    for (int score_index = 0; score_index < 6; score_index++) begin
      if (scores[32*score_index+:32] != expected[score_index]) begin
        $fatal(1, "score %0d mismatch got=%0d expected=%0d", score_index,
               scores[32*score_index+:32], expected[score_index]);
      end
    end
    if (busy_cycles != EXPECTED_CYCLES) begin
      $fatal(1, "cycle mismatch got=%0d expected=%0d", busy_cycles, EXPECTED_CYCLES);
    end
    @(negedge clk);
  endtask

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    support_valid = 1'b0;
    support_block = '0;
    support_position = '0;
    support_index = '0;
    start = 1'b0;
    repeat (4) @(negedge clk);
    rst_n = 1'b1;

    run_case(1'b0);
    run_case(1'b1);
    $display("tb_trike_weak_key_test PASS cycles=%0d", EXPECTED_CYCLES);
    $finish;
  end

  initial begin
    repeat (2000) @(posedge clk);
    $fatal(1, "tb_trike_weak_key_test timeout");
  end

endmodule
