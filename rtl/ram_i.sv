`timescale 1ns / 1ps
// RAM-I：一个实例只保存一个 group 的 H-block 列 metadata。
// list 是该 group 内的 packed entries，entry = {one_idx, row_idx_group}。
// 上电时通过 $readmemh 从 hex 文件加载初始数据。
module ram_i
  import bike_pkg::*;
#(
    parameter string INIT_HEX_STEM   = "rtl/generated/ram_i",
    parameter string INIT_HEX_PREFIX = "rtl/generated/ram_i",
    parameter int    BANK_IDX        = 0,
`ifndef BIKE_TOY_PARAMS
    parameter string INIT_HEX_TAG    = "_l1"
`else
    parameter string INIT_HEX_TAG    = "_test"
`endif
) (
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    input  logic                     i_we,
    input  logic [    H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [  ENTRY_POS_W-1:0] i_read_entry_idx,
    input  logic [  ENTRY_POS_W-1:0] i_write_entry_idx,
    input  logic [    I_ENTRY_W-1:0] i_entry_wdata,
    input  logic                     i_count_we,
    input  logic [GROUP_COUNT_W-1:0] i_count_wdata,
`ifdef BIKE_SIM_DEBUG
    output logic [    I_ENTRY_W-1:0] o_entry_rdata,
    output logic [GROUP_COUNT_W-1:0] o_count,
    output logic [    I_ENTRY_W-1:0] o_debug_list_entries[0:N0-1][0:RAM_LANE_DEPTH-1],
    output logic [GROUP_COUNT_W-1:0] o_debug_counts[0:N0-1]
`else
    output logic [    I_ENTRY_W-1:0] o_entry_rdata,
    output logic [GROUP_COUNT_W-1:0] o_count
`endif
);

  localparam int I_MEM_DEPTH = N0 * RAM_LANE_DEPTH;
  localparam int I_MEM_ADDR_W = (I_MEM_DEPTH > 1) ? $clog2(I_MEM_DEPTH) : 1;

  // 每个 h_block 保存一个 group-local list；count 说明 list 前几项有效。
  (* ram_style = "block" *) logic [    I_ENTRY_W-1:0] list_entries_mem[0:I_MEM_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] list_count_mem[         0:N0-1];

  function automatic logic [I_MEM_ADDR_W-1:0] entry_addr(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                                         input  logic [ENTRY_POS_W-1:0] entry_idx);
    begin
      entry_addr = I_MEM_ADDR_W'(int'(h_block_idx) * RAM_LANE_DEPTH + int'(entry_idx));
    end
  endfunction

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      o_debug_counts[h_block_idx] = list_count_mem[h_block_idx];
      for (int entry_idx = 0; entry_idx < RAM_LANE_DEPTH; entry_idx++) begin
        o_debug_list_entries[h_block_idx][entry_idx] =
          list_entries_mem[h_block_idx * RAM_LANE_DEPTH + entry_idx];
      end
    end
  end
`endif

  assign o_count = list_count_mem[i_h_block_idx];

`ifdef BIKE_SIM_DEBUG
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_entry_rdata <= '0;
    end else begin
      if (i_we) begin
        list_entries_mem[entry_addr(i_h_block_idx, i_write_entry_idx)] <= i_entry_wdata;
      end
      if (i_count_we) begin
        list_count_mem[i_h_block_idx] <= i_count_wdata;
      end
      o_entry_rdata <= list_entries_mem[entry_addr(i_h_block_idx, i_read_entry_idx)];
    end
  end
`else
  always_ff @(posedge i_clk) begin
    if (i_we) begin
      list_entries_mem[entry_addr(i_h_block_idx, i_write_entry_idx)] <= i_entry_wdata;
    end
    if (i_count_we) begin
      list_count_mem[i_h_block_idx] <= i_count_wdata;
    end
    o_entry_rdata <= list_entries_mem[entry_addr(i_h_block_idx, i_read_entry_idx)];
  end
`endif

  // 从 hex 文件加载初始数据。
  initial begin
    if (INIT_HEX_STEM != "") begin
      $readmemh({INIT_HEX_STEM, "_entries", INIT_HEX_TAG, ".hex"}, list_entries_mem);
      $readmemh({INIT_HEX_STEM, "_counts", INIT_HEX_TAG, ".hex"}, list_count_mem);
    end else begin
      $readmemh($sformatf("%s%0d_entries%s.hex", INIT_HEX_PREFIX, BANK_IDX, INIT_HEX_TAG),
                list_entries_mem);
      $readmemh($sformatf("%s%0d_counts%s.hex", INIT_HEX_PREFIX, BANK_IDX, INIT_HEX_TAG),
                list_count_mem);
    end
  end
endmodule
