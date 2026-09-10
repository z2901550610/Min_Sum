`timescale 1ns / 1ps

module tb_trike_poly_mul_karatsuba_reference;
  `include "generated/trike_poly_mul_reference_case.svh"

  localparam int HALF_WORDS = (REF_WORDS + 1) / 2;
  // Number of shifted subproduct words intersecting the reduction boundary
  // or the unaligned high half. Count intervals, independently of DUT control.
  function automatic int overlap_words(input int first_word);
    int lo;
    int hi;
    lo = (first_word > (REF_WORDS - 1)) ? first_word : (REF_WORDS - 1);
    hi = first_word + 2 * HALF_WORDS - 1;
    if (hi > (2 * REF_WORDS - 2)) hi = 2 * REF_WORDS - 2;
    return (hi >= lo) ? (hi - lo + 1) : 0;
  endfunction
  localparam int SECOND_WRITES = ((REF_R_BITS % REF_WORD_W) == 0) ? 0 : overlap_words(
      0
  ) + 3 * overlap_words(
      HALF_WORDS
  ) + overlap_words(
      2 * HALF_WORDS
  );
  `include "trike_fold_schedule.svh"

  localparam int REF_DENSE_CYCLES =
      (5 * REF_WORDS) + (3 * HALF_WORDS * HALF_WORDS) + (32 * HALF_WORDS) - 3 +
      (2 * (REF_WORDS % 2)) + (2 * SECOND_WRITES) - trike_fold_overlap_savings(
      REF_R_BITS, REF_WORD_W
  );

  logic                  clk;
  logic                  rst_n;
  logic                  start;
  logic                  a_valid;
  logic [REF_WORD_W-1:0] a_data;
  logic                  a_ready;
  logic                  b_valid;
  logic [REF_WORD_W-1:0] b_data;
  logic                  b_ready;
  logic                  result_valid;
  logic [REF_WORD_W-1:0] result_data;
  logic                  result_last;
  logic                  result_ready;
  logic                  busy;
  logic                  done;

  // Stream or RAM outputs unused in this binding.
  /* verilator lint_off PINCONNECTEMPTY */
  trike_poly_mul_karatsuba_core #(
      .R_BITS(REF_R_BITS),
      .WORD_W(REF_WORD_W)
  ) dut (
      .i_clk            (clk),
      .i_rst_n          (rst_n),
      .i_start          (start),
      .i_runtime_r_bits ('0),
      .i_runtime_words  ('0),
      .o_operand_re     (),
      .o_operand_we     (),
      .o_operand_waddr  (),
      .o_operand_a_wdata(),
      .o_operand_b_wdata(),
      .o_a0_addr        (),

      .o_b0_addr(),

      .i_a0_data('0),

      .i_b0_data('0),

      .o_acc_we      (),
      .o_acc_re      (),
      .o_acc_waddr   (),
      .o_acc_raddr   (),
      .o_acc_wdata   (),
      .i_acc_rdata   ('0),
      .i_a_valid     (a_valid),
      .i_a_data      (a_data),
      .o_a_ready     (a_ready),
      .i_b_valid     (b_valid),
      .i_b_data      (b_data),
      .o_b_ready     (b_ready),
      .o_result_valid(result_valid),
      .o_result_data (result_data),
      .o_result_last (result_last),
      .i_result_ready(result_ready),
      .o_busy        (busy),
      .o_done        (done)
  );

  /* verilator lint_on PINCONNECTEMPTY */
  always #1 clk = ~clk;

  task automatic run_reference_case(output int busy_cycles);
    int                    a_idx;
    int                    b_idx;
    int                    result_idx;
    logic                  a_transfer;
    logic                  b_transfer;
    logic                  result_transfer;
    logic                  cycle_busy;
    logic [REF_WORD_W-1:0] transferred_result;
    logic                  transferred_last;
    begin
      @(negedge clk);
      start = 1'b1;
      @(posedge clk);
      #0.1;
      start = 1'b0;

      a_idx = 0;
      b_idx = 0;
      result_idx = 0;
      busy_cycles = 0;
      a_valid = 1'b1;
      a_data = REF_DENSE_A[0];
      b_valid = 1'b1;
      b_data = REF_DENSE_B[0];
      result_ready = 1'b1;

      while (!done) begin
        @(negedge clk);
        cycle_busy = busy;
        a_transfer = a_valid && a_ready;
        b_transfer = b_valid && b_ready;
        result_transfer = result_valid && result_ready;
        transferred_result = result_data;
        transferred_last = result_last;

        @(posedge clk);
        #0.1;
        if (cycle_busy) busy_cycles++;

        if (a_transfer) begin
          a_idx++;
          if (a_idx == REF_WORDS) begin
            a_valid = 1'b0;
          end else begin
            a_data = REF_DENSE_A[a_idx];
          end
        end

        if (b_transfer) begin
          b_idx++;
          if (b_idx == REF_WORDS) begin
            b_valid = 1'b0;
          end else begin
            b_data = REF_DENSE_B[b_idx];
          end
        end

        if (result_transfer) begin
          if (transferred_result != REF_DENSE_RESULT[result_idx]) begin
            $fatal(1, "dense reference mismatch at word %0d", result_idx);
          end
          if (transferred_last != (result_idx == (REF_WORDS - 1))) begin
            $fatal(1, "reference result_last mismatch at word %0d", result_idx);
          end
          result_idx++;
        end
      end

      if (result_idx != REF_WORDS) $fatal(1, "reference result word count mismatch");
      a_valid = 1'b0;
      b_valid = 1'b0;
      result_ready = 1'b0;
    end
  endtask

  int dense_cycles;

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    a_valid = 1'b0;
    a_data = '0;
    b_valid = 1'b0;
    b_data = '0;
    result_ready = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    run_reference_case(dense_cycles);
    if (dense_cycles != REF_DENSE_CYCLES) begin
      $fatal(1, "reference dense cycles=%0d expected=%0d", dense_cycles, REF_DENSE_CYCLES);
    end

    $display("tb_trike_poly_mul_karatsuba_reference PASS r=%0d dense=%0d", REF_R_BITS,
             dense_cycles);
    $finish;
  end

  initial begin
    repeat (REF_DENSE_CYCLES + 1000) @(posedge clk);
    $fatal(1, "tb_trike_poly_mul_karatsuba_reference timeout");
  end
endmodule
