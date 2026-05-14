`timescale 1ns/1ps

module tb_decoder_top;
  import bike_pkg::*;

  /* verilator lint_off UNUSEDPARAM */
  `include "tb/generated/bike_demo_vectors.svh"
  /* verilator lint_on UNUSEDPARAM */

  logic clk;
  logic rst_n;
  logic start;
  logic syndrome_we;
  logic [ROW_IDX_W-1:0] syndrome_addr;
  logic syndrome_wdata;
  logic done;
  logic success;
  logic [COL_W-1:0] e_read_col_idx;
  logic e_rdata;
  logic [N-1:0] e_out;
  logic [$clog2(I_MAX + 1)-1:0] iter_count;
  logic checks_active;
  integer idx;
  integer flat_idx;
  logic prev_ram_i_shift_count_we;
  logic [H_BLOCK_W-1:0] prev_ram_i_shift_h_block_idx;
  logic [GROUP_COUNT_W-1:0] prev_ram_i_shift_count_wdata [0:L-1];
  logic saw_ram_i_count_commit;
  logic saw_drain_state;

  decoder_top dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_syndrome_we(syndrome_we),
    .i_syndrome_addr(syndrome_addr),
    .i_syndrome_wdata(syndrome_wdata),
    .i_e_read_col_idx(e_read_col_idx),
    .o_done(done),
    .o_success(success),
    .o_e_rdata(e_rdata),
    .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic apply_reset;
    begin
      rst_n = 1'b0;
      checks_active = 1'b0;
      prev_ram_i_shift_count_we = 1'b0;
      prev_ram_i_shift_h_block_idx = '0;
      for (int group_idx = 0; group_idx < L; group_idx++) begin
        prev_ram_i_shift_count_wdata[group_idx] = '0;
      end
      saw_ram_i_count_commit = 1'b0;
      saw_drain_state = 1'b0;
      start = 1'b0;
      syndrome_we = 1'b0;
      syndrome_addr = '0;
      syndrome_wdata = 1'b0;
      e_read_col_idx = '0;
      repeat (2) @(posedge clk);
      rst_n = 1'b1;
      @(posedge clk);
      checks_active = 1'b1;
    end
  endtask

  task automatic load_syndrome(input logic [R-1:0] syndrome);
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

  task automatic start_case(input logic [R-1:0] syndrome);
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

  function automatic int c2v_signmag_to_tc(
    input int msg_sign,
    input int msg_mag
  );
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
      edge_row_idx = (H_BASE[0][h_block_local][one_idx_i] + col_local) % R;
    end
  endfunction

  function automatic int ram_t_item_count(input int group_idx);
    begin
      if (group_idx == 0) ram_t_item_count = int'(dut.u_ram_t0.valid_count);
      else ram_t_item_count = int'(dut.u_ram_t1.valid_count);
    end
  endfunction

  function automatic logic [R-1:0] residual_of(input logic [R-1:0] syndrome, input logic [N-1:0] candidate);
    logic [R-1:0] residual;
    int var_idx;
    int h_block_idx;
    int col_idx_i;
    int edge_idx;
    int row_idx_i;
    begin
      residual = syndrome;
      for (var_idx = 0; var_idx < N; var_idx++) begin
        if (candidate[var_idx]) begin
          h_block_idx = var_idx / R;
          col_idx_i = var_idx % R;
          for (edge_idx = 0; edge_idx < W; edge_idx++) begin
            row_idx_i = (H_BASE[0][h_block_idx][edge_idx] + col_idx_i) % R;
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
      if (!dut.ram_i_shift_ready) begin
        if (dut.c2v_read) begin
          $fatal(1, "RAM-I reader advanced while shift writer was busy");
        end
      end

      if (dut.state == DEC_ITER_V2C_DRAIN && dut.v2c_col_idx == COL_W'(N - 1)) begin
        saw_drain_state <= 1'b1;
      end

      for (int group_idx = 0; group_idx < L; group_idx++) begin
        if (ram_t_item_count(group_idx) > W) begin
          $fatal(1, "RAM-T valid slot count overflow in group %0d", group_idx);
        end
        if (dut.ram_i_shift_pending_count[group_idx] > 3) begin
          $fatal(1, "RAM-I shift pending queue overflow in group %0d", group_idx);
        end
      end

      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        int group_count_sum;

        group_count_sum = 0;
        for (int group_idx = 0; group_idx < L; group_idx++) begin
          group_count_sum += int'(dut.ram_i_debug_count[h_block_idx][group_idx]);
        end
        if (group_count_sum > W) begin
          $fatal(1, "RAM-I group counts exceed W in h block %0d: sum=%0d", h_block_idx, group_count_sum);
        end
      end

      if (dut.ram_i_shift_count_we) begin
        saw_ram_i_count_commit <= 1'b1;
        if (dut.ram_i_shift_commit_pending_next) begin
          $fatal(1, "RAM-I count commit left commit_pending asserted");
        end
        for (int group_idx = 0; group_idx < L; group_idx++) begin
          if (dut.ram_i_shift_pending_count[group_idx] != 0 ||
              dut.ram_i_shift_pending_count_next[group_idx] != 0) begin
            $fatal(1, "RAM-I count committed with pending entries in group %0d", group_idx);
          end
        end
      end

      if (prev_ram_i_shift_count_we) begin
        for (int group_idx = 0; group_idx < L; group_idx++) begin
          if (dut.ram_i_debug_count[prev_ram_i_shift_h_block_idx][group_idx] !=
              prev_ram_i_shift_count_wdata[group_idx]) begin
            $fatal(1, "RAM-I committed count mismatch group %0d: got %0d exp %0d",
                   group_idx,
                   dut.ram_i_debug_count[prev_ram_i_shift_h_block_idx][group_idx],
                   prev_ram_i_shift_count_wdata[group_idx]);
          end
        end
      end
    end

    prev_ram_i_shift_count_we <= checks_active && dut.ram_i_shift_count_we;
    prev_ram_i_shift_h_block_idx <= dut.c2v_h_block_idx;
    for (int group_idx = 0; group_idx < L; group_idx++) begin
      prev_ram_i_shift_count_wdata[group_idx] <= dut.ram_i_shift_count_wdata[group_idx];
    end
  end

  initial begin
    logic [R-1:0] final_residual;

    fork
      begin
        repeat (20000) @(posedge clk);
        $fatal(1, "tb_decoder_top timeout: state=%0d phase=%0d work_col_idx=%0d work_group_idx_pos=%0d iter=%0d overlap=%0b c2v=%0b v2c=%0b done=%0b",
               dut.state, dut.phase, dut.work_col_idx, dut.work_entry_pos, iter_count,
               dut.c2v_v2c_overlap_seen, dut.c2v_phase_active, dut.v2c_phase_active, done);
      end
    join_none

    apply_reset();
    start_case(CASE1_SYNDROME);

    wait (dut.c2v_phase_active && !dut.v2c_phase_active && dut.c2v_col_idx == 0 && dut.active_entry_pos == 0);
    #1;
    if (dut.m_read_pair === dut.m_write_pair) $fatal(1, "RAM M ping-pong pairs should differ");

    wait (dut.c2v_read_d1 && dut.c2v_read_col_d1 == 1 && dut.c2v_read_entry_pos_d1 == 0);
    #1;
    if (dut.ram_i_debug_count[0][0] != GROUP_COUNT_W'(2)) $fatal(1, "RAM I shifted group_idx0 count mismatch for column 1");
    if (dut.ram_i_debug_count[0][1] != GROUP_COUNT_W'(1)) $fatal(1, "RAM I shifted group_idx1 count mismatch for column 1");
    if (!(dut.c2v_group_valid[0] && dut.c2v_group_valid[1])) $fatal(1, "shifted column 1 should expose two active group_idxs");
    if (dut.c2v_one_idx[0] != ONE_IDX_W'(1) || dut.c2v_row_idx_group[0] != ROW_GROUP_W'(1)) $fatal(1, "shifted group_idx0 entry mismatch for column 1");
    if (dut.c2v_one_idx[1] != ONE_IDX_W'(0) || dut.c2v_row_idx_group[1] != ROW_GROUP_W'(0)) $fatal(1, "shifted group_idx1 entry mismatch for column 1");

    wait (dut.c2v_phase_active && dut.v2c_phase_active && dut.c2v_v2c_overlap_seen === 1'b1);
    #1;
    if (!(dut.c2v_phase_active && dut.v2c_phase_active)) $fatal(1, "pipeline did not expose simultaneous CNU_B and VNU/CNU_A work");
    if (dut.c2v_col_idx != dut.v2c_col_idx + COL_W'(1)) $fatal(1, "overlap should keep the c2v column exactly one step ahead");

    wait (dut.vnu_accum_t && dut.c2v_latched_col == 1 && dut.c2v_latched_entry_pos == 0);
    #1;
    if (!(dut.vnu_accum_valid[0] && dut.vnu_accum_valid[1])) $fatal(1, "VNU did not consume both RAM-I group_idxs for shifted column 1");
    for (idx = 0; idx < L; idx++) begin
      if (dut.vnu_accum_valid[idx]) begin
        flat_idx = int'(dut.c2v_latched_col) * W + int'(dut.c2v_latched_one_idx[idx]);
        if (int'(dut.c2v_tc[idx]) !=
            c2v_signmag_to_tc(CASE1_FIRST_C2V_SIGN[flat_idx], CASE1_FIRST_C2V_MAG[flat_idx])) begin
          $fatal(1, "CASE1 RAM-T slot c2v tc[%0d] mismatch: got %0d exp %0d",
                 flat_idx,
                 int'(dut.c2v_tc[idx]),
                 c2v_signmag_to_tc(CASE1_FIRST_C2V_SIGN[flat_idx], CASE1_FIRST_C2V_MAG[flat_idx]));
        end
      end
    end

    wait (iter_count == 1);
    #1;
    if (dut.m_read_pair === dut.m_write_pair) $fatal(1, "RAM M pairs collapsed before iteration swap");

    wait (done === 1'b1);
    @(posedge clk);
    read_error_vector(e_out);
    final_residual = residual_of(CASE1_SYNDROME, e_out);
    if (success !== 1'b0) $fatal(1, "fixed-iteration core should leave o_success low");
    if (int'(iter_count) != I_MAX) $fatal(1, "CASE1 iterations mismatch: got %0d exp %0d", iter_count, I_MAX);
    $display("CASE1 final residual after fixed iterations: %b", final_residual);
    if (!saw_drain_state) $fatal(1, "last v2c column drain state was not exercised");
    if (!saw_ram_i_count_commit) $fatal(1, "RAM-I count commit was not exercised");

    $display("tb_decoder_top PASS");
    $finish;
  end
endmodule
