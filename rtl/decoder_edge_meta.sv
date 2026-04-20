// Derives row/lane metadata for one QC edge in the active variable column.
module decoder_edge_meta
  import bike_pkg::*;
(
  input  logic [VAR_W-1:0] i_var_idx,
  input  logic [EDGE_W-1:0] i_edge_idx,
  output logic [BANK_W-1:0] o_bank_idx,
  output logic [ROW_W-1:0] o_col_idx,
  output logic [ROW_W-1:0] o_row_global,
  output logic [ROW_W-1:0] o_row_local,
  output logic [LANE_IDX_W-1:0] o_lane_idx
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
    integer col_idx_local;
    integer row_idx_local;

    o_bank_idx = BANK_W'(int'(i_var_idx) / R);
    col_idx_local = int'(i_var_idx) % R;
    o_col_idx = ROW_W'(col_idx_local);

    row_idx_local = (H_BASE[0][o_bank_idx][i_edge_idx] + col_idx_local) % R;
    o_row_global = ROW_W'(row_idx_local);
    if (row_idx_local < ROW_SEG_SIZE) begin
      o_lane_idx = LANE_IDX_W'(0);
      o_row_local = ROW_W'(row_idx_local);
    end else begin
      o_lane_idx = LANE_IDX_W'(1);
      o_row_local = ROW_W'(row_idx_local - ROW_SEG_SIZE);
    end
  end
endmodule
