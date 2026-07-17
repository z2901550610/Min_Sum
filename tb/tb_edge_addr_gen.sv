`timescale 1ns / 1ps

module tb_edge_addr_gen;
  import bike_pkg::*;

  logic                        clk;
  logic                        rst_n;
  logic                        phase_valid;
  logic [       H_BLOCK_W-1:0] h_block_idx;
  logic [      TILE_IDX_W-1:0] tile_idx;
  logic [LANE_GROUP_IDX_W-1:0] lane_group_idx;
  logic [       ROW_IDX_W-1:0] base_row_idx;
  logic [      DIAG_IDX_W-1:0] diag_idx_local;
  logic [   DIAG_GLOBAL_W-1:0] diag_idx_global_base;
  logic                        valid[0:L-1];
  logic [       ROW_IDX_W-1:0] check_row_idx[0:L-1];
  logic [           COL_W-1:0] col_idx[0:L-1];
  logic [   DIAG_GLOBAL_W-1:0] lane_diag_idx_global[0:L-1];
  logic [      LANE_IDX_W-1:0] row_bank[0:L-1];
  logic [     ROW_BANK_AW-1:0] row_addr[0:L-1];
  logic [      TILE_OFF_W-1:0] tile_offset[0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic [   DIAG_GLOBAL_W-1:0] observed_lane_diag_idx_global[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */

  edge_addr_gen dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_phase_valid(phase_valid),
      .i_h_block_idx(h_block_idx),
      .i_tile_idx(tile_idx),
      .i_lane_group_idx(lane_group_idx),
      .i_base_row_idx(base_row_idx),
      .i_diag_idx_local(diag_idx_local),
      .i_cfg_r(CFG_R_W'(R)),
      .i_cfg_w(CFG_W_W'(W)),
      .o_valid(valid),
      .o_check_row_idx(check_row_idx),
      .o_col_idx(col_idx),
      .o_diag_idx_global_base(diag_idx_global_base),
      .o_diag_idx_global(lane_diag_idx_global),
      .o_row_bank(row_bank),
      .o_row_addr(row_addr),
      .o_tile_offset(tile_offset)
  );

  initial clk = 1'b0;
  always #1 clk = ~clk;

  initial begin
    #1000000;
    $fatal(1, "tb_edge_addr_gen timeout");
  end

  task automatic check_no_bank_conflict;
    begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        observed_lane_diag_idx_global[lane_idx] = lane_diag_idx_global[lane_idx];
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

  function automatic int first_group_cols(input int tile_value);
    int tile_base;
    int cols_per_tile;
    begin
      tile_base = tile_value * COLS_PER_TILE;
      cols_per_tile = ((tile_base + COLS_PER_TILE) > R) ? (R - tile_base) : COLS_PER_TILE;
      first_group_cols = (cols_per_tile < L) ? cols_per_tile : L;
    end
  endfunction

  task automatic check_tile_coverage(input int block_value, input int tile_value,
                                     input int base_value);
    bit                       seen                     [0:COLS_PER_TILE-1];
    int                       tile_base;
    int                       cols_per_tile;
    int                       seen_total;
    logic [DIAG_GLOBAL_W-1:0] expected_diag_idx_global;
    begin
      tile_base = tile_value * COLS_PER_TILE;
      cols_per_tile = ((tile_base + COLS_PER_TILE) > R) ? (R - tile_base) : COLS_PER_TILE;
      expected_diag_idx_global = DIAG_GLOBAL_W'((block_value * W) + 2);
      seen_total = 0;

      for (int offset_idx = 0; offset_idx < COLS_PER_TILE; offset_idx++) begin
        seen[offset_idx] = 1'b0;
      end

      h_block_idx = H_BLOCK_W'(block_value);
      tile_idx = TILE_IDX_W'(tile_value);
      base_row_idx = ROW_IDX_W'(base_value);
      diag_idx_local = DIAG_IDX_W'(2);

      for (int lane_group_idx_loop = 0; lane_group_idx_loop < Q_TILE; lane_group_idx_loop++) begin
        lane_group_idx = LANE_GROUP_IDX_W'(lane_group_idx_loop);
        @(posedge clk);
        #1;
        check_no_bank_conflict();
        if (diag_idx_global_base != expected_diag_idx_global) begin
          $fatal(1, "global diagonal base mismatch block=%0d got=%0d exp=%0d", block_value,
                 int'(diag_idx_global_base), int'(expected_diag_idx_global));
        end

        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (valid[lane_idx]) begin
            int offset_value;
            int col_local;
            int expected_col;
            int expected_row;

            offset_value = int'(tile_offset[lane_idx]);
            if ((offset_value < 0) || (offset_value >= cols_per_tile)) begin
              $fatal(1,
                     "coverage offset range base=%0d tile=%0d q=%0d lane=%0d offset=%0d cols=%0d",
                     base_value, tile_value, lane_group_idx_loop, lane_idx, offset_value,
                     cols_per_tile);
            end
            if (seen[offset_value]) begin
              $fatal(1, "coverage duplicate base=%0d tile=%0d q=%0d lane=%0d offset=%0d",
                     base_value, tile_value, lane_group_idx_loop, lane_idx, offset_value);
            end
            seen[offset_value] = 1'b1;
            seen_total++;

            col_local = tile_base + offset_value;
            expected_col = block_value * R + col_local;
            expected_row = base_value + col_local;
            if (expected_row >= R) expected_row -= R;

            if (int'(col_idx[lane_idx]) != expected_col) begin
              $fatal(1, "coverage col mismatch base=%0d tile=%0d q=%0d lane=%0d got=%0d exp=%0d",
                     base_value, tile_value, lane_group_idx_loop, lane_idx,
                     int'(col_idx[lane_idx]), expected_col);
            end
            if (int'(check_row_idx[lane_idx]) != expected_row) begin
              $fatal(1, "coverage row mismatch base=%0d tile=%0d q=%0d lane=%0d got=%0d exp=%0d",
                     base_value, tile_value, lane_group_idx_loop, lane_idx,
                     int'(check_row_idx[lane_idx]), expected_row);
            end
            if (int'(row_bank[lane_idx]) != (expected_row % L)) begin
              $fatal(1, "coverage row bank mismatch base=%0d tile=%0d q=%0d lane=%0d", base_value,
                     tile_value, lane_group_idx_loop, lane_idx);
            end
            if (int'(row_addr[lane_idx]) != (expected_row >> L_SHIFT)) begin
              $fatal(1, "coverage row addr mismatch base=%0d tile=%0d q=%0d lane=%0d", base_value,
                     tile_value, lane_group_idx_loop, lane_idx);
            end
            if (lane_diag_idx_global[lane_idx] != expected_diag_idx_global) begin
              $fatal(1, "coverage global diagonal index mismatch base=%0d tile=%0d q=%0d lane=%0d",
                     base_value, tile_value, lane_group_idx_loop, lane_idx);
            end
          end
        end
      end

      if (seen_total != cols_per_tile) begin
        $fatal(1, "coverage count mismatch base=%0d tile=%0d got=%0d exp=%0d", base_value,
               tile_value, seen_total, cols_per_tile);
      end
      for (int offset_idx = 0; offset_idx < cols_per_tile; offset_idx++) begin
        if (!seen[offset_idx]) begin
          $fatal(1, "coverage missing base=%0d tile=%0d offset=%0d", base_value, tile_value,
                 offset_idx);
        end
      end
    end
  endtask

  task automatic check_representative_coverage;
    int base_samples[0:7];
    begin
      base_samples[0] = 0;
      base_samples[1] = 1 % R;
      base_samples[2] = (L > 1) ? ((L - 1) % R) : 0;
      base_samples[3] = L % R;
      base_samples[4] = (R > L) ? (R - L) : 0;
      base_samples[5] = R - 1;
      base_samples[6] = R / 2;
      base_samples[7] = (R > COLS_PER_TILE) ? (R - COLS_PER_TILE) : 0;

      for (int block_idx = 0; block_idx < N0; block_idx++) begin
        for (int tile_value = 0; tile_value < TILE_COUNT; tile_value++) begin
          for (int sample_idx = 0; sample_idx < 8; sample_idx++) begin
            check_tile_coverage(block_idx, tile_value, base_samples[sample_idx]);
          end
        end
      end

      if (R <= 1024) begin
        for (int block_idx = 0; block_idx < N0; block_idx++) begin
          for (int tile_value = 0; tile_value < TILE_COUNT; tile_value++) begin
            for (int base_value = 0; base_value < R; base_value++) begin
              check_tile_coverage(block_idx, tile_value, base_value);
            end
          end
        end
      end
    end
  endtask

  initial begin
    rst_n = 1'b0;
    phase_valid = 1'b1;
    h_block_idx = '0;
    tile_idx = '0;
    lane_group_idx = '0;
    base_row_idx = '0;
    diag_idx_local = '0;
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    #1;
    if (valid_count() != first_group_cols(0)) begin
      $fatal(1, "base_row_idx=0 valid count mismatch got=%0d exp=%0d", valid_count(),
             first_group_cols(0));
    end
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      if (bank_idx < first_group_cols(0)) begin
        if (!valid[bank_idx]) $fatal(1, "base_row_idx=0 bank %0d should be valid", bank_idx);
        if (check_row_idx[bank_idx] != ROW_IDX_W'(bank_idx))
          $fatal(1, "base_row_idx=0 row mismatch");
        if (col_idx[bank_idx] != COL_W'(bank_idx)) $fatal(1, "base_row_idx=0 col mismatch");
        if (row_addr[bank_idx] != '0) $fatal(1, "base_row_idx=0 row addr mismatch");
        if (row_bank[bank_idx] != LANE_IDX_W'(bank_idx)) $fatal(1, "row bank mismatch");
        if (tile_offset[bank_idx] != TILE_OFF_W'(bank_idx)) $fatal(1, "tile offset mismatch");
      end else if (valid[bank_idx]) begin
        $fatal(1, "base_row_idx=0 bank %0d should be invalid", bank_idx);
      end
    end
    check_no_bank_conflict();

    base_row_idx   = ROW_IDX_W'(R - 1);
    lane_group_idx = '0;
    @(posedge clk);
    #1;
    if (valid_count() != 1) $fatal(1, "pre-wrap should have one valid lane");
    if (!has_tile_offset(0)) $fatal(1, "pre-wrap offset 0 should be valid");
    check_no_bank_conflict();

    lane_group_idx = LANE_GROUP_IDX_W'(1);
    @(posedge clk);
    #1;
    if (valid_count() != (first_group_cols(0) - 1)) begin
      $fatal(1, "post-wrap valid count mismatch got=%0d exp=%0d", valid_count(), first_group_cols(0
             ) - 1);
    end
    for (int offset_idx = 1; offset_idx < first_group_cols(0); offset_idx++) begin
      if (!has_tile_offset(TILE_OFF_W'(offset_idx))) begin
        $fatal(1, "post-wrap offset %0d should be valid", offset_idx);
      end
    end
    check_no_bank_conflict();

    base_row_idx   = '0;
    lane_group_idx = LANE_GROUP_IDX_W'(Q_TILE - 1);
    @(posedge clk);
    #1;
    if (valid_count() != 0) $fatal(1, "guard dummy should have no valid lanes");

    tile_idx = TILE_IDX_W'(TILE_COUNT - 1);
    lane_group_idx = '0;
    @(posedge clk);
    #1;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (valid[lane_idx] && (int'(col_idx[lane_idx]) >= N)) begin
        $fatal(1, "tail tile produced out-of-range col");
      end
    end
    check_no_bank_conflict();

    check_representative_coverage();

    $display("tb_edge_addr_gen PASS");
    $finish;
  end
endmodule
