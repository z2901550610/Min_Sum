module ram_c
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_load,
  input  logic [N-1:0] i_load_bits,
  input  logic i_we,
  input  logic [VAR_W-1:0] i_w_addr,
  input  logic i_din,
  input  logic [VAR_W-1:0] i_r_addr,
  output logic o_dout,
  output logic [N-1:0] o_bits
);

  timeunit 1ns;
  timeprecision 1ps;

  logic [N-1:0] mem;

  assign o_dout = mem[i_r_addr];
  assign o_bits = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      mem <= '0;
    end else if (i_clear) begin
      mem <= '0;
    end else if (i_load) begin
      mem <= i_load_bits;
    end else if (i_we) begin
      mem[i_w_addr] <= i_din;
    end
  end
endmodule
