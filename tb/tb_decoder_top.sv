`timescale 1ns/1ps

module tb_decoder_top;
  import bike_pkg::*;

  /* verilator lint_off UNUSEDPARAM */
  `include "tb/generated/bike_demo_vectors.svh"
  /* verilator lint_on UNUSEDPARAM */

  logic clk;
  logic rst_n;
  logic start;
  logic [H_SEL_W-1:0] h_sel;
  logic [R-1:0] syndrome_in;
  logic done;
  logic success;
  logic [N-1:0] e_out;
  logic [$clog2(I_MAX + 1)-1:0] iter_count;
  integer idx;
  integer flat_idx;

  decoder_top dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_h_sel(h_sel),
    .i_syndrome(syndrome_in),
    .o_done(done),
    .o_success(success),
    .o_e(e_out),
    .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic apply_reset;
    begin
      rst_n = 1'b0;
      start = 1'b0;
      h_sel = '0;
      syndrome_in = '0;
      repeat (2) @(posedge clk);
      rst_n = 1'b1;
      @(posedge clk);
    end
  endtask

  task automatic start_case(input logic [R-1:0] syndrome);
    begin
      syndrome_in = syndrome;
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

  function automatic int c2v_signmag_to_tc(
    input int msg_sign,
    input int msg_mag
  );
    begin
      if (msg_sign != 0 && msg_mag != 0) begin
        c2v_signmag_to_tc = -msg_mag;
      end else begin
        c2v_signmag_to_tc = msg_mag;
      end
    end
  endfunction

  function automatic int row_lane(input int row_idx_i);
    begin
      row_lane = (row_idx_i < ROW_SEG_SIZE) ? 0 : 1;
    end
  endfunction

  function automatic int row_local(input int row_idx_i);
    begin
      row_local = (row_idx_i < ROW_SEG_SIZE) ? row_idx_i : (row_idx_i - ROW_SEG_SIZE);
    end
  endfunction

  initial begin
    int case1_hist [0:I_MAX-1];

    case1_hist = CASE1_SYNDROME_HIST;

    apply_reset();
    start_case(CASE1_SYNDROME);

    wait (dut.state == DEC_PIPE_PREP && dut.active_var_idx == 0 && dut.scan_slot == 0);
    #1;
    if (dut.m_read_bank === dut.m_write_bank) $fatal(1, "RAM M ping-pong banks should differ");
    for (idx = 0; idx < R; idx++) begin
      if (int'(dut.u_m_ram.mem[dut.m_read_bank][row_lane(idx)][row_local(idx)][ROW_STATE_MIN1_LSB +: D]) != CASE1_FIRST_ROW_MIN1[idx]) $fatal(1, "CASE1 row min1[%0d] mismatch", idx);
      if (int'(dut.u_m_ram.mem[dut.m_read_bank][row_lane(idx)][row_local(idx)][ROW_STATE_MIN2_LSB +: D]) != CASE1_FIRST_ROW_MIN2[idx]) $fatal(1, "CASE1 row min2[%0d] mismatch", idx);
      if (int'(dut.u_m_ram.mem[dut.m_read_bank][row_lane(idx)][row_local(idx)][ROW_STATE_MIN_ID_LSB +: VAR_W]) != CASE1_FIRST_ROW_MIN_ID[idx]) $fatal(1, "CASE1 row min_id[%0d] mismatch", idx);
      if (int'(dut.u_m_ram.mem[dut.m_read_bank][row_lane(idx)][row_local(idx)][ROW_STATE_SIGN_XOR_BIT]) != CASE1_FIRST_ROW_SIGN_XOR[idx]) $fatal(1, "CASE1 row sign_xor[%0d] mismatch", idx);
    end

    wait (dut.state == DEC_PIPE && dut.pipeline_overlap_seen === 1'b1);
    #1;
    if (!(dut.cnu_b_active && dut.emit_active)) $fatal(1, "pipeline did not expose simultaneous CNU_B and VNU/CNU_A work");

    wait (dut.state == DEC_CHECK && iter_count == 0);
    #1;
    flat_idx = 0;
    for (idx = 0; idx < N; idx++) begin
      int edge_idx;
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        if (int'($signed(dut.u_t_ram.mem[idx][edge_idx])) != c2v_signmag_to_tc(CASE1_FIRST_C2V_SIGN[flat_idx], CASE1_FIRST_C2V_MAG[flat_idx])) $fatal(1, "CASE1 c2v tc[%0d] mismatch", flat_idx);
        flat_idx += 1;
      end
    end

    flat_idx = 0;
    for (idx = 0; idx < N; idx++) begin
      int edge_idx;
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        if (int'(dut.u_u_ram.mem[idx][edge_idx][MSG_SIGN_BIT]) != CASE1_FIRST_U_SIGN[flat_idx]) $fatal(1, "CASE1 u sign[%0d] mismatch", flat_idx);
        if (int'(dut.u_u_ram.mem[idx][edge_idx][MSG_MAG_LSB +: D]) != CASE1_FIRST_U_MAG[flat_idx]) $fatal(1, "CASE1 u mag[%0d] mismatch", flat_idx);
        flat_idx += 1;
      end
    end

    if (dut.m_read_bank === dut.m_write_bank) $fatal(1, "RAM M banks collapsed before iteration swap");

    wait (done === 1'b1);
    @(posedge clk);
    if (int'(success) != CASE1_SUCCESS) $fatal(1, "CASE1 success mismatch: got %0d exp %0d", success, CASE1_SUCCESS);
    if (int'(iter_count) != CASE1_ITERATIONS) $fatal(1, "CASE1 iterations mismatch: got %0d exp %0d", iter_count, CASE1_ITERATIONS);
    if (e_out !== CASE1_OUTPUT) $fatal(1, "CASE1 e_out mismatch: got %h exp %h", e_out, CASE1_OUTPUT);
    check_hist(case1_hist);

    $display("tb_decoder_top PASS");
    $finish;
  end
endmodule
