module mdpc_bit_ram_c (
  input  logic clk,
  input  logic rst_n,
  input  logic clear_en,
  input  logic load_en,
  input  logic [N-1:0] load_bits,
  input  logic wr_en,
  input  logic [VAR_W-1:0] wr_addr,
  input  logic wr_bit,
  input  logic [VAR_W-1:0] rd_addr,
  output logic rd_bit,
  output logic [N-1:0] bits_out
);

  import mdpc_demo_pkg::*;

  logic [N-1:0] mem;

  assign rd_bit = mem[rd_addr];
  assign bits_out = mem;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem <= '0;
    end else if (clear_en) begin
      mem <= '0;
    end else if (load_en) begin
      mem <= load_bits;
    end else if (wr_en) begin
      mem[wr_addr] <= wr_bit;
    end
  end
endmodule
