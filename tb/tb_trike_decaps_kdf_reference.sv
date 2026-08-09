`timescale 1ns / 1ps

module tb_trike_decaps_kdf_reference;
  `include "generated/trike_decaps_message_minsum_case.svh"

  localparam int CT_ADDR_W = $clog2(REF_CIPHERTEXT_BYTES);
  localparam int SS_IDX_W  = $clog2(REF_M_BYTES);

  logic                   clk;
  logic                   rst_n;
  logic                   start;
  logic   [        255:0] selected_message;
  logic                   ciphertext_re;
  logic   [CT_ADDR_W-1:0] ciphertext_raddr;
  logic   [          7:0] ciphertext_rdata;
  logic                   shared_secret_valid;
  logic   [ SS_IDX_W-1:0] shared_secret_index;
  logic   [          7:0] shared_secret_data;
  logic                   shared_secret_last;
  logic                   shared_secret_ready;
  logic                   busy;
  logic                   done;
  logic                   expect_reject;
  integer                 shared_secret_count;
  integer                 cycle_count;

  /* verilator lint_off PINCONNECTEMPTY */
  trike_decaps_kdf #(
      .M_BYTES         (REF_M_BYTES),
      .CIPHERTEXT_BYTES(REF_CIPHERTEXT_BYTES)
  ) dut (
      .i_clk                (clk),
      .i_rst_n              (rst_n),
      .i_start              (start),
      .i_selected_message   (selected_message),
      .o_ciphertext_re      (ciphertext_re),
      .o_ciphertext_raddr   (ciphertext_raddr),
      .i_ciphertext_rdata   (ciphertext_rdata),
      .o_shared_secret_valid(shared_secret_valid),
      .o_shared_secret_index(shared_secret_index),
      .o_shared_secret_data (shared_secret_data),
      .o_shared_secret_last (shared_secret_last),
      .i_shared_secret_ready(shared_secret_ready),
      .o_busy               (busy),
      .o_done               (done),
      .o_k_digest           (),
      .o_compress_start     (),
      .o_compress_block     (),
      .o_compress_state     (),
      .i_compress_busy      (1'b0),
      .i_compress_done      (1'b0),
      .i_compress_state     ('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always #1 clk = ~clk;

  assign shared_secret_ready = 1'b1;

  always_ff @(posedge clk) begin
    if (ciphertext_re) ciphertext_rdata <= REF_CIPHERTEXT[8*ciphertext_raddr+:8];
    if (!rst_n) begin
      shared_secret_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (start) begin
        shared_secret_count <= 0;
      end else if (shared_secret_valid && shared_secret_ready) begin
        if (shared_secret_index != SS_IDX_W'(shared_secret_count))
          $fatal(1, "shared-secret index mismatch");
        if (shared_secret_last != (shared_secret_count == (REF_M_BYTES - 1)))
          $fatal(1, "shared-secret last mismatch");
        if (shared_secret_data !=
            (expect_reject ? REF_REJECT_SHARED_SECRET[8*shared_secret_count+:8] :
                             REF_SHARED_SECRET[8*shared_secret_count+:8]))
          $fatal(1, "shared-secret byte mismatch at %0d", shared_secret_count);
        shared_secret_count <= shared_secret_count + 1;
      end
    end
  end

  task automatic run_case(input  logic reject, output integer latency);
    integer start_cycle;
    begin
      expect_reject = reject;
      selected_message = reject ? REF_SIGMA2 : REF_MESSAGE;
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "decapsulation KDF did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (shared_secret_count != REF_M_BYTES) $fatal(1, "shared-secret count mismatch");
    end
  endtask

  initial begin
    integer valid_latency;
    integer reject_latency;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    selected_message = '0;
    expect_reject = 1'b0;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    run_case(1'b0, valid_latency);
    run_case(1'b1, reject_latency);
    if (valid_latency != reject_latency) $fatal(1, "selected-message-dependent KDF latency");

    $display("tb_trike_decaps_kdf_reference PASS cycles=%0d", valid_latency);
    $finish;
  end

  initial begin
    repeat (1000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_kdf_reference timeout");
  end

endmodule
