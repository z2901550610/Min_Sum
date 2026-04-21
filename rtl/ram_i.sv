// One paper-style RAM I block. A block belongs to one processing row_group and
// contains the n0 H-block column-index lists for that row_group.
module ram_i
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_en,
  input  logic i_we,
  input  logic [H_BLOCK_W-1:0] i_h_block_idx,                  // Which circulant block of H: H0, H1, ...
  input  logic [EDGE_W-1:0] i_row_group_pos_addr,              // Which packed row_group list position to access, range 0..W-1.
  input  logic [I_ENTRY_W-1:0] i_wdata,
  input  logic i_row_group_count_we,
  input  logic [ROW_GROUP_COUNT_W-1:0] i_row_group_count_wdata,      // How many "1"s in this variable column belong to this row_group.
  input  logic i_column_replace_en,
  input  logic [H_BLOCK_W-1:0] i_column_replace_h_block_idx,    // Which H block column metadata is replaced.
  input  logic [I_ENTRY_W-1:0] i_column_entries_wdata [0:W-1],  // Whole-column packed entries for this row_group.
  input  logic [ROW_GROUP_COUNT_W-1:0] i_column_row_group_count_wdata,  // Valid entry count for the replacement column.
  output logic [I_ENTRY_W-1:0] o_rdata,
  output logic [ROW_GROUP_COUNT_W-1:0] o_row_group_count,            // How many "1"s in this variable column belong to this row_group.
  output logic [I_ENTRY_W-1:0] o_column_entries [0:W-1],   // Functional full-column view for the selected H block.
  output logic [I_ENTRY_W-1:0] o_debug_entries [0:N0-1][0:W-1],
  output logic [ROW_GROUP_COUNT_W-1:0] o_debug_row_group_count [0:N0-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [I_ENTRY_W-1:0] mem [0:N0-1][0:W-1];
  logic [ROW_GROUP_COUNT_W-1:0] count_mem [0:N0-1];
  assign o_debug_entries = mem;
  assign o_debug_row_group_count = count_mem;

  always_comb begin
    o_row_group_count = count_mem[i_h_block_idx];
    for (int column_pos_idx = 0; column_pos_idx < W; column_pos_idx++) begin
      o_column_entries[column_pos_idx] = mem[i_h_block_idx][column_pos_idx];
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= '0;
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        count_mem[h_block_idx] <= '0;
        for (int column_pos_idx = 0; column_pos_idx < W; column_pos_idx++) begin
          mem[h_block_idx][column_pos_idx] <= '0;
        end
      end
    end else if (i_clear) begin
      o_rdata <= '0;
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        count_mem[h_block_idx] <= '0;
        for (int column_pos_idx = 0; column_pos_idx < W; column_pos_idx++) begin
          mem[h_block_idx][column_pos_idx] <= '0;
        end
      end
    end else if (i_column_replace_en) begin
      count_mem[i_column_replace_h_block_idx] <= i_column_row_group_count_wdata;
      for (int column_pos_idx = 0; column_pos_idx < W; column_pos_idx++) begin
        mem[i_column_replace_h_block_idx][column_pos_idx] <= i_column_entries_wdata[column_pos_idx];
      end
    end else begin
      if (i_en) begin
        if (i_we) begin
          mem[i_h_block_idx][i_row_group_pos_addr] <= i_wdata;
        end
        o_rdata <= mem[i_h_block_idx][i_row_group_pos_addr];
      end
      if (i_row_group_count_we) begin
        count_mem[i_h_block_idx] <= i_row_group_count_wdata;
      end
    end
  end
endmodule
