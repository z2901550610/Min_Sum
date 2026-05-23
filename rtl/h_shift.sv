`timescale 1ns / 1ps
// 根据 "row_idx_global mod L = l" 进行分组。
// row_idx_group   -- 组内行号
// row_idx_global  -- 全局行号
// group_idx       -- 分组索引
module h_shift #(
    parameter int R               = 8,
    parameter int L               = 2,
    /* verilator lint_off UNUSEDPARAM */
    parameter int ROW_IDX_W       = (R > 1) ? $clog2(R) : 1,
    /* verilator lint_on UNUSEDPARAM */
    parameter int GROUP_IDX_W     = (L > 1) ? $clog2(L) : 1,
    parameter int ROW_GROUP_DEPTH = (R + L - 1) / L,
    parameter int ROW_GROUP_W     = (ROW_GROUP_DEPTH > 1) ? $clog2(ROW_GROUP_DEPTH) : 1
) (
    input  logic [GROUP_IDX_W-1:0] i_group_idx[0:L-1],
    input  logic [ROW_GROUP_W-1:0] i_row_idx_group[0:L-1],
    output logic [GROUP_IDX_W-1:0] o_ram_i_target_idx[0:L-1],
    output logic [ROW_GROUP_W-1:0] o_row_idx_group[0:L-1]
);

  localparam int LAST_ROW_GROUP = (R - 1) / L;
  localparam int LAST_GROUP_IDX = (R - 1) - (LAST_ROW_GROUP * L);

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      logic [ROW_GROUP_W-1:0] row_idx_group;
      logic [GROUP_IDX_W-1:0] group_idx_bits;
      logic [GROUP_IDX_W-1:0] next_group_idx;
      logic [ROW_GROUP_W-1:0] next_row_idx_group;
      logic                   last_row;
      logic                   last_group;

      row_idx_group = i_row_idx_group[lane_idx];
      group_idx_bits = i_group_idx[lane_idx];

      last_row =
        (row_idx_group == ROW_GROUP_W'(LAST_ROW_GROUP)) &&
        (group_idx_bits == GROUP_IDX_W'(LAST_GROUP_IDX));
      last_group = (group_idx_bits == GROUP_IDX_W'(L - 1));
      next_group_idx = (last_row || last_group) ? '0 : (group_idx_bits + 1'b1);
      next_row_idx_group = last_row ? '0 : (last_group ? (row_idx_group + 1'b1) : row_idx_group);

      o_ram_i_target_idx[lane_idx] = next_group_idx;
      o_row_idx_group[lane_idx] = next_row_idx_group;
    end
  end
endmodule
