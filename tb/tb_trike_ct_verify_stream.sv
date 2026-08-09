`timescale 1ns / 1ps

module tb_trike_ct_verify_stream;
  localparam int WORD_W = 13;
  localparam int WORD_COUNT = 7;
  localparam int DATA_W = 19;

  logic              clk;
  logic              rst_n;
  logic              start;
  logic              decoder_ok;
  logic [WORD_W-1:0] reference_data;
  logic              reference_valid;
  logic              reference_ready;
  logic [WORD_W-1:0] candidate_data;
  logic              candidate_valid;
  logic              candidate_ready;
  logic [DATA_W-1:0] match_data;
  logic [DATA_W-1:0] mismatch_data;
  logic              equal;
  logic [DATA_W-1:0] selected_data;
  logic              busy;
  logic              done;

  logic [WORD_W-1:0] reference_words[0:WORD_COUNT-1];
  logic [WORD_W-1:0] candidate_words[0:WORD_COUNT-1];

  trike_ct_verify_stream #(
      .WORD_W    (WORD_W),
      .WORD_COUNT(WORD_COUNT),
      .DATA_W    (DATA_W)
  ) dut (
      .i_clk            (clk),
      .i_rst_n          (rst_n),
      .i_start          (start),
      .i_decoder_ok     (decoder_ok),
      .i_reference_data (reference_data),
      .i_reference_valid(reference_valid),
      .o_reference_ready(reference_ready),
      .i_candidate_data (candidate_data),
      .i_candidate_valid(candidate_valid),
      .o_candidate_ready(candidate_ready),
      .i_match_data     (match_data),
      .i_mismatch_data  (mismatch_data),
      .o_equal          (equal),
      .o_selected_data  (selected_data),
      .o_busy           (busy),
      .o_done           (done)
  );

  always #1 clk = ~clk;

  task automatic run_case(input int mismatch_word, input  logic decoder_pass, input int stall_word,
                          output int busy_cycles);
    int   word_idx;
    int   accepted_words;
    logic transfer;
    logic cycle_busy;
    begin
      for (int idx = 0; idx < WORD_COUNT; idx++) begin
        reference_words[idx] = WORD_W'((idx * 37) + 11);
        candidate_words[idx] = reference_words[idx];
      end
      if (mismatch_word >= 0)
        candidate_words[mismatch_word] ^= WORD_W'(1 << (mismatch_word % WORD_W));

      @(negedge clk);
      decoder_ok = decoder_pass;
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;

      word_idx = 0;
      accepted_words = 0;
      busy_cycles = 0;
      reference_valid = 1'b1;
      candidate_valid = (stall_word != 0);
      reference_data = reference_words[0];
      candidate_data = candidate_words[0];
      #0.1;

      while (!done) begin
        cycle_busy = busy;
        transfer   = reference_valid && reference_ready && candidate_valid && candidate_ready;

        @(posedge clk);
        #0.1;
        if (cycle_busy) busy_cycles++;
        if (!transfer && (word_idx == stall_word)) candidate_valid = 1'b1;
        if (transfer) begin
          word_idx++;
          accepted_words++;
          if (word_idx < WORD_COUNT) begin
            reference_data = reference_words[word_idx];
            candidate_data = candidate_words[word_idx];
          end else begin
            reference_valid = 1'b0;
            candidate_valid = 1'b0;
          end
        end
        if (!done) @(negedge clk);
      end

      if (accepted_words != WORD_COUNT)
        $fatal(1, "accepted word count mismatch got=%0d", accepted_words);
      if (equal != ((mismatch_word < 0) && decoder_pass)) $fatal(1, "equal mismatch");
      if (selected_data != (((mismatch_word < 0) && decoder_pass) ? match_data : mismatch_data)) begin
        $fatal(1, "selected data mismatch");
      end

      reference_valid = 1'b0;
      candidate_valid = 1'b0;
      @(negedge clk);
    end
  endtask

  initial begin
    int busy_cycles;
    int baseline_cycles;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    decoder_ok = 1'b0;
    reference_data = '0;
    reference_valid = 1'b0;
    candidate_data = '0;
    candidate_valid = 1'b0;
    match_data = DATA_W'(19'h52a5a);
    mismatch_data = DATA_W'(19'h13579);

    repeat (3) @(negedge clk);
    rst_n = 1'b1;

    run_case(-1, 1'b1, -1, baseline_cycles);
    if (baseline_cycles != WORD_COUNT) $fatal(1, "continuous busy cycle mismatch");
    run_case(0, 1'b1, -1, busy_cycles);
    if (busy_cycles != baseline_cycles) $fatal(1, "first-word mismatch changed schedule");
    run_case(WORD_COUNT / 2, 1'b1, -1, busy_cycles);
    if (busy_cycles != baseline_cycles) $fatal(1, "middle-word mismatch changed schedule");
    run_case(WORD_COUNT - 1, 1'b1, -1, busy_cycles);
    if (busy_cycles != baseline_cycles) $fatal(1, "last-word mismatch changed schedule");
    run_case(-1, 1'b0, -1, busy_cycles);
    if (busy_cycles != baseline_cycles) $fatal(1, "decoder status changed schedule");
    run_case(-1, 1'b1, 0, busy_cycles);
    if (busy_cycles != baseline_cycles + 1) $fatal(1, "input stall accounting mismatch");

    $display("tb_trike_ct_verify_stream PASS");
    $finish;
  end

endmodule
