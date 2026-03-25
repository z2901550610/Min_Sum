import mdpc_demo_pkg::*;

module mdpc_i_ram (
  input  logic clk,
  input  logic rst_n,
  input  logic load_first_col_en,
  input  logic shift_en,
  input  logic [0:0] bank_sel,
  output logic [I_ENTRY_W-1:0] lane_entries [0:L-1][0:W-1],
  output logic [1:0] lane_count [0:L-1]
);

  logic [I_ENTRY_W-1:0] mem [0:N0-1][0:L-1][0:W-1];
  logic [1:0] count_mem [0:N0-1][0:L-1];
  logic [I_ENTRY_W-1:0] first_col_entries [0:N0-1][0:L-1][0:W-1];
  logic [1:0] first_col_count [0:N0-1][0:L-1];
  logic [I_ENTRY_W-1:0] shifted_entries [0:L-1][0:W-1];
  logic [1:0] shifted_count [0:L-1];

  always_comb begin
    integer bank_idx_local;
    integer lane_idx_local;
    integer slot_idx_local;
    integer edge_idx_local;
    integer row_value_local;

    for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
      for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
        first_col_count[bank_idx_local][lane_idx_local] = '0;
        for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
          first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local] = '0;
        end
      end

      for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
        row_value_local = H_BASE[bank_idx_local][edge_idx_local];
        lane_idx_local = row_segment(row_value_local);
        slot_idx_local = int'(first_col_count[bank_idx_local][lane_idx_local]);
        first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local] = i_entry_pack(
          row_local_from_global(row_value_local),
          edge_idx_local[EDGE_W-1:0]
        );
        first_col_count[bank_idx_local][lane_idx_local] =
          first_col_count[bank_idx_local][lane_idx_local] + 1'b1;
      end
    end
  end

  always_comb begin
    integer lane_idx_local;
    integer slot_idx_local;
    integer row_value_local;
    integer next_row_value_local;
    integer next_lane_idx_local;
    integer next_slot_idx_local;

    row_value_local = 0;
    next_row_value_local = 0;
    next_lane_idx_local = 0;
    next_slot_idx_local = 0;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      shifted_count[lane_idx_local] = '0;
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        shifted_entries[lane_idx_local][slot_idx_local] = '0;
      end
    end

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        if (slot_idx_local < count_mem[bank_sel][lane_idx_local]) begin
          row_value_local = int'(row_global_from_lane_local(
            lane_idx_local,
            i_entry_row_local(mem[bank_sel][lane_idx_local][slot_idx_local])
          ));
          next_row_value_local = (row_value_local + 1) % R;
          next_lane_idx_local = row_segment(next_row_value_local);
          next_slot_idx_local = int'(shifted_count[next_lane_idx_local]);
          shifted_entries[next_lane_idx_local][next_slot_idx_local] = i_entry_pack(
            row_local_from_global(next_row_value_local),
            i_entry_edge_slot(mem[bank_sel][lane_idx_local][slot_idx_local])
          );
          shifted_count[next_lane_idx_local] = shifted_count[next_lane_idx_local] + 1'b1;
        end
      end
    end
  end

  always_comb begin
    integer lane_idx_local;
    integer slot_idx_local;

    for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
      lane_count[lane_idx_local] = count_mem[bank_sel][lane_idx_local];
      for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
        lane_entries[lane_idx_local][slot_idx_local] = mem[bank_sel][lane_idx_local][slot_idx_local];
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    integer bank_idx_local;
    integer lane_idx_local;
    integer slot_idx_local;

    if (!rst_n) begin
      for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
        for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
          count_mem[bank_idx_local][lane_idx_local] <= first_col_count[bank_idx_local][lane_idx_local];
          for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
            mem[bank_idx_local][lane_idx_local][slot_idx_local] <=
              first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local];
          end
        end
      end
    end else if (load_first_col_en) begin
      for (bank_idx_local = 0; bank_idx_local < N0; bank_idx_local++) begin
        for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
          count_mem[bank_idx_local][lane_idx_local] <= first_col_count[bank_idx_local][lane_idx_local];
          for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
            mem[bank_idx_local][lane_idx_local][slot_idx_local] <=
              first_col_entries[bank_idx_local][lane_idx_local][slot_idx_local];
          end
        end
      end
    end else if (shift_en) begin
      for (lane_idx_local = 0; lane_idx_local < L; lane_idx_local++) begin
        count_mem[bank_sel][lane_idx_local] <= shifted_count[lane_idx_local];
        for (slot_idx_local = 0; slot_idx_local < W; slot_idx_local++) begin
          mem[bank_sel][lane_idx_local][slot_idx_local] <= shifted_entries[lane_idx_local][slot_idx_local];
        end
      end
    end
  end
endmodule
