`timescale 1ns/1ps

module tb_h_shift;
  import bike_pkg::*;

  logic [I_ENTRY_W-1:0] row_group_entries_in [0:L-1][0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] row_group_count_in [0:L-1];
  logic [I_ENTRY_W-1:0] row_group_entries_out [0:L-1][0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] row_group_count_out [0:L-1];
  integer row_group_idx;
  integer edge_idx;

  h_shift dut (
    .i_row_group_entries(row_group_entries_in),
    .i_row_group_count(row_group_count_in),
    .o_row_group_entries(row_group_entries_out),
    .o_row_group_count(row_group_count_out)
  );

  initial begin
    for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
      row_group_count_in[row_group_idx] = '0;
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        row_group_entries_in[row_group_idx][edge_idx] = '0;
      end
    end

    row_group_count_in[0] = ROW_GROUP_COUNT_W'(2);
    row_group_count_in[1] = ROW_GROUP_COUNT_W'(1);
    row_group_entries_in[0][0] = {EDGE_W'(0), ROW_W'(3)};
    row_group_entries_in[0][1] = {EDGE_W'(2), ROW_W'(1)};
    row_group_entries_in[1][0] = {EDGE_W'(1), ROW_W'(3)};

    #1;
    if (row_group_count_out[0] != 2 || row_group_count_out[1] != 1) $fatal(1, "h_shift output counts mismatch");
    if (row_group_entries_out[0][0] != {EDGE_W'(2), ROW_W'(2)}) $fatal(1, "h_shift row_group0 first entry mismatch");
    if (row_group_entries_out[0][1] != {EDGE_W'(1), ROW_W'(0)}) $fatal(1, "h_shift wrapped entry mismatch");
    if (row_group_entries_out[1][0] != {EDGE_W'(0), ROW_W'(0)}) $fatal(1, "h_shift crossing entry mismatch");

    for (row_group_idx = 0; row_group_idx < L; row_group_idx++) begin
      row_group_count_in[row_group_idx] = '0;
      for (edge_idx = 0; edge_idx < W; edge_idx++) begin
        row_group_entries_in[row_group_idx][edge_idx] = '0;
      end
    end

    row_group_count_in[0] = ROW_GROUP_COUNT_W'(1);
    row_group_count_in[1] = ROW_GROUP_COUNT_W'(2);
    row_group_entries_in[0][0] = {EDGE_W'(1), ROW_W'(ROW_SEG_SIZE - 1)};
    row_group_entries_in[1][0] = {EDGE_W'(0), ROW_W'(R - ROW_SEG_SIZE - 2)};
    row_group_entries_in[1][1] = {EDGE_W'(2), ROW_W'(R - ROW_SEG_SIZE - 1)};

    #1;
    if (row_group_count_out[0] != 1 || row_group_count_out[1] != 2) $fatal(1, "h_shift second output counts mismatch");
    if (row_group_entries_out[0][0] != {EDGE_W'(2), ROW_W'(0)}) $fatal(1, "h_shift second wrapped edge index mismatch");
    if (row_group_entries_out[1][0] != {EDGE_W'(1), ROW_W'(0)}) $fatal(1, "h_shift second crossing edge index mismatch");
    if (row_group_entries_out[1][1] != {EDGE_W'(0), ROW_W'(R - ROW_SEG_SIZE - 1)}) $fatal(1, "h_shift second row_group1 advance mismatch");

    $display("tb_h_shift PASS");
    $finish;
  end
endmodule
