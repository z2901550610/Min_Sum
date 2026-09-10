`timescale 1ns / 1ps
module tb_trike_poly_mul_runtime;
  localparam int WORD_W = 16;
  localparam int MAX_R = 521;
  localparam int MAX_WORDS = (MAX_R + WORD_W - 1) / WORD_W;
  logic clk;
  logic rst_n;
  logic start, sparse, av, ar, bv, br, sv, sr, rv, rr, last, busy, done;
  logic [31:0] r_bits, words, weight;
  logic [WORD_W-1:0] ad, bd, rd;
  logic [$clog2(MAX_R)-1:0] index_data;
  logic [MAX_R-1:0] a, b, expected;
  logic [191:0] trace[0:8191];
  logic [191:0] now_trace;
  trike_poly_mul_core #(
      .R_BITS(MAX_R),
      .WORD_W(WORD_W),
      .SPARSE_WEIGHT(3),
      .RUNTIME_GEOMETRY(1'b1)
  ) dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_runtime_r_bits(r_bits),
      .i_runtime_words(words),
      .i_runtime_sparse_weight(weight),
      .i_sparse_a(sparse),
      .i_a_valid(av),
      .i_a_data(ad),
      .o_a_ready(ar),
      .i_b_valid(bv),
      .i_b_data(bd),
      .o_b_ready(br),
      .i_sparse_index_valid(sv),
      .i_sparse_index(index_data),
      .o_sparse_index_ready(sr),
      .o_result_valid(rv),
      .o_result_data(rd),
      .o_result_last(last),
      .i_result_ready(rr),
      .o_busy(busy),
      .o_done(done)
  );
  always #1 clk = ~clk;
  assign now_trace = 192'({
    dut.state_q,
    dut.u_dense.state_q,
    dut.a_we,
    dut.a_waddr,
    dut.a_re,
    dut.a_raddr,
    dut.b_we,
    dut.b_waddr,
    dut.b_re,
    dut.b_raddr,
    dut.dense_operand_re,
    dut.dense_operand_we,
    (dut.dense_operand_we ? dut.dense_operand_waddr : '0),
    dut.result_we,
    dut.result_waddr,
    dut.result_re,
    dut.result_raddr,
    dut.sparse_re,
    dut.sparse_raddr
  });
  `include "trike_fold_schedule.svh"

  function automatic int dense_cycles(input int r);
    int n, h, extra, off;
    n = (r + WORD_W - 1) / WORD_W;
    h = (n + 1) / 2;
    extra = 0;
    if (r % WORD_W != 0)
      for (int p = 0; p < 3; p++)
      for (int k = 0; k < 2 * h; k++) begin
        off = k + p * h;
        if (off >= n - 1 && off <= 2 * n - 2) extra += (p == 1 ? 3 : 1);
      end
    return 3 * h * h + 38 * h + 5 * n - 1 + 2 * extra - trike_fold_overlap_savings(r, WORD_W);
  endfunction
  task automatic run_case(input int r, input int pattern, input bit use_sparse, input bit stall);
    int n, ai, bi, si, oi, cycles, waits, tick, expected_cycles;
    int result_reads, result_writes, overlaps;
    bit at, bt, st, ot;
    logic [WORD_W-1:0] captured, golden, held;
    bit captured_last, held_last, holding;
    n = (r + WORD_W - 1) / WORD_W;
    a = '0;
    b = '0;
    expected = '0;
    for (int k = 0; k < r; k++) begin
      a[k] = (pattern == 0) ? 1'b1 : ((k * 7 + pattern) % 11 < 5);
      b[k] = (pattern == 0) ? 1'b0 : ((k * 3 + pattern) % 13 < 7);
    end
    if (use_sparse) begin
      a = '0;
      a[0] = 1;
      a[r/2] = 1;
      a[r-1] = 1;
    end
    for (int i = 0; i < r; i++)
      for (int j = 0; j < r; j++) if (a[i] && b[j]) expected[(i+j)%r] ^= 1'b1;
    @(negedge clk);
    r_bits = 32'(r);
    words  = 32'(n);
    weight = 3;
    sparse = use_sparse;
    start  = 1;
    @(negedge clk);
    start = 0;
    r_bits = MAX_R;
    words = MAX_WORDS;
    weight = 1;
    ai = 0;
    bi = 0;
    si = 0;
    oi = 0;
    cycles = 0;
    waits = 0;
    tick = 0;
    holding = 0;
    result_reads = 0;
    result_writes = 0;
    overlaps = 0;
    while (!done) begin
      if (!busy) $fatal(1, "runtime busy dropped before done");
      av = !use_sparse && ai < n && (!stall || tick % 5 != 0);
      bv = bi < n && (!stall || tick % 7 != 0);
      sv = use_sparse && si < 3;
      rr = !stall || tick % 4 != 0;
      ad = '0;
      bd = '0;
      for (int k = 0; k < WORD_W; k++) begin
        if (ai * WORD_W + k < r) ad[k] = a[ai*WORD_W+k];
        else ad[k] = 1'b1;
        if (bi * WORD_W + k < r) bd[k] = b[bi*WORD_W+k];
        else bd[k] = 1'b1;
      end
      index_data = $clog2(MAX_R)'(si == 0 ? 0 : (si == 1 ? r / 2 : r - 1));
      #0.1;
      at = av && ar;
      bt = bv && br;
      st = sv && sr;
      ot = rv && rr;
      captured = rd;
      captured_last = last;
      if (holding && (!rv || rd != held || last != held_last))
        $fatal(1, "runtime stalled output changed");
      holding = rv && !rr;
      held = rd;
      held_last = last;
      if ((ar && !av) || (br && !bv) || (rv && !rr)) waits++;
      if (!stall) begin
        if (pattern == 0) trace[cycles] = now_trace;
        else if (trace[cycles] !== now_trace)
          $fatal(1, "runtime trace mismatch r=%0d cycle=%0d", r, cycles);
      end
      if (dut.a_re && (int'(dut.a_raddr) >= n)) $fatal(1, "A address bound");
      if (dut.b_re && int'(dut.b_raddr) >= n) $fatal(1, "B address bound");
      if (dut.result_we && int'(dut.result_waddr) >= n) $fatal(1, "result address bound");
      if (dut.result_re) result_reads++;
      if (dut.result_we) result_writes++;
      if (use_sparse && dut.result_re && dut.result_we) begin
        overlaps++;
        if (dut.result_raddr == dut.result_waddr && dut.result_wdata != '0) nonzero_collisions++;
      end
      @(posedge clk);
      #0.1;
      cycles++;
      if (at) ai++;
      if (bt) bi++;
      if (st) si++;
      if (ot) begin
        golden = '0;
        for (int k = 0; k < WORD_W; k++) if (oi * WORD_W + k < r) golden[k] = expected[oi*WORD_W+k];
        if (captured !== golden || captured_last != (oi == n - 1))
          $fatal(1, "runtime result r=%0d word=%0d", r, oi);
        oi++;
      end
      if (cycles >= 8192) $fatal(1, "runtime timeout");
      @(negedge clk);
      tick++;
    end
    // Original operands must be restored before result completion.
    for (int word_idx = 0; word_idx < n; word_idx++) begin
      golden = '0;
      for (int bit_idx = 0; bit_idx < WORD_W; bit_idx++)
      if (word_idx * WORD_W + bit_idx < r) golden[bit_idx] = a[word_idx*WORD_W+bit_idx];
      if (!use_sparse && dut.u_a_mem.g_block.mem[word_idx] !== golden)
        $fatal(1, "A was not restored r=%0d word=%0d", r, word_idx);
      golden = '0;
      for (int bit_idx = 0; bit_idx < WORD_W; bit_idx++)
      if (word_idx * WORD_W + bit_idx < r) golden[bit_idx] = b[word_idx*WORD_W+bit_idx];
      if (dut.u_b_mem.g_block.mem[word_idx] !== golden)
        $fatal(1, "B was not restored r=%0d word=%0d", r, word_idx);
    end
    expected_cycles = use_sparse ? 4 * n + 6 + 18 * n : dense_cycles(r);
    if (use_sparse && (result_reads != 10 * n || result_writes != 10 * n || overlaps != 6 * n))
      $fatal(
          1,
          "sparse access counts r=%0d read=%0d write=%0d overlap=%0d",
          r,
          result_reads,
          result_writes,
          overlaps
      );
    if (oi != n || cycles != expected_cycles + waits)
      $fatal(
          1, "runtime r=%0d cycles=%0d expected=%0d waits=%0d", r, cycles, expected_cycles, waits
      );
    av = 0;
    bv = 0;
    sv = 0;
    rr = 0;
  endtask
  int profiles               [0:12] = '{2, 15, 16, 17, 31, 32, 33, 63, 65, 129, 257, 521, 17};
  int nonzero_collisions = 0;
  initial begin
    clk = 0;
    rst_n = 0;
    start = 0;
    sparse = 0;
    av = 0;
    bv = 0;
    sv = 0;
    rr = 0;
    ad = 0;
    bd = 0;
    index_data = 0;
    r_bits = MAX_R;
    words = MAX_WORDS;
    weight = 3;
    repeat (3) @(negedge clk);
    rst_n = 1;
    foreach (profiles[k]) begin
      run_case(profiles[k], 0, 0, 0);
      run_case(profiles[k], 1, 0, 0);
      run_case(profiles[k], 2, 0, 1);
      if (profiles[k] >= 3) begin
        run_case(profiles[k], 0, 1, 0);
        run_case(profiles[k], 3, 1, 0);
        run_case(profiles[k], 3, 1, 1);
      end
    end
    if (nonzero_collisions == 0) $fatal(1, "same-address nonzero forwarding was not exercised");
    $display(
        "tb_trike_poly_mul_runtime PASS 13 profile transitions, 75 transactions, collisions=%0d",
        nonzero_collisions);
    $finish;
  end
endmodule
