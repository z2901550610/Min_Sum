`timescale 1ns/1ps

module tb_decoder_top;
  import bike_pkg::*;

  /* verilator lint_off UNUSEDPARAM */
  `include "tb/generated/bike_demo_vectors.svh"
  /* verilator lint_on UNUSEDPARAM */

  logic clk;
  logic rst_n;
  logic start;
  logic [R-1:0] syndrome_in;
  logic done;
  logic success;
  logic [N-1:0] e_out;
  logic [$clog2(I_MAX + 1)-1:0] iter_count;
  logic checks_active;
  integer h_block_idx;
  integer idx;
  integer flat_idx;

  decoder_top dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
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
      checks_active = 1'b0;
      start = 1'b0;
      syndrome_in = '0;
      repeat (2) @(posedge clk);
      rst_n = 1'b1;
      @(posedge clk);
      checks_active = 1'b1;
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

  function automatic int group_idx_from_row(input int row_idx_i);
    begin
      group_idx_from_row = row_idx_i & 1;
    end
  endfunction

  function automatic int row_local(input int row_idx_i);
    begin
      row_local = row_idx_i >> 1;
    end
  endfunction

  /* verilator lint_off UNUSEDSIGNAL */
  function automatic int edge_row_idx(input int var_idx_i, input int one_idx_i);
    int h_block_local;
    int col_local;
    begin
      h_block_local = var_idx_i / R;
      col_local = var_idx_i % R;
      edge_row_idx = (H_BASE[0][h_block_local][one_idx_i] + col_local) % R;
    end
  endfunction

  function automatic logic [COMP_C2V_W-1:0] ram_m_debug_read(
    input logic pair,
    input int group_idx,
    input int local_row
  );
    begin
      if (!pair && group_idx == 0) ram_m_debug_read = dut.ram_m0_debug_mem[local_row];
      else if (!pair) ram_m_debug_read = dut.ram_m1_debug_mem[local_row];
      else if (group_idx == 0) ram_m_debug_read = dut.ram_m2_debug_mem[local_row];
      else ram_m_debug_read = dut.ram_m3_debug_mem[local_row];
    end
  endfunction
  /* verilator lint_on UNUSEDSIGNAL */

  function automatic logic signed [MSG_W-1:0] ram_t_debug_read(
    input int var_idx_i,
    input int one_idx_i
  );
    begin
      if (group_idx_from_row(edge_row_idx(var_idx_i, one_idx_i)) == 0) begin
        ram_t_debug_read = dut.ram_t0_debug_mem[var_idx_i][one_idx_i];
      end else begin
        ram_t_debug_read = dut.ram_t1_debug_mem[var_idx_i][one_idx_i];
      end
    end
  endfunction

  function automatic logic [MSG_W-1:0] ram_u_debug_read(
    input int var_idx_i,
    input int one_idx_i
  );
    begin
      if (group_idx_from_row(edge_row_idx(var_idx_i, one_idx_i)) == 0) begin
        ram_u_debug_read = dut.ram_u0_debug_mem[var_idx_i][one_idx_i];
      end else begin
        ram_u_debug_read = dut.ram_u1_debug_mem[var_idx_i][one_idx_i];
      end
    end
  endfunction

  always @(posedge clk) begin
    if (checks_active && (dut.error_estimate_bits !== e_out)) begin
      $fatal(1, "decision RAM and o_e diverged: ram=%h out=%h", dut.error_estimate_bits, e_out);
    end
  end

  initial begin
    int case1_hist [0:I_MAX-1];

    case1_hist = CASE1_SYNDROME_HIST;

    fork
      begin
        repeat (20000) @(posedge clk);
        $fatal(1, "tb_decoder_top timeout: state=%0d phase=%0d work_var=%0d work_group_idx_pos=%0d iter=%0d overlap=%0b c2v=%0b v2c=%0b done=%0b",
               dut.state, dut.phase, dut.work_var, dut.work_entry_pos, iter_count,
               dut.c2v_v2c_overlap_seen, dut.c2v_phase_active, dut.v2c_phase_active, done);
      end
    join_none

    apply_reset();
    start_case(CASE1_SYNDROME);

    wait (dut.init_m_read && dut.c2v_var_idx == 1 && dut.active_entry_pos == 0);
    #1;
    if (dut.ram_i_debug_count[0][0] != GROUP_COUNT_W'(2)) $fatal(1, "RAM I shifted group_idx0 count mismatch for column 1");
    if (dut.ram_i_debug_count[0][1] != GROUP_COUNT_W'(1)) $fatal(1, "RAM I shifted group_idx1 count mismatch for column 1");
    if (!(dut.c2v_group_valid[0] && dut.c2v_group_valid[1])) $fatal(1, "shifted column 1 should expose two active group_idxs");
    if (dut.c2v_one_idx_global[0] != ONE_IDX_W'(1) || dut.c2v_row_idx_group[0] != ROW_IDX_W'(1)) $fatal(1, "shifted group_idx0 entry mismatch for column 1");
    if (dut.c2v_one_idx_global[1] != ONE_IDX_W'(0) || dut.c2v_row_idx_group[1] != ROW_IDX_W'(0)) $fatal(1, "shifted group_idx1 entry mismatch for column 1");

    wait (dut.c2v_phase_active && !dut.v2c_phase_active && dut.c2v_var_idx == 0 && dut.active_entry_pos == 0);
    #1;
    if (dut.m_read_pair === dut.m_write_pair) $fatal(1, "RAM M ping-pong pairs should differ");
    for (idx = 0; idx < R; idx++) begin
      if (int'(ram_m_debug_read(dut.m_read_pair, group_idx_from_row(idx), row_local(idx))[COMP_C2V_MIN1_LSB +: D]) != CASE1_FIRST_ROW_MIN1[idx]) $fatal(1, "CASE1 row min1[%0d] mismatch", idx);
      if (int'(ram_m_debug_read(dut.m_read_pair, group_idx_from_row(idx), row_local(idx))[COMP_C2V_MIN2_LSB +: D]) != CASE1_FIRST_ROW_MIN2[idx]) $fatal(1, "CASE1 row min2[%0d] mismatch", idx);
      if (int'(ram_m_debug_read(dut.m_read_pair, group_idx_from_row(idx), row_local(idx))[COMP_C2V_MIN_ID_LSB +: VAR_W]) != CASE1_FIRST_ROW_MIN_ID[idx]) $fatal(1, "CASE1 row min_id[%0d] mismatch", idx);
      if (int'(ram_m_debug_read(dut.m_read_pair, group_idx_from_row(idx), row_local(idx))[COMP_C2V_SIGN_XOR_BIT]) != CASE1_FIRST_ROW_SIGN_XOR[idx]) $fatal(1, "CASE1 row sign_xor[%0d] mismatch", idx);
    end

    wait (dut.c2v_phase_active && dut.v2c_phase_active && dut.c2v_v2c_overlap_seen === 1'b1);
    #1;
    if (!(dut.c2v_phase_active && dut.v2c_phase_active)) $fatal(1, "pipeline did not expose simultaneous CNU_B and VNU/CNU_A work");
    if (dut.c2v_var_idx != dut.v2c_var_idx + VAR_W'(1)) $fatal(1, "overlap should keep the c2v column exactly one step ahead");

    wait (dut.vnu_accum_t && dut.v2c_var_idx == 1 && dut.active_entry_pos == 0);
    #1;
    if (!(dut.vnu_accum_valid[0] && dut.vnu_accum_valid[1])) $fatal(1, "VNU did not consume both RAM-I group_idxs for shifted column 1");

    wait (dut.v2c_phase_active && !dut.c2v_phase_active && dut.v2c_var_idx == VAR_W'(N - 1));
    #1;
    if (dut.state != DEC_ITER_V2C_DRAIN) $fatal(1, "last v2c column should drain without c2v activity");

    wait (iter_count == 1);
    #1;
    if (dut.syndrome_hist[0] != dut.residual_syndrome_next) begin
      $fatal(1, "residual syndrome history mismatch after first iteration");
    end
    flat_idx = 0;
    for (idx = 0; idx < N; idx++) begin
      int one_idx;
      for (one_idx = 0; one_idx < W; one_idx++) begin
        if (int'($signed(ram_t_debug_read(idx, one_idx))) != c2v_signmag_to_tc(CASE1_FIRST_C2V_SIGN[flat_idx], CASE1_FIRST_C2V_MAG[flat_idx])) $fatal(1, "CASE1 c2v tc[%0d] mismatch", flat_idx);
        flat_idx += 1;
      end
    end

    flat_idx = 0;
    for (idx = 0; idx < N; idx++) begin
      int one_idx;
      for (one_idx = 0; one_idx < W; one_idx++) begin
        if (int'(ram_u_debug_read(idx, one_idx)[MSG_SIGN_BIT]) != CASE1_FIRST_U_SIGN[flat_idx]) begin
          $fatal(1, "CASE1 u sign[%0d] mismatch: got %0d exp %0d", flat_idx,
                 int'(ram_u_debug_read(idx, one_idx)[MSG_SIGN_BIT]), CASE1_FIRST_U_SIGN[flat_idx]);
        end
        if (int'(ram_u_debug_read(idx, one_idx)[MSG_MAG_LSB +: D]) != CASE1_FIRST_U_MAG[flat_idx]) begin
          $fatal(1, "CASE1 u mag[%0d] mismatch: got %0d exp %0d", flat_idx,
                 int'(ram_u_debug_read(idx, one_idx)[MSG_MAG_LSB +: D]), CASE1_FIRST_U_MAG[flat_idx]);
        end
        flat_idx += 1;
      end
    end

    if (dut.m_read_pair === dut.m_write_pair) $fatal(1, "RAM M pairs collapsed before iteration swap");
    if (dut.error_estimate_bits !== e_out) $fatal(1, "decision RAM mirror mismatch at completion");

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
