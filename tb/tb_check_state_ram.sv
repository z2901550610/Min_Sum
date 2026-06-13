`timescale 1ns / 1ps

module tb_check_state_ram;
  import bike_pkg::*;

  logic                   clk;
  logic                   rst_n;
  logic                   clear_valid;
  logic                   clear_pair_sel;
  logic [ROW_BANK_AW-1:0] clear_row_addr;
  logic                   c2v_pair_sel;
  logic                   c2v_valid[0:L-1];
  logic [ROW_BANK_AW-1:0] c2v_row_addr[0:L-1];
  logic [ COMP_C2V_W-1:0] c2v_comp[0:L-1];
  logic                   v2c_pair_sel;
  logic                   v2c_valid[0:L-1];
  logic [ROW_BANK_AW-1:0] v2c_row_addr[0:L-1];
  logic [ COMP_C2V_W-1:0] v2c_comp[0:L-1];
  logic                   v2c_write_pair_sel;
  logic                   v2c_write_valid[0:L-1];
  logic [ROW_BANK_AW-1:0] v2c_write_row_addr[0:L-1];
  logic [ COMP_C2V_W-1:0] v2c_write_data[0:L-1];

  localparam logic [COMP_C2V_W-1:0] TEST_COMP = {1'b1, EDGE_ID_W'(2), D'(7), D'(3)};

  check_state_ram dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_clear_valid(clear_valid),
      .i_clear_pair_sel(clear_pair_sel),
      .i_clear_row_addr(clear_row_addr),
      .i_c2v_pair_sel(c2v_pair_sel),
      .i_c2v_valid(c2v_valid),
      .i_c2v_row_addr(c2v_row_addr),
      .o_c2v_comp(c2v_comp),
      .i_v2c_pair_sel(v2c_pair_sel),
      .i_v2c_valid(v2c_valid),
      .i_v2c_row_addr(v2c_row_addr),
      .o_v2c_comp(v2c_comp),
      .i_v2c_write_pair_sel(v2c_write_pair_sel),
      .i_v2c_write_valid(v2c_write_valid),
      .i_v2c_write_row_addr(v2c_write_row_addr),
      .i_v2c_write_data(v2c_write_data)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_check_state_ram timeout");
  end

  task automatic clear_inputs;
    begin
      clear_valid = 1'b0;
      clear_pair_sel = 1'b0;
      clear_row_addr = '0;
      c2v_pair_sel = 1'b0;
      v2c_pair_sel = 1'b0;
      v2c_write_pair_sel = 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_valid[lane_idx] = 1'b0;
        c2v_row_addr[lane_idx] = '0;
        v2c_valid[lane_idx] = 1'b0;
        v2c_row_addr[lane_idx] = '0;
        v2c_write_valid[lane_idx] = 1'b0;
        v2c_write_row_addr[lane_idx] = '0;
        v2c_write_data[lane_idx] = COMP_C2V_INIT;
      end
    end
  endtask

  initial begin
    rst_n = 1'b0;
    clear_inputs();
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    @(posedge clk);

    v2c_write_pair_sel = 1'b1;
    v2c_write_valid[0] = 1'b1;
    v2c_write_row_addr[0] = '0;
    v2c_write_data[0] = TEST_COMP;
    @(posedge clk);
    #1;
    clear_inputs();

    v2c_pair_sel = 1'b1;
    v2c_valid[0] = 1'b1;
    v2c_row_addr[0] = '0;
    @(posedge clk);
    #1;
    if (v2c_comp[0] !== TEST_COMP) $fatal(1, "v2c pair read mismatch");
    clear_inputs();

    clear_valid = 1'b1;
    clear_pair_sel = 1'b1;
    clear_row_addr = '0;
    @(posedge clk);
    #1;
    clear_inputs();

    c2v_pair_sel = 1'b1;
    c2v_valid[0] = 1'b1;
    c2v_row_addr[0] = '0;
    @(posedge clk);
    #1;
    if (c2v_comp[0] !== COMP_C2V_INIT) $fatal(1, "clear readback mismatch");

    $display("tb_check_state_ram PASS");
    $finish;
  end
endmodule
