`timescale 1ns / 1ps

// Exhaustive functional proof for one characteristic-two divstep word update.
module trike_poly_divstep_s1_formal #(
    parameter int WORD_W  = 4,
    parameter int DELTA_W = 5
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
    input  logic        [ WORD_W-1:0] i_w_prev_word
);

  logic signed [DELTA_W-1:0] result_delta;
  logic                      result_swap;
  logic                      result_alpha;
  logic        [ WORD_W-1:0] result_f_word;
  logic        [ WORD_W-1:0] result_g_word;
  logic        [ WORD_W-1:0] result_v_word;
  logic        [ WORD_W-1:0] result_w_word;

  trike_poly_divstep_s1 #(
      .WORD_W (WORD_W),
      .DELTA_W(DELTA_W)
  ) u_dut (
      .i_delta      (i_delta),
      .i_g_lsb      (i_g_lsb),
      .i_f_word     (i_f_word),
      .i_f_next_lsb (i_f_next_lsb),
      .i_g_word     (i_g_word),
      .i_g_next_lsb (i_g_next_lsb),
      .i_v_word     (i_v_word),
      .i_v_prev_word(i_v_prev_word),
      .i_w_word     (i_w_word),
      .i_w_prev_word(i_w_prev_word),
      .o_delta      (result_delta),
      .o_swap       (result_swap),
      .o_alpha      (result_alpha),
      .o_f_word     (result_f_word),
      .o_g_word     (result_g_word),
      .o_v_word     (result_v_word),
      .o_w_word     (result_w_word)
  );

  always_comb begin
    assert (result_alpha == i_g_lsb);
    assert (result_swap == ((i_delta > 0) && i_g_lsb));
    assert (result_delta == (result_swap ? (-i_delta + DELTA_W'(1)) : (i_delta + DELTA_W'(1))));
    assert (result_f_word == (result_swap ? i_g_word : i_f_word));
    assert (result_g_word == {
      result_alpha ? (i_g_next_lsb ^ i_f_next_lsb) : i_g_next_lsb,
      result_alpha ? (i_g_word[WORD_W-1:1] ^ i_f_word[WORD_W-1:1]) :
                     i_g_word[WORD_W-1:1]
    });
    assert (result_v_word == {
      result_swap ? i_w_word[WORD_W-2:0] : i_v_word[WORD_W-2:0],
      result_swap ? i_w_prev_word[WORD_W-1] : i_v_prev_word[WORD_W-1]
    });
    assert (result_w_word == (result_alpha ? (i_w_word ^ i_v_word) : i_w_word));

    cover (result_swap);
    cover (!result_swap && result_alpha);
    cover (!result_alpha);
  end

endmodule
