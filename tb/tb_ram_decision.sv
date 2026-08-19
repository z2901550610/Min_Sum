`timescale 1ns / 1ps

module tb_ram_decision;
  import bike_pkg::*;

  logic             clk;
  logic             rst_n;
  logic             we[0:L-1];
  logic [COL_W-1:0] write_col_idx[0:L-1];
  logic             wdata[0:L-1];
  logic [COL_W-1:0] read_col_idx;
  logic [COL_W-1:0] read_col_idx_1;
  logic             read_valid_1;
  logic             rdata;
  logic             rdata_1;

  ram_decision dut (
      .i_clk(clk),
      .i_rst_n(rst_n),
      .i_we(we),
      .i_write_col_idx(write_col_idx),
      .i_wdata(wdata),
      .i_read_col_idx(read_col_idx),
      .i_read_col_idx_1(read_col_idx_1),
      .i_read_valid_1(read_valid_1),
      .o_rdata(rdata),
      .o_rdata_1(rdata_1)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_ram_decision timeout");
  end

  task automatic clear_inputs;
    begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        we[lane_idx] = 1'b0;
        write_col_idx[lane_idx] = '0;
        wdata[lane_idx] = 1'b0;
      end
    end
  endtask

  initial begin
    clear_inputs();
    rst_n = 1'b0;
    read_col_idx = '0;
    read_col_idx_1 = '0;
    read_valid_1 = 1'b0;
    repeat (2) @(negedge clk);
    rst_n = 1'b1;

    we[0] = 1'b1;
    write_col_idx[0] = COL_W'(3);
    wdata[0] = 1'b1;
    @(posedge clk);
    #1;
    clear_inputs();
    read_col_idx = COL_W'(3);
    @(posedge clk);
    #1;
    if (rdata !== 1'b1) $fatal(1, "single-lane write/read mismatch");

    if (L > 1) begin
      we[0] = 1'b1;
      write_col_idx[0] = COL_W'(5);
      wdata[0] = 1'b1;
      we[1] = 1'b1;
      write_col_idx[1] = COL_W'(5);
      wdata[1] = 1'b0;
      @(posedge clk);
      #1;
      clear_inputs();
      read_col_idx = COL_W'(5);
      @(posedge clk);
      #1;
      if (rdata !== 1'b0) $fatal(1, "same-bank write priority mismatch");

      we[0] = 1'b1;
      write_col_idx[0] = COL_W'(3);
      wdata[0] = 1'b1;
      we[1] = 1'b1;
      write_col_idx[1] = COL_W'(4);
      wdata[1] = 1'b0;
      @(posedge clk);
      #1;
      clear_inputs();
      read_col_idx   = COL_W'(3);
      read_col_idx_1 = COL_W'(4);
      read_valid_1   = 1'b1;
      @(posedge clk);
      #1;
      if ((rdata !== 1'b1) || (rdata_1 !== 1'b0)) $fatal(1, "dual-bank read mismatch");
    end

    $display("tb_ram_decision PASS");
    $finish;
  end
endmodule
