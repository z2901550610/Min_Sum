`timescale 1ns / 1ps

module tb_trike_decaps_input_loader;
  import bike_pkg::*;

  logic                      clk;
  logic                      rst_n;
  logic                      start;
  logic   [PROFILE_ID_W-1:0] param_level;
  logic                      valid;
  logic   [             7:0] data;
  logic                      ready;
  logic                      support_we;
  logic   [             8:0] support_waddr;
  logic   [            16:0] support_wdata;
  logic                      t0_we;
  logic   [            10:0] t0_waddr;
  logic   [            63:0] t0_wdata;
  logic                      r2_we;
  logic   [            13:0] r2_waddr;
  logic   [             7:0] r2_wdata;
  logic                      u_we;
  logic   [            10:0] u_waddr;
  logic   [            63:0] u_wdata;
  logic                      v_we;
  logic   [            10:0] v_waddr;
  logic   [            63:0] v_wdata;
  logic                      ct_we;
  logic   [            14:0] ct_waddr;
  logic   [             7:0] ct_wdata;
  logic                      sigma2_we;
  logic   [             4:0] sigma2_waddr;
  logic   [             7:0] sigma2_wdata;
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

  integer                    expected_r_bits;
  integer                    expected_secret_weight;
  integer                    expected_error_weight;
  integer                    expected_r_bytes;
  integer                    expected_padded_r_bytes;
  integer                    expected_words;
  integer                    expected_support_count;
  integer                    expected_support_bytes;
  integer                    expected_secret_key_bytes;
  integer                    expected_ciphertext_bytes;
  integer                    expected_input_bytes;
  integer                    expected_error_bytes;
  logic   [             7:0] pattern_seed;
  integer                    input_seen;
  integer                    support_writes;
  integer                    t0_writes;
  integer                    r2_writes;
  integer                    u_writes;
  integer                    v_writes;
  integer                    ct_writes;
  integer                    sigma2_writes;
  integer                    cycle_count;

  trike_decaps_input_loader dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_param_level     (param_level),
      .i_valid           (valid),
      .i_data            (data),
      .o_ready           (ready),
      .o_support_we      (support_we),
      .o_support_waddr   (support_waddr),
      .o_support_wdata   (support_wdata),
      .o_t0_we           (t0_we),
      .o_t0_waddr        (t0_waddr),
      .o_t0_wdata        (t0_wdata),
      .o_r2_we           (r2_we),
      .o_r2_waddr        (r2_waddr),
      .o_r2_wdata        (r2_wdata),
      .o_u_we            (u_we),
      .o_u_waddr         (u_waddr),
      .o_u_wdata         (u_wdata),
      .o_v_we            (v_we),
      .o_v_waddr         (v_waddr),
      .o_v_wdata         (v_wdata),
      .o_ct_we           (ct_we),
      .o_ct_waddr        (ct_waddr),
      .o_ct_wdata        (ct_wdata),
      .o_sigma2_we       (sigma2_we),
      .o_sigma2_waddr    (sigma2_waddr),
      .o_sigma2_wdata    (sigma2_wdata),
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

  always_comb begin
    valid = ready;
    data  = 8'(input_seen) ^ pattern_seed;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      input_seen <= 0;
      support_writes <= 0;
      t0_writes <= 0;
      r2_writes <= 0;
      u_writes <= 0;
      v_writes <= 0;
      ct_writes <= 0;
      sigma2_writes <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (ready && valid) begin
        input_seen <= input_seen + 1;
        if (r2_we && (r2_wdata != data)) $fatal(1, "r2 data mismatch");
        if (ct_we && (ct_wdata != data)) $fatal(1, "ciphertext data mismatch");
        if (sigma2_we && (sigma2_wdata != data)) $fatal(1, "sigma2 data mismatch");
      end
      if (support_we) begin
        if (support_waddr != 9'(support_writes)) $fatal(1, "support address mismatch");
        support_writes <= support_writes + 1;
      end
      if (t0_we) begin
        if (t0_waddr != 11'(t0_writes)) $fatal(1, "t0 address mismatch");
        t0_writes <= t0_writes + 1;
      end
      if (r2_we) begin
        if (r2_waddr != 14'(r2_writes)) $fatal(1, "r2 address mismatch");
        r2_writes <= r2_writes + 1;
      end
      if (u_we) begin
        if (u_waddr != 11'(u_writes)) $fatal(1, "u address mismatch");
        u_writes <= u_writes + 1;
      end
      if (v_we) begin
        if (v_waddr != 11'(v_writes)) $fatal(1, "v address mismatch");
        v_writes <= v_writes + 1;
      end
      if (ct_we) begin
        if (ct_waddr != 15'(ct_writes)) $fatal(1, "ciphertext address mismatch");
        ct_writes <= ct_writes + 1;
      end
      if (sigma2_we) begin
        if (sigma2_waddr != 5'(sigma2_writes)) $fatal(1, "sigma2 address mismatch");
        sigma2_writes <= sigma2_writes + 1;
      end
    end
  end

  task automatic run_profile(input  logic [PROFILE_ID_W-1:0] profile, input integer r_value,
                             input integer w_value, input integer t_value,
                             input  logic [7:0] data_seed, output integer latency);
    integer start_cycle;
    begin
      expected_r_bits = r_value;
      expected_secret_weight = w_value;
      expected_error_weight = t_value;
      expected_r_bytes = (r_value + 7) / 8;
      expected_padded_r_bytes = ((r_value + 511) / 512) * 64;
      expected_words = (r_value + 63) / 64;
      expected_support_count = 3 * w_value;
      expected_support_bytes = expected_support_count * 4;
      expected_secret_key_bytes = expected_support_bytes + (3 * expected_r_bytes) + 64;
      expected_ciphertext_bytes = (2 * expected_r_bytes) + 32;
      expected_input_bytes = expected_secret_key_bytes + expected_ciphertext_bytes;
      expected_error_bytes = 3 * expected_padded_r_bytes;
      pattern_seed = data_seed;

      rst_n = 1'b0;
      start = 1'b0;
      param_level = profile;
      repeat (3) @(negedge clk);
      rst_n = 1'b1;
      repeat (2) @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      param_level = profile ^ 2'b11;

      if (!busy || !ready) $fatal(1, "loader did not enter load state");
      if (selected_level != profile) $fatal(1, "profile was not locked");
      if ((r_bits != 32'(expected_r_bits)) ||
          (secret_weight != 32'(expected_secret_weight)) ||
          (error_weight != 32'(expected_error_weight)) ||
          (r_bytes != 32'(expected_r_bytes)) ||
          (padded_r_bytes != 32'(expected_padded_r_bytes)) ||
          (words != 32'(expected_words)) ||
          (support_count != 32'(expected_support_count)) ||
          (secret_key_bytes != 32'(expected_secret_key_bytes)) ||
          (ciphertext_bytes != 32'(expected_ciphertext_bytes)) ||
          (input_bytes != 32'(expected_input_bytes)) ||
          (error_bytes != 32'(expected_error_bytes)))
        $fatal(1, "profile descriptor mismatch for profile %0d", profile);

      while (!done) begin
        @(negedge clk);
        if (selected_level != profile) $fatal(1, "profile changed during transaction");
      end
      latency = cycle_count - start_cycle;
      if (latency != (expected_input_bytes + 1)) $fatal(1, "loader latency mismatch");
      if (input_seen != expected_input_bytes) $fatal(1, "input count mismatch");
      if (support_writes != expected_support_count) $fatal(1, "support write count mismatch");
      if (t0_writes != expected_words) $fatal(1, "t0 write count mismatch");
      if (r2_writes != expected_r_bytes) $fatal(1, "r2 write count mismatch");
      if (u_writes != expected_words) $fatal(1, "u write count mismatch");
      if (v_writes != expected_words) $fatal(1, "v write count mismatch");
      if (ct_writes != expected_ciphertext_bytes) $fatal(1, "ciphertext write count mismatch");
      if (sigma2_writes != 32) $fatal(1, "sigma2 write count mismatch");
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
    pattern_seed = 0;

    run_profile(PROFILE_TRIKE_160, 12589, 35, 263, 8'h12, latency_a);
    run_profile(PROFILE_TRIKE_160, 12589, 35, 263, 8'he7, latency_b);
    if (latency_a != latency_b) $fatal(1, "TRIKE160 data-dependent loader latency");
    run_profile(PROFILE_TRIKE_256, 30389, 55, 429, 8'h25, latency_a);
    run_profile(PROFILE_TRIKE_256, 30389, 55, 429, 8'hda, latency_b);
    if (latency_a != latency_b) $fatal(1, "TRIKE256 data-dependent loader latency");
    run_profile(PROFILE_TRIKE_384, 63773, 83, 659, 8'h38, latency_a);
    run_profile(PROFILE_TRIKE_384, 63773, 83, 659, 8'hc7, latency_b);
    if (latency_a != latency_b) $fatal(1, "TRIKE384 data-dependent loader latency");
    run_profile(PROFILE_TRIKE_512, 106781, 111, 877, 8'h4b, latency_a);
    run_profile(PROFILE_TRIKE_512, 106781, 111, 877, 8'hb4, latency_b);
    if (latency_a != latency_b) $fatal(1, "TRIKE512 data-dependent loader latency");

    $display("tb_trike_decaps_input_loader PASS");
    $finish;
  end

  initial begin
    repeat (600000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_input_loader timeout");
  end

  /* verilator lint_off UNUSEDSIGNAL */
  logic [208:0] unused_write_data;
  assign unused_write_data = {support_wdata, t0_wdata, u_wdata, v_wdata};
  /* verilator lint_on UNUSEDSIGNAL */

endmodule
