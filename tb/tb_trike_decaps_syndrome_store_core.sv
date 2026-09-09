`timescale 1ns / 1ps

module tb_trike_decaps_syndrome_store_core;
  localparam int MAX_R = 23;
  localparam int MAX_WEIGHT = 5;
  localparam int WORD_W = 8;
  localparam int MAX_WORDS = (MAX_R + WORD_W - 1) / WORD_W;
  localparam int INDEX_W = $clog2(MAX_R);
  localparam int SUPPORT_ADDR_W = $clog2(3 * MAX_WEIGHT);
  localparam int WORD_ADDR_W = $clog2(MAX_WORDS);

  logic                        clk;
  logic                        rst_n;
  logic                        start;
  logic   [              31:0] r_bits;
  logic   [              31:0] secret_weight;
  logic   [              31:0] words;
  logic                        support_re;
  logic   [SUPPORT_ADDR_W-1:0] support_raddr;
  logic   [       INDEX_W-1:0] support_rdata;
  logic                        t0_re;
  logic   [   WORD_ADDR_W-1:0] t0_raddr;
  logic   [        WORD_W-1:0] t0_rdata;
  logic                        u_re;
  logic   [   WORD_ADDR_W-1:0] u_raddr;
  logic   [        WORD_W-1:0] u_rdata;
  logic                        v_re;
  logic   [   WORD_ADDR_W-1:0] v_raddr;
  logic   [        WORD_W-1:0] v_rdata;
  logic                        syndrome_valid;
  logic   [        WORD_W-1:0] syndrome_data;
  logic                        syndrome_last;
  logic                        external_h0_ready;
  logic                        busy;
  logic                        done;

  logic   [       INDEX_W-1:0] support_mem[0:(3*MAX_WEIGHT)-1];
  logic   [        WORD_W-1:0] t0_mem[     0:MAX_WORDS-1];
  logic   [        WORD_W-1:0] u_mem[     0:MAX_WORDS-1];
  logic   [        WORD_W-1:0] v_mem[     0:MAX_WORDS-1];
  logic   [         MAX_R-1:0] expected_vector;
  integer                      active_words;
  integer                      support_reads;
  integer                      t0_reads;
  integer                      u_reads;
  integer                      v_reads;
  integer                      output_count;
  integer                      busy_cycles;

  trike_decaps_syndrome_store_core #(
      .WORD_W(WORD_W),

      .MAX_R_BITS       (MAX_R),
      .MAX_SECRET_WEIGHT(MAX_WEIGHT),
      .SUPPORT_ADDR_W   (SUPPORT_ADDR_W),
      .WORD_ADDR_W      (WORD_ADDR_W),
      .INDEX_W          (INDEX_W)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_r_bits        (r_bits),
      .i_secret_weight (secret_weight),
      .i_words         (words),
      .o_support_re    (support_re),
      .o_support_raddr (support_raddr),
      .i_support_rdata (support_rdata),
      .o_t0_re         (t0_re),
      .o_t0_raddr      (t0_raddr),
      .i_t0_rdata      (t0_rdata),
      .o_u_re          (u_re),
      .o_u_raddr       (u_raddr),
      .i_u_rdata       (u_rdata),
      .o_v_re          (v_re),
      .o_v_raddr       (v_raddr),
      .i_v_rdata       (v_rdata),
      .i_h0_valid      (1'b0),
      .i_h0_index      ('0),
      .o_h0_ready      (external_h0_ready),
      .o_syndrome_valid(syndrome_valid),
      .o_syndrome_data (syndrome_data),
      .o_syndrome_last (syndrome_last),
      .i_syndrome_ready(1'b1),
      .o_busy          (busy),
      .o_done          (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk) begin
    if (support_re) support_rdata <= support_mem[support_raddr];
    if (t0_re) t0_rdata <= t0_mem[t0_raddr];
    if (u_re) u_rdata <= u_mem[u_raddr];
    if (v_re) v_rdata <= v_mem[v_raddr];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      support_reads <= 0;
      t0_reads <= 0;
      u_reads <= 0;
      v_reads <= 0;
      output_count <= 0;
      busy_cycles <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;
      if (support_re) support_reads <= support_reads + 1;
      if (t0_re) t0_reads <= t0_reads + 1;
      if (u_re) u_reads <= u_reads + 1;
      if (v_re) v_reads <= v_reads + 1;
      if (syndrome_valid) begin
        if (syndrome_data != expected_vector[(output_count*WORD_W)+:WORD_W])
          $fatal(1, "store-fed syndrome mismatch word=%0d", output_count);
        if (syndrome_last != (output_count == (active_words - 1)))
          $fatal(1, "store-fed syndrome last mismatch");
        output_count <= output_count + 1;
      end
    end
  end

  function automatic logic [MAX_R-1:0] cyclic_mul(input  logic [MAX_R-1:0] a,
                                                  input  logic [MAX_R-1:0] b, input integer r_value);
    logic [MAX_R-1:0] result;
    begin
      result = '0;
      for (int a_idx = 0; a_idx < MAX_R; a_idx++) begin
        for (int b_idx = 0; b_idx < MAX_R; b_idx++) begin
          if ((a_idx < r_value) && (b_idx < r_value) && a[a_idx] && b[b_idx])
            result[(a_idx+b_idx)%r_value] = result[(a_idx+b_idx)%r_value] ^ 1'b1;
        end
      end
      cyclic_mul = result;
    end
  endfunction

  task automatic run_case(input integer r_value, input integer weight_value, input  logic [7:0] seed,
                          output integer latency);
    logic [MAX_R-1:0] h0_vector;
    logic [MAX_R-1:0] t0_vector;
    logic [MAX_R-1:0] u_vector;
    logic [MAX_R-1:0] v_vector;
    logic [MAX_R-1:0] mask;
    begin
      active_words = (r_value + WORD_W - 1) / WORD_W;
      mask = {MAX_R{1'b1}} >> (MAX_R - r_value);
      t0_vector = MAX_R'((32'h156a39c7 ^ seed)) & mask;
      u_vector = MAX_R'((32'h49c35a91 ^ (32'(seed) << 3))) & mask;
      v_vector = MAX_R'((32'h72ad168e ^ (32'(seed) << 5))) & mask;
      h0_vector = '0;
      for (int idx = 0; idx < (3 * MAX_WEIGHT); idx++) support_mem[idx] = '0;
      for (int idx = 0; idx < MAX_WEIGHT; idx++) begin
        support_mem[idx] = INDEX_W'((idx * 3 + int'(seed)) % r_value);
        if (idx < weight_value) h0_vector[support_mem[idx]] = 1'b1;
      end
      for (int idx = 0; idx < MAX_WORDS; idx++) begin
        t0_mem[idx] = t0_vector[(idx*WORD_W)+:WORD_W];
        u_mem[idx]  = u_vector[(idx*WORD_W)+:WORD_W];
        v_mem[idx]  = v_vector[(idx*WORD_W)+:WORD_W];
      end
      expected_vector = cyclic_mul(h0_vector, u_vector, r_value) ^
          cyclic_mul(t0_vector, u_vector ^ v_vector, r_value);
      expected_vector = expected_vector & mask;

      r_bits = 32'(r_value);
      secret_weight = 32'(weight_value);
      words = 32'(active_words);
      rst_n = 1'b0;
      start = 1'b0;
      repeat (3) @(negedge clk);
      rst_n = 1'b1;
      repeat (2) @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      r_bits = MAX_R;
      secret_weight = MAX_WEIGHT;
      words = MAX_WORDS;
      while (!done) @(negedge clk);
      latency = busy_cycles;
      if ((support_reads != weight_value) || (t0_reads != active_words) ||
          (u_reads != active_words) || (v_reads != active_words))
        $fatal(1, "store-fed memory access count mismatch");
      if (output_count != active_words) $fatal(1, "store-fed output count mismatch");
      @(negedge clk);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    r_bits = MAX_R;
    secret_weight = MAX_WEIGHT;
    words = MAX_WORDS;
    expected_vector = '0;

    run_case(7, 2, 8'h11, latency_a);
    run_case(7, 2, 8'he2, latency_b);
    if (latency_a != latency_b) $fatal(1, "store-fed r7 data-dependent latency");
    run_case(13, 3, 8'h2d, latency_a);
    run_case(13, 3, 8'hc4, latency_b);
    if (latency_a != latency_b) $fatal(1, "store-fed r13 data-dependent latency");
    run_case(23, 5, 8'h39, latency_a);
    run_case(23, 5, 8'ha6, latency_b);
    if (latency_a != latency_b) $fatal(1, "store-fed r23 data-dependent latency");

    $display("tb_trike_decaps_syndrome_store_core PASS");
    $finish;
  end

  initial begin
    repeat (200000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_syndrome_store_core timeout");
  end

  /* verilator lint_off UNUSED */
  logic unused_external_h0_ready;
  always_comb unused_external_h0_ready = external_h0_ready;
  /* verilator lint_on UNUSED */

endmodule
