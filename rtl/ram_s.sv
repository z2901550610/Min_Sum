`timescale 1ns / 1ps
// RAM S stores packed v2c sign-bit words for one processing group.
module ram_s
  import bike_pkg::*;
#(
    parameter int RAM_S_PACK_W        = S_PACK_W,
    parameter int RAM_S_WORDS_PER_COL = S_WORDS_PER_COL,
    parameter int RAM_S_WORD_DEPTH    = S_WORD_DEPTH,
    parameter int RAM_S_WORD_ADDR_W   = S_WORD_ADDR_W
) (
    input  logic                         i_clk,
    input  logic                         i_rst_n,
    input  logic                         i_we,
    input  logic [RAM_S_WORD_ADDR_W-1:0] i_read_word_addr,
`ifdef BIKE_SIM_DEBUG
    input  logic [RAM_S_WORD_ADDR_W-1:0] i_write_word_addr,
    input  logic [     RAM_S_PACK_W-1:0] i_wdata,
    output logic [     RAM_S_PACK_W-1:0] o_rdata,
    output logic                         o_debug_mem[0:N-1][0:RAM_LANE_DEPTH-1]
`else
    input  logic [RAM_S_WORD_ADDR_W-1:0] i_write_word_addr,
    input  logic [     RAM_S_PACK_W-1:0] i_wdata,
    output logic [     RAM_S_PACK_W-1:0] o_rdata
`endif
);

  (* ram_style = "block" *) logic [RAM_S_PACK_W-1:0] mem[0:RAM_S_WORD_DEPTH-1];

  function automatic int debug_word_addr(input int col_idx, input int entry_idx);
    begin
      debug_word_addr = col_idx * RAM_S_WORDS_PER_COL + (entry_idx / RAM_S_PACK_W);
    end
  endfunction

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      for (int entry_idx = 0; entry_idx < RAM_LANE_DEPTH; entry_idx++) begin
        o_debug_mem[col_idx][entry_idx] =
            mem[debug_word_addr(col_idx, entry_idx)][entry_idx%RAM_S_PACK_W];
      end
    end
  end
`endif

  initial begin
    if ((RAM_S_PACK_W <= 0) || ((RAM_S_PACK_W & (RAM_S_PACK_W - 1)) != 0)) begin
      $fatal(1, "ram_s RAM_S_PACK_W must be a positive power of two");
    end
  end

`ifdef BIKE_SIM_DEBUG
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= '0;
      for (int word_addr = 0; word_addr < RAM_S_WORD_DEPTH; word_addr++) begin
        mem[word_addr] <= '0;
      end
    end else begin
      if (i_we) begin
        mem[i_write_word_addr] <= i_wdata;
      end
      o_rdata <= mem[i_read_word_addr];
    end
  end
`else
  always_ff @(posedge i_clk) begin
    if (i_we) begin
      mem[i_write_word_addr] <= i_wdata;
    end
    o_rdata <= mem[i_read_word_addr];
  end
`endif
endmodule
