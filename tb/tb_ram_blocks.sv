`timescale 1ns/1ps

module tb_ram_blocks;
  import bike_pkg::*;

  logic clk;
  logic rst_n;

  logic m_clear;
  logic m_en;
  logic m_we;
  logic [ROW_W-1:0] m_check_row_addr;
  logic [COMP_C2V_W-1:0] m_wdata;
  logic [COMP_C2V_W-1:0] m_rdata;
  logic [COMP_C2V_W-1:0] m_debug [0:R-1];

  logic s_clear;
  logic s_en;
  logic s_we;
  logic [VAR_W-1:0] s_var;
  logic [EDGE_W-1:0] s_edge;
  logic s_wdata;
  logic s_rdata;
  logic s_debug [0:N-1][0:W-1];

  logic t_clear;
  logic t_en;
  logic t_we;
  logic [MSG_W-1:0] t_wdata;
  logic [MSG_W-1:0] t_rdata;
  logic [MSG_W-1:0] t_debug [0:N-1][0:W-1];

  logic u_init;
  logic u_en;
  logic u_we;
  logic [MSG_W-1:0] u_wdata;
  logic [MSG_W-1:0] u_rdata;
  logic [MSG_W-1:0] u_debug [0:N-1][0:W-1];

  logic c_clear;
  logic c_load;
  logic c_en;
  logic c_we;
  logic c_din;
  logic c_dout;
  logic [N-1:0] c_bits;

  ram_m u_ram_m (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(m_clear),
    .i_en(m_en),
    .i_we(m_we),
    .i_check_row_addr(m_check_row_addr),
    .i_wdata(m_wdata),
    .o_rdata(m_rdata),
    .o_debug_mem(m_debug)
  );

  ram_s u_ram_s (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(s_clear),
    .i_en(s_en),
    .i_we(s_we),
    .i_var_idx(s_var),
    .i_edge_slot(s_edge),
    .i_wdata(s_wdata),
    .o_rdata(s_rdata),
    .o_debug_mem(s_debug)
  );

  ram_t u_ram_t (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(t_clear),
    .i_en(t_en),
    .i_we(t_we),
    .i_var_idx(s_var),
    .i_edge_slot(s_edge),
    .i_wdata(t_wdata),
    .o_rdata(t_rdata),
    .o_debug_mem(t_debug)
  );

  ram_u u_ram_u (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_init(u_init),
    .i_en(u_en),
    .i_we(u_we),
    .i_var_idx(s_var),
    .i_edge_slot(s_edge),
    .i_wdata(u_wdata),
    .o_rdata(u_rdata),
    .o_debug_mem(u_debug)
  );

  ram_c u_ram_c (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_clear(c_clear),
    .i_load(c_load),
    .i_load_wdata('0),
    .i_en(c_en),
    .i_we(c_we),
    .i_var_idx(s_var),
    .i_wdata(c_din),
    .o_rdata(c_dout),
    .o_debug_bits(c_bits)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 1'b0;
    m_clear = 1'b0;
    m_en = 1'b0;
    m_we = 1'b0;
    m_check_row_addr = '0;
    m_wdata = '0;
    s_clear = 1'b0;
    s_en = 1'b0;
    s_we = 1'b0;
    s_var = '0;
    s_edge = '0;
    s_wdata = 1'b0;
    t_clear = 1'b0;
    t_en = 1'b0;
    t_we = 1'b0;
    t_wdata = '0;
    u_init = 1'b0;
    u_en = 1'b0;
    u_we = 1'b0;
    u_wdata = '0;
    c_clear = 1'b0;
    c_load = 1'b0;
    c_en = 1'b0;
    c_we = 1'b0;
    c_din = 1'b0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (m_debug[0] != COMP_C2V_INIT) $fatal(1, "ram_m reset mismatch");
    if (s_debug[0][0] != 1'b0) $fatal(1, "ram_s reset mismatch");
    if (t_debug[0][0] != '0) $fatal(1, "ram_t reset mismatch");
    if (u_debug[0][0] != '0) $fatal(1, "ram_u reset mismatch");
    if (c_bits != '0) $fatal(1, "ram_c reset mismatch");

    m_check_row_addr = ROW_W'(2 % R);
    m_wdata = COMP_C2V_INIT ^ COMP_C2V_W'(7);
    m_en = 1'b1;
    m_we = 1'b1;
    @(posedge clk);
    #1;
    m_we = 1'b0;
    @(posedge clk);
    #1;
    if (m_rdata != m_wdata) $fatal(1, "ram_m read-after-write mismatch");

    s_var = VAR_W'(3 % N);
    s_edge = EDGE_W'(1 % W);
    s_wdata = 1'b1;
    s_en = 1'b1;
    s_we = 1'b1;
    t_wdata = MSG_W'(-2);
    t_en = 1'b1;
    t_we = 1'b1;
    u_wdata = {1'b0, D'(C_VAL)};
    u_en = 1'b1;
    u_we = 1'b1;
    c_din = 1'b1;
    c_en = 1'b1;
    c_we = 1'b1;
    @(posedge clk);
    #1;
    s_we = 1'b0;
    t_we = 1'b0;
    u_we = 1'b0;
    c_we = 1'b0;
    @(posedge clk);
    #1;
    if (s_rdata != 1'b1) $fatal(1, "ram_s read-after-write mismatch");
    if ($signed(t_rdata) != -MSG_W'(2)) $fatal(1, "ram_t read-after-write mismatch");
    if (u_rdata != {1'b0, D'(C_VAL)}) $fatal(1, "ram_u read-after-write mismatch");
    if (c_dout != 1'b1) $fatal(1, "ram_c read-after-write mismatch");

    u_init = 1'b1;
    u_en = 1'b0;
    @(posedge clk);
    #1;
    u_init = 1'b0;
    if (u_debug[0][0] != {1'b0, D'(C_VAL)}) $fatal(1, "ram_u init mismatch");

    $display("tb_ram_blocks PASS");
    $finish;
  end
endmodule
