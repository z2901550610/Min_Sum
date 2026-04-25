// Reference preprocessor that lists the "1"s in a QC column by lane.
module qc_column_preprocess
  import bike_pkg::*;
(
  input  logic [VAR_W-1:0] i_var_idx,                            // Which variable column j to expand.
  output logic [LANE_COUNT_W-1:0] o_col_lane_count [0:L-1],      // How many "1"s from this column belong to each lane.
  output logic o_col_one_valid [0:L-1][0:W-1],                   // Whether this output slot holds a valid "1".
  output logic [ROW_W-1:0] o_col_one_row_local [0:L-1][0:W-1],   // Compact parity-local row index floor(row_global / 2).
  output logic [ROW_W-1:0] o_col_one_row_global [0:L-1][0:W-1], // Full check-row index hit by this "1", range 0..R-1.
  output logic [EDGE_W-1:0] o_col_one_slot [0:L-1][0:W-1]        // Which "1" in this variable column, range 0..W-1.
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
    integer lane_idx_local;
    integer edge_idx_local;
    integer circ_idx_local;
    integer col_idx_local;
    integer row_value_local;
    integer lane_slot_idx_local;
    logic [ROW_W-1:0] row_local_value;

    circ_idx_local = int'(i_var_idx) / R;
    col_idx_local = int'(i_var_idx) % R;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      o_col_lane_count[lane_idx_local] = '0;
      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        o_col_one_valid[lane_idx_local][edge_idx_local] = 1'b0;
        o_col_one_row_local[lane_idx_local][edge_idx_local] = '0;
        o_col_one_row_global[lane_idx_local][edge_idx_local] = '0;
        o_col_one_slot[lane_idx_local][edge_idx_local] = '0;
      end
    end

    for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
      row_value_local = (H_BASE[0][circ_idx_local][edge_idx_local] + col_idx_local) % R;
      lane_idx_local = row_value_local & 1;
      row_local_value = ROW_W'(row_value_local >> 1);
      lane_slot_idx_local = int'(o_col_lane_count[lane_idx_local]);
      o_col_one_valid[lane_idx_local][lane_slot_idx_local] = 1'b1;
      o_col_one_row_local[lane_idx_local][lane_slot_idx_local] = row_local_value;
      o_col_one_row_global[lane_idx_local][lane_slot_idx_local] = ROW_W'(row_value_local);
      o_col_one_slot[lane_idx_local][lane_slot_idx_local] = EDGE_W'(edge_idx_local);
      o_col_lane_count[lane_idx_local] =
        o_col_lane_count[lane_idx_local] + 1'b1;
    end
  end
endmodule
