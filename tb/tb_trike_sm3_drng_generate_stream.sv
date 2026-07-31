`timescale 1ns / 1ps

module tb_trike_sm3_drng_generate_stream;
  localparam int OUTPUT_BYTES = 64;
  localparam int EXPECTED_BUSY_CYCLES = 708;
  localparam logic [439:0] INITIAL_V =
      440'h16665ec1cb7f52e088e340915fd3eae1a368e63010f30806778d7b208208ffac32f1266f54b42d34a31bc63b7ade4ce41c6cfb307ed37f;
  localparam logic [439:0] INITIAL_C =
      440'h5663d04e549ec9cb3947d645b6e2f519a97e11f58c61c8e86e47835c7225f4f30d0f640435ed006597257c49f11c99d990d0921750ebda;
  localparam logic [511:0] EXPECTED_OUTPUT =
      512'he8901c93650a10456d74d6f7aaeed176175e77370fbe51c04d51c380dc4e90912a12e8f9abc22807e6ea98884e6431bb2d4c092328cd716334277fd44f0f0da0;
  localparam logic [439:0] EXPECTED_V =
      440'h6cca2f10201e1cabc22b16d716b6dffb4ce6f8259d54d1eb547a950b0014c37cf1c16bc49b44c9c59dad38300c43dd11b9a2ce3eb54ceb;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         output_ready;
  logic         output_valid;
  logic [  7:0] output_data;
  logic         busy;
  logic         done;
  logic [439:0] v;
  logic [439:0] c;
  logic [439:0] reseed_counter;

  logic [511:0] collected_output;
  int           output_idx;
  int           busy_cycles;

  trike_sm3_drng_generate_stream #(
      .OUTPUT_BYTES(OUTPUT_BYTES)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_v             (INITIAL_V),
      .i_c             (INITIAL_C),
      .i_reseed_counter(440'd1),
      .i_output_ready  (output_ready),
      .o_output_valid  (output_valid),
      .o_output_data   (output_data),
      .o_busy          (busy),
      .o_done          (done),
      .o_v             (v),
      .o_c             (c),
      .o_reseed_counter(reseed_counter)
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
    #200000;
    $fatal(1, "tb_trike_sm3_drng_generate_stream timeout");
  end

  initial begin
    rst_n            = 1'b0;
    start            = 1'b0;
    output_ready     = 1'b0;
    collected_output = '0;
    output_idx       = 0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start        = 1'b0;
    output_ready = 1'b1;

    while (output_idx < OUTPUT_BYTES) begin
      @(posedge clk);
      if (output_valid && output_ready) begin
        collected_output[511-8*output_idx-:8] = output_data;
        output_idx++;
      end
    end

    wait (done);
    #1;
    if (collected_output != EXPECTED_OUTPUT) begin
      $fatal(1, "output mismatch: got=%0128h expected=%0128h", collected_output, EXPECTED_OUTPUT);
    end
    if (v != EXPECTED_V) begin
      $fatal(1, "V mismatch: got=%0110h expected=%0110h", v, EXPECTED_V);
    end
    if (c != INITIAL_C) begin
      $fatal(1, "C mismatch: got=%0110h expected=%0110h", c, INITIAL_C);
    end
    if (reseed_counter != 440'd2) begin
      $fatal(1, "reseed counter mismatch: got=%0110h", reseed_counter);
    end
    if (busy) begin
      $fatal(1, "busy remained asserted after done");
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "busy cycle mismatch: got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end

    $display("tb_trike_sm3_drng_generate_stream PASS");
    $finish;
  end

endmodule
