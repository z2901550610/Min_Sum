`timescale 1ns / 1ps

// Complete toy-geometry proof for fixed completion latency and phase safety.
// Production profiles retain separate full-size fixed-cycle simulation.
module tile_scheduler_formal;
  localparam int EXPECTED_CYCLES = 316;
  localparam int AGE_W = $clog2(EXPECTED_CYCLES + 2);

  (* gclk *) logic             clk;
  (* anyseq *) logic             start;

  logic             rst_n = 1'b0;
  logic [      3:0] state;
  logic             c2v_valid;
  logic             v2c_valid;
  logic             ksign_corr_valid;
  logic [      2:0] c2v_tile_linear;
  logic [      2:0] v2c_tile_linear;
  logic [      0:0] c2v_h_block_idx;
  logic [      1:0] c2v_tile_idx;
  logic [      0:0] v2c_h_block_idx;
  logic [      1:0] v2c_tile_idx;
  logic [      1:0] diag_idx_local;
  logic [      2:0] lane_group_idx;
  logic             clear_valid;
  logic [      1:0] clear_addr;
  logic             done;
  logic [      2:0] iter_count;
  logic             started_q;
  logic [AGE_W-1:0] age_q;

  tile_scheduler_formal_dut dut (
      .clk             (clk),
      .rst_n           (rst_n),
      .start           (start),
      .state           (state),
      .c2v_valid       (c2v_valid),
      .v2c_valid       (v2c_valid),
      .ksign_corr_valid(ksign_corr_valid),
      .c2v_tile_linear (c2v_tile_linear),
      .v2c_tile_linear (v2c_tile_linear),
      .c2v_h_block_idx (c2v_h_block_idx),
      .c2v_tile_idx    (c2v_tile_idx),
      .v2c_h_block_idx (v2c_h_block_idx),
      .v2c_tile_idx    (v2c_tile_idx),
      .diag_idx_local  (diag_idx_local),
      .lane_group_idx  (lane_group_idx),
      .clear_valid     (clear_valid),
      .clear_addr      (clear_addr),
      .done            (done),
      .iter_count      (iter_count)
  );

  always_ff @(posedge clk) begin
    rst_n <= 1'b1;
    if (!rst_n) begin
      assume (!start);
      started_q <= 1'b0;
      age_q <= '0;
    end else begin
      if (!started_q) begin
        assume (start);
      end else begin
        assume (!start);
      end

      if (start) begin
        started_q <= 1'b1;
        age_q <= '0;
      end else if (started_q && !done) begin
        age_q <= age_q + AGE_W'(1);
      end

      assert (!(clear_valid && (c2v_valid || v2c_valid || ksign_corr_valid)));
      assert (!ksign_corr_valid);
      if (c2v_valid || v2c_valid) begin
        assert (diag_idx_local < 2'd3);
        assert (lane_group_idx < 3'd5);
      end
      if (c2v_valid) begin
        assert (c2v_tile_linear < 3'd4);
        assert ({1'b0, c2v_h_block_idx} < 2'd2);
        assert (c2v_tile_idx < 2'd2);
      end
      if (v2c_valid) begin
        assert (v2c_tile_linear < 3'd4);
        assert ({1'b0, v2c_h_block_idx} < 2'd2);
        assert (v2c_tile_idx < 2'd2);
      end
      if (c2v_valid && v2c_valid) assert (c2v_tile_linear == v2c_tile_linear + 3'd1);
      if (clear_valid) assert ({1'b0, clear_addr} < 3'd4);

      if (started_q && (age_q < AGE_W'(EXPECTED_CYCLES))) assert (!done);
      if (started_q && (age_q == AGE_W'(EXPECTED_CYCLES))) assert (done);
      if (done) begin
        assert (age_q == AGE_W'(EXPECTED_CYCLES));
        assert (state == 4'd9);
        assert (iter_count == 3'd4);
        assert (!(clear_valid || c2v_valid || v2c_valid || ksign_corr_valid));
      end

      cover (state == 4'd4);
      cover (state == 4'd5);
      cover (state == 4'd6);
      cover (done);
    end
  end
endmodule
