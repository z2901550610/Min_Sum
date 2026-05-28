`timescale 1ns / 1ps

module tb_decoder_top;
  import bike_pkg::*;

  /* verilator lint_off UNUSEDPARAM */
  `include "tb/generated/bike_toy_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  logic                           clk;
  logic                           rst_n;
  logic                           start;
  logic                           syndrome_we;
  logic   [        ROW_IDX_W-1:0] syndrome_addr;
  logic                           syndrome_wdata;
  logic                           h_load_start;
  logic                           h_load_valid;
  logic   [        ROW_IDX_W-1:0] h_load_row_idx_global[0:L-1];
  logic                           done;
  /* verilator lint_off UNUSEDSIGNAL */
  logic                           h_load_ready;
  logic                           h_load_busy;
  logic                           h_load_done;
  logic   [        H_BLOCK_W-1:0] h_load_request_h_block_idx;
  logic   [      ENTRY_POS_W-1:0] h_load_request_entry_pos;
  /* verilator lint_on UNUSEDSIGNAL */
  logic   [            COL_W-1:0] e_read_col_idx;
  logic                           e_rdata;
  logic   [                N-1:0] e_out;
  logic   [$clog2(I_MAX + 1)-1:0] iter_count;
  logic                           checks_active;
  integer                         active_lane_count;
  logic                           saw_drain_state;
  localparam string TB_RAM_I_HEX_PREFIX = (L == 2) ? "rtl/generated/l2/ram_i" :
                                          ((L == 4) ? "rtl/generated/l4/ram_i" :
                                           "rtl/generated/l8/ram_i");

  decoder_top #(
      .RAM_I_HEX_PREFIX(TB_RAM_I_HEX_PREFIX)
  ) dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_syndrome_we(syndrome_we),
      .i_syndrome_addr(syndrome_addr),
      .i_syndrome_wdata(syndrome_wdata),
      .i_h_load_start(h_load_start),
      .i_h_load_valid(h_load_valid),
      .i_h_load_row_idx_global(h_load_row_idx_global),
      .i_e_read_col_idx(e_read_col_idx),
      .o_h_load_ready(h_load_ready),
      .o_h_load_busy(h_load_busy),
      .o_h_load_done(h_load_done),
      .o_h_load_request_h_block_idx(h_load_request_h_block_idx),
      .o_h_load_request_entry_pos(h_load_request_entry_pos),
      .o_done(done),
      .o_e_rdata(e_rdata),
      .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic apply_reset;
    begin
      rst_n = 1'b0;
      checks_active = 1'b0;
      saw_drain_state = 1'b0;
      start = 1'b0;
      h_load_start = 1'b0;
      h_load_valid = 1'b0;
      syndrome_we = 1'b0;
      syndrome_addr = '0;
      syndrome_wdata = 1'b0;
      e_read_col_idx = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        h_load_row_idx_global[lane_idx] = '0;
      end
      repeat (2) @(posedge clk);
      rst_n = 1'b1;
      @(posedge clk);
      checks_active = 1'b1;
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

  task automatic load_h_matrix;
    logic [H_BLOCK_W-1:0] h_block_idx;
    int                   entry_pos;
    int                   one_idx;
    begin
      h_load_start = 1'b1;
      @(posedge clk);
      h_load_start = 1'b0;
      #1;
      while (!h_load_done) begin
        h_block_idx = h_load_request_h_block_idx;
        entry_pos   = int'(h_load_request_entry_pos);
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          one_idx = entry_pos * L + lane_idx;
          h_load_row_idx_global[lane_idx] =
              (one_idx < W) ? ROW_IDX_W'(TOY_CASE_SUPPORTS[int'(h_block_idx)][one_idx]) : '0;
        end
        h_load_valid = 1'b1;
        @(posedge clk);
        #1;
      end
      h_load_valid = 1'b0;
      @(posedge clk);
    end
  endtask

  task automatic start_case(input  logic [R-1:0] syndrome);
    begin
      load_syndrome(syndrome);
      start = 1'b1;
      @(posedge clk);
      start = 1'b0;
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

  function automatic int c2v_signmag_to_tc(input int msg_sign, input int msg_mag);
    begin
      if (msg_sign != 0 && msg_mag != 0) begin
        c2v_signmag_to_tc = -msg_mag;
      end else begin
        c2v_signmag_to_tc = msg_mag;
      end
    end
  endfunction

  /* verilator lint_off UNUSEDSIGNAL */
  function automatic int edge_row_idx(input int col_idx_i, input int one_idx_i);
    int h_block_local;
    int col_local;
    begin
      h_block_local = col_idx_i / R;
      col_local = col_idx_i % R;
      edge_row_idx = (TOY_CASE_SUPPORTS[h_block_local][one_idx_i] + col_local) % R;
    end
  endfunction

  function automatic int ram_t_item_count(input int lane_idx);
    begin
      ram_t_item_count = int'(dut.ram_t_debug_item_count[lane_idx]);
    end
  endfunction

  function automatic logic [R-1:0] residual_of(input  logic [R-1:0] syndrome,
                                               input  logic [N-1:0] candidate);
    logic [R-1:0] residual;
    int           var_idx;
    int           h_block_idx;
    int           col_idx_i;
    int           edge_idx;
    int           row_idx_i;
    begin
      residual = syndrome;
      for (var_idx = 0; var_idx < N; var_idx++) begin
        if (candidate[var_idx]) begin
          h_block_idx = var_idx / R;
          col_idx_i   = var_idx % R;
          for (edge_idx = 0; edge_idx < W; edge_idx++) begin
            row_idx_i = (TOY_CASE_SUPPORTS[h_block_idx][edge_idx] + col_idx_i) % R;
            residual[row_idx_i] = residual[row_idx_i] ^ 1'b1;
          end
        end
      end
      return residual;
    end
  endfunction
  /* verilator lint_on UNUSEDSIGNAL */

  always @(posedge clk) begin
    if (checks_active) begin
      if (dut.state == DEC_ITER_V2C_DRAIN && dut.v2c_col_idx == COL_W'(N - 1)) begin
        saw_drain_state <= 1'b1;
      end

      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (ram_t_item_count(lane_idx) > W) begin
          $fatal(1, "RAM-T valid slot count overflow in lane %0d", lane_idx);
        end
      end

      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        int group_count_sum;

        group_count_sum = 0;
        for (int group_idx = 0; group_idx < L; group_idx++) begin
          group_count_sum += int'(dut.ram_i_debug_count[h_block_idx][group_idx]);
        end
        if (group_count_sum > W) begin
          $fatal(1, "RAM-I group counts exceed W in h block %0d: sum=%0d", h_block_idx,
                 group_count_sum);
        end
      end

    end
  end

  initial begin
    logic [R-1:0] final_residual;
    bit           exact_match;

    fork
      begin
        repeat (20000) @(posedge clk);
        $fatal(
            1,
            "tb_decoder_top timeout: state=%0d work_col_idx=%0d work_group_idx_pos=%0d iter=%0d overlap=%0b c2v=%0b v2c=%0b done=%0b",
            dut.state, dut.work_col_idx, dut.work_entry_pos, iter_count, dut.c2v_v2c_overlap_seen,
            dut.c2v_phase_active, dut.v2c_phase_active, done);
      end
    join_none

    apply_reset();
    if (C_VAL != TOY_CASE_C_VAL || ALPHA_SHIFT_0 != TOY_CASE_ALPHA_SHIFT_0 ||
        ALPHA_SHIFT_1 != TOY_CASE_ALPHA_SHIFT_1) begin
      $fatal(1, "toy fixture parameter mismatch");
    end
    load_h_matrix();
    start_case(TOY_CASE_SYNDROME);

    wait (dut.c2v_phase_active && !dut.v2c_phase_active && dut.c2v_col_idx == 0 && dut.active_entry_pos == 0);
    #1;
    if (dut.ram_m_read_pair_sel === dut.ram_m_write_pair_sel)
      $fatal(1, "RAM M ping-pong pairs should differ");

    wait (dut.c2v_read_d1 && dut.c2v_read_col_d1 == 1 && dut.c2v_read_entry_pos_d1 == 0);
    #1;
    active_lane_count = 0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      logic [ROW_IDX_W-1:0] row_idx_i;
      bit                   row_match;

      if (!dut.c2v_group_valid[lane_idx]) begin
        continue;
      end
      active_lane_count++;
      row_match = 1'b0;
      for (int one_idx = 0; one_idx < W; one_idx++) begin
        row_idx_i = ROW_IDX_W'(edge_row_idx(int'(dut.c2v_read_col_d1), one_idx));
        if (dut.c2v_row_idx_global[lane_idx] == row_idx_i) begin
          row_match = 1'b1;
        end
      end
      if (!row_match)
        $fatal(
            1,
            "shifted column 1 row mismatch lane %0d: got %0d",
            lane_idx,
            int'(dut.c2v_row_idx_global[lane_idx])
        );
    end
    if (active_lane_count == 0) $fatal(1, "shifted column 1 exposed no active group");

    wait (dut.c2v_phase_active && dut.v2c_phase_active && dut.c2v_v2c_overlap_seen === 1'b1);
    #1;
    if (!(dut.c2v_phase_active && dut.v2c_phase_active))
      $fatal(1, "pipeline did not expose simultaneous CNU_B and VNU/CNU_A work");
    if (dut.c2v_col_idx != dut.v2c_col_idx + COL_W'(1))
      $fatal(1, "overlap should keep the c2v column exactly one step ahead");

    wait (iter_count >= 1);
    #1;
    if (dut.ram_m_read_pair_sel === dut.ram_m_write_pair_sel)
      $fatal(1, "RAM M pairs collapsed before iteration swap");

    wait (done === 1'b1);
    @(posedge clk);
    read_error_vector(e_out);
    final_residual = residual_of(TOY_CASE_SYNDROME, e_out);
    exact_match = (e_out === TOY_CASE_ERROR);
    if (int'(iter_count) != I_MAX)
      $fatal(1, "toy case iterations mismatch: got %0d exp %0d", iter_count, I_MAX);
    $display("toy case residual=%b exact=%0d", final_residual, exact_match);
    if (final_residual != '0) begin
      $fatal(1, "toy case residual check failed");
    end
    if (!exact_match) begin
      $fatal(1, "toy case exact check failed");
    end
    if (!saw_drain_state) $fatal(1, "last v2c column drain state was not exercised");

    $display("tb_decoder_top PASS");
    $finish;
  end
endmodule
