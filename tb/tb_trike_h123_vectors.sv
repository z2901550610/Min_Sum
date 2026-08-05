`timescale 1ns / 1ps

module tb_trike_h123_vectors;

  localparam int M_BYTES = 4;
  localparam int R_BITS = 13;
  localparam int R_BYTES = (R_BITS + 7) / 8;
  localparam int EXPECTED_BUSY_CYCLES = 2284;
  localparam logic [439:0] EXPECTED_V =
      440'h48028506749d882fc3c330fe4fbcaa54bfc217d2c7ec8e8cd5a7e7e930f7e8e458d96010b5bf1d03b31a6b521100185f1f6e0b881649d4;
  localparam logic [439:0] EXPECTED_C =
      440'h4811a9bd6fcfa908df058124d3c470d7ca43a91023c1b497e8a4c776453a03f51f267a6d4409d254fe1da35e7c3f0723b9f3f230bee832;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         seed_valid;
  logic [  7:0] seed_data;
  logic         seed_ready;
  logic         seed_pass;
  logic         vector_valid;
  logic [  1:0] vector_select;
  logic         vector_byte;
  logic [  7:0] vector_data;
  logic         vector_ready;
  logic         busy;
  logic         done;
  logic [439:0] v;
  logic [439:0] c;
  logic [439:0] reseed_counter;

  logic [  7:0] expected[0:2][0:R_BYTES-1];
  logic [  7:0] received[0:2][0:R_BYTES-1];
  int           seed_idx;
  int           received_count;
  int           busy_cycles;

  assign seed_data = 8'(seed_idx);

  /* verilator lint_off PINCONNECTEMPTY */
  trike_h123_vectors #(
      .M_BYTES(M_BYTES),
      .R_BITS (R_BITS)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_seed_valid    (seed_valid),
      .i_seed_data     (seed_data),
      .o_seed_ready    (seed_ready),
      .o_seed_pass     (seed_pass),
      .o_vector_valid  (vector_valid),
      .o_vector_select (vector_select),
      .o_vector_byte   (vector_byte),
      .o_vector_data   (vector_data),
      .i_vector_ready  (vector_ready),
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
    #1000000;
    $fatal(1, "tb_trike_h123_vectors timeout");
  end

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    seed_valid = 1'b0;
    vector_ready = 1'b0;
    seed_idx = 0;
    received_count = 0;
    for (int vector_idx = 0; vector_idx < 3; vector_idx++) begin
      for (int byte_idx = 0; byte_idx < R_BYTES; byte_idx++) received[vector_idx][byte_idx] = '0;
    end
    expected[0][0] = 8'h2d;
    expected[0][1] = 8'h00;
    expected[1][0] = 8'h79;
    expected[1][1] = 8'h08;
    expected[2][0] = 8'h21;
    expected[2][1] = 8'h0d;

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
      while (seed_idx < M_BYTES) begin
        @(posedge clk);
        if (seed_valid && seed_ready) begin
          if (seed_pass != pass[0]) $fatal(1, "seed pass mismatch");
          @(negedge clk);
          seed_idx++;
        end
      end
    end
    seed_valid = 1'b0;

    wait (vector_valid);
    for (int stall = 0; stall < 3; stall++) begin
      logic [1:0] held_select;
      logic       held_byte;
      logic [7:0] held_data;
      held_select = vector_select;
      held_byte   = vector_byte;
      held_data   = vector_data;
      @(posedge clk);
      #1;
      if (!vector_valid || vector_select != held_select || vector_byte != held_byte ||
          vector_data != held_data) begin
        $fatal(1, "vector output changed under backpressure");
      end
    end

    @(negedge clk);
    vector_ready = 1'b1;
    while (received_count < (3 * R_BYTES)) begin
      @(posedge clk);
      if (vector_valid && vector_ready) begin
        received[vector_select][vector_byte] = vector_data;
        received_count++;
      end
    end
    @(negedge clk);
    vector_ready = 1'b0;

    wait (done);
    #1;
    for (int vector_idx = 0; vector_idx < 3; vector_idx++) begin
      for (int byte_idx = 0; byte_idx < R_BYTES; byte_idx++) begin
        if (received[vector_idx][byte_idx] != expected[vector_idx][byte_idx]) begin
          $fatal(1, "vector mismatch vector=%0d byte=%0d got=%02x expected=%02x", vector_idx,
                 byte_idx, received[vector_idx][byte_idx], expected[vector_idx][byte_idx]);
        end
      end
    end
    if (v != EXPECTED_V || c != EXPECTED_C || reseed_counter != 440'd4) begin
      $fatal(1, "final H1/H2/H3 DRNG state mismatch");
    end
    if (busy) $fatal(1, "H1/H2/H3 service remained busy after done");
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "H1/H2/H3 busy cycle mismatch: got=%0d expected=%0d", busy_cycles,
             EXPECTED_BUSY_CYCLES);
    end

    $display("tb_trike_h123_vectors PASS cycles=%0d", busy_cycles);
    $finish;
  end

endmodule
