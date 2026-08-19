`timescale 1ns / 1ps

module tb_trike_keygen_core_reference #(
    parameter bit ALT_CASE      = 1'b0,
    parameter bit USE_SYNTH_TOP = 1'b0
);

  `include "generated/trike_keygen_reference_case.svh"

  localparam int EXPECTED_BUSY_CYCLES = 53995036;
  localparam int EXPECTED_SYNTH_BUSY_CYCLES = 54002607;

  logic       clk;
  logic       rst_n;
  logic       start;
  logic       random_valid;
  logic [7:0] random_data;
  logic       random_ready;
  logic       pk_valid;
  logic [7:0] pk_data;
  logic       pk_last;
  logic       pk_ready;
  logic       sk_valid;
  logic [7:0] sk_data;
  logic       sk_last;
  logic       sk_ready;
  logic       busy;
  logic       done;
  logic       success;

  int         random_count;
  int         pk_count;
  int         sk_count;
  int         busy_cycles;

  always_comb begin
    if (random_count < 32) begin
      random_data = ALT_CASE ? REF_ALT_KEY_SEED[random_count] : REF_KEY_SEED[random_count];
    end else if (random_count < 64) begin
      random_data = REF_SIGMA2[random_count-32];
    end else begin
      random_data = REF_SIGMA[random_count-64];
    end
  end

  generate
    if (USE_SYNTH_TOP) begin : g_synth_top
      trike_keygen_synth_top dut (
          .i_clk         (clk),
          .i_rst_n       (rst_n),
          .i_start       (start),
          .i_random_valid(random_valid),
          .i_random_data (random_data),
          .o_random_ready(random_ready),
          .o_pk_valid    (pk_valid),
          .o_pk_data     (pk_data),
          .o_pk_last     (pk_last),
          .i_pk_ready    (pk_ready),
          .o_sk_valid    (sk_valid),
          .o_sk_data     (sk_data),
          .o_sk_last     (sk_last),
          .i_sk_ready    (sk_ready),
          .o_busy        (busy),
          .o_done        (done),
          .o_success     (success)
      );
    end else begin : g_core
      trike_keygen_core #(
          .M_BYTES        (32),
          .R_BITS         (REF_R_BITS),
          .SECRET_WEIGHT  (REF_SECRET_WEIGHT),
          .CANDIDATE_COUNT(REF_CANDIDATE_COUNT),
          .WORD_W         (64),
          .DIGIT_W        (16)
      ) dut (
          .i_clk         (clk),
          .i_rst_n       (rst_n),
          .i_start       (start),
          .i_random_valid(random_valid),
          .i_random_data (random_data),
          .o_random_ready(random_ready),
          .o_pk_valid    (pk_valid),
          .o_pk_data     (pk_data),
          .o_pk_last     (pk_last),
          .i_pk_ready    (pk_ready),
          .o_sk_valid    (sk_valid),
          .o_sk_data     (sk_data),
          .o_sk_last     (sk_last),
          .i_sk_ready    (sk_ready),
          .o_busy        (busy),
          .o_done        (done),
          .o_success     (success)
      );
    end
  endgenerate

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
      pk_count <= 0;
      sk_count <= 0;
    end else begin
      if (pk_valid && pk_ready) begin
        if (pk_count >= REF_PK_BYTES) $fatal(1, "too many public-key bytes");
        if ((!ALT_CASE && (pk_data != REF_PUBLIC_KEY[pk_count])) ||
            (ALT_CASE && (pk_data != REF_ALT_PUBLIC_KEY[pk_count]))) begin
          $fatal(1, "PK byte %0d mismatch got=%02h expected=%02h", pk_count, pk_data,
                 ALT_CASE ? REF_ALT_PUBLIC_KEY[pk_count] : REF_PUBLIC_KEY[pk_count]);
        end
        if (pk_last != (pk_count == (REF_PK_BYTES - 1))) begin
          $fatal(1, "PK last mismatch byte=%0d", pk_count);
        end
        pk_count <= pk_count + 1;
      end
      if (sk_valid && sk_ready) begin
        if (sk_count >= REF_SK_BYTES) $fatal(1, "too many secret-key bytes");
        if ((!ALT_CASE && (sk_data != REF_SECRET_KEY[sk_count])) ||
            (ALT_CASE && (sk_data != REF_ALT_SECRET_KEY[sk_count]))) begin
          $fatal(1, "SK byte %0d mismatch got=%02h expected=%02h", sk_count, sk_data,
                 ALT_CASE ? REF_ALT_SECRET_KEY[sk_count] : REF_SECRET_KEY[sk_count]);
        end
        if (sk_last != (sk_count == (REF_SK_BYTES - 1))) begin
          $fatal(1, "SK last mismatch byte=%0d", sk_count);
        end
        sk_count <= sk_count + 1;
      end
    end
  end

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    random_valid = 1'b0;
    pk_ready = 1'b1;
    sk_ready = 1'b1;
    random_count = 0;

    repeat (4) @(negedge clk);
    rst_n = 1'b1;
    if (USE_SYNTH_TOP) repeat (3) @(negedge clk);
    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;
    random_valid = 1'b1;

    while (random_count < 96) begin
      @(posedge clk);
      if (random_valid && random_ready) begin
        @(negedge clk);
        random_count++;
      end
    end
    random_valid = 1'b0;

    wait (done);
    #1;
    if (!success) $fatal(1, "official KeyGen returned failure");
    if (pk_count != REF_PK_BYTES) begin
      $fatal(1, "PK length mismatch got=%0d expected=%0d", pk_count, REF_PK_BYTES);
    end
    if (sk_count != REF_SK_BYTES) begin
      $fatal(1, "SK length mismatch got=%0d expected=%0d", sk_count, REF_SK_BYTES);
    end
    if (busy) $fatal(1, "KeyGen remained busy after done");
    if (busy_cycles != (USE_SYNTH_TOP ? EXPECTED_SYNTH_BUSY_CYCLES : EXPECTED_BUSY_CYCLES)) begin
      $fatal(1, "cycle mismatch got=%0d expected=%0d", busy_cycles,
             USE_SYNTH_TOP ? EXPECTED_SYNTH_BUSY_CYCLES : EXPECTED_BUSY_CYCLES);
    end
    $display("tb_trike_keygen_core_reference PASS alt=%0d synth=%0d pk=%0d sk=%0d cycles=%0d",
             ALT_CASE, USE_SYNTH_TOP, pk_count, sk_count, busy_cycles);
    $finish;
  end

  initial begin
    repeat (110000000) @(posedge clk);
    $fatal(1, "tb_trike_keygen_core_reference timeout");
  end

endmodule
