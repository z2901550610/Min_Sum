`timescale 1ns / 1ps

module tb_trike_parity_map_stream;
  localparam int R = 13;
  localparam int R_BYTES = (R + 7) / 8;
  localparam int EXPECTED_BUSY_CYCLES = (2 * R_BYTES) + 1;

  logic       clk;
  logic       rst_n;
  logic       start;
  logic       target_parity;
  logic       input_valid;
  logic [7:0] input_data;
  logic       input_ready;
  logic       output_valid;
  logic [7:0] output_data;
  logic       output_ready;
  logic       busy;
  logic       done;

  logic [7:0] input_bytes[0:R_BYTES-1];
  logic [7:0] expected_bytes[0:R_BYTES-1];

  trike_parity_map_stream #(
      .R(R)
  ) dut (
      .i_clk          (clk),
      .i_rst_n        (rst_n),
      .i_start        (start),
      .i_target_parity(target_parity),
      .i_input_valid  (input_valid),
      .i_input_data   (input_data),
      .o_input_ready  (input_ready),
      .o_output_valid (output_valid),
      .o_output_data  (output_data),
      .i_output_ready (output_ready),
      .o_busy         (busy),
      .o_done         (done)
  );

  always #5 clk = ~clk;

  task automatic run_case(input  logic parity_target, input int stall_cycles,
                          output int busy_cycles);
    int         input_idx;
    int         output_idx;
    int         held_cycles;
    logic       input_transfer;
    logic       output_transfer;
    logic       cycle_busy;
    logic [7:0] held_data;
    begin
      @(negedge clk);
      target_parity = parity_target;
      start         = 1'b1;
      @(posedge clk);
      #1;
      start = 1'b0;

      input_idx = 0;
      output_idx = 0;
      busy_cycles = 0;
      held_cycles = 0;
      input_valid = 1'b1;
      input_data = input_bytes[0];
      output_ready = (stall_cycles == 0);

      while (!done) begin
        @(negedge clk);
        cycle_busy     = busy;
        input_transfer = input_valid && input_ready;

        if (output_valid && !output_ready) begin
          if (held_cycles == 0) begin
            held_data = output_data;
          end else if (output_data != held_data) begin
            $fatal(1, "parity mapper output changed under backpressure");
          end
          held_cycles++;
          if (held_cycles == (stall_cycles + 1)) output_ready = 1'b1;
        end
        output_transfer = output_valid && output_ready;

        @(posedge clk);
        #1;
        if (cycle_busy) busy_cycles++;

        if (input_transfer) begin
          input_idx++;
          if (input_idx == R_BYTES) begin
            input_valid = 1'b0;
          end else begin
            input_data = input_bytes[input_idx];
          end
        end

        if (output_transfer) begin
          if (held_data != expected_bytes[output_idx]) begin
            $fatal(1, "output byte %0d mismatch: got=%02x expected=%02x", output_idx, held_data,
                   expected_bytes[output_idx]);
          end
          output_idx++;
        end

        if (output_valid) held_data = output_data;
      end

      if (input_idx != R_BYTES) $fatal(1, "not all parity mapper input bytes transferred");
      if (output_idx != R_BYTES) $fatal(1, "not all parity mapper output bytes transferred");
    end
  endtask

  int even_cycles;
  int odd_cycles;
  int stalled_cycles;

  initial begin
    clk            = 1'b0;
    rst_n          = 1'b0;
    start          = 1'b0;
    target_parity  = 1'b0;
    input_valid    = 1'b0;
    input_data     = '0;
    output_ready   = 1'b0;
    input_bytes[0] = 8'hb3;
    input_bytes[1] = 8'hff;

    repeat (3) @(posedge clk);
    rst_n = 1'b1;

    expected_bytes[0] = 8'hb3;
    expected_bytes[1] = 8'h1f;
    run_case(1'b0, 0, even_cycles);
    if (even_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "even case cycles=%0d expected=%0d", even_cycles, EXPECTED_BUSY_CYCLES);
    end

    expected_bytes[1] = 8'h0f;
    run_case(1'b1, 0, odd_cycles);
    if (odd_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "odd case cycles=%0d expected=%0d", odd_cycles, EXPECTED_BUSY_CYCLES);
    end

    expected_bytes[1] = 8'h1f;
    run_case(1'b0, 3, stalled_cycles);
    if (stalled_cycles != EXPECTED_BUSY_CYCLES + 3) begin
      $fatal(1, "stalled case cycles=%0d expected=%0d", stalled_cycles, EXPECTED_BUSY_CYCLES + 3);
    end

    $display("tb_trike_parity_map_stream PASS");
    $finish;
  end

  initial begin
    repeat (300) @(posedge clk);
    $fatal(1, "tb_trike_parity_map_stream timeout");
  end
endmodule
