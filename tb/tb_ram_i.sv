`timescale 1ns/1ps

module tb_ram_i;
  import bike_pkg::*;

  logic clk;
  logic rst_n;
  logic clear_en;
  logic en;
  logic we;
  logic [H_BLOCK_W-1:0] h_block_idx;
  logic [EDGE_W-1:0] row_group_pos_addr;
  logic [I_ENTRY_W-1:0] din;
  logic count_we;
  logic [ROW_GROUP_COUNT_W-1:0] count_din;
  logic replace_en;
  logic [H_BLOCK_W-1:0] replace_h_block_idx;
  logic [I_ENTRY_W-1:0] replace_entries [0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] replace_count;
  logic [I_ENTRY_W-1:0] dout;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [ROW_GROUP_COUNT_W-1:0] count;
  logic [I_ENTRY_W-1:0] column_entries [0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] debug_entries [0:N0-1][0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] debug_count [0:N0-1];
  integer row_group_pos_idx;

  ram_i dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(clear_en),
    .i_en(en),
    .i_we(we),
    .i_h_block_idx(h_block_idx),
    .i_row_group_pos_addr(row_group_pos_addr),
    .i_wdata(din),
    .i_row_group_count_we(count_we),
    .i_row_group_count_wdata(count_din),
    .i_column_replace_en(replace_en),
    .i_column_replace_h_block_idx(replace_h_block_idx),
    .i_column_entries_wdata(replace_entries),
    .i_column_row_group_count_wdata(replace_count),
    .o_rdata(dout),
    .o_row_group_count(count),
    .o_column_entries(column_entries),
    .o_debug_entries(debug_entries),
    .o_debug_row_group_count(debug_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    clear_en = 1'b0;
    en = 1'b0;
    we = 1'b0;
    h_block_idx = '0;
    row_group_pos_addr = '0;
    din = '0;
    count_we = 1'b0;
    count_din = '0;
    replace_en = 1'b0;
    replace_h_block_idx = '0;
    replace_count = '0;
    for (row_group_pos_idx = 0; row_group_pos_idx < W; row_group_pos_idx++) begin
      replace_entries[row_group_pos_idx] = '0;
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (debug_count[0] != 0) $fatal(1, "ram_i reset should clear count");

    replace_h_block_idx = H_BLOCK_W'(1 % N0);
    replace_count = ROW_GROUP_COUNT_W'(2);
    replace_entries[0] = {EDGE_W'(0), ROW_W'(1)};
    replace_entries[1] = {EDGE_W'(2), ROW_W'(3)};
    replace_en = 1'b1;
    @(posedge clk);
    #1;
    replace_en = 1'b0;
    h_block_idx = replace_h_block_idx;
    #1;
    if (debug_count[replace_h_block_idx] != ROW_GROUP_COUNT_W'(2)) $fatal(1, "ram_i replace count mismatch");
    if (debug_entries[replace_h_block_idx][0] != {EDGE_W'(0), ROW_W'(1)}) $fatal(1, "ram_i replace entry 0 mismatch");
    if (count != debug_count[replace_h_block_idx]) $fatal(1, "ram_i functional count view mismatch");
    if (column_entries[1] != debug_entries[replace_h_block_idx][1]) $fatal(1, "ram_i functional column view mismatch");

    replace_count = ROW_GROUP_COUNT_W'(1);
    replace_entries[0] = {EDGE_W'(2), ROW_W'(0)};
    replace_entries[1] = '0;
    replace_entries[2] = '0;
    replace_en = 1'b1;
    @(posedge clk);
    #1;
    replace_en = 1'b0;
    if (debug_count[replace_h_block_idx] != ROW_GROUP_COUNT_W'(1)) $fatal(1, "ram_i shifted bulk count mismatch");
    if (debug_entries[replace_h_block_idx][0] != {EDGE_W'(2), ROW_W'(0)}) $fatal(1, "ram_i shifted bulk entry mismatch");

    h_block_idx = '0;
    row_group_pos_addr = EDGE_W'(1);
    din = {EDGE_W'(1), ROW_W'(4)};
    count_din = ROW_GROUP_COUNT_W'(1);
    en = 1'b1;
    we = 1'b1;
    count_we = 1'b1;
    @(posedge clk);
    #1;
    we = 1'b0;
    count_we = 1'b0;
    if (debug_count[0] != ROW_GROUP_COUNT_W'(1)) $fatal(1, "ram_i single-port count write mismatch");

    @(posedge clk);
    #1;
    if (dout != {EDGE_W'(1), ROW_W'(4)}) $fatal(1, "ram_i single-port read mismatch");

    clear_en = 1'b1;
    en = 1'b0;
    @(posedge clk);
    #1;
    clear_en = 1'b0;
    if (debug_count[0] != 0) $fatal(1, "ram_i clear should reset count");

    $display("tb_ram_i PASS");
    $finish;
  end
endmodule
