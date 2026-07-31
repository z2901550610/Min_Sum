`timescale 1ns / 1ps

module tb_trike_fixed_weight_sampler;
  localparam int LENGTH = 17;
  localparam int WEIGHT = 5;
  localparam int INDEX_W = $clog2(LENGTH);
  localparam int POSITION_W = $clog2(WEIGHT);
  localparam int EXPECTED_BUSY_CYCLES = WEIGHT * (WEIGHT + 3);

  logic                  clk;
  logic                  rst_n;
  logic                  start;
  logic                  random_valid;
  logic [          31:0] random_data;
  logic                  random_ready;
  logic                  index_valid;
  logic [POSITION_W-1:0] index_position;
  logic [   INDEX_W-1:0] index_value;
  logic                  index_ready;
  logic                  busy;
  logic                  done;

  logic [          31:0] random_words[0:WEIGHT-1];
  logic [   INDEX_W-1:0] expected_indices[0:WEIGHT-1];

  trike_fixed_weight_sampler #(
      .LENGTH(LENGTH),
      .WEIGHT(WEIGHT)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_random_valid  (random_valid),
      .i_random_data   (random_data),
      .o_random_ready  (random_ready),
      .o_index_valid   (index_valid),
      .o_index_position(index_position),
      .o_index         (index_value),
      .i_index_ready   (index_ready),
      .o_busy          (busy),
      .o_done          (done)
  );

  always #5 clk = ~clk;

  task automatic run_case(input int output_stall_cycles, output int busy_cycles);
    int                    random_idx;
    int                    output_count;
    int                    held_cycles;
    logic                  random_transfer;
    logic                  index_transfer;
    logic                  cycle_busy;
    logic [POSITION_W-1:0] held_position;
    logic [   INDEX_W-1:0] held_index;
    begin
      @(negedge clk);
      start = 1'b1;
      @(posedge clk);
      #1;
      start = 1'b0;

      random_idx = 0;
      output_count = 0;
      held_cycles = 0;
      busy_cycles = 0;
      random_valid = 1'b1;
      random_data = random_words[0];
      index_ready = (output_stall_cycles == 0);

      while (!done) begin
        @(negedge clk);
        cycle_busy      = busy;
        random_transfer = random_valid && random_ready;

        if (index_valid && !index_ready) begin
          if (held_cycles == 0) begin
            held_position = index_position;
            held_index    = index_value;
          end else if ((index_position != held_position) || (index_value != held_index)) begin
            $fatal(1, "sampler output changed under backpressure");
          end
          held_cycles++;
          if (held_cycles == (output_stall_cycles + 1)) index_ready = 1'b1;
        end
        index_transfer = index_valid && index_ready;

        @(posedge clk);
        #1;
        if (cycle_busy) busy_cycles++;

        if (random_transfer) begin
          random_idx++;
          if (random_idx == WEIGHT) begin
            random_valid = 1'b0;
          end else begin
            random_data = random_words[random_idx];
          end
        end

        if (index_transfer) begin
          if (held_position != POSITION_W'(WEIGHT - 1 - output_count)) begin
            $fatal(1, "position mismatch at output %0d: got=%0d", output_count, held_position);
          end
          if (held_index != expected_indices[held_position]) begin
            $fatal(1, "index mismatch at position %0d: got=%0d expected=%0d", held_position,
                   held_index, expected_indices[held_position]);
          end
          output_count++;
        end

        if (index_valid) begin
          held_position = index_position;
          held_index    = index_value;
        end
      end

      if (random_idx != WEIGHT) $fatal(1, "not all random words transferred");
      if (output_count != WEIGHT) $fatal(1, "not all indices transferred");
    end
  endtask

  int collision_cycles;
  int distinct_cycles;
  int stalled_cycles;

  initial begin
    clk          = 1'b0;
    rst_n        = 1'b0;
    start        = 1'b0;
    random_valid = 1'b0;
    random_data  = '0;
    index_ready  = 1'b0;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    random_words[0] = 32'hffffffff;
    random_words[1] = 32'hedb6db6e;
    random_words[2] = 32'h11111112;
    random_words[3] = 32'h10000000;
    random_words[4] = 32'h0f0f0f10;
    expected_indices[0] = INDEX_W'(0);
    expected_indices[1] = INDEX_W'(1);
    expected_indices[2] = INDEX_W'(2);
    expected_indices[3] = INDEX_W'(3);
    expected_indices[4] = INDEX_W'(16);
    run_case(0, collision_cycles);
    if (collision_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "collision case cycles=%0d expected=%0d", collision_cycles, EXPECTED_BUSY_CYCLES);
    end

    for (int word_idx = 0; word_idx < WEIGHT; word_idx++) begin
      random_words[word_idx] = 32'h00000000;
      expected_indices[word_idx] = INDEX_W'(word_idx);
    end
    run_case(0, distinct_cycles);
    if (distinct_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "distinct case cycles=%0d expected=%0d", distinct_cycles, EXPECTED_BUSY_CYCLES);
    end
    if (distinct_cycles != collision_cycles) begin
      $fatal(1, "sampler latency depends on collision pattern");
    end

    run_case(4, stalled_cycles);
    if (stalled_cycles != EXPECTED_BUSY_CYCLES + 4) begin
      $fatal(1, "stalled case cycles=%0d expected=%0d", stalled_cycles, EXPECTED_BUSY_CYCLES + 4);
    end

    $display("tb_trike_fixed_weight_sampler PASS");
    $finish;
  end

  initial begin
    repeat (1000) @(posedge clk);
    $fatal(1, "tb_trike_fixed_weight_sampler timeout");
  end
endmodule
