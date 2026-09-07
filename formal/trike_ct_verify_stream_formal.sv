`timescale 1ns / 1ps

// Two-trace noninterference and functional proof for the verification stream.
// The traces share only public control and handshake inputs. Payloads, decoder
// status, and selected data differ arbitrarily; their control outputs remain
// identical while each result matches an independent accepted-word model.
module trike_ct_verify_stream_formal #(
    parameter int WORD_COUNT    = 3,
    parameter bit RUNTIME_COUNT = 1'b0
) (
    input  logic        i_start,
    input  logic [31:0] i_runtime_word_count,
    input  logic        i_reference_valid,
    input  logic        i_candidate_valid,
    input  logic        i_decoder_ok_a,
    input  logic        i_decoder_ok_b,
    input  logic [ 7:0] i_reference_data_a,
    input  logic [ 7:0] i_reference_data_b,
    input  logic [ 7:0] i_candidate_data_a,
    input  logic [ 7:0] i_candidate_data_b,
    input  logic [ 7:0] i_match_data_a,
    input  logic [ 7:0] i_match_data_b,
    input  logic [ 7:0] i_mismatch_data_a,
    input  logic [ 7:0] i_mismatch_data_b
);

  (* gclk *) logic        i_clk;
  logic        i_rst_n = 1'b0;

  logic        reference_ready_a;
  logic        reference_ready_b;
  logic        candidate_ready_a;
  logic        candidate_ready_b;
  logic        equal_a;
  logic        equal_b;
  logic [ 7:0] selected_data_a;
  logic [ 7:0] selected_data_b;
  logic        busy_a;
  logic        busy_b;
  logic        done_a;
  logic        done_b;
  logic        transaction_active_q;
  logic [31:0] accepted_word_count_q;
  logic [31:0] active_word_count_q;
  logic        expected_difference_a_q;
  logic        expected_difference_b_q;
  logic        expected_decoder_ok_a_q;
  logic        expected_decoder_ok_b_q;
  logic [ 7:0] expected_match_data_a_q;
  logic [ 7:0] expected_match_data_b_q;
  logic [ 7:0] expected_mismatch_data_a_q;
  logic [ 7:0] expected_mismatch_data_b_q;
  logic        expected_equal_a;
  logic        expected_equal_b;

  assign expected_equal_a = expected_decoder_ok_a_q && !expected_difference_a_q;
  assign expected_equal_b = expected_decoder_ok_b_q && !expected_difference_b_q;

  trike_ct_verify_stream #(
      .WORD_W       (8),
      .WORD_COUNT   (WORD_COUNT),
      .DATA_W       (8),
      .RUNTIME_COUNT(RUNTIME_COUNT)
  ) u_trace_a (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_start             (i_start),
      .i_runtime_word_count(i_runtime_word_count),
      .i_decoder_ok        (i_decoder_ok_a),
      .i_reference_data    (i_reference_data_a),
      .i_reference_valid   (i_reference_valid),
      .o_reference_ready   (reference_ready_a),
      .i_candidate_data    (i_candidate_data_a),
      .i_candidate_valid   (i_candidate_valid),
      .o_candidate_ready   (candidate_ready_a),
      .i_match_data        (i_match_data_a),
      .i_mismatch_data     (i_mismatch_data_a),
      .o_equal             (equal_a),
      .o_selected_data     (selected_data_a),
      .o_busy              (busy_a),
      .o_done              (done_a)
  );

  trike_ct_verify_stream #(
      .WORD_W       (8),
      .WORD_COUNT   (WORD_COUNT),
      .DATA_W       (8),
      .RUNTIME_COUNT(RUNTIME_COUNT)
  ) u_trace_b (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_start             (i_start),
      .i_runtime_word_count(i_runtime_word_count),
      .i_decoder_ok        (i_decoder_ok_b),
      .i_reference_data    (i_reference_data_b),
      .i_reference_valid   (i_reference_valid),
      .o_reference_ready   (reference_ready_b),
      .i_candidate_data    (i_candidate_data_b),
      .i_candidate_valid   (i_candidate_valid),
      .o_candidate_ready   (candidate_ready_b),
      .i_match_data        (i_match_data_b),
      .i_mismatch_data     (i_mismatch_data_b),
      .o_equal             (equal_b),
      .o_selected_data     (selected_data_b),
      .o_busy              (busy_b),
      .o_done              (done_b)
  );

  always_ff @(posedge i_clk) begin
    i_rst_n <= 1'b1;
    if (!i_rst_n) begin
      assume (!i_start);
      transaction_active_q       <= 1'b0;
      accepted_word_count_q      <= '0;
      active_word_count_q        <= '0;
      expected_difference_a_q    <= 1'b0;
      expected_difference_b_q    <= 1'b0;
      expected_decoder_ok_a_q    <= 1'b0;
      expected_decoder_ok_b_q    <= 1'b0;
      expected_match_data_a_q    <= '0;
      expected_match_data_b_q    <= '0;
      expected_mismatch_data_a_q <= '0;
      expected_mismatch_data_b_q <= '0;
    end else begin
      if (done_a) begin
        transaction_active_q  <= 1'b0;
        accepted_word_count_q <= '0;
      end
      if (i_start && !busy_a) begin
        if (RUNTIME_COUNT) begin
          assume (i_runtime_word_count >= 1);
          assume (i_runtime_word_count <= WORD_COUNT);
          active_word_count_q <= i_runtime_word_count;
        end else begin
          active_word_count_q <= WORD_COUNT;
        end
        transaction_active_q       <= 1'b1;
        accepted_word_count_q      <= '0;
        expected_difference_a_q    <= 1'b0;
        expected_difference_b_q    <= 1'b0;
        expected_decoder_ok_a_q    <= i_decoder_ok_a;
        expected_decoder_ok_b_q    <= i_decoder_ok_b;
        expected_match_data_a_q    <= i_match_data_a;
        expected_match_data_b_q    <= i_match_data_b;
        expected_mismatch_data_a_q <= i_mismatch_data_a;
        expected_mismatch_data_b_q <= i_mismatch_data_b;
      end else if (transaction_active_q && busy_a && i_reference_valid && i_candidate_valid) begin
        accepted_word_count_q <= accepted_word_count_q + 1'b1;
        expected_difference_a_q <=
            expected_difference_a_q | |(i_reference_data_a ^ i_candidate_data_a);
        expected_difference_b_q <=
            expected_difference_b_q | |(i_reference_data_b ^ i_candidate_data_b);
      end
    end
    assert (reference_ready_a == reference_ready_b);
    assert (candidate_ready_a == candidate_ready_b);
    assert (busy_a == busy_b);
    assert (done_a == done_b);
    if (i_rst_n) begin
      assert (done_a == (transaction_active_q && (accepted_word_count_q == active_word_count_q)));
      if (transaction_active_q) assert (accepted_word_count_q <= active_word_count_q);
      if (done_a) begin
        assert (equal_a == expected_equal_a);
        assert (equal_b == expected_equal_b);
        assert (selected_data_a ==
                (expected_equal_a ? expected_match_data_a_q : expected_mismatch_data_a_q));
        assert (selected_data_b ==
                (expected_equal_b ? expected_match_data_b_q : expected_mismatch_data_b_q));
      end
    end
    cover (i_rst_n && busy_a && !(i_reference_valid && i_candidate_valid));
    cover (i_rst_n && done_a);
    cover (i_rst_n && done_a && equal_a);
    cover (i_rst_n && done_a && expected_decoder_ok_a_q && expected_difference_a_q && !equal_a);
    cover (i_rst_n && done_a && !expected_decoder_ok_a_q && !equal_a);
    cover (i_rst_n && done_a && equal_a && !equal_b);
  end

  if (RUNTIME_COUNT) begin : g_runtime_cover
    always_ff @(posedge i_clk) begin
      cover (i_rst_n && done_a && (active_word_count_q == 1));
      cover (i_rst_n && done_a && (active_word_count_q == WORD_COUNT));
    end
  end

endmodule
