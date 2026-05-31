`timescale 1ns / 1ps
// RAM-S stores one W-bit v2c sign vector for each variable column.
module ram_s
  import bike_pkg::*;
(
    input  logic                     i_clk,
    input  logic                     i_we,
    input  logic [S_WORD_ADDR_W-1:0] i_read_col_idx,
    input  logic [S_WORD_ADDR_W-1:0] i_write_col_idx,
    input  logic [     S_WORD_W-1:0] i_wdata,
`ifdef BIKE_SIM_DEBUG
    output logic [     S_WORD_W-1:0] o_rdata,
    output logic                     o_debug_mem[0:N-1][0:W-1]
`else
    output logic [     S_WORD_W-1:0] o_rdata
`endif
);

`ifdef BIKE_SIM_DEBUG
  logic [S_WORD_W-1:0] debug_words[0:S_WORD_DEPTH-1];

  always_comb begin
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      for (int one_idx = 0; one_idx < W; one_idx++) begin
        o_debug_mem[col_idx][one_idx] = debug_words[col_idx][one_idx];
      end
    end
  end
`endif

  ram_1r1w_sync_read #(
      .DATA_W(S_WORD_W),
      .DEPTH(S_WORD_DEPTH),
      .ADDR_W(S_WORD_ADDR_W),
      .RESET_VALUE('0)
  ) u_mem (
      .i_clk(i_clk),
      .i_we(i_we),
      .i_write_addr(i_write_col_idx),
      .i_wdata(i_wdata),
      .i_read_addr(i_read_col_idx),
`ifdef BIKE_SIM_DEBUG
      .o_rdata(o_rdata),
      .o_debug_mem(debug_words)
`else
      .o_rdata(o_rdata)
`endif
  );
endmodule
