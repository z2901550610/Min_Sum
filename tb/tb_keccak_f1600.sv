`timescale 1ns / 1ps

module tb_keccak_f1600;
  localparam int EXPECTED_CYCLES = 24;

  logic          clk;
  logic          rst_n;
  logic          start;
  logic [1599:0] input_state;
  logic          busy;
  logic          done;
  logic [1599:0] output_state;

  logic [  63:0] expected_lanes[0:24];
  int            cycle_count;

  keccak_f1600 dut (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .i_start(start),
      .i_state(input_state),
      .o_busy (busy),
      .o_done (done),
      .o_state(output_state)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #10000;
    $fatal(1, "tb_keccak_f1600 timeout");
  end

  initial begin
    expected_lanes[0]  = 64'hf1258f7940e1dde7;
    expected_lanes[1]  = 64'h84d5ccf933c0478a;
    expected_lanes[2]  = 64'hd598261ea65aa9ee;
    expected_lanes[3]  = 64'hbd1547306f80494d;
    expected_lanes[4]  = 64'h8b284e056253d057;
    expected_lanes[5]  = 64'hff97a42d7f8e6fd4;
    expected_lanes[6]  = 64'h90fee5a0a44647c4;
    expected_lanes[7]  = 64'h8c5bda0cd6192e76;
    expected_lanes[8]  = 64'had30a6f71b19059c;
    expected_lanes[9]  = 64'h30935ab7d08ffc64;
    expected_lanes[10] = 64'heb5aa93f2317d635;
    expected_lanes[11] = 64'ha9a6e6260d712103;
    expected_lanes[12] = 64'h81a57c16dbcf555f;
    expected_lanes[13] = 64'h43b831cd0347c826;
    expected_lanes[14] = 64'h01f22f1a11a5569f;
    expected_lanes[15] = 64'h05e5635a21d9ae61;
    expected_lanes[16] = 64'h64befef28cc970f2;
    expected_lanes[17] = 64'h613670957bc46611;
    expected_lanes[18] = 64'hb87c5a554fd00ecb;
    expected_lanes[19] = 64'h8c3ee88a1ccf32c8;
    expected_lanes[20] = 64'h940c7922ae3a2614;
    expected_lanes[21] = 64'h1841f924a2c509e4;
    expected_lanes[22] = 64'h16f53526e70465c2;
    expected_lanes[23] = 64'h75f644e97f30a13b;
    expected_lanes[24] = 64'heaf1ff7b5ceca249;

    rst_n              = 1'b0;
    start              = 1'b0;
    input_state        = '0;
    cycle_count        = 0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    while (!done) begin
      @(posedge clk);
      if (busy) cycle_count++;
    end
    #1;

    if (cycle_count != EXPECTED_CYCLES) begin
      $fatal(1, "latency mismatch: got=%0d expected=%0d", cycle_count, EXPECTED_CYCLES);
    end

    for (int lane = 0; lane < 25; lane++) begin
      if (output_state[64*lane+:64] != expected_lanes[lane]) begin
        $fatal(1, "lane %0d mismatch: got=%016h expected=%016h", lane, output_state[64*lane+:64],
               expected_lanes[lane]);
      end
    end

    $display("tb_keccak_f1600 PASS");
    $finish;
  end
endmodule
