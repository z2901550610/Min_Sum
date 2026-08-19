`timescale 1ns / 1ps

/* verilator lint_off DECLFILENAME */
module sm3_hash_stream_case #(
    parameter int           INPUT_BYTES     = 3,
    parameter bit           ABC_MESSAGE     = 1'b0,
    parameter logic [255:0] EXPECTED_DIGEST = '0
) (
    input  logic i_clk,
    input  logic i_rst_n,
    output logic o_pass
);

  logic         start;
  logic         input_valid;
  logic [  7:0] input_data;
  logic         input_ready;
  logic         busy;
  logic         done;
  logic [255:0] digest;

  int           sent_count;

  sm3_hash_stream #(
      .INPUT_BYTES(INPUT_BYTES)
  ) dut (
      .i_clk                (i_clk),
      .i_rst_n              (i_rst_n),
      .i_start              (start),
      .i_runtime_input_bytes('0),
      .i_input_valid        (input_valid),
      .i_input_data         (input_data),
      .o_input_ready        (input_ready),
      .o_busy               (busy),
      .o_done               (done),
      .o_digest             (digest)
  );

  always_comb begin
    if (ABC_MESSAGE) begin
      unique case (sent_count)
        0: input_data = 8'h61;
        1: input_data = 8'h62;
        default: input_data = 8'h63;
      endcase
    end else begin
      input_data = 8'(sent_count);
    end
  end

  initial begin
    start       = 1'b0;
    input_valid = 1'b0;
    sent_count  = 0;
    o_pass      = 1'b0;

    wait (i_rst_n);
    @(negedge i_clk);
    start = 1'b1;
    @(negedge i_clk);
    start       = 1'b0;
    input_valid = 1'b1;

    while (sent_count < INPUT_BYTES) begin
      @(posedge i_clk);
      if (input_valid && input_ready) begin
        @(negedge i_clk);
        sent_count++;
      end
    end
    input_valid = 1'b0;

    wait (done);
    #1;
    if (digest != EXPECTED_DIGEST) begin
      $fatal(1, "INPUT_BYTES=%0d digest mismatch: got=%064h expected=%064h", INPUT_BYTES, digest,
             EXPECTED_DIGEST);
    end
    if (busy) begin
      $fatal(1, "INPUT_BYTES=%0d busy remained asserted after done", INPUT_BYTES);
    end
    o_pass = 1'b1;
  end

endmodule
/* verilator lint_on DECLFILENAME */

module tb_sm3_hash_stream;
  logic       clk;
  logic       rst_n;
  logic [4:0] case_pass;

  sm3_hash_stream_case #(
      .INPUT_BYTES    (3),
      .ABC_MESSAGE    (1'b1),
      .EXPECTED_DIGEST(256'h66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0)
  ) u_case_abc (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .o_pass (case_pass[0])
  );

  sm3_hash_stream_case #(
      .INPUT_BYTES    (55),
      .EXPECTED_DIGEST(256'ha79cf9dcee3404abf7f769698201647fd9d3ff61d629d0f58bb4b5579a427db8)
  ) u_case_55 (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .o_pass (case_pass[1])
  );

  sm3_hash_stream_case #(
      .INPUT_BYTES    (56),
      .EXPECTED_DIGEST(256'h62f7363b15f4de76dd925c493b9d6d00d4ba0ef2a1f334c1d0f13b293aeb40d1)
  ) u_case_56 (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .o_pass (case_pass[2])
  );

  sm3_hash_stream_case #(
      .INPUT_BYTES    (64),
      .EXPECTED_DIGEST(256'h93566f236d157aae078d1ddb5cebdbba1520b5142e22a8915564345ba2ae1d63)
  ) u_case_64 (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .o_pass (case_pass[3])
  );

  sm3_hash_stream_case #(
      .INPUT_BYTES    (65),
      .EXPECTED_DIGEST(256'hc886e6814be748285a10b28ae62ddacd85db830cd2cf3a2bfa2f729c15f63618)
  ) u_case_65 (
      .i_clk  (clk),
      .i_rst_n(rst_n),
      .o_pass (case_pass[4])
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    #50000;
    $fatal(1, "tb_sm3_hash_stream timeout");
  end

  initial begin
    rst_n = 1'b0;
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    wait (&case_pass);
    $display("tb_sm3_hash_stream PASS");
    $finish;
  end

endmodule
