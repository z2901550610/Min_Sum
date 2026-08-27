`timescale 1ns / 1ps

module tb_trike_keygen_arith_core #(
    parameter bit USE_EXTERNAL_RESULT_STORE  = 1'b0,
    parameter bit USE_EXTERNAL_SUPPORT_STORE = 1'b0
);

  localparam int R_BITS = 13;
  localparam int SECRET_WEIGHT = 3;
  localparam int WORD_W = 64;
  localparam int POSITION_W = $clog2(SECRET_WEIGHT);
  localparam int INDEX_W = $clog2(R_BITS);
  localparam int EXPECTED_BUSY_CYCLES = 603;

  logic                               clk;
  logic                               rst_n;
  logic                               support_valid;
  logic [                        1:0] support_block;
  logic [             POSITION_W-1:0] support_position;
  logic [                INDEX_W-1:0] support_index;
  logic [3*SECRET_WEIGHT*INDEX_W-1:0] support_store;
  logic                               support_ready;
  logic                               vector_valid;
  logic [                        1:0] vector_select;
  logic [                        0:0] vector_word;
  logic [                 WORD_W-1:0] vector_data;
  logic                               vector_ready;
  logic                               start;
  logic                               result_valid;
  logic                               result_select;
  logic [                        0:0] result_word;
  logic [                 WORD_W-1:0] result_data;
  logic                               result_last;
  logic                               result_ready;
  logic                               busy;
  logic                               done;
  logic                               h123_t1_re;
  logic [                        0:0] h123_t1_raddr;
  /* verilator lint_off UNUSEDSIGNAL */
  logic                               h123_t1_we;
  logic [                        0:0] h123_t1_waddr;
  logic [                 WORD_W-1:0] h123_t1_wdata;
  /* verilator lint_on UNUSEDSIGNAL */
  logic                               h123_t2_re;
  logic [                        0:0] h123_t2_raddr;
  logic                               h123_r1_re;
  logic [                        0:0] h123_r1_raddr;
  logic                               store_t0_we;
  logic [                        0:0] store_t0_waddr;
  logic [                 WORD_W-1:0] store_t0_wdata;
  logic                               store_t0_re;
  logic [                        0:0] store_t0_raddr;
  logic [                 WORD_W-1:0] store_t0_rdata;
  logic                               store_numerator_r2_we;
  logic [                        0:0] store_numerator_r2_waddr;
  logic [                 WORD_W-1:0] store_numerator_r2_wdata;
  logic                               store_numerator_r2_re;
  logic [                        0:0] store_numerator_r2_raddr;
  logic [                 WORD_W-1:0] store_numerator_r2_rdata;

  int                                 supports                 [0:2][0:SECRET_WEIGHT-1];
  int                                 busy_cycles;
  int                                 first_cycles;

  trike_keygen_arith_core #(
      .R_BITS                    (R_BITS),
      .SECRET_WEIGHT             (SECRET_WEIGHT),
      .WORD_W                    (WORD_W),
      .DIGIT_W                   (8),
      .USE_EXTERNAL_SUPPORT_STORE(USE_EXTERNAL_SUPPORT_STORE),
      .USE_EXTERNAL_RESULT_STORE (USE_EXTERNAL_RESULT_STORE)
  ) dut (
      .i_clk                     (clk),
      .i_rst_n                   (rst_n),
      .i_support_valid           (support_valid),
      .i_support_block           (support_block),
      .i_support_position        (support_position),
      .i_support_index           (support_index),
      .i_support_store           (support_store),
      .o_support_ready           (support_ready),
      .i_vector_valid            (vector_valid),
      .i_vector_select           (vector_select),
      .i_vector_word             (vector_word),
      .i_vector_data             (vector_data),
      .o_vector_ready            (vector_ready),
      .i_start                   (start),
      .o_result_valid            (result_valid),
      .o_result_select           (result_select),
      .o_result_word             (result_word),
      .o_result_data             (result_data),
      .o_result_last             (result_last),
      .i_result_ready            (result_ready),
      .o_busy                    (busy),
      .o_done                    (done),
      .o_h123_t1_re              (h123_t1_re),
      .o_h123_t1_raddr           (h123_t1_raddr),
      .i_h123_t1_rdata           ('0),
      .o_h123_t1_we              (h123_t1_we),
      .o_h123_t1_waddr           (h123_t1_waddr),
      .o_h123_t1_wdata           (h123_t1_wdata),
      .o_h123_t2_re              (h123_t2_re),
      .o_h123_t2_raddr           (h123_t2_raddr),
      .i_h123_t2_rdata           ('0),
      .o_h123_r1_re              (h123_r1_re),
      .o_h123_r1_raddr           (h123_r1_raddr),
      .i_h123_r1_rdata           ('0),
      .o_store_t0_we             (store_t0_we),
      .o_store_t0_waddr          (store_t0_waddr),
      .o_store_t0_wdata          (store_t0_wdata),
      .o_store_t0_re             (store_t0_re),
      .o_store_t0_raddr          (store_t0_raddr),
      .i_store_t0_rdata          (store_t0_rdata),
      .o_store_numerator_r2_we   (store_numerator_r2_we),
      .o_store_numerator_r2_waddr(store_numerator_r2_waddr),
      .o_store_numerator_r2_wdata(store_numerator_r2_wdata),
      .o_store_numerator_r2_re   (store_numerator_r2_re),
      .o_store_numerator_r2_raddr(store_numerator_r2_raddr),
      .i_store_numerator_r2_rdata(store_numerator_r2_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (1)
  ) u_store_t0 (
      .i_clk  (clk),
      .i_we   (store_t0_we),
      .i_waddr(store_t0_waddr),
      .i_wdata(store_t0_wdata),
      .i_re   (store_t0_re),
      .i_raddr(store_t0_raddr),
      .o_rdata(store_t0_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (1)
  ) u_store_numerator_r2 (
      .i_clk  (clk),
      .i_we   (store_numerator_r2_we),
      .i_waddr(store_numerator_r2_waddr),
      .i_wdata(store_numerator_r2_wdata),
      .i_re   (store_numerator_r2_re),
      .i_raddr(store_numerator_r2_raddr),
      .o_rdata(store_numerator_r2_rdata)
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

  always_ff @(posedge clk) begin
    if (rst_n) begin
      if (h123_t1_re && (h123_t1_raddr != '0)) $fatal(1, "t1 read out of range");
      if (h123_t2_re && (h123_t2_raddr != '0)) $fatal(1, "t2 read out of range");
      if (h123_r1_re && (h123_r1_raddr != '0)) $fatal(1, "r1 read out of range");
    end
  end

  task automatic load_inputs(input  logic [12:0] t1, input  logic [12:0] t2, input  logic [12:0] r1);
    for (int block = 0; block < 3; block++) begin
      for (int position = 0; position < SECRET_WEIGHT; position++) begin
        @(negedge clk);
        support_valid = 1'b1;
        support_block = 2'(block);
        support_position = POSITION_W'(position);
        support_index = INDEX_W'(supports[block][position]);
        support_store[(block*SECRET_WEIGHT+position)*INDEX_W+:INDEX_W] = support_index;
        if (!support_ready) $fatal(1, "support input was not accepted");
      end
    end
    @(negedge clk);
    support_valid = 1'b0;
    for (int vector_index = 0; vector_index < 3; vector_index++) begin
      vector_valid  = 1'b1;
      vector_select = 2'(vector_index);
      vector_word   = '0;
      unique case (vector_index)
        0: vector_data = WORD_W'(t1);
        1: vector_data = WORD_W'(t2);
        default: vector_data = WORD_W'(r1);
      endcase
      if (!vector_ready) $fatal(1, "vector input was not accepted");
      @(negedge clk);
    end
    vector_valid = 1'b0;
  endtask

  task automatic run_case(input  logic [12:0] t1, input  logic [12:0] t2, input  logic [12:0] r1,
                          input  logic [12:0] expected_t0, input  logic [12:0] expected_r2,
                          input bit first_case);
    int output_count;
    load_inputs(t1, t2, r1);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;
    output_count = 0;
    while (output_count < 2) begin
      @(posedge clk);
      if (result_valid && result_ready) begin
        if (result_word != 0 || !result_last) $fatal(1, "toy output framing mismatch");
        if (!result_select && result_data[12:0] != expected_t0) begin
          $fatal(1, "t0 mismatch got=%h expected=%h", result_data[12:0], expected_t0);
        end
        if (result_select && result_data[12:0] != expected_r2) begin
          $fatal(1, "r2 mismatch got=%h expected=%h", result_data[12:0], expected_r2);
        end
        if (result_data[63:13] != 0) $fatal(1, "toy result padding was not zero");
        output_count++;
      end
    end
    wait (done);
    #1;
    if (first_case) begin
      first_cycles = busy_cycles;
    end else if (busy_cycles != first_cycles) begin
      $fatal(1, "data-dependent cycle count got=%0d expected=%0d", busy_cycles, first_cycles);
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "cycle mismatch got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end
    @(negedge clk);
  endtask

  initial begin
    rst_n = 1'b0;
    support_valid = 1'b0;
    support_block = '0;
    support_position = '0;
    support_index = '0;
    support_store = '0;
    vector_valid = 1'b0;
    vector_select = '0;
    vector_word = '0;
    vector_data = '0;
    start = 1'b0;
    result_ready = 1'b1;
    first_cycles = 0;
    supports = '{'{0, 2, 5}, '{1, 3, 8}, '{0, 4, 7}};

    repeat (4) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
    run_case(13'h0898, 13'h0408, 13'h1053, 13'h0914, 13'h0d87, 1'b1);
    run_case(13'h039f, 13'h05dd, 13'h056e, 13'h0da1, 13'h17b9, 1'b0);
    $display("tb_trike_keygen_arith_core PASS external_result=%0d external_support=%0d cycles=%0d",
             USE_EXTERNAL_RESULT_STORE, USE_EXTERNAL_SUPPORT_STORE, first_cycles);
    $finish;
  end

  initial begin
    repeat (10000) @(posedge clk);
    $fatal(1, "tb_trike_keygen_arith_core timeout");
  end

endmodule
