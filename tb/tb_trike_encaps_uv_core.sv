`timescale 1ns / 1ps

module tb_trike_encaps_uv_core;

  localparam int R_BITS = 13;
  localparam int WORD_W = 8;
  localparam int ERROR_WEIGHT = 5;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int INDEX_W = $clog2(3 * R_BITS);
  localparam int ERROR_ADDR_W = $clog2(ERROR_WEIGHT);
  localparam int WORD_ADDR_W = $clog2(WORDS);

  logic                    clk;
  logic                    rst_n;
  logic                    start;
  logic                    error_valid;
  logic [ERROR_ADDR_W-1:0] error_position;
  logic [     INDEX_W-1:0] error_index;
  logic                    error_ready;
  logic [             1:0] operand_select;
  logic [ WORD_ADDR_W-1:0] operand_word;
  logic                    operand_valid;
  logic [      WORD_W-1:0] operand_data;
  logic                    operand_ready;
  logic                    result_valid;
  logic                    result_select;
  logic [      WORD_W-1:0] result_data;
  logic                    result_last;
  logic                    result_ready;
  logic                    busy;
  logic                    done;

  logic [     INDEX_W-1:0] error_sets[0:1][0:ERROR_WEIGHT-1];
  logic [      WORD_W-1:0] operands[0:3][       0:WORDS-1];
  logic [      R_BITS-1:0] expected_u[0:1];
  logic [      R_BITS-1:0] expected_v[0:1];

  trike_encaps_uv_core #(
      .R_BITS      (R_BITS),
      .WORD_W      (WORD_W),
      .ERROR_WEIGHT(ERROR_WEIGHT)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_error_valid   (error_valid),
      .i_error_position(error_position),
      .i_error_index   (error_index),
      .o_error_ready   (error_ready),
      .o_operand_select(operand_select),
      .o_operand_word  (operand_word),
      .i_operand_valid (operand_valid),
      .i_operand_data  (operand_data),
      .o_operand_ready (operand_ready),
      .o_result_valid  (result_valid),
      .o_result_select (result_select),
      .o_result_data   (result_data),
      .o_result_last   (result_last),
      .i_result_ready  (result_ready),
      .o_busy          (busy),
      .o_done          (done)
  );

  always #5 clk = ~clk;

  task automatic calculate_expected(input  logic case_idx);
    logic [R_BITS-1:0] e0;
    logic [R_BITS-1:0] e1;
    logic [R_BITS-1:0] e2;
    logic [R_BITS-1:0] dense[0:3];
    logic [R_BITS-1:0] product;
    begin
      e0 = '0;
      e1 = '0;
      e2 = '0;
      for (int idx = 0; idx < ERROR_WEIGHT; idx++) begin
        if (int'(error_sets[case_idx][idx]) < R_BITS) begin
          e0[int'(error_sets[case_idx][idx])] = 1'b1;
        end else if (int'(error_sets[case_idx][idx]) < (2 * R_BITS)) begin
          e1[int'(error_sets[case_idx][idx])-R_BITS] = 1'b1;
        end else begin
          e2[int'(error_sets[case_idx][idx])-(2*R_BITS)] = 1'b1;
        end
      end
      for (int poly = 0; poly < 4; poly++) begin
        dense[poly] = '0;
        for (int bit_idx = 0; bit_idx < R_BITS; bit_idx++) begin
          dense[poly][bit_idx] = operands[poly][bit_idx/WORD_W][bit_idx%WORD_W];
        end
      end

      expected_u[case_idx] = e0;
      expected_v[case_idx] = e0;
      for (int poly = 0; poly < 4; poly++) begin
        product = '0;
        for (int a_idx = 0; a_idx < R_BITS; a_idx++) begin
          for (int b_idx = 0; b_idx < R_BITS; b_idx++) begin
            if (((poly == 0) || (poly == 2)) && e1[a_idx] && dense[poly][b_idx]) begin
              product[(a_idx+b_idx)%R_BITS] ^= 1'b1;
            end
            if (((poly == 1) || (poly == 3)) && e2[a_idx] && dense[poly][b_idx]) begin
              product[(a_idx+b_idx)%R_BITS] ^= 1'b1;
            end
          end
        end
        if (poly < 2) begin
          expected_u[case_idx] ^= product;
        end else begin
          expected_v[case_idx] ^= product;
        end
      end
    end
  endtask

  task automatic run_case(input  logic case_idx, input int output_stall_cycles,
                          output int busy_cycles);
    int                        error_count;
    int                        operand_count;
    int                        stall_left;
    int                        output_count  [0:1];
    logic [(WORDS*WORD_W)-1:0] observed[0:1];
    begin
      error_count = 0;
      operand_count = 0;
      stall_left = output_stall_cycles;
      output_count[0] = 0;
      output_count[1] = 0;
      observed[0] = '0;
      observed[1] = '0;
      error_valid = 1'b1;
      error_position = ERROR_ADDR_W'(ERROR_WEIGHT - 1);
      error_index = error_sets[case_idx][ERROR_WEIGHT-1];
      operand_valid = 1'b1;
      result_ready = output_stall_cycles == 0;

      @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "busy did not assert after start");
      busy_cycles = 0;

      while (!done) begin
        @(posedge clk);
        busy_cycles++;
        if (error_valid && error_ready) begin
          error_count++;
        end
        if (operand_valid && operand_ready) operand_count++;
        if (result_valid && result_ready) begin
          observed[result_select][output_count[result_select]*WORD_W+:WORD_W] = result_data;
          output_count[result_select]++;
          if (result_last != (output_count[result_select] == WORDS)) begin
            $fatal(1, "result last mismatch select=%0d word=%0d", result_select,
                   output_count[result_select]);
          end
        end

        @(negedge clk);
        if (error_count == ERROR_WEIGHT) begin
          error_valid = 1'b0;
        end else begin
          error_position = ERROR_ADDR_W'(ERROR_WEIGHT - 1 - error_count);
          error_index = error_sets[case_idx][ERROR_WEIGHT-1-error_count];
        end
        operand_data = operands[operand_select][operand_word];
        if (result_valid && (stall_left > 0)) begin
          result_ready = 1'b0;
          stall_left--;
        end else begin
          result_ready = 1'b1;
        end
      end

      if (error_count != ERROR_WEIGHT) $fatal(1, "error support transfer count mismatch");
      if (operand_count != (4 * WORDS)) $fatal(1, "operand transfer count mismatch");
      if ((output_count[0] != WORDS) || (output_count[1] != WORDS)) begin
        $fatal(1, "result word count mismatch u=%0d v=%0d", output_count[0], output_count[1]);
      end
      if (observed[0][R_BITS-1:0] != expected_u[case_idx]) begin
        $fatal(1, "u mismatch got=%h expected=%h", observed[0][R_BITS-1:0], expected_u[case_idx]);
      end
      if (observed[1][R_BITS-1:0] != expected_v[case_idx]) begin
        $fatal(1, "v mismatch got=%h expected=%h", observed[1][R_BITS-1:0], expected_v[case_idx]);
      end

      error_valid   = 1'b0;
      operand_valid = 1'b0;
      result_ready  = 1'b0;
      @(negedge clk);
    end
  endtask

  int cycles_a;
  int cycles_b;
  int cycles_stalled;

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    error_valid = 1'b0;
    error_position = '0;
    error_index = '0;
    operand_valid = 1'b0;
    operand_data = '0;
    result_ready = 1'b0;

    error_sets[0][0] = INDEX_W'(0);
    error_sets[0][1] = INDEX_W'(4);
    error_sets[0][2] = INDEX_W'(R_BITS + 1);
    error_sets[0][3] = INDEX_W'(2 * R_BITS + 2);
    error_sets[0][4] = INDEX_W'(2 * R_BITS + 12);

    error_sets[1][0] = INDEX_W'(R_BITS);
    error_sets[1][1] = INDEX_W'(R_BITS + 1);
    error_sets[1][2] = INDEX_W'(R_BITS + 4);
    error_sets[1][3] = INDEX_W'(2 * R_BITS + 2);
    error_sets[1][4] = INDEX_W'(2 * R_BITS + 12);

    operands[0][0] = 8'b00001001;
    operands[0][1] = 8'b00010000;
    operands[1][0] = 8'b00010010;
    operands[1][1] = 8'b00000000;
    operands[2][0] = 8'b00100100;
    operands[2][1] = 8'b00000000;
    operands[3][0] = 8'b01000001;
    operands[3][1] = 8'b00000000;

    calculate_expected(0);
    calculate_expected(1);

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    run_case(0, 0, cycles_a);
    run_case(1, 0, cycles_b);
    if (cycles_b != cycles_a) begin
      $fatal(1, "latency depends on e0/e1/e2 weight split: %0d versus %0d", cycles_a, cycles_b);
    end

    run_case(0, 3, cycles_stalled);
    if (cycles_stalled != (cycles_a + 3)) begin
      $fatal(1, "output stall mismatch got=%0d expected=%0d", cycles_stalled, cycles_a + 3);
    end

    $display("tb_trike_encaps_uv_core PASS cycles=%0d", cycles_a);
    $finish;
  end

  initial begin
    repeat (3000) @(posedge clk);
    $fatal(1, "tb_trike_encaps_uv_core timeout");
  end

endmodule
