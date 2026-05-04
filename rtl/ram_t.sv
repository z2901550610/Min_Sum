`timescale 1ns/1ps
// RAM T — stores cached c2v messages for one processing group.
module ram_t
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_we,
  input  logic [ONE_IDX_W-1:0] i_entry_pos,
  input  logic [MSG_W-1:0] i_wdata,
  output logic [MSG_W-1:0] o_rdata,
  output logic [MSG_W-1:0] o_debug_mem [0:W-1]
);

  logic [MSG_W-1:0] mem [0:W-1];

  assign o_debug_mem = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= '0;
      for (int entry_pos = 0; entry_pos < W; entry_pos++) begin
        mem[entry_pos] <= '0;
      end
    end else begin
      if (i_we) begin
        mem[i_entry_pos] <= i_wdata;
      end
      o_rdata <= mem[i_entry_pos];
    end
  end
endmodule
