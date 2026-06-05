`timescale 1ns / 1ps

module tb_support_row_col_gen;
  import bike_pkg::*;

  logic                   phase_valid;
  logic [  H_BLOCK_W-1:0] h_block_idx;
  logic [ TILE_IDX_W-1:0] tile_idx;
  logic [    Q_SEQ_W-1:0] q_seq;
  logic [  ROW_IDX_W-1:0] support_row;
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

  support_row_col_gen dut (
      .i_phase_valid(phase_valid),
      .i_h_block_idx(h_block_idx),
      .i_tile_idx(tile_idx),
      .i_q_seq(q_seq),
      .i_support_row(support_row),
      .i_edge_id(edge_id),
      .o_valid(valid),
      .o_row_idx(row_idx),
      .o_col_idx(col_idx),
      .o_edge_id(lane_edge_id),
      .o_row_bank(row_bank),
      .o_row_addr(row_addr),
      .o_tile_offset(tile_offset)
  );

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

  initial begin
    phase_valid = 1'b1;
    h_block_idx = '0;
    tile_idx = '0;
    q_seq = '0;
    support_row = '0;
    edge_id = '0;
    #1;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (!valid[lane_idx]) $fatal(1, "support=0 lane %0d should be valid", lane_idx);
      if (row_idx[lane_idx] != ROW_IDX_W'(lane_idx)) $fatal(1, "support=0 row mismatch");
      if (col_idx[lane_idx] != COL_W'(lane_idx)) $fatal(1, "support=0 col mismatch");
      if (row_addr[lane_idx] != '0) $fatal(1, "support=0 row addr mismatch");
      if (tile_offset[lane_idx] != TILE_OFF_W'(lane_idx)) $fatal(1, "tile offset mismatch");
    end
    check_no_bank_conflict();

    support_row = ROW_IDX_W'(R - 1);
    q_seq = '0;
    #1;
    if (!valid[0]) $fatal(1, "pre-wrap lane 0 should be valid");
    for (int lane_idx = 1; lane_idx < L; lane_idx++) begin
      if (valid[lane_idx]) $fatal(1, "pre-wrap lane %0d should be masked", lane_idx);
    end
    check_no_bank_conflict();

    q_seq = Q_SEQ_W'(1);
    #1;
    if (valid[0]) $fatal(1, "post-wrap lane 0 should be masked");
    for (int lane_idx = 1; lane_idx < L; lane_idx++) begin
      if (!valid[lane_idx]) $fatal(1, "post-wrap lane %0d should be valid", lane_idx);
    end
    check_no_bank_conflict();

    support_row = '0;
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

    $display("tb_support_row_col_gen PASS");
    $finish;
  end
endmodule
