`timescale 1ns / 1ps

module tb_trike_poly_divstep_s1;

  localparam int WORD_W  = 64;
  localparam int DELTA_W = 8;

  logic signed [DELTA_W-1:0] delta;
  logic                      g_lsb;
  logic        [ WORD_W-1:0] f_word;
  logic                      f_next_lsb;
  logic        [ WORD_W-1:0] g_word;
  logic                      g_next_lsb;
  logic        [ WORD_W-1:0] v_word;
  logic        [ WORD_W-1:0] v_prev_word;
  logic        [ WORD_W-1:0] w_word;
  logic        [ WORD_W-1:0] w_prev_word;
  logic signed [DELTA_W-1:0] result_delta;
  logic                      result_swap;
  logic                      result_alpha;
  logic        [ WORD_W-1:0] result_f_word;
  logic        [ WORD_W-1:0] result_g_word;
  logic        [ WORD_W-1:0] result_v_word;
  logic        [ WORD_W-1:0] result_w_word;

  int unsigned               seed;

  trike_poly_divstep_s1 #(
      .WORD_W (WORD_W),
      .DELTA_W(DELTA_W)
  ) dut (
      .i_delta      (delta),
      .i_g_lsb      (g_lsb),
      .i_f_word     (f_word),
      .i_f_next_lsb (f_next_lsb),
      .i_g_word     (g_word),
      .i_g_next_lsb (g_next_lsb),
      .i_v_word     (v_word),
      .i_v_prev_word(v_prev_word),
      .i_w_word     (w_word),
      .i_w_prev_word(w_prev_word),
      .o_delta      (result_delta),
      .o_swap       (result_swap),
      .o_alpha      (result_alpha),
      .o_f_word     (result_f_word),
      .o_g_word     (result_g_word),
      .o_v_word     (result_v_word),
      .o_w_word     (result_w_word)
  );

  task automatic check_case;
    logic                      expected_swap;
    logic                      expected_alpha;
    logic signed [DELTA_W-1:0] expected_delta;
    logic        [ WORD_W-1:0] expected_f_word;
    logic        [ WORD_W-1:0] expected_g_word;
    logic        [ WORD_W-1:0] expected_v_word;
    logic        [ WORD_W-1:0] expected_w_word;
    begin
      #1;
      expected_alpha = g_lsb;
      expected_swap = (delta > 0) && g_lsb;
      expected_delta = expected_swap ? (-delta + 1) : (delta + 1);
      expected_f_word = expected_swap ? g_word : f_word;
      expected_g_word = {
        expected_alpha ? (g_next_lsb ^ f_next_lsb) : g_next_lsb,
        expected_alpha ? (g_word[WORD_W-1:1] ^ f_word[WORD_W-1:1]) : g_word[WORD_W-1:1]
      };
      expected_v_word = {
        expected_swap ? w_word[WORD_W-2:0] : v_word[WORD_W-2:0],
        expected_swap ? w_prev_word[WORD_W-1] : v_prev_word[WORD_W-1]
      };
      expected_w_word = expected_alpha ? (w_word ^ v_word) : w_word;

      if ((result_swap != expected_swap) || (result_alpha != expected_alpha) ||
          (result_delta != expected_delta) || (result_f_word != expected_f_word) ||
          (result_g_word != expected_g_word) || (result_v_word != expected_v_word) ||
          (result_w_word != expected_w_word)) begin
        $fatal(1, "divstep mismatch delta=%0d g_lsb=%0b", delta, g_lsb);
      end
    end
  endtask

  initial begin
    seed = 32'h4259_0001;
    f_word = '0;
    f_next_lsb = 1'b0;
    g_word = '0;
    g_next_lsb = 1'b0;
    v_word = '0;
    v_prev_word = '0;
    w_word = '0;
    w_prev_word = '0;

    for (int delta_value = -8; delta_value <= 8; delta_value++) begin
      for (int alpha_value = 0; alpha_value < 2; alpha_value++) begin
        delta = DELTA_W'(delta_value);
        g_lsb = alpha_value[0];
        f_word = 64'h0123_4567_89ab_cdef;
        f_next_lsb = 1'b0;
        g_word = 64'hf0f0_0f0f_a5a5_5a5a;
        g_next_lsb = 1'b1;
        v_word = 64'h1111_2222_3333_4444;
        v_prev_word = 64'h8000_0000_0000_0000;
        w_word = 64'haaaa_bbbb_cccc_dddd;
        w_prev_word = 64'h7fff_ffff_ffff_ffff;
        check_case();
      end
    end

    for (int case_idx = 0; case_idx < 1024; case_idx++) begin
      delta = DELTA_W'($urandom(seed) % 127 - 63);
      g_lsb = 1'($urandom(seed));
      f_word = {$urandom(seed), $urandom(seed)};
      f_next_lsb = 1'($urandom(seed));
      g_word = {$urandom(seed), $urandom(seed)};
      g_next_lsb = 1'($urandom(seed));
      v_word = {$urandom(seed), $urandom(seed)};
      v_prev_word = {$urandom(seed), $urandom(seed)};
      w_word = {$urandom(seed), $urandom(seed)};
      w_prev_word = {$urandom(seed), $urandom(seed)};
      check_case();
    end

    g_lsb = 1'b1;
    delta = 1;
    f_next_lsb = 1'b0;
    g_next_lsb = 1'b0;
    v_prev_word = '0;
    w_prev_word = '0;
    check_case();

    $display("tb_trike_poly_divstep_s1 PASS cases=1059");
    $finish;
  end

endmodule
