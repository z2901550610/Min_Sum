`timescale 1ns / 1ps

module tb_trike_poly_mul_karatsuba_core;
  localparam int R_BITS = 129;
  localparam int WORD_W = 64;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int PAD_BITS = WORDS * WORD_W;

  logic              clk;
  logic              rst_n;
  logic              start;
  logic              a_valid;
  logic [WORD_W-1:0] a_data;
  logic              a_ready;
  logic              b_valid;
  logic [WORD_W-1:0] b_data;
  logic              b_ready;
  logic              result_valid;
  logic [WORD_W-1:0] result_data;
  logic              result_last;
  logic              result_ready;
  logic              busy;
  logic              done;

  logic [R_BITS-1:0] case_a[0:2];
  logic [R_BITS-1:0] case_b[0:2];

  trike_poly_mul_karatsuba_core #(
      .R_BITS              (R_BITS),
      .WORD_W              (WORD_W),
      .BASE_KARATSUBA_DEPTH(1)
  ) dut (
      .i_clk         (clk),
      .i_rst_n       (rst_n),
      .i_start       (start),
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

  always #1 clk = ~clk;

  function automatic logic [R_BITS-1:0] reference_product(input  logic [R_BITS-1:0] a,
                                                          input  logic [R_BITS-1:0] b);
    logic [R_BITS-1:0] value;
    begin
      value = '0;
      for (int i = 0; i < R_BITS; i++) begin
        for (int j = 0; j < R_BITS; j++) begin
          value[(i+j)%R_BITS] ^= a[i] & b[j];
        end
      end
      return value;
    end
  endfunction

  task automatic run_case(input  logic [R_BITS-1:0] a, input  logic [R_BITS-1:0] b,
                          output int busy_cycles);
    logic [PAD_BITS-1:0] a_padded;
    logic [PAD_BITS-1:0] b_padded;
    logic [PAD_BITS-1:0] expected_padded;
    logic [PAD_BITS-1:0] observed_padded;
    int                  a_idx;
    int                  b_idx;
    int                  result_idx;
    logic                a_transfer;
    logic                b_transfer;
    logic                result_transfer;
    logic                cycle_busy;
    begin
      a_padded = '0;
      b_padded = '0;
      expected_padded = '0;
      observed_padded = '0;
      a_padded[R_BITS-1:0] = a;
      b_padded[R_BITS-1:0] = b;
      expected_padded[R_BITS-1:0] = reference_product(a, b);

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
      a_data = a_padded[0+:WORD_W];
      b_valid = 1'b1;
      b_data = b_padded[0+:WORD_W];
      result_ready = 1'b1;

      while (!done) begin
        @(negedge clk);
        cycle_busy = busy;
        a_transfer = a_valid && a_ready;
        b_transfer = b_valid && b_ready;
        result_transfer = result_valid && result_ready;

        if (result_transfer) begin
          observed_padded[result_idx*WORD_W+:WORD_W] = result_data;
          if (result_last != (result_idx == (WORDS - 1))) begin
            $fatal(1, "result_last mismatch at word %0d", result_idx);
          end
        end

        @(posedge clk);
        #0.1;
        if (cycle_busy) busy_cycles++;

        if (a_transfer) begin
          a_idx++;
          if (a_idx == WORDS) begin
            a_valid = 1'b0;
          end else begin
            a_data = a_padded[a_idx*WORD_W+:WORD_W];
          end
        end

        if (b_transfer) begin
          b_idx++;
          if (b_idx == WORDS) begin
            b_valid = 1'b0;
          end else begin
            b_data = b_padded[b_idx*WORD_W+:WORD_W];
          end
        end

        if (result_transfer) result_idx++;
      end

      if (result_idx != WORDS) $fatal(1, "result word count=%0d expected=%0d", result_idx, WORDS);
      if (observed_padded != expected_padded) begin
        $fatal(1, "product mismatch observed=%h expected=%h", observed_padded, expected_padded);
      end
      a_valid = 1'b0;
      b_valid = 1'b0;
      result_ready = 1'b0;
    end
  endtask

  int cycles[0:2];

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    a_valid = 1'b0;
    a_data = '0;
    b_valid = 1'b0;
    b_data = '0;
    result_ready = 1'b0;

    case_a[0] = '0;
    case_b[0] = '0;
    case_a[0][0] = 1'b1;
    case_a[0][128] = 1'b1;
    case_b[0][1] = 1'b1;
    case_b[0][127] = 1'b1;
    case_a[1] = 129'h1_0123_4567_89ab_cdef_fedc_ba98_7654_3210;
    case_b[1] = 129'h0_0f0f_f0f0_55aa_aa55_1357_9bdf_2468_ace1;
    case_a[2] = {129{1'b1}};
    case_b[2] = 129'h1_8000_0000_0000_0001_0000_0000_0000_0003;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    for (int test_idx = 0; test_idx < 3; test_idx++) begin
      run_case(case_a[test_idx], case_b[test_idx], cycles[test_idx]);
    end

    if ((cycles[0] != cycles[1]) || (cycles[1] != cycles[2])) begin
      $fatal(1, "data-dependent cycle count %0d/%0d/%0d", cycles[0], cycles[1], cycles[2]);
    end

    $display("tb_trike_poly_mul_karatsuba_core PASS cycles=%0d", cycles[0]);
    $finish;
  end

  initial begin
    repeat (2000) @(posedge clk);
    $fatal(1, "tb_trike_poly_mul_karatsuba_core timeout");
  end
endmodule
