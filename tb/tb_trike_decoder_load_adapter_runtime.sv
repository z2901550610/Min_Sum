`timescale 1ns / 1ps

module tb_trike_decoder_load_adapter_runtime;
  localparam int MAX_R = 23;
  localparam int BLOCKS = 3;
  localparam int MAX_WEIGHT = 5;
  localparam int WORD_W = 8;
  localparam int MAX_WORDS = (MAX_R + WORD_W - 1) / WORD_W;
  localparam int ROW_W = $clog2(MAX_R);
  localparam int BLOCK_W = $clog2(BLOCKS);
  localparam int DIAG_W = $clog2(MAX_WEIGHT);
  localparam int MAX_TOTAL = BLOCKS * MAX_WEIGHT;

  logic                 clk;
  logic                 rst_n;
  logic                 start;
  logic   [       31:0] runtime_r_bits;
  logic   [       31:0] runtime_weight;
  logic                 h_valid;
  logic   [  ROW_W-1:0] h_index;
  logic                 h_ready;
  logic                 h_we;
  logic   [BLOCK_W-1:0] h_block_idx;
  logic   [ DIAG_W-1:0] h_diag_idx;
  logic   [  ROW_W-1:0] h_base_row;
  logic                 h_loaded;
  logic                 syndrome_valid;
  logic   [ WORD_W-1:0] syndrome_data;
  logic                 syndrome_ready;
  logic                 syndrome_we;
  logic   [  ROW_W-1:0] syndrome_addr;
  logic                 syndrome_wdata;
  logic                 decoder_start;
  logic                 decoder_done;
  logic                 error;
  logic                 busy;
  logic                 done;

  logic   [  ROW_W-1:0] support[0:MAX_TOTAL-1];
  logic   [  ROW_W-1:0] sorted_support[0:MAX_TOTAL-1];
  logic   [ WORD_W-1:0] syndrome_words[0:MAX_WORDS-1];
  integer               active_r;
  integer               active_weight;
  integer               active_total;
  integer               active_words;
  integer               support_count;
  integer               syndrome_word_count;
  integer               h_write_count;
  integer               syndrome_write_count;
  integer               decoder_wait_count;
  integer               decoder_start_count;
  integer               cycle_count;

  trike_decoder_load_adapter #(
      .R_BITS          (MAX_R),
      .BLOCKS          (BLOCKS),
      .WEIGHT          (MAX_WEIGHT),
      .WORD_W          (WORD_W),
      .RUNTIME_GEOMETRY(1'b1)
  ) dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_runtime_r_bits  (runtime_r_bits),
      .i_runtime_weight  (runtime_weight),
      .i_h_valid         (h_valid),
      .i_h_index         (h_index),
      .o_h_ready         (h_ready),
      .o_h_we            (h_we),
      .o_h_block_idx     (h_block_idx),
      .o_h_diag_idx_local(h_diag_idx),
      .o_h_base_row_idx  (h_base_row),
      .i_h_loaded        (h_loaded),
      .i_h_error         (1'b0),
      .i_syndrome_valid  (syndrome_valid),
      .i_syndrome_data   (syndrome_data),
      .o_syndrome_ready  (syndrome_ready),
      .o_syndrome_we     (syndrome_we),
      .o_syndrome_addr   (syndrome_addr),
      .o_syndrome_wdata  (syndrome_wdata),
      .o_decoder_start   (decoder_start),
      .i_decoder_done    (decoder_done),
      .o_error           (error),
      .o_busy            (busy),
      .o_done            (done)
  );

  always #1 clk = ~clk;

  always_comb begin
    h_valid = support_count < active_total;
    h_index = support[(support_count<active_total)?support_count : 0];
    h_loaded = h_write_count == active_total;
    syndrome_valid = syndrome_word_count < active_words;
    syndrome_data = syndrome_words[(syndrome_word_count<active_words)?syndrome_word_count : 0];
    decoder_done = decoder_wait_count == 4;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      support_count <= 0;
      syndrome_word_count <= 0;
      h_write_count <= 0;
      syndrome_write_count <= 0;
      decoder_wait_count <= 0;
      decoder_start_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        support_count <= 0;
        syndrome_word_count <= 0;
        h_write_count <= 0;
        syndrome_write_count <= 0;
        decoder_wait_count <= 0;
        decoder_start_count <= 0;
      end else begin
        if (h_valid && h_ready) support_count <= support_count + 1;
        if (syndrome_valid && syndrome_ready) syndrome_word_count <= syndrome_word_count + 1;
        if (h_we) begin
          if (h_block_idx != BLOCK_W'(h_write_count / active_weight))
            $fatal(1, "runtime adapter H block mismatch");
          if (h_diag_idx != DIAG_W'(h_write_count % active_weight))
            $fatal(1, "runtime adapter H diagonal mismatch");
          if (h_base_row != sorted_support[h_write_count])
            $fatal(1, "runtime adapter H row mismatch");
          h_write_count <= h_write_count + 1;
        end
        if (syndrome_we) begin
          if (syndrome_addr != ROW_W'(syndrome_write_count))
            $fatal(1, "runtime adapter syndrome address mismatch");
          if (syndrome_wdata !=
              syndrome_words[syndrome_write_count/WORD_W][syndrome_write_count%WORD_W])
            $fatal(1, "runtime adapter syndrome data mismatch");
          syndrome_write_count <= syndrome_write_count + 1;
        end
        if (decoder_start) decoder_start_count <= decoder_start_count + 1;
        if (decoder_start || (decoder_wait_count != 0))
          decoder_wait_count <= decoder_wait_count + 1;
      end
    end
  end

  task automatic prepare_case(input integer r_value, input integer weight_value,
                              input  logic [7:0] seed);
    logic [ROW_W-1:0] swap_value;
    begin
      active_r = r_value;
      active_weight = weight_value;
      active_total = BLOCKS * weight_value;
      active_words = (r_value + WORD_W - 1) / WORD_W;
      for (int idx = 0; idx < MAX_TOTAL; idx++) begin
        support[idx] = '0;
        sorted_support[idx] = '0;
      end
      for (int idx = 0; idx < MAX_WORDS; idx++) syndrome_words[idx] = 8'((idx * 37) ^ int'(seed));
      for (int block_idx = 0; block_idx < BLOCKS; block_idx++) begin
        for (int diag_idx = 0; diag_idx < weight_value; diag_idx++) begin
          support[(block_idx*weight_value)+diag_idx] =
              ROW_W'(((diag_idx * 7) + (block_idx * 5) + int'(seed)) % r_value);
          sorted_support[(block_idx*weight_value)+diag_idx] =
              support[(block_idx*weight_value)+diag_idx];
        end
        for (int pass_idx = 0; pass_idx < weight_value; pass_idx++) begin
          for (int compare_idx = 0; compare_idx < (weight_value - 1); compare_idx++) begin
            if (sorted_support[(block_idx*weight_value)+compare_idx] >
                sorted_support[(block_idx*weight_value)+compare_idx+1]) begin
              swap_value = sorted_support[(block_idx*weight_value)+compare_idx];
              sorted_support[(block_idx*weight_value)+compare_idx] =
                  sorted_support[(block_idx*weight_value)+compare_idx+1];
              sorted_support[(block_idx*weight_value)+compare_idx+1] = swap_value;
            end
          end
        end
      end
    end
  endtask

  task automatic run_case(input integer r_value, input integer weight_value, input  logic [7:0] seed,
                          output integer latency);
    integer start_cycle;
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
      if (!busy) $fatal(1, "runtime adapter did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (error) $fatal(1, "runtime adapter unexpected error");
      if ((support_count != active_total) || (h_write_count != active_total))
        $fatal(1, "runtime adapter support count mismatch");
      if ((syndrome_word_count != active_words) || (syndrome_write_count != active_r))
        $fatal(1, "runtime adapter syndrome count mismatch");
      if (decoder_start_count != 1) $fatal(1, "runtime adapter decoder start count mismatch");
      $display("runtime adapter r=%0d w=%0d seed=%0h cycles=%0d", r_value, weight_value, seed,
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
    active_r = MAX_R;
    active_weight = MAX_WEIGHT;
    active_total = MAX_TOTAL;
    active_words = MAX_WORDS;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(7, 1, 8'h11, latency_a);
    run_case(7, 1, 8'he2, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime adapter r7 data-dependent latency");
    run_case(13, 3, 8'h2d, latency_a);
    run_case(13, 3, 8'hc4, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime adapter r13 data-dependent latency");
    run_case(23, 5, 8'h39, latency_a);
    run_case(23, 5, 8'ha6, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime adapter r23 data-dependent latency");

    $display("tb_trike_decoder_load_adapter_runtime PASS");
    $finish;
  end

  initial begin
    repeat (5000) @(posedge clk);
    $fatal(1, "tb_trike_decoder_load_adapter_runtime timeout");
  end

endmodule
