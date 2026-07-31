`timescale 1ns / 1ps

module tb_sm3_compress;
  localparam int EXPECTED_BUSY_CYCLES = 116;
  localparam logic [255:0] SM3_INITIAL_STATE = {
    32'h7380166f,
    32'h4914b2b9,
    32'h172442d7,
    32'hda8a0600,
    32'ha96f30bc,
    32'h163138aa,
    32'he38dee4d,
    32'hb0fb0e4e
  };
  localparam logic [255:0] EXPECTED_DIGEST =
      256'h66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic [511:0] input_block;
  logic [255:0] input_state;
  logic         busy;
  logic         done;
  logic [255:0] output_state;

  int           busy_cycles;

  sm3_compress dut (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_block(input_block),
      .i_state(input_state),
      .o_busy (busy),
      .o_done (done),
      .o_state(output_state)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_sm3_compress timeout");
  end

  initial begin
    rst_n                = 1'b0;
    start                = 1'b0;
    input_block          = '0;
    input_state          = SM3_INITIAL_STATE;
    busy_cycles          = 0;

    input_block[511:480] = 32'h61626380;
    input_block[63:0]    = 64'd24;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    while (!done) begin
      @(posedge clk);
      if (busy) busy_cycles++;
    end
    #1;

    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "busy cycle mismatch: got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end
    if (output_state != EXPECTED_DIGEST) begin
      $fatal(1, "digest mismatch: got=%064h expected=%064h", output_state, EXPECTED_DIGEST);
    end

    $display("tb_sm3_compress PASS");
    $finish;
  end
endmodule
