`timescale 1ns/1ps
// RAM-I：一个实例只保存一个 group 的 H-block 列 metadata。
// list 是该 group 内的 packed entries，entry = {one_idx, row_idx_group}。
// 上电时通过 $readmemh 从 hex 文件加载初始数据。
module ram_i
  import bike_pkg::*;
#(
  parameter string INIT_HEX_STEM = "rtl/generated/ram_i"
)
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_we,
  input  logic [H_BLOCK_W-1:0] i_h_block_idx,
  input  logic [ONE_IDX_W-1:0] i_entry_idx,
  input  logic [I_ENTRY_W-1:0] i_entry_wdata,
  input  logic i_count_we,
  input  logic [GROUP_COUNT_W-1:0] i_count_wdata,
  output logic [I_ENTRY_W-1:0] o_entry_rdata,
  output logic [GROUP_COUNT_W-1:0] o_count,
  output logic [I_ENTRY_W-1:0] o_debug_list_entries [0:N0-1][0:W-1],
  output logic [GROUP_COUNT_W-1:0] o_debug_counts [0:N0-1]
);

  // 每个 h_block 保存一个 group-local list；count 说明 list 前几项有效。
  logic [I_ENTRY_W-1:0] list_entries_mem [0:N0-1][0:W-1];
  logic [GROUP_COUNT_W-1:0] list_count_mem [0:N0-1];
  assign o_debug_list_entries = list_entries_mem;
  assign o_debug_counts = list_count_mem;

  assign o_count = list_count_mem[i_h_block_idx];
  assign o_entry_rdata = list_entries_mem[i_h_block_idx][i_entry_idx];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
    end else begin
      if (i_we) begin
        list_entries_mem[i_h_block_idx][i_entry_idx] <= i_entry_wdata;
      end
      if (i_count_we) begin
        list_count_mem[i_h_block_idx] <= i_count_wdata;
      end
    end
  end

  // 从 hex 文件加载初始数据，替代原先的 SEED+list_load 机制。
`ifdef BIKE_L1_PARAMS
  localparam string INIT_TAG = "_l1";
`else
  localparam string INIT_TAG = "_test";
`endif

  initial begin
    $readmemh({INIT_HEX_STEM, "_entries", INIT_TAG, ".hex"}, list_entries_mem);
    $readmemh({INIT_HEX_STEM, "_counts", INIT_TAG, ".hex"}, list_count_mem);
  end
endmodule
