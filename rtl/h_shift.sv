// Advances every "1" in a packed QC column by +1 mod R and reassigns row_groups.
module h_shift
  import bike_pkg::*;
(
  input  logic [I_ENTRY_W-1:0] i_row_group_entries [0:L-1][0:W-1],  // Packed "1" entries for each row_group before the shift.
  input  logic [ROW_GROUP_COUNT_W-1:0] i_row_group_count [0:L-1],         // How many "1"s are valid in each input row_group.
  output logic [I_ENTRY_W-1:0] o_row_group_entries [0:L-1][0:W-1],   // Packed "1" entries after every row index is shifted by +1 mod R.
  output logic [ROW_GROUP_COUNT_W-1:0] o_row_group_count [0:L-1]          // How many "1"s are valid in each output row_group.
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
    integer row_group_idx_local;
    integer edge_idx_local;
    integer row_value_local;
    integer next_row_value_local;
    logic [ROW_GROUP_IDX_W-1:0] next_row_group_idx_local;
    logic [EDGE_W-1:0] next_edge_idx_local;
    logic [ROW_W-1:0] row_local_value;
    logic [ROW_W-1:0] next_row_local_value;

    row_value_local = 0;
    next_row_value_local = 0;
    next_row_group_idx_local = '0;
    next_edge_idx_local = '0;
    row_local_value = '0;
    next_row_local_value = '0;

    for (row_group_idx_local = 0; row_group_idx_local < L; row_group_idx_local++) begin
      o_row_group_count[row_group_idx_local] = '0;
      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        o_row_group_entries[row_group_idx_local][edge_idx_local] = '0;
      end
    end

    for (row_group_idx_local = 0; row_group_idx_local < L; row_group_idx_local++) begin
      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        if (edge_idx_local < i_row_group_count[row_group_idx_local]) begin
          row_local_value = i_row_group_entries[row_group_idx_local][edge_idx_local][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
          if (row_group_idx_local == 0) begin
            row_value_local = int'(row_local_value);
          end else begin
            row_value_local = ROW_SEG_SIZE + int'(row_local_value);
          end

          next_row_value_local = (row_value_local + 1) % R;
          if (next_row_value_local < ROW_SEG_SIZE) begin
            next_row_group_idx_local = ROW_GROUP_IDX_W'(0);
            next_row_local_value = ROW_W'(next_row_value_local);
          end else begin
            next_row_group_idx_local = ROW_GROUP_IDX_W'(1);
            next_row_local_value = ROW_W'(next_row_value_local - ROW_SEG_SIZE);
          end

          next_edge_idx_local = EDGE_W'(o_row_group_count[next_row_group_idx_local]);
          o_row_group_entries[next_row_group_idx_local][next_edge_idx_local] = {
            i_row_group_entries[row_group_idx_local][edge_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W],
            next_row_local_value
          };
          o_row_group_count[next_row_group_idx_local] =
            o_row_group_count[next_row_group_idx_local] + 1'b1;
        end
      end
    end
  end
endmodule
