`timescale 1ns / 1ps
// RAM S stores packed v2c sign-bit words for one processing group.
module ram_s
  import bike_pkg::*;
#(
    parameter int RAM_S_PACK_W        = S_PACK_W,
    /* verilator lint_off UNUSEDPARAM */
    parameter int RAM_S_WORDS_PER_COL = S_WORDS_PER_COL,
    /* verilator lint_on UNUSEDPARAM */
    parameter int RAM_S_WORD_DEPTH    = S_WORD_DEPTH,
    parameter int RAM_S_WORD_ADDR_W   = S_WORD_ADDR_W
) (
    input  logic                         i_clk,
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

`ifdef BIKE_SIM_DEBUG
  logic [RAM_S_PACK_W-1:0] debug_words[0:RAM_S_WORD_DEPTH-1];
  localparam int RAM_S_PACK_SHIFT = (RAM_S_PACK_W > 1) ? $clog2(RAM_S_PACK_W) : 0;

  function automatic int debug_word_addr(input int col_idx, input int entry_idx);
    begin
      debug_word_addr = col_idx * RAM_S_WORDS_PER_COL + (entry_idx >> RAM_S_PACK_SHIFT);
    end
  endfunction

  function automatic int debug_bit_idx(input int entry_idx);
    begin
      debug_bit_idx = (RAM_S_PACK_W == 1) ? 0 : (entry_idx & (RAM_S_PACK_W - 1));
    end
  endfunction

  always_comb begin
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      for (int entry_idx = 0; entry_idx < RAM_LANE_DEPTH; entry_idx++) begin
        o_debug_mem[col_idx][entry_idx] =
            debug_words[debug_word_addr(col_idx, entry_idx)][debug_bit_idx(entry_idx)];
      end
    end
  end
`endif

`ifndef SYNTHESIS
  initial begin
    if ((RAM_S_PACK_W <= 0) || ((RAM_S_PACK_W & (RAM_S_PACK_W - 1)) != 0)) begin
      $fatal(1, "ram_s RAM_S_PACK_W must be a positive power of two");
    end
  end
`endif

  ram_1r1w_sync_read #(
      .DATA_W(RAM_S_PACK_W),
      .DEPTH(RAM_S_WORD_DEPTH),
      .ADDR_W(RAM_S_WORD_ADDR_W),
      .RESET_VALUE('0)
  ) u_mem (
      .i_clk(i_clk),
      .i_we(i_we),
      .i_write_addr(i_write_word_addr),
      .i_wdata(i_wdata),
      .i_read_addr(i_read_word_addr),
`ifdef BIKE_SIM_DEBUG
      .o_rdata(o_rdata),
      .o_debug_mem(debug_words)
`else
      .o_rdata(o_rdata)
`endif
  );
endmodule
