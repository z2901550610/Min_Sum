`timescale 1ns / 1ps

module tb_ram_blocks;
  import bike_pkg::*;

  logic                   clk;
  logic                   rst_n;

  logic                   m_we;
  logic [ROW_GROUP_W-1:0] m_read_row_idx_group;
  logic [ROW_GROUP_W-1:0] m_write_row_idx_group;
  logic                   m_epoch;
  logic [ COMP_C2V_W-1:0] m_wdata;
  logic [ COMP_C2V_W-1:0] m_rdata;
  logic                   m_repoch;
  logic [ COMP_C2V_W-1:0] m_debug[0:ROW_GROUP_DEPTH-1];

  localparam int TB_S_PACK_W = 8;
  localparam int TB_S_WORDS_PER_COL = (RAM_LANE_DEPTH + TB_S_PACK_W - 1) / TB_S_PACK_W;
  localparam int TB_S_WORD_DEPTH = N * TB_S_WORDS_PER_COL;
  localparam int TB_S_WORD_ADDR_W = (TB_S_WORD_DEPTH > 1) ? $clog2(TB_S_WORD_DEPTH) : 1;
  localparam int TB_S_PACK1_WORDS_PER_COL = RAM_LANE_DEPTH;
  localparam int TB_S_PACK1_WORD_DEPTH = N * RAM_LANE_DEPTH;
  localparam int TB_S_PACK1_WORD_ADDR_W = (TB_S_PACK1_WORD_DEPTH > 1) ? $clog2(
      TB_S_PACK1_WORD_DEPTH
  ) : 1;

  logic s_we;
  logic [TB_S_WORD_ADDR_W-1:0] s_read_word_addr;
  logic [TB_S_WORD_ADDR_W-1:0] s_write_word_addr;
  logic [TB_S_PACK_W-1:0] s_wdata;
  logic [TB_S_PACK_W-1:0] s_rdata;
  logic s_debug[0:N-1][0:RAM_LANE_DEPTH-1];

  logic s_pack2_we;
  logic [TB_S_PACK1_WORD_ADDR_W-1:0] s_pack2_read_word_addr;
  logic [TB_S_PACK1_WORD_ADDR_W-1:0] s_pack2_write_word_addr;
  logic [0:0] s_pack2_wdata;
  logic [0:0] s_pack2_rdata;
  logic s_pack2_debug[0:N-1][0:RAM_LANE_DEPTH-1];

  logic t_push;
  logic t_pop;
  logic [ENTRY_POS_W-1:0] t_write_entry_idx;
  logic [ENTRY_POS_W-1:0] t_read_entry_idx;
  logic t_valid;
  logic [MSG_W-1:0] t_wdata;
  logic [MSG_W-1:0] t_rdata;
  logic t_rvalid;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [GROUP_COUNT_W-1:0] t_item_count;
  /* verilator lint_on UNUSEDSIGNAL */
  logic [MSG_W-1:0] t_debug[0:RAM_LANE_DEPTH-1];

  logic c_we;
  logic c_din;
  logic c_dout;

  ram_m u_ram_m (
      .i_clk(clk),
      .i_we(m_we),
      .i_read_row_idx_group(m_read_row_idx_group),
      .i_write_row_idx_group(m_write_row_idx_group),
      .i_epoch(m_epoch),
      .i_wdata(m_wdata),
      .o_rdata(m_rdata),
      .o_epoch(m_repoch),
      .o_debug_mem(m_debug)
  );

  ram_s #(
      .RAM_S_PACK_W(TB_S_PACK_W),
      .RAM_S_WORDS_PER_COL(TB_S_WORDS_PER_COL),
      .RAM_S_WORD_DEPTH(TB_S_WORD_DEPTH),
      .RAM_S_WORD_ADDR_W(TB_S_WORD_ADDR_W)
  ) u_ram_s (
      .i_clk(clk),
      .i_we(s_we),
      .i_read_word_addr(s_read_word_addr),
      .i_write_word_addr(s_write_word_addr),
      .i_wdata(s_wdata),
      .o_rdata(s_rdata),
      .o_debug_mem(s_debug)
  );

  ram_s #(
      .RAM_S_PACK_W(1),
      .RAM_S_WORDS_PER_COL(TB_S_PACK1_WORDS_PER_COL),
      .RAM_S_WORD_DEPTH(TB_S_PACK1_WORD_DEPTH),
      .RAM_S_WORD_ADDR_W(TB_S_PACK1_WORD_ADDR_W)
  ) u_ram_s_pack2 (
      .i_clk(clk),
      .i_we(s_pack2_we),
      .i_read_word_addr(s_pack2_read_word_addr),
      .i_write_word_addr(s_pack2_write_word_addr),
      .i_wdata(s_pack2_wdata),
      .o_rdata(s_pack2_rdata),
      .o_debug_mem(s_pack2_debug)
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

  initial clk = 1'b0;
  always #5 clk = ~clk;

  function automatic int s_bit_addr(input int col_idx, input int entry_idx);
    begin
      s_bit_addr = (col_idx % N) * RAM_LANE_DEPTH + (entry_idx % RAM_LANE_DEPTH);
    end
  endfunction

  function automatic int s_word_addr(input int col_idx, input int entry_idx);
    begin
      s_word_addr = (col_idx % N) * TB_S_WORDS_PER_COL +
                    ((entry_idx % RAM_LANE_DEPTH) / TB_S_PACK_W);
    end
  endfunction

  task automatic write_pack2_sign(input int col_idx, input int entry_idx, input  logic sign_bit);
    begin
      s_pack2_write_word_addr = TB_S_PACK1_WORD_ADDR_W'(s_bit_addr(col_idx, entry_idx));
      s_pack2_wdata = {sign_bit};
      s_pack2_we = 1'b1;
      @(posedge clk);
      #1;
      s_pack2_we = 1'b0;
    end
  endtask

  task automatic check_pack2_sign(input int col_idx, input int entry_idx,
                                  input  logic expected_sign);
    begin
      s_pack2_read_word_addr = TB_S_PACK1_WORD_ADDR_W'(s_bit_addr(col_idx, entry_idx));
      @(posedge clk);
      #1;
      if (s_pack2_rdata[0] != expected_sign) begin
        $fatal(1, "packed ram_s read mismatch col=%0d entry=%0d got=%0b exp=%0b", col_idx,
               entry_idx, s_pack2_rdata[0], expected_sign);
      end
      if (s_pack2_debug[col_idx%N][entry_idx%RAM_LANE_DEPTH] != expected_sign) begin
        $fatal(1, "packed ram_s debug mismatch col=%0d entry=%0d got=%0b exp=%0b", col_idx,
               entry_idx, s_pack2_debug[col_idx%N][entry_idx%RAM_LANE_DEPTH], expected_sign);
      end
    end
  endtask

  initial begin
    rst_n = 1'b0;
    m_we = 1'b0;
    m_read_row_idx_group = '0;
    m_write_row_idx_group = '0;
    m_epoch = 1'b0;
    m_wdata = '0;
    s_we = 1'b0;
    s_read_word_addr = '0;
    s_write_word_addr = '0;
    s_wdata = '0;
    s_pack2_we = 1'b0;
    s_pack2_read_word_addr = '0;
    s_pack2_write_word_addr = '0;
    s_pack2_wdata = '0;
    t_push = 1'b0;
    t_pop = 1'b0;
    t_write_entry_idx = '0;
    t_read_entry_idx = '0;
    t_valid = 1'b0;
    t_wdata = '0;
    c_we = 1'b0;
    c_din = 1'b0;

    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    #1;
    if (m_debug[0] != COMP_C2V_INIT) $fatal(1, "ram_m reset mismatch");
    if (s_debug[0][0] != 1'b0) $fatal(1, "ram_s reset mismatch");
    if (s_pack2_debug[0][0] != 1'b0) $fatal(1, "packed ram_s reset mismatch");
    if (t_debug[0] != '0) $fatal(1, "ram_t reset mismatch");

    m_read_row_idx_group = ROW_GROUP_W'(2 % ROW_GROUP_DEPTH);
    m_write_row_idx_group = ROW_GROUP_W'(2 % ROW_GROUP_DEPTH);
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

    s_read_word_addr = TB_S_WORD_ADDR_W'(s_word_addr(3, 1));
    s_write_word_addr = TB_S_WORD_ADDR_W'(s_word_addr(3, 1));
    s_wdata = '0;
    s_wdata[s_bit_addr(3, 1)%TB_S_PACK_W] = 1'b1;
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
    if (s_rdata[s_bit_addr(3, 1)%TB_S_PACK_W] != 1'b1) $fatal(1, "ram_s read-after-write mismatch");
    write_pack2_sign(4, 0, 1'b1);
    check_pack2_sign(4, 0, 1'b1);
    write_pack2_sign(4, 1, 1'b1);
    check_pack2_sign(4, 0, 1'b1);
    check_pack2_sign(4, 1, 1'b1);
    write_pack2_sign(4, 1, 1'b0);
    check_pack2_sign(4, 1, 1'b0);
    check_pack2_sign(4, 0, 1'b1);
    if ($signed(t_rdata) != -MSG_W'(2)) $fatal(1, "ram_t read-after-write mismatch");
    if (t_rvalid != 1'b1) $fatal(1, "ram_t valid read-after-write mismatch");
    t_pop = 1'b1;
    @(posedge clk);
    #1;
    t_pop = 1'b0;
    if (c_dout != 1'b1) $fatal(1, "ram_c read-after-write mismatch");

    $display("tb_ram_blocks PASS");
    $finish;
  end
endmodule
