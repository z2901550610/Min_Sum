`timescale 1ns / 1ps

module tb_tile_scheduler;
  import bike_pkg::*;

  logic                   clk;
  logic                   rst_n;
  logic                   start;
  logic                   sample_reset;
  logic [DEC_STATE_W-1:0] state;
  logic                   c2v_valid;
  logic                   v2c_valid;
  logic [  TILE_ID_W-1:0] c2v_tile_linear;
  logic [  TILE_ID_W-1:0] v2c_tile_linear;
  logic [  H_BLOCK_W-1:0] c2v_h_block_idx;
  logic [ TILE_IDX_W-1:0] c2v_tile_idx;
  logic [  H_BLOCK_W-1:0] v2c_h_block_idx;
  logic [ TILE_IDX_W-1:0] v2c_tile_idx;
  logic [  ONE_IDX_W-1:0] one_idx;
  logic [    Q_SEQ_W-1:0] q_seq;
  logic                   clear_valid;
  logic [ROW_BANK_AW-1:0] clear_addr;
  logic                   fill_buf;
  logic                   active_buf;
  logic                   final_iter;
  logic                   iter_first_cycle;
  logic                   iter_last_cycle;
  logic                   done;
  logic [     ITER_W-1:0] iter_count;

  int                     cycle_count;
  logic                   saw_prime;
  logic                   saw_overlap;
  logic                   saw_drain;
  int                     clear_count;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [  H_BLOCK_W-1:0] observed_c2v_h_block_idx;
  logic [ TILE_IDX_W-1:0] observed_c2v_tile_idx;
  logic [  H_BLOCK_W-1:0] observed_v2c_h_block_idx;
  logic [ TILE_IDX_W-1:0] observed_v2c_tile_idx;
  logic [  ONE_IDX_W-1:0] observed_one_idx;
  logic [    Q_SEQ_W-1:0] observed_q_seq;
  logic                   observed_fill_buf;
  logic                   observed_active_buf;
  logic                   observed_final_iter;
  logic                   observed_iter_first_cycle;
  logic                   observed_iter_last_cycle;
  /* verilator lint_on UNUSEDSIGNAL */

  tile_scheduler dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_cfg_w(CFG_W_W'(W)),
      .i_cfg_tile_count(TILE_IDX_W'(TILE_COUNT)),
      .i_cfg_row_seg_size(ROW_BANK_AW'(ROW_SEG_SIZE)),
      .o_state(state),
      .o_c2v_valid(c2v_valid),
      .o_v2c_valid(v2c_valid),
      .o_c2v_tile_linear(c2v_tile_linear),
      .o_v2c_tile_linear(v2c_tile_linear),
      .o_c2v_h_block_idx(c2v_h_block_idx),
      .o_c2v_tile_idx(c2v_tile_idx),
      .o_v2c_h_block_idx(v2c_h_block_idx),
      .o_v2c_tile_idx(v2c_tile_idx),
      .o_one_idx(one_idx),
      .o_q_seq(q_seq),
      .o_clear_valid(clear_valid),
      .o_clear_addr(clear_addr),
      .o_fill_buf(fill_buf),
      .o_active_buf(active_buf),
      .o_final_iter(final_iter),
      .o_iter_first_cycle(iter_first_cycle),
      .o_iter_last_cycle(iter_last_cycle),
      .o_done(done),
      .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always_ff @(posedge clk) begin
    if (sample_reset) begin
      saw_prime <= 1'b0;
      saw_overlap <= 1'b0;
      saw_drain <= 1'b0;
      clear_count <= 0;
      observed_c2v_h_block_idx <= '0;
      observed_c2v_tile_idx <= '0;
      observed_v2c_h_block_idx <= '0;
      observed_v2c_tile_idx <= '0;
      observed_one_idx <= '0;
      observed_q_seq <= '0;
      observed_fill_buf <= 1'b0;
      observed_active_buf <= 1'b0;
      observed_final_iter <= 1'b0;
      observed_iter_first_cycle <= 1'b0;
      observed_iter_last_cycle <= 1'b0;
    end else if (done !== 1'b1) begin
      observed_c2v_h_block_idx <= c2v_h_block_idx;
      observed_c2v_tile_idx <= c2v_tile_idx;
      observed_v2c_h_block_idx <= v2c_h_block_idx;
      observed_v2c_tile_idx <= v2c_tile_idx;
      observed_one_idx <= one_idx;
      observed_q_seq <= q_seq;
      observed_fill_buf <= fill_buf;
      observed_active_buf <= active_buf;
      observed_final_iter <= final_iter;
      observed_iter_first_cycle <= iter_first_cycle;
      observed_iter_last_cycle <= iter_last_cycle;
      if (clear_valid) begin
        clear_count <= clear_count + 1;
        if (c2v_valid || v2c_valid) $fatal(1, "scheduler clear overlap with main phase");
        if (clear_addr >= ROW_BANK_AW'(ROW_SEG_SIZE)) $fatal(1, "scheduler clear addr range");
      end
      if (c2v_valid && !v2c_valid) saw_prime <= 1'b1;
      if (c2v_valid && v2c_valid) begin
        saw_overlap <= 1'b1;
        if (c2v_tile_linear != (v2c_tile_linear + TILE_ID_W'(1))) begin
          $fatal(1, "tile overlap spacing mismatch");
        end
      end
      if (!c2v_valid && v2c_valid) saw_drain <= 1'b1;
    end
  end

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    sample_reset = 1'b1;
    cycle_count = 0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    sample_reset = 1'b0;
    @(posedge clk);

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    while (done !== 1'b1) begin
      cycle_count++;
      if (cycle_count > 20000) $fatal(1, "tile_scheduler timeout");
      @(posedge clk);
    end

    if (cycle_count != I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE)) begin
      $fatal(1, "tile_scheduler cycle mismatch: got %0d exp %0d", cycle_count,
             I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE));
    end
    if (clear_count != I_MAX * ROW_SEG_SIZE)
      $fatal(
          1,
          "tile_scheduler clear count mismatch: got %0d exp %0d",
          clear_count,
          I_MAX * ROW_SEG_SIZE
      );
    if (iter_count != ITER_W'(I_MAX)) $fatal(1, "tile_scheduler iter mismatch");
    if (!saw_prime || !saw_overlap || !saw_drain) $fatal(1, "missing scheduler phase");
    if (state != DEC_DONE) $fatal(1, "tile_scheduler final state mismatch");

    $display("tb_tile_scheduler PASS");
    $finish;
  end
endmodule
