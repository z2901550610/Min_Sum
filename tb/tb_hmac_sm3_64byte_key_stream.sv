`timescale 1ns / 1ps

module tb_hmac_sm3_64byte_key_stream;
  localparam int MESSAGE_BYTES = 5;
  localparam logic [511:0] ICCS_KEY = {
    256'h5307f6d5eb6a3ced3d24c53cc9c82cce2f8936397023f0695c26c80c1ab182a7,
    256'h1db02ba92f544018115a96e719662ca32b7c7efc0a6d2482150766ba6f655b8e
  };
  localparam logic [255:0] EXPECTED_DIGEST =
      256'hcf45aba1dd21f7a103e00c9f0c7b51e33eba7c75655067a9e2c233d9c32ebf22;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         input_valid;
  logic [  7:0] input_data;
  logic         input_ready;
  logic         busy;
  logic         done;
  logic [255:0] digest;

  int           sent_count;

  hmac_sm3_64byte_key_stream #(
      .MESSAGE_BYTES(MESSAGE_BYTES)
  ) dut (
      .i_clk        (clk),
      .i_rst_n      (rst_n),
      .i_start      (start),
      .i_key        (ICCS_KEY),
      .i_input_valid(input_valid),
      .i_input_data (input_data),
      .o_input_ready(input_ready),
      .o_busy       (busy),
      .o_done       (done),
      .o_digest     (digest)
  );

  always_comb begin
    unique case (sent_count)
      0: input_data = 8'h02;
      1: input_data = 8'h00;
      2: input_data = 8'h61;
      3: input_data = 8'h62;
      default: input_data = 8'h63;
    endcase
  end

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #100000;
    $fatal(1, "tb_hmac_sm3_64byte_key_stream timeout");
  end

  initial begin
    rst_n       = 1'b0;
    start       = 1'b0;
    input_valid = 1'b0;
    sent_count  = 0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    input_valid = 1'b1;
    while (sent_count < MESSAGE_BYTES) begin
      @(posedge clk);
      if (input_valid && input_ready) begin
        @(negedge clk);
        sent_count++;
      end
    end
    input_valid = 1'b0;

    wait (done);
    #1;
    if (digest != EXPECTED_DIGEST) begin
      $fatal(1, "digest mismatch: got=%064h expected=%064h", digest, EXPECTED_DIGEST);
    end
    if (busy) begin
      $fatal(1, "busy remained asserted after done");
    end

    $display("tb_hmac_sm3_64byte_key_stream PASS");
    $finish;
  end

endmodule
