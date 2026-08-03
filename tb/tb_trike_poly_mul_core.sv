`timescale 1ns / 1ps

module tb_trike_poly_mul_core;
  localparam int R_BITS = 13;
  localparam int WORD_W = 8;
  localparam int DIGIT_W = 4;
  localparam int SPARSE_WEIGHT = 3;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int INDEX_W = $clog2(R_BITS);
  localparam int DENSE_CYCLES = (11 * WORDS) + (WORDS * WORDS * (1 + (4 * WORD_W / DIGIT_W)));
  localparam int SPARSE_CYCLES = (4 * WORDS) + (2 * SPARSE_WEIGHT) + (7 * SPARSE_WEIGHT * WORDS);

  logic                     clk;
  logic                     rst_n;
  logic                     start;
  logic                     sparse_a;
  logic                     a_valid;
  logic [       WORD_W-1:0] a_data;
  logic                     a_ready;
  logic                     sparse_index_valid;
  logic [      INDEX_W-1:0] sparse_index;
  logic                     sparse_index_ready;
  logic                     b_valid;
  logic [       WORD_W-1:0] b_data;
  logic                     b_ready;
  logic                     result_valid;
  logic [       WORD_W-1:0] result_data;
  logic                     result_last;
  logic                     result_ready;
  logic                     busy;
  logic                     done;
  logic                     ext_a_re;
  logic [$clog2(WORDS)-1:0] ext_a_raddr;
  logic                     ext_b_re;
  logic [$clog2(WORDS)-1:0] ext_b_raddr;
  logic                     ext_result_we;
  logic [$clog2(WORDS)-1:0] ext_result_waddr;
  logic [       WORD_W-1:0] ext_result_wdata;

  logic [       WORD_W-1:0] a_words[        0:WORDS-1];
  logic [       WORD_W-1:0] b_words[        0:WORDS-1];
  logic [       WORD_W-1:0] expected_words[        0:WORDS-1];
  logic [      INDEX_W-1:0] sparse_indices[0:SPARSE_WEIGHT-1];

  trike_poly_mul_core #(
      .R_BITS       (R_BITS),
      .WORD_W       (WORD_W),
      .DIGIT_W      (DIGIT_W),
      .SPARSE_WEIGHT(SPARSE_WEIGHT)
  ) dut (
      .i_clk               (clk),
      .i_rst_n             (rst_n),
      .i_start             (start),
      .i_sparse_a          (sparse_a),
      .i_a_valid           (a_valid),
      .i_a_data            (a_data),
      .o_a_ready           (a_ready),
      .i_sparse_index_valid(sparse_index_valid),
      .i_sparse_index      (sparse_index),
      .o_sparse_index_ready(sparse_index_ready),
      .i_b_valid           (b_valid),
      .i_b_data            (b_data),
      .o_b_ready           (b_ready),
      .o_result_valid      (result_valid),
      .o_result_data       (result_data),
      .o_result_last       (result_last),
      .i_result_ready      (result_ready),
      .o_ext_a_re          (ext_a_re),
      .o_ext_a_raddr       (ext_a_raddr),
      .i_ext_a_rdata       ('0),
      .o_ext_b_re          (ext_b_re),
      .o_ext_b_raddr       (ext_b_raddr),
      .i_ext_b_rdata       ('0),
      .o_ext_result_we     (ext_result_we),
      .o_ext_result_waddr  (ext_result_waddr),
      .o_ext_result_wdata  (ext_result_wdata),
      .o_busy              (busy),
      .o_done              (done)
  );

  always #5 clk = ~clk;

  always @(posedge clk) begin
    if (ext_a_re || ext_b_re || ext_result_we) begin
      $fatal(1, "internal RAM mode drove external port a=%0d b=%0d result=%0d data=%h",
             ext_a_raddr, ext_b_raddr, ext_result_waddr, ext_result_wdata);
    end
  end

  task automatic calculate_expected;
    int product_bit;
    begin
      for (int word_idx = 0; word_idx < WORDS; word_idx++) begin
        expected_words[word_idx] = '0;
      end
      for (int a_bit = 0; a_bit < R_BITS; a_bit++) begin
        for (int b_bit = 0; b_bit < R_BITS; b_bit++) begin
          if (a_words[a_bit/WORD_W][a_bit%WORD_W] && b_words[b_bit/WORD_W][b_bit%WORD_W]) begin
            product_bit = (a_bit + b_bit) % R_BITS;
            expected_words[product_bit/WORD_W][product_bit%WORD_W] =
                ~expected_words[product_bit/WORD_W][product_bit%WORD_W];
          end
        end
      end
    end
  endtask

  task automatic run_case(input  logic use_sparse, input int output_stall_cycles,
                          output int busy_cycles);
    int                a_idx;
    int                b_idx;
    int                support_idx;
    int                result_idx;
    int                stall_count;
    logic              a_transfer;
    logic              b_transfer;
    logic              support_transfer;
    logic              result_transfer;
    logic              cycle_busy;
    logic [WORD_W-1:0] held_result;
    logic              held_last;
    logic [WORD_W-1:0] transferred_result;
    logic              transferred_last;
    begin
      @(negedge clk);
      sparse_a = use_sparse;
      start = 1'b1;
      @(posedge clk);
      #1;
      start = 1'b0;

      a_idx = 0;
      b_idx = 0;
      support_idx = 0;
      result_idx = 0;
      stall_count = 0;
      busy_cycles = 0;
      a_valid = !use_sparse;
      a_data = a_words[0];
      sparse_index_valid = use_sparse;
      sparse_index = sparse_indices[0];
      b_valid = 1'b1;
      b_data = b_words[0];
      result_ready = (output_stall_cycles == 0);
      held_result = '0;
      held_last = 1'b0;

      while (!done) begin
        @(negedge clk);
        cycle_busy = busy;
        a_transfer = a_valid && a_ready;
        b_transfer = b_valid && b_ready;
        support_transfer = sparse_index_valid && sparse_index_ready;

        if (result_valid && !result_ready) begin
          if (stall_count == 0) begin
            held_result = result_data;
            held_last   = result_last;
          end else if ((result_data != held_result) || (result_last != held_last)) begin
            $fatal(1, "polynomial result changed under backpressure");
          end
          stall_count++;
          if (stall_count == (output_stall_cycles + 1)) result_ready = 1'b1;
        end
        result_transfer = result_valid && result_ready;
        transferred_result = result_data;
        transferred_last = result_last;

        @(posedge clk);
        #1;
        if (cycle_busy) busy_cycles++;

        if (a_transfer) begin
          a_idx++;
          if (a_idx == WORDS) begin
            a_valid = 1'b0;
          end else begin
            a_data = a_words[a_idx];
          end
        end

        if (support_transfer) begin
          support_idx++;
          if (support_idx == SPARSE_WEIGHT) begin
            sparse_index_valid = 1'b0;
          end else begin
            sparse_index = sparse_indices[support_idx];
          end
        end

        if (b_transfer) begin
          b_idx++;
          if (b_idx == WORDS) begin
            b_valid = 1'b0;
          end else begin
            b_data = b_words[b_idx];
          end
        end

        if (result_transfer) begin
          if (transferred_result != expected_words[result_idx]) begin
            $fatal(1, "result word %0d got=%02x expected=%02x", result_idx, transferred_result,
                   expected_words[result_idx]);
          end
          if (transferred_last != (result_idx == (WORDS - 1))) begin
            $fatal(1, "result_last mismatch at word %0d", result_idx);
          end
          result_idx++;
        end
      end

      if (use_sparse && (support_idx != SPARSE_WEIGHT)) begin
        $fatal(1, "not all sparse indices transferred");
      end
      if (!use_sparse && (a_idx != WORDS)) begin
        $fatal(1, "not all dense A words transferred");
      end
      if (b_idx != WORDS) $fatal(1, "not all B words transferred");
      if (result_idx != WORDS) $fatal(1, "not all result words transferred");

      a_valid = 1'b0;
      sparse_index_valid = 1'b0;
      b_valid = 1'b0;
      result_ready = 1'b0;
    end
  endtask

  int dense_cycles_a;
  int dense_cycles_b;
  int sparse_cycles;
  int sparse_invalid_cycles;
  int stalled_cycles;

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

    a_words[0] = 8'b00001001;
    a_words[1] = 8'b00010000;
    b_words[0] = 8'b00100010;
    b_words[1] = 8'b00000010;
    sparse_indices[0] = INDEX_W'(0);
    sparse_indices[1] = INDEX_W'(3);
    sparse_indices[2] = INDEX_W'(12);
    calculate_expected();

    run_case(1'b0, 0, dense_cycles_a);
    if (dense_cycles_a != DENSE_CYCLES) begin
      $fatal(1, "dense cycles=%0d expected=%0d", dense_cycles_a, DENSE_CYCLES);
    end

    run_case(1'b1, 0, sparse_cycles);
    if (sparse_cycles != SPARSE_CYCLES) begin
      $fatal(1, "sparse cycles=%0d expected=%0d", sparse_cycles, SPARSE_CYCLES);
    end

    a_words[0] = 8'b00001001;
    a_words[1] = 8'b00000000;
    sparse_indices[2] = INDEX_W'(15);
    calculate_expected();
    run_case(1'b1, 0, sparse_invalid_cycles);
    if (sparse_invalid_cycles != sparse_cycles) begin
      $fatal(1, "sparse latency depends on index range");
    end

    a_words[0] = 8'b11010110;
    a_words[1] = 8'b00001101;
    b_words[0] = 8'b10101101;
    b_words[1] = 8'b00010111;
    calculate_expected();
    run_case(1'b0, 0, dense_cycles_b);
    if (dense_cycles_b != dense_cycles_a) begin
      $fatal(1, "dense latency depends on operand data");
    end

    run_case(1'b0, 3, stalled_cycles);
    if (stalled_cycles != (DENSE_CYCLES + 3)) begin
      $fatal(1, "stalled cycles=%0d expected=%0d", stalled_cycles, DENSE_CYCLES + 3);
    end

    $display("tb_trike_poly_mul_core PASS");
    $finish;
  end

  initial begin
    repeat (2000) @(posedge clk);
    $fatal(1, "tb_trike_poly_mul_core timeout");
  end
endmodule
