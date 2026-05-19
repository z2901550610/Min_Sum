`timescale 1ns / 1ps
// RAM T — streams cached c2v messages for one processing group.
module ram_t
  import bike_pkg::*;
(
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    input  logic                     i_clear,
    input  logic                     i_push,
    input  logic                     i_pop,
    input  logic [  ENTRY_POS_W-1:0] i_write_entry_idx,
    input  logic [  ENTRY_POS_W-1:0] i_read_entry_idx,
`ifdef BIKE_SIM_DEBUG
    input  logic                     i_valid,
    input  logic [        MSG_W-1:0] i_wdata,
    output logic [        MSG_W-1:0] o_rdata,
    output logic                     o_valid,
    output logic [GROUP_COUNT_W-1:0] o_item_count,
    output logic [        MSG_W-1:0] o_debug_mem[0:RAM_LANE_DEPTH-1]
`else
    input  logic                     i_valid,
    input  logic [        MSG_W-1:0] i_wdata,
    output logic [        MSG_W-1:0] o_rdata,
    output logic                     o_valid
`endif
);

  logic valid_mem[0:RAM_LANE_DEPTH-1];
`ifdef BIKE_SIM_DEBUG
  logic [        MSG_W-1:0] debug_words[0:RAM_LANE_DEPTH-1];
  logic [GROUP_COUNT_W-1:0] valid_count;

  assign o_item_count = valid_count;

  always_comb begin
    for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
      o_debug_mem[entry_pos] = debug_words[entry_pos];
    end
  end
`endif

  ram_1r1w_sync_read #(
      .DATA_W(MSG_W),
      .DEPTH(RAM_LANE_DEPTH),
      .ADDR_W(ENTRY_POS_W),
`ifdef BIKE_SIM_DEBUG
      .RESET_MEM(1'b1),
`else
      .RESET_MEM(1'b0),
`endif
      .RESET_VALUE('0)
  ) u_mem (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_clear(i_clear),
      .i_we(i_push),
      .i_write_addr(i_write_entry_idx),
      .i_wdata(i_wdata),
      .i_read_addr(i_read_entry_idx),
`ifdef BIKE_SIM_DEBUG
      .o_rdata(o_rdata),
      .o_debug_mem(debug_words)
`else
      .o_rdata(o_rdata)
`endif
  );

`ifdef BIKE_SIM_DEBUG
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n || i_clear) begin
      o_valid <= 1'b0;
      for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
        valid_mem[entry_pos] <= 1'b0;
      end
    end else begin
      if (i_pop) begin
        valid_mem[i_read_entry_idx] <= 1'b0;
      end
      if (i_push) begin
        valid_mem[i_write_entry_idx] <= i_valid;
      end
      o_valid <= valid_mem[i_read_entry_idx];
    end
  end
`else
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n || i_clear) begin
      o_valid <= 1'b0;
      for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
        valid_mem[entry_pos] <= 1'b0;
      end
    end else begin
      if (i_pop) begin
        valid_mem[i_read_entry_idx] <= 1'b0;
      end
      if (i_push) begin
        valid_mem[i_write_entry_idx] <= i_valid;
      end
      o_valid <= valid_mem[i_read_entry_idx];
    end
  end
`endif

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    valid_count = '0;
    for (int entry_pos = 0; entry_pos < RAM_LANE_DEPTH; entry_pos++) begin
      if (valid_mem[entry_pos]) begin
        valid_count = valid_count + GROUP_COUNT_W'(1);
      end
    end
  end
`endif
endmodule
