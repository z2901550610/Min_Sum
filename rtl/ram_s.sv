`timescale 1ns/1ps
// RAM S stores packed v2c sign bits for one processing group.
module ram_s
  import bike_pkg::*;
#(
  parameter int S_PACK_W = 8
)
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_we,
  input  logic [COL_W-1:0] i_read_col_idx,
  input  logic [ENTRY_POS_W-1:0] i_read_entry_idx,
  input  logic [COL_W-1:0] i_write_col_idx,
  input  logic [ENTRY_POS_W-1:0] i_write_entry_idx,
  input  logic i_wdata,
  output logic o_rdata,
  output logic o_debug_mem [0:N-1][0:RAM_LANE_DEPTH-1]
);

  localparam int S_PACK_STORAGE_W = (S_PACK_W > 0) ? S_PACK_W : 1;
  localparam int S_PACK_WORDS = (RAM_LANE_DEPTH + S_PACK_STORAGE_W - 1) / S_PACK_STORAGE_W;
  localparam int S_MEM_DEPTH = N * S_PACK_WORDS;

  (* ram_style = "block" *) logic [S_PACK_STORAGE_W-1:0] mem [0:S_MEM_DEPTH-1];

  function automatic int mem_addr(
    input logic [COL_W-1:0] col_idx,
    input logic [ENTRY_POS_W-1:0] entry_idx
  );
    begin
      mem_addr = int'(col_idx) * S_PACK_WORDS + (int'(entry_idx) / S_PACK_STORAGE_W);
    end
  endfunction

`ifndef SYNTHESIS
  always_comb begin
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      for (int entry_idx = 0; entry_idx < RAM_LANE_DEPTH; entry_idx++) begin
        o_debug_mem[col_idx][entry_idx] =
          mem[col_idx * S_PACK_WORDS + (entry_idx / S_PACK_STORAGE_W)][entry_idx % S_PACK_STORAGE_W];
      end
    end
  end
`else
  always_comb begin
    for (int col_idx = 0; col_idx < N; col_idx++) begin
      for (int entry_idx = 0; entry_idx < RAM_LANE_DEPTH; entry_idx++) begin
        o_debug_mem[col_idx][entry_idx] = 1'b0;
      end
    end
  end
`endif

  initial begin
    if ((S_PACK_W <= 0) || ((S_PACK_W & (S_PACK_W - 1)) != 0)) begin
      $fatal(1, "ram_s S_PACK_W must be a positive power of two");
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= 1'b0;
`ifndef SYNTHESIS
      for (int addr = 0; addr < S_MEM_DEPTH; addr++) begin
        mem[addr] <= '0;
      end
`endif
    end else begin
      if (i_we) begin
        mem[mem_addr(i_write_col_idx, i_write_entry_idx)]
           [int'(i_write_entry_idx) % S_PACK_STORAGE_W] <= i_wdata;
      end
      o_rdata <= mem[mem_addr(i_read_col_idx, i_read_entry_idx)]
                    [int'(i_read_entry_idx) % S_PACK_STORAGE_W];
    end
  end
endmodule
