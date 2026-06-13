`timescale 1ns / 1ps

module tb_edge_addr_gen;
  import bike_pkg::*;

  logic                   phase_valid;
  logic [  H_BLOCK_W-1:0] h_block_idx;
  logic [ TILE_IDX_W-1:0] tile_idx;
  logic [    Q_SEQ_W-1:0] q_seq;
  logic [  ROW_IDX_W-1:0] base_row;
  logic [  EDGE_ID_W-1:0] edge_id;
  logic                   valid[0:L-1];
  logic [  ROW_IDX_W-1:0] row_idx[0:L-1];
  logic [      COL_W-1:0] col_idx[0:L-1];
  logic [  EDGE_ID_W-1:0] lane_edge_id[0:L-1];
  logic [ LANE_IDX_W-1:0] row_bank[0:L-1];
  logic [ROW_BANK_AW-1:0] row_addr[0:L-1];
  logic [ TILE_OFF_W-1:0] tile_offset[0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [  EDGE_ID_W-1:0] observed_lane_edge_id[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */

  edge_addr_gen dut (
      .i_phase_valid(phase_valid),
      .i_h_block_idx(h_block_idx),
      .i_tile_idx(tile_idx),
      .i_q_seq(q_seq),
      .i_base_row(base_row),
      .i_edge_id(edge_id),
      .o_valid(valid),
      .o_row_idx(row_idx),
      .o_col_idx(col_idx),
      .o_edge_id(lane_edge_id),
      .o_row_bank(row_bank),
      .o_row_addr(row_addr),
      .o_tile_offset(tile_offset)
  );

  initial begin
    #10000;
    $fatal(1, "tb_edge_addr_gen timeout");
  end

  task automatic check_no_bank_conflict;
    begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        observed_lane_edge_id[lane_idx] = lane_edge_id[lane_idx];
      end
      for (int lhs = 0; lhs < L; lhs++) begin
        for (int rhs = lhs + 1; rhs < L; rhs++) begin
          if (valid[lhs] && valid[rhs] && (row_bank[lhs] == row_bank[rhs])) begin
            $fatal(1, "row bank conflict lhs=%0d rhs=%0d bank=%0d", lhs, rhs, row_bank[lhs]);
          end
        end
      end
    end
  endtask

  function automatic int valid_count;
    begin
      valid_count = 0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (valid[lane_idx]) valid_count++;
      end
    end
  endfunction

  function automatic bit has_tile_offset(input  logic [TILE_OFF_W-1:0] offset_value);
    begin
      has_tile_offset = 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (valid[lane_idx] && (tile_offset[lane_idx] == TILE_OFF_W'(offset_value))) begin
          has_tile_offset = 1'b1;
        end
      end
    end
  endfunction

  initial begin
    phase_valid = 1'b1;
    h_block_idx = '0;
    tile_idx = '0;
    q_seq = '0;
    base_row = '0;
    edge_id = '0;
    #1;
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      if (!valid[bank_idx]) $fatal(1, "base_row=0 bank %0d should be valid", bank_idx);
      if (row_idx[bank_idx] != ROW_IDX_W'(bank_idx)) $fatal(1, "base_row=0 row mismatch");
      if (col_idx[bank_idx] != COL_W'(bank_idx)) $fatal(1, "base_row=0 col mismatch");
      if (row_addr[bank_idx] != '0) $fatal(1, "base_row=0 row addr mismatch");
      if (row_bank[bank_idx] != LANE_IDX_W'(bank_idx)) $fatal(1, "row bank mismatch");
      if (tile_offset[bank_idx] != TILE_OFF_W'(bank_idx)) $fatal(1, "tile offset mismatch");
    end
    check_no_bank_conflict();

    base_row = ROW_IDX_W'(R - 1);
    q_seq = '0;
    #1;
    if (valid_count() != 1) $fatal(1, "pre-wrap should have one valid lane");
    if (!has_tile_offset(0)) $fatal(1, "pre-wrap offset 0 should be valid");
    check_no_bank_conflict();

    q_seq = Q_SEQ_W'(1);
    #1;
    if (valid_count() != (L - 1)) $fatal(1, "post-wrap should have L-1 valid lanes");
    for (int offset_idx = 1; offset_idx < L; offset_idx++) begin
      if (!has_tile_offset(TILE_OFF_W'(offset_idx))) begin
        $fatal(1, "post-wrap offset %0d should be valid", offset_idx);
      end
    end
    check_no_bank_conflict();

    base_row = '0;
    q_seq = Q_SEQ_W'(Q_TILE - 1);
    #1;
    if (valid_count() != 0) $fatal(1, "guard dummy should have no valid lanes");

    tile_idx = TILE_IDX_W'(TILE_COUNT - 1);
    q_seq = '0;
    #1;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (valid[lane_idx] && (int'(col_idx[lane_idx]) >= N)) begin
        $fatal(1, "tail tile produced out-of-range col");
      end
    end
    check_no_bank_conflict();

    $display("tb_edge_addr_gen PASS");
    $finish;
  end
endmodule
