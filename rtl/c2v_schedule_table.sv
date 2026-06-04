`timescale 1ns / 1ps
// C2V row-bank issue schedule generated from the loaded first-column support.
module c2v_schedule_table
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_load_lane_we[0:L-1],
    input  logic [  H_BLOCK_W-1:0] i_load_h_block_idx,
    input  logic [ENTRY_POS_W-1:0] i_load_entry_idx,
    input  logic [  I_ENTRY_W-1:0] i_load_entry_wdata[0:L-1],
    input  logic                   i_build_start,
    output logic                   o_build_busy,
    output logic                   o_build_done,
    output logic                   o_ready,
    input  logic                   i_read_en,
    input  logic [  H_BLOCK_W-1:0] i_read_h_block_idx,
    input  logic [  ROW_IDX_W-1:0] i_read_col_local,
    input  logic [ENTRY_POS_W-1:0] i_read_entry_pos,
    output logic                   o_lane_valid[0:L-1],
    output logic [  ROW_IDX_W-1:0] o_lane_base_row[0:L-1],
    output logic [  ONE_IDX_W-1:0] o_lane_one_idx[0:L-1],
    output logic [  EDGE_ID_W-1:0] o_lane_edge_id[0:L-1]
);

  localparam int SCHED_VALID_LSB = 0;
  localparam int SCHED_BASE_LSB = SCHED_VALID_LSB + 1;
  localparam int SCHED_ONE_LSB = SCHED_BASE_LSB + ROW_IDX_W;
  localparam int SCHED_EDGE_LSB = SCHED_ONE_LSB + ONE_IDX_W;

  (* ram_style = "block" *) logic [ SCHED_WORD_W-1:0] sched_mem[0:SCHED_DEPTH-1];

  logic [    ROW_IDX_W-1:0] support_row[         0:N0-1][0:W-1];
  logic [            W-1:0] issued_mask;
  logic [            W-1:0] issued_mask_next;
  logic [ SCHED_WORD_W-1:0] build_word_next;
  logic [ SCHED_WORD_W-1:0] sched_rword;
  logic [    H_BLOCK_W-1:0] build_h_block_idx;
  logic [SCHED_CLASS_W-1:0] build_class_idx;
  logic [  ENTRY_POS_W-1:0] build_entry_pos;
  logic [SCHED_CLASS_W-1:0] read_class_idx;
  logic [ SCHED_ADDR_W-1:0] build_addr;
  logic [ SCHED_ADDR_W-1:0] read_addr;
  logic                     build_last_entry;
  logic                     build_last_class;
  logic                     build_last_h_block;

  function automatic logic [SCHED_ADDR_W-1:0] sched_addr(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                                         input  logic [SCHED_CLASS_W-1:0] class_idx,
                                                         input  logic [ENTRY_POS_W-1:0] entry_pos);
    begin
      sched_addr = SCHED_ADDR_W'(
        (int'(h_block_idx) * SCHED_CLASS_COUNT + int'(class_idx)) * RAM_LANE_DEPTH +
        int'(entry_pos)
      );
    end
  endfunction

  function automatic logic [M_ROW_BANK_IDX_W-1:0] adjusted_bank(
      input  logic [ROW_IDX_W-1:0] base_row, input  logic wrapped);
    int adjusted_mod;
    begin
      if (M_ROW_BANKS == 1) begin
        adjusted_bank = '0;
      end else if (wrapped) begin
        adjusted_mod  = (int'(base_row) % M_ROW_BANKS) + M_ROW_BANKS - (R % M_ROW_BANKS);
        adjusted_bank = M_ROW_BANK_IDX_W'(adjusted_mod % M_ROW_BANKS);
      end else begin
        adjusted_bank = M_ROW_BANK_IDX_W'(int'(base_row) % M_ROW_BANKS);
      end
    end
  endfunction

  function automatic logic edge_wraps_in_class(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                               input  logic [ONE_IDX_W-1:0] one_idx,
                                               input  logic [SCHED_CLASS_W-1:0] class_idx);
    int rank;
    begin
      rank = 0;
      for (int cmp_idx = 0; cmp_idx < W; cmp_idx++) begin
        if (support_row[int'(h_block_idx)][cmp_idx] >
            support_row[int'(h_block_idx)][int'(one_idx)]) begin
          rank++;
        end
      end
      edge_wraps_in_class = (rank < int'(class_idx));
    end
  endfunction

  always_comb begin
    int                          one_idx;
    int                          source_entry_idx;
    int                          source_lane_idx;
    logic                        lane_assigned;
    logic                        bank_conflict;
    logic                        wrapped;
    logic [M_ROW_BANK_IDX_W-1:0] candidate_bank;
    logic [M_ROW_BANK_IDX_W-1:0] slot_bank_idx[0:L-1];
    logic                        slot_bank_valid[0:L-1];

    build_word_next  = '0;
    issued_mask_next = issued_mask;

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      slot_bank_idx[lane_idx]   = '0;
      slot_bank_valid[lane_idx] = 1'b0;
    end

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      lane_assigned = 1'b0;
      for (source_lane_idx = 0; source_lane_idx < L; source_lane_idx++) begin
        for (source_entry_idx = 0; source_entry_idx < RAM_LANE_DEPTH; source_entry_idx++) begin
          one_idx = source_entry_idx * L + source_lane_idx;
          bank_conflict = 1'b0;
          wrapped = 1'b0;
          candidate_bank = '0;
          if (one_idx < W) begin
            wrapped = edge_wraps_in_class(build_h_block_idx, ONE_IDX_W'(one_idx), build_class_idx);
            candidate_bank = adjusted_bank(support_row[int'(build_h_block_idx)][one_idx], wrapped);
            for (int prev_lane_idx = 0; prev_lane_idx < L; prev_lane_idx++) begin
              if (slot_bank_valid[prev_lane_idx] &&
                  (slot_bank_idx[prev_lane_idx] == candidate_bank)) begin
                bank_conflict = 1'b1;
              end
            end

            if (!lane_assigned && !issued_mask[one_idx] && !bank_conflict) begin
              build_word_next[lane_idx*SCHED_LANE_ENTRY_W+SCHED_VALID_LSB] = 1'b1;
              build_word_next[lane_idx*SCHED_LANE_ENTRY_W+SCHED_BASE_LSB+:ROW_IDX_W] =
                support_row[int'(build_h_block_idx)][one_idx];
              build_word_next[lane_idx*SCHED_LANE_ENTRY_W+SCHED_ONE_LSB+:ONE_IDX_W] =
                ONE_IDX_W'(one_idx);
              build_word_next[lane_idx*SCHED_LANE_ENTRY_W+SCHED_EDGE_LSB+:EDGE_ID_W] =
                EDGE_ID_W'(int'(build_h_block_idx) * W + one_idx);
              issued_mask_next[one_idx] = 1'b1;
              slot_bank_idx[lane_idx] = candidate_bank;
              slot_bank_valid[lane_idx] = 1'b1;
              lane_assigned = 1'b1;
            end
          end
        end
      end
    end
  end

  always_comb begin
    logic [ROW_IDX_W:0] row_sum;

    read_class_idx = '0;
    for (int one_idx = 0; one_idx < W; one_idx++) begin
      row_sum = {1'b0, support_row[int'(i_read_h_block_idx)][one_idx]} + {1'b0, i_read_col_local};
      if (row_sum >= (ROW_IDX_W + 1)'(R)) begin
        read_class_idx = read_class_idx + SCHED_CLASS_W'(1);
      end
    end

    build_addr = sched_addr(build_h_block_idx, build_class_idx, build_entry_pos);
    read_addr = sched_addr(i_read_h_block_idx, read_class_idx, i_read_entry_pos);

    build_last_entry = ((int'(build_entry_pos) + 1) >= RAM_LANE_DEPTH);
    build_last_class = ((int'(build_class_idx) + 1) >= SCHED_CLASS_COUNT);
    build_last_h_block = (build_h_block_idx == H_BLOCK_W'(N0 - 1));
  end

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_decode_lane
    assign o_lane_valid[lane_idx] = sched_rword[lane_idx*SCHED_LANE_ENTRY_W+SCHED_VALID_LSB];
    assign o_lane_base_row[lane_idx] =
        sched_rword[lane_idx*SCHED_LANE_ENTRY_W+SCHED_BASE_LSB+:ROW_IDX_W];
    assign o_lane_one_idx[lane_idx] =
        sched_rword[lane_idx*SCHED_LANE_ENTRY_W+SCHED_ONE_LSB+:ONE_IDX_W];
    assign o_lane_edge_id[lane_idx] =
        sched_rword[lane_idx*SCHED_LANE_ENTRY_W+SCHED_EDGE_LSB+:EDGE_ID_W];
  end

  always_ff @(posedge i_clk) begin
    if (i_read_en) begin
      sched_rword <= sched_mem[read_addr];
    end
    if (o_build_busy) begin
      sched_mem[build_addr] <= build_word_next;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_build_busy <= 1'b0;
      o_build_done <= 1'b0;
      o_ready <= 1'b0;
      build_h_block_idx <= '0;
      build_class_idx <= '0;
      build_entry_pos <= '0;
      issued_mask <= '0;
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          support_row[h_block_idx][one_idx] <= '0;
        end
      end
    end else begin
      o_build_done <= 1'b0;

      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (i_load_lane_we[lane_idx] && ((int'(i_load_entry_idx) * L + lane_idx) < W)) begin
          support_row[int'(i_load_h_block_idx)][int'(i_load_entry_idx)*L+lane_idx] <=
              i_load_entry_wdata[lane_idx];
        end
      end

      if (i_build_start) begin
        o_build_busy <= 1'b1;
        o_ready <= 1'b0;
        build_h_block_idx <= '0;
        build_class_idx <= '0;
        build_entry_pos <= '0;
        issued_mask <= '0;
      end else if (o_build_busy) begin
        if (build_last_entry && build_last_class && build_last_h_block) begin
          o_build_busy <= 1'b0;
          o_build_done <= 1'b1;
          o_ready <= 1'b1;
          build_h_block_idx <= '0;
          build_class_idx <= '0;
          build_entry_pos <= '0;
          issued_mask <= '0;
        end else if (build_last_entry) begin
          build_entry_pos <= '0;
          issued_mask <= '0;
          if (build_last_class) begin
            build_class_idx   <= '0;
            build_h_block_idx <= build_h_block_idx + H_BLOCK_W'(1);
          end else begin
            build_class_idx <= build_class_idx + SCHED_CLASS_W'(1);
          end
        end else begin
          build_entry_pos <= build_entry_pos + ENTRY_POS_W'(1);
          issued_mask <= issued_mask_next;
        end
      end
    end
  end
endmodule
