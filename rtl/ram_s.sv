`timescale 1ns/1ps
// RAM S stores packed v2c sign-bit words for one processing group.
module ram_s
  import bike_pkg::*;
#(
  parameter int S_PACK_W = 8,
  parameter int S_WORDS_PER_COL = (ENTRY_DEPTH + S_PACK_W - 1) / S_PACK_W,
  parameter int S_WORD_DEPTH = N * S_WORDS_PER_COL,
  parameter int S_WORD_ADDR_W = (S_WORD_DEPTH > 1) ? $clog2(S_WORD_DEPTH) : 1
)
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_we,
  input  logic [S_WORD_ADDR_W-1:0] i_read_word_addr,
  input  logic [S_WORD_ADDR_W-1:0] i_write_word_addr,
  input  logic [S_PACK_W-1:0] i_wdata,
  output logic [S_PACK_W-1:0] o_rdata
`ifdef BIKE_SIM_DEBUG
  ,
  output logic o_debug_mem [0:N-1][0:ENTRY_DEPTH-1]
`endif
);

  (* ram_style = "block" *) logic [S_PACK_W-1:0] mem [0:S_WORD_DEPTH-1];

  function automatic int debug_word_addr(input int col_idx, input int entry_idx);
    begin
      debug_word_addr = col_idx * S_WORDS_PER_COL + (entry_idx / S_PACK_W);
    end
  endfunction

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      for (int entry_idx = 0; entry_idx < ENTRY_DEPTH; entry_idx++) begin
        o_debug_mem[col_idx][entry_idx] =
          mem[debug_word_addr(col_idx, entry_idx)][entry_idx % S_PACK_W];
      end
    end
  end
`endif

  initial begin
    if ((S_PACK_W <= 0) || ((S_PACK_W & (S_PACK_W - 1)) != 0)) begin
      $fatal(1, "ram_s S_PACK_W must be a positive power of two");
    end
  end

`ifdef BIKE_SIM_DEBUG
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= '0;
      for (int word_addr = 0; word_addr < S_WORD_DEPTH; word_addr++) begin
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
