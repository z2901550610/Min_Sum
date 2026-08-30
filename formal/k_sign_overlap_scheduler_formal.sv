`timescale 1ns / 1ps

// Fixed-public-geometry proof for correction scan order, bounds, drain, and
// exact completion latency. The complete toy scan is 60 cycles plus 7 drain
// cycles; no private data enters this scheduler.
module k_sign_overlap_scheduler_formal;
  localparam int PHASE_CYCLES = 60;
  localparam int DONE_AGE = PHASE_CYCLES + 7;
  localparam int AGE_W = $clog2(DONE_AGE + 2);

  (* gclk *) logic             clk;
  (* anyseq *) logic             start;

  logic             rst_n = 1'b0;
  logic             phase_valid;
  logic [      0:0] h_block_idx;
  logic [      1:0] tile_idx;
  logic [      1:0] diag_idx_local;
  logic [      2:0] lane_group_idx;
  logic             done;
  logic             started_q;
  logic [AGE_W-1:0] age_q;
  logic             phase_valid_prev_q;
  logic             start_prev_q;
  logic [      0:0] h_block_idx_prev_q;
  logic [      1:0] tile_idx_prev_q;
  logic [      1:0] diag_idx_local_prev_q;
  logic [      2:0] lane_group_idx_prev_q;

  k_sign_overlap_scheduler_formal_dut dut (
      .clk           (clk),
      .rst_n         (rst_n),
      .start         (start),
      .phase_valid   (phase_valid),
      .h_block_idx   (h_block_idx),
      .tile_idx      (tile_idx),
      .diag_idx_local(diag_idx_local),
      .lane_group_idx(lane_group_idx),
      .done          (done)
  );

  always_ff @(posedge clk) begin
    rst_n <= 1'b1;
    if (!rst_n) begin
      assume (!start);
      started_q <= 1'b0;
      age_q <= '0;
      phase_valid_prev_q <= 1'b0;
      start_prev_q <= 1'b0;
      h_block_idx_prev_q <= '0;
      tile_idx_prev_q <= '0;
      diag_idx_local_prev_q <= '0;
      lane_group_idx_prev_q <= '0;
    end else begin
      if (started_q) assume (!start);

      if (start) begin
        started_q <= 1'b1;
        age_q <= '0;
      end else if (started_q && !done) begin
        age_q <= age_q + AGE_W'(1);
      end

      assert (!(phase_valid && done));
      if (phase_valid) begin
        assert ({1'b0, h_block_idx} < 2'd2);
        assert (tile_idx < 2'd2);
        assert (diag_idx_local < 2'd3);
        assert (lane_group_idx < 3'd5);
      end
      if (started_q && (age_q < AGE_W'(DONE_AGE))) assert (!done);
      if (started_q && (age_q == AGE_W'(DONE_AGE))) assert (done);
      if (done) assert (age_q == AGE_W'(DONE_AGE));

      if (phase_valid && phase_valid_prev_q && !start_prev_q) begin
        if (lane_group_idx_prev_q != 3'd4) begin
          assert (lane_group_idx == lane_group_idx_prev_q + 3'd1);
          assert (diag_idx_local == diag_idx_local_prev_q);
          assert (tile_idx == tile_idx_prev_q);
          assert (h_block_idx == h_block_idx_prev_q);
        end else if (diag_idx_local_prev_q != 2'd2) begin
          assert (lane_group_idx == '0);
          assert (diag_idx_local == diag_idx_local_prev_q + 2'd1);
          assert (tile_idx == tile_idx_prev_q);
          assert (h_block_idx == h_block_idx_prev_q);
        end else if (tile_idx_prev_q != 2'd1) begin
          assert (lane_group_idx == '0);
          assert (diag_idx_local == '0);
          assert (tile_idx == tile_idx_prev_q + 2'd1);
          assert (h_block_idx == h_block_idx_prev_q);
        end else if (h_block_idx_prev_q != 1'b1) begin
          assert (lane_group_idx == '0);
          assert (diag_idx_local == '0);
          assert (tile_idx == '0);
          assert (h_block_idx == h_block_idx_prev_q + 1'b1);
        end
      end

      phase_valid_prev_q <= phase_valid;
      start_prev_q <= start;
      h_block_idx_prev_q <= h_block_idx;
      tile_idx_prev_q <= tile_idx;
      diag_idx_local_prev_q <= diag_idx_local;
      lane_group_idx_prev_q <= lane_group_idx;

      cover (phase_valid);
      cover (phase_valid && (h_block_idx == 1'b1) && (tile_idx == 2'd1) &&
             (diag_idx_local == 2'd2) && (lane_group_idx == 3'd4));
      cover (done);
    end
  end
endmodule
