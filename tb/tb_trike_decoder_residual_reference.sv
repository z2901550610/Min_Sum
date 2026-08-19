`timescale 1ns / 1ps

module tb_trike_decoder_residual_reference;
  `include "generated/trike_decaps_message_minsum_case.svh"

  localparam int COL_W = $clog2(REF_BLOCKS * REF_R_BITS);
  localparam int BLOCK_W = $clog2(REF_BLOCKS);
  localparam int DIAG_W = $clog2(REF_SECRET_WEIGHT);
  localparam int WEIGHT_W = $clog2(REF_R_BITS + 1);
  localparam int EXPECTED_CYCLES = 1 + REF_R_BITS * (2 + 2 * REF_BLOCKS * REF_SECRET_WEIGHT);

  logic                       clk;
  logic                       rst_n;
  logic                       h_we;
  logic   [      BLOCK_W-1:0] h_block;
  logic   [       DIAG_W-1:0] h_diag;
  logic   [REF_ROW_WIDTH-1:0] h_index;
  logic                       syndrome_we;
  logic   [REF_ROW_WIDTH-1:0] syndrome_addr;
  logic                       syndrome_data;
  logic                       start;
  logic   [        COL_W-1:0] decision_col;
  logic                       decision_data;
  logic                       residual_zero;
  logic   [     WEIGHT_W-1:0] residual_weight;
  logic                       busy;
  logic                       done;
  integer                     cycle_count;

  trike_decoder_residual_check #(
      .R_BITS(REF_R_BITS),
      .BLOCKS(REF_BLOCKS),
      .WEIGHT(REF_SECRET_WEIGHT),
      .RUNTIME_GEOMETRY(1'b1)
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
      .i_runtime_r_bits  (32'(REF_R_BITS)),
      .i_runtime_weight  (32'(REF_SECRET_WEIGHT)),
      .o_decision_col_idx(decision_col),
      .i_decision_data   (decision_data),
      .o_residual_zero   (residual_zero),
      .o_residual_weight (residual_weight),
      .o_busy            (busy),
      .o_done            (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk) begin
    decision_data <= REF_DECISION[decision_col];
    if (!rst_n) cycle_count <= 0;
    else cycle_count <= cycle_count + 1;
  end

  task automatic load_syndrome(input  logic flip_first);
    begin
      for (int row = 0; row < REF_R_BITS; row++) begin
        @(negedge clk);
        syndrome_we   = 1'b1;
        syndrome_addr = REF_ROW_WIDTH'(row);
        syndrome_data = REF_SYNDROME[row] ^ (flip_first && (row == 0));
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
      if (!busy) $fatal(1, "project residual checker did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (residual_zero != expect_zero) $fatal(1, "project residual zero mismatch");
      if (residual_weight != (expect_zero ? 0 : 1)) $fatal(1, "project residual weight mismatch");
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

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    for (int idx = 0; idx < (REF_BLOCKS * REF_SECRET_WEIGHT); idx++) begin
      @(negedge clk);
      h_we = 1'b1;
      h_block = BLOCK_W'(idx / REF_SECRET_WEIGHT);
      h_diag = DIAG_W'(idx % REF_SECRET_WEIGHT);
      h_index = REF_H_SUPPORT[REF_ROW_WIDTH*idx+:REF_ROW_WIDTH];
    end
    @(negedge clk);
    h_we = 1'b0;

    load_syndrome(1'b0);
    run_case(1'b1, zero_latency);
    load_syndrome(1'b1);
    run_case(1'b0, nonzero_latency);
    if (zero_latency != nonzero_latency) $fatal(1, "project residual-dependent latency");
    if (zero_latency != EXPECTED_CYCLES) $fatal(1, "project residual cycle mismatch");

    $display("tb_trike_decoder_residual_reference PASS cycles=%0d", zero_latency);
    $finish;
  end

  initial begin
    repeat (6000000) @(posedge clk);
    $fatal(1, "tb_trike_decoder_residual_reference timeout");
  end

endmodule
