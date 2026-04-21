// Advances every "1" in a packed QC column by +1 mod R and reassigns lanes.
module h_shift
  import bike_pkg::*;
(
  input  logic [I_ENTRY_W-1:0] i_lane_entries [0:L-1][0:W-1],  // Packed "1" entries for each lane before the shift.
  input  logic [LANE_COUNT_W-1:0] i_lane_count [0:L-1],         // How many "1"s are valid in each input lane.
  output logic [I_ENTRY_W-1:0] o_lane_entries [0:L-1][0:W-1],   // Packed "1" entries after every row index is shifted by +1 mod R.
  output logic [LANE_COUNT_W-1:0] o_lane_count [0:L-1]          // How many "1"s are valid in each output lane.
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
    integer lane_idx_local;
    integer slot_idx_local;
    integer row_value_local;
    integer next_row_value_local;
    logic [LANE_IDX_W-1:0] next_lane_idx_local;
    logic [EDGE_W-1:0] next_slot_idx_local;
    logic [ROW_W-1:0] row_local_value;
    logic [ROW_W-1:0] next_row_local_value;

    row_value_local = 0;
    next_row_value_local = 0;
    next_lane_idx_local = '0;
    next_slot_idx_local = '0;
    row_local_value = '0;
    next_row_local_value = '0;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      o_lane_count[lane_idx_local] = '0;
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        o_lane_entries[lane_idx_local][slot_idx_local] = '0;
      end
    end

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        if (slot_idx_local < i_lane_count[lane_idx_local]) begin
          row_local_value = i_lane_entries[lane_idx_local][slot_idx_local][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
          if (lane_idx_local == 0) begin
            row_value_local = int'(row_local_value);
          end else begin
            row_value_local = ROW_SEG_SIZE + int'(row_local_value);
          end

          next_row_value_local = (row_value_local + 1) % R;
          if (next_row_value_local < ROW_SEG_SIZE) begin
            next_lane_idx_local = LANE_IDX_W'(0);
            next_row_local_value = ROW_W'(next_row_value_local);
          end else begin
            next_lane_idx_local = LANE_IDX_W'(1);
            next_row_local_value = ROW_W'(next_row_value_local - ROW_SEG_SIZE);
          end

          next_slot_idx_local = EDGE_W'(o_lane_count[next_lane_idx_local]);
          o_lane_entries[next_lane_idx_local][next_slot_idx_local] = {
            i_lane_entries[lane_idx_local][slot_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W],
            next_row_local_value
          };
          o_lane_count[next_lane_idx_local] =
            o_lane_count[next_lane_idx_local] + 1'b1;
        end
      end
    end
  end
endmodule
