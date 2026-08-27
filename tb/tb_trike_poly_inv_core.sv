`timescale 1ns / 1ps

module tb_trike_poly_inv_core;
  localparam int R_BITS = 13;
  localparam int WORD_W = 8;
  localparam int DIGIT_W = 4;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int DENSE_MUL_CYCLES = (6 * WORDS) + (WORDS * WORDS * (WORD_W / DIGIT_W)) + 1;
  localparam int PERMUTATIONS = 6;
  localparam int MULTIPLICATIONS = 5;
  localparam int INV_CYCLES =
      WORDS + (2 * R_BITS * PERMUTATIONS) +
      (MULTIPLICATIONS * (DENSE_MUL_CYCLES + 1)) + (2 * WORDS);

  logic              clk;
  logic              rst_n;
  logic              start;
  logic              input_valid;
  logic [WORD_W-1:0] input_data;
  logic              input_ready;
  logic              result_valid;
  logic [WORD_W-1:0] result_data;
  logic              result_last;
  logic              result_ready;
  logic              busy;
  logic              done;

  logic [WORD_W-1:0] input_words[0:WORDS-1];
  logic [WORD_W-1:0] inverse_words[0:WORDS-1];

  trike_poly_inv_core #(
      .R_BITS (R_BITS),
      .WORD_W (WORD_W),
      .DIGIT_W(DIGIT_W)
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

  always #5 clk = ~clk;

  task automatic check_inverse;
    logic [R_BITS-1:0] product;
    begin
      product = '0;
      for (int input_bit = 0; input_bit < R_BITS; input_bit++) begin
        for (int inverse_bit = 0; inverse_bit < R_BITS; inverse_bit++) begin
          if (input_words[input_bit/WORD_W][input_bit%WORD_W] &&
              inverse_words[inverse_bit/WORD_W][inverse_bit%WORD_W]) begin
            product[(input_bit+inverse_bit)%R_BITS] = ~product[(input_bit+inverse_bit)%R_BITS];
          end
        end
      end
      if (product != {{(R_BITS - 1) {1'b0}}, 1'b1}) begin
        $fatal(1, "inverse product=%h expected one", product);
      end
    end
  endtask

  task automatic run_case(input int output_stall_cycles, output int busy_cycles);
    int   input_idx;
    int   result_idx;
    int   stall_count;
    logic input_transfer;
    logic result_transfer;
    logic cycle_busy;
    begin
      @(negedge clk);
      start = 1'b1;
      @(posedge clk);
      #1;
      start = 1'b0;

      input_idx = 0;
      result_idx = 0;
      stall_count = 0;
      busy_cycles = 0;
      input_valid = 1'b1;
      input_data = input_words[0];
      result_ready = (output_stall_cycles == 0);

      while (!done) begin
        @(negedge clk);
        cycle_busy = busy;
        input_transfer = input_valid && input_ready;

        if (result_valid && !result_ready) begin
          stall_count++;
          if (stall_count == (output_stall_cycles + 1)) result_ready = 1'b1;
        end
        result_transfer = result_valid && result_ready;

        if (result_transfer) begin
          inverse_words[result_idx] = result_data;
          if (result_last != (result_idx == (WORDS - 1))) begin
            $fatal(1, "result_last mismatch at word %0d got=%0b dut_word=%0d", result_idx,
                   result_last, dut.word_idx_q);
          end
          result_idx++;
        end

        @(posedge clk);
        #1;
        if (cycle_busy) busy_cycles++;

        if (input_transfer) begin
          input_idx++;
          if (input_idx == WORDS) begin
            input_valid = 1'b0;
          end else begin
            input_data = input_words[input_idx];
          end
        end
      end

      if (input_idx != WORDS) $fatal(1, "not all input words transferred");
      if (result_idx != WORDS) $fatal(1, "not all result words transferred");
      check_inverse();
      input_valid  = 1'b0;
      result_ready = 1'b0;
    end
  endtask

  int cycles_a;
  int cycles_b;
  int stalled_cycles;

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    input_valid = 1'b0;
    input_data = '0;
    result_ready = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    input_words[0] = 8'b00001011;
    input_words[1] = 8'b00000000;
    run_case(0, cycles_a);
    if (cycles_a != INV_CYCLES) begin
      $fatal(1, "inverse cycles=%0d expected=%0d", cycles_a, INV_CYCLES);
    end

    input_words[0] = 8'b10100101;
    input_words[1] = 8'b00010000;
    run_case(0, cycles_b);
    if (cycles_b != cycles_a) begin
      $fatal(1, "inverse latency depends on input data");
    end

    run_case(3, stalled_cycles);
    if (stalled_cycles != (INV_CYCLES + 3)) begin
      $fatal(1, "stalled cycles=%0d expected=%0d", stalled_cycles, INV_CYCLES + 3);
    end

    $display("tb_trike_poly_inv_core PASS cycles=%0d", cycles_a);
    $finish;
  end

  initial begin
    repeat (5000) @(posedge clk);
    $fatal(1, "tb_trike_poly_inv_core timeout");
  end
endmodule
