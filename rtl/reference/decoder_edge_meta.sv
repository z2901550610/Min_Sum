// Finds the check-row location of one "1" in the active variable column.
module decoder_edge_meta
  import bike_pkg::*;
(
  input  logic [VAR_W-1:0] i_var_idx,        // Which variable column j to inspect.
  input  logic [EDGE_W-1:0] i_edge_slot,     // Which "1" in that variable column, range 0..W-1.
  output logic [H_BLOCK_W-1:0] o_circ_idx,   // Which circulant block of H contains i_var_idx: H0, H1, ...
  output logic [ROW_W-1:0] o_circ_col_idx,   // Column index inside that circulant block, range 0..R-1.
  output logic [ROW_W-1:0] o_row_global,     // Full check-row index hit by this "1", range 0..R-1.
  output logic [ROW_W-1:0] o_row_local,      // Compact parity-local row index floor(o_row_global / 2).
  output logic [LANE_IDX_W-1:0] o_lane_idx   // 0 for even rows, 1 for odd rows.
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
    integer col_idx_local;
    integer row_idx_local;

    o_circ_idx = H_BLOCK_W'(int'(i_var_idx) / R);
    col_idx_local = int'(i_var_idx) % R;
    o_circ_col_idx = ROW_W'(col_idx_local);

    row_idx_local = (H_BASE[0][o_circ_idx][i_edge_slot] + col_idx_local) % R;
    o_row_global = ROW_W'(row_idx_local);
    o_lane_idx = LANE_IDX_W'(row_idx_local & 1);
    o_row_local = ROW_W'(row_idx_local >> 1);
  end
endmodule
