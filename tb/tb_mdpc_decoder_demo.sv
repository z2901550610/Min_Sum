`timescale 1ns/1ps

import mdpc_demo_pkg::*;

module tb_mdpc_decoder_demo;
  `include "tb/generated/mdpc_demo_vectors.svh"

  logic clk;
  logic rst_n;
  logic start;
  logic [N-1:0] x_in;
  logic done;
  logic success;
  logic [N-1:0] x_out;
  logic [$clog2(I_MAX + 1)-1:0] iter_count;
  integer idx;
  integer flat_idx;

  mdpc_decoder_demo dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .x_in(x_in),
    .done(done),
    .success(success),
    .x_out(x_out),
    .iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic apply_reset;
    begin
      rst_n = 1'b0;
      start = 1'b0;
      x_in = '0;
      repeat (2) @(posedge clk);
      rst_n = 1'b1;
      @(posedge clk);
    end
  endtask

  task automatic start_case(input logic [N-1:0] vec);
    begin
      x_in = vec;
      start = 1'b1;
      @(posedge clk);
      start = 1'b0;
    end
  endtask

  task automatic check_hist(input int expected_hist [0:I_MAX-1]);
    begin
      for (idx = 0; idx < I_MAX; idx++) begin
        if (int'(dut.syndrome_hist[idx]) != expected_hist[idx]) begin
          $fatal(1, "syndrome_hist[%0d] mismatch: got %0d exp %0d", idx, dut.syndrome_hist[idx], expected_hist[idx]);
        end
      end
    end
  endtask

  initial begin
    int case0_hist [0:I_MAX-1];
    int case1_hist [0:I_MAX-1];

    case0_hist = CASE0_SYNDROME_HIST;
    case1_hist = CASE1_SYNDROME_HIST;

    apply_reset();
    start_case(CASE0_INPUT);
    wait (done === 1'b1);
    @(posedge clk);
    if (int'(success) != CASE0_SUCCESS) $fatal(1, "CASE0 success mismatch: got %0d exp %0d", success, CASE0_SUCCESS);
    if (int'(iter_count) != CASE0_ITERATIONS) $fatal(1, "CASE0 iterations mismatch: got %0d exp %0d", iter_count, CASE0_ITERATIONS);
    if (x_out !== CASE0_OUTPUT) $fatal(1, "CASE0 x_out mismatch: got %h exp %h", x_out, CASE0_OUTPUT);
    check_hist(case0_hist);

    apply_reset();
    start_case(CASE1_INPUT);

    wait (dut.state == DEC_CNU_B && dut.active_var_idx == 0 && dut.scan_slot == 0);
    #1;
    for (idx = 0; idx < R; idx++) begin
      if (int'(dut.u_m_ram.mem[idx][ROW_STATE_MIN1_LSB +: D]) != CASE1_FIRST_ROW_MIN1[idx]) $fatal(1, "CASE1 row min1[%0d] mismatch", idx);
      if (int'(dut.u_m_ram.mem[idx][ROW_STATE_MIN2_LSB +: D]) != CASE1_FIRST_ROW_MIN2[idx]) $fatal(1, "CASE1 row min2[%0d] mismatch", idx);
      if (int'(dut.u_m_ram.mem[idx][ROW_STATE_MIN_ID_LSB +: VAR_W]) != CASE1_FIRST_ROW_MIN_ID[idx]) $fatal(1, "CASE1 row min_id[%0d] mismatch", idx);
      if (int'(dut.u_m_ram.mem[idx][ROW_STATE_SIGN_XOR_BIT]) != CASE1_FIRST_ROW_SIGN_XOR[idx]) $fatal(1, "CASE1 row sign_xor[%0d] mismatch", idx);
      if (int'(dut.u_m_ram.mem[idx][ROW_STATE_VALID_COUNT_LSB +: 2]) != CASE1_FIRST_ROW_VALID_COUNT[idx]) $fatal(1, "CASE1 row valid_count[%0d] mismatch", idx);
    end

    wait (dut.state == DEC_VNU && dut.active_var_idx == 0);
    #1;
    flat_idx = 0;
    for (idx = 0; idx < N; idx++) begin
      int edge_idx;
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        if (int'(dut.u_t_ram.mem[idx][edge_idx][MSG_SIGN_BIT]) != CASE1_FIRST_C2V_SIGN[flat_idx]) $fatal(1, "CASE1 c2v sign[%0d] mismatch", flat_idx);
        if (int'(dut.u_t_ram.mem[idx][edge_idx][MSG_MAG_LSB +: D]) != CASE1_FIRST_C2V_MAG[flat_idx]) $fatal(1, "CASE1 c2v mag[%0d] mismatch", flat_idx);
        flat_idx += 1;
      end
    end

    wait (dut.state == DEC_CHECK && dut.iter_count == 0);
    #1;
    flat_idx = 0;
    for (idx = 0; idx < N; idx++) begin
      int edge_idx;
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        if (int'(dut.u_u_ram.mem[idx][edge_idx][MSG_SIGN_BIT]) != CASE1_FIRST_U_SIGN[flat_idx]) $fatal(1, "CASE1 u sign[%0d] mismatch", flat_idx);
        if (int'(dut.u_u_ram.mem[idx][edge_idx][MSG_MAG_LSB +: D]) != CASE1_FIRST_U_MAG[flat_idx]) $fatal(1, "CASE1 u mag[%0d] mismatch", flat_idx);
        flat_idx += 1;
      end
    end

    wait (done === 1'b1);
    @(posedge clk);
    if (int'(success) != CASE1_SUCCESS) $fatal(1, "CASE1 success mismatch: got %0d exp %0d", success, CASE1_SUCCESS);
    if (int'(iter_count) != CASE1_ITERATIONS) $fatal(1, "CASE1 iterations mismatch: got %0d exp %0d", iter_count, CASE1_ITERATIONS);
    if (x_out !== CASE1_OUTPUT) $fatal(1, "CASE1 x_out mismatch: got %h exp %h", x_out, CASE1_OUTPUT);
    check_hist(case1_hist);

    $display("tb_mdpc_decoder_demo PASS");
    $finish;
  end
endmodule
