// 目前实现的是根据"row_idx_global 属于第 l 组，当且仅当 row_idx_global mod L = l"进行分组
// row_idx--行号索引
// _global--全局
// _group--组内
module h_shift
  #(
    parameter int R = 8,  // 单个矩阵长宽
    parameter int L = 2,  // 并行度
    parameter int ROW_IDX_W = (R > 1) ? $clog2(R) : 1,  // 行索引位宽
    parameter int GROUP_IDX_W = (L > 1) ? $clog2(L) : 1  // 分组索引位宽
  )
(
  input  logic [ROW_IDX_W-GROUP_IDX_W-1:0] i_row_idx_group [0:L-1],
  output logic [GROUP_IDX_W-1:0] o_ram_i_target_idx [0:L-1],
  output logic [ROW_IDX_W-GROUP_IDX_W-1:0] o_row_idx_group [0:L-1]
);

  localparam logic [ROW_IDX_W-1:0] MAX_ROW_IDX = ROW_IDX_W'(R - 1);

  always_comb begin
    for (int group_idx = 0; group_idx < L; group_idx++) begin
      logic [ROW_IDX_W-GROUP_IDX_W-1:0] row_idx_group;  // 组内行号idx，2并行时，行号idx的最后一位用来确定存在哪个ram i中
      logic [GROUP_IDX_W-1:0]           group_idx_bits; // 组的idx，也就是组内行号idx相对于全局行号idx剔除的部分
      logic [ROW_IDX_W-1:0]             row_idx_global; // 全局行号idx，由组内行号idx和组的idx拼接而成
      logic [ROW_IDX_W-1:0]             next_row_idx_global;
      logic [ROW_IDX_W-1:0]             next_row_idx_group;

      row_idx_group  = i_row_idx_group[group_idx];
      group_idx_bits = GROUP_IDX_W'(group_idx);

      row_idx_global = {row_idx_group, group_idx_bits};

      next_row_idx_global = (row_idx_global == MAX_ROW_IDX) ? '0 : (row_idx_global + 1'b1);
      
      next_row_idx_group  = {
        {GROUP_IDX_W{1'b0}},
        next_row_idx_global[ROW_IDX_W-1:GROUP_IDX_W]
      };

      o_ram_i_target_idx[group_idx] = next_row_idx_global[GROUP_IDX_W-1:0];
      o_row_idx_group[group_idx] = next_row_idx_group[ROW_IDX_W-GROUP_IDX_W-1:0];
    end
  end
endmodule
