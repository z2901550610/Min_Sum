`timescale 1ns / 1ps

module tb_reset_sync;
  logic clk;
  logic rst_n;
  logic sync_rst_n;

  reset_sync dut (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .o_rst_n(sync_rst_n)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_reset_sync timeout");
  end

  initial begin
    rst_n = 1'b0;
    #1;
    if (sync_rst_n !== 1'b0) $fatal(1, "reset output should assert asynchronously");

    @(negedge clk);
    rst_n = 1'b1;
    #1;
    if (sync_rst_n !== 1'b0) $fatal(1, "reset output released before sync stages");

    @(posedge clk);
    #1;
    if (sync_rst_n !== 1'b0) $fatal(1, "reset output released after one stage");

    @(posedge clk);
    #1;
    if (sync_rst_n !== 1'b1) $fatal(1, "reset output did not release after two stages");

    rst_n = 1'b0;
    #1;
    if (sync_rst_n !== 1'b0) $fatal(1, "reset output did not reassert asynchronously");

    $display("tb_reset_sync PASS");
    $finish;
  end
endmodule
