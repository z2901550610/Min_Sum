`timescale 1ns / 1ps

module tb_decoder_top;
  import bike_pkg::*;

  /* verilator lint_off UNUSEDPARAM */
  `include "tb/generated/bike_toy_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  logic                 clk;
  logic                 rst_n;
  logic                 start;
  logic                 syndrome_we;
  logic [ROW_IDX_W-1:0] syndrome_addr;
  logic                 syndrome_wdata;
  logic                 h_we;
  logic [H_BLOCK_W-1:0] h_load_block_idx;
  logic [ONE_IDX_W-1:0] h_load_one_idx;
  logic [ROW_IDX_W-1:0] h_base_row;
  logic                 h_loaded;
  logic                 h_error;
  logic                 done;
  logic [    COL_W-1:0] e_read_col_idx;
  logic                 e_rdata;
  logic [        N-1:0] e_out;
  logic [   ITER_W-1:0] iter_count;
  logic                 saw_overlap;
  logic                 saw_guard_dummy;
  logic                 guard_any_valid;
  logic                 checks_active;
  int                   decode_cycles;

  decoder_top dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_syndrome_we(syndrome_we),
      .i_syndrome_addr(syndrome_addr),
      .i_syndrome_wdata(syndrome_wdata),
      .i_h_we(h_we),
      .i_h_block_idx(h_load_block_idx),
      .i_h_one_idx(h_load_one_idx),
      .i_h_base_row(h_base_row),
      .i_e_read_col_idx(e_read_col_idx),
      .o_h_loaded(h_loaded),
      .o_h_error(h_error),
      .o_done(done),
      .o_e_rdata(e_rdata),
      .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic apply_reset;
    begin
      rst_n = 1'b0;
      start = 1'b0;
      syndrome_we = 1'b0;
      syndrome_addr = '0;
      syndrome_wdata = 1'b0;
      h_we = 1'b0;
      h_load_block_idx = '0;
      h_load_one_idx = '0;
      h_base_row = '0;
      e_read_col_idx = '0;
      saw_overlap = 1'b0;
      saw_guard_dummy = 1'b0;
      checks_active = 1'b0;
      decode_cycles = 0;
      repeat (2) @(posedge clk);
      rst_n = 1'b1;
      repeat (3) @(posedge clk);
      checks_active = 1'b1;
    end
  endtask

  task automatic load_h_matrix;
    begin
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          h_we = 1'b1;
          h_load_block_idx = H_BLOCK_W'(h_block_idx);
          h_load_one_idx = ONE_IDX_W'(one_idx);
          h_base_row = ROW_IDX_W'(TOY_CASE_H_BASE_ROWS[h_block_idx][one_idx]);
          @(posedge clk);
        end
      end
      h_we = 1'b0;
      while (!h_loaded && !h_error) begin
        @(posedge clk);
      end
      if (!h_loaded) $fatal(1, "H matrix load did not complete");
      if (h_error) $fatal(1, "H matrix load reported error");
    end
  endtask

  task automatic load_syndrome(input  logic [R-1:0] syndrome);
    begin
      for (int row_idx = 0; row_idx < R; row_idx++) begin
        syndrome_we = 1'b1;
        syndrome_addr = ROW_IDX_W'(row_idx);
        syndrome_wdata = syndrome[row_idx];
        @(posedge clk);
      end
      syndrome_we = 1'b0;
      syndrome_addr = '0;
      syndrome_wdata = 1'b0;
      @(posedge clk);
    end
  endtask

  task automatic read_error_vector(output logic [N-1:0] error_bits);
    begin
      error_bits = '0;
      for (int col_idx = 0; col_idx < N; col_idx++) begin
        e_read_col_idx = COL_W'(col_idx);
        @(posedge clk);
        #1;
        error_bits[col_idx] = e_rdata;
      end
    end
  endtask

  function automatic logic [R-1:0] residual_of(input  logic [R-1:0] syndrome,
                                               input  logic [N-1:0] candidate);
    logic [R-1:0] residual;
    /* verilator lint_off UNUSEDSIGNAL */
    int           h_block_idx;
    int           col_idx_i;
    int           row_idx_i;
    /* verilator lint_on UNUSEDSIGNAL */
    begin
      residual = syndrome;
      for (int var_idx = 0; var_idx < N; var_idx++) begin
        if (candidate[var_idx]) begin
          h_block_idx = var_idx / R;
          col_idx_i   = var_idx % R;
          for (int one_idx = 0; one_idx < W; one_idx++) begin
            row_idx_i = (TOY_CASE_H_BASE_ROWS[h_block_idx][one_idx] + col_idx_i) % R;
            residual[row_idx_i] = residual[row_idx_i] ^ 1'b1;
          end
        end
      end
      return residual;
    end
  endfunction

  always_comb begin
    guard_any_valid = 1'b0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      guard_any_valid |= dut.c2v_valid[lane_idx] || dut.v2c_valid[lane_idx];
    end
  end

  always_ff @(posedge clk) begin
    if (checks_active && dut.c2v_phase_active && dut.v2c_phase_active) begin
      saw_overlap <= 1'b1;
    end
    if (checks_active && (dut.active_q_seq == Q_SEQ_W'(Q_TILE - 1))) begin
      if (!guard_any_valid) begin
        saw_guard_dummy <= 1'b1;
      end
    end
  end

  initial begin
    logic [R-1:0] final_residual;
    bit           exact_match;
    int           expected_main_cycles;

    fork
      begin
        repeat (20000) @(posedge clk);
        $fatal(1, "tb_decoder_top timeout: state=%0d iter=%0d done=%0b", dut.state, iter_count,
               done);
      end
    join_none

    apply_reset();
    if (C_VAL != TOY_CASE_C_VAL || ALPHA_SHIFT_0 != TOY_CASE_ALPHA_SHIFT_0 ||
        ALPHA_SHIFT_1 != TOY_CASE_ALPHA_SHIFT_1) begin
      $fatal(1, "toy fixture parameter mismatch");
    end
    load_h_matrix();
    load_syndrome(TOY_CASE_SYNDROME);

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;

    while (done !== 1'b1) begin
      decode_cycles++;
      @(posedge clk);
    end

    read_error_vector(e_out);
    final_residual = residual_of(TOY_CASE_SYNDROME, e_out);
    exact_match = (e_out === TOY_CASE_ERROR);
    expected_main_cycles = I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE) + 2;

    if (int'(iter_count) != I_MAX)
      $fatal(1, "toy case iterations mismatch: got %0d exp %0d", iter_count, I_MAX);
    if (decode_cycles != expected_main_cycles)
      $fatal(1, "fixed cycle mismatch: got %0d exp %0d", decode_cycles, expected_main_cycles);
    if (!saw_overlap) $fatal(1, "tile overlap was not observed");
    if (!saw_guard_dummy) $fatal(1, "guard dummy cycle was not observed");
    $display("toy case residual=%b exact=%0d cycles=%0d", final_residual, exact_match,
             decode_cycles);
    if (final_residual != '0) $fatal(1, "toy case residual check failed");
    if (!exact_match) $fatal(1, "toy case exact check failed");

    $display("tb_decoder_top PASS");
    $finish;
  end
endmodule
