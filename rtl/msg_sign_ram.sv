`timescale 1ns / 1ps
// Banked v2c sign storage indexed by edge and packed column word.
module msg_sign_ram
  import bike_pkg::*;
(
    input  logic                  i_clk,
    input  logic                  i_c2v_valid[0:L-1],
    input  logic [TILE_IDX_W-1:0] i_c2v_tile_idx,
    input  logic [TILE_OFF_W-1:0] i_c2v_tile_offset[0:L-1],
    input  logic [ EDGE_ID_W-1:0] i_c2v_edge_id[0:L-1],
    output logic                  o_c2v_sign[0:L-1],
    input  logic                  i_v2c_write_valid[0:L-1],
    input  logic [TILE_IDX_W-1:0] i_v2c_write_tile_idx,
    input  logic [TILE_OFF_W-1:0] i_v2c_write_tile_offset[0:L-1],
    input  logic [ EDGE_ID_W-1:0] i_v2c_edge_id[0:L-1],
    input  logic                  i_v2c_sign[0:L-1]
);

  localparam int SIGN_WORD_W = 36;
  localparam int SIGN_WORDS_PER_EDGE = (ROW_SEG_SIZE + SIGN_WORD_W - 1) / SIGN_WORD_W;
  localparam int SIGN_BANK_DEPTH = ROW_EDGE_COUNT * SIGN_WORDS_PER_EDGE;
  localparam int SIGN_BANK_AW = (SIGN_BANK_DEPTH > 1) ? $clog2(SIGN_BANK_DEPTH) : 1;
  localparam int SIGN_BIT_IDX_W = $clog2(SIGN_WORD_W);

  function automatic logic [SIGN_BANK_AW-1:0] edge_base(input  logic [EDGE_ID_W-1:0] edge_id);
    logic [SIGN_BANK_AW-1:0] acc;
    begin
      acc = '0;
      for (int bit_idx = 0; bit_idx < SIGN_BANK_AW; bit_idx++) begin
        if (((SIGN_WORDS_PER_EDGE >> bit_idx) & 1) != 0) begin
          acc = acc + (SIGN_BANK_AW'(edge_id) << bit_idx);
        end
      end
      edge_base = acc;
    end
  endfunction

  function automatic int col_group(input  logic [TILE_IDX_W-1:0] tile_idx,
                                   input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      col_group = (int'(tile_idx) * Q_BASE) + (int'(tile_offset) >> L_SHIFT);
    end
  endfunction

  function automatic logic [SIGN_BANK_AW-1:0] col_word(input  logic [TILE_IDX_W-1:0] tile_idx,
                                                       input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      col_word = SIGN_BANK_AW'(col_group(tile_idx, tile_offset) / SIGN_WORD_W);
    end
  endfunction

  function automatic logic [SIGN_BIT_IDX_W-1:0] col_bit(input  logic [TILE_IDX_W-1:0] tile_idx,
                                                        input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      col_bit = SIGN_BIT_IDX_W'(col_group(tile_idx, tile_offset) % SIGN_WORD_W);
    end
  endfunction

  function automatic logic [SIGN_BANK_AW-1:0] bank_addr(input  logic [EDGE_ID_W-1:0] edge_id,
                                                        input  logic [TILE_IDX_W-1:0] tile_idx,
                                                        input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      bank_addr = edge_base(edge_id) + col_word(tile_idx, tile_offset);
    end
  endfunction

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      (* ram_style = "block" *) logic [   SIGN_WORD_W-1:0] mem[0:SIGN_BANK_DEPTH-1];
      logic [  SIGN_BANK_AW-1:0] bank_raddr;
      logic [SIGN_BIT_IDX_W-1:0] bank_rbit;
      logic                      bank_we;
      logic [  SIGN_BANK_AW-1:0] bank_waddr;
      logic [SIGN_BIT_IDX_W-1:0] bank_wbit;
      logic                      bank_wdata;

      always_comb begin
        bank_raddr = '0;
        bank_rbit = '0;
        bank_we = 1'b0;
        bank_waddr = '0;
        bank_wbit = '0;
        bank_wdata = 1'b0;
        if (i_c2v_valid[bank_idx]) begin
          bank_raddr =
              bank_addr(i_c2v_edge_id[bank_idx], i_c2v_tile_idx, i_c2v_tile_offset[bank_idx]);
          bank_rbit = col_bit(i_c2v_tile_idx, i_c2v_tile_offset[bank_idx]);
        end
        if (i_v2c_write_valid[bank_idx]) begin
          bank_we = 1'b1;
          bank_waddr = bank_addr(i_v2c_edge_id[bank_idx], i_v2c_write_tile_idx,
                                 i_v2c_write_tile_offset[bank_idx]);
          bank_wbit = col_bit(i_v2c_write_tile_idx, i_v2c_write_tile_offset[bank_idx]);
          bank_wdata = i_v2c_sign[bank_idx];
        end
      end

      always_ff @(posedge i_clk) begin
        o_c2v_sign[bank_idx] <= i_c2v_valid[bank_idx] ? mem[bank_raddr][bank_rbit] : 1'b0;
        if (bank_we) begin
          mem[bank_waddr][bank_wbit] <= bank_wdata;
        end
      end
    end
  endgenerate
endmodule
