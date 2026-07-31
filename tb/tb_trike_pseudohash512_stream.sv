`timescale 1ns / 1ps

module tb_trike_pseudohash512_stream;
  localparam int MESSAGE_BYTES = 32;
  localparam int EXPECTED_BUSY_CYCLES = 1128;
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
  logic [511:0] digest;

  int           input_idx;
  int           busy_cycles;

  assign input_data = 8'(input_idx);

  trike_pseudohash512_stream #(
      .MESSAGE_BYTES(MESSAGE_BYTES)
  ) dut (
      .i_clk        (clk),
      .i_rst_n      (rst_n),
      .i_start      (start),
      .i_input_valid(input_valid),
      .i_input_data (input_data),
      .o_input_ready(input_ready),
      .o_input_pass (input_pass),
      .o_busy       (busy),
      .o_done       (done),
      .o_digest     (digest)
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
    #300000;
    $fatal(1, "tb_trike_pseudohash512_stream timeout");
  end

  initial begin
    rst_n       = 1'b0;
    start       = 1'b0;
    input_valid = 1'b0;
    input_idx   = 0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

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

    wait (done);
    #1;
    if (digest != EXPECTED_DIGEST) begin
      $fatal(1, "digest mismatch: got=%0128h expected=%0128h", digest, EXPECTED_DIGEST);
    end
    if (busy) begin
      $fatal(1, "busy remained asserted after done");
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "busy cycle mismatch: got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end

    $display("tb_trike_pseudohash512_stream PASS");
    $finish;
  end

endmodule
