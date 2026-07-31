`timescale 1ns / 1ps

module tb_shake256_stream;
  localparam int INPUT_BYTES = 272;
  localparam int OUTPUT_BYTES = 200;
  localparam logic [8*OUTPUT_BYTES-1:0] EXPECTED_OUTPUT =
      1600'hecd86f2a67d4137400685e60c59e676f7abdcb6136647fbccf28062ebc71b24130729dfbf789395361bd0698325fa11cf8bd1907971d1f2cf753bdb1ad0accc1de17f690e17c0936f132192df8babf2948d64498808299fabaa628c5c64a4f7881b52479d75dcfe31a5cea8e50c77c199a9bf121f927b19e09657dcd456131f04a3bd3da3ef677f0ab4eb24c905d995155029567ea95a780795cbb2c2337fd0342fa69db67d6e08df0be2a42e814b0a299bdc0f62f0bfd199500f84b7946c9fb911279106da37983;

  logic       clk;
  logic       rst_n;
  logic       start;
  logic       input_valid;
  logic [7:0] input_data;
  logic       input_ready;
  logic       output_ready;
  logic       output_valid;
  logic [7:0] output_data;
  logic       busy;
  logic       done;

  int         output_count;
  int         cycle_count;
  logic       held_valid;
  logic [7:0] held_data;

  shake256_stream #(
      .INPUT_BYTES (INPUT_BYTES),
      .OUTPUT_BYTES(OUTPUT_BYTES)
  ) dut (
      .i_clk         (clk),
      .i_rst_n       (rst_n),
      .i_start       (start),
      .i_input_valid (input_valid),
      .i_input_data  (input_data),
      .o_input_ready (input_ready),
      .i_output_ready(output_ready),
      .o_output_valid(output_valid),
      .o_output_data (output_data),
      .o_busy        (busy),
      .o_done        (done)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #100000;
    $fatal(1, "tb_shake256_stream timeout");
  end

  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
    if (held_valid && (output_data != held_data)) begin
      $fatal(1, "output data changed while backpressured");
    end
    held_valid <= output_valid && !output_ready;
    held_data  <= output_data;

    if (output_valid && output_ready) begin
      if (output_data != EXPECTED_OUTPUT[8*output_count+:8]) begin
        $fatal(1, "output byte %0d mismatch: got=%02h expected=%02h", output_count, output_data,
               EXPECTED_OUTPUT[8*output_count+:8]);
      end
      output_count <= output_count + 1;
    end
  end

  always_comb begin
    output_ready = (cycle_count % 5) != 0;
  end

  initial begin
    rst_n        = 1'b0;
    start        = 1'b0;
    input_valid  = 1'b0;
    input_data   = '0;
    output_count = 0;
    cycle_count  = 0;
    held_valid   = 1'b0;
    held_data    = '0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    for (int byte_idx = 0; byte_idx < INPUT_BYTES; byte_idx++) begin
      while (!input_ready) @(negedge clk);
      input_valid = 1'b1;
      input_data  = 8'(byte_idx);
      @(negedge clk);
      input_valid = 1'b0;
    end

    wait (done);
    #1;
    if (output_count != OUTPUT_BYTES) begin
      $fatal(1, "output length mismatch: got=%0d expected=%0d", output_count, OUTPUT_BYTES);
    end
    if (busy) $fatal(1, "busy remained asserted after completion");

    $display("tb_shake256_stream PASS");
    $finish;
  end
endmodule
