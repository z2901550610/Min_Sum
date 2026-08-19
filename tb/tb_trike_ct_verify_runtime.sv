`timescale 1ns / 1ps

module tb_trike_ct_verify_runtime;
  localparam int MAX_WORD_COUNT = 8;

  logic          clk;
  logic          rst_n;
  logic          start;
  logic   [31:0] runtime_word_count;
  logic          decoder_ok;
  logic   [ 7:0] reference_data;
  logic          reference_valid;
  logic          reference_ready;
  logic   [ 7:0] candidate_data;
  logic          candidate_valid;
  logic          candidate_ready;
  logic          equal;
  logic   [ 7:0] selected_data;
  logic          busy;
  logic          done;
  integer        word_idx;
  integer        mismatch_idx;
  integer        busy_cycles;

  assign reference_data = 8'((5 * word_idx) + 1);
  assign candidate_data = reference_data ^ ((word_idx == mismatch_idx) ? 8'h80 : 8'h00);

  trike_ct_verify_stream #(
      .WORD_W       (8),
      .WORD_COUNT   (MAX_WORD_COUNT),
      .DATA_W       (8),
      .RUNTIME_COUNT(1'b1)
  ) dut (
      .i_clk               (clk),
      .i_rst_n             (rst_n),
      .i_start             (start),
      .i_runtime_word_count(runtime_word_count),
      .i_decoder_ok        (decoder_ok),
      .i_reference_data    (reference_data),
      .i_reference_valid   (reference_valid),
      .o_reference_ready   (reference_ready),
      .i_candidate_data    (candidate_data),
      .i_candidate_valid   (candidate_valid),
      .o_candidate_ready   (candidate_ready),
      .i_match_data        (8'h5a),
      .i_mismatch_data     (8'ha5),
      .o_equal             (equal),
      .o_selected_data     (selected_data),
      .o_busy              (busy),
      .o_done              (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) busy_cycles <= 0;
    else if (start) busy_cycles <= 0;
    else if (busy) busy_cycles <= busy_cycles + 1;
  end

  task automatic run_case(input integer word_count, input integer mismatch_position,
                          input  logic decoder_accept, output integer latency);
    logic expect_equal;
    begin
      word_idx = 0;
      mismatch_idx = mismatch_position;
      decoder_ok = decoder_accept;
      runtime_word_count = 32'(word_count);
      reference_valid = 1'b1;
      candidate_valid = 1'b1;
      @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      runtime_word_count = MAX_WORD_COUNT;
      while (!done) begin
        @(posedge clk);
        if (reference_ready && candidate_ready) begin
          @(negedge clk);
          word_idx++;
        end
      end
      reference_valid = 1'b0;
      candidate_valid = 1'b0;
      latency = busy_cycles;
      expect_equal = decoder_accept &&
                     ((mismatch_position < 0) || (mismatch_position >= word_count));
      if (word_idx != word_count) $fatal(1, "runtime compare word count mismatch");
      if (equal != expect_equal) $fatal(1, "runtime compare equality mismatch");
      if (selected_data != (expect_equal ? 8'h5a : 8'ha5))
        $fatal(1, "runtime compare selection mismatch");
      $display("runtime compare words=%0d mismatch=%0d decoder_ok=%0d cycles=%0d", word_count,
               mismatch_position, decoder_accept, latency);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    runtime_word_count = '0;
    decoder_ok = 1'b0;
    reference_valid = 1'b0;
    candidate_valid = 1'b0;
    word_idx = 0;
    mismatch_idx = -1;
    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(1, -1, 1'b1, latency_a);
    run_case(1, 0, 1'b1, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime compare words=1 data-dependent latency");
    run_case(3, -1, 1'b0, latency_a);
    run_case(3, 2, 1'b1, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime compare words=3 data-dependent latency");
    run_case(8, 8, 1'b1, latency_a);
    run_case(8, 0, 1'b1, latency_b);
    if (latency_a != latency_b) $fatal(1, "runtime compare words=8 data-dependent latency");

    $display("tb_trike_ct_verify_runtime PASS");
    $finish;
  end

endmodule
