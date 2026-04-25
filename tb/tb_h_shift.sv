`timescale 1ns/1ps

module tb_h_shift;
  import bike_pkg::*;

  logic [I_ENTRY_W-1:0] group0_entries_in [0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] group0_count_in;
  logic [I_ENTRY_W-1:0] group1_entries_in [0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] group1_count_in;
  logic [I_ENTRY_W-1:0] group0_entries_out [0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] group0_count_out;
  logic [I_ENTRY_W-1:0] group1_entries_out [0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] group1_count_out;
  integer edge_idx;

  h_shift dut (
    .i_group0_entries(group0_entries_in),
    .i_group0_count(group0_count_in),
    .i_group1_entries(group1_entries_in),
    .i_group1_count(group1_count_in),
    .o_group0_entries(group0_entries_out),
    .o_group0_count(group0_count_out),
    .o_group1_entries(group1_entries_out),
    .o_group1_count(group1_count_out)
  );

  initial begin
    group0_count_in = '0;
    group1_count_in = '0;
    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      group0_entries_in[edge_idx] = '0;
      group1_entries_in[edge_idx] = '0;
    end

    group0_count_in = ROW_GROUP_COUNT_W'(2);
    group1_count_in = ROW_GROUP_COUNT_W'(1);
    group0_entries_in[0] = {EDGE_W'(0), ROW_W'(3)};  // global row 6 -> 7
    group0_entries_in[1] = {EDGE_W'(2), ROW_W'(1)};  // global row 2 -> 3
    group1_entries_in[0] = {EDGE_W'(1), ROW_W'(3)};  // global row 7 -> 0

    #1;
    if (group0_count_out != 1 || group1_count_out != 2) $fatal(1, "h_shift output counts mismatch");
    if (group0_entries_out[0] != {EDGE_W'(1), ROW_W'(0)}) $fatal(1, "h_shift wrapped even-row entry mismatch");
    if (group1_entries_out[0] != {EDGE_W'(0), ROW_W'(3)}) $fatal(1, "h_shift odd-row entry 0 mismatch");
    if (group1_entries_out[1] != {EDGE_W'(2), ROW_W'(1)}) $fatal(1, "h_shift odd-row entry 1 mismatch");

    group0_count_in = '0;
    group1_count_in = '0;
    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      group0_entries_in[edge_idx] = '0;
      group1_entries_in[edge_idx] = '0;
    end

    group0_count_in = ROW_GROUP_COUNT_W'(1);
    group1_count_in = ROW_GROUP_COUNT_W'(2);
    group0_entries_in[0] = {EDGE_W'(1), ROW_W'(0)};  // global row 0 -> 1
    group1_entries_in[0] = {EDGE_W'(0), ROW_W'(2)};  // global row 5 -> 6
    group1_entries_in[1] = {EDGE_W'(2), ROW_W'(3)};  // global row 7 -> 0

    #1;
    if (group0_count_out != 2 || group1_count_out != 1) $fatal(1, "h_shift second output counts mismatch");
    if (group0_entries_out[0] != {EDGE_W'(0), ROW_W'(3)}) $fatal(1, "h_shift second even-row entry 0 mismatch");
    if (group0_entries_out[1] != {EDGE_W'(2), ROW_W'(0)}) $fatal(1, "h_shift second wrapped even-row entry mismatch");
    if (group1_entries_out[0] != {EDGE_W'(1), ROW_W'(0)}) $fatal(1, "h_shift second odd-row entry mismatch");

    $display("tb_h_shift PASS");
    $finish;
  end
endmodule
