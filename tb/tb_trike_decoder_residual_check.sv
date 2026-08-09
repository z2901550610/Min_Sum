`timescale 1ns / 1ps

module tb_trike_decoder_residual_check;
  localparam int R_BITS = 13;
  localparam int BLOCKS = 3;
  localparam int WEIGHT = 3;
  localparam int N_BITS = BLOCKS * R_BITS;
  localparam int ROW_W = $clog2(R_BITS);
  localparam int COL_W = $clog2(N_BITS);
  localparam int BLOCK_W = $clog2(BLOCKS);
  localparam int DIAG_W = $clog2(WEIGHT);
  localparam int WEIGHT_W = $clog2(R_BITS + 1);

  logic                  clk;
  logic                  rst_n;
  logic                  h_we;
  logic   [ BLOCK_W-1:0] h_block;
  logic   [  DIAG_W-1:0] h_diag;
  logic   [   ROW_W-1:0] h_index;
  logic                  syndrome_we;
  logic   [   ROW_W-1:0] syndrome_addr;
  logic                  syndrome_data;
  logic                  start;
  logic   [   COL_W-1:0] decision_col;
  logic                  decision_data;
  logic                  residual_zero;
  logic   [WEIGHT_W-1:0] residual_weight;
  logic                  busy;
  logic                  done;
  logic   [   ROW_W-1:0] support[0:BLOCKS*WEIGHT-1];
  logic                  decisions[       0:N_BITS-1];
  logic                  syndrome[       0:R_BITS-1];
  integer                cycle_count;

  trike_decoder_residual_check #(
      .R_BITS(R_BITS),
      .BLOCKS(BLOCKS),
      .WEIGHT(WEIGHT)
  ) dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_h_we            (h_we),
      .i_h_block_idx     (h_block),
      .i_h_diag_idx      (h_diag),
      .i_h_index         (h_index),
      .i_syndrome_we     (syndrome_we),
      .i_syndrome_addr   (syndrome_addr),
      .i_syndrome_data   (syndrome_data),
      .i_start           (start),
      .o_decision_col_idx(decision_col),
      .i_decision_data   (decision_data),
      .o_residual_zero   (residual_zero),
      .o_residual_weight (residual_weight),
      .o_busy            (busy),
      .o_done            (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk) begin
    decision_data <= decisions[decision_col];
    if (!rst_n) cycle_count <= 0;
    else cycle_count <= cycle_count + 1;
  end

  task automatic load_syndrome(input  logic flip_first);
    begin
      for (int row = 0; row < R_BITS; row++) begin
        @(negedge clk);
        syndrome_we   = 1'b1;
        syndrome_addr = ROW_W'(row);
        syndrome_data = syndrome[row] ^ (flip_first && (row == 0));
      end
      @(negedge clk);
      syndrome_we = 1'b0;
    end
  endtask

  task automatic run_case(input  logic expect_zero, output integer latency);
    integer start_cycle;
    begin
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "residual checker did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (residual_zero != expect_zero) $fatal(1, "residual zero mismatch");
      if (residual_weight != (expect_zero ? 0 : 1)) $fatal(1, "residual weight mismatch");
    end
  endtask

  initial begin
    integer zero_latency;
    integer nonzero_latency;

    clk = 1'b0;
    rst_n = 1'b0;
    h_we = 1'b0;
    syndrome_we = 1'b0;
    start = 1'b0;
    support[0:8] = '{0, 3, 7, 1, 4, 9, 2, 5, 11};
    for (int idx = 0; idx < N_BITS; idx++) decisions[idx] = 1'b0;
    decisions[1] = 1'b1;
    decisions[8] = 1'b1;
    decisions[R_BITS+2] = 1'b1;
    decisions[2*R_BITS+6] = 1'b1;
    for (int row = 0; row < R_BITS; row++) syndrome[row] = 1'b0;
    for (int variable = 0; variable < N_BITS; variable++) begin
      if (decisions[variable]) begin
        for (int diag = 0; diag < WEIGHT; diag++) begin
          syndrome[((variable%R_BITS)+int'(support[(variable/R_BITS)*WEIGHT+diag]))%R_BITS] ^= 1'b1;
        end
      end
    end

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    for (int idx = 0; idx < (BLOCKS * WEIGHT); idx++) begin
      @(negedge clk);
      h_we = 1'b1;
      h_block = BLOCK_W'(idx / WEIGHT);
      h_diag = DIAG_W'(idx % WEIGHT);
      h_index = support[idx];
    end
    @(negedge clk);
    h_we = 1'b0;

    load_syndrome(1'b0);
    run_case(1'b1, zero_latency);
    load_syndrome(1'b1);
    run_case(1'b0, nonzero_latency);
    if (zero_latency != nonzero_latency) $fatal(1, "residual-dependent checker latency");
    if (zero_latency != 261) $fatal(1, "unexpected residual checker latency");

    $display("tb_trike_decoder_residual_check PASS cycles=%0d", zero_latency);
    $finish;
  end

endmodule
