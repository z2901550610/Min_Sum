`timescale 1ns / 1ps
// Banked v2c sign storage indexed by edge and tile word.
module msg_sign_ram
  import bike_pkg::*;
(
    input  logic                  i_clk,
    input  logic                  i_rst_n,
    input  logic                  i_c2v_valid[0:L-1],
    input  logic [TILE_IDX_W-1:0] i_c2v_tile_idx,
    input  logic [TILE_OFF_W-1:0] i_c2v_tile_offset[0:L-1],
    input  logic [ EDGE_ID_W-1:0] i_c2v_edge_id[0:L-1],
    output logic                  o_c2v_sign[0:L-1],
    input  logic                  i_v2c_phase_valid,
    input  logic [TILE_IDX_W-1:0] i_v2c_tile_idx,
    input  logic [   Q_SEQ_W-1:0] i_v2c_q_seq,
    input  logic [ EDGE_ID_W-1:0] i_v2c_edge_id,
    input  logic                  i_v2c_write_valid[0:L-1],
    input  logic [TILE_OFF_W-1:0] i_v2c_tile_offset[0:L-1],
    input  logic                  i_v2c_sign[0:L-1]
);

  localparam int SIGN_WORD_W = Q_BASE;
  localparam int SIGN_WORD_AW = (SIGN_WORD_W > 1) ? $clog2(SIGN_WORD_W) : 1;
  localparam int SIGN_BANK_DEPTH = ROW_EDGE_COUNT * TILE_COUNT;
  localparam int SIGN_BANK_AW = (SIGN_BANK_DEPTH > 1) ? $clog2(SIGN_BANK_DEPTH) : 1;

  function automatic logic [SIGN_BANK_AW-1:0] edge_base(input  logic [EDGE_ID_W-1:0] edge_id);
    logic [SIGN_BANK_AW-1:0] acc;
    begin
      acc = '0;
      for (int bit_idx = 0; bit_idx < SIGN_BANK_AW; bit_idx++) begin
        if (((TILE_COUNT >> bit_idx) & 1) != 0) begin
          acc = acc + (SIGN_BANK_AW'(edge_id) << bit_idx);
        end
      end
      edge_base = acc;
    end
  endfunction

  function automatic logic [SIGN_BANK_AW-1:0] bank_addr(input  logic [EDGE_ID_W-1:0] edge_id,
                                                        input  logic [TILE_IDX_W-1:0] tile_idx);
    begin
      bank_addr = edge_base(edge_id) + SIGN_BANK_AW'(tile_idx);
    end
  endfunction

  function automatic logic [SIGN_WORD_AW-1:0] word_bit(input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      word_bit = SIGN_WORD_AW'(tile_offset >> L_SHIFT);
    end
  endfunction

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      (* ram_style = "block" *) logic [ SIGN_WORD_W-1:0] mem[0:SIGN_BANK_DEPTH-1];
      logic [SIGN_BANK_AW-1:0] bank_raddr;
      logic [SIGN_WORD_AW-1:0] bank_rbit;
      logic                    bank_we;
      logic [SIGN_BANK_AW-1:0] bank_waddr;
      logic [SIGN_WORD_AW-1:0] bank_wbit;
      logic [ SIGN_WORD_W-1:0] bank_word_q;
      logic [ SIGN_WORD_W-1:0] bank_word_next;
      logic                    bank_word_start;
      logic                    bank_word_flush;

      always_comb begin
        bank_raddr = '0;
        bank_rbit = '0;
        bank_waddr = bank_addr(i_v2c_edge_id, i_v2c_tile_idx);
        bank_wbit = '0;
        bank_word_start = i_v2c_phase_valid && (i_v2c_q_seq == '0);
        bank_word_flush = i_v2c_phase_valid && (i_v2c_q_seq == Q_SEQ_W'(Q_TILE - 1));
        bank_we = bank_word_flush;
        bank_word_next = bank_word_start ? '0 : bank_word_q;
        if (i_c2v_valid[bank_idx]) begin
          bank_raddr = bank_addr(i_c2v_edge_id[bank_idx], i_c2v_tile_idx);
          bank_rbit  = word_bit(i_c2v_tile_offset[bank_idx]);
        end
        if (i_v2c_write_valid[bank_idx]) begin
          bank_wbit = word_bit(i_v2c_tile_offset[bank_idx]);
          bank_word_next[bank_wbit] = i_v2c_sign[bank_idx];
        end
      end

      always_ff @(posedge i_clk) begin
        o_c2v_sign[bank_idx] <= i_c2v_valid[bank_idx] ? mem[bank_raddr][bank_rbit] : 1'b0;
        if (bank_we) begin
          mem[bank_waddr] <= bank_word_next;
        end
      end

      always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
          bank_word_q <= '0;
        end else begin
          bank_word_q <= bank_we ? '0 : bank_word_next;
        end
      end
    end
  endgenerate
endmodule
