import mdpc_demo_pkg::*;

module mdpc_h_shift (
  input  logic [VAR_W-1:0] var_idx,
  input  logic [I_ENTRY_W-1:0] lane_entries [0:L-1][0:W-1],
  input  logic [1:0] lane_count [0:L-1],
  output logic [LANE_EDGE_W-1:0] lane_edges [0:L-1][0:W-1]
);

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
          row_local_value = i_entry_row_local(lane_entries[lane_idx_local][edge_idx_local]);
          row_global_value = row_global_from_lane_local(lane_idx_local, row_local_value);
          edge_slot_value = i_entry_edge_slot(lane_entries[lane_idx_local][edge_idx_local]);
          lane_edges[lane_idx_local][edge_idx_local] = lane_edge_pack(
            1'b1,
            row_local_value,
            row_global_value,
            var_idx,
            edge_slot_value
          );
        end else begin
          lane_edges[lane_idx_local][edge_idx_local] = '0;
        end
      end
    end
  end
endmodule
