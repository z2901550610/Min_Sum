`timescale 1ns / 1ps

module tb_trike_h123_vector_store;

  localparam int R_BITS = 21;
  localparam int WORD_W = 16;
  localparam int R_BYTES = (R_BITS + 7) / 8;
  localparam int WORD_ADDR_W = $clog2((R_BITS + WORD_W - 1) / WORD_W);

  logic                   clk;
  logic                   rst_n;
  logic                   vector_valid;
  logic [            1:0] vector_select;
  logic [            1:0] vector_byte;
  logic [            7:0] vector_data;
  logic                   vector_ready;
  logic                   t1_re;
  logic [WORD_ADDR_W-1:0] t1_raddr;
  logic [     WORD_W-1:0] t1_rdata;
  logic                   t1_we;
  logic [WORD_ADDR_W-1:0] t1_waddr;
  logic [     WORD_W-1:0] t1_wdata;
  logic                   t2_re;
  logic [WORD_ADDR_W-1:0] t2_raddr;
  logic [     WORD_W-1:0] t2_rdata;
  logic                   r1_re;
  logic [WORD_ADDR_W-1:0] r1_raddr;
  logic [     WORD_W-1:0] r1_rdata;

  trike_h123_vector_store #(
      .R_BITS(R_BITS),
      .WORD_W(WORD_W)
  ) dut (
      .i_clk          (clk),
      .i_rst_n        (rst_n),
      .i_vector_valid (vector_valid),
      .i_vector_select(vector_select),
      .i_vector_byte  (vector_byte),
      .i_vector_data  (vector_data),
      .o_vector_ready (vector_ready),
      .i_t1_re        (t1_re),
      .i_t1_raddr     (t1_raddr),
      .o_t1_rdata     (t1_rdata),
      .i_t1_we        (t1_we),
      .i_t1_waddr     (t1_waddr),
      .i_t1_wdata     (t1_wdata),
      .i_t2_re        (t2_re),
      .i_t2_raddr     (t2_raddr),
      .o_t2_rdata     (t2_rdata),
      .i_r1_re        (r1_re),
      .i_r1_raddr     (r1_raddr),
      .o_r1_rdata     (r1_rdata)
  );

  always #5 clk = ~clk;

  task automatic write_vectors(input  logic [7:0] base);
    for (int bank = 0; bank < 3; bank++) begin
      for (int byte_index = 0; byte_index < R_BYTES; byte_index++) begin
        @(negedge clk);
        vector_valid  = 1'b1;
        vector_select = 2'(bank);
        vector_byte   = 2'(byte_index);
        vector_data   = base + 8'(16 * bank) + 8'(byte_index);
        if (!vector_ready) $fatal(1, "H123 vector store backpressured a fixed stream");
      end
    end
    @(negedge clk);
    vector_valid = 1'b0;
  endtask

  task automatic overwrite_t1_scratch;
    @(negedge clk);
    t1_we = 1'b1;
    t1_waddr = 1;
    t1_wdata = 16'hcafe;
    @(negedge clk);
    t1_we = 1'b0;
    t1_re = 1'b1;
    t1_raddr = 1;
    @(posedge clk);
    #1;
    if (t1_rdata != 16'hcafe) $fatal(1, "t1 scratch overwrite mismatch");
    @(negedge clk);
    t1_re = 1'b0;
  endtask

  task automatic check_words(input  logic [7:0] base);
    @(negedge clk);
    t1_re = 1'b1;
    t1_raddr = 0;
    t2_re = 1'b1;
    t2_raddr = 1;
    r1_re = 1'b1;
    r1_raddr = 0;
    @(posedge clk);
    #1;
    if (t1_rdata != {base + 8'd1, base}) $fatal(1, "t1 word 0 mismatch");
    if (t2_rdata != {8'h00, base + 8'd18}) $fatal(1, "t2 word 1 mismatch");
    if (r1_rdata != {base + 8'd33, base + 8'd32}) $fatal(1, "r1 word 0 mismatch");

    @(negedge clk);
    t1_raddr = 1;
    t2_raddr = 0;
    r1_raddr = 1;
    @(posedge clk);
    #1;
    if (t1_rdata != {8'h00, base + 8'd2}) $fatal(1, "t1 word 1 mismatch");
    if (t2_rdata != {base + 8'd17, base + 8'd16}) $fatal(1, "t2 word 0 mismatch");
    if (r1_rdata != {8'h00, base + 8'd34}) $fatal(1, "r1 word 1 mismatch");

    @(negedge clk);
    t1_re = 1'b0;
    t2_re = 1'b0;
    r1_re = 1'b0;
  endtask

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    vector_valid = 1'b0;
    vector_select = '0;
    vector_byte = '0;
    vector_data = '0;
    t1_re = 1'b0;
    t1_raddr = '0;
    t1_we = 1'b0;
    t1_waddr = '0;
    t1_wdata = '0;
    t2_re = 1'b0;
    t2_raddr = '0;
    r1_re = 1'b0;
    r1_raddr = '0;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    write_vectors(8'h10);
    check_words(8'h10);
    overwrite_t1_scratch();
    write_vectors(8'h80);
    check_words(8'h80);

    $display("tb_trike_h123_vector_store PASS");
    $finish;
  end

  initial begin
    repeat (200) @(posedge clk);
    $fatal(1, "tb_trike_h123_vector_store timeout");
  end

endmodule
