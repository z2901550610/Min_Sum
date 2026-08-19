`timescale 1ns / 1ps

module tb_trike_decaps_syndrome_runtime;
  localparam int MAX_R = 23;
  localparam int MAX_WEIGHT = 5;
  localparam int WORD_W = 8;
  localparam int MAX_WORDS = (MAX_R + WORD_W - 1) / WORD_W;
  localparam int INDEX_W = $clog2(MAX_R);

  logic                 clk;
  logic                 rst_n;
  logic                 start;
  logic   [       31:0] runtime_r_bits;
  logic   [       31:0] runtime_weight;
  logic   [       31:0] runtime_words;
  logic                 h0_valid;
  logic   [INDEX_W-1:0] h0_index;
  logic                 h0_ready;
  logic                 t0_valid;
  logic   [ WORD_W-1:0] t0_data;
  logic                 t0_ready;
  logic                 u_valid;
  logic   [ WORD_W-1:0] u_data;
  logic                 u_ready;
  logic                 v_valid;
  logic   [ WORD_W-1:0] v_data;
  logic                 v_ready;
  logic                 syndrome_valid;
  logic   [ WORD_W-1:0] syndrome_data;
  logic                 syndrome_last;
  logic                 busy;
  logic                 done;

  logic   [  MAX_R-1:0] t0_vector;
  logic   [  MAX_R-1:0] u_vector;
  logic   [  MAX_R-1:0] v_vector;
  logic   [  MAX_R-1:0] expected_vector;
  logic   [INDEX_W-1:0] support[0:MAX_WEIGHT-1];
  integer               active_weight;
  integer               active_words;
  integer               h0_count;
  integer               t0_count;
  integer               u_count;
  integer               v_count;
  integer               output_count;
  integer               busy_cycles;

  trike_decaps_syndrome_core #(
      .R_BITS          (MAX_R),
      .SECRET_WEIGHT   (MAX_WEIGHT),
      .WORD_W          (WORD_W),
      .DIGIT_W         (2),
      .RUNTIME_GEOMETRY(1'b1)
  ) dut (
      .i_clk                  (clk),
      .i_rst_n                (rst_n),
      .i_start                (start),
      .i_runtime_r_bits       (runtime_r_bits),
      .i_runtime_secret_weight(runtime_weight),
      .i_runtime_words        (runtime_words),
      .i_h0_valid             (h0_valid),
      .i_h0_index             (h0_index),
      .o_h0_ready             (h0_ready),
      .i_t0_valid             (t0_valid),
      .i_t0_data              (t0_data),
      .o_t0_ready             (t0_ready),
      .i_u_valid              (u_valid),
      .i_u_data               (u_data),
      .o_u_ready              (u_ready),
      .i_v_valid              (v_valid),
      .i_v_data               (v_data),
      .o_v_ready              (v_ready),
      .o_syndrome_valid       (syndrome_valid),
      .o_syndrome_data        (syndrome_data),
      .o_syndrome_last        (syndrome_last),
      .i_syndrome_ready       (1'b1),
      .o_busy                 (busy),
      .o_done                 (done)
  );

  always #1 clk = ~clk;

  always_comb begin
    h0_valid = h0_count < active_weight;
    h0_index = support[(h0_count<active_weight)?h0_count : 0];
    t0_valid = t0_count < active_words;
    t0_data  = t0_vector[(t0_count*WORD_W)+:WORD_W];
    u_valid  = u_count < active_words;
    u_data   = u_vector[(u_count*WORD_W)+:WORD_W];
    v_valid  = v_count < active_words;
    v_data   = v_vector[(v_count*WORD_W)+:WORD_W];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      h0_count <= 0;
      t0_count <= 0;
      u_count <= 0;
      v_count <= 0;
      output_count <= 0;
      busy_cycles <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;
      if (h0_valid && h0_ready) h0_count <= h0_count + 1;
      if (t0_valid && t0_ready) t0_count <= t0_count + 1;
      if (u_valid && u_ready) u_count <= u_count + 1;
      if (v_valid && v_ready) v_count <= v_count + 1;
      if (syndrome_valid) begin
        if (syndrome_data != expected_vector[(output_count*WORD_W)+:WORD_W])
          $fatal(1, "runtime syndrome mismatch word=%0d", output_count);
        if (syndrome_last != (output_count == (active_words - 1)))
          $fatal(1, "runtime syndrome last mismatch");
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
    logic [MAX_R-1:0] mask;
    begin
      active_weight = weight_value;
      active_words = (r_value + WORD_W - 1) / WORD_W;
      runtime_r_bits = 32'(r_value);
      runtime_weight = 32'(weight_value);
      runtime_words = 32'(active_words);
      mask = {MAX_R{1'b1}} >> (MAX_R - r_value);
      t0_vector = MAX_R'((32'h156a39c7 ^ seed)) & mask;
      u_vector = MAX_R'((32'h49c35a91 ^ (32'(seed) << 3))) & mask;
      v_vector = MAX_R'((32'h72ad168e ^ (32'(seed) << 5))) & mask;
      h0_vector = '0;
      for (int idx = 0; idx < MAX_WEIGHT; idx++) begin
        support[idx] = INDEX_W'((idx * 3 + int'(seed)) % r_value);
        if (idx < weight_value) h0_vector[support[idx]] = 1'b1;
      end
      expected_vector = cyclic_mul(h0_vector, u_vector, r_value) ^
          cyclic_mul(t0_vector, u_vector ^ v_vector, r_value);
      expected_vector = expected_vector & mask;

      rst_n = 1'b0;
      start = 1'b0;
      repeat (3) @(negedge clk);
      rst_n = 1'b1;
      repeat (2) @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      runtime_r_bits = 32'(MAX_R);
      runtime_weight = 32'(MAX_WEIGHT);
      runtime_words = 32'(MAX_WORDS);
      while (!done) @(negedge clk);
      latency = busy_cycles;
      if ((h0_count != weight_value) || (t0_count != active_words) ||
          (u_count != active_words) || (v_count != active_words) ||
          (output_count != active_words))
        $fatal(1, "runtime syndrome transfer count mismatch");
      @(negedge clk);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    runtime_r_bits = MAX_R;
    runtime_weight = MAX_WEIGHT;
    runtime_words = MAX_WORDS;
    active_weight = MAX_WEIGHT;
    active_words = MAX_WORDS;
    t0_vector = '0;
    u_vector = '0;
    v_vector = '0;
    expected_vector = '0;
    for (int idx = 0; idx < MAX_WEIGHT; idx++) support[idx] = '0;

    run_case(7, 2, 8'h11, latency_a);
    run_case(7, 2, 8'he2, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime r7 data-dependent latency");
    run_case(13, 3, 8'h2d, latency_a);
    run_case(13, 3, 8'hc4, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime r13 data-dependent latency");
    run_case(23, 5, 8'h39, latency_a);
    run_case(23, 5, 8'ha6, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime r23 data-dependent latency");

    $display("tb_trike_decaps_syndrome_runtime PASS");
    $finish;
  end

  initial begin
    repeat (200000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_syndrome_runtime timeout");
  end

endmodule
