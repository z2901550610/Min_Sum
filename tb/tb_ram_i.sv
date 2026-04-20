`timescale 1ns/1ps

module tb_ram_i;
  import bike_pkg::*;

  logic clk;
  logic rst_n;
  logic clear_en;
  logic en;
  logic we;
  logic [BANK_W-1:0] bank;
  logic [EDGE_W-1:0] addr;
  logic [I_ENTRY_W-1:0] din;
  logic count_we;
  logic [LANE_COUNT_W-1:0] count_din;
  logic load;
  logic [BANK_W-1:0] load_bank;
  logic [I_ENTRY_W-1:0] load_entries [0:W-1];
  logic [LANE_COUNT_W-1:0] load_count;
  logic [I_ENTRY_W-1:0] dout;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [LANE_COUNT_W-1:0] count;
  /* verilator lint_on UNUSEDSIGNAL */
  logic [I_ENTRY_W-1:0] debug_entries [0:N0-1][0:W-1];
  logic [LANE_COUNT_W-1:0] debug_count [0:N0-1];
  integer slot_idx;

  ram_i dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(clear_en),
    .i_en(en),
    .i_we(we),
    .i_bank(bank),
    .i_addr(addr),
    .i_din(din),
    .i_count_we(count_we),
    .i_count_din(count_din),
    .i_load(load),
    .i_load_bank(load_bank),
    .i_load_entries(load_entries),
    .i_load_count(load_count),
    .o_dout(dout),
    .o_count(count),
    .o_debug_entries(debug_entries),
    .o_debug_count(debug_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    clear_en = 1'b0;
    en = 1'b0;
    we = 1'b0;
    bank = '0;
    addr = '0;
    din = '0;
    count_we = 1'b0;
    count_din = '0;
    load = 1'b0;
    load_bank = '0;
    load_count = '0;
    for (slot_idx = 0; slot_idx < W; slot_idx++) begin
      load_entries[slot_idx] = '0;
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (debug_count[0] != 0) $fatal(1, "ram_i reset should clear count");

    load_bank = BANK_W'(1 % N0);
    load_count = LANE_COUNT_W'(2);
    load_entries[0] = {EDGE_W'(0), ROW_W'(1)};
    load_entries[1] = {EDGE_W'(2), ROW_W'(3)};
    load = 1'b1;
    @(posedge clk);
    #1;
    load = 1'b0;
    if (debug_count[load_bank] != LANE_COUNT_W'(2)) $fatal(1, "ram_i load count mismatch");
    if (debug_entries[load_bank][0] != {EDGE_W'(0), ROW_W'(1)}) $fatal(1, "ram_i load entry 0 mismatch");

    bank = '0;
    addr = EDGE_W'(1);
    din = {EDGE_W'(1), ROW_W'(4)};
    count_din = LANE_COUNT_W'(1);
    en = 1'b1;
    we = 1'b1;
    count_we = 1'b1;
    @(posedge clk);
    #1;
    we = 1'b0;
    count_we = 1'b0;
    if (debug_count[0] != LANE_COUNT_W'(1)) $fatal(1, "ram_i single-port count write mismatch");

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
