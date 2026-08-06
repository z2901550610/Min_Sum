`timescale 1ns / 1ps

module tb_trike_weak_key_reference;

  `include "generated/trike_keygen_reference_case.svh"

  localparam int POSITION_W = $clog2(REF_SECRET_WEIGHT);
  localparam int EXPECTED_CYCLES =
      3 * (REF_R_BITS + REF_SECRET_WEIGHT * (REF_SECRET_WEIGHT - 1) +
           2 * ((REF_R_BITS + 1) / 2)) +
      3 * (3 * REF_R_BITS + 2 * REF_SECRET_WEIGHT * REF_SECRET_WEIGHT);

  logic                   clk;
  logic                   rst_n;
  logic                   support_valid;
  logic [            1:0] support_block;
  logic [ POSITION_W-1:0] support_position;
  logic [REF_INDEX_W-1:0] support_index;
  logic                   support_ready;
  logic                   start;
  logic                   busy;
  logic                   done;
  logic                   weak_result;
  logic [          191:0] scores;

  int                     busy_cycles;

  trike_weak_key_test #(
      .R_BITS(REF_R_BITS),
      .WEIGHT(REF_SECRET_WEIGHT)
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

    for (int flat_position = 0; flat_position < 3 * REF_SECRET_WEIGHT; flat_position++) begin
      @(negedge clk);
      support_valid = 1'b1;
      support_block = 2'(flat_position / REF_SECRET_WEIGHT);
      support_position = POSITION_W'(flat_position % REF_SECRET_WEIGHT);
      support_index = REF_SELECTED_SUPPORT[flat_position];
      if (!support_ready) $fatal(1, "reference support load was not accepted");
    end
    @(negedge clk);
    support_valid = 1'b0;
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    wait (done);
    if (weak_result) $fatal(1, "official selected key was marked weak");
    for (int score_index = 0; score_index < 6; score_index++) begin
      if (scores[32*score_index+:32] != REF_SELECTED_SCORES[score_index]) begin
        $fatal(1, "score %0d mismatch got=%0d expected=%0d", score_index,
               scores[32*score_index+:32], REF_SELECTED_SCORES[score_index]);
      end
    end
    if (busy_cycles != EXPECTED_CYCLES) begin
      $fatal(1, "cycle mismatch got=%0d expected=%0d", busy_cycles, EXPECTED_CYCLES);
    end
    $display("tb_trike_weak_key_reference PASS cycles=%0d", busy_cycles);
    $finish;
  end

  initial begin
    repeat (300000) @(posedge clk);
    $fatal(1, "tb_trike_weak_key_reference timeout");
  end

endmodule
