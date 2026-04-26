`timescale 1ns/1ps

module tb_h_shift;
  import bike_pkg::*;

  logic [ROW_W-ROW_GROUP_IDX_W-1:0] row_idx_group_in [0:L-1];
  logic [ROW_GROUP_IDX_W-1:0] ram_i_target_idx_out [0:L-1];
  logic [ROW_W-ROW_GROUP_IDX_W-1:0] row_idx_group_out [0:L-1];

  localparam int ODD_R = 9;
  localparam int ODD_ROW_W = (ODD_R > 1) ? $clog2(ODD_R) : 1;
  localparam int ODD_ROW_SEG_SIZE = (ODD_R + L - 1) / L;

  logic [ODD_ROW_W-ROW_GROUP_IDX_W-1:0] odd_row_idx_group_in [0:L-1];
  logic [ROW_GROUP_IDX_W-1:0] odd_ram_i_target_idx_out [0:L-1];
  logic [ODD_ROW_W-ROW_GROUP_IDX_W-1:0] odd_row_idx_group_out [0:L-1];

  h_shift #(
    .R(R),
    .L(L),
    .ROW_IDX_W(ROW_W),
    .GROUP_IDX_W(ROW_GROUP_IDX_W)
  ) dut (
    .i_row_idx_group(row_idx_group_in),
    .o_ram_i_target_idx(ram_i_target_idx_out),
    .o_row_idx_group(row_idx_group_out)
  );

  h_shift #(
    .R(ODD_R),
    .L(L),
    .ROW_IDX_W(ODD_ROW_W),
    .GROUP_IDX_W(ROW_GROUP_IDX_W)
  ) odd_r_dut (
    .i_row_idx_group(odd_row_idx_group_in),
    .o_ram_i_target_idx(odd_ram_i_target_idx_out),
    .o_row_idx_group(odd_row_idx_group_out)
  );

  function automatic int row_global_from_second_scheme(
    input int row_group_i,
    input int row_local_i
  );
    begin
      row_global_from_second_scheme = (row_local_i * L) + row_group_i;
    end
  endfunction

  function automatic int shifted_row_global(input int row_global_i);
    begin
      shifted_row_global = (row_global_i == (R - 1)) ? 0 : (row_global_i + 1);
    end
  endfunction

  function automatic logic [ROW_GROUP_IDX_W-1:0] expected_target_idx(
    input int row_group_i,
    input int row_local_i
  );
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_second_scheme(row_group_i, row_local_i));
      expected_target_idx = ROW_GROUP_IDX_W'(next_row_global % L);
    end
  endfunction

  function automatic logic [ROW_W-ROW_GROUP_IDX_W-1:0] expected_row_idx_group(
    input int row_group_i,
    input int row_local_i
  );
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_second_scheme(row_group_i, row_local_i));
      expected_row_idx_group = (ROW_W-ROW_GROUP_IDX_W)'(next_row_global / L);
    end
  endfunction

  task automatic check_shift(
    input int row_local0_i,
    input logic [ROW_GROUP_IDX_W-1:0] expected_target0_i,
    input logic [ROW_W-ROW_GROUP_IDX_W-1:0] expected_row_idx_group0_i,
    input int row_local1_i,
    input logic [ROW_GROUP_IDX_W-1:0] expected_target1_i,
    input logic [ROW_W-ROW_GROUP_IDX_W-1:0] expected_row_idx_group1_i
  );
    begin
      row_idx_group_in[0] = (ROW_W-ROW_GROUP_IDX_W)'(row_local0_i);
      row_idx_group_in[1] = (ROW_W-ROW_GROUP_IDX_W)'(row_local1_i);
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

  task automatic check_second_scheme_pair(
    input int row_local0_i,
    input int row_local1_i
  );
    begin
      check_shift(
        row_local0_i,
        expected_target_idx(0, row_local0_i),
        expected_row_idx_group(0, row_local0_i),
        row_local1_i,
        expected_target_idx(1, row_local1_i),
        expected_row_idx_group(1, row_local1_i)
      );
    end
  endtask

  task automatic check_odd_r_same_target(
    input int row_local0_i,
    input int expected_row_local0_i,
    input int row_local1_i,
    input int expected_row_local1_i
  );
    begin
      odd_row_idx_group_in[0] = (ODD_ROW_W-ROW_GROUP_IDX_W)'(row_local0_i);
      odd_row_idx_group_in[1] = (ODD_ROW_W-ROW_GROUP_IDX_W)'(row_local1_i);
      #1;
      if (odd_ram_i_target_idx_out[0] != ROW_GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target0 mismatch: got %0d exp 0",
               odd_ram_i_target_idx_out[0]);
      end
      if (odd_ram_i_target_idx_out[1] != ROW_GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target1 mismatch: got %0d exp 0",
               odd_ram_i_target_idx_out[1]);
      end
      if (odd_row_idx_group_out[0] != (ODD_ROW_W-ROW_GROUP_IDX_W)'(expected_row_local0_i)) begin
        $fatal(1, "odd-r h_shift row_idx_group0 mismatch: got %0d exp %0d",
               odd_row_idx_group_out[0], expected_row_local0_i);
      end
      if (odd_row_idx_group_out[1] != (ODD_ROW_W-ROW_GROUP_IDX_W)'(expected_row_local1_i)) begin
        $fatal(1, "odd-r h_shift row_idx_group1 mismatch: got %0d exp %0d",
               odd_row_idx_group_out[1], expected_row_local1_i);
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
      ROW_GROUP_IDX_W'(1),
      (ROW_W-ROW_GROUP_IDX_W)'(3),
      3,  // global row 7 -> 0
      ROW_GROUP_IDX_W'(0),
      (ROW_W-ROW_GROUP_IDX_W)'(0)
    );
    check_shift(
      1,  // global row 2 -> 3
      ROW_GROUP_IDX_W'(1),
      (ROW_W-ROW_GROUP_IDX_W)'(1),
      2,  // global row 5 -> 6
      ROW_GROUP_IDX_W'(0),
      (ROW_W-ROW_GROUP_IDX_W)'(3)
    );

    for (int row_local0 = 0; row_local0 < ROW_SEG_SIZE; row_local0++) begin
      for (int row_local1 = 0; row_local1 < ROW_SEG_SIZE; row_local1++) begin
        if (row_global_from_second_scheme(0, row_local0) < R &&
            row_global_from_second_scheme(1, row_local1) < R) begin
          check_second_scheme_pair(row_local0, row_local1);
        end
      end
    end

    check_odd_r_same_target(4, 0, 0, 1);  // row 8 -> 0 and row 1 -> 2.
    check_odd_r_same_target(4, 0, 3, 4);  // row 8 -> 0 and row 7 -> 8.

    $display("tb_h_shift PASS");
    $finish;
  end
endmodule
