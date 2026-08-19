`timescale 1ns / 1ps

module tb_trike_decaps_input_store;
  import bike_pkg::*;

  localparam int WORD_W = 64;
  localparam int WORD_BYTES = WORD_W / 8;

  logic                      clk;
  logic                      rst_n;
  logic                      start;
  logic   [PROFILE_ID_W-1:0] param_level;
  logic                      valid;
  logic   [             7:0] data;
  logic                      ready;
  logic                      support_re;
  logic   [             8:0] support_raddr;
  logic   [            16:0] support_rdata;
  logic                      t0_re;
  logic   [            10:0] t0_raddr;
  logic   [            63:0] t0_rdata;
  logic                      r2_re;
  logic   [            13:0] r2_raddr;
  logic   [             7:0] r2_rdata;
  logic                      u_re;
  logic   [            10:0] u_raddr;
  logic   [            63:0] u_rdata;
  logic                      v_re;
  logic   [            10:0] v_raddr;
  logic   [            63:0] v_rdata;
  logic                      ciphertext_re;
  logic   [            14:0] ciphertext_raddr;
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
  logic                      busy;
  logic                      done;

  integer                    input_seen;
  logic   [             7:0] pattern_seed;

  trike_decaps_input_store dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_param_level     (param_level),
      .i_valid           (valid),
      .i_data            (data),
      .o_ready           (ready),
      .i_support_re      (support_re),
      .i_support_raddr   (support_raddr),
      .o_support_rdata   (support_rdata),
      .i_t0_re           (t0_re),
      .i_t0_raddr        (t0_raddr),
      .o_t0_rdata        (t0_rdata),
      .i_r2_re           (r2_re),
      .i_r2_raddr        (r2_raddr),
      .o_r2_rdata        (r2_rdata),
      .i_u_re            (u_re),
      .i_u_raddr         (u_raddr),
      .o_u_rdata         (u_rdata),
      .i_v_re            (v_re),
      .i_v_raddr         (v_raddr),
      .o_v_rdata         (v_rdata),
      .i_ciphertext_re   (ciphertext_re),
      .i_ciphertext_raddr(ciphertext_raddr),
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
      .o_busy            (busy),
      .o_done            (done)
  );

  always #1 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) input_seen <= 0;
    else if (ready && valid) input_seen <= input_seen + 1;
  end

  function automatic logic [7:0] stream_byte(input  logic [31:0] byte_idx);
    stream_byte = byte_idx[7:0] ^ byte_idx[15:8] ^ byte_idx[23:16] ^ byte_idx[31:24] ^ pattern_seed;
  endfunction

  always_comb begin
    valid = ready;
    data  = stream_byte(32'(input_seen));
  end

  function automatic logic [63:0] stream_word(input integer byte_offset, input integer word_idx,
                                              input integer active_bytes);
    logic   [63:0] result;
    integer        byte_idx;
    begin
      result = '0;
      for (int lane = 0; lane < WORD_BYTES; lane++) begin
        byte_idx = (word_idx * WORD_BYTES) + lane;
        if (byte_idx < active_bytes) result[8*lane+:8] = stream_byte(32'(byte_offset + byte_idx));
      end
      stream_word = result;
    end
  endfunction

  task automatic clear_read_ports;
    begin
      support_re = 1'b0;
      t0_re = 1'b0;
      r2_re = 1'b0;
      u_re = 1'b0;
      v_re = 1'b0;
      ciphertext_re = 1'b0;
      support_raddr = '0;
      t0_raddr = '0;
      r2_raddr = '0;
      u_raddr = '0;
      v_raddr = '0;
      ciphertext_raddr = '0;
    end
  endtask

  task automatic verify_support(input integer count);
    logic [16:0] expected_support;
    begin
      for (int addr = 0; addr < count; addr++) begin
        @(negedge clk);
        support_re = 1'b1;
        support_raddr = 9'(addr);
        @(negedge clk);
        expected_support = 17'({
          stream_byte(32'((4 * addr) + 2)),
          stream_byte(32'((4 * addr) + 1)),
          stream_byte(32'(4 * addr))
        });
        if (support_rdata != expected_support) $fatal(1, "support readback mismatch at %0d", addr);
      end
      support_re = 1'b0;
    end
  endtask

  task automatic verify_word_mem(input integer which_mem, input integer byte_offset,
                                 input integer active_bytes, input integer active_words);
    logic [63:0] actual_word;
    logic [63:0] expected_word;
    begin
      for (int addr = 0; addr < active_words; addr++) begin
        @(negedge clk);
        unique case (which_mem)
          0: begin
            t0_re = 1'b1;
            t0_raddr = 11'(addr);
          end
          1: begin
            u_re = 1'b1;
            u_raddr = 11'(addr);
          end
          default: begin
            v_re = 1'b1;
            v_raddr = 11'(addr);
          end
        endcase
        @(negedge clk);
        unique case (which_mem)
          0: actual_word = t0_rdata;
          1: actual_word = u_rdata;
          default: actual_word = v_rdata;
        endcase
        expected_word = stream_word(byte_offset, addr, active_bytes);
        if (actual_word != expected_word)
          $fatal(1, "word memory %0d readback mismatch at %0d", which_mem, addr);
      end
      t0_re = 1'b0;
      u_re  = 1'b0;
      v_re  = 1'b0;
    end
  endtask

  task automatic verify_byte_mem(input integer which_mem, input integer byte_offset,
                                 input integer active_bytes);
    logic [7:0] actual_byte;
    begin
      for (int addr = 0; addr < active_bytes; addr++) begin
        @(negedge clk);
        if (which_mem == 0) begin
          r2_re = 1'b1;
          r2_raddr = 14'(addr);
        end else begin
          ciphertext_re = 1'b1;
          ciphertext_raddr = 15'(addr);
        end
        @(negedge clk);
        if (which_mem == 0) actual_byte = r2_rdata;
        else actual_byte = ciphertext_rdata;
        if (actual_byte != stream_byte(32'(byte_offset + addr)))
          $fatal(1, "byte memory %0d readback mismatch at %0d", which_mem, addr);
      end
      r2_re = 1'b0;
      ciphertext_re = 1'b0;
    end
  endtask

  task automatic run_profile(input  logic [PROFILE_ID_W-1:0] profile, input integer r_value,
                             input integer w_value, input integer t_value,
                             input  logic [7:0] data_seed);
    integer r_bytes_expected;
    integer words_expected;
    integer support_count_expected;
    integer support_bytes_expected;
    integer sk_bytes_expected;
    integer ct_bytes_expected;
    integer h0_offset;
    integer t0_offset;
    integer r2_offset;
    integer sigma2_offset;
    integer u_offset;
    integer v_offset;
    begin
      r_bytes_expected = (r_value + 7) / 8;
      words_expected = (r_value + WORD_W - 1) / WORD_W;
      support_count_expected = 3 * w_value;
      support_bytes_expected = 4 * support_count_expected;
      sk_bytes_expected = support_bytes_expected + (3 * r_bytes_expected) + 64;
      ct_bytes_expected = (2 * r_bytes_expected) + 32;
      h0_offset = support_bytes_expected;
      t0_offset = h0_offset + r_bytes_expected;
      r2_offset = t0_offset + r_bytes_expected;
      sigma2_offset = r2_offset + r_bytes_expected + 32;
      u_offset = sk_bytes_expected;
      v_offset = u_offset + r_bytes_expected;
      pattern_seed = data_seed;

      rst_n = 1'b0;
      start = 1'b0;
      param_level = profile;
      clear_read_ports();
      repeat (3) @(negedge clk);
      rst_n = 1'b1;
      repeat (2) @(negedge clk);
      start = 1'b1;
      @(negedge clk);
      start = 1'b0;
      param_level = profile ^ 2'b11;
      if (!busy) $fatal(1, "store did not become busy");
      while (!done) @(negedge clk);

      if (input_seen != (sk_bytes_expected + ct_bytes_expected))
        $fatal(1, "store input count mismatch");
      if ((selected_level != profile) || (r_bits != 32'(r_value)) ||
          (secret_weight != 32'(w_value)) || (error_weight != 32'(t_value)) ||
          (r_bytes != 32'(r_bytes_expected)) || (words != 32'(words_expected)) ||
          (support_count != 32'(support_count_expected)) ||
          (secret_key_bytes != 32'(sk_bytes_expected)) ||
          (ciphertext_bytes != 32'(ct_bytes_expected)) ||
          (input_bytes != 32'(sk_bytes_expected + ct_bytes_expected)))
        $fatal(1, "store profile descriptor mismatch");

      verify_support(support_count_expected);
      verify_word_mem(0, t0_offset, r_bytes_expected, words_expected);
      verify_byte_mem(0, r2_offset, r_bytes_expected);
      verify_word_mem(1, u_offset, r_bytes_expected, words_expected);
      verify_word_mem(2, v_offset, r_bytes_expected, words_expected);
      verify_byte_mem(1, u_offset, ct_bytes_expected);
      for (int idx = 0; idx < 32; idx++) begin
        if (sigma2[8*idx+:8] != stream_byte(32'(sigma2_offset + idx)))
          $fatal(1, "sigma2 readback mismatch at %0d", idx);
      end

      if ((padded_r_bytes != 32'(((r_value + 511) / 512) * 64)) ||
          (error_bytes != 32'(3 * ((r_value + 511) / 512) * 64)))
        $fatal(1, "store padded error geometry mismatch");
      clear_read_ports();
      @(negedge clk);
    end
  endtask

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    param_level = PROFILE_TRIKE_160;
    pattern_seed = '0;
    clear_read_ports();

    run_profile(PROFILE_TRIKE_160, 12589, 35, 263, 8'h19);
    run_profile(PROFILE_TRIKE_256, 30389, 55, 429, 8'h36);
    run_profile(PROFILE_TRIKE_384, 63773, 83, 659, 8'h5a);
    run_profile(PROFILE_TRIKE_512, 106781, 111, 877, 8'hc3);

    $display("tb_trike_decaps_input_store PASS");
    $finish;
  end

  initial begin
    repeat (1000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_input_store timeout");
  end

endmodule
