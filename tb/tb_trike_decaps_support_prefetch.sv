`timescale 1ns / 1ps

module tb_trike_decaps_support_prefetch;
  localparam int BLOCKS = 3;
  localparam int MAX_WEIGHT = 5;
  localparam int MAX_R = 23;
  localparam int MAX_TOTAL = BLOCKS * MAX_WEIGHT;
  localparam int ADDR_W = $clog2(MAX_TOTAL);
  localparam int INDEX_W = $clog2(MAX_R);

  logic                 clk;
  logic                 rst_n;
  logic                 start;
  logic   [       31:0] runtime_weight;
  logic                 support_re;
  logic   [ ADDR_W-1:0] support_raddr;
  logic   [INDEX_W-1:0] support_rdata;
  logic                 h_valid;
  logic   [INDEX_W-1:0] h_index;
  logic                 h0_valid;
  logic   [INDEX_W-1:0] h0_index;
  logic                 busy;
  logic                 done;

  logic   [INDEX_W-1:0] support_mem[0:MAX_TOTAL-1];
  integer               active_weight;
  integer               active_total;
  integer               read_count;
  integer               h_count;
  integer               h0_count;
  integer               cycle_count;

  trike_decaps_support_prefetch #(
      .BLOCKS           (BLOCKS),
      .MAX_SECRET_WEIGHT(MAX_WEIGHT),
      .SUPPORT_ADDR_W   (ADDR_W),
      .INDEX_W          (INDEX_W)
  ) dut (
      .i_clk          (clk),
      .i_rst_n        (rst_n),
      .i_start        (start),
      .i_secret_weight(runtime_weight),
      .o_support_re   (support_re),
      .o_support_raddr(support_raddr),
      .i_support_rdata(support_rdata),
      .o_h_valid      (h_valid),
      .o_h_index      (h_index),
      .i_h_ready      (1'b1),
      .o_h0_valid     (h0_valid),
      .o_h0_index     (h0_index),
      .i_h0_ready     (1'b1),
      .o_busy         (busy),
      .o_done         (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk) begin
    if (support_re) support_rdata <= support_mem[support_raddr];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      read_count <= 0;
      h_count <= 0;
      h0_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        read_count <= 0;
        h_count <= 0;
        h0_count <= 0;
      end else begin
        if (support_re) read_count <= read_count + 1;
        if (h_valid) begin
          if (h_index != support_mem[h_count]) $fatal(1, "support prefetch H mismatch");
          h_count <= h_count + 1;
        end
        if (h0_valid) begin
          if (h0_index != support_mem[h0_count]) $fatal(1, "support prefetch H0 mismatch");
          h0_count <= h0_count + 1;
        end
      end
    end
  end

  task automatic run_case(input integer weight_value, input  logic [7:0] seed,
                          output integer latency);
    integer start_cycle;
    begin
      active_weight = weight_value;
      active_total  = BLOCKS * weight_value;
      for (int idx = 0; idx < MAX_TOTAL; idx++)
      support_mem[idx] = INDEX_W'(((idx * 7) + int'(seed)) % MAX_R);
      runtime_weight = 32'(weight_value);
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      runtime_weight = MAX_WEIGHT;
      if (!busy) $fatal(1, "support prefetch did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (latency != (1 + (2 * active_total))) $fatal(1, "support prefetch latency mismatch");
      if ((read_count != active_total) || (h_count != active_total) || (h0_count != active_weight))
        $fatal(1, "support prefetch transfer count mismatch");
      $display("support prefetch w=%0d seed=%0h cycles=%0d", weight_value, seed, latency);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    runtime_weight = MAX_WEIGHT;
    active_weight = MAX_WEIGHT;
    active_total = MAX_TOTAL;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(1, 8'h11, latency_a);
    run_case(1, 8'he2, latency_b);
    if (latency_a != latency_b) $fatal(1, "support prefetch w1 data-dependent latency");
    run_case(3, 8'h2d, latency_a);
    run_case(3, 8'hc4, latency_b);
    if (latency_a != latency_b) $fatal(1, "support prefetch w3 data-dependent latency");
    run_case(5, 8'h39, latency_a);
    run_case(5, 8'ha6, latency_b);
    if (latency_a != latency_b) $fatal(1, "support prefetch w5 data-dependent latency");

    $display("tb_trike_decaps_support_prefetch PASS");
    $finish;
  end

  initial begin
    repeat (2000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_support_prefetch timeout");
  end

endmodule
