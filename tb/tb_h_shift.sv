`timescale 1ns/1ps

module tb_h_shift;
  import bike_pkg::*;

  logic [ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group_in [0:L-1];
  logic [GROUP_IDX_W-1:0] ram_i_target_idx_out [0:L-1];
  logic [ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group_out [0:L-1];

  localparam int ODD_R = 9;
  localparam int ODD_ROW_IDX_W = (ODD_R > 1) ? $clog2(ODD_R) : 1;

  logic [ODD_ROW_IDX_W-GROUP_IDX_W-1:0] odd_row_idx_group_in [0:L-1];
  logic [GROUP_IDX_W-1:0] odd_ram_i_target_idx_out [0:L-1];
  logic [ODD_ROW_IDX_W-GROUP_IDX_W-1:0] odd_row_idx_group_out [0:L-1];

  h_shift #(
    .R(R),
    .L(L),
    .ROW_IDX_W(ROW_IDX_W),
    .GROUP_IDX_W(GROUP_IDX_W)
  ) dut (
    .i_row_idx_group(row_idx_group_in),
    .o_ram_i_target_idx(ram_i_target_idx_out),
    .o_row_idx_group(row_idx_group_out)
  );

  h_shift #(
    .R(ODD_R),
    .L(L),
    .ROW_IDX_W(ODD_ROW_IDX_W),
    .GROUP_IDX_W(GROUP_IDX_W)
  ) odd_r_dut (
    .i_row_idx_group(odd_row_idx_group_in),
    .o_ram_i_target_idx(odd_ram_i_target_idx_out),
    .o_row_idx_group(odd_row_idx_group_out)
  );

  function automatic int row_global_from_group(
    input int group_idx_i,
    input int row_idx_group_i
  );
    begin
      row_global_from_group = (row_idx_group_i * L) + group_idx_i;
    end
  endfunction

  function automatic int shifted_row_global(input int row_idx_global_i);
    begin
      shifted_row_global = (row_idx_global_i == (R - 1)) ? 0 : (row_idx_global_i + 1);
    end
  endfunction

  function automatic logic [GROUP_IDX_W-1:0] expected_target_idx(
    input int group_idx_i,
    input int row_idx_group_i
  );
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_group(group_idx_i, row_idx_group_i));
      expected_target_idx = GROUP_IDX_W'(next_row_global % L);
    end
  endfunction

  function automatic logic [ROW_IDX_W-GROUP_IDX_W-1:0] expected_row_idx_group(
    input int group_idx_i,
    input int row_idx_group_i
  );
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_group(group_idx_i, row_idx_group_i));
      expected_row_idx_group = (ROW_IDX_W-GROUP_IDX_W)'(next_row_global / L);
    end
  endfunction

  task automatic check_shift(
    input logic [ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group0_i,
    input logic [GROUP_IDX_W-1:0] expected_target0_i,
    input logic [ROW_IDX_W-GROUP_IDX_W-1:0] expected_row_idx_group0_i,
    input logic [ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group1_i,
    input logic [GROUP_IDX_W-1:0] expected_target1_i,
    input logic [ROW_IDX_W-GROUP_IDX_W-1:0] expected_row_idx_group1_i
  );
    begin
      row_idx_group_in[0] = (ROW_IDX_W-GROUP_IDX_W)'(row_idx_group0_i);
      row_idx_group_in[1] = (ROW_IDX_W-GROUP_IDX_W)'(row_idx_group1_i);
      #1;
      if (ram_i_target_idx_out[0] != expected_target0_i) begin
        $fatal(1, "h_shift target0 mismatch: got %0d exp %0d",
               ram_i_target_idx_out[0], expected_target0_i);
      end
      if (row_idx_group_out[0] != expected_row_idx_group0_i) begin
        $fatal(1, "h_shift row_idx_group0 mismatch: got %0d exp %0d",
               row_idx_group_out[0], expected_row_idx_group0_i);
      end
      if (ram_i_target_idx_out[1] != expected_target1_i) begin
        $fatal(1, "h_shift target1 mismatch: got %0d exp %0d",
               ram_i_target_idx_out[1], expected_target1_i);
      end
      if (row_idx_group_out[1] != expected_row_idx_group1_i) begin
        $fatal(1, "h_shift row_idx_group1 mismatch: got %0d exp %0d",
               row_idx_group_out[1], expected_row_idx_group1_i);
      end
    end
  endtask

  task automatic check_group_pair(
    input int row_idx_group0_i,
    input int row_idx_group1_i
  );
    begin
      check_shift(
        (ROW_IDX_W-GROUP_IDX_W)'(row_idx_group0_i),
        expected_target_idx(0, row_idx_group0_i),
        expected_row_idx_group(0, row_idx_group0_i),
        (ROW_IDX_W-GROUP_IDX_W)'(row_idx_group1_i),
        expected_target_idx(1, row_idx_group1_i),
        expected_row_idx_group(1, row_idx_group1_i)
      );
    end
  endtask

  task automatic check_odd_r_same_target(
    input logic [ODD_ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group0_i,
    input int expected_row_idx_group0_i,
    input logic [ODD_ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group1_i,
    input int expected_row_idx_group1_i
  );
    begin
      odd_row_idx_group_in[0] = (ODD_ROW_IDX_W-GROUP_IDX_W)'(row_idx_group0_i);
      odd_row_idx_group_in[1] = (ODD_ROW_IDX_W-GROUP_IDX_W)'(row_idx_group1_i);
      #1;
      if (odd_ram_i_target_idx_out[0] != GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target0 mismatch: got %0d exp 0",
               odd_ram_i_target_idx_out[0]);
      end
      if (odd_ram_i_target_idx_out[1] != GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target1 mismatch: got %0d exp 0",
               odd_ram_i_target_idx_out[1]);
      end
      if (odd_row_idx_group_out[0] != (ODD_ROW_IDX_W-GROUP_IDX_W)'(expected_row_idx_group0_i)) begin
        $fatal(1, "odd-r h_shift row_idx_group0 mismatch: got %0d exp %0d",
               odd_row_idx_group_out[0], expected_row_idx_group0_i);
      end
      if (odd_row_idx_group_out[1] != (ODD_ROW_IDX_W-GROUP_IDX_W)'(expected_row_idx_group1_i)) begin
        $fatal(1, "odd-r h_shift row_idx_group1 mismatch: got %0d exp %0d",
               odd_row_idx_group_out[1], expected_row_idx_group1_i);
      end
    end
  endtask

  initial begin
    row_idx_group_in[0] = '0;
    row_idx_group_in[1] = '0;
    odd_row_idx_group_in[0] = '0;
    odd_row_idx_group_in[1] = '0;

    check_shift(
      3,  // global row 6 -> 7
      GROUP_IDX_W'(1),
      (ROW_IDX_W-GROUP_IDX_W)'(3),
      3,  // global row 7 -> 0
      GROUP_IDX_W'(0),
      (ROW_IDX_W-GROUP_IDX_W)'(0)
    );
    check_shift(
      1,  // global row 2 -> 3
      GROUP_IDX_W'(1),
      (ROW_IDX_W-GROUP_IDX_W)'(1),
      2,  // global row 5 -> 6
      GROUP_IDX_W'(0),
      (ROW_IDX_W-GROUP_IDX_W)'(3)
    );

    for (int row_idx_group0 = 0; row_idx_group0 < ROW_SEG_SIZE; row_idx_group0++) begin
      for (int row_idx_group1 = 0; row_idx_group1 < ROW_SEG_SIZE; row_idx_group1++) begin
        if (row_global_from_group(0, row_idx_group0) < R &&
            row_global_from_group(1, row_idx_group1) < R) begin
          check_group_pair(row_idx_group0, row_idx_group1);
        end
      end
    end

    check_odd_r_same_target(4, 0, 0, 1);  // row 8 -> 0 and row 1 -> 2.
    check_odd_r_same_target(4, 0, 3, 4);  // row 8 -> 0 and row 7 -> 8.

    $display("tb_h_shift PASS");
    $finish;
  end
endmodule
