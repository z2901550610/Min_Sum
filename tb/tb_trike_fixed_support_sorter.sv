`timescale 1ns / 1ps

module tb_trike_fixed_support_sorter;
  localparam int R_BITS = 13;
  localparam int BLOCKS = 3;
  localparam int WEIGHT = 4;
  localparam int TOTAL = BLOCKS * WEIGHT;
  localparam int ROW_W = $clog2(R_BITS);
  localparam int BLOCK_W = $clog2(BLOCKS);
  localparam int DIAG_W = $clog2(WEIGHT);

  logic                 clk;
  logic                 rst_n;
  logic                 start;
  logic                 valid;
  logic   [  ROW_W-1:0] index_in;
  logic                 ready_in;
  logic                 valid_out;
  logic   [BLOCK_W-1:0] block_out;
  logic   [ DIAG_W-1:0] diag_out;
  logic   [  ROW_W-1:0] index_out;
  logic                 ready_out;
  logic                 busy;
  logic                 done;

  logic   [  ROW_W-1:0] input_data[0:2*TOTAL-1];
  logic   [  ROW_W-1:0] expected_data[0:2*TOTAL-1];
  integer               case_base;
  integer               send_count;
  integer               receive_count;
  integer               cycle_count;

  trike_fixed_support_sorter #(
      .R_BITS(R_BITS),
      .BLOCKS(BLOCKS),
      .WEIGHT(WEIGHT)
  ) dut (
      .i_clk      (clk),
      .i_rst_n    (rst_n),
      .i_start    (start),
      .i_valid    (valid),
      .i_index    (index_in),
      .o_ready    (ready_in),
      .o_valid    (valid_out),
      .o_block_idx(block_out),
      .o_diag_idx (diag_out),
      .o_index    (index_out),
      .i_ready    (ready_out),
      .o_busy     (busy),
      .o_done     (done)
  );

  always #1 clk = ~clk;

  always_comb begin
    valid = (send_count < TOTAL);
    index_in = input_data[case_base+((send_count<TOTAL)?send_count : 0)];
    ready_out = 1'b1;
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      send_count <= 0;
      receive_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        send_count <= 0;
        receive_count <= 0;
      end else begin
        if (valid && ready_in) send_count <= send_count + 1;
        if (valid_out && ready_out) begin
          if (block_out != BLOCK_W'(receive_count / WEIGHT)) $fatal(1, "output block mismatch");
          if (diag_out != DIAG_W'(receive_count % WEIGHT)) $fatal(1, "output diagonal mismatch");
          if (index_out != expected_data[case_base+receive_count])
            $fatal(1, "sorted coordinate mismatch");
          receive_count <= receive_count + 1;
        end
      end
    end
  end

  task automatic run_case(input integer selected_base, output integer latency);
    integer start_cycle;
    begin
      case_base = selected_base;
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "sorter did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (send_count != TOTAL) $fatal(1, "input count mismatch");
      if (receive_count != TOTAL) $fatal(1, "output count mismatch");
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    case_base = 0;

    input_data[0:11] = '{9, 2, 7, 1, 3, 11, 0, 5, 8, 4, 6, 2};
    expected_data[0:11] = '{1, 2, 7, 9, 0, 3, 5, 11, 2, 4, 6, 8};
    input_data[12:23] = '{0, 3, 8, 12, 11, 7, 4, 1, 2, 5, 6, 9};
    expected_data[12:23] = '{0, 3, 8, 12, 1, 4, 7, 11, 2, 5, 6, 9};

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    run_case(0, latency_a);
    run_case(TOTAL, latency_b);
    if (latency_a != latency_b) $fatal(1, "data-dependent sorter latency");
    if (latency_a != 43) $fatal(1, "unexpected fixed sorter latency");

    $display("tb_trike_fixed_support_sorter PASS cycles=%0d", latency_a);
    $finish;
  end

endmodule
