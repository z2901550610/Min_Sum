`timescale 1ns / 1ps

module tb_trike_error_support_store_reference;

  /* verilator lint_off UNUSEDPARAM */
  `include "generated/trike_encaps_reference_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  localparam int REF_ERROR_BYTES = 3 * REF_PADDED_R_BYTES;
  localparam int REF_SUPPORT_ADDR_W = $clog2(REF_ERROR_WEIGHT);
  localparam int REF_ERROR_ADDR_W = $clog2(REF_ERROR_BYTES);
  localparam int REF_STORE_BUSY_CYCLES = 6478;

  logic                          clk;
  logic                          rst_n;
  logic                          start;
  logic                          index_valid;
  logic [REF_SUPPORT_ADDR_W-1:0] index_position;
  logic [REF_GLOBAL_INDEX_W-1:0] index_value;
  logic                          index_ready;
  logic                          support_re;
  logic [REF_SUPPORT_ADDR_W-1:0] support_raddr;
  logic [REF_GLOBAL_INDEX_W-1:0] support_rdata;
  logic                          error_re;
  logic [  REF_ERROR_ADDR_W-1:0] error_raddr;
  logic [                   7:0] error_rdata;
  logic                          busy;
  logic                          done;

  int                            busy_cycles;

  trike_error_support_store #(
      .R_BITS        (REF_R_BITS),
      .ERROR_WEIGHT  (REF_ERROR_WEIGHT),
      .PADDED_R_BYTES(REF_PADDED_R_BYTES)
  ) dut (
      .i_clk                   (clk),
      .i_rst_n                 (rst_n),
      .i_start                 (start),
      .i_runtime_r_bits        ('0),
      .i_runtime_error_weight  ('0),
      .i_runtime_padded_r_bytes('0),
      .i_index_valid           (index_valid),
      .i_index_position        (index_position),
      .i_index                 (index_value),
      .o_index_ready           (index_ready),
      .i_support_re            (support_re),
      .i_support_raddr         (support_raddr),
      .o_support_rdata         (support_rdata),
      .i_error_re              (error_re),
      .i_error_raddr           (error_raddr),
      .o_error_rdata           (error_rdata),
      .o_busy                  (busy),
      .o_done                  (done)
  );

  always #5 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy_cycles <= 0;
    end else if (busy) begin
      busy_cycles <= busy_cycles + 1;
    end
  end

  initial begin
    int transfer_count;
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    index_valid = 1'b0;
    index_position = '0;
    index_value = '0;
    support_re = 1'b0;
    support_raddr = '0;
    error_re = 1'b0;
    error_raddr = '0;

    repeat (3) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    start = 1'b1;
    index_valid = 1'b1;
    transfer_count = 0;
    index_position = REF_SUPPORT_ADDR_W'(REF_ERROR_WEIGHT - 1);
    index_value = REF_ERROR_INDICES[REF_ERROR_WEIGHT-1];
    @(negedge clk);
    start = 1'b0;

    while (!done) begin
      @(posedge clk);
      if (index_valid && index_ready) transfer_count++;
      @(negedge clk);
      if (transfer_count == REF_ERROR_WEIGHT) begin
        index_valid = 1'b0;
      end else begin
        index_position = REF_SUPPORT_ADDR_W'(REF_ERROR_WEIGHT - 1 - transfer_count);
        index_value = REF_ERROR_INDICES[REF_ERROR_WEIGHT-1-transfer_count];
      end
    end
    if (transfer_count != REF_ERROR_WEIGHT) $fatal(1, "support transfer count mismatch");

    for (int address = 0; address < REF_ERROR_WEIGHT; address++) begin
      @(negedge clk);
      support_re = 1'b1;
      support_raddr = REF_SUPPORT_ADDR_W'(address);
      @(posedge clk);
      @(negedge clk);
      support_re = 1'b0;
      if (support_rdata != REF_ERROR_INDICES[address]) begin
        $fatal(1, "support RAM mismatch address=%0d", address);
      end
    end

    for (int address = 0; address < REF_ERROR_BYTES; address++) begin
      @(negedge clk);
      error_re = 1'b1;
      error_raddr = REF_ERROR_ADDR_W'(address);
      @(posedge clk);
      @(negedge clk);
      error_re = 1'b0;
      if (error_rdata != REF_ERROR_PADDED[address]) begin
        $fatal(1, "error RAM mismatch address=%0d got=%02x expected=%02x", address, error_rdata,
               REF_ERROR_PADDED[address]);
      end
    end

    if (busy_cycles != REF_STORE_BUSY_CYCLES) $fatal(1, "error-store cycle mismatch");

    $display("tb_trike_error_support_store_reference PASS cycles=%0d", busy_cycles);
    $finish;
  end

  initial begin
    repeat (100000) @(posedge clk);
    $fatal(1, "tb_trike_error_support_store_reference timeout");
  end

endmodule
