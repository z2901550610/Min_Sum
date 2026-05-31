`timescale 1ns / 1ps

module tb_ram_blocks;
  import bike_pkg::*;

  logic                     clk;
  logic                     rst_n;

  logic                     m_we;
  logic [    ROW_IDX_W-1:0] m_read_row_idx_global;
  logic [    ROW_IDX_W-1:0] m_write_row_idx_global;
  logic                     m_epoch;
  logic [   COMP_C2V_W-1:0] m_wdata;
  logic [   COMP_C2V_W-1:0] m_rdata;
  logic                     m_repoch;
  logic [   COMP_C2V_W-1:0] m_debug[             0:R-1];

  logic                     s_we;
  logic [S_WORD_ADDR_W-1:0] s_read_col_idx;
  logic [S_WORD_ADDR_W-1:0] s_write_col_idx;
  logic [     S_WORD_W-1:0] s_wdata;
  logic [     S_WORD_W-1:0] s_rdata;
  logic                     s_debug[             0:N-1][0:W-1];

  logic                     t_push;
  logic                     t_pop;
  logic [  ENTRY_POS_W-1:0] t_write_entry_idx;
  logic [  ENTRY_POS_W-1:0] t_read_entry_idx;
  logic                     t_valid;
  logic [        MSG_W-1:0] t_wdata;
  logic [        MSG_W-1:0] t_rdata;
  logic                     t_rvalid;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [GROUP_COUNT_W-1:0] t_item_count;
  /* verilator lint_on UNUSEDSIGNAL */
  logic [        MSG_W-1:0] t_debug[0:RAM_LANE_DEPTH-1];

  logic                     c_we;
  logic                     c_din;
  logic                     c_dout;

  logic                     syn_we;
  logic [    ROW_IDX_W-1:0] syn_write_row_idx;
  logic                     syn_wdata;
  logic                     syn_read_valid[             0:L-1];
  logic [    ROW_IDX_W-1:0] syn_read_row_idx[             0:L-1];
  logic                     syn_rdata[             0:L-1];

  ram_m u_ram_m (
      .i_clk(clk),
      .i_we(m_we),
      .i_read_row_idx_global(m_read_row_idx_global),
      .i_write_row_idx_global(m_write_row_idx_global),
      .i_epoch(m_epoch),
      .i_wdata(m_wdata),
      .o_rdata(m_rdata),
      .o_epoch(m_repoch),
      .o_debug_mem(m_debug)
  );

  ram_s u_ram_s (
      .i_clk(clk),
      .i_we(s_we),
      .i_read_col_idx(s_read_col_idx),
      .i_write_col_idx(s_write_col_idx),
      .i_wdata(s_wdata),
      .o_rdata(s_rdata),
      .o_debug_mem(s_debug)
  );

  ram_t u_ram_t (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_clear(1'b0),
      .i_push(t_push),
      .i_pop(t_pop),
      .i_write_entry_idx(t_write_entry_idx),
      .i_read_entry_idx(t_read_entry_idx),
      .i_valid(t_valid),
      .i_wdata(t_wdata),
      .o_rdata(t_rdata),
      .o_valid(t_rvalid),
      .o_item_count(t_item_count),
      .o_debug_mem(t_debug)
  );

  ram_c u_ram_c (
      .i_clk(clk),
      .i_we(c_we),
      .i_col_idx(COL_W'(3 % N)),
      .i_wdata(c_din),
      .o_rdata(c_dout)
  );

  ram_syndrome u_ram_syndrome (
      .i_clk(clk),
      .i_we(syn_we),
      .i_write_row_idx(syn_write_row_idx),
      .i_wdata(syn_wdata),
      .i_read_valid(syn_read_valid),
      .i_read_row_idx(syn_read_row_idx),
      .o_rdata(syn_rdata)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    m_we = 1'b0;
    m_read_row_idx_global = '0;
    m_write_row_idx_global = '0;
    m_epoch = 1'b0;
    m_wdata = '0;
    s_we = 1'b0;
    s_read_col_idx = '0;
    s_write_col_idx = '0;
    s_wdata = '0;
    t_push = 1'b0;
    t_pop = 1'b0;
    t_write_entry_idx = '0;
    t_read_entry_idx = '0;
    t_valid = 1'b0;
    t_wdata = '0;
    c_we = 1'b0;
    c_din = 1'b0;
    syn_we = 1'b0;
    syn_write_row_idx = '0;
    syn_wdata = 1'b0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      syn_read_valid[lane_idx]   = 1'b0;
      syn_read_row_idx[lane_idx] = '0;
    end

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (m_debug[0] != COMP_C2V_INIT) $fatal(1, "ram_m reset mismatch");
    if (s_debug[0][0] != 1'b0) $fatal(1, "ram_s reset mismatch");
    if (t_debug[0] != '0) $fatal(1, "ram_t reset mismatch");

    m_read_row_idx_global = ROW_IDX_W'(2 % R);
    m_write_row_idx_global = ROW_IDX_W'(2 % R);
    m_epoch = 1'b1;
    m_wdata = COMP_C2V_INIT ^ COMP_C2V_W'(7);
    m_we = 1'b1;
    @(posedge clk);
    #1;
    m_we = 1'b0;
    @(posedge clk);
    #1;
    if (m_rdata != m_wdata) $fatal(1, "ram_m read-after-write mismatch");
    if (m_repoch != m_epoch) $fatal(1, "ram_m epoch read-after-write mismatch");

    s_read_col_idx = S_WORD_ADDR_W'(3 % N);
    s_write_col_idx = S_WORD_ADDR_W'(3 % N);
    s_wdata = '0;
    s_wdata[1] = 1'b1;
    s_we = 1'b1;
    t_write_entry_idx = ENTRY_POS_W'(1 % RAM_LANE_DEPTH);
    t_read_entry_idx = ENTRY_POS_W'(1 % RAM_LANE_DEPTH);
    t_wdata = MSG_W'(-2);
    t_push = 1'b1;
    t_valid = 1'b1;
    c_din = 1'b1;
    c_we = 1'b1;
    @(posedge clk);
    #1;
    s_we = 1'b0;
    t_push = 1'b0;
    t_valid = 1'b0;
    c_we = 1'b0;
    @(posedge clk);
    #1;
    if (s_rdata != s_wdata) $fatal(1, "ram_s read-after-write mismatch");
    if (s_debug[3%N][1] != 1'b1) $fatal(1, "ram_s debug mismatch");
    if ($signed(t_rdata) != -MSG_W'(2)) $fatal(1, "ram_t read-after-write mismatch");
    if (t_rvalid != 1'b1) $fatal(1, "ram_t valid read-after-write mismatch");
    t_pop = 1'b1;
    @(posedge clk);
    #1;
    t_pop = 1'b0;
    if (c_dout != 1'b1) $fatal(1, "ram_c read-after-write mismatch");

    syn_write_row_idx = ROW_IDX_W'(2 % R);
    syn_wdata = 1'b1;
    syn_we = 1'b1;
    @(posedge clk);
    #1;
    syn_we = 1'b0;
    syn_read_valid[0] = 1'b1;
    syn_read_row_idx[0] = ROW_IDX_W'(2 % R);
    @(posedge clk);
    #1;
    if (syn_rdata[0] != 1'b1) $fatal(1, "ram_syndrome read-after-write mismatch");
    syn_read_valid[0] = 1'b0;
    @(posedge clk);
    #1;
    if (syn_rdata[0] != 1'b0) $fatal(1, "ram_syndrome invalid read should return zero");

    $display("tb_ram_blocks PASS");
    $finish;
  end
endmodule
