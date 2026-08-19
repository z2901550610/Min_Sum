`timescale 1ns / 1ps

module tb_trike_decaps_input_syndrome_core;
  import bike_pkg::*;

  localparam int WORD_W = 64;
  localparam int MAX_R_BITS = P_R_VALS[3];
  localparam int MAX_R_BYTES = (MAX_R_BITS + 7) / 8;
  localparam int MAX_CT_BYTES = (2 * MAX_R_BYTES) + 32;
  localparam int R_ADDR_W = $clog2(MAX_R_BYTES);
  localparam int CT_ADDR_W = $clog2(MAX_CT_BYTES);
  localparam int ACTIVE_R = P_R_VALS[0];
  localparam int ACTIVE_WEIGHT = P_W_VALS[0];
  localparam int ACTIVE_R_BYTES = (ACTIVE_R + 7) / 8;
  localparam int ACTIVE_WORDS = (ACTIVE_R + WORD_W - 1) / WORD_W;
  localparam int SUPPORT_COUNT = 3 * ACTIVE_WEIGHT;
  localparam int SUPPORT_BYTES = 4 * SUPPORT_COUNT;
  localparam int SECRET_KEY_BYTES = SUPPORT_BYTES + (3 * ACTIVE_R_BYTES) + 64;
  localparam int CIPHERTEXT_BYTES = (2 * ACTIVE_R_BYTES) + 32;
  localparam int INPUT_BYTES = SECRET_KEY_BYTES + CIPHERTEXT_BYTES;
  localparam int T0_OFFSET = SUPPORT_BYTES + ACTIVE_R_BYTES;
  localparam int U_OFFSET = SECRET_KEY_BYTES;
  localparam int V_OFFSET = U_OFFSET + ACTIVE_R_BYTES;

  logic                      clk;
  logic                      rst_n;
  logic                      start;
  logic   [PROFILE_ID_W-1:0] param_level;
  logic                      input_valid;
  logic   [             7:0] input_data;
  logic                      input_ready;
  logic   [             7:0] r2_rdata;
  logic   [             7:0] ciphertext_rdata;
  logic   [           255:0] sigma2;
  logic   [PROFILE_ID_W-1:0] selected_level;
  logic   [            31:0] r_bits;
  logic   [            31:0] secret_weight;
  logic   [            31:0] error_weight;
  logic   [            31:0] r_bytes;
  logic   [            31:0] padded_r_bytes;
  logic   [            31:0] words;
  logic   [            31:0] support_count;
  logic   [            31:0] secret_key_bytes;
  logic   [            31:0] ciphertext_bytes;
  logic   [            31:0] input_bytes;
  logic   [            31:0] error_bytes;
  logic                      syndrome_valid;
  logic   [      WORD_W-1:0] syndrome_data;
  logic                      syndrome_last;
  logic                      busy;
  logic                      done;

  integer                    input_count;
  integer                    output_count;
  integer                    busy_cycles;
  logic   [             7:0] payload_seed;
  logic   [  MAX_R_BITS-1:0] expected_vector;

  trike_decaps_input_syndrome_core dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_param_level     (param_level),
      .i_input_valid     (input_valid),
      .i_input_data      (input_data),
      .o_input_ready     (input_ready),
      .i_r2_re           (1'b0),
      .i_r2_raddr        (R_ADDR_W'(0)),
      .o_r2_rdata        (r2_rdata),
      .i_ciphertext_re   (1'b0),
      .i_ciphertext_raddr(CT_ADDR_W'(0)),
      .o_ciphertext_rdata(ciphertext_rdata),
      .o_sigma2          (sigma2),
      .o_param_level     (selected_level),
      .o_r_bits          (r_bits),
      .o_secret_weight   (secret_weight),
      .o_error_weight    (error_weight),
      .o_r_bytes         (r_bytes),
      .o_padded_r_bytes  (padded_r_bytes),
      .o_words           (words),
      .o_support_count   (support_count),
      .o_secret_key_bytes(secret_key_bytes),
      .o_ciphertext_bytes(ciphertext_bytes),
      .o_input_bytes     (input_bytes),
      .o_error_bytes     (error_bytes),
      .o_syndrome_valid  (syndrome_valid),
      .o_syndrome_data   (syndrome_data),
      .o_syndrome_last   (syndrome_last),
      .i_syndrome_ready  (1'b1),
      .o_busy            (busy),
      .o_done            (done)
  );

  always #1 clk = ~clk;

  function automatic integer support_position(input integer support_idx);
    support_position = ((support_idx * 313) + int'(payload_seed)) % ACTIVE_R;
  endfunction

  function automatic logic [7:0] u_byte(input integer byte_idx);
    u_byte = 8'((byte_idx * 29) + int'(payload_seed) + (byte_idx >> 3));
  endfunction

  function automatic logic [7:0] transaction_byte(input integer byte_idx);
    integer support_idx;
    integer support_lane;
    integer support_value;
    begin
      transaction_byte = 8'((byte_idx * 17) ^ int'(payload_seed));
      if (byte_idx < SUPPORT_BYTES) begin
        support_idx = byte_idx / 4;
        support_lane = byte_idx % 4;
        support_value = support_position(support_idx);
        transaction_byte = 8'(support_value >> (8 * support_lane));
      end else if ((byte_idx >= T0_OFFSET) && (byte_idx < (T0_OFFSET + ACTIVE_R_BYTES))) begin
        transaction_byte = '0;
      end else if ((byte_idx >= U_OFFSET) && (byte_idx < (U_OFFSET + ACTIVE_R_BYTES))) begin
        transaction_byte = u_byte(byte_idx - U_OFFSET);
      end else if ((byte_idx >= V_OFFSET) && (byte_idx < (V_OFFSET + ACTIVE_R_BYTES))) begin
        transaction_byte = u_byte(byte_idx - V_OFFSET);
      end
    end
  endfunction

  always_comb begin
    input_valid = input_ready;
    input_data  = transaction_byte(input_count);
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      input_count  <= 0;
      output_count <= 0;
      busy_cycles  <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;
      if (input_valid && input_ready) input_count <= input_count + 1;
      if (syndrome_valid) begin
        if (syndrome_data != expected_vector[(output_count*WORD_W)+:WORD_W])
          $fatal(1, "input-store syndrome mismatch word=%0d", output_count);
        if (syndrome_last != (output_count == (ACTIVE_WORDS - 1)))
          $fatal(1, "input-store syndrome last mismatch");
        output_count <= output_count + 1;
      end
    end
  end

  task automatic build_expected;
    logic [MAX_R_BITS-1:0] u_vector;
    begin
      u_vector = '0;
      expected_vector = '0;
      for (int byte_idx = 0; byte_idx < ACTIVE_R_BYTES; byte_idx++) begin
        u_vector[8*byte_idx+:8] = u_byte(byte_idx);
      end
      for (int bit_idx = ACTIVE_R; bit_idx < (ACTIVE_R_BYTES * 8); bit_idx++) begin
        u_vector[bit_idx] = 1'b0;
      end
      for (int support_idx = 0; support_idx < ACTIVE_WEIGHT; support_idx++) begin
        for (int bit_idx = 0; bit_idx < ACTIVE_R; bit_idx++) begin
          if (u_vector[bit_idx]) begin
            expected_vector[(support_position(support_idx)+bit_idx)%ACTIVE_R] =
                expected_vector[(support_position(support_idx)+bit_idx)%ACTIVE_R] ^ 1'b1;
          end
        end
      end
    end
  endtask

  task automatic run_case(input  logic [7:0] data_seed, output integer latency);
    begin
      payload_seed = data_seed;
      build_expected();
      rst_n = 1'b0;
      start = 1'b0;
      param_level = PROFILE_TRIKE_160;
      repeat (3) @(negedge clk);
      rst_n = 1'b1;
      repeat (2) @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      param_level = PROFILE_TRIKE_512;
      while (!done) @(negedge clk);
      latency = busy_cycles;
      if ((input_count != INPUT_BYTES) || (output_count != ACTIVE_WORDS))
        $fatal(1, "input-store syndrome transfer count mismatch");
      if ((selected_level != PROFILE_TRIKE_160) || (r_bits != ACTIVE_R) ||
          (secret_weight != ACTIVE_WEIGHT) || (r_bytes != ACTIVE_R_BYTES) ||
          (words != ACTIVE_WORDS) || (support_count != SUPPORT_COUNT) ||
          (secret_key_bytes != SECRET_KEY_BYTES) || (ciphertext_bytes != CIPHERTEXT_BYTES) ||
          (input_bytes != INPUT_BYTES))
        $fatal(1, "input-store syndrome descriptor mismatch");
      @(negedge clk);
    end
  endtask

  initial begin
    integer latency_a;
    integer latency_b;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    param_level = PROFILE_TRIKE_160;
    payload_seed = '0;
    expected_vector = '0;

    run_case(8'h19, latency_a);
    run_case(8'hc6, latency_b);
    if (latency_a != latency_b) $fatal(1, "input-store syndrome data-dependent latency");

    $display("tb_trike_decaps_input_syndrome_core PASS cycles=%0d", latency_a);
    $finish;
  end

  initial begin
    repeat (5000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_input_syndrome_core timeout");
  end

  /* verilator lint_off UNUSED */
  logic unused_descriptor;
  always_comb
    unused_descriptor = ^{r2_rdata, ciphertext_rdata, sigma2, error_weight, padded_r_bytes, error_bytes};
  /* verilator lint_on UNUSED */

endmodule
