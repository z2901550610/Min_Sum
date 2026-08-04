`timescale 1ns / 1ps

module tb_trike_pseudohash_synth_top;
  localparam int MESSAGE_BYTES = 32;
  localparam logic [511:0] EXPECTED_DIGEST =
      512'h2acdcc794d88db70909ece5572a0a48fb435e938e38602afdd7a1afebd6df20f2294a54168ecb4f530f83c9608c08606cf5dce87970f44703eefdc22c8896ac6;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         input_valid;
  logic [  7:0] input_data;
  logic         input_ready;
  logic         input_pass;
  logic         busy;
  logic         done;
  logic         result_valid;
  logic [ 63:0] result_data;
  logic         result_last;
  logic         result_ready;

  logic [511:0] received_digest;
  int           input_idx;
  int           result_idx;

  assign input_data = 8'(input_idx);

  trike_pseudohash_synth_top dut (
      .i_clk         (clk),
      .i_rst_n       (rst_n),
      .i_start       (start),
      .i_input_valid (input_valid),
      .i_input_data  (input_data),
      .o_input_ready (input_ready),
      .o_input_pass  (input_pass),
      .o_busy        (busy),
      .o_done        (done),
      .o_result_valid(result_valid),
      .o_result_data (result_data),
      .o_result_last (result_last),
      .i_result_ready(result_ready)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #300000;
    $fatal(1, "tb_trike_pseudohash_synth_top timeout");
  end

  initial begin
    rst_n           = 1'b0;
    start           = 1'b0;
    input_valid     = 1'b0;
    result_ready    = 1'b0;
    received_digest = '0;
    input_idx       = 0;
    result_idx      = 0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    repeat (2) @(posedge clk);
    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    input_valid = 1'b1;
    for (int pass = 0; pass < 2; pass++) begin
      input_idx = 0;
      while (input_idx < MESSAGE_BYTES) begin
        @(posedge clk);
        if (input_valid && input_ready) begin
          if (input_pass != pass[0]) begin
            $fatal(1, "pass mismatch: got=%0d expected=%0d", input_pass, pass);
          end
          @(negedge clk);
          input_idx++;
        end
      end
    end
    input_valid = 1'b0;

    wait (result_valid);
    repeat (3) @(posedge clk);
    if (!result_valid || !busy) begin
      $fatal(1, "output backpressure was not held");
    end

    @(negedge clk);
    result_ready = 1'b1;
    while (result_idx < 8) begin
      @(posedge clk);
      if (result_valid && result_ready) begin
        received_digest[511-64*result_idx-:64] = result_data;
        if (result_last != (result_idx == 7)) begin
          $fatal(1, "last mismatch at result word %0d", result_idx);
        end
        result_idx++;
      end
    end
    @(negedge clk);
    result_ready = 1'b0;

    wait (done);
    #1;
    if (received_digest != EXPECTED_DIGEST) begin
      $fatal(1, "digest mismatch: got=%0128h expected=%0128h", received_digest, EXPECTED_DIGEST);
    end
    if (busy || result_valid) begin
      $fatal(1, "wrapper remained busy after final result handshake");
    end

    $display("tb_trike_pseudohash_synth_top PASS");
    $finish;
  end

endmodule
