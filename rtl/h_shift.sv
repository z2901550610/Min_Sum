`timescale 1ns / 1ps
// 根据 "row_idx_global mod B = l" 进行分组。
// row_idx_group   -- 组内行号
// row_idx_global  -- 全局行号
// group_idx       -- 分组索引
module h_shift #(
    parameter int R               = 8,
    parameter int L               = 2,
    parameter int B               = 2,
    parameter int ROW_IDX_W       = (R > 1) ? $clog2(R) : 1,
    parameter int GROUP_IDX_W     = (B > 1) ? $clog2(B) : 1,
    parameter int ROW_GROUP_DEPTH = (R + B - 1) / B,
    parameter int ROW_GROUP_W     = (ROW_GROUP_DEPTH > 1) ? $clog2(ROW_GROUP_DEPTH) : 1
) (
    input  logic [GROUP_IDX_W-1:0] i_group_idx[0:L-1],
    input  logic [ROW_GROUP_W-1:0] i_row_idx_group[0:L-1],
    output logic [GROUP_IDX_W-1:0] o_ram_i_target_idx[0:L-1],
    output logic [ROW_GROUP_W-1:0] o_row_idx_group[0:L-1]
);

  localparam logic [ROW_IDX_W-1:0] MAX_ROW_IDX = ROW_IDX_W'(R - 1);

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      logic [ROW_GROUP_W-1:0] row_idx_group;
      logic [GROUP_IDX_W-1:0] group_idx_bits;
      logic [  ROW_IDX_W-1:0] row_idx_global;
      logic [  ROW_IDX_W-1:0] next_row_idx_global;
      logic [GROUP_IDX_W-1:0] next_group_idx;
      logic [ROW_GROUP_W-1:0] next_row_idx_group;

      row_idx_group = i_row_idx_group[lane_idx];
      group_idx_bits = i_group_idx[lane_idx];
      row_idx_global = ROW_IDX_W'(int'(row_idx_group) * B + int'(group_idx_bits));

      next_row_idx_global = (row_idx_global == MAX_ROW_IDX) ? '0 : (row_idx_global + 1'b1);
      next_group_idx = GROUP_IDX_W'(int'(next_row_idx_global) % B);
      next_row_idx_group = ROW_GROUP_W'(int'(next_row_idx_global) / B);

      o_ram_i_target_idx[lane_idx] = next_group_idx;
      o_row_idx_group[lane_idx] = next_row_idx_group;
    end
  end
endmodule
