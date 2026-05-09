`timescale 1ns/1ps
// RAM T — streams cached c2v messages for one processing group.
module ram_t
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_push,
  input  logic i_pop,
  input  logic [ENTRY_POS_W-1:0] i_write_entry_idx,
  input  logic [ENTRY_POS_W-1:0] i_read_entry_idx,
  input  logic i_valid,
  input  logic [MSG_W-1:0] i_wdata,
  output logic [MSG_W-1:0] o_rdata,
  output logic o_valid,
  output logic [GROUP_COUNT_W-1:0] o_item_count,
  output logic [MSG_W-1:0] o_debug_mem [0:RAM_LANE_DEPTH-1]
);

  logic [MSG_W-1:0] mem [0:RAM_LANE_DEPTH-1];
  logic valid_mem [0:RAM_LANE_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] valid_count;

  assign o_rdata = mem[i_read_entry_idx];
  assign o_valid = valid_mem[i_read_entry_idx];
  assign o_item_count = valid_count;

  always_comb begin
    for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
      o_debug_mem[entry_pos] = mem[entry_pos];
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n || i_clear) begin
      for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
        mem[entry_pos] <= '0;
        valid_mem[entry_pos] <= 1'b0;
      end
    end else begin
      if (i_pop) begin
        valid_mem[i_read_entry_idx] <= 1'b0;
      end
      if (i_push) begin
        mem[i_write_entry_idx] <= i_wdata;
        valid_mem[i_write_entry_idx] <= i_valid;
      end
    end
  end

  always_comb begin
    valid_count = '0;
    for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
      if (valid_mem[entry_pos]) begin
        valid_count = valid_count + GROUP_COUNT_W'(1);
      end
    end
  end
endmodule
