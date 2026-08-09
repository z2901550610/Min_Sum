`timescale 1ns / 1ps

module tb_trike_decoder_load_adapter;
  localparam int R_BITS  = 13;
  localparam int BLOCKS  = 3;
  localparam int WEIGHT  = 3;
  localparam int WORD_W  = 8;
  localparam int WORDS   = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int ROW_W   = $clog2(R_BITS);
  localparam int BLOCK_W = $clog2(BLOCKS);
  localparam int DIAG_W  = $clog2(WEIGHT);

  logic                 clk;
  logic                 rst_n;
  logic                 start;
  logic                 h_valid;
  logic   [  ROW_W-1:0] h_index;
  logic                 h_ready;
  logic                 h_we;
  logic   [BLOCK_W-1:0] h_block_idx;
  logic   [ DIAG_W-1:0] h_diag_idx_local;
  logic   [  ROW_W-1:0] h_base_row_idx;
  logic                 h_loaded;
  logic                 h_error;
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

  logic   [  ROW_W-1:0] support[0:BLOCKS*WEIGHT-1];
  logic   [  ROW_W-1:0] sorted_support[0:BLOCKS*WEIGHT-1];
  logic   [ WORD_W-1:0] syndrome_words[        0:WORDS-1];
  integer               support_count;
  integer               syndrome_word_count;
  integer               h_write_count;
  integer               syndrome_write_count;
  integer               decoder_wait_count;

  trike_decoder_load_adapter #(
      .R_BITS(R_BITS),
      .BLOCKS(BLOCKS),
      .WEIGHT(WEIGHT),
      .WORD_W(WORD_W)
  ) dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_h_valid         (h_valid),
      .i_h_index         (h_index),
      .o_h_ready         (h_ready),
      .o_h_we            (h_we),
      .o_h_block_idx     (h_block_idx),
      .o_h_diag_idx_local(h_diag_idx_local),
      .o_h_base_row_idx  (h_base_row_idx),
      .i_h_loaded        (h_loaded),
      .i_h_error         (h_error),
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
    h_valid = (support_count < (BLOCKS * WEIGHT));
    h_index = support[(support_count<(BLOCKS*WEIGHT))?support_count : 0];
    syndrome_valid = (syndrome_word_count < WORDS);
    syndrome_data = syndrome_words[(syndrome_word_count<WORDS)?syndrome_word_count : 0];
    h_loaded = (h_write_count == (BLOCKS * WEIGHT));
    decoder_done = (decoder_wait_count == 5);
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      support_count <= 0;
      syndrome_word_count <= 0;
      h_write_count <= 0;
      syndrome_write_count <= 0;
      decoder_wait_count <= 0;
    end else begin
      if (h_valid && h_ready) support_count <= support_count + 1;
      if (syndrome_valid && syndrome_ready) syndrome_word_count <= syndrome_word_count + 1;
      if (h_we) begin
        if (h_block_idx != BLOCK_W'(h_write_count / WEIGHT)) $fatal(1, "H block mismatch");
        if (h_diag_idx_local != DIAG_W'(h_write_count % WEIGHT)) $fatal(1, "H diag mismatch");
        if (h_base_row_idx != sorted_support[h_write_count]) $fatal(1, "H row mismatch");
        h_write_count <= h_write_count + 1;
      end
      if (syndrome_we) begin
        if (syndrome_addr != ROW_W'(syndrome_write_count)) $fatal(1, "syndrome addr mismatch");
        if (syndrome_wdata != syndrome_words[syndrome_write_count/WORD_W][syndrome_write_count%WORD_W]) begin
          $fatal(1, "syndrome data mismatch");
        end
        syndrome_write_count <= syndrome_write_count + 1;
      end
      if (decoder_start || (decoder_wait_count != 0)) decoder_wait_count <= decoder_wait_count + 1;
    end
  end

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    h_error = 1'b0;
    for (int idx = 0; idx < (BLOCKS * WEIGHT); idx++) support[idx] = ROW_W'((idx * 4) % R_BITS);
    sorted_support[0:8] = '{0, 4, 8, 3, 7, 12, 2, 6, 11};
    syndrome_words[0]   = 8'b10110100;
    syndrome_words[1]   = 8'b00010110;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;
    if (!busy) $fatal(1, "adapter did not become busy");

    while (!done) @(negedge clk);
    if (error) $fatal(1, "unexpected adapter error");
    if (support_count != (BLOCKS * WEIGHT)) $fatal(1, "support count mismatch");
    if (syndrome_word_count != WORDS) $fatal(1, "syndrome word count mismatch");
    if (syndrome_write_count != R_BITS) $fatal(1, "syndrome bit count mismatch");

    $display("tb_trike_decoder_load_adapter PASS");
    $finish;
  end

endmodule
