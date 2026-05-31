`timescale 1ns / 1ps

module tb_edge_message_pipe;
  import bike_pkg::*;

  logic                            clk;
  logic                            rst_n;
  logic                            start;
  logic                            c2v_read_d1;
  logic                            c2v_write_t;
  logic                            v2c_emit_to_cnu_a;
  logic                            vnu_accum_t;
  logic                            cnu_a_writeback;
  logic        [        COL_W-1:0] c2v_col_idx;
  logic        [        COL_W-1:0] c2v_read_col_d1;
  logic                            v2c_read;
  logic        [  ENTRY_POS_W-1:0] v2c_entry_pos;
  logic        [  ENTRY_POS_W-1:0] v2c_read_entry_pos_d1;
  logic        [  ENTRY_POS_W-1:0] c2v_latched_entry_pos;
  logic                            c2v_latched_entry_pos_last;
  logic        [    ONE_IDX_W-1:0] c2v_latched_one_idx[0:L-1];
  logic        [        COL_W-1:0] v2c_m_latched_col;
  logic        [  ENTRY_POS_W-1:0] v2c_m_latched_entry_pos;
  logic        [    ONE_IDX_W-1:0] v2c_m_latched_one_idx[0:L-1];
  logic                            v2c_m_latched_group_valid[0:L-1];
  logic                            c2v_latched_group_valid[0:L-1];
  logic        [GROUP_COUNT_W-1:0] col_meta_slot_count;
  logic                            cnu_a_valid[0:L-1];
  logic                            cnu_a_sign[0:L-1];
  logic signed [        MSG_W-1:0] c2v_tc[0:L-1];
  logic        [     S_WORD_W-1:0] s_col_rdata;
  logic                            t_rvalid[0:L-1];
  logic        [        MSG_W-1:0] t_rdata[0:L-1];
  /* verilator lint_off UNUSEDSIGNAL */
  logic                            s_rdata[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic                            s_col_we;
  logic        [S_WORD_ADDR_W-1:0] s_read_col_idx;
  logic        [S_WORD_ADDR_W-1:0] s_write_col_idx;
  logic        [     S_WORD_W-1:0] s_col_wdata;
  logic                            t_push[0:L-1];
  logic                            t_pop[0:L-1];
  logic                            t_valid[0:L-1];
  logic        [  ENTRY_POS_W-1:0] t_write_entry_idx;
  logic        [  ENTRY_POS_W-1:0] t_read_entry_idx;
  logic        [        MSG_W-1:0] t_wdata[0:L-1];
  logic                            vnu_col_start;
  logic                            vnu_col_end;
  logic                            vnu_accum_valid[0:L-1];
  logic                            vnu_prev_c2v_valid[0:L-1];
  logic signed [        MSG_W-1:0] vnu_prev_c2v[0:L-1];

  edge_message_pipe dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_c2v_write_t(c2v_write_t),
      .i_v2c_emit_to_cnu_a(v2c_emit_to_cnu_a),
      .i_vnu_accum_t(vnu_accum_t),
      .i_cnu_a_writeback(cnu_a_writeback),
      .i_c2v_col_idx(c2v_col_idx),
      .i_c2v_read_col_d1(c2v_read_col_d1),
      .i_c2v_read_d1(c2v_read_d1),
      .i_v2c_read(v2c_read),
      .i_v2c_entry_pos(v2c_entry_pos),
      .i_v2c_read_entry_pos_d1(v2c_read_entry_pos_d1),
      .i_c2v_latched_entry_pos(c2v_latched_entry_pos),
      .i_c2v_latched_entry_pos_last(c2v_latched_entry_pos_last),
      .i_c2v_latched_one_idx(c2v_latched_one_idx),
      .i_v2c_m_latched_col(v2c_m_latched_col),
      .i_v2c_m_latched_entry_pos(v2c_m_latched_entry_pos),
      .i_v2c_m_latched_one_idx(v2c_m_latched_one_idx),
      .i_v2c_m_latched_group_valid(v2c_m_latched_group_valid),
      .i_c2v_latched_group_valid(c2v_latched_group_valid),
      .i_col_meta_slot_count(col_meta_slot_count),
      .i_cnu_a_valid(cnu_a_valid),
      .i_cnu_a_sign(cnu_a_sign),
      .i_c2v_tc(c2v_tc),
      .i_s_col_rdata(s_col_rdata),
      .i_t_rvalid(t_rvalid),
      .i_t_rdata(t_rdata),
      .o_s_rdata(s_rdata),
      .o_s_col_we(s_col_we),
      .o_s_read_col_idx(s_read_col_idx),
      .o_s_write_col_idx(s_write_col_idx),
      .o_s_col_wdata(s_col_wdata),
      .o_t_push(t_push),
      .o_t_pop(t_pop),
      .o_t_valid(t_valid),
      .o_t_write_entry_idx(t_write_entry_idx),
      .o_t_read_entry_idx(t_read_entry_idx),
      .o_t_wdata(t_wdata),
      .o_vnu_col_start(vnu_col_start),
      .o_vnu_col_end(vnu_col_end),
      .o_vnu_accum_valid(vnu_accum_valid),
      .o_vnu_prev_c2v_valid(vnu_prev_c2v_valid),
      .o_vnu_prev_c2v(vnu_prev_c2v)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic logic [S_WORD_ADDR_W-1:0] expected_s_col_addr(input  logic [COL_W-1:0] col_idx);
    begin
      expected_s_col_addr = S_WORD_ADDR_W'(col_idx);
    end
  endfunction

  function automatic int alpha_scale_ref(input int value);
    int abs_value;
    int scaled_abs;
    begin
      abs_value  = (value < 0) ? -value : value;
      scaled_abs = 0;
      if ((ALPHA_SHIFT_0 > 0) && (ALPHA_SHIFT_0 <= ALPHA_FRAC_W)) begin
        scaled_abs += abs_value << (ALPHA_FRAC_W - ALPHA_SHIFT_0);
      end
      if ((ALPHA_SHIFT_1 > 0) && (ALPHA_SHIFT_1 <= ALPHA_FRAC_W)) begin
        scaled_abs += abs_value << (ALPHA_FRAC_W - ALPHA_SHIFT_1);
      end
      scaled_abs += 1 << (ALPHA_FRAC_W - 1);
      scaled_abs = scaled_abs >> ALPHA_FRAC_W;
      alpha_scale_ref = (value < 0) ? -scaled_abs : scaled_abs;
    end
  endfunction

  task automatic drive_idle;
    begin
      start = 1'b0;
      c2v_read_d1 = 1'b0;
      c2v_write_t = 1'b0;
      v2c_emit_to_cnu_a = 1'b0;
      vnu_accum_t = 1'b0;
      cnu_a_writeback = 1'b0;
      c2v_col_idx = '0;
      c2v_read_col_d1 = '0;
      v2c_read = 1'b0;
      v2c_entry_pos = '0;
      v2c_read_entry_pos_d1 = '0;
      c2v_latched_entry_pos = '0;
      c2v_latched_entry_pos_last = 1'b0;
      v2c_m_latched_col = '0;
      v2c_m_latched_entry_pos = '0;
      col_meta_slot_count = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        v2c_m_latched_group_valid[lane_idx] = 1'b0;
        c2v_latched_group_valid[lane_idx] = 1'b0;
        c2v_latched_one_idx[lane_idx] = '0;
        v2c_m_latched_one_idx[lane_idx] = '0;
        cnu_a_valid[lane_idx] = 1'b0;
        cnu_a_sign[lane_idx] = 1'b0;
        c2v_tc[lane_idx] = '0;
        t_rvalid[lane_idx] = 1'b0;
        t_rdata[lane_idx] = '0;
      end
      s_col_rdata = '0;
    end
  endtask

  initial begin
    drive_idle();
    rst_n = 1'b0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    c2v_col_idx = COL_W'(2);
    #1;
    if (s_read_col_idx != expected_s_col_addr(2)) begin
      $fatal(1, "RAM-S read address did not use live c2v column/entry");
    end

    c2v_read_d1 = 1'b1;
    c2v_read_col_d1 = COL_W'(3);
    #1;
    if (s_read_col_idx != expected_s_col_addr(3)) begin
      $fatal(1, "RAM-S read address did not use d1 c2v column/entry");
    end

    c2v_latched_entry_pos = ENTRY_POS_W'(1);
    c2v_latched_entry_pos_last = 1'b1;
    c2v_latched_group_valid[0] = 1'b1;
    c2v_latched_group_valid[1] = 1'b0;
    c2v_latched_one_idx[0] = ONE_IDX_W'(1);
    c2v_latched_one_idx[1] = ONE_IDX_W'(2);
    s_col_rdata[1] = 1'b1;
    c2v_tc[0] = MSG_W'(5);
    c2v_tc[1] = MSG_W'(3);
    c2v_write_t = 1'b1;
    vnu_accum_t = 1'b1;
    #1;
    if (!(t_push[0] && t_push[1])) $fatal(1, "RAM-T push should be asserted for all lanes");
    if (!(t_valid[0] && !t_valid[1])) $fatal(1, "RAM-T valid sideband mismatch");
    if (t_write_entry_idx != ENTRY_POS_W'(1)) $fatal(1, "RAM-T write entry mismatch");
    if (int'($signed(t_wdata[0])) != alpha_scale_ref(5)) $fatal(1, "RAM-T write data mismatch");
    if (!(vnu_col_end && !vnu_col_start)) $fatal(1, "VNU column end pulse mismatch");
    if (!(vnu_accum_valid[0] && !vnu_accum_valid[1])) $fatal(1, "VNU accum valid mismatch");
    if (s_rdata[0] != 1'b1 || s_rdata[1] != 1'b0) $fatal(1, "RAM-S sign select mismatch");

    c2v_latched_entry_pos = '0;
    c2v_latched_entry_pos_last = 1'b0;
    #1;
    if (!(vnu_col_start && !vnu_col_end)) $fatal(1, "VNU column start pulse mismatch");

    c2v_write_t = 1'b0;
    vnu_accum_t = 1'b0;
    v2c_read = 1'b1;
    v2c_entry_pos = ENTRY_POS_W'(1);
    v2c_read_entry_pos_d1 = '0;
    #1;
    if (t_read_entry_idx != ENTRY_POS_W'(1)) $fatal(1, "RAM-T read entry should use v2c issue");

    v2c_read = 1'b0;
    #1;
    if (t_read_entry_idx != '0) $fatal(1, "RAM-T read entry should use v2c d1 fallback");

    v2c_emit_to_cnu_a = 1'b1;
    t_rvalid[0] = 1'b1;
    t_rvalid[1] = 1'b0;
    t_rdata[0] = MSG_W'(7);
    t_rdata[1] = MSG_W'(4);
    #1;
    if (!(t_pop[0] && t_pop[1])) $fatal(1, "RAM-T pop should be asserted for all lanes");
    if (!(vnu_prev_c2v_valid[0] && !vnu_prev_c2v_valid[1])) begin
      $fatal(1, "VNU previous-c2v valid mismatch");
    end
    if (vnu_prev_c2v[0] != $signed(MSG_W'(7))) $fatal(1, "VNU previous-c2v data mismatch");

    v2c_emit_to_cnu_a = 1'b0;
    cnu_a_writeback = 1'b1;
    v2c_m_latched_col = COL_W'(5);
    v2c_m_latched_entry_pos = ENTRY_POS_W'(1);
    v2c_m_latched_one_idx[0] = ONE_IDX_W'(1);
    v2c_m_latched_one_idx[1] = ONE_IDX_W'(2);
    col_meta_slot_count = GROUP_COUNT_W'(2);
    v2c_m_latched_group_valid[0] = 1'b1;
    v2c_m_latched_group_valid[1] = 1'b0;
    cnu_a_valid[0] = 1'b1;
    cnu_a_valid[1] = 1'b1;
    cnu_a_sign[0] = 1'b1;
    cnu_a_sign[1] = 1'b1;
    #1;
    if (!s_col_we) $fatal(1, "RAM-S vector write enable mismatch");
    if (s_write_col_idx != expected_s_col_addr(5)) $fatal(1, "RAM-S vector write address mismatch");
    if (s_col_wdata[0] != 1'b0) $fatal(1, "RAM-S vector low bit mismatch");
    if (s_col_wdata[1] != 1'b1) $fatal(1, "RAM-S vector sign bit mismatch");
    if (s_col_wdata[2] != 1'b0) $fatal(1, "RAM-S invalid-lane vector bit mismatch");

    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
    @(posedge clk);

    $display("tb_edge_message_pipe PASS");
    $finish;
  end
endmodule
