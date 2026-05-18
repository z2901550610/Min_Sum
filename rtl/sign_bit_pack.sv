`timescale 1ns / 1ps
// Packs sequential sign bits into RAM-S words and shifts RAM-S words for reads.
module sign_bit_pack #(
    parameter int PACK_W  = 8,
    parameter int INDEX_W = (PACK_W > 1) ? $clog2(PACK_W) : 1
) (
    input  logic               i_clk,
    input  logic               i_rst_n,
    input  logic               i_clear,
    input  logic               i_read_shift,
    input  logic               i_load_read_word,
    input  logic [ PACK_W-1:0] i_read_word,
    input  logic               i_write_en,
    input  logic [INDEX_W-1:0] i_write_bit_idx,
    input  logic               i_write_bit,
    input  logic               i_flush_write_word,
    output logic               o_read_bit,
    output logic [ PACK_W-1:0] o_write_word
);

  logic [PACK_W-1:0] read_shift;
  logic [PACK_W-1:0] write_shift;
  logic [PACK_W-1:0] write_word_next;

  assign o_read_bit   = i_load_read_word ? i_read_word[0] : read_shift[0];
  assign o_write_word = write_word_next;

  always_comb begin
    write_word_next = write_shift;
    if (i_write_en) begin
      write_word_next[i_write_bit_idx] = i_write_bit;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n || i_clear) begin
      read_shift  <= '0;
      write_shift <= '0;
    end else begin
      if (i_load_read_word) begin
        read_shift <= {{1{1'b0}}, i_read_word[PACK_W-1:1]};
      end else if (i_read_shift) begin
        read_shift <= {{1{1'b0}}, read_shift[PACK_W-1:1]};
      end

      if (i_write_en) begin
        write_shift[i_write_bit_idx] <= i_write_bit;
      end

      if (i_flush_write_word) begin
        write_shift <= '0;
      end
    end
  end
endmodule
