module mdpc_h_shift (
  input  logic [VAR_W-1:0] var_idx,
  input  logic [I_ENTRY_W-1:0] lane_entries [0:L-1][0:W-1],
  input  logic [LANE_COUNT_W-1:0] lane_count [0:L-1],
  output logic [LANE_EDGE_W-1:0] lane_edges [0:L-1][0:W-1]
);

  import mdpc_demo_pkg::*;

  // Expand lane-local RAM I entries into global edge descriptors used by the
  // top-level scheduler. row_local addresses lane memories; row_global indexes
  // the full parity-check row space.
  always_comb begin
    integer lane_idx_local;
    integer edge_idx_local;
    logic [ROW_W-1:0] row_local_value;
    logic [ROW_W-1:0] row_global_value;
    logic [EDGE_W-1:0] edge_slot_value;

    row_local_value = '0;
    row_global_value = '0;
    edge_slot_value = '0;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        if (edge_idx_local < lane_count[lane_idx_local]) begin
          row_local_value = lane_entries[lane_idx_local][edge_idx_local][I_ENTRY_ROW_LOCAL_LSB +: ROW_W];
          if (lane_idx_local == 0) begin
            row_global_value = row_local_value;
          end else begin
            row_global_value = ROW_W'(ROW_SPLIT + int'(row_local_value));
          end
          edge_slot_value = lane_entries[lane_idx_local][edge_idx_local][I_ENTRY_EDGE_SLOT_LSB +: EDGE_W];
          lane_edges[lane_idx_local][edge_idx_local] = {
            edge_slot_value,
            var_idx,
            row_global_value,
            row_local_value,
            1'b1
          };
        end else begin
          lane_edges[lane_idx_local][edge_idx_local] = '0;
        end
      end
    end
  end
endmodule
