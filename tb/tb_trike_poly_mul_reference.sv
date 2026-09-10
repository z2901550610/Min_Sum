`timescale 1ns / 1ps

module tb_trike_poly_mul_reference #(

    parameter int DUT_BASE_KARATSUBA_DEPTH = 2
);
  `include "generated/trike_poly_mul_reference_case.svh"

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
  localparam int REF_DENSE_CYCLES = fold_cycles(
      REF_R_BITS, REF_WORD_W
  ) + 2 * ((REF_R_BITS + REF_WORD_W - 1) / REF_WORD_W) + 2;
  localparam int REF_SPARSE_CYCLES =
      (4 * REF_WORDS) + (2 * REF_SPARSE_WEIGHT) +
      (6 * REF_SPARSE_WEIGHT * REF_WORDS);

  logic                   clk;
  logic                   rst_n;
  logic                   start;
  logic                   sparse_a;
  logic                   a_valid;
  logic [ REF_WORD_W-1:0] a_data;
  logic                   a_ready;
  logic                   sparse_index_valid;
  logic [REF_INDEX_W-1:0] sparse_index;
  logic                   sparse_index_ready;
  logic                   b_valid;
  logic [ REF_WORD_W-1:0] b_data;
  logic                   b_ready;
  logic                   result_valid;
  logic [ REF_WORD_W-1:0] result_data;
  logic                   result_last;
  logic                   result_ready;
  logic                   busy;
  logic                   done;

  trike_poly_mul_core #(
      .R_BITS(106781),
      .WORD_W(REF_WORD_W),

      .BASE_KARATSUBA_DEPTH(DUT_BASE_KARATSUBA_DEPTH),
      .SPARSE_WEIGHT       (REF_SPARSE_WEIGHT),
      .RUNTIME_GEOMETRY    (1'b1)
  ) dut (
      .i_clk                  (clk),
      .i_rst_n                (rst_n),
      .i_start                (start),
      .i_runtime_r_bits       (32'(REF_R_BITS)),
      .i_runtime_words        (32'(REF_WORDS)),
      .i_runtime_sparse_weight(32'(REF_SPARSE_WEIGHT)),
      .i_sparse_a             (sparse_a),
      .i_a_valid              (a_valid),
      .i_a_data               (a_data),
      .o_a_ready              (a_ready),
      .i_sparse_index_valid   (sparse_index_valid),
      .i_sparse_index         ($clog2(106781)'(sparse_index)),
      .o_sparse_index_ready   (sparse_index_ready),
      .i_b_valid              (b_valid),
      .i_b_data               (b_data),
      .o_b_ready              (b_ready),
      .o_result_valid         (result_valid),
      .o_result_data          (result_data),
      .o_result_last          (result_last),
      .i_result_ready         (result_ready),

      .o_busy(busy),
      .o_done(done)
  );

  always #1 clk = ~clk;

  task automatic run_reference_case(input logic use_sparse, output int busy_cycles);
    int                    a_idx;
    int                    b_idx;
    int                    support_idx;
    int                    result_idx;
    logic                  a_transfer;
    logic                  b_transfer;
    logic                  support_transfer;
    logic                  result_transfer;
    logic                  cycle_busy;
    logic [REF_WORD_W-1:0] transferred_result;
    logic                  transferred_last;
    begin
      @(negedge clk);
      sparse_a = use_sparse;
      start = 1'b1;
      @(posedge clk);
      #0.1;
      start = 1'b0;

      a_idx = 0;
      b_idx = 0;
      support_idx = 0;
      result_idx = 0;
      busy_cycles = 0;
      a_valid = !use_sparse;
      a_data = REF_DENSE_A[0];
      sparse_index_valid = use_sparse;
      sparse_index = REF_SPARSE_INDICES[0];
      b_valid = 1'b1;
      b_data = REF_DENSE_B[0];
      result_ready = 1'b1;

      while (!done) begin
        @(negedge clk);
        cycle_busy = busy;
        a_transfer = a_valid && a_ready;
        b_transfer = b_valid && b_ready;
        support_transfer = sparse_index_valid && sparse_index_ready;
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

        if (support_transfer) begin
          support_idx++;
          if (support_idx == REF_SPARSE_WEIGHT) begin
            sparse_index_valid = 1'b0;
          end else begin
            sparse_index = REF_SPARSE_INDICES[support_idx];
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
          if (use_sparse) begin
            if (transferred_result != REF_SPARSE_RESULT[result_idx]) begin
              $fatal(1, "sparse reference mismatch at word %0d", result_idx);
            end
          end else if (transferred_result != REF_DENSE_RESULT[result_idx]) begin
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
      sparse_index_valid = 1'b0;
      b_valid = 1'b0;
      result_ready = 1'b0;
    end
  endtask

  int dense_cycles;
  int sparse_cycles;

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    sparse_a = 1'b0;
    a_valid = 1'b0;
    a_data = '0;
    sparse_index_valid = 1'b0;
    sparse_index = '0;
    b_valid = 1'b0;
    b_data = '0;
    result_ready = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    run_reference_case(1'b0, dense_cycles);
    if (dense_cycles != REF_DENSE_CYCLES) begin
      $fatal(1, "reference dense cycles=%0d expected=%0d", dense_cycles, REF_DENSE_CYCLES);
    end

    run_reference_case(1'b1, sparse_cycles);
    if (sparse_cycles != REF_SPARSE_CYCLES) begin
      $fatal(1, "reference sparse cycles=%0d expected=%0d", sparse_cycles, REF_SPARSE_CYCLES);
    end

    $display("tb_trike_poly_mul_reference PASS dense=%0d sparse=%0d", dense_cycles, sparse_cycles);
    $finish;
  end

  initial begin
    repeat (REF_DENSE_CYCLES + REF_SPARSE_CYCLES + 1000) @(posedge clk);
    $fatal(1, "tb_trike_poly_mul_reference timeout");
  end
endmodule
