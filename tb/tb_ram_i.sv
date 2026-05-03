`timescale 1ns/1ps

module tb_ram_i;
  import bike_pkg::*;

  logic clk;
  logic rst_n;
  logic en;
  logic we;
  logic [H_BLOCK_W-1:0] hblk_idx;
  logic [ONE_IDX_W-1:0] entry_idx;
  logic [I_ENTRY_W-1:0] entry_wdata;
  logic count_we;
  logic [GROUP_COUNT_W-1:0] count_wdata;
  logic list_load_en;
  logic [H_BLOCK_W-1:0] list_load_hblk_idx;
  logic [I_ENTRY_W-1:0] list_load_entries [0:W-1];
  logic [GROUP_COUNT_W-1:0] list_load_count;
  logic [I_ENTRY_W-1:0] entry_rdata;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [GROUP_COUNT_W-1:0] count;
  logic [I_ENTRY_W-1:0] list_entries [0:W-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] debug_list_entries [0:N0-1][0:W-1];
  logic [GROUP_COUNT_W-1:0] debug_counts [0:N0-1];
  integer entry_idx_local;

  ram_i dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_en(en),
    .i_we(we),
    .i_hblk_idx(hblk_idx),
    .i_entry_idx(entry_idx),
    .i_entry_wdata(entry_wdata),
    .i_count_we(count_we),
    .i_count_wdata(count_wdata),
    .i_list_load_en(list_load_en),
    .i_list_load_hblk_idx(list_load_hblk_idx),
    .i_list_load_entries(list_load_entries),
    .i_list_load_count(list_load_count),
    .o_entry_rdata(entry_rdata),
    .o_count(count),
    .o_list_entries(list_entries),
    .o_debug_list_entries(debug_list_entries),
    .o_debug_counts(debug_counts)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    en = 1'b0;
    we = 1'b0;
    hblk_idx = '0;
    entry_idx = '0;
    entry_wdata = '0;
    count_we = 1'b0;
    count_wdata = '0;
    list_load_en = 1'b0;
    list_load_hblk_idx = '0;
    list_load_count = '0;
    for (entry_idx_local = 0; entry_idx_local < W; entry_idx_local++) begin
      list_load_entries[entry_idx_local] = '0;
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (debug_counts[0] != 0) $fatal(1, "ram_i reset should zero count");

    list_load_hblk_idx = H_BLOCK_W'(1 % N0);
    list_load_count = GROUP_COUNT_W'(2);
    list_load_entries[0] = {ONE_IDX_W'(0), ROW_IDX_W'(0)};
    list_load_entries[1] = {ONE_IDX_W'(2), ROW_IDX_W'(1)};
    list_load_en = 1'b1;
    @(posedge clk);
    #1;
    list_load_en = 1'b0;
    hblk_idx = list_load_hblk_idx;
    #1;
    if (debug_counts[list_load_hblk_idx] != GROUP_COUNT_W'(2)) $fatal(1, "ram_i list_load count mismatch");
    if (debug_list_entries[list_load_hblk_idx][0] != {ONE_IDX_W'(0), ROW_IDX_W'(0)}) $fatal(1, "ram_i list_load entry 0 mismatch");
    if (count != debug_counts[list_load_hblk_idx]) $fatal(1, "ram_i functional count view mismatch");
    if (list_entries[1] != debug_list_entries[list_load_hblk_idx][1]) $fatal(1, "ram_i functional list view mismatch");

    list_load_count = GROUP_COUNT_W'(1);
    list_load_entries[0] = {ONE_IDX_W'(2), ROW_IDX_W'(2)};
    list_load_entries[1] = '0;
    list_load_entries[2] = '0;
    list_load_en = 1'b1;
    @(posedge clk);
    #1;
    list_load_en = 1'b0;
    if (debug_counts[list_load_hblk_idx] != GROUP_COUNT_W'(1)) $fatal(1, "ram_i shifted bulk count mismatch");
    if (debug_list_entries[list_load_hblk_idx][0] != {ONE_IDX_W'(2), ROW_IDX_W'(2)}) $fatal(1, "ram_i shifted bulk entry mismatch");

    hblk_idx = '0;
    entry_idx = ONE_IDX_W'(1);
    entry_wdata = {ONE_IDX_W'(1), ROW_IDX_W'(2)};
    count_wdata = GROUP_COUNT_W'(1);
    en = 1'b1;
    we = 1'b1;
    count_we = 1'b1;
    @(posedge clk);
    #1;
    we = 1'b0;
    count_we = 1'b0;
    if (debug_counts[0] != GROUP_COUNT_W'(1)) $fatal(1, "ram_i single-port count write mismatch");

    @(posedge clk);
    #1;
    if (entry_rdata != {ONE_IDX_W'(1), ROW_IDX_W'(2)}) $fatal(1, "ram_i single-port read mismatch");

    rst_n = 1'b0;
    en = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    #1;
    if (debug_counts[0] != 0) $fatal(1, "ram_i reset should reset count");

    $display("tb_ram_i PASS");
    $finish;
  end
endmodule
