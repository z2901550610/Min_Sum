`timescale 1ns / 1ps

module tb_decoder_top;
  import bike_pkg::*;

  /* verilator lint_off UNUSEDPARAM */
  `include "tb/generated/bike_demo_vectors.svh"
  /* verilator lint_on UNUSEDPARAM */

  logic                           clk;
  logic                           rst_n;
  logic                           start;
  logic                           syndrome_we;
  logic   [        ROW_IDX_W-1:0] syndrome_addr;
  logic                           syndrome_wdata;
  logic                           done;
  logic   [            COL_W-1:0] e_read_col_idx;
  logic                           e_rdata;
  logic   [                N-1:0] e_out;
  logic   [$clog2(I_MAX + 1)-1:0] iter_count;
  logic                           checks_active;
  integer                         idx;
  integer                         flat_idx;
  logic                           saw_drain_state;
  localparam int unsigned TB_SUPPORTS[0:N0-1][0:W-1] = '{'{0, 1, 3}, '{0, 2, 5}};

  decoder_top dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_syndrome_we(syndrome_we),
      .i_syndrome_addr(syndrome_addr),
      .i_syndrome_wdata(syndrome_wdata),
      .i_e_read_col_idx(e_read_col_idx),
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
      edge_row_idx = (TB_SUPPORTS[h_block_local][one_idx_i] + col_local) % R;
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
            row_idx_i = (TB_SUPPORTS[h_block_idx][edge_idx] + col_idx_i) % R;
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
    start_case(CASE1_SYNDROME);

    wait (dut.c2v_phase_active && !dut.v2c_phase_active && dut.c2v_col_idx == 0 && dut.active_entry_pos == 0);
    #1;
    if (dut.ram_m_read_pair_sel === dut.ram_m_write_pair_sel)
      $fatal(1, "RAM M ping-pong pairs should differ");

    wait (dut.c2v_read_d1 && dut.c2v_read_col_d1 == 1 && dut.c2v_read_entry_pos_d1 == 0);
    #1;
    if (!(dut.c2v_group_valid[0] && dut.c2v_group_valid[1]))
      $fatal(1, "shifted column 1 should expose two active group_idxs");
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      int row_idx_i;

      row_idx_i = edge_row_idx(int'(dut.c2v_read_col_d1), int'(dut.c2v_one_idx[lane_idx]));
      if (dut.c2v_row_idx_global[lane_idx] != ROW_IDX_W'(row_idx_i))
        $fatal(
            1,
            "shifted column 1 row mismatch lane %0d: got %0d exp %0d",
            lane_idx,
            int'(dut.c2v_row_idx_global[lane_idx]),
            row_idx_i
        );
      if (dut.c2v_group_idx[lane_idx] != GROUP_IDX_W'(row_idx_i % L))
        $fatal(1, "shifted column 1 group mismatch lane %0d", lane_idx);
      if (dut.c2v_row_idx_group[lane_idx] != ROW_GROUP_W'(row_idx_i / L))
        $fatal(1, "shifted column 1 row group mismatch lane %0d", lane_idx);
    end

    wait (dut.c2v_phase_active && dut.v2c_phase_active && dut.c2v_v2c_overlap_seen === 1'b1);
    #1;
    if (!(dut.c2v_phase_active && dut.v2c_phase_active))
      $fatal(1, "pipeline did not expose simultaneous CNU_B and VNU/CNU_A work");
    if (dut.c2v_col_idx != dut.v2c_col_idx + COL_W'(1))
      $fatal(1, "overlap should keep the c2v column exactly one step ahead");

    wait (dut.vnu_accum_t && dut.c2v_latched_col == 1 && dut.c2v_latched_entry_pos == 0);
    #1;
    if (!(dut.vnu_accum_valid[0] && dut.vnu_accum_valid[1]))
      $fatal(1, "VNU did not consume both RAM-I group_idxs for shifted column 1");
    for (int one_idx = 0; one_idx < W; one_idx++) begin
      bit matched;
      int expected_tc;

      flat_idx = int'(dut.c2v_latched_col) * W + one_idx;
      expected_tc =
          c2v_signmag_to_tc(CASE1_FIRST_C2V_SIGN[flat_idx], CASE1_FIRST_C2V_MAG[flat_idx]);
      matched = 1'b0;
      for (idx = 0; idx < L; idx++) begin
        if (dut.vnu_accum_valid[idx] && (int'(dut.c2v_tc[idx]) == expected_tc)) begin
          matched = 1'b1;
        end
      end
      if (!matched) begin
        $fatal(1, "CASE1 RAM-T slot c2v tc[%0d] was not observed: exp %0d", flat_idx, expected_tc);
      end
    end

    wait (iter_count == 1);
    #1;
    if (dut.ram_m_read_pair_sel === dut.ram_m_write_pair_sel)
      $fatal(1, "RAM M pairs collapsed before iteration swap");

    wait (done === 1'b1);
    @(posedge clk);
    read_error_vector(e_out);
    final_residual = residual_of(CASE1_SYNDROME, e_out);
    if (int'(iter_count) != I_MAX)
      $fatal(1, "CASE1 iterations mismatch: got %0d exp %0d", iter_count, I_MAX);
    $display("CASE1 final residual after fixed iterations: %b", final_residual);
    if (!saw_drain_state) $fatal(1, "last v2c column drain state was not exercised");

    $display("tb_decoder_top PASS");
    $finish;
  end
endmodule
