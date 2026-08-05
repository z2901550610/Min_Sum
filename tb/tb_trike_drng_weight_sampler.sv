`timescale 1ns / 1ps

module tb_trike_drng_weight_sampler;
  localparam int LENGTH = 19;
  localparam int WEIGHT = 3;
  localparam int EXPECTED_BUSY_CYCLES = 1448;
  localparam logic [439:0] INITIAL_V =
      440'h16665ec1cb7f52e088e340915fd3eae1a368e63010f30806778d7b208208ffac32f1266f54b42d34a31bc63b7ade4ce41c6cfb307ed37f;
  localparam logic [439:0] INITIAL_C =
      440'h5663d04e549ec9cb3947d645b6e2f519a97e11f58c61c8e86e47835c7225f4f30d0f640435ed006597257c49f11c99d990d0921750ebda;
  localparam logic [439:0] EXPECTED_V =
      440'h1991cfacc95bb04234bac362847cca2e9fe31c10b61865ad8a7db5e4613df67a52321a039848b6166b9f0f94f4552f91071eb9806c364c;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         index_valid;
  logic [  1:0] index_position;
  logic [  4:0] index_value;
  logic         index_ready;
  logic         busy;
  logic         done;
  logic [439:0] v;
  logic [439:0] c;
  logic [439:0] reseed_counter;

  /* verilator lint_off UNUSEDSIGNAL */
  logic         compress_start;
  logic [511:0] compress_block;
  logic [255:0] compress_state;
  /* verilator lint_on UNUSEDSIGNAL */

  logic [  4:0] received_index[0:WEIGHT-1];
  int           received_count;
  int           busy_cycles;

  trike_drng_weight_sampler #(
      .LENGTH(LENGTH),
      .WEIGHT(WEIGHT)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_v             (INITIAL_V),
      .i_c             (INITIAL_C),
      .i_reseed_counter(440'd1),
      .o_index_valid   (index_valid),
      .o_index_position(index_position),
      .o_index         (index_value),
      .i_index_ready   (index_ready),
      .o_busy          (busy),
      .o_done          (done),
      .o_v             (v),
      .o_c             (c),
      .o_reseed_counter(reseed_counter),
      .o_compress_start(compress_start),
      .o_compress_block(compress_block),
      .o_compress_state(compress_state),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy_cycles <= 0;
    end else if (busy) begin
      busy_cycles <= busy_cycles + 1;
    end
  end

  initial begin
    #500000;
    $fatal(1, "tb_trike_drng_weight_sampler timeout");
  end

  initial begin
    rst_n          = 1'b0;
    start          = 1'b0;
    index_ready    = 1'b0;
    received_count = 0;
    for (int i = 0; i < WEIGHT; i++) received_index[i] = '0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    wait (index_valid);
    for (int hold_cycle = 0; hold_cycle < 3; hold_cycle++) begin
      logic [1:0] held_position;
      logic [4:0] held_index;
      held_position = index_position;
      held_index    = index_value;
      @(posedge clk);
      #1;
      if (!index_valid || index_position != held_position || index_value != held_index) begin
        $fatal(1, "index output changed under backpressure");
      end
    end

    @(negedge clk);
    index_ready = 1'b1;
    while (received_count < WEIGHT) begin
      @(posedge clk);
      if (index_valid && index_ready) begin
        received_index[index_position] = index_value;
        received_count++;
      end
    end
    @(negedge clk);
    index_ready = 1'b0;

    wait (done);
    #1;
    if (received_index[0] != 5'd7 || received_index[1] != 5'd6 || received_index[2] != 5'd11) begin
      $fatal(1, "index fixture mismatch: got={%0d,%0d,%0d}", received_index[0], received_index[1],
             received_index[2]);
    end
    if (v != EXPECTED_V || c != INITIAL_C || reseed_counter != 440'd4) begin
      $fatal(1, "final DRNG state mismatch");
    end
    if (busy) begin
      $fatal(1, "busy remained asserted after done");
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "busy cycle mismatch: got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end

    $display("tb_trike_drng_weight_sampler PASS cycles=%0d", busy_cycles);
    $finish;
  end

endmodule
