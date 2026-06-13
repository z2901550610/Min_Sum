`timescale 1ns / 1ps

module tb_decision_ram;
  import bike_pkg::*;

  logic             clk;
  logic             we[0:L-1];
  logic [COL_W-1:0] write_col_idx[0:L-1];
  logic             wdata[0:L-1];
  logic [COL_W-1:0] read_col_idx;
  logic             rdata;

  decision_ram dut (
      .i_clk(clk),
      .i_we(we),
      .i_write_col_idx(write_col_idx),
      .i_wdata(wdata),
      .i_read_col_idx(read_col_idx),
      .o_rdata(rdata)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_decision_ram timeout");
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
    read_col_idx = '0;

    we[0] = 1'b1;
    write_col_idx[0] = COL_W'(3);
    wdata[0] = 1'b1;
    @(posedge clk);
    #1;
    clear_inputs();
    read_col_idx = COL_W'(3);
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
      #1;
      if (rdata !== 1'b0) $fatal(1, "same-bank write priority mismatch");
    end

    $display("tb_decision_ram PASS");
    $finish;
  end
endmodule
