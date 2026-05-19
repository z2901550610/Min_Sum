`timescale 1ns / 1ps
// Generic one-read/one-write synchronous RAM primitive.
module ram_1r1w_sync_read #(
    parameter int                 DATA_W        = 1,
    parameter int                 DEPTH         = 2,
    parameter int                 ADDR_W        = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter string              INIT_FILE     = "",
    parameter bit                 INIT_TO_VALUE = 1'b0,
    parameter logic  [DATA_W-1:0] RESET_VALUE   = '0
) (
    input  logic              i_clk,
    input  logic              i_we,
    input  logic [ADDR_W-1:0] i_write_addr,
    input  logic [DATA_W-1:0] i_wdata,
    input  logic [ADDR_W-1:0] i_read_addr,
`ifdef BIKE_SIM_DEBUG
    output logic [DATA_W-1:0] o_rdata,
    output logic [DATA_W-1:0] o_debug_mem[0:DEPTH-1]
`else
    output logic [DATA_W-1:0] o_rdata
`endif
);

  logic [DATA_W-1:0] mem[0:DEPTH-1];

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    for (int addr = 0; addr < DEPTH; addr++) begin
      o_debug_mem[addr] = mem[addr];
    end
  end
`endif

  initial begin
    o_rdata = RESET_VALUE;
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end else if (INIT_TO_VALUE) begin
      for (int addr = 0; addr < DEPTH; addr++) begin
        mem[addr] = RESET_VALUE;
      end
    end
  end

  always_ff @(posedge i_clk) begin
    if (i_we) begin
      mem[i_write_addr] <= i_wdata;
    end
    o_rdata <= mem[i_read_addr];
  end
endmodule
