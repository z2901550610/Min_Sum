`timescale 1ns / 1ps

module tb_trike_kem_operation_control;

  logic       clk;
  logic       rst_n;
  logic       start;
  logic [1:0] operation;
  logic       keygen_done;
  logic       encaps_done;
  logic       decaps_done;
  logic       keygen_start;
  logic       encaps_start;
  logic       decaps_start;
  logic [1:0] active_operation;
  logic       busy;
  logic       done;
  logic       error;

  trike_kem_operation_control dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_operation       (operation),
      .i_keygen_done     (keygen_done),
      .i_encaps_done     (encaps_done),
      .i_decaps_done     (decaps_done),
      .o_keygen_start    (keygen_start),
      .o_encaps_start    (encaps_start),
      .o_decaps_start    (decaps_start),
      .o_active_operation(active_operation),
      .o_busy            (busy),
      .o_done            (done),
      .o_error           (error)
  );

  always #5 clk = ~clk;

  task automatic launch(input  logic [1:0] selected_operation);
    begin
      operation = selected_operation;
      start = 1'b1;
      #1;
      case (selected_operation)
        2'd0: if (!keygen_start) $fatal(1, "KeyGen start was not one-hot");
        2'd1: if (!encaps_start) $fatal(1, "Encaps start was not one-hot");
        2'd2: if (!decaps_start) $fatal(1, "Decaps start was not one-hot");
        default: $fatal(1, "launch task received invalid operation");
      endcase
      @(posedge clk);
      #1;
      start = 1'b0;
      if (!busy || (active_operation != selected_operation))
        $fatal(1, "operation was not accepted");
    end
  endtask

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    operation = '0;
    keygen_done = 1'b0;
    encaps_done = 1'b0;
    decaps_done = 1'b0;
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    launch(2'd0);
    operation = 2'd1;
    start = 1'b1;
    @(posedge clk);
    #1;
    start = 1'b0;
    if (!busy || (active_operation != 2'd0) || encaps_start)
      $fatal(1, "busy operation was not isolated");
    keygen_done = 1'b1;
    @(posedge clk);
    #1;
    keygen_done = 1'b0;
    if (busy || !done) $fatal(1, "KeyGen completion failed");

    launch(2'd1);
    encaps_done = 1'b1;
    @(posedge clk);
    #1;
    encaps_done = 1'b0;
    if (busy || !done) $fatal(1, "Encaps completion failed");

    launch(2'd2);
    decaps_done = 1'b1;
    @(posedge clk);
    #1;
    decaps_done = 1'b0;
    if (busy || !done) $fatal(1, "Decaps completion failed");

    operation = 2'd2;
    start = 1'b1;
    @(posedge clk);
    #1;
    start = 1'b0;
    if (busy || !done || !error) $fatal(1, "second Decaps was not rejected");

    operation = 2'd3;
    start = 1'b1;
    @(posedge clk);
    #1;
    start = 1'b0;
    if (busy || !done || !error) $fatal(1, "invalid operation was not rejected");

    $display("tb_trike_kem_operation_control PASS");
    $finish;
  end

endmodule
