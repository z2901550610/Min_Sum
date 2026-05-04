`timescale 1ns/1ps

module tb_ram_blocks;
  import bike_pkg::*;

  logic clk;
  logic rst_n;

  logic m_we;
  logic [ROW_IDX_W-1:0] m_row_idx_group;
  logic [COMP_C2V_W-1:0] m_wdata;
  logic [COMP_C2V_W-1:0] m_rdata;
  logic [COMP_C2V_W-1:0] m_debug [0:R-1];

  logic s_we;
  logic [COL_W-1:0] s_col_idx;
  logic [ONE_IDX_W-1:0] s_one_idx;
  logic s_wdata;
  logic s_rdata;
  logic s_debug [0:N-1][0:W-1];

  logic t_we;
  logic [ONE_IDX_W-1:0] t_entry_pos;
  logic [MSG_W-1:0] t_wdata;
  logic [MSG_W-1:0] t_rdata;
  logic [MSG_W-1:0] t_debug [0:W-1];

  logic c_we;
  logic c_din;
  logic c_dout;
  logic [N-1:0] c_bits;

  ram_m u_ram_m (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_we(m_we),
    .i_row_idx_group(m_row_idx_group),
    .i_wdata(m_wdata),
    .o_rdata(m_rdata),
    .o_debug_mem(m_debug)
  );

  ram_s u_ram_s (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_we(s_we),
    .i_col_idx(s_col_idx),
    .i_one_idx(s_one_idx),
    .i_wdata(s_wdata),
    .o_rdata(s_rdata),
    .o_debug_mem(s_debug)
  );

  ram_t u_ram_t (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_we(t_we),
    .i_entry_pos(t_entry_pos),
    .i_wdata(t_wdata),
    .o_rdata(t_rdata),
    .o_debug_mem(t_debug)
  );

  ram_c u_ram_c (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_we(c_we),
    .i_col_idx(s_col_idx),
    .i_wdata(c_din),
    .o_rdata(c_dout),
    .o_bits(c_bits)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    m_we = 1'b0;
    m_row_idx_group = '0;
    m_wdata = '0;
    s_we = 1'b0;
    s_col_idx = '0;
    s_one_idx = '0;
    s_wdata = 1'b0;
    t_we = 1'b0;
    t_entry_pos = '0;
    t_wdata = '0;
    c_we = 1'b0;
    c_din = 1'b0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (m_debug[0] != COMP_C2V_INIT) $fatal(1, "ram_m reset mismatch");
    if (s_debug[0][0] != 1'b0) $fatal(1, "ram_s reset mismatch");
    if (t_debug[0] != '0) $fatal(1, "ram_t reset mismatch");
    if (c_bits != '0) $fatal(1, "ram_c reset mismatch");

    m_row_idx_group = ROW_IDX_W'(2 % R);
    m_wdata = COMP_C2V_INIT ^ COMP_C2V_W'(7);
    m_we = 1'b1;
    @(posedge clk);
    #1;
    m_we = 1'b0;
    @(posedge clk);
    #1;
    if (m_rdata != m_wdata) $fatal(1, "ram_m read-after-write mismatch");

    s_col_idx = COL_W'(3 % N);
    s_one_idx = ONE_IDX_W'(1 % W);
    s_wdata = 1'b1;
    s_we = 1'b1;
    t_entry_pos = ONE_IDX_W'(1 % W);
    t_wdata = MSG_W'(-2);
    t_we = 1'b1;
    c_din = 1'b1;
    c_we = 1'b1;
    @(posedge clk);
    #1;
    s_we = 1'b0;
    t_we = 1'b0;
    c_we = 1'b0;
    @(posedge clk);
    #1;
    if (s_rdata != 1'b1) $fatal(1, "ram_s read-after-write mismatch");
    if ($signed(t_rdata) != -MSG_W'(2)) $fatal(1, "ram_t read-after-write mismatch");
    if (c_dout != 1'b1) $fatal(1, "ram_c read-after-write mismatch");

    $display("tb_ram_blocks PASS");
    $finish;
  end
endmodule
