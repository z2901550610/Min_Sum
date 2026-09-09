`timescale 1ns / 1ps

module tb_trike_poly_mul_karatsuba_core;
  localparam int GEOMETRIES = 13;
  localparam int R_VALUES[0:GEOMETRIES-1] = '{
      2,
      13,
      63,
      64,
      65,
      127,
      128,
      129,
      191,
      192,
      193,
      257,
      513
  };
  logic [GEOMETRIES-1:0] complete;
  for (genvar geometry = 0; geometry < GEOMETRIES; geometry++) begin : g_case
    trike_poly_fold_test_case #(
        .R_BITS(R_VALUES[geometry])
    ) u_case (
        .o_complete(complete[geometry])
    );
  end
  initial begin
    wait (&complete);
    $display("tb_trike_poly_mul_karatsuba_core PASS geometries=%0d cases_per_geometry=13",
             GEOMETRIES);
    $finish;
  end
endmodule

// Keep the parameterized checker with the single owning test entrypoint.
/* verilator lint_off DECLFILENAME */
module trike_poly_fold_test_case #(
    parameter int R_BITS = 129
) (
    output logic o_complete
);
  localparam int WORD_W = 64;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int PAD_BITS = WORDS * WORD_W;
  localparam int HALF_WORDS = (WORDS + 1) / 2;
  function automatic int overlap_words(input int first_word);
    int lo;
    int hi;
    lo = (first_word > (WORDS - 1)) ? first_word : (WORDS - 1);
    hi = first_word + 2 * HALF_WORDS - 1;
    if (hi > (2 * WORDS - 2)) hi = 2 * WORDS - 2;
    return (hi >= lo) ? (hi - lo + 1) : 0;
  endfunction
  localparam int SECOND_WRITES = ((R_BITS % WORD_W) == 0) ? 0 : overlap_words(
      0
  ) + 3 * overlap_words(
      HALF_WORDS
  ) + overlap_words(
      2 * HALF_WORDS
  );
  localparam int EXPECTED_CYCLES = 3 * HALF_WORDS * HALF_WORDS + 32 * HALF_WORDS +
      5 * WORDS - 3 + 2 * (WORDS % 2) + 2 * SECOND_WRITES;
  localparam int MIX_WRITES = 10 * HALF_WORDS + SECOND_WRITES;
  logic [     361:0] reference_trace[0:EXPECTED_CYCLES-1];

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

  logic [R_BITS-1:0] case_a[               0:11];
  logic [R_BITS-1:0] case_b[               0:11];

  // Stream or RAM outputs unused in this binding.
  /* verilator lint_off PINCONNECTEMPTY */
  trike_poly_mul_karatsuba_core #(
      .R_BITS              (R_BITS),
      .WORD_W              (WORD_W),
      .BASE_KARATSUBA_DEPTH(1)
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
                          input int case_idx, input bit stalls, output int busy_cycles);
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
    logic [       361:0] trace_value;
    logic [    WORD_W:0] held_output;
    bit                  output_held;
    int                  wait_cycles;
    int                  operand_reads;
    int                  result_reads;
    int                  result_writes;
    begin
      // Deliberately dirty padding checks masking at the input boundary.
      a_padded = '1;
      b_padded = '1;
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
      wait_cycles = 0;
      operand_reads = 0;
      result_reads = 0;
      result_writes = 0;
      output_held = 1'b0;
      held_output = '0;
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
        if (output_held && (!result_valid || ({result_last, result_data} !== held_output))) begin
          $fatal(1, "r=%0d output changed under backpressure", R_BITS);
        end
        output_held = result_valid && !result_ready;
        held_output = {result_last, result_data};
        if ((a_ready && !a_valid) || (b_ready && !b_valid) || (result_valid && !result_ready)) begin
          wait_cycles++;
        end
        if (dut.a0_re) operand_reads++;
        if (dut.result_re) result_reads++;
        if (dut.result_we) result_writes++;
        if ((dut.a0_re && (int'(dut.a0_raddr) >= HALF_WORDS)) ||
            (dut.b0_re && (int'(dut.b0_raddr) >= HALF_WORDS)) ||
            (dut.result_re && (int'(dut.result_raddr) >= WORDS)) ||
            (dut.result_we && (int'(dut.result_waddr) >= WORDS))) begin
          $fatal(1, "r=%0d out-of-range RAM access", R_BITS);
        end
        if ({dut.a0_re, dut.a0_raddr, dut.b0_re, dut.b0_raddr} !==
            {dut.a1_re, dut.a1_raddr, dut.b1_re, dut.b1_raddr}) begin
          $fatal(1, "r=%0d operand bank read schedules differ", R_BITS);
        end
        if (dut.result_we && (int'(dut.result_waddr) == (WORDS - 1)) &&
            ((dut.result_wdata >> (R_BITS - (WORDS - 1) * WORD_W)) != '0)) begin
          $fatal(1, "r=%0d unmasked accumulator padding", R_BITS);
        end
        trace_value = {
          32'(dut.state_q),
          dut.a0_we,
          32'(dut.a0_waddr),
          dut.a1_we,
          32'(dut.a1_waddr),
          dut.b0_we,
          32'(dut.b0_waddr),
          dut.b1_we,
          32'(dut.b1_waddr),
          dut.a0_re,
          32'(dut.a0_raddr),
          dut.a1_re,
          32'(dut.a1_raddr),
          dut.b0_re,
          32'(dut.b0_raddr),
          dut.b1_re,
          32'(dut.b1_raddr),
          dut.result_re,
          32'(dut.result_raddr),
          dut.result_we,
          32'(dut.result_waddr)
        };
        if (!stalls) begin
          if (busy_cycles >= EXPECTED_CYCLES) $fatal(1, "r=%0d exceeded cycle budget", R_BITS);
          if (case_idx == 0) reference_trace[busy_cycles] = trace_value;
          else if (reference_trace[busy_cycles] !== trace_value) begin
            $fatal(1, "r=%0d data-dependent RAM/control trace at cycle %0d", R_BITS, busy_cycles);
          end
        end

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
        a_valid = (a_idx < WORDS) && (!stalls || ((busy_cycles % 4) != 0));
        b_valid = (b_idx < WORDS) && (!stalls || ((busy_cycles % 3) != 0));
        result_ready = !stalls || ((busy_cycles % 5) >= 2);
      end

      if (result_idx != WORDS) $fatal(1, "result word count=%0d expected=%0d", result_idx, WORDS);
      if (observed_padded != expected_padded) begin
        $fatal(1, "r=%0d case=%0d product mismatch observed=%h expected=%h", R_BITS, case_idx,
               observed_padded, expected_padded);
      end
      if (busy_cycles != EXPECTED_CYCLES + wait_cycles) begin
        $fatal(1, "r=%0d busy=%0d expected=%0d waits=%0d", R_BITS, busy_cycles, EXPECTED_CYCLES,
               wait_cycles);
      end
      if ((operand_reads != 3 * HALF_WORDS * HALF_WORDS) ||
          (result_reads != MIX_WRITES + WORDS) || (result_writes != MIX_WRITES + WORDS)) begin
        $fatal(1, "r=%0d access counts A=%0d Rread=%0d Rwrite=%0d", R_BITS, operand_reads,
               result_reads, result_writes);
      end
      a_valid = 1'b0;
      b_valid = 1'b0;
      result_ready = 1'b0;
    end
  endtask

  int          cycles       [0:12];
  logic [31:0] random_state;

  initial begin
    clk = 1'b0;
    o_complete = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    a_valid = 1'b0;
    a_data = '0;
    b_valid = 1'b0;
    b_data = '0;
    result_ready = 1'b0;

    random_state = 32'h20260907 ^ 32'(R_BITS);
    for (int test_idx = 0; test_idx < 12; test_idx++) begin
      for (int bit_idx = 0; bit_idx < R_BITS; bit_idx++) begin
        random_state ^= random_state << 13;
        random_state ^= random_state >> 17;
        random_state ^= random_state << 5;
        case_a[test_idx][bit_idx] = random_state[0];
        case_b[test_idx][bit_idx] = random_state[1];
      end
    end
    case_a[0] = '0;
    case_b[0] = '1;
    case_a[1] = '0;
    case_b[1] = '0;
    case_a[1][R_BITS-1] = 1'b1;
    case_b[1][1] = 1'b1;
    case_a[2] = '1;
    case_b[2] = '1;
    case_a[3] = '0;
    case_b[3] = '0;
    case_a[3][R_BITS-1] = 1'b1;
    case_b[3][R_BITS-1] = 1'b1;
    case_a[11] = '0;
    case_b[11] = '0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    for (int test_idx = 0; test_idx < 12; test_idx++) begin
      run_case(case_a[test_idx], case_b[test_idx], test_idx, 1'b0, cycles[test_idx]);
    end
    run_case(case_a[4], case_b[4], 12, 1'b1, cycles[12]);
    $display("fold case PASS r=%0d cycles=%0d result_RMW=%0d", R_BITS, cycles[0], MIX_WRITES);
    o_complete = 1'b1;
  end

  initial begin
    repeat (20 * EXPECTED_CYCLES) @(posedge clk);
    if (!o_complete) $fatal(1, "fold case timeout r=%0d", R_BITS);
  end
endmodule
/* verilator lint_on DECLFILENAME */
