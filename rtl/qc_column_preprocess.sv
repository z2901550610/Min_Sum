// Reference preprocessor that expands a QC column into lane-packed metadata.
module qc_column_preprocess
  import bike_pkg::*;
(
  input  logic [VAR_W-1:0] i_var_idx,                            // Variable index of the requested QC column.
  output logic [LANE_COUNT_W-1:0] o_col_lane_count [0:L-1],      // Number of edges assigned to each lane.
  output logic o_col_edge_valid [0:L-1][0:W-1],                  // Valid bit for each emitted lane slot.
  output logic [ROW_W-1:0] o_col_edge_row_local [0:L-1][0:W-1],  // Lane-local row index for each edge.
  output logic [ROW_W-1:0] o_col_edge_row_global [0:L-1][0:W-1], // Global row index for each edge.
  output logic [EDGE_W-1:0] o_col_edge_slot [0:L-1][0:W-1]       // Original edge slot within the circulant support.
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
    integer lane_idx_local;
    integer edge_idx_local;
    integer bank_idx_local;
    integer col_idx_local;
    integer row_value_local;
    integer lane_slot_idx_local;
    logic [ROW_W-1:0] row_local_value;

    bank_idx_local = int'(i_var_idx) / R;
    col_idx_local = int'(i_var_idx) % R;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      o_col_lane_count[lane_idx_local] = '0;
      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        o_col_edge_valid[lane_idx_local][edge_idx_local] = 1'b0;
        o_col_edge_row_local[lane_idx_local][edge_idx_local] = '0;
        o_col_edge_row_global[lane_idx_local][edge_idx_local] = '0;
        o_col_edge_slot[lane_idx_local][edge_idx_local] = '0;
      end
    end

    for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
      row_value_local = (H_BASE[0][bank_idx_local][edge_idx_local] + col_idx_local) % R;
      if (row_value_local < ROW_SEG_SIZE) begin
        lane_idx_local = 0;
        row_local_value = ROW_W'(row_value_local);
      end else begin
        lane_idx_local = 1;
        row_local_value = ROW_W'(row_value_local - ROW_SEG_SIZE);
      end
      lane_slot_idx_local = int'(o_col_lane_count[lane_idx_local]);
      o_col_edge_valid[lane_idx_local][lane_slot_idx_local] = 1'b1;
      o_col_edge_row_local[lane_idx_local][lane_slot_idx_local] = row_local_value;
      o_col_edge_row_global[lane_idx_local][lane_slot_idx_local] = ROW_W'(row_value_local);
      o_col_edge_slot[lane_idx_local][lane_slot_idx_local] = EDGE_W'(edge_idx_local);
      o_col_lane_count[lane_idx_local] =
        o_col_lane_count[lane_idx_local] + 1'b1;
    end
  end
endmodule
