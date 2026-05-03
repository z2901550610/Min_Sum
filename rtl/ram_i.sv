// RAM-I：一个实例只保存一个 group 的 H-block 列 metadata。
// list 是该 group 内的 packed entries，entry = {one_idx_global, row_idx_group}。
module ram_i
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_en,
  input  logic i_we,
  input  logic [H_BLOCK_W-1:0] i_hblk_idx,
  input  logic [ONE_IDX_W-1:0] i_entry_idx,
  input  logic [I_ENTRY_W-1:0] i_entry_wdata,
  input  logic i_count_we,
  input  logic [GROUP_COUNT_W-1:0] i_count_wdata,
  input  logic i_list_load_en,
  input  logic [H_BLOCK_W-1:0] i_list_load_hblk_idx,
  input  logic [I_ENTRY_W-1:0] i_list_load_entries [0:W-1],
  input  logic [GROUP_COUNT_W-1:0] i_list_load_count,
  output logic [I_ENTRY_W-1:0] o_entry_rdata,
  output logic [GROUP_COUNT_W-1:0] o_count,
  output logic [I_ENTRY_W-1:0] o_list_entries [0:W-1],
  output logic [I_ENTRY_W-1:0] o_debug_list_entries [0:N0-1][0:W-1],
  output logic [GROUP_COUNT_W-1:0] o_debug_counts [0:N0-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  // 每个 hblk 保存一个 group-local list；count 说明 list 前几项有效。
  logic [I_ENTRY_W-1:0] list_entries_mem [0:N0-1][0:W-1];
  logic [GROUP_COUNT_W-1:0] list_count_mem [0:N0-1];
  assign o_debug_list_entries = list_entries_mem;
  assign o_debug_counts = list_count_mem;

  always_comb begin
    o_count = list_count_mem[i_hblk_idx];
    for (int entry_idx_local = 0; entry_idx_local < W; entry_idx_local++) begin
      o_list_entries[entry_idx_local] = list_entries_mem[i_hblk_idx][entry_idx_local];
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_entry_rdata <= '0;
      for (int hblk_idx_local = 0; hblk_idx_local < N0; hblk_idx_local++) begin
        list_count_mem[hblk_idx_local] <= '0;
        for (int entry_idx_local = 0; entry_idx_local < W; entry_idx_local++) begin
          list_entries_mem[hblk_idx_local][entry_idx_local] <= '0;
        end
      end
    end else if (i_list_load_en) begin
      // 整组覆盖：seed 第一列或写入 h_shift 后的下一列 metadata。
      list_count_mem[i_list_load_hblk_idx] <= i_list_load_count;
      for (int entry_idx_local = 0; entry_idx_local < W; entry_idx_local++) begin
        list_entries_mem[i_list_load_hblk_idx][entry_idx_local] <= i_list_load_entries[entry_idx_local];
      end
    end else begin
      if (i_en) begin
        if (i_we) begin
          list_entries_mem[i_hblk_idx][i_entry_idx] <= i_entry_wdata;
        end
        o_entry_rdata <= list_entries_mem[i_hblk_idx][i_entry_idx];
      end
      if (i_count_we) begin
        list_count_mem[i_hblk_idx] <= i_count_wdata;
      end
    end
  end
endmodule
