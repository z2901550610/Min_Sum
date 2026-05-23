`timescale 1ns / 1ps

module tb_ram_i_idx_loader;
  import bike_pkg::*;

  logic                     clk;
  logic                     rst_n;
  logic                     start;
  logic                     valid;
  logic [    ROW_IDX_W-1:0] row_idx_global[0:L-1];
  logic                     ready;
  logic                     busy;
  logic                     done;
  logic [    H_BLOCK_W-1:0] request_h_block_idx;
  logic [  ENTRY_POS_W-1:0] request_entry_pos;
  logic                     lane_we[0:L-1];
  logic [    H_BLOCK_W-1:0] write_h_block_idx;
  logic [  ENTRY_POS_W-1:0] write_entry_idx;
  logic [    I_ENTRY_W-1:0] entry_wdata[0:L-1];
  logic                     count_we[0:L-1];
  logic [GROUP_COUNT_W-1:0] count_wdata[0:L-1];

  ram_i_idx_loader dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_valid(valid),
      .i_row_idx_global(row_idx_global),
      .o_ready(ready),
      .o_busy(busy),
      .o_done(done),
      .o_request_h_block_idx(request_h_block_idx),
      .o_request_entry_pos(request_entry_pos),
      .o_lane_we(lane_we),
      .o_write_h_block_idx(write_h_block_idx),
      .o_write_entry_idx(write_entry_idx),
      .o_entry_wdata(entry_wdata),
      .o_count_we(count_we),
      .o_count_wdata(count_wdata)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic int lane_count(input int lane_idx);
    begin
      lane_count = (W > lane_idx) ? ((W + L - 1 - lane_idx) >> LANE_IDX_W) : 0;
    end
  endfunction

  task automatic check_cycle(input int h_block_idx_i, input int entry_pos_i);
    int one_idx;
    begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        row_idx_global[lane_idx] = ROW_IDX_W'(h_block_idx_i * 16 + entry_pos_i * L + lane_idx);
      end
      valid = 1'b1;
      #1;
      if (!ready || !busy) $fatal(1, "loader should be ready while busy");
      if (request_h_block_idx != H_BLOCK_W'(h_block_idx_i)) begin
        $fatal(1, "request h_block mismatch got=%0d exp=%0d", request_h_block_idx, h_block_idx_i);
      end
      if (request_entry_pos != ENTRY_POS_W'(entry_pos_i)) begin
        $fatal(1, "request entry_pos mismatch got=%0d exp=%0d", request_entry_pos, entry_pos_i);
      end
      if (write_h_block_idx != H_BLOCK_W'(h_block_idx_i)) $fatal(1, "write h_block mismatch");
      if (write_entry_idx != ENTRY_POS_W'(entry_pos_i)) $fatal(1, "write entry_pos mismatch");
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        one_idx = entry_pos_i * L + lane_idx;
        if (lane_we[lane_idx] != (one_idx < W)) begin
          $fatal(1, "lane_we lane=%0d got=%0b exp=%0b", lane_idx, lane_we[lane_idx], one_idx < W);
        end
        if (one_idx < W) begin
          if (entry_wdata[lane_idx] != {ONE_IDX_W'(one_idx), row_idx_global[lane_idx]}) begin
            $fatal(1, "entry_wdata lane=%0d mismatch", lane_idx);
          end
        end
        if (count_we[lane_idx] != (entry_pos_i == (RAM_LANE_DEPTH - 1))) begin
          $fatal(1, "count_we lane=%0d mismatch", lane_idx);
        end
        if (count_wdata[lane_idx] != GROUP_COUNT_W'(lane_count(lane_idx))) begin
          $fatal(1, "count_wdata lane=%0d got=%0d exp=%0d", lane_idx, count_wdata[lane_idx],
                 lane_count(lane_idx));
        end
      end
      @(posedge clk);
      #1;
    end
  endtask

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    valid = 1'b0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      row_idx_global[lane_idx] = '0;
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    #1;

    for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
        check_cycle(h_block_idx, entry_pos);
      end
    end

    valid = 1'b0;
    #1;
    if (!done) $fatal(1, "loader did not pulse done");
    if (busy || ready) $fatal(1, "loader should be idle after final cycle");

    @(posedge clk);
    #1;
    if (done) $fatal(1, "done should be a one-cycle pulse");

    $display("tb_ram_i_idx_loader PASS");
    $finish;
  end
endmodule
