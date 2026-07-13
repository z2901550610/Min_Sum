`timescale 1ns / 1ps
// Combinational cyclic lane rotation implemented as a logarithmic mux network.
module barrel_rotate #(
    parameter int DATA_W = 1
) (
    input  logic [              DATA_W-1:0] i_data[0:bike_pkg::L-1],
    input  logic [bike_pkg::LANE_IDX_W-1:0] i_shift,
    output logic [              DATA_W-1:0] o_data[0:bike_pkg::L-1]
);

  import bike_pkg::*;

  /* verilator lint_off UNOPTFLAT */
  logic [DATA_W-1:0] stage[0:L_SHIFT][0:L-1];
  /* verilator lint_on UNOPTFLAT */

  generate
    for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_input
      assign stage[0][lane_idx] = i_data[lane_idx];
    end

    for (genvar stage_idx = 0; stage_idx < L_SHIFT; stage_idx++) begin : g_stage
      localparam int STAGE_OFFSET = 1 << stage_idx;
      for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane
        localparam int SHIFTED_LANE = (lane_idx + STAGE_OFFSET) % L;
        assign stage[stage_idx+1][lane_idx] =
            i_shift[stage_idx] ? stage[stage_idx][SHIFTED_LANE] : stage[stage_idx][lane_idx];
      end
    end

    for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_output
      assign o_data[lane_idx] = stage[L_SHIFT][lane_idx];
    end
  endgenerate
endmodule
