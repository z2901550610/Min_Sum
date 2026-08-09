`timescale 1ns / 1ps

// Fixed-length streaming comparison and implicit-rejection selection.
//
// Both input streams transfer together. The controller always consumes
// WORD_COUNT word pairs before producing a result, independent of the first
// mismatch position and of i_decoder_ok. Input backpressure may extend the
// outer transaction, but it does not change the number of accepted words.
module trike_ct_verify_stream #(
    parameter int WORD_W     = 64,
    parameter int WORD_COUNT = 1,
    parameter int DATA_W     = 256
) (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_start,
    input  logic              i_decoder_ok,
    input  logic [WORD_W-1:0] i_reference_data,
    input  logic              i_reference_valid,
    output logic              o_reference_ready,
    input  logic [WORD_W-1:0] i_candidate_data,
    input  logic              i_candidate_valid,
    output logic              o_candidate_ready,
    input  logic [DATA_W-1:0] i_match_data,
    input  logic [DATA_W-1:0] i_mismatch_data,
    output logic              o_equal,
    output logic [DATA_W-1:0] o_selected_data,
    output logic              o_busy,
    output logic              o_done
);

  localparam int COUNT_W = (WORD_COUNT > 1) ? $clog2(WORD_COUNT) : 1;

  typedef enum logic {
    ST_IDLE,
    ST_COMPARE
  } state_t;

  state_t               state_q;
  logic   [COUNT_W-1:0] word_count_q;
  logic                 difference_q;
  logic                 decoder_ok_q;
  logic   [ DATA_W-1:0] match_data_q;
  logic   [ DATA_W-1:0] mismatch_data_q;
  logic                 final_difference_c;
  logic   [        1:0] compare_a_c;
  logic                 select_equal_c;
  logic   [ DATA_W-1:0] selected_data_c;

  assign o_reference_ready = (state_q == ST_COMPARE) && i_candidate_valid;
  assign o_candidate_ready = (state_q == ST_COMPARE) && i_reference_valid;
  assign o_busy = (state_q != ST_IDLE);

  always_comb begin
    final_difference_c = difference_q | |(i_reference_data ^ i_candidate_data);
    compare_a_c = {decoder_ok_q, ~final_difference_c};
  end

  kem_ct_compare_select #(
      .COMPARE_W(2),
      .DATA_W   (DATA_W)
  ) u_select (
      .i_compare_a    (compare_a_c),
      .i_compare_b    (2'b11),
      .i_match_data   (match_data_q),
      .i_mismatch_data(mismatch_data_q),
      .o_equal        (select_equal_c),
      .o_selected_data(selected_data_c)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q         <= ST_IDLE;
      word_count_q    <= '0;
      difference_q    <= 1'b0;
      decoder_ok_q    <= 1'b0;
      match_data_q    <= '0;
      mismatch_data_q <= '0;
      o_equal         <= 1'b0;
      o_selected_data <= '0;
      o_done          <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            word_count_q    <= '0;
            difference_q    <= 1'b0;
            decoder_ok_q    <= i_decoder_ok;
            match_data_q    <= i_match_data;
            mismatch_data_q <= i_mismatch_data;
            state_q         <= ST_COMPARE;
          end
        end

        ST_COMPARE: begin
          if (i_reference_valid && i_candidate_valid) begin
            difference_q <= final_difference_c;
            if (word_count_q == COUNT_W'(WORD_COUNT - 1)) begin
              o_equal         <= select_equal_c;
              o_selected_data <= selected_data_c;
              o_done          <= 1'b1;
              state_q         <= ST_IDLE;
            end else begin
              word_count_q <= word_count_q + 1'b1;
            end
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  initial begin
    if (WORD_COUNT <= 0) $fatal(1, "trike_ct_verify_stream requires WORD_COUNT > 0");
  end

endmodule
