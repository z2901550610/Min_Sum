// One paper-style RAM C block storing hard decisions/error-estimate bits.
module ram_c
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_load,
  input  logic [N-1:0] i_load_wdata,
  input  logic i_en,
  input  logic i_we,
  input  logic [VAR_W-1:0] i_var_idx,                      // Which variable column j / hard-decision bit to access.
  input  logic i_wdata,
  output logic o_rdata,
  output logic [N-1:0] o_bits
);

  timeunit 1ns;
  timeprecision 1ps;

  localparam logic RESET_VALUE = 1'b0;

  logic [N-1:0] mem;

  assign o_bits = mem;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_rdata <= RESET_VALUE;
      for (int bit_idx = 0; bit_idx < N; bit_idx++) begin
        mem[bit_idx] <= RESET_VALUE;
      end
    end else if (i_clear) begin
      o_rdata <= RESET_VALUE;
      for (int bit_idx = 0; bit_idx < N; bit_idx++) begin
        mem[bit_idx] <= RESET_VALUE;
      end
    end else if (i_load) begin
      o_rdata <= RESET_VALUE;
      for (int bit_idx = 0; bit_idx < N; bit_idx++) begin
        mem[bit_idx] <= i_load_wdata[bit_idx];
      end
    end else if (i_en) begin
      if (i_we) begin
        mem[i_var_idx] <= i_wdata;
      end
      o_rdata <= mem[i_var_idx];
    end
  end
endmodule
