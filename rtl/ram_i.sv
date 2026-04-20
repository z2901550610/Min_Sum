// Stores one lane-packed QC column per circulant bank.
module ram_i
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic [BANK_W-1:0] i_rd_bank,                          // Bank selected for combinational readout.
  output logic [I_ENTRY_W-1:0] o_rd_lane_entries [0:L-1][0:W-1],// Lane-packed entries for the selected bank.
  output logic [LANE_COUNT_W-1:0] o_rd_lane_count [0:L-1],      // Valid lane counts for the selected bank.
  input  logic i_we,                                            // Bank write enable.
  input  logic [BANK_W-1:0] i_wr_bank,                          // Bank selected for update.
  input  logic [I_ENTRY_W-1:0] i_wr_lane_entries [0:L-1][0:W-1],// Replacement packed column entries.
  input  logic [LANE_COUNT_W-1:0] i_wr_lane_count [0:L-1]       // Replacement valid lane counts.
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [I_ENTRY_W-1:0] mem [0:N0-1][0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] count_mem [0:N0-1][0:L-1];

  always_comb begin
    integer lane_idx_local;
    integer slot_idx_local;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      o_rd_lane_count[lane_idx_local] = count_mem[i_rd_bank][lane_idx_local];
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        o_rd_lane_entries[lane_idx_local][slot_idx_local] =
          mem[i_rd_bank][lane_idx_local][slot_idx_local];
      end
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    integer bank_idx_local;
    integer lane_idx_local;
    integer slot_idx_local;

    if (!i_rst_n) begin
      for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
        for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
          count_mem[bank_idx_local][lane_idx_local] <= '0;
          for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
            mem[bank_idx_local][lane_idx_local][slot_idx_local] <= '0;
          end
        end
      end
    end else if (i_clear) begin
      for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
        for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
          count_mem[bank_idx_local][lane_idx_local] <= '0;
          for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
            mem[bank_idx_local][lane_idx_local][slot_idx_local] <= '0;
          end
        end
      end
    end else if (i_we) begin
      for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
        if (BANK_W'(bank_idx_local) == i_wr_bank) begin
          for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
            count_mem[bank_idx_local][lane_idx_local] <= i_wr_lane_count[lane_idx_local];
            for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
              mem[bank_idx_local][lane_idx_local][slot_idx_local] <=
                i_wr_lane_entries[lane_idx_local][slot_idx_local];
            end
          end
        end
      end
    end
  end
endmodule
