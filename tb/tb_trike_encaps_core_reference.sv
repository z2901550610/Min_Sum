`timescale 1ns / 1ps

module tb_trike_encaps_core_reference;

  /* verilator lint_off UNUSEDPARAM */
  `include "generated/trike_encaps_reference_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  localparam int REF_INPUT_BYTES = REF_R_BYTES + (2 * REF_M_BYTES);
  localparam int REF_CT_BYTES = (2 * REF_R_BYTES) + REF_M_BYTES;
  localparam int REF_BUSY_CYCLES = 2121759;

  logic       clk;
  logic       rst_n;
  logic       start;
  logic       input_valid;
  logic [7:0] input_data;
  logic       input_ready;
  logic       ciphertext_valid;
  logic [7:0] ciphertext_data;
  logic       ciphertext_last;
  logic       ciphertext_ready;
  logic       shared_secret_valid;
  logic [7:0] shared_secret_data;
  logic       shared_secret_last;
  logic       shared_secret_ready;
  logic       busy;
  logic       done;

  int         busy_cycles;
  int         ciphertext_count;
  int         shared_secret_count;

  trike_encaps_core #(
      .M_BYTES     (REF_M_BYTES),
      .R_BITS      (REF_R_BITS),
      .ERROR_WEIGHT(REF_ERROR_WEIGHT),
      .WORD_W      (64)
  ) dut (
      .i_clk                (clk),
      .i_rst_n              (rst_n),
      .i_start              (start),
      .i_input_valid        (input_valid),
      .i_input_data         (input_data),
      .o_input_ready        (input_ready),
      .o_ciphertext_valid   (ciphertext_valid),
      .o_ciphertext_data    (ciphertext_data),
      .o_ciphertext_last    (ciphertext_last),
      .i_ciphertext_ready   (ciphertext_ready),
      .o_shared_secret_valid(shared_secret_valid),
      .o_shared_secret_data (shared_secret_data),
      .o_shared_secret_last (shared_secret_last),
      .i_shared_secret_ready(shared_secret_ready),
      .o_busy               (busy),
      .o_done               (done)
  );

  always #5 clk = ~clk;

  function automatic logic [7:0] encaps_input_byte(input int byte_idx);
    begin
      if (byte_idx < REF_R_BYTES) begin
        encaps_input_byte = REF_R2[byte_idx];
      end else if (byte_idx < (REF_R_BYTES + REF_M_BYTES)) begin
        encaps_input_byte = REF_SIGMA[byte_idx-REF_R_BYTES];
      end else begin
        encaps_input_byte = REF_MESSAGE[byte_idx-REF_R_BYTES-REF_M_BYTES];
      end
    end
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy_cycles <= 0;
      ciphertext_count <= 0;
      shared_secret_count <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;

      if (ciphertext_valid && ciphertext_ready) begin
        if (ciphertext_data != REF_CIPHERTEXT[ciphertext_count]) begin
          $fatal(1, "ciphertext mismatch byte=%0d got=%02x expected=%02x", ciphertext_count,
                 ciphertext_data, REF_CIPHERTEXT[ciphertext_count]);
        end
        if (ciphertext_last != (ciphertext_count == (REF_CT_BYTES - 1))) begin
          $fatal(1, "ciphertext last mismatch byte=%0d", ciphertext_count);
        end
        ciphertext_count <= ciphertext_count + 1;
      end

      if (shared_secret_valid && shared_secret_ready) begin
        if (shared_secret_data != REF_SS[shared_secret_count]) begin
          $fatal(1, "shared-secret mismatch byte=%0d got=%02x expected=%02x", shared_secret_count,
                 shared_secret_data, REF_SS[shared_secret_count]);
        end
        if (shared_secret_last != (shared_secret_count == (REF_M_BYTES - 1))) begin
          $fatal(1, "shared-secret last mismatch byte=%0d", shared_secret_count);
        end
        shared_secret_count <= shared_secret_count + 1;
      end
    end
  end

  initial begin
    int input_count;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    input_valid = 1'b0;
    input_data = '0;
    ciphertext_ready = 1'b1;
    shared_secret_ready = 1'b1;

    repeat (3) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    input_count = 0;
    input_valid = 1'b1;
    while (input_count < REF_INPUT_BYTES) begin
      input_data = encaps_input_byte(input_count);
      @(posedge clk);
      if (input_valid && input_ready) begin
        @(negedge clk);
        input_count++;
      end
    end
    input_valid = 1'b0;

    wait (done);
    if (ciphertext_count != REF_CT_BYTES) begin
      $fatal(1, "ciphertext transfer count mismatch got=%0d expected=%0d", ciphertext_count,
             REF_CT_BYTES);
    end
    if (shared_secret_count != REF_M_BYTES) begin
      $fatal(1, "shared-secret transfer count mismatch got=%0d expected=%0d", shared_secret_count,
             REF_M_BYTES);
    end
    if (busy_cycles != REF_BUSY_CYCLES) begin
      $fatal(1, "Encaps cycle mismatch got=%0d expected=%0d", busy_cycles, REF_BUSY_CYCLES);
    end

    $display("tb_trike_encaps_core_reference PASS cycles=%0d ct=%0d ss=%0d", busy_cycles,
             ciphertext_count, shared_secret_count);
    $finish;
  end

  initial begin
    repeat (3000000) @(posedge clk);
    $fatal(1, "tb_trike_encaps_core_reference timeout");
  end

endmodule
