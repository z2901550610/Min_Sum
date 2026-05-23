`timescale 1ns / 1ps
// L-wide RAM-I loader for first-column support rows.
module ram_i_idx_loader
  import bike_pkg::*;
(
    input  logic                     i_clk,
    input  logic                     i_rst_n,
    input  logic                     i_start,
    input  logic                     i_valid,
    input  logic [    ROW_IDX_W-1:0] i_row_idx_global[0:L-1],
    output logic                     o_ready,
    output logic                     o_busy,
    output logic                     o_done,
    output logic [    H_BLOCK_W-1:0] o_request_h_block_idx,
    output logic [  ENTRY_POS_W-1:0] o_request_entry_pos,
    output logic                     o_lane_we[0:L-1],
    output logic [    H_BLOCK_W-1:0] o_write_h_block_idx,
    output logic [  ENTRY_POS_W-1:0] o_write_entry_idx,
    output logic [    I_ENTRY_W-1:0] o_entry_wdata[0:L-1],
    output logic                     o_count_we[0:L-1],
    output logic [GROUP_COUNT_W-1:0] o_count_wdata[0:L-1]
);

  localparam bit L_IS_POWER_OF_TWO = (L > 0) && ((L & (L - 1)) == 0);

  logic [  H_BLOCK_W-1:0] load_h_block_idx;
  logic [ENTRY_POS_W-1:0] load_entry_pos;
  logic [  ENTRY_POS_W:0] next_entry_pos_ext;
  logic                   accepted;
  logic                   block_last_entry;
  logic                   all_done;

`ifndef SYNTHESIS
  initial begin
    if (!L_IS_POWER_OF_TWO) begin
      $fatal(1, "ram_i_idx_loader requires L to be a power of two");
    end
  end
`endif

  assign accepted = o_busy && i_valid;
  assign o_ready = o_busy;
  assign o_request_h_block_idx = load_h_block_idx;
  assign o_request_entry_pos = load_entry_pos;
  assign o_write_h_block_idx = o_request_h_block_idx;
  assign o_write_entry_idx = o_request_entry_pos;
  assign next_entry_pos_ext = {1'b0, o_request_entry_pos} + 1'b1;
  assign block_last_entry = (next_entry_pos_ext >= (ENTRY_POS_W + 1)'(RAM_LANE_DEPTH));
  assign all_done = accepted && block_last_entry && (load_h_block_idx == H_BLOCK_W'(N0 - 1));

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      int unsigned one_idx;
      logic        lane_valid;

      one_idx = (int'(o_request_entry_pos) << LANE_IDX_W) + lane_idx;
      lane_valid = accepted && (one_idx < W);
      o_lane_we[lane_idx] = lane_valid;
      o_entry_wdata[lane_idx] = {ONE_IDX_W'(one_idx), i_row_idx_global[lane_idx]};
      o_count_we[lane_idx] = accepted && block_last_entry;
      o_count_wdata[lane_idx] =
        GROUP_COUNT_W'(((W + L - 1 - lane_idx) > 0) ? ((W + L - 1 - lane_idx) >> LANE_IDX_W) : 0);
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_busy <= 1'b0;
      o_done <= 1'b0;
      load_h_block_idx <= '0;
      load_entry_pos <= '0;
    end else begin
      o_done <= 1'b0;
      if (i_start) begin
        o_busy <= 1'b1;
        load_h_block_idx <= '0;
        load_entry_pos <= '0;
      end else if (accepted) begin
        if (all_done) begin
          o_busy <= 1'b0;
          o_done <= 1'b1;
          load_h_block_idx <= '0;
          load_entry_pos <= '0;
        end else if (block_last_entry) begin
          load_h_block_idx <= load_h_block_idx + 1'b1;
          load_entry_pos   <= '0;
        end else begin
          load_entry_pos <= load_entry_pos + 1'b1;
        end
      end
    end
  end
endmodule
