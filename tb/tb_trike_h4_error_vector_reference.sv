`timescale 1ns / 1ps

module tb_trike_h4_error_vector_reference;

  /* verilator lint_off UNUSEDPARAM */
  `include "generated/trike_encaps_reference_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  localparam int REF_ERROR_BYTES = 3 * REF_PADDED_R_BYTES;
  localparam int REF_SUPPORT_ADDR_W = $clog2(REF_ERROR_WEIGHT);
  localparam int REF_ERROR_ADDR_W = $clog2(REF_ERROR_BYTES);
  localparam int REF_BUSY_CYCLES = 207018;

  logic                          clk;
  logic                          rst_n;
  logic                          start;
  logic                          seed_valid;
  logic [                   7:0] seed_data;
  logic                          seed_ready;
  logic                          seed_pass;
  logic                          support_re;
  logic [REF_SUPPORT_ADDR_W-1:0] support_raddr;
  logic [REF_GLOBAL_INDEX_W-1:0] support_rdata;
  logic                          error_re;
  logic [  REF_ERROR_ADDR_W-1:0] error_raddr;
  logic [                   7:0] error_rdata;
  logic                          busy;
  logic                          done;
  int                            busy_cycles;

  /* verilator lint_off PINCONNECTEMPTY */
  trike_h4_error_vector #(
      .M_BYTES       (REF_M_BYTES),
      .R_BITS        (REF_R_BITS),
      .ERROR_WEIGHT  (REF_ERROR_WEIGHT),
      .PADDED_R_BYTES(REF_PADDED_R_BYTES)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_seed_valid    (seed_valid),
      .i_seed_data     (seed_data),
      .o_seed_ready    (seed_ready),
      .o_seed_pass     (seed_pass),
      .i_support_re    (support_re),
      .i_support_raddr (support_raddr),
      .o_support_rdata (support_rdata),
      .i_error_re      (error_re),
      .i_error_raddr   (error_raddr),
      .o_error_rdata   (error_rdata),
      .o_busy          (busy),
      .o_done          (done),
      .o_v             (),
      .o_c             (),
      .o_reseed_counter(),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always #5 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy_cycles <= 0;
    end else if (busy) begin
      busy_cycles <= busy_cycles + 1;
    end
  end

  initial begin
    int seed_idx;
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    seed_valid = 1'b0;
    seed_data = '0;
    support_re = 1'b0;
    support_raddr = '0;
    error_re = 1'b0;
    error_raddr = '0;

    repeat (3) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;
    seed_valid = 1'b1;
    for (int pass = 0; pass < 2; pass++) begin
      seed_idx = 0;
      while (seed_idx < (REF_M_BYTES + REF_R_BYTES)) begin
        if (seed_idx < REF_M_BYTES) begin
          seed_data = REF_MESSAGE[seed_idx];
        end else begin
          seed_data = REF_R2[seed_idx-REF_M_BYTES];
        end
        @(posedge clk);
        if (seed_valid && seed_ready) begin
          if (seed_pass != pass[0]) $fatal(1, "H4 vector seed pass mismatch");
          @(negedge clk);
          seed_idx++;
        end
      end
    end
    seed_valid = 1'b0;
    wait (done);

    for (int address = 0; address < REF_ERROR_WEIGHT; address++) begin
      @(negedge clk);
      support_re = 1'b1;
      support_raddr = REF_SUPPORT_ADDR_W'(address);
      @(posedge clk);
      @(negedge clk);
      support_re = 1'b0;
      if (support_rdata != REF_ERROR_INDICES[address]) begin
        $fatal(1, "H4 vector support mismatch address=%0d", address);
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
        $fatal(1, "H4 vector error mismatch address=%0d", address);
      end
    end

    if (busy_cycles != REF_BUSY_CYCLES) $fatal(1, "H4 error-vector cycle mismatch");

    $display("tb_trike_h4_error_vector_reference PASS cycles=%0d", busy_cycles);
    $finish;
  end

  initial begin
    repeat (300000) @(posedge clk);
    $fatal(1, "tb_trike_h4_error_vector_reference timeout");
  end

endmodule
