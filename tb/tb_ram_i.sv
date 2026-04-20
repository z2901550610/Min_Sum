`timescale 1ns/1ps

module tb_ram_i;
  import bike_pkg::*;

  logic clk;
  logic rst_n;
  logic clear_en;
  logic [BANK_W-1:0] rd_bank;
  logic [I_ENTRY_W-1:0] rd_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] rd_lane_count [0:L-1];
  logic we;
  logic [BANK_W-1:0] wr_bank;
  logic [I_ENTRY_W-1:0] wr_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] wr_lane_count [0:L-1];
  integer lane_idx;
  integer slot_idx;

  ram_i dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(clear_en),
    .i_rd_bank(rd_bank),
    .o_rd_lane_entries(rd_lane_entries),
    .o_rd_lane_count(rd_lane_count),
    .i_we(we),
    .i_wr_bank(wr_bank),
    .i_wr_lane_entries(wr_lane_entries),
    .i_wr_lane_count(wr_lane_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    clear_en = 1'b0;
    rd_bank = '0;
    we = 1'b0;
    wr_bank = '0;
    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      wr_lane_count[lane_idx] = '0;
      for (slot_idx = 0; slot_idx < W; slot_idx++) begin
        wr_lane_entries[lane_idx][slot_idx] = '0;
      end
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (rd_lane_count[0] != 0 || rd_lane_count[1] != 0) $fatal(1, "ram_i reset should clear counts");

    wr_bank = BANK_W'(1);
    wr_lane_count[0] = LANE_COUNT_W'(2);
    wr_lane_count[1] = LANE_COUNT_W'(1);
    wr_lane_entries[0][0] = {EDGE_W'(0), ROW_W'(1)};
    wr_lane_entries[0][1] = {EDGE_W'(2), ROW_W'(3)};
    wr_lane_entries[1][0] = {EDGE_W'(1), ROW_W'(0)};
    we = 1'b1;
    @(posedge clk);
    we = 1'b0;
    @(posedge clk);

    rd_bank = BANK_W'(1);
    #1;
    if (^dut.count_mem[1][0] === 1'bx || ^dut.count_mem[1][1] === 1'bx) $fatal(1, "ram_i write path produced unknown counts");

    clear_en = 1'b1;
    @(posedge clk);
    clear_en = 1'b0;
    #1;
    if (rd_lane_count[0] != 0 || rd_lane_count[1] != 0) $fatal(1, "ram_i clear should reset counts");

    $display("tb_ram_i PASS");
    $finish;
  end
endmodule
