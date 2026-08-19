`timescale 1ns / 1ps

module tb_sm3_df_stream;
  localparam int INPUT_BYTES = 32;
  localparam int EXPECTED_BUSY_CYCLES = 314;
  localparam logic [439:0] EXPECTED_SEED =
      440'h16665ec1cb7f52e088e340915fd3eae1a368e63010f30806778d7b208208ffac32f1266f54b42d34a31bc63b7ade4ce41c6cfb307ed37f;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         input_valid;
  logic [  7:0] input_data;
  logic         input_ready;
  logic         input_pass;
  logic         busy;
  logic         done;
  logic [439:0] seed;

  int           input_idx;
  int           busy_cycles;

  assign input_data = 8'(input_idx);

  sm3_df_stream #(
      .INPUT_BYTES(INPUT_BYTES)
  ) dut (
      .i_clk                (clk),
      .i_rst_n              (rst_n),
      .i_start              (start),
      .i_runtime_input_bytes('0),
      .i_input_valid        (input_valid),
      .i_input_data         (input_data),
      .o_input_ready        (input_ready),
      .o_input_pass         (input_pass),
      .o_busy               (busy),
      .o_done               (done),
      .o_seed               (seed)
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
    #100000;
    $fatal(1, "tb_sm3_df_stream timeout");
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
      while (input_idx < INPUT_BYTES) begin
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
    if (seed != EXPECTED_SEED) begin
      $fatal(1, "seed mismatch: got=%0110h expected=%0110h", seed, EXPECTED_SEED);
    end
    if (busy) begin
      $fatal(1, "busy remained asserted after done");
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "busy cycle mismatch: got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end

    $display("tb_sm3_df_stream PASS");
    $finish;
  end

endmodule
