`timescale 1ns / 1ps

module tb_decoder_ctrl;
  import bike_pkg::*;

  logic                   clk;
  logic                   rst_n;
  logic                   start;
  logic                   finish_decode;
  logic                   c2v_entry_pos_last;
  logic                   v2c_entry_pos_last;
  logic [DEC_STATE_W-1:0] state;
  logic [      COL_W-1:0] work_col_idx;
  logic [ENTRY_POS_W-1:0] work_entry_pos;
  logic [      COL_W-1:0] c2v_col_idx;
  logic [      COL_W-1:0] v2c_col_idx;
  logic [ENTRY_POS_W-1:0] c2v_entry_pos;
  logic [ENTRY_POS_W-1:0] v2c_entry_pos;
  logic [ENTRY_POS_W-1:0] active_entry_pos;
  logic                   ram_m_read_pair_sel;
  logic                   ram_m_write_pair_sel;
  logic                   c2v_read;
  logic                   v2c_read;
  logic                   c2v_write_t;
  logic                   vnu_accum_t;
  logic                   vnu_finalize;
  logic                   decision_write;
  logic                   v2c_emit_to_cnu_a;
  logic                   cnu_a_writeback;
  logic                   iter_check;
  logic                   col_k_meta_advance;
  logic                   c2v_pipe_valid;
  logic                   v2c_pipe_valid;
  logic                   c2v_v2c_overlap_seen;
  logic                   done;
  logic [     ITER_W-1:0] iter_count;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [      COL_W-1:0] observed_work_col_idx;
  /* verilator lint_on UNUSEDSIGNAL */

  int                     cycle_count;
  logic                   checks_active;

  decoder_ctrl dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_finish_decode(finish_decode),
      .i_c2v_entry_pos_last(c2v_entry_pos_last),
      .i_v2c_entry_pos_last(v2c_entry_pos_last),
      .o_state(state),
      .o_work_col_idx(work_col_idx),
      .o_work_entry_pos(work_entry_pos),
      .o_c2v_col_idx(c2v_col_idx),
      .o_v2c_col_idx(v2c_col_idx),
      .o_c2v_entry_pos(c2v_entry_pos),
      .o_v2c_entry_pos(v2c_entry_pos),
      .o_active_entry_pos(active_entry_pos),
      .o_ram_m_read_pair_sel(ram_m_read_pair_sel),
      .o_ram_m_write_pair_sel(ram_m_write_pair_sel),
      .o_c2v_read(c2v_read),
      .o_v2c_read(v2c_read),
      .o_c2v_write_t(c2v_write_t),
      .o_vnu_accum_t(vnu_accum_t),
      .o_vnu_finalize(vnu_finalize),
      .o_decision_write(decision_write),
      .o_v2c_emit_to_cnu_a(v2c_emit_to_cnu_a),
      .o_cnu_a_writeback(cnu_a_writeback),
      .o_iter_check(iter_check),
      .o_col_k_meta_advance(col_k_meta_advance),
      .o_c2v_pipe_valid(c2v_pipe_valid),
      .o_v2c_pipe_valid(v2c_pipe_valid),
      .o_c2v_v2c_overlap_seen(c2v_v2c_overlap_seen),
      .o_done(done),
      .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always_comb begin
    c2v_entry_pos_last = (int'(c2v_entry_pos) + 1) >= RAM_LANE_DEPTH;
    v2c_entry_pos_last = (int'(v2c_entry_pos) + 1) >= RAM_LANE_DEPTH;
    finish_decode = iter_check && (iter_count == ITER_W'(I_MAX - 1));
  end

  always @(posedge clk) begin
    if (checks_active) begin
      cycle_count <= cycle_count + 1;
      observed_work_col_idx <= work_col_idx;

      if (ram_m_write_pair_sel !== ~ram_m_read_pair_sel) begin
        $fatal(1, "RAM-M pair selectors are not complementary");
      end
      if (active_entry_pos != work_entry_pos) begin
        $fatal(1, "active_entry_pos should mirror work_entry_pos");
      end
      if (vnu_accum_t != c2v_write_t) begin
        $fatal(1, "VNU accumulation pulse should match c2v write pulse");
      end
      if (vnu_finalize && (c2v_read || v2c_read || decision_write)) begin
        $fatal(1, "data-path issue pulse active during VNU finalize");
      end
      if (iter_check && (c2v_read || v2c_read || c2v_write_t || cnu_a_writeback)) begin
        $fatal(1, "data-path issue pulse active during iter_check");
      end
      if (c2v_pipe_valid != (c2v_read || c2v_write_t || dut.col_kp1_c2v_valid_d1)) begin
        $fatal(1, "c2v pipe valid summary mismatch");
      end
      if (v2c_pipe_valid != (decision_write || v2c_read || v2c_emit_to_cnu_a || cnu_a_writeback)) begin
        $fatal(1, "v2c pipe valid summary mismatch");
      end
      if (c2v_read && v2c_read && (c2v_col_idx != v2c_col_idx + COL_W'(1))) begin
        $fatal(1, "simultaneous c2v/v2c issue has unexpected column spacing");
      end
      if (cycle_count > 20000) begin
        $fatal(1, "tb_decoder_ctrl timeout: state=%0d c2v_col=%0d v2c_col=%0d iter=%0d", state,
               c2v_col_idx, v2c_col_idx, iter_count);
      end
    end
  end

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    checks_active = 1'b0;
    cycle_count = 0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);
    checks_active = 1'b1;

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;

    wait (state == 4'd5);
    wait (c2v_v2c_overlap_seen === 1'b1);
    wait (col_k_meta_advance === 1'b1);
    wait (state == 4'd6);
    wait (iter_check === 1'b1);
    wait (ram_m_read_pair_sel === 1'b1);
    wait (done === 1'b1);
    @(posedge clk);

    if (iter_count != ITER_W'(I_MAX)) $fatal(1, "iter_count mismatch: got %0d", iter_count);

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk);
    if (done) $fatal(1, "new start did not leave done state");
    if (iter_count != '0) $fatal(1, "new start did not clear iter_count");

    $display("tb_decoder_ctrl PASS");
    $finish;
  end
endmodule
