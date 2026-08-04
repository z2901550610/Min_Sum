`timescale 1ns / 1ps

// Fixed 32-byte pseudohash512 wrapper for shared-SM3 implementation reports.
module trike_pseudohash_synth_top (
    input  logic        i_clk,
    input  logic        i_rst_n,
    input  logic        i_start,
    input  logic        i_input_valid,
    input  logic [ 7:0] i_input_data,
    output logic        o_input_ready,
    output logic        o_input_pass,
    output logic        o_busy,
    output logic        o_done,
    output logic        o_result_valid,
    output logic [63:0] o_result_data,
    output logic        o_result_last,
    input  logic        i_result_ready
);

  logic         rst_n_sync;
  logic         pseudohash_start;
  logic         pseudohash_busy;
  logic         pseudohash_done;
  logic [511:0] digest;
  logic         result_valid_q;
  logic [  2:0] result_word_q;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  assign pseudohash_start = i_start && !pseudohash_busy && !result_valid_q;
  assign o_busy           = pseudohash_busy || result_valid_q;
  assign o_result_valid   = result_valid_q;
  assign o_result_data    = digest[511-64*result_word_q-:64];
  assign o_result_last    = result_word_q == 3'd7;

  always_ff @(posedge i_clk) begin
    if (!rst_n_sync) begin
      result_valid_q <= 1'b0;
      result_word_q  <= '0;
      o_done         <= 1'b0;
    end else begin
      o_done <= 1'b0;
      if (pseudohash_done) begin
        result_valid_q <= 1'b1;
        result_word_q  <= '0;
      end else if (result_valid_q && i_result_ready) begin
        if (result_word_q == 3'd7) begin
          result_valid_q <= 1'b0;
          o_done         <= 1'b1;
        end else begin
          result_word_q <= result_word_q + 1'b1;
        end
      end
    end
  end

  /* verilator lint_off PINCONNECTEMPTY */
  trike_pseudohash512_stream #(
      .MESSAGE_BYTES(32)
  ) u_pseudohash (
      .i_clk           (i_clk),
      .i_rst_n         (rst_n_sync),
      .i_start         (pseudohash_start),
      .i_input_valid   (i_input_valid),
      .i_input_data    (i_input_data),
      .o_input_ready   (o_input_ready),
      .o_input_pass    (o_input_pass),
      .o_busy          (pseudohash_busy),
      .o_done          (pseudohash_done),
      .o_digest        (digest),
      .o_compress_start(),
      .o_compress_block(),
      .o_compress_state(),
      .i_compress_busy (1'b0),
      .i_compress_done (1'b0),
      .i_compress_state('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

endmodule
