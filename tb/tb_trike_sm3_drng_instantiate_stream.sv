`timescale 1ns / 1ps

module tb_trike_sm3_drng_instantiate_stream;
  localparam int SEED_BYTES = 32;
  localparam int EXPECTED_BUSY_CYCLES = 916;
  localparam logic [439:0] EXPECTED_V =
      440'h16665ec1cb7f52e088e340915fd3eae1a368e63010f30806778d7b208208ffac32f1266f54b42d34a31bc63b7ade4ce41c6cfb307ed37f;
  localparam logic [439:0] EXPECTED_C =
      440'h5663d04e549ec9cb3947d645b6e2f519a97e11f58c61c8e86e47835c7225f4f30d0f640435ed006597257c49f11c99d990d0921750ebda;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         seed_valid;
  logic [  7:0] seed_data;
  logic         seed_ready;
  logic         seed_pass;
  logic         busy;
  logic         done;
  logic [439:0] v;
  logic [439:0] c;
  logic [439:0] reseed_counter;

  int           seed_idx;
  int           busy_cycles;

  assign seed_data = 8'(seed_idx);

  trike_sm3_drng_instantiate_stream #(
      .SEED_BYTES(SEED_BYTES)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_seed_valid    (seed_valid),
      .i_seed_data     (seed_data),
      .o_seed_ready    (seed_ready),
      .o_seed_pass     (seed_pass),
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
    $fatal(1, "tb_trike_sm3_drng_instantiate_stream timeout");
  end

  initial begin
    rst_n      = 1'b0;
    start      = 1'b0;
    seed_valid = 1'b0;
    seed_idx   = 0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    seed_valid = 1'b1;
    for (int pass = 0; pass < 2; pass++) begin
      seed_idx = 0;
      while (seed_idx < SEED_BYTES) begin
        @(posedge clk);
        if (seed_valid && seed_ready) begin
          if (seed_pass != pass[0]) begin
            $fatal(1, "pass mismatch: got=%0d expected=%0d", seed_pass, pass);
          end
          @(negedge clk);
          seed_idx++;
        end
      end
    end
    seed_valid = 1'b0;

    wait (done);
    #1;
    if (v != EXPECTED_V) begin
      $fatal(1, "V mismatch: got=%0110h expected=%0110h", v, EXPECTED_V);
    end
    if (c != EXPECTED_C) begin
      $fatal(1, "C mismatch: got=%0110h expected=%0110h", c, EXPECTED_C);
    end
    if (reseed_counter != 440'd1) begin
      $fatal(1, "reseed counter mismatch: got=%0110h", reseed_counter);
    end
    if (busy) begin
      $fatal(1, "busy remained asserted after done");
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "busy cycle mismatch: got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end

    $display("tb_trike_sm3_drng_instantiate_stream PASS");
    $finish;
  end

endmodule
