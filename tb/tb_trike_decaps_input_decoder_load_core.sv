`timescale 1ns / 1ps

module tb_trike_decaps_input_decoder_load_core;
  import bike_pkg::*;

  localparam int WORD_W = 64;
  localparam int MAX_R_BITS = P_R_VALS[3];
  localparam int MAX_R_BYTES = (MAX_R_BITS + 7) / 8;
  localparam int MAX_CT_BYTES = (2 * MAX_R_BYTES) + 32;
  localparam int ROW_W = $clog2(MAX_R_BITS);
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
  logic                      h_we;
  logic   [             1:0] h_block_idx;
  logic   [             6:0] h_diag_idx;
  logic   [       ROW_W-1:0] h_index;
  logic                      h_loaded;
  logic                      syndrome_we;
  logic   [       ROW_W-1:0] syndrome_addr;
  logic                      syndrome_data;
  logic                      decoder_start;
  logic                      decoder_done;
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
  logic                      error;
  logic                      busy;
  logic                      done;

  integer                    input_count;
  integer                    h_write_count;
  integer                    syndrome_write_count;
  integer                    decoder_wait_count;
  integer                    decoder_start_count;
  integer                    busy_cycles;
  logic   [             7:0] payload_seed;
  logic   [  MAX_R_BITS-1:0] expected_vector;
  logic   [       ROW_W-1:0] expected_support[0:SUPPORT_COUNT-1];

  trike_decaps_input_decoder_load_core dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_param_level     (param_level),
      .i_input_valid     (input_valid),
      .i_input_data      (input_data),
      .o_input_ready     (input_ready),
      .o_h_we            (h_we),
      .o_h_block_idx     (h_block_idx),
      .o_h_diag_idx      (h_diag_idx),
      .o_h_index         (h_index),
      .i_h_loaded        (h_loaded),
      .i_h_error         (1'b0),
      .o_syndrome_we     (syndrome_we),
      .o_syndrome_addr   (syndrome_addr),
      .o_syndrome_data   (syndrome_data),
      .o_decoder_start   (decoder_start),
      .i_decoder_done    (decoder_done),
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
      .o_error           (error),
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
    input_data = transaction_byte(input_count);
    h_loaded = h_write_count == SUPPORT_COUNT;
    decoder_done = decoder_wait_count == 5;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      input_count <= 0;
      h_write_count <= 0;
      syndrome_write_count <= 0;
      decoder_wait_count <= 0;
      decoder_start_count <= 0;
      busy_cycles <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;
      if (input_valid && input_ready) input_count <= input_count + 1;
      if (h_we) begin
        if (h_block_idx != 2'(h_write_count / ACTIVE_WEIGHT))
          $fatal(1, "input decoder-load H block mismatch");
        if (h_diag_idx != 7'(h_write_count % ACTIVE_WEIGHT))
          $fatal(1, "input decoder-load H diagonal mismatch");
        if (h_index != expected_support[h_write_count])
          $fatal(1, "input decoder-load H index mismatch");
        h_write_count <= h_write_count + 1;
      end
      if (syndrome_we) begin
        if (syndrome_addr != ROW_W'(syndrome_write_count))
          $fatal(1, "input decoder-load syndrome address mismatch");
        if (syndrome_data != expected_vector[syndrome_write_count])
          $fatal(1, "input decoder-load syndrome data mismatch");
        syndrome_write_count <= syndrome_write_count + 1;
      end
      if (decoder_start) decoder_start_count <= decoder_start_count + 1;
      if (decoder_start || (decoder_wait_count != 0)) decoder_wait_count <= decoder_wait_count + 1;
    end
  end

  task automatic build_expected;
    logic [MAX_R_BITS-1:0] u_vector;
    logic [     ROW_W-1:0] swap_value;
    begin
      u_vector = '0;
      expected_vector = '0;
      for (int byte_idx = 0; byte_idx < ACTIVE_R_BYTES; byte_idx++)
      u_vector[8*byte_idx+:8] = u_byte(byte_idx);
      for (int bit_idx = ACTIVE_R; bit_idx < (ACTIVE_R_BYTES * 8); bit_idx++)
      u_vector[bit_idx] = 1'b0;
      for (int support_idx = 0; support_idx < ACTIVE_WEIGHT; support_idx++) begin
        for (int bit_idx = 0; bit_idx < ACTIVE_R; bit_idx++) begin
          if (u_vector[bit_idx]) begin
            expected_vector[(support_position(support_idx)+bit_idx)%ACTIVE_R] =
                expected_vector[(support_position(support_idx)+bit_idx)%ACTIVE_R] ^ 1'b1;
          end
        end
      end
      for (int block_idx = 0; block_idx < 3; block_idx++) begin
        for (int diag_idx = 0; diag_idx < ACTIVE_WEIGHT; diag_idx++)
        expected_support[(block_idx*ACTIVE_WEIGHT)+diag_idx] =
            ROW_W'(support_position((block_idx * ACTIVE_WEIGHT) + diag_idx));
        for (int pass_idx = 0; pass_idx < ACTIVE_WEIGHT; pass_idx++) begin
          for (int compare_idx = 0; compare_idx < (ACTIVE_WEIGHT - 1); compare_idx++) begin
            if (expected_support[(block_idx*ACTIVE_WEIGHT)+compare_idx] >
                expected_support[(block_idx*ACTIVE_WEIGHT)+compare_idx+1]) begin
              swap_value = expected_support[(block_idx*ACTIVE_WEIGHT)+compare_idx];
              expected_support[(block_idx*ACTIVE_WEIGHT)+compare_idx] =
                  expected_support[(block_idx*ACTIVE_WEIGHT)+compare_idx+1];
              expected_support[(block_idx*ACTIVE_WEIGHT)+compare_idx+1] = swap_value;
            end
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
      if (error) $fatal(1, "input decoder-load unexpected error");
      if ((input_count != INPUT_BYTES) || (h_write_count != SUPPORT_COUNT) ||
          (syndrome_write_count != ACTIVE_R) || (decoder_start_count != 1))
        $fatal(1, "input decoder-load transfer count mismatch");
      if ((selected_level != PROFILE_TRIKE_160) || (r_bits != ACTIVE_R) ||
          (secret_weight != ACTIVE_WEIGHT) || (r_bytes != ACTIVE_R_BYTES) ||
          (words != ACTIVE_WORDS) || (support_count != SUPPORT_COUNT) ||
          (secret_key_bytes != SECRET_KEY_BYTES) || (ciphertext_bytes != CIPHERTEXT_BYTES) ||
          (input_bytes != INPUT_BYTES))
        $fatal(1, "input decoder-load descriptor mismatch");
      $display("input decoder-load seed=%0h cycles=%0d", data_seed, latency);
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
    if (latency_a != latency_b) $fatal(1, "input decoder-load data-dependent latency");

    $display("tb_trike_decaps_input_decoder_load_core PASS cycles=%0d", latency_a);
    $finish;
  end

  initial begin
    repeat (5000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_input_decoder_load_core timeout");
  end

  /* verilator lint_off UNUSED */
  logic unused_descriptor;
  always_comb begin
    unused_descriptor =
        ^{r2_rdata, ciphertext_rdata, sigma2, error_weight, padded_r_bytes, error_bytes};
  end
  /* verilator lint_on UNUSED */

endmodule
