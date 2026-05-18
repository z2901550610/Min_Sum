`timescale 1ns / 1ps

module tb_ram_i;
  import bike_pkg::*;

  logic                     clk;
  logic                     rst_n;
  logic                     we;
  logic [    H_BLOCK_W-1:0] read_h_block_idx;
  logic [    H_BLOCK_W-1:0] write_h_block_idx;
  logic [  ENTRY_POS_W-1:0] read_entry_idx;
  logic [  ENTRY_POS_W-1:0] write_entry_idx;
  logic [    I_ENTRY_W-1:0] entry_wdata;
  logic                     count_we;
  logic [GROUP_COUNT_W-1:0] count_wdata;
  logic [    I_ENTRY_W-1:0] entry_rdata;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [GROUP_COUNT_W-1:0] count;
  /* verilator lint_on UNUSEDSIGNAL */
  logic [    I_ENTRY_W-1:0] debug_list_entries[0:N0-1] [0:RAM_LANE_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] debug_counts[0:N0-1];

  ram_i #(
      .INIT_HEX_STEM("rtl/generated/ram_i0")
  ) dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_we(we),
      .i_read_h_block_idx(read_h_block_idx),
      .i_write_h_block_idx(write_h_block_idx),
      .i_read_entry_idx(read_entry_idx),
      .i_write_entry_idx(write_entry_idx),
      .i_entry_wdata(entry_wdata),
      .i_count_we(count_we),
      .i_count_wdata(count_wdata),
      .o_entry_rdata(entry_rdata),
      .o_count(count),
      .o_debug_list_entries(debug_list_entries),
      .o_debug_counts(debug_counts)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    we = 1'b0;
    read_h_block_idx = '0;
    write_h_block_idx = '0;
    read_entry_idx = '0;
    write_entry_idx = '0;
    entry_wdata = '0;
    count_we = 1'b0;
    count_wdata = '0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    #1;

    // After reset, $readmemh-initialised memory should retain its data.
    // For test params, ram_i0: h_block 0 count=1, h_block 1 count=2.
    if (debug_counts[0] != GROUP_COUNT_W'(1))
      $fatal(1, "ram_i init count h_block 0 mismatch: %0d", debug_counts[0]);
    if (debug_counts[1] != GROUP_COUNT_W'(2))
      $fatal(1, "ram_i init count h_block 1 mismatch: %0d", debug_counts[1]);

    // Read back via functional port.
    read_h_block_idx = '0;
    read_entry_idx   = '0;
    @(posedge clk);
    #1;
    if (count != debug_counts[0]) $fatal(1, "ram_i functional count view mismatch");
    if (entry_rdata != debug_list_entries[0][0]) $fatal(1, "ram_i functional entry view mismatch");

    // Single-entry write / read.
    read_h_block_idx = '0;
    write_h_block_idx = '0;
    read_entry_idx = ENTRY_POS_W'(1);
    write_entry_idx = ENTRY_POS_W'(1);
    entry_wdata = {ONE_IDX_W'(1), ROW_GROUP_W'(2)};
    count_wdata = GROUP_COUNT_W'(1);
    we = 1'b1;
    count_we = 1'b1;
    @(posedge clk);
    #1;
    we = 1'b0;
    count_we = 1'b0;
    if (debug_counts[0] != GROUP_COUNT_W'(1)) $fatal(1, "ram_i single-port count write mismatch");

    @(posedge clk);
    #1;
    if (entry_rdata != {ONE_IDX_W'(1), ROW_GROUP_W'(2)})
      $fatal(1, "ram_i single-port read mismatch");

    // Reset clears read data register only, not the memory.
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    #1;
    if (debug_counts[0] != GROUP_COUNT_W'(1))
      $fatal(1, "ram_i memory should persist through reset");

    $display("tb_ram_i PASS");
    $finish;
  end
endmodule
