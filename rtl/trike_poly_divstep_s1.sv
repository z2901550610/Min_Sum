`timescale 1ns / 1ps

// One characteristic-two Bernstein-Yang divstep over one word window.
// The controller supplies the global g(0) bit and the adjacent words needed
// for the opposite f/g right shift and v/w left shift directions.
module trike_poly_divstep_s1 #(
    parameter int WORD_W  = 64,
    parameter int DELTA_W = 17
) (
    input  logic signed [DELTA_W-1:0] i_delta,
    input  logic                      i_g_lsb,
    input  logic        [ WORD_W-1:0] i_f_word,
    input  logic                      i_f_next_lsb,
    input  logic        [ WORD_W-1:0] i_g_word,
    input  logic                      i_g_next_lsb,
    input  logic        [ WORD_W-1:0] i_v_word,
    input  logic        [ WORD_W-1:0] i_v_prev_word,
    input  logic        [ WORD_W-1:0] i_w_word,
    input  logic        [ WORD_W-1:0] i_w_prev_word,
    output logic signed [DELTA_W-1:0] o_delta,
    output logic                      o_swap,
    output logic                      o_alpha,
    output logic        [ WORD_W-1:0] o_f_word,
    output logic        [ WORD_W-1:0] o_g_word,
    output logic        [ WORD_W-1:0] o_v_word,
    output logic        [ WORD_W-1:0] o_w_word
);

  logic signed [DELTA_W-1:0] delta_one_c;

  always_comb begin
    delta_one_c = 'd1;
    o_alpha = i_g_lsb;
    o_swap = (i_delta > 0) && i_g_lsb;
    o_delta = o_swap ? (-i_delta + delta_one_c) : (i_delta + delta_one_c);

    o_f_word = o_swap ? i_g_word : i_f_word;
    o_g_word = {
      o_alpha ? (i_g_next_lsb ^ i_f_next_lsb) : i_g_next_lsb,
      o_alpha ? (i_g_word[WORD_W-1:1] ^ i_f_word[WORD_W-1:1]) : i_g_word[WORD_W-1:1]
    };

    o_v_word = {
      o_swap ? i_w_word[WORD_W-2:0] : i_v_word[WORD_W-2:0],
      o_swap ? i_w_prev_word[WORD_W-1] : i_v_prev_word[WORD_W-1]
    };
    o_w_word = o_alpha ? (i_w_word ^ i_v_word) : i_w_word;
  end

`ifndef SYNTHESIS
  initial begin
    if (WORD_W < 2) $error("trike_poly_divstep_s1 WORD_W must be at least 2");
    if (DELTA_W < 3) $error("trike_poly_divstep_s1 DELTA_W must be at least 3");
  end
`endif

endmodule
