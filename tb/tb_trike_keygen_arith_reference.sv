`timescale 1ns / 1ps

module tb_trike_keygen_arith_reference;

  `include "generated/trike_keygen_reference_case.svh"

  localparam int WORD_ADDR_W = $clog2(REF_WORDS);
  localparam int POSITION_W = $clog2(REF_SECRET_WEIGHT);
  localparam int EXPECTED_BUSY_CYCLES = 2919579;

  logic                   clk;
  logic                   rst_n;
  logic                   support_valid;
  logic [            1:0] support_block;
  logic [ POSITION_W-1:0] support_position;
  logic [REF_INDEX_W-1:0] support_index;
  logic                   support_ready;
  logic                   vector_valid;
  logic [            1:0] vector_select;
  logic [WORD_ADDR_W-1:0] vector_word;
  logic [           63:0] vector_data;
  logic                   vector_ready;
  logic                   start;
  logic                   result_valid;
  logic                   result_select;
  logic [WORD_ADDR_W-1:0] result_word;
  logic [           63:0] result_data;
  logic                   result_last;
  logic                   busy;
  logic                   done;
  logic                   h123_t1_re;
  logic [WORD_ADDR_W-1:0] h123_t1_raddr;
  /* verilator lint_off UNUSEDSIGNAL */
  logic                   h123_t1_we;
  logic [WORD_ADDR_W-1:0] h123_t1_waddr;
  logic [           63:0] h123_t1_wdata;
  /* verilator lint_on UNUSEDSIGNAL */
  logic                   h123_t2_re;
  logic [WORD_ADDR_W-1:0] h123_t2_raddr;
  logic                   h123_r1_re;
  logic [WORD_ADDR_W-1:0] h123_r1_raddr;

  int                     busy_cycles;
  int                     result_count;

  trike_keygen_arith_core #(
      .R_BITS       (REF_R_BITS),
      .SECRET_WEIGHT(REF_SECRET_WEIGHT),
      .WORD_W       (64)
  ) dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_support_valid   (support_valid),
      .i_support_block   (support_block),
      .i_support_position(support_position),
      .i_support_index   (support_index),
      .i_support_store   ('0),
      .o_support_ready   (support_ready),
      .i_vector_valid    (vector_valid),
      .i_vector_select   (vector_select),
      .i_vector_word     (vector_word),
      .i_vector_data     (vector_data),
      .o_vector_ready    (vector_ready),
      .i_start           (start),
      .o_result_valid    (result_valid),
      .o_result_select   (result_select),
      .o_result_word     (result_word),
      .o_result_data     (result_data),
      .o_result_last     (result_last),
      .i_result_ready    (1'b1),
      .o_busy            (busy),
      .o_done            (done),
      .o_h123_t1_re      (h123_t1_re),
      .o_h123_t1_raddr   (h123_t1_raddr),
      .i_h123_t1_rdata   ('0),
      .o_h123_t1_we      (h123_t1_we),
      .o_h123_t1_waddr   (h123_t1_waddr),
      .o_h123_t1_wdata   (h123_t1_wdata),
      .o_h123_t2_re      (h123_t2_re),
      .o_h123_t2_raddr   (h123_t2_raddr),
      .i_h123_t2_rdata   ('0),
      .o_h123_r1_re      (h123_r1_re),
      .o_h123_r1_raddr   (h123_r1_raddr),
      .i_h123_r1_rdata   ('0)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always_ff @(posedge clk) begin
    if (!rst_n || start) begin
      busy_cycles <= 0;
    end else if (busy) begin
      busy_cycles <= busy_cycles + 1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      result_count <= 0;
    end else if (result_valid) begin
      if (!result_select && result_data != REF_T0_WORDS[result_word]) begin
        $fatal(1, "t0 word %0d mismatch got=%h expected=%h", result_word, result_data,
               REF_T0_WORDS[result_word]);
      end
      if (result_select && result_data != REF_R2_WORDS[result_word]) begin
        $fatal(1, "r2 word %0d mismatch got=%h expected=%h", result_word, result_data,
               REF_R2_WORDS[result_word]);
      end
      if (result_last != (result_word == WORD_ADDR_W'(REF_WORDS - 1))) begin
        $fatal(1, "result last mismatch select=%0d word=%0d", result_select, result_word);
      end
      result_count <= result_count + 1;
    end
  end

  always_ff @(posedge clk) begin
    if (rst_n) begin
      if (h123_t1_re && (int'(h123_t1_raddr) >= REF_WORDS)) $fatal(1, "t1 read out of range");
      if (h123_t2_re && (int'(h123_t2_raddr) >= REF_WORDS)) $fatal(1, "t2 read out of range");
      if (h123_r1_re && (int'(h123_r1_raddr) >= REF_WORDS)) $fatal(1, "r1 read out of range");
    end
  end

  initial begin
    rst_n = 1'b0;
    support_valid = 1'b0;
    support_block = '0;
    support_position = '0;
    support_index = '0;
    vector_valid = 1'b0;
    vector_select = '0;
    vector_word = '0;
    vector_data = '0;
    start = 1'b0;

    repeat (4) @(negedge clk);
    rst_n = 1'b1;

    for (int flat_position = 0; flat_position < 3 * REF_SECRET_WEIGHT; flat_position++) begin
      @(negedge clk);
      support_valid = 1'b1;
      support_block = 2'(flat_position / REF_SECRET_WEIGHT);
      support_position = POSITION_W'(flat_position % REF_SECRET_WEIGHT);
      support_index = REF_SELECTED_SUPPORT[flat_position];
      if (!support_ready) $fatal(1, "reference support was not accepted");
    end
    @(negedge clk);
    support_valid = 1'b0;

    for (int vector_index = 0; vector_index < 3; vector_index++) begin
      for (int word_index = 0; word_index < REF_WORDS; word_index++) begin
        @(negedge clk);
        vector_valid  = 1'b1;
        vector_select = 2'(vector_index);
        vector_word   = WORD_ADDR_W'(word_index);
        unique case (vector_index)
          0: vector_data = REF_T1_WORDS[word_index];
          1: vector_data = REF_T2_WORDS[word_index];
          default: vector_data = REF_R1_WORDS[word_index];
        endcase
        if (!vector_ready) $fatal(1, "reference vector was not accepted");
      end
    end
    @(negedge clk);
    vector_valid = 1'b0;
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    wait (done);
    #1;
    if (result_count != 2 * REF_WORDS) begin
      $fatal(1, "result count mismatch got=%0d expected=%0d", result_count, 2 * REF_WORDS);
    end
    if (busy) $fatal(1, "arithmetic core remained busy after done");
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "cycle mismatch got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end
    $display("tb_trike_keygen_arith_reference PASS cycles=%0d", busy_cycles);
    $finish;
  end

  initial begin
    repeat (120000000) @(posedge clk);
    $fatal(1, "tb_trike_keygen_arith_reference timeout");
  end

endmodule
