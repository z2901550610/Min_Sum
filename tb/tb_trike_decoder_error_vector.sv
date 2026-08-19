`timescale 1ns / 1ps

module tb_trike_decoder_error_vector;
  localparam int R_BITS = 13;
  localparam int BLOCKS = 3;
  localparam int PADDED_R_BYTES = 4;
  localparam int N_BITS = BLOCKS * R_BITS;
  localparam int ERROR_BYTES = BLOCKS * PADDED_R_BYTES;
  localparam int COL_W = $clog2(N_BITS);
  localparam int ERROR_ADDR_W = $clog2(ERROR_BYTES);

  logic                      clk;
  logic                      rst_n;
  logic                      start;
  logic   [       COL_W-1:0] decision_col;
  logic                      decision_data;
  logic                      error_re;
  logic   [ERROR_ADDR_W-1:0] error_raddr;
  logic   [             7:0] error_rdata;
  logic                      busy;
  logic                      done;
  logic                      decision_bits[     0:N_BITS-1];
  logic   [             7:0] expected_bytes[0:ERROR_BYTES-1];
  integer                    cycle_count;

  trike_decoder_error_vector #(
      .R_BITS(R_BITS),
      .BLOCKS(BLOCKS),
      .PADDED_R_BYTES(PADDED_R_BYTES)
  ) dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_runtime_r_bits  ('0),
      .o_decision_col_idx(decision_col),
      .i_decision_data   (decision_data),
      .i_error_re        (error_re),
      .i_error_raddr     (error_raddr),
      .o_error_rdata     (error_rdata),
      .o_busy            (busy),
      .o_done            (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk) begin
    decision_data <= decision_bits[decision_col];
    if (!rst_n) cycle_count <= 0;
    else cycle_count <= cycle_count + 1;
  end

  initial begin
    integer start_cycle;
    integer latency;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    error_re = 1'b0;
    error_raddr = '0;
    for (int idx = 0; idx < N_BITS; idx++) decision_bits[idx] = 1'b0;
    decision_bits[0] = 1'b1;
    decision_bits[3] = 1'b1;
    decision_bits[12] = 1'b1;
    decision_bits[R_BITS+1] = 1'b1;
    decision_bits[R_BITS+7] = 1'b1;
    decision_bits[R_BITS+8] = 1'b1;
    decision_bits[2*R_BITS+4] = 1'b1;
    decision_bits[2*R_BITS+5] = 1'b1;
    decision_bits[2*R_BITS+11] = 1'b1;
    expected_bytes[0:11] = '{8'h09, 8'h10, 0, 0, 8'h82, 8'h01, 0, 0, 8'h30, 8'h08, 0, 0};

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
    start = 1'b1;
    start_cycle = cycle_count;
    @(negedge clk);
    start = 1'b0;
    if (!busy) $fatal(1, "decision scan did not become busy");
    while (!done) @(negedge clk);
    latency = cycle_count - start_cycle;
    if (latency != 53) $fatal(1, "unexpected decision scan latency");

    for (int byte_idx = 0; byte_idx < ERROR_BYTES; byte_idx++) begin
      @(negedge clk);
      error_re = 1'b1;
      error_raddr = ERROR_ADDR_W'(byte_idx);
      @(negedge clk);
      if (error_rdata != expected_bytes[byte_idx]) $fatal(1, "dense error byte mismatch");
    end
    error_re = 1'b0;

    $display("tb_trike_decoder_error_vector PASS cycles=%0d", latency);
    $finish;
  end

endmodule
