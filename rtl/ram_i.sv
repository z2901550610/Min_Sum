// One paper-style RAM I block.  A block belongs to one processing lane and
// contains the n0 circulant-bank column-index lists for that lane.
module ram_i
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_en,
  input  logic i_we,
  input  logic [BANK_W-1:0] i_bank,
  input  logic [EDGE_W-1:0] i_addr,
  input  logic [I_ENTRY_W-1:0] i_din,
  input  logic i_count_we,
  input  logic [LANE_COUNT_W-1:0] i_count_din,
  input  logic i_load,
  input  logic [BANK_W-1:0] i_load_bank,
  input  logic [I_ENTRY_W-1:0] i_load_entries [0:W-1],
  input  logic [LANE_COUNT_W-1:0] i_load_count,
  output logic [I_ENTRY_W-1:0] o_dout,
  output logic [LANE_COUNT_W-1:0] o_count,
  output logic [I_ENTRY_W-1:0] o_debug_entries [0:N0-1][0:W-1],
  output logic [LANE_COUNT_W-1:0] o_debug_count [0:N0-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [I_ENTRY_W-1:0] mem [0:N0-1][0:W-1];
  logic [LANE_COUNT_W-1:0] count_mem [0:N0-1];

  assign o_debug_entries = mem;
  assign o_debug_count = count_mem;
  assign o_count = count_mem[i_bank];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer bank_idx;
    integer slot_idx;

    if (!i_rst_n) begin
      o_dout <= '0;
      for (bank_idx = 0; bank_idx < N0; bank_idx++) begin
        count_mem[bank_idx] <= '0;
        for (slot_idx = 0; slot_idx < W; slot_idx++) begin
          mem[bank_idx][slot_idx] <= '0;
        end
      end
    end else if (i_clear) begin
      o_dout <= '0;
      for (bank_idx = 0; bank_idx < N0; bank_idx++) begin
        count_mem[bank_idx] <= '0;
        for (slot_idx = 0; slot_idx < W; slot_idx++) begin
          mem[bank_idx][slot_idx] <= '0;
        end
      end
    end else if (i_load) begin
      count_mem[i_load_bank] <= i_load_count;
      for (slot_idx = 0; slot_idx < W; slot_idx++) begin
        mem[i_load_bank][slot_idx] <= i_load_entries[slot_idx];
      end
    end else begin
      if (i_en) begin
        if (i_we) begin
          mem[i_bank][i_addr] <= i_din;
        end
        o_dout <= mem[i_bank][i_addr];
      end
      if (i_count_we) begin
        count_mem[i_bank] <= i_count_din;
      end
    end
  end
endmodule
