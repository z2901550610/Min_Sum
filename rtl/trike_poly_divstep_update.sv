`timescale 1ns / 1ps

// Apply one broadcast divstep control sequence to a local word window.
module trike_poly_divstep_update #(
    parameter int WORD_W = 64,
    parameter int STEPS  = 8
) (
    input  logic [ STEPS-1:0] i_swap,
    input  logic [ STEPS-1:0] i_alpha,
    input  logic [WORD_W-1:0] i_f_word,
    input  logic [ STEPS-1:0] i_f_next_bits,
    input  logic [WORD_W-1:0] i_g_word,
    input  logic [ STEPS-1:0] i_g_next_bits,
    input  logic [WORD_W-1:0] i_v_word,
    input  logic [ STEPS-1:0] i_v_prev_bits,
    input  logic [WORD_W-1:0] i_w_word,
    input  logic [ STEPS-1:0] i_w_prev_bits,
    output logic [WORD_W-1:0] o_f_word,
    output logic [WORD_W-1:0] o_g_word,
    output logic [WORD_W-1:0] o_v_word,
    output logic [WORD_W-1:0] o_w_word
);

  localparam int WINDOW_W = WORD_W + STEPS;

  logic [WINDOW_W-1:0] f_window_c[0:STEPS];
  logic [WINDOW_W-1:0] g_window_c[0:STEPS];
  logic [WINDOW_W-1:0] v_window_c[0:STEPS];
  logic [WINDOW_W-1:0] w_window_c[0:STEPS];

  always_comb begin
    f_window_c[0] = {i_f_next_bits, i_f_word};
    g_window_c[0] = {i_g_next_bits, i_g_word};
    v_window_c[0] = {i_v_word, i_v_prev_bits};
    w_window_c[0] = {i_w_word, i_w_prev_bits};

    for (int step_idx = 0; step_idx < STEPS; step_idx++) begin
      f_window_c[step_idx+1] = i_swap[step_idx] ? g_window_c[step_idx] : f_window_c[step_idx];
      g_window_c[step_idx+1] =
          (i_alpha[step_idx] ?
               (g_window_c[step_idx] ^ f_window_c[step_idx]) :
               g_window_c[step_idx]) >> 1;
      v_window_c[step_idx+1] =
          (i_swap[step_idx] ? w_window_c[step_idx] : v_window_c[step_idx]) << 1;
      w_window_c[step_idx+1] =
          i_alpha[step_idx] ? (w_window_c[step_idx] ^ v_window_c[step_idx]) :
                              w_window_c[step_idx];
    end

    o_f_word = f_window_c[STEPS][WORD_W-1:0];
    o_g_word = g_window_c[STEPS][WORD_W-1:0];
    o_v_word = v_window_c[STEPS][STEPS+:WORD_W];
    o_w_word = w_window_c[STEPS][STEPS+:WORD_W];
  end

`ifndef SYNTHESIS
  initial begin
    if (WORD_W < 2) $error("trike_poly_divstep_update WORD_W must be at least 2");
    if (STEPS < 1) $error("trike_poly_divstep_update STEPS must be positive");
    if (STEPS > WORD_W) $error("trike_poly_divstep_update STEPS must not exceed WORD_W");
  end
`endif

endmodule
