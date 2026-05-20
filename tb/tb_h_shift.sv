`timescale 1ns / 1ps

module tb_h_shift;
  import bike_pkg::*;

  logic [GROUP_IDX_W-1:0] group_idx_in[0:L-1];
  logic [ROW_GROUP_W-1:0] row_idx_group_in[0:L-1];
  logic [GROUP_IDX_W-1:0] ram_i_target_idx_out[0:L-1];
  logic [ROW_GROUP_W-1:0] row_idx_group_out[0:L-1];

  localparam int ODD_R = 9;
  localparam int ODD_ROW_IDX_W = (ODD_R > 1) ? $clog2(ODD_R) : 1;
  localparam int ODD_ROW_GROUP_DEPTH = (ODD_R + L - 1) / L;
  localparam int ODD_ROW_GROUP_W = (ODD_ROW_GROUP_DEPTH > 1) ? $clog2(ODD_ROW_GROUP_DEPTH) : 1;

  logic [    GROUP_IDX_W-1:0] odd_group_idx_in[0:L-1];
  logic [ODD_ROW_GROUP_W-1:0] odd_row_idx_group_in[0:L-1];
  logic [    GROUP_IDX_W-1:0] odd_ram_i_target_idx_out[0:L-1];
  logic [ODD_ROW_GROUP_W-1:0] odd_row_idx_group_out[0:L-1];

  h_shift #(
      .R(R),
      .L(L),
      .ROW_IDX_W(ROW_IDX_W),
      .GROUP_IDX_W(GROUP_IDX_W),
      .ROW_GROUP_DEPTH(ROW_GROUP_DEPTH),
      .ROW_GROUP_W(ROW_GROUP_W)
  ) dut (
      .i_group_idx(group_idx_in),
      .i_row_idx_group(row_idx_group_in),
      .o_ram_i_target_idx(ram_i_target_idx_out),
      .o_row_idx_group(row_idx_group_out)
  );

  h_shift #(
      .R(ODD_R),
      .L(L),
      .ROW_IDX_W(ODD_ROW_IDX_W),
      .GROUP_IDX_W(GROUP_IDX_W),
      .ROW_GROUP_DEPTH(ODD_ROW_GROUP_DEPTH),
      .ROW_GROUP_W(ODD_ROW_GROUP_W)
  ) odd_r_dut (
      .i_group_idx(odd_group_idx_in),
      .i_row_idx_group(odd_row_idx_group_in),
      .o_ram_i_target_idx(odd_ram_i_target_idx_out),
      .o_row_idx_group(odd_row_idx_group_out)
  );

  function automatic int row_global_from_group(input int group_idx_i, input int row_idx_group_i);
    begin
      row_global_from_group = (row_idx_group_i * L) + group_idx_i;
    end
  endfunction

  function automatic int shifted_row_global(input int row_idx_global_i);
    begin
      shifted_row_global = (row_idx_global_i == (R - 1)) ? 0 : (row_idx_global_i + 1);
    end
  endfunction

  function automatic logic [GROUP_IDX_W-1:0] expected_target_idx(input int group_idx_i,
                                                                 input int row_idx_group_i);
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_group(group_idx_i, row_idx_group_i));
      expected_target_idx = GROUP_IDX_W'(next_row_global % L);
    end
  endfunction

  function automatic logic [ROW_GROUP_W-1:0] expected_row_idx_group(input int group_idx_i,
                                                                    input int row_idx_group_i);
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_group(group_idx_i, row_idx_group_i));
      expected_row_idx_group = ROW_GROUP_W'(next_row_global / L);
    end
  endfunction

  task automatic check_shift(input  logic [ROW_GROUP_W-1:0] row_idx_group0_i,
                             input  logic [GROUP_IDX_W-1:0] expected_target0_i,
                             input  logic [ROW_GROUP_W-1:0] expected_row_idx_group0_i,
                             input  logic [ROW_GROUP_W-1:0] row_idx_group1_i,
                             input  logic [GROUP_IDX_W-1:0] expected_target1_i,
                             input  logic [ROW_GROUP_W-1:0] expected_row_idx_group1_i);
    begin
      group_idx_in[0] = '0;
      group_idx_in[1] = GROUP_IDX_W'(1);
      row_idx_group_in[0] = ROW_GROUP_W'(row_idx_group0_i);
      row_idx_group_in[1] = ROW_GROUP_W'(row_idx_group1_i);
      #1;
      if (ram_i_target_idx_out[0] != expected_target0_i) begin
        $fatal(1, "h_shift target0 mismatch: got %0d exp %0d", ram_i_target_idx_out[0],
               expected_target0_i);
      end
      if (row_idx_group_out[0] != expected_row_idx_group0_i) begin
        $fatal(1, "h_shift row_idx_group0 mismatch: got %0d exp %0d", row_idx_group_out[0],
               expected_row_idx_group0_i);
      end
      if (ram_i_target_idx_out[1] != expected_target1_i) begin
        $fatal(1, "h_shift target1 mismatch: got %0d exp %0d", ram_i_target_idx_out[1],
               expected_target1_i);
      end
      if (row_idx_group_out[1] != expected_row_idx_group1_i) begin
        $fatal(1, "h_shift row_idx_group1 mismatch: got %0d exp %0d", row_idx_group_out[1],
               expected_row_idx_group1_i);
      end
    end
  endtask

  task automatic check_group_pair(input int row_idx_group0_i, input int row_idx_group1_i);
    begin
      check_shift(ROW_GROUP_W'(row_idx_group0_i), expected_target_idx(0, row_idx_group0_i),
                  expected_row_idx_group(0, row_idx_group0_i), ROW_GROUP_W'(row_idx_group1_i),
                  expected_target_idx(1, row_idx_group1_i), expected_row_idx_group(
                  1, row_idx_group1_i));
    end
  endtask

  task automatic check_odd_r_same_target(
      input  logic [ODD_ROW_GROUP_W-1:0] row_idx_group0_i, input int expected_row_idx_group0_i,
      input  logic [ODD_ROW_GROUP_W-1:0] row_idx_group1_i, input int expected_row_idx_group1_i);
    begin
      odd_group_idx_in[0] = '0;
      odd_group_idx_in[1] = GROUP_IDX_W'(1);
      odd_row_idx_group_in[0] = ODD_ROW_GROUP_W'(row_idx_group0_i);
      odd_row_idx_group_in[1] = ODD_ROW_GROUP_W'(row_idx_group1_i);
      #1;
      if (odd_ram_i_target_idx_out[0] != GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target0 mismatch: got %0d exp 0", odd_ram_i_target_idx_out[0]);
      end
      if (odd_ram_i_target_idx_out[1] != GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target1 mismatch: got %0d exp 0", odd_ram_i_target_idx_out[1]);
      end
      if (odd_row_idx_group_out[0] != ODD_ROW_GROUP_W'(expected_row_idx_group0_i)) begin
        $fatal(1, "odd-r h_shift row_idx_group0 mismatch: got %0d exp %0d",
               odd_row_idx_group_out[0], expected_row_idx_group0_i);
      end
      if (odd_row_idx_group_out[1] != ODD_ROW_GROUP_W'(expected_row_idx_group1_i)) begin
        $fatal(1, "odd-r h_shift row_idx_group1 mismatch: got %0d exp %0d",
               odd_row_idx_group_out[1], expected_row_idx_group1_i);
      end
    end
  endtask

  initial begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      group_idx_in[lane_idx] = GROUP_IDX_W'(lane_idx);
      row_idx_group_in[lane_idx] = '0;
      odd_group_idx_in[lane_idx] = GROUP_IDX_W'(lane_idx);
      odd_row_idx_group_in[lane_idx] = '0;
    end

    for (int row_idx_global = 0; row_idx_global < R; row_idx_global++) begin
      int                     lane_idx;
      logic [ROW_GROUP_W-1:0] row_idx_group_i;
      int                     next_row_global;

      lane_idx = row_idx_global % L;
      row_idx_group_i = ROW_GROUP_W'(row_idx_global / L);
      next_row_global = (row_idx_global == (R - 1)) ? 0 : (row_idx_global + 1);
      row_idx_group_in[lane_idx] = row_idx_group_i;
      #1;
      if (ram_i_target_idx_out[lane_idx] != GROUP_IDX_W'(next_row_global % L)) begin
        $fatal(1, "h_shift target mismatch row=%0d lane=%0d got=%0d exp=%0d", row_idx_global,
               lane_idx, ram_i_target_idx_out[lane_idx], next_row_global % L);
      end
      if (row_idx_group_out[lane_idx] != ROW_GROUP_W'(next_row_global / L)) begin
        $fatal(1, "h_shift row_idx_group mismatch row=%0d lane=%0d got=%0d exp=%0d",
               row_idx_global, lane_idx, row_idx_group_out[lane_idx], next_row_global / L);
      end
    end

    for (int row_idx_global = 0; row_idx_global < ODD_R; row_idx_global++) begin
      int                         lane_idx;
      logic [ODD_ROW_GROUP_W-1:0] row_idx_group_i;
      int                         next_row_global;

      lane_idx = row_idx_global % L;
      row_idx_group_i = ODD_ROW_GROUP_W'(row_idx_global / L);
      next_row_global = (row_idx_global == (ODD_R - 1)) ? 0 : (row_idx_global + 1);
      odd_row_idx_group_in[lane_idx] = row_idx_group_i;
      #1;
      if (odd_ram_i_target_idx_out[lane_idx] != GROUP_IDX_W'(next_row_global % L)) begin
        $fatal(1, "odd-r h_shift target mismatch row=%0d lane=%0d got=%0d exp=%0d", row_idx_global,
               lane_idx, odd_ram_i_target_idx_out[lane_idx], next_row_global % L);
      end
      if (odd_row_idx_group_out[lane_idx] != ODD_ROW_GROUP_W'(next_row_global / L)) begin
        $fatal(1, "odd-r h_shift row_idx_group mismatch row=%0d lane=%0d got=%0d exp=%0d",
               row_idx_global, lane_idx, odd_row_idx_group_out[lane_idx], next_row_global / L);
      end
    end

    $display("tb_h_shift PASS");
    $finish;
  end
endmodule
