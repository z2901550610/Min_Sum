// One paper-style RAM C block storing hard decisions/error-estimate bits.
module ram_c
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_load,
  input  logic [N-1:0] i_load_bits,
  input  logic i_en,
  input  logic i_we,
  input  logic [VAR_W-1:0] i_addr,
  input  logic i_din,
  output logic o_dout,
  output logic [N-1:0] o_debug_bits
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [N-1:0] mem;

  assign o_debug_bits = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      mem <= '0;
      o_dout <= 1'b0;
    end else if (i_clear) begin
      mem <= '0;
      o_dout <= 1'b0;
    end else if (i_load) begin
      mem <= i_load_bits;
      o_dout <= 1'b0;
    end else if (i_en) begin
      if (i_we) begin
        mem[i_addr] <= i_din;
      end
      o_dout <= mem[i_addr];
    end
  end
endmodule
