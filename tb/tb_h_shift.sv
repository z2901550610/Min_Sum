`timescale 1ns/1ps

module tb_h_shift;
  import bike_pkg::*;

  logic [I_ENTRY_W-1:0] ram_i_entry_in [0:L-1];
  logic [GROUP_IDX_W-1:0] ram_i_target_idx_out [0:L-1];
  logic [I_ENTRY_W-1:0] ram_i_entry_out [0:L-1];

  localparam int ODD_R = 9;
  localparam int ODD_ROW_IDX_W = (ODD_R > 1) ? $clog2(ODD_R) : 1;
  localparam int ODD_ROW_SEG_SIZE = (ODD_R + L - 1) / L;
  localparam int ODD_I_ENTRY_ONE_IDX_LSB = ODD_ROW_IDX_W;
  localparam int ODD_I_ENTRY_W = ODD_I_ENTRY_ONE_IDX_LSB + ONE_IDX_W;

  logic [ODD_I_ENTRY_W-1:0] odd_ram_i_entry_in [0:L-1];
  logic [GROUP_IDX_W-1:0] odd_ram_i_target_idx_out [0:L-1];
  logic [ODD_I_ENTRY_W-1:0] odd_ram_i_entry_out [0:L-1];

  h_shift #(
    .R(R),
    .L(L),
    .ONE_IDX_W(ONE_IDX_W),
    .ROW_IDX_W(ROW_IDX_W),
    .GROUP_IDX_W(GROUP_IDX_W),
    .I_ENTRY_ROW_IDX_GROUP_LSB(I_ENTRY_ROW_IDX_GROUP_LSB),
    .I_ENTRY_ONE_IDX_LSB(I_ENTRY_ONE_IDX_LSB),
    .I_ENTRY_W(I_ENTRY_W)
  ) dut (
    .i_ram_i_entry(ram_i_entry_in),
    .o_ram_i_target_idx(ram_i_target_idx_out),
    .o_ram_i_entry(ram_i_entry_out)
  );

  h_shift #(
    .R(ODD_R),
    .L(L),
    .ONE_IDX_W(ONE_IDX_W),
    .ROW_IDX_W(ODD_ROW_IDX_W),
    .GROUP_IDX_W(GROUP_IDX_W),
    .I_ENTRY_ROW_IDX_GROUP_LSB(I_ENTRY_ROW_IDX_GROUP_LSB),
    .I_ENTRY_ONE_IDX_LSB(ODD_I_ENTRY_ONE_IDX_LSB),
    .I_ENTRY_W(ODD_I_ENTRY_W)
  ) odd_r_dut (
    .i_ram_i_entry(odd_ram_i_entry_in),
    .o_ram_i_target_idx(odd_ram_i_target_idx_out),
    .o_ram_i_entry(odd_ram_i_entry_out)
  );

  function automatic logic [I_ENTRY_W-1:0] make_entry(
    input int edge_slot_i,
    input int row_local_i
  );
    begin
      if (edge_slot_i < 0 || edge_slot_i >= W || row_local_i < 0 || row_local_i >= ROW_SEG_SIZE) begin
        make_entry = 'x;
      end else begin
        make_entry = {ONE_IDX_W'(edge_slot_i), ROW_IDX_W'(row_local_i)};
      end
    end
  endfunction

  function automatic logic [ODD_I_ENTRY_W-1:0] make_odd_entry(
    input int edge_slot_i,
    input int row_local_i
  );
    begin
      if (edge_slot_i < 0 || edge_slot_i >= W ||
          row_local_i < 0 || row_local_i >= ODD_ROW_SEG_SIZE) begin
        make_odd_entry = 'x;
      end else begin
        make_odd_entry = {ONE_IDX_W'(edge_slot_i), ODD_ROW_IDX_W'(row_local_i)};
      end
    end
  endfunction

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

  function automatic logic [GROUP_IDX_W-1:0] expected_target_idx(
    input int row_group_i,
    input int row_local_i
  );
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_second_scheme(row_group_i, row_local_i));
      expected_target_idx = GROUP_IDX_W'(next_row_global % L);
    end
  endfunction

  function automatic logic [I_ENTRY_W-1:0] expected_entry(
    input int row_group_i,
    input int row_local_i,
    input int edge_slot_i
  );
    int next_row_global;
    begin
      next_row_global = shifted_row_global(row_global_from_second_scheme(row_group_i, row_local_i));
      expected_entry = make_entry(edge_slot_i, next_row_global / L);
    end
  endfunction

  task automatic check_shift(
    input logic [I_ENTRY_W-1:0] entry0_i,
    input logic [I_ENTRY_W-1:0] entry1_i,
    input logic [GROUP_IDX_W-1:0] expected_target0_i,
    input logic [I_ENTRY_W-1:0] expected_entry0_i,
    input logic [GROUP_IDX_W-1:0] expected_target1_i,
    input logic [I_ENTRY_W-1:0] expected_entry1_i
  );
    begin
      ram_i_entry_in[0] = entry0_i;
      ram_i_entry_in[1] = entry1_i;
      #1;
      if (ram_i_target_idx_out[0] != expected_target0_i) begin
        $fatal(1, "h_shift target0 mismatch: got %0d exp %0d",
               ram_i_target_idx_out[0], expected_target0_i);
      end
      if (ram_i_entry_out[0] != expected_entry0_i) begin
        $fatal(1, "h_shift entry0 mismatch: got %0d exp %0d",
               ram_i_entry_out[0], expected_entry0_i);
      end
      if (ram_i_target_idx_out[1] != expected_target1_i) begin
        $fatal(1, "h_shift target1 mismatch: got %0d exp %0d",
               ram_i_target_idx_out[1], expected_target1_i);
      end
      if (ram_i_entry_out[1] != expected_entry1_i) begin
        $fatal(1, "h_shift entry1 mismatch: got %0d exp %0d",
               ram_i_entry_out[1], expected_entry1_i);
      end
    end
  endtask

  task automatic check_second_scheme_pair(
    input int row_local0_i,
    input int edge_slot0_i,
    input int row_local1_i,
    input int edge_slot1_i
  );
    begin
      check_shift(
        make_entry(edge_slot0_i, row_local0_i),
        make_entry(edge_slot1_i, row_local1_i),
        expected_target_idx(0, row_local0_i),
        expected_entry(0, row_local0_i, edge_slot0_i),
        expected_target_idx(1, row_local1_i),
        expected_entry(1, row_local1_i, edge_slot1_i)
      );
    end
  endtask

  task automatic check_odd_r_same_target(
    input int row_local0_i,
    input int edge_slot0_i,
    input int expected_row_local0_i,
    input int row_local1_i,
    input int edge_slot1_i,
    input int expected_row_local1_i
  );
    begin
      odd_ram_i_entry_in[0] = make_odd_entry(edge_slot0_i, row_local0_i);
      odd_ram_i_entry_in[1] = make_odd_entry(edge_slot1_i, row_local1_i);
      #1;
      if (odd_ram_i_target_idx_out[0] != GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target0 mismatch: got %0d exp 0",
               odd_ram_i_target_idx_out[0]);
      end
      if (odd_ram_i_target_idx_out[1] != GROUP_IDX_W'(0)) begin
        $fatal(1, "odd-r h_shift target1 mismatch: got %0d exp 0",
               odd_ram_i_target_idx_out[1]);
      end
      if (odd_ram_i_entry_out[0] != make_odd_entry(edge_slot0_i, expected_row_local0_i)) begin
        $fatal(1, "odd-r h_shift entry0 mismatch: got %0d exp %0d",
               odd_ram_i_entry_out[0], make_odd_entry(edge_slot0_i, expected_row_local0_i));
      end
      if (odd_ram_i_entry_out[1] != make_odd_entry(edge_slot1_i, expected_row_local1_i)) begin
        $fatal(1, "odd-r h_shift entry1 mismatch: got %0d exp %0d",
               odd_ram_i_entry_out[1], make_odd_entry(edge_slot1_i, expected_row_local1_i));
      end
    end
  endtask

  initial begin
    ram_i_entry_in[0] = '0;
    ram_i_entry_in[1] = '0;
    odd_ram_i_entry_in[0] = '0;
    odd_ram_i_entry_in[1] = '0;

    check_shift(
      make_entry(0, 3),  // global row 6 -> 7
      make_entry(1, 3),  // global row 7 -> 0
      GROUP_IDX_W'(1),
      make_entry(0, 3),
      GROUP_IDX_W'(0),
      make_entry(1, 0)
    );
    check_shift(
      make_entry(2, 1),  // global row 2 -> 3
      make_entry(0, 2),  // global row 5 -> 6
      GROUP_IDX_W'(1),
      make_entry(2, 1),
      GROUP_IDX_W'(0),
      make_entry(0, 3)
    );

    for (int row_local0 = 0; row_local0 < ROW_SEG_SIZE; row_local0++) begin
      for (int row_local1 = 0; row_local1 < ROW_SEG_SIZE; row_local1++) begin
        if (row_global_from_second_scheme(0, row_local0) < R &&
            row_global_from_second_scheme(1, row_local1) < R) begin
          for (int edge_slot0 = 0; edge_slot0 < W; edge_slot0++) begin
            for (int edge_slot1 = 0; edge_slot1 < W; edge_slot1++) begin
              check_second_scheme_pair(row_local0, edge_slot0, row_local1, edge_slot1);
            end
          end
        end
      end
    end

    check_odd_r_same_target(4, 0, 0, 0, 1, 1);  // row 8 -> 0 and row 1 -> 2.
    check_odd_r_same_target(4, 2, 0, 3, 0, 4);  // row 8 -> 0 and row 7 -> 8.

    $display("tb_h_shift PASS");
    $finish;
  end
endmodule
