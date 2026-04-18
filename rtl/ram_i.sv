`ifdef MDPC_PAPER_CFG
import mdpc_paper_pkg::*;
`else
import mdpc_demo_pkg::*;
`endif

module ram_i (
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_load_first_col,
  input  logic i_shift,
  input  logic [H_SEL_W-1:0] i_h_sel,
  input  logic [BANK_W-1:0] i_bank_sel,
  output logic [I_ENTRY_W-1:0] o_lane_entries [0:L-1][0:W-1],
  output logic [LANE_COUNT_W-1:0] o_lane_count [0:L-1]
);

`ifdef MDPC_PAPER_CFG
  import mdpc_paper_pkg::*;
`else
  import mdpc_demo_pkg::*;
`endif

  logic [I_ENTRY_W-1:0] mem [0:N0-1][0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] count_mem [0:N0-1][0:L-1];
  logic [I_ENTRY_W-1:0] first_col_entries [0:N0-1][0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] first_col_count [0:N0-1][0:L-1];
  logic [I_ENTRY_W-1:0] shifted_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] shifted_count [0:L-1];

  // RAM I stores only the current QC column's nonzero row indices. Rows are
  // split into lane-local addresses so each lane can drive its RAM M segment.
  always_comb begin
    integer bank_idx_local;
    integer lane_idx_local;
    integer slot_idx_local;
    integer edge_idx_local;
    integer row_value_local;
    integer row_local_value;

    for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
      for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
        first_col_count[bank_idx_local][lane_idx_local] = '0;
        for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
          first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local] = '0;
        end
      end

      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        row_value_local = H_BASE[i_h_sel][bank_idx_local][edge_idx_local];
        if (row_value_local < ROW_SEG_SIZE) begin
          lane_idx_local = 0;
          row_local_value = row_value_local;
        end else begin
          lane_idx_local = 1;
          row_local_value = row_value_local - ROW_SEG_SIZE;
        end
        slot_idx_local = int'(first_col_count[bank_idx_local][lane_idx_local]);
        first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local] = {
          edge_idx_local[EDGE_W-1:0],
          row_local_value[ROW_W-1:0]
        };
        first_col_count[bank_idx_local][lane_idx_local] =
          first_col_count[bank_idx_local][lane_idx_local] + 1'b1;
      end
    end
  end

  // Advancing one QC column is a +1 mod R row rotation for the selected bank.
  // Entries may cross the lane split, so the next lane-local lists are rebuilt.
  always_comb begin
    integer lane_idx_local;
    integer slot_idx_local;
    integer row_value_local;
    integer row_local_value;
    integer next_row_value_local;
    integer next_lane_idx_local;
    integer next_slot_idx_local;
    integer next_row_local_value;

    row_value_local = 0;
    row_local_value = 0;
    next_row_value_local = 0;
    next_lane_idx_local = 0;
    next_slot_idx_local = 0;
    next_row_local_value = 0;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      shifted_count[lane_idx_local] = '0;
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        shifted_entries[lane_idx_local][slot_idx_local] = '0;
      end
    end

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        if (slot_idx_local < count_mem[i_bank_sel][lane_idx_local]) begin
          row_local_value = int'(mem[i_bank_sel][lane_idx_local][slot_idx_local][I_ENTRY_ROW_LOCAL_LSB +: ROW_W]);
          if (lane_idx_local == 0) begin
            row_value_local = row_local_value;
          end else begin
            row_value_local = ROW_SEG_SIZE + row_local_value;
          end
          next_row_value_local = (row_value_local + 1) % R;
          if (next_row_value_local < ROW_SEG_SIZE) begin
            next_lane_idx_local = 0;
            next_row_local_value = next_row_value_local;
          end else begin
            next_lane_idx_local = 1;
            next_row_local_value = next_row_value_local - ROW_SEG_SIZE;
          end
          next_slot_idx_local = int'(shifted_count[next_lane_idx_local]);
          shifted_entries[next_lane_idx_local][next_slot_idx_local] = {
            mem[i_bank_sel][lane_idx_local][slot_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W],
            next_row_local_value[ROW_W-1:0]
          };
          shifted_count[next_lane_idx_local] = shifted_count[next_lane_idx_local] + 1'b1;
        end
      end
    end
  end

  always_comb begin
    integer lane_idx_local;
    integer slot_idx_local;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      o_lane_count[lane_idx_local] = count_mem[i_bank_sel][lane_idx_local];
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        o_lane_entries[lane_idx_local][slot_idx_local] = mem[i_bank_sel][lane_idx_local][slot_idx_local];
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
          count_mem[bank_idx_local][lane_idx_local] <= first_col_count[bank_idx_local][lane_idx_local];
          for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
            mem[bank_idx_local][lane_idx_local][slot_idx_local] <=
              first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local];
          end
        end
      end
    end else if (i_load_first_col) begin
      for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
        for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
          count_mem[bank_idx_local][lane_idx_local] <= first_col_count[bank_idx_local][lane_idx_local];
          for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
            mem[bank_idx_local][lane_idx_local][slot_idx_local] <=
              first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local];
          end
        end
      end
    end else if (i_shift) begin
      for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
        count_mem[i_bank_sel][lane_idx_local] <= shifted_count[lane_idx_local];
        for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
          mem[i_bank_sel][lane_idx_local][slot_idx_local] <= shifted_entries[lane_idx_local][slot_idx_local];
        end
      end
    end
  end
endmodule
