`timescale 1ns / 1ps

module tb_trike_poly_inv_reference #(

    parameter int DUT_BASE_KARATSUBA_DEPTH = 2
);
`ifdef TRIKE_MINSUM_INV_FIXTURE
  `include "generated/trike_poly_inv_minsum_case.svh"
`else
  `include "generated/trike_poly_inv_reference_case.svh"
`endif

  `include "trike_fold_schedule.svh"

  function automatic integer fold_cycles(input integer r, input integer w);
    integer n, h, extra, off;
    begin
      n = (r + w - 1) / w;
      h = (n + 1) / 2;
      extra = 0;
      if (r % w != 0) begin
        for (integer phase = 0; phase < 3; phase++) begin
          for (integer word_idx = 0; word_idx < 2 * h; word_idx++) begin
            off = word_idx + phase * h;
            if (off >= n - 1 && off <= 2 * n - 2) extra += (phase == 1 ? 3 : 1);
          end
        end
      end
      fold_cycles = 3 * h * h + 38 * h + 3 * n - 3 + 2 * extra - trike_fold_overlap_savings(r, w);
    end
  endfunction
  localparam int REF_INV_DENSE_MUL_CYCLES = fold_cycles(REF_INV_R_BITS, REF_INV_WORD_W);
  localparam int REF_INV_CYCLES =
      REF_INV_WORDS +
      (2 * REF_INV_R_BITS * REF_INV_PERMUTATIONS) +
      (REF_INV_MULTIPLICATIONS * (REF_INV_DENSE_MUL_CYCLES + 1)) +
      (2 * REF_INV_WORDS);

  logic                      clk;
  logic                      rst_n;
  logic                      start;
  logic                      input_valid;
  logic [REF_INV_WORD_W-1:0] input_data;
  logic                      input_ready;
  logic                      result_valid;
  logic [REF_INV_WORD_W-1:0] result_data;
  logic                      result_last;
  logic                      result_ready;
  logic                      busy;
  logic                      done;

  trike_poly_inv_core #(
      .R_BITS(REF_INV_R_BITS),
      .WORD_W(REF_INV_WORD_W),

      .BASE_KARATSUBA_DEPTH(DUT_BASE_KARATSUBA_DEPTH)
  ) dut (
      .i_clk         (clk),
      .i_rst_n       (rst_n),
      .i_start       (start),
      .i_input_valid (input_valid),
      .i_input_data  (input_data),
      .o_input_ready (input_ready),
      .o_result_valid(result_valid),
      .o_result_data (result_data),
      .o_result_last (result_last),
      .i_result_ready(result_ready),
      .o_busy        (busy),
      .o_done        (done)
  );

  always #1 clk = ~clk;

  int input_idx;
  int result_idx;
  int busy_cycles;

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    input_valid = 1'b0;
    input_data = '0;
    result_ready = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(posedge clk);
    #0.1;
    start = 1'b0;

    input_idx = 0;
    result_idx = 0;
    busy_cycles = 0;
    input_valid = 1'b1;
    input_data = REF_INV_INPUT[0];
    result_ready = 1'b1;

    while (!done) begin
      logic input_transfer;
      logic result_transfer;
      logic cycle_busy;

      @(negedge clk);
      cycle_busy = busy;
      input_transfer = input_valid && input_ready;
      result_transfer = result_valid && result_ready;

      if (result_transfer) begin
        if (result_data != REF_INV_RESULT[result_idx]) begin
          $fatal(1, "inverse word %0d got=%016x expected=%016x", result_idx, result_data,
                 REF_INV_RESULT[result_idx]);
        end
        if (result_last != (result_idx == (REF_INV_WORDS - 1))) begin
          $fatal(1, "result_last mismatch at word %0d", result_idx);
        end
        result_idx++;
      end

      @(posedge clk);
      #0.1;
      if (cycle_busy) busy_cycles++;

      if (input_transfer) begin
        input_idx++;
        if (input_idx == REF_INV_WORDS) begin
          input_valid = 1'b0;
        end else begin
          input_data = REF_INV_INPUT[input_idx];
        end
      end
    end

    if (input_idx != REF_INV_WORDS) $fatal(1, "not all input words transferred");
    if (result_idx != REF_INV_WORDS) $fatal(1, "not all result words transferred");
    if (busy_cycles != REF_INV_CYCLES) begin
      $fatal(1, "inverse cycles=%0d expected=%0d", busy_cycles, REF_INV_CYCLES);
    end

    $display("tb_trike_poly_inv_reference PASS cycles=%0d", busy_cycles);
    $finish;
  end

  initial begin
    repeat (REF_INV_CYCLES + 1000) @(posedge clk);
    $fatal(1, "tb_trike_poly_inv_reference timeout");
  end
endmodule
