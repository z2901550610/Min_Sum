`timescale 1ns / 1ps

module tb_trike_h4_error_sampler;
  localparam int M_BYTES = 4;
  localparam int R_BITS = 13;
  localparam int ERROR_WEIGHT = 3;
  localparam int SEED_BYTES = M_BYTES + ((R_BITS + 7) / 8);
  localparam int EXPECTED_BUSY_CYCLES = 2313;
  localparam logic [439:0] EXPECTED_V =
      440'hde04aac5a68fa2ed9019cd5ed0589b75c621e4b59884c033b8ba1cb8e6b55d753ca76d8b77d4d086a20130f3a391f5cf1f791b694150cc;
  localparam logic [439:0] EXPECTED_C =
      440'h39f229d29eca5b8d82a8c7ae1e8d1bba244183751cc6a170a21d9e8e10dfe1c80d876cd78b83ecb56291ae4fda8ae7012e4511f6d55872;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         seed_valid;
  logic [  7:0] seed_data;
  logic         seed_ready;
  logic         seed_pass;
  logic         index_valid;
  logic [  1:0] index_position;
  logic [  5:0] index_value;
  logic         index_ready;
  logic         busy;
  logic         done;
  logic [439:0] v;
  logic [439:0] c;
  logic [439:0] reseed_counter;

  logic [  5:0] received_index[0:ERROR_WEIGHT-1];
  int           seed_idx;
  int           received_count;
  int           busy_cycles;

  assign seed_data = 8'(seed_idx);

  /* verilator lint_off PINCONNECTEMPTY */
  trike_h4_error_sampler #(
      .M_BYTES     (M_BYTES),
      .R_BITS      (R_BITS),
      .ERROR_WEIGHT(ERROR_WEIGHT)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_seed_valid    (seed_valid),
      .i_seed_data     (seed_data),
      .o_seed_ready    (seed_ready),
      .o_seed_pass     (seed_pass),
      .o_index_valid   (index_valid),
      .o_index_position(index_position),
      .o_index         (index_value),
      .i_index_ready   (index_ready),
      .o_busy          (busy),
      .o_done          (done),
      .o_v             (v),
      .o_c             (c),
      .o_reseed_counter(reseed_counter),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

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
    #800000;
    $fatal(1, "tb_trike_h4_error_sampler timeout");
  end

  initial begin
    rst_n          = 1'b0;
    start          = 1'b0;
    seed_valid     = 1'b0;
    index_ready    = 1'b0;
    seed_idx       = 0;
    received_count = 0;
    for (int i = 0; i < ERROR_WEIGHT; i++) received_index[i] = '0;

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
            $fatal(1, "seed pass mismatch: got=%0d expected=%0d", seed_pass, pass);
          end
          @(negedge clk);
          seed_idx++;
        end
      end
    end
    seed_valid  = 1'b0;
    index_ready = 1'b1;

    while (received_count < ERROR_WEIGHT) begin
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
    if (received_index[0] != 6'd37 || received_index[1] != 6'd10 ||
        received_index[2] != 6'd13) begin
      $fatal(1, "H4 index mismatch: got={%0d,%0d,%0d}", received_index[0], received_index[1],
             received_index[2]);
    end
    if (v != EXPECTED_V || c != EXPECTED_C || reseed_counter != 440'd4) begin
      $fatal(1, "H4 final DRNG state mismatch");
    end
    if (busy) begin
      $fatal(1, "H4 service remained busy after done");
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "H4 busy cycle mismatch: got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end

    $display("tb_trike_h4_error_sampler PASS cycles=%0d", busy_cycles);
    $finish;
  end

endmodule
