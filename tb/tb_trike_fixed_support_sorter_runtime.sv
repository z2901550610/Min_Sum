`timescale 1ns / 1ps

module tb_trike_fixed_support_sorter_runtime;
  localparam int MAX_R = 23;
  localparam int BLOCKS = 3;
  localparam int MAX_WEIGHT = 5;
  localparam int ROW_W = $clog2(MAX_R);
  localparam int BLOCK_W = $clog2(BLOCKS);
  localparam int DIAG_W = $clog2(MAX_WEIGHT);
  localparam int MAX_TOTAL = BLOCKS * MAX_WEIGHT;

  logic                 clk;
  logic                 rst_n;
  logic                 start;
  logic   [       31:0] runtime_r_bits;
  logic   [       31:0] runtime_weight;
  logic                 valid;
  logic   [  ROW_W-1:0] index_in;
  logic                 ready_in;
  logic                 valid_out;
  logic   [BLOCK_W-1:0] block_out;
  logic   [ DIAG_W-1:0] diag_out;
  logic   [  ROW_W-1:0] index_out;
  logic                 busy;
  logic                 done;

  logic   [  ROW_W-1:0] input_data[0:MAX_TOTAL-1];
  logic   [  ROW_W-1:0] expected_data[0:MAX_TOTAL-1];
  integer               active_weight;
  integer               active_total;
  integer               send_count;
  integer               receive_count;
  integer               cycle_count;

  trike_fixed_support_sorter #(
      .R_BITS          (MAX_R),
      .BLOCKS          (BLOCKS),
      .WEIGHT          (MAX_WEIGHT),
      .RUNTIME_GEOMETRY(1'b1)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_runtime_r_bits(runtime_r_bits),
      .i_runtime_weight(runtime_weight),
      .i_valid         (valid),
      .i_index         (index_in),
      .o_ready         (ready_in),
      .o_valid         (valid_out),
      .o_block_idx     (block_out),
      .o_diag_idx      (diag_out),
      .o_index         (index_out),
      .i_ready         (1'b1),
      .o_busy          (busy),
      .o_done          (done)
  );

  always #1 clk = ~clk;

  always_comb begin
    valid = send_count < active_total;
    index_in = input_data[(send_count<active_total)?send_count : 0];
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      send_count <= 0;
      receive_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        send_count <= 0;
        receive_count <= 0;
      end else begin
        if (valid && ready_in) send_count <= send_count + 1;
        if (valid_out) begin
          if (block_out != BLOCK_W'(receive_count / active_weight))
            $fatal(1, "runtime sorter block mismatch");
          if (diag_out != DIAG_W'(receive_count % active_weight))
            $fatal(1, "runtime sorter diagonal mismatch");
          if (index_out != expected_data[receive_count])
            $fatal(1, "runtime sorter coordinate mismatch");
          receive_count <= receive_count + 1;
        end
      end
    end
  end

  task automatic prepare_case(input integer r_value, input integer weight_value,
                              input  logic [7:0] seed);
    logic [ROW_W-1:0] swap_value;
    begin
      active_weight = weight_value;
      active_total  = BLOCKS * weight_value;
      for (int idx = 0; idx < MAX_TOTAL; idx++) begin
        input_data[idx] = '0;
        expected_data[idx] = '0;
      end
      for (int block_idx = 0; block_idx < BLOCKS; block_idx++) begin
        for (int diag_idx = 0; diag_idx < weight_value; diag_idx++) begin
          input_data[(block_idx*weight_value)+diag_idx] =
              ROW_W'(((diag_idx * 7) + (block_idx * 5) + int'(seed)) % r_value);
          expected_data[(block_idx*weight_value)+diag_idx] =
              input_data[(block_idx*weight_value)+diag_idx];
        end
        for (int pass_idx = 0; pass_idx < weight_value; pass_idx++) begin
          for (int compare_idx = 0; compare_idx < (weight_value - 1); compare_idx++) begin
            if (expected_data[(block_idx*weight_value)+compare_idx] >
                expected_data[(block_idx*weight_value)+compare_idx+1]) begin
              swap_value = expected_data[(block_idx*weight_value)+compare_idx];
              expected_data[(block_idx*weight_value)+compare_idx] =
                  expected_data[(block_idx*weight_value)+compare_idx+1];
              expected_data[(block_idx*weight_value)+compare_idx+1] = swap_value;
            end
          end
        end
      end
    end
  endtask

  task automatic run_case(input integer r_value, input integer weight_value, input  logic [7:0] seed,
                          output integer latency);
    integer start_cycle;
    integer expected_latency;
    begin
      prepare_case(r_value, weight_value, seed);
      runtime_r_bits = 32'(r_value);
      runtime_weight = 32'(weight_value);
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      runtime_r_bits = MAX_R;
      runtime_weight = MAX_WEIGHT;
      if (!busy) $fatal(1, "runtime sorter did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      expected_latency = 1 + (BLOCKS * ((2 * weight_value) +
                                       ((weight_value * (weight_value - 1)) / 2)));
      if (latency != expected_latency) $fatal(1, "runtime sorter fixed latency mismatch");
      if ((send_count != active_total) || (receive_count != active_total))
        $fatal(1, "runtime sorter transfer count mismatch");
      $display("runtime sorter r=%0d w=%0d seed=%0h cycles=%0d", r_value, weight_value, seed,
               latency);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    runtime_r_bits = MAX_R;
    runtime_weight = MAX_WEIGHT;
    active_weight = MAX_WEIGHT;
    active_total = MAX_TOTAL;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(7, 1, 8'h11, latency_a);
    run_case(7, 1, 8'he2, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime sorter w1 data-dependent latency");
    run_case(13, 3, 8'h2d, latency_a);
    run_case(13, 3, 8'hc4, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime sorter w3 data-dependent latency");
    run_case(23, 5, 8'h39, latency_a);
    run_case(23, 5, 8'ha6, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime sorter w5 data-dependent latency");

    $display("tb_trike_fixed_support_sorter_runtime PASS");
    $finish;
  end

  initial begin
    repeat (2000) @(posedge clk);
    $fatal(1, "tb_trike_fixed_support_sorter_runtime timeout");
  end

endmodule
