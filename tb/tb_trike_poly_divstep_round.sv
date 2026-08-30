`timescale 1ns / 1ps

module tb_trike_poly_divstep_round;

  localparam int WORD_W   = 64;
  localparam int STEPS    = 8;
  localparam int DELTA_W  = 17;
  localparam int WINDOW_W = WORD_W + STEPS;

  logic signed [DELTA_W-1:0] delta;
  logic        [    STEPS:0] f_control;
  logic        [    STEPS:0] g_control;
  logic        [ WORD_W-1:0] f_word;
  logic        [  STEPS-1:0] f_next_bits;
  logic        [ WORD_W-1:0] g_word;
  logic        [  STEPS-1:0] g_next_bits;
  logic        [ WORD_W-1:0] v_word;
  logic        [  STEPS-1:0] v_prev_bits;
  logic        [ WORD_W-1:0] w_word;
  logic        [  STEPS-1:0] w_prev_bits;

  logic signed [DELTA_W-1:0] result_delta;
  logic        [  STEPS-1:0] result_swap;
  logic        [  STEPS-1:0] result_alpha;
  logic        [ WORD_W-1:0] result_f_word;
  logic        [ WORD_W-1:0] result_g_word;
  logic        [ WORD_W-1:0] result_v_word;
  logic        [ WORD_W-1:0] result_w_word;

  int unsigned               seed;

  trike_poly_divstep_control #(
      .STEPS  (STEPS),
      .DELTA_W(DELTA_W)
  ) u_control (
      .i_delta    (delta),
      .i_f_control(f_control),
      .i_g_control(g_control),
      .o_delta    (result_delta),
      .o_swap     (result_swap),
      .o_alpha    (result_alpha)
  );

  trike_poly_divstep_update #(
      .WORD_W(WORD_W),
      .STEPS (STEPS)
  ) u_update (
      .i_swap       (result_swap),
      .i_alpha      (result_alpha),
      .i_f_word     (f_word),
      .i_f_next_bits(f_next_bits),
      .i_g_word     (g_word),
      .i_g_next_bits(g_next_bits),
      .i_v_word     (v_word),
      .i_v_prev_bits(v_prev_bits),
      .i_w_word     (w_word),
      .i_w_prev_bits(w_prev_bits),
      .o_f_word     (result_f_word),
      .o_g_word     (result_g_word),
      .o_v_word     (result_v_word),
      .o_w_word     (result_w_word)
  );

  task automatic check_case;
    logic signed [ DELTA_W-1:0] expected_delta;
    logic        [     STEPS:0] expected_f_control;
    logic        [     STEPS:0] expected_g_control;
    logic        [     STEPS:0] old_f_control;
    logic        [     STEPS:0] old_g_control;
    logic        [   STEPS-1:0] expected_swap;
    logic        [   STEPS-1:0] expected_alpha;
    logic        [WINDOW_W-1:0] expected_f_window;
    logic        [WINDOW_W-1:0] expected_g_window;
    logic        [WINDOW_W-1:0] expected_v_window;
    logic        [WINDOW_W-1:0] expected_w_window;
    logic        [WINDOW_W-1:0] old_f_window;
    logic        [WINDOW_W-1:0] old_g_window;
    logic        [WINDOW_W-1:0] old_v_window;
    logic        [WINDOW_W-1:0] old_w_window;
    begin
      expected_delta = delta;
      expected_f_control = f_control;
      expected_g_control = g_control;
      expected_f_window = {f_next_bits, f_word};
      expected_g_window = {g_next_bits, g_word};
      expected_v_window = {v_word, v_prev_bits};
      expected_w_window = {w_word, w_prev_bits};

      for (int step_idx = 0; step_idx < STEPS; step_idx++) begin
        expected_alpha[step_idx] = expected_g_control[0];
        expected_swap[step_idx] = (expected_delta > 0) && expected_alpha[step_idx];
        expected_delta = expected_swap[step_idx] ? (-expected_delta + DELTA_W'(1)) :
                                                   (expected_delta + DELTA_W'(1));

        old_f_window = expected_f_window;
        old_g_window = expected_g_window;
        old_v_window = expected_v_window;
        old_w_window = expected_w_window;
        expected_f_window = expected_swap[step_idx] ? old_g_window : old_f_window;
        expected_g_window =
            (expected_alpha[step_idx] ? (old_g_window ^ old_f_window) : old_g_window) >> 1;
        expected_v_window = (expected_swap[step_idx] ? old_w_window : old_v_window) << 1;
        expected_w_window = expected_alpha[step_idx] ? (old_w_window ^ old_v_window) : old_w_window;

        if (step_idx < STEPS - 1) begin
          old_f_control = expected_f_control;
          old_g_control = expected_g_control;
          expected_f_control = expected_swap[step_idx] ? old_g_control : old_f_control;
          expected_g_control =
              (expected_alpha[step_idx] ?
                   (old_g_control ^ old_f_control) :
                   old_g_control) >> 1;
        end
      end

      #1;
      if ((result_delta != expected_delta) || (result_swap != expected_swap) ||
          (result_alpha != expected_alpha) ||
          (result_f_word != expected_f_window[WORD_W-1:0]) ||
          (result_g_word != expected_g_window[WORD_W-1:0]) ||
          (result_v_word != expected_v_window[STEPS+:WORD_W]) ||
          (result_w_word != expected_w_window[STEPS+:WORD_W])) begin
        $fatal(1, "divstep round mismatch delta=%0d f_control=%0h g_control=%0h", delta, f_control,
               g_control);
      end
    end
  endtask

  initial begin
    seed = 32'h4259_0008;
    delta = 1;
    f_control = '1;
    g_control = '1;
    f_word = '0;
    f_next_bits = '0;
    g_word = '0;
    g_next_bits = '0;
    v_word = '0;
    v_prev_bits = '0;
    w_word = '0;
    w_prev_bits = '0;
    check_case();

    for (int case_idx = 0; case_idx < 2048; case_idx++) begin
      delta = DELTA_W'($urandom(seed) % 2047 - 1023);
      f_control = (STEPS + 1)'($urandom(seed));
      g_control = (STEPS + 1)'($urandom(seed));
      f_word = {$urandom(seed), $urandom(seed)};
      f_next_bits = STEPS'($urandom(seed));
      g_word = {$urandom(seed), $urandom(seed)};
      g_next_bits = STEPS'($urandom(seed));
      v_word = {$urandom(seed), $urandom(seed)};
      v_prev_bits = STEPS'($urandom(seed));
      w_word = {$urandom(seed), $urandom(seed)};
      w_prev_bits = STEPS'($urandom(seed));
      check_case();
    end

    $display("tb_trike_poly_divstep_round PASS steps=%0d cases=2049", STEPS);
    $finish;
  end

endmodule
