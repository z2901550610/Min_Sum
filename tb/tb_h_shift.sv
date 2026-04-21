`timescale 1ns/1ps

module tb_h_shift;
  import bike_pkg::*;

  logic [I_ENTRY_W-1:0] lane_entries_in [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] lane_count_in [0:L-1];
  logic [I_ENTRY_W-1:0] lane_entries_out [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] lane_count_out [0:L-1];
  integer lane_idx;
  integer slot_idx;

  h_shift dut (
    .i_lane_entries(lane_entries_in),
    .i_lane_count(lane_count_in),
    .o_lane_entries(lane_entries_out),
    .o_lane_count(lane_count_out)
  );

  initial begin
    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      lane_count_in[lane_idx] = '0;
      for (slot_idx = 0; slot_idx < W; slot_idx++) begin
        lane_entries_in[lane_idx][slot_idx] = '0;
      end
    end

    lane_count_in[0] = LANE_COUNT_W'(2);
    lane_count_in[1] = LANE_COUNT_W'(1);
    lane_entries_in[0][0] = {EDGE_W'(0), ROW_W'(3)};
    lane_entries_in[0][1] = {EDGE_W'(2), ROW_W'(1)};
    lane_entries_in[1][0] = {EDGE_W'(1), ROW_W'(3)};

    #1;
    if (lane_count_out[0] != 2 || lane_count_out[1] != 1) $fatal(1, "h_shift output counts mismatch");
    if (lane_entries_out[0][0] != {EDGE_W'(2), ROW_W'(2)}) $fatal(1, "h_shift lane0 first entry mismatch");
    if (lane_entries_out[0][1] != {EDGE_W'(1), ROW_W'(0)}) $fatal(1, "h_shift wrapped entry mismatch");
    if (lane_entries_out[1][0] != {EDGE_W'(0), ROW_W'(0)}) $fatal(1, "h_shift crossing entry mismatch");

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      lane_count_in[lane_idx] = '0;
      for (slot_idx = 0; slot_idx < W; slot_idx++) begin
        lane_entries_in[lane_idx][slot_idx] = '0;
      end
    end

    lane_count_in[0] = LANE_COUNT_W'(1);
    lane_count_in[1] = LANE_COUNT_W'(2);
    lane_entries_in[0][0] = {EDGE_W'(1), ROW_W'(ROW_SEG_SIZE - 1)};
    lane_entries_in[1][0] = {EDGE_W'(0), ROW_W'(R - ROW_SEG_SIZE - 2)};
    lane_entries_in[1][1] = {EDGE_W'(2), ROW_W'(R - ROW_SEG_SIZE - 1)};

    #1;
    if (lane_count_out[0] != 1 || lane_count_out[1] != 2) $fatal(1, "h_shift second output counts mismatch");
    if (lane_entries_out[0][0] != {EDGE_W'(2), ROW_W'(0)}) $fatal(1, "h_shift second wrapped edge slot mismatch");
    if (lane_entries_out[1][0] != {EDGE_W'(1), ROW_W'(0)}) $fatal(1, "h_shift second crossing edge slot mismatch");
    if (lane_entries_out[1][1] != {EDGE_W'(0), ROW_W'(R - ROW_SEG_SIZE - 1)}) $fatal(1, "h_shift second lane1 advance mismatch");

    $display("tb_h_shift PASS");
    $finish;
  end
endmodule
