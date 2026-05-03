// Reference preprocessor that lists the "1"s in a QC column by group.
module qc_column_preprocess
  import bike_pkg::*;
(
  input  logic [VAR_W-1:0] i_var_idx,                            // Which variable column j to expand.
  output logic [GROUP_COUNT_W-1:0] o_col_group_count [0:L-1],     // How many "1"s from this column belong to each group.
  output logic o_col_one_valid [0:L-1][0:W-1],                   // Whether this output slot holds a valid "1".
  output logic [ROW_IDX_W-1:0] o_col_one_row_idx_group [0:L-1][0:W-1], // Compact parity-local row index floor(row_global / L).
  output logic [ROW_IDX_W-1:0] o_col_one_row_idx_global [0:L-1][0:W-1], // Full check-row index hit by this "1", range 0..R-1.
  output logic [ONE_IDX_W-1:0] o_col_one_idx_global [0:L-1][0:W-1]       // Which "1" in this variable column, range 0..W-1.
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
    integer group_idx_local;
    integer one_idx_local;
    integer circ_idx_local;
    integer col_idx_local;
    integer row_idx_global_local;
    integer group_entry_idx_local;
    logic [ROW_IDX_W-1:0] row_idx_group_value;

    circ_idx_local = int'(i_var_idx) / R;
    col_idx_local = int'(i_var_idx) % R;

    for (group_idx_local = 0; group_idx_local < L; group_idx_local++) begin
      o_col_group_count[group_idx_local] = '0;
      for (one_idx_local = 0; one_idx_local < W; one_idx_local++) begin
        o_col_one_valid[group_idx_local][one_idx_local] = 1'b0;
        o_col_one_row_idx_group[group_idx_local][one_idx_local] = '0;
        o_col_one_row_idx_global[group_idx_local][one_idx_local] = '0;
        o_col_one_idx_global[group_idx_local][one_idx_local] = '0;
      end
    end

    for (one_idx_local = 0; one_idx_local < W; one_idx_local++) begin
      row_idx_global_local = (H_BASE[0][circ_idx_local][one_idx_local] + col_idx_local) % R;
      group_idx_local = row_idx_global_local & 1;
      row_idx_group_value = ROW_IDX_W'(row_idx_global_local >> 1);
      group_entry_idx_local = int'(o_col_group_count[group_idx_local]);
      o_col_one_valid[group_idx_local][group_entry_idx_local] = 1'b1;
      o_col_one_row_idx_group[group_idx_local][group_entry_idx_local] = row_idx_group_value;
      o_col_one_row_idx_global[group_idx_local][group_entry_idx_local] = ROW_IDX_W'(row_idx_global_local);
      o_col_one_idx_global[group_idx_local][group_entry_idx_local] = ONE_IDX_W'(one_idx_local);
      o_col_group_count[group_idx_local] =
        o_col_group_count[group_idx_local] + 1'b1;
    end
  end
endmodule
