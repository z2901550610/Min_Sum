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
  input  logic [BANK_W-1:0] i_circ_idx,                    // Which circulant block of H: H0, H1, ...
  input  logic [EDGE_W-1:0] i_edge_slot_addr,              // Which "1" in this variable column to access, range 0..W-1.
  input  logic [I_ENTRY_W-1:0] i_wdata,
  input  logic i_lane_count_we,
  input  logic [LANE_COUNT_W-1:0] i_lane_count_wdata,      // How many "1"s in this variable column belong to this lane.
  input  logic i_seed_en,
  input  logic [BANK_W-1:0] i_seed_circ_idx,               // Which circulant block is being seeded: H0, H1, ...
  input  logic [I_ENTRY_W-1:0] i_seed_entries [0:W-1],      // First-column "1" entries assigned to this lane.
  input  logic [LANE_COUNT_W-1:0] i_seed_lane_count,        // How many first-column "1"s in i_seed_entries are valid.
  output logic [I_ENTRY_W-1:0] o_rdata,
  output logic [LANE_COUNT_W-1:0] o_lane_count,            // How many "1"s in this variable column belong to this lane.
  output logic [I_ENTRY_W-1:0] o_column_entries [0:W-1],   // Functional full-column view for the selected circulant bank.
  output logic [I_ENTRY_W-1:0] o_debug_entries [0:N0-1][0:W-1],
  output logic [LANE_COUNT_W-1:0] o_debug_lane_count [0:N0-1]
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [I_ENTRY_W-1:0] mem [0:N0-1][0:W-1];
  logic [LANE_COUNT_W-1:0] count_mem [0:N0-1];
  integer slot_idx_local;

  assign o_debug_entries = mem;
  assign o_debug_lane_count = count_mem;

  always_comb begin
    o_lane_count = count_mem[i_circ_idx];
    for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
      o_column_entries[slot_idx_local] = mem[i_circ_idx][slot_idx_local];
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= '0;
      for (int circ_idx = 0; circ_idx < N0; circ_idx++) begin
        count_mem[circ_idx] <= '0;
        for (int slot_idx = 0; slot_idx < W; slot_idx++) begin
          mem[circ_idx][slot_idx] <= '0;
        end
      end
    end else if (i_clear) begin
      o_rdata <= '0;
      for (int circ_idx = 0; circ_idx < N0; circ_idx++) begin
        count_mem[circ_idx] <= '0;
        for (int slot_idx = 0; slot_idx < W; slot_idx++) begin
          mem[circ_idx][slot_idx] <= '0;
        end
      end
    end else if (i_seed_en) begin
      count_mem[i_seed_circ_idx] <= i_seed_lane_count;
      for (int slot_idx = 0; slot_idx < W; slot_idx++) begin
        mem[i_seed_circ_idx][slot_idx] <= i_seed_entries[slot_idx];
      end
    end else begin
      if (i_en) begin
        if (i_we) begin
          mem[i_circ_idx][i_edge_slot_addr] <= i_wdata;
        end
        o_rdata <= mem[i_circ_idx][i_edge_slot_addr];
      end
      if (i_lane_count_we) begin
        count_mem[i_circ_idx] <= i_lane_count_wdata;
      end
    end
  end
endmodule
