`timescale 1ns / 1ps
// Generic synchronous-write, combinational-read RAM/register-file primitive.
module ram_1r1w_async_read #(
    parameter int    DATA_W    = 1,
    parameter int    DEPTH     = 2,
    parameter int    ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter string INIT_FILE = ""
) (
    input  logic              i_clk,
    input  logic              i_we,
    input  logic [ADDR_W-1:0] i_write_addr,
    input  logic [DATA_W-1:0] i_wdata,
    input  logic [ADDR_W-1:0] i_read_addr,
    output logic [DATA_W-1:0] o_rdata,
    output logic [DATA_W-1:0] o_debug_mem[0:DEPTH-1]
);

  logic [DATA_W-1:0] mem[0:DEPTH-1];

  assign o_rdata = mem[i_read_addr];

  always_comb begin
    for (int addr = 0; addr < DEPTH; addr++) begin
      o_debug_mem[addr] = mem[addr];
    end
  end

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end
  end

  always_ff @(posedge i_clk) begin
    if (i_we) begin
      mem[i_write_addr] <= i_wdata;
    end
  end
endmodule
