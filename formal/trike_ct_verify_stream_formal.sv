`timescale 1ns / 1ps

// Two-trace noninterference proof for the fixed-control verification stream.
// The traces share only control and handshake inputs. Payloads, decoder status,
// and selected data differ arbitrarily; therefore their control outputs must
// remain identical after reset.
module trike_ct_verify_stream_formal #(
    parameter int WORD_COUNT = 3
) (
    input  logic       i_clk,
    input  logic       i_start,
    input  logic       i_reference_valid,
    input  logic       i_candidate_valid,
    input  logic       i_decoder_ok_a,
    input  logic       i_decoder_ok_b,
    input  logic [7:0] i_reference_data_a,
    input  logic [7:0] i_reference_data_b,
    input  logic [7:0] i_candidate_data_a,
    input  logic [7:0] i_candidate_data_b,
    input  logic [7:0] i_match_data_a,
    input  logic [7:0] i_match_data_b,
    input  logic [7:0] i_mismatch_data_a,
    input  logic [7:0] i_mismatch_data_b
);

  logic       i_rst_n = 1'b0;

  logic       reference_ready_a;
  logic       reference_ready_b;
  logic       candidate_ready_a;
  logic       candidate_ready_b;
  logic       equal_a;
  logic       equal_b;
  logic [7:0] selected_data_a;
  logic [7:0] selected_data_b;
  logic       busy_a;
  logic       busy_b;
  logic       done_a;
  logic       done_b;
  logic       decoder_fail_seen_q;

  trike_ct_verify_stream #(
      .WORD_W    (8),
      .WORD_COUNT(WORD_COUNT),
      .DATA_W    (8)
  ) u_trace_a (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_start             (i_start),
      .i_runtime_word_count('0),
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
      .WORD_W    (8),
      .WORD_COUNT(WORD_COUNT),
      .DATA_W    (8)
  ) u_trace_b (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_start             (i_start),
      .i_runtime_word_count('0),
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
      decoder_fail_seen_q <= 1'b0;
    end else if (i_start && !busy_a) begin
      decoder_fail_seen_q <= !i_decoder_ok_a;
    end
    assert (reference_ready_a == reference_ready_b);
    assert (candidate_ready_a == candidate_ready_b);
    assert (busy_a == busy_b);
    assert (done_a == done_b);
    cover (i_rst_n && busy_a && !(i_reference_valid && i_candidate_valid));
    cover (i_rst_n && done_a);
    cover (i_rst_n && done_a && !equal_a);
    cover (i_rst_n && done_a && decoder_fail_seen_q && !equal_a);
  end

endmodule
