`timescale 1ns / 1ps
// RAM-I：一个实例保存一个 edge lane 的 H-block 列 metadata。
// list 是该 lane 内的 packed entries，entry = {one_idx, row_idx_global}。
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
    input  logic [    H_BLOCK_W-1:0] i_read_h_block_idx,
    input  logic [    H_BLOCK_W-1:0] i_write_h_block_idx,
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

  localparam int I_SLOT_DEPTH = N0 * RAM_LANE_DEPTH;
  localparam int I_MEM_DEPTH = 2 * I_SLOT_DEPTH;
  localparam int I_MEM_ADDR_W = (I_MEM_DEPTH > 1) ? $clog2(I_MEM_DEPTH) : 1;
  localparam int COUNT_MEM_DEPTH = 2 * N0;
  localparam int COUNT_MEM_ADDR_W = (COUNT_MEM_DEPTH > 1) ? $clog2(COUNT_MEM_DEPTH) : 1;
  localparam string ENTRY_INIT_FILE = (INIT_HEX_STEM != "") ? {
    INIT_HEX_STEM, "_entries", INIT_HEX_TAG, ".hex"
  } : $sformatf(
      "%s%0d_entries%s.hex", INIT_HEX_PREFIX, BANK_IDX, INIT_HEX_TAG
  );
  localparam string COUNT_INIT_FILE = (INIT_HEX_STEM != "") ? {
    INIT_HEX_STEM, "_counts", INIT_HEX_TAG, ".hex"
  } : $sformatf(
      "%s%0d_counts%s.hex", INIT_HEX_PREFIX, BANK_IDX, INIT_HEX_TAG
  );

  // 每个 h_block 保存 active/next 两个 lane-local list；count 说明 list 前几项有效。
  logic                     active_slot[             0:N0-1];
  logic [    I_ENTRY_W-1:0] entry_mem[    0:I_MEM_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] count_mem[0:COUNT_MEM_DEPTH-1];

  function automatic logic [I_MEM_ADDR_W-1:0] entry_addr(input  logic slot,
                                                         input  logic [H_BLOCK_W-1:0] h_block_idx,
                                                         input  logic [ENTRY_POS_W-1:0] entry_idx);
    begin
      entry_addr = I_MEM_ADDR_W'(
        (slot ? I_SLOT_DEPTH : 0) + int'(h_block_idx) * RAM_LANE_DEPTH + int'(entry_idx)
      );
    end
  endfunction

  function automatic logic [COUNT_MEM_ADDR_W-1:0] count_addr(
      input  logic slot, input  logic [H_BLOCK_W-1:0] h_block_idx);
    begin
      count_addr = COUNT_MEM_ADDR_W'((slot ? N0 : 0) + int'(h_block_idx));
    end
  endfunction

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      o_debug_counts[h_block_idx] =
          count_mem[count_addr(active_slot[h_block_idx], H_BLOCK_W'(h_block_idx))];
      for (int entry_idx = 0; entry_idx < RAM_LANE_DEPTH; entry_idx++) begin
        o_debug_list_entries[h_block_idx][entry_idx] = entry_mem[
            entry_addr(active_slot[h_block_idx], H_BLOCK_W'(h_block_idx), ENTRY_POS_W'(entry_idx))];
      end
    end
  end
`endif

  assign o_count = count_mem[count_addr(active_slot[i_read_h_block_idx], i_read_h_block_idx)];

  initial begin
    o_entry_rdata = '0;
    for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
      active_slot[h_block_idx] = 1'b0;
    end
    for (int entry_idx = 0; entry_idx < I_MEM_DEPTH; entry_idx++) begin
      entry_mem[entry_idx] = '0;
    end
    for (int count_idx = 0; count_idx < COUNT_MEM_DEPTH; count_idx++) begin
      count_mem[count_idx] = '0;
    end
    if (ENTRY_INIT_FILE != "") begin
      $readmemh(ENTRY_INIT_FILE, entry_mem, 0, I_SLOT_DEPTH - 1);
    end
    if (COUNT_INIT_FILE != "") begin
      $readmemh(COUNT_INIT_FILE, count_mem, 0, N0 - 1);
    end
  end

  always_ff @(posedge i_clk) begin
    if (i_we) begin
      entry_mem[entry_addr(~active_slot[i_write_h_block_idx], i_write_h_block_idx,
                           i_write_entry_idx)] <= i_entry_wdata;
    end
    if (i_count_we) begin
      count_mem[count_addr(~active_slot[i_write_h_block_idx], i_write_h_block_idx)] <=
          i_count_wdata;
    end
    o_entry_rdata <= entry_mem[entry_addr(
        active_slot[i_read_h_block_idx], i_read_h_block_idx, i_read_entry_idx
    )];
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        active_slot[h_block_idx] <= 1'b0;
      end
    end else if (i_count_we) begin
      active_slot[i_write_h_block_idx] <= ~active_slot[i_write_h_block_idx];
    end
  end
endmodule
