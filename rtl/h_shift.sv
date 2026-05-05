`timescale 1ns/1ps
// 根据 "row_idx_global mod L = l" 进行分组。
// row_idx_group   -- 组内行号
// row_idx_global  -- 全局行号
// group_idx       -- 分组索引
module h_shift
  #(
    parameter int R = 8,
    parameter int L = 2,
    parameter int ROW_IDX_W = (R > 1) ? $clog2(R) : 1,
    parameter int GROUP_IDX_W = (L > 1) ? $clog2(L) : 1
  )
(
  input  logic [ROW_IDX_W-GROUP_IDX_W-1:0] i_row_idx_group [0:L-1],
  output logic [GROUP_IDX_W-1:0] o_ram_i_target_idx [0:L-1],
  output logic [ROW_IDX_W-GROUP_IDX_W-1:0] o_row_idx_group [0:L-1]
);

  localparam logic [ROW_IDX_W-1:0] MAX_ROW_IDX = ROW_IDX_W'(R - 1);

  always_comb begin
    for (int group_idx = 0; group_idx < L; group_idx++) begin
      logic [ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group;
      logic [GROUP_IDX_W-1:0] group_idx_bits;
      logic [ROW_IDX_W-1:0] row_idx_global;
      logic [ROW_IDX_W-1:0] next_row_idx_global;

      row_idx_group = i_row_idx_group[group_idx];
      group_idx_bits = GROUP_IDX_W'(group_idx);
      row_idx_global = {row_idx_group, group_idx_bits};

      next_row_idx_global = (row_idx_global == MAX_ROW_IDX) ? '0 : (row_idx_global + 1'b1);

      o_ram_i_target_idx[group_idx] = next_row_idx_global[GROUP_IDX_W-1:0];
      o_row_idx_group[group_idx] = next_row_idx_global[ROW_IDX_W-1:GROUP_IDX_W];
    end
  end
endmodule
