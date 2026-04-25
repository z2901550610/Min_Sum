// Advances every "1" in a packed QC column by +1 mod R and reassigns row_groups.
// row_group 0 stores even rows, row_group 1 stores odd rows, and row_local is
// the compact parity-local index floor(row_global / 2).
module h_shift
  import bike_pkg::*;
(
  input  logic [I_ENTRY_W-1:0] i_group0_entries [0:W-1],   // Packed entries for even-row metadata before the shift.
  input  logic [ROW_GROUP_COUNT_W-1:0] i_group0_count,     // How many even-row entries are valid.
  input  logic [I_ENTRY_W-1:0] i_group1_entries [0:W-1],   // Packed entries for odd-row metadata before the shift.
  input  logic [ROW_GROUP_COUNT_W-1:0] i_group1_count,     // How many odd-row entries are valid.
  output logic [I_ENTRY_W-1:0] o_group0_entries [0:W-1],   // Packed entries after the shift that land on even rows.
  output logic [ROW_GROUP_COUNT_W-1:0] o_group0_count,     // How many shifted entries land on even rows.
  output logic [I_ENTRY_W-1:0] o_group1_entries [0:W-1],   // Packed entries after the shift that land on odd rows.
  output logic [ROW_GROUP_COUNT_W-1:0] o_group1_count      // How many shifted entries land on odd rows.
);

  timeunit 1ns;
  timeprecision 1ps;

  always_comb begin
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

    o_group0_count = '0;
    o_group1_count = '0;
    for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
      o_group0_entries[edge_idx_local] = '0;
      o_group1_entries[edge_idx_local] = '0;
    end

    for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
      if (edge_idx_local < i_group0_count) begin
        row_local_value = i_group0_entries[edge_idx_local][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
        row_value_local = int'(row_local_value) << 1;
        next_row_value_local = (row_value_local + 1) % R;
        next_row_group_idx_local = ROW_GROUP_IDX_W'(next_row_value_local & 1);
        next_row_local_value = ROW_W'(next_row_value_local >> 1);

        if (next_row_group_idx_local == ROW_GROUP_IDX_W'(0)) begin
          next_edge_idx_local = EDGE_W'(o_group0_count);
          o_group0_entries[next_edge_idx_local] = {
            i_group0_entries[edge_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W],
            next_row_local_value
          };
          o_group0_count = o_group0_count + 1'b1;
        end else begin
          next_edge_idx_local = EDGE_W'(o_group1_count);
          o_group1_entries[next_edge_idx_local] = {
            i_group0_entries[edge_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W],
            next_row_local_value
          };
          o_group1_count = o_group1_count + 1'b1;
        end
      end
    end

    for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
      if (edge_idx_local < i_group1_count) begin
        row_local_value = i_group1_entries[edge_idx_local][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
        row_value_local = (int'(row_local_value) << 1) | 1;
        next_row_value_local = (row_value_local + 1) % R;
        next_row_group_idx_local = ROW_GROUP_IDX_W'(next_row_value_local & 1);
        next_row_local_value = ROW_W'(next_row_value_local >> 1);

        if (next_row_group_idx_local == ROW_GROUP_IDX_W'(0)) begin
          next_edge_idx_local = EDGE_W'(o_group0_count);
          o_group0_entries[next_edge_idx_local] = {
            i_group1_entries[edge_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W],
            next_row_local_value
          };
          o_group0_count = o_group0_count + 1'b1;
        end else begin
          next_edge_idx_local = EDGE_W'(o_group1_count);
          o_group1_entries[next_edge_idx_local] = {
            i_group1_entries[edge_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W],
            next_row_local_value
          };
          o_group1_count = o_group1_count + 1'b1;
        end
      end
    end
  end
endmodule
