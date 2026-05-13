`timescale 1ns/1ps

module tb_bike_l1_cycle;
  import bike_pkg::*;

  localparam int TIMEOUT_CYCLES = 4000000;
  localparam int MAX_START_TO_ACTIVITY_CYCLES = 2;

  logic clk;
  logic rst_n;
  logic start;
  logic [R-1:0] syndrome;
  logic done;
  logic success;
  logic e_rdata;
  logic [COL_W-1:0] e_read_col_idx;
  logic [$clog2(I_MAX + 1)-1:0] iter_count;

  decoder_top dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_syndrome(syndrome),
    .i_e_read_col_idx(e_read_col_idx),
    .o_done(done),
    .o_success(success),
    .o_e_rdata(e_rdata),
    .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    int cycles;
    int first_active_cycle;
    int active_iter_cycles;

    syndrome = '0;
    for (int one_idx = 0; one_idx < W; one_idx++) begin
      syndrome[H_BASE[0][0][one_idx]] = 1'b1;
    end

    rst_n = 1'b0;
    start = 1'b0;
    e_read_col_idx = '0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;

    cycles = 0;
    first_active_cycle = -1;
    while ((iter_count < 1) && (done !== 1'b1) && (cycles < TIMEOUT_CYCLES)) begin
      cycles += 1;
      @(posedge clk);
      if ((first_active_cycle < 0) &&
          (dut.c2v_read || dut.c2v_write_t || dut.v2c_read || dut.vnu_write_next)) begin
        first_active_cycle = cycles;
      end
    end

    if (iter_count < 1) begin
      $fatal(
        1,
        "timeout before first iteration: cycles=%0d state=%0d phase=%0d c2v_col=%0d c2v_pos=%0d v2c_col=%0d v2c_pos=%0d",
        cycles,
        dut.state,
        dut.phase,
        dut.c2v_col_idx,
        dut.c2v_entry_pos,
        dut.v2c_col_idx,
        dut.v2c_entry_pos
      );
    end

    if (first_active_cycle < 0 || first_active_cycle > MAX_START_TO_ACTIVITY_CYCLES) begin
      $fatal(1, "unexpected start-to-activity latency: %0d cycles", first_active_cycle);
    end

    active_iter_cycles = cycles - first_active_cycle;
    $display(
      "BIKE_L1 cycle cycles=%0d first_active_cycle=%0d active_iter_cycles=%0d iter=%0d done=%0d success=%0d e0=%0d",
      cycles,
      first_active_cycle,
      active_iter_cycles,
      iter_count,
      done,
      success,
      e_rdata
    );
    $finish;
  end
endmodule
