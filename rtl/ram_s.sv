// Stores per-edge v2c sign bits for later c2v reconstruction.
module ram_s
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic [VAR_W-1:0] i_r_var0,    // Variable index for read port 0.
  input  logic [EDGE_W-1:0] i_r_edge0,  // Edge slot for read port 0.
  input  logic [VAR_W-1:0] i_r_var1,    // Variable index for read port 1.
  input  logic [EDGE_W-1:0] i_r_edge1,  // Edge slot for read port 1.
  output logic o_sign0,                 // Sign bit returned on read port 0.
  output logic o_sign1,                 // Sign bit returned on read port 1.
  input  logic i_we0,                   // Write enable for write port 0.
  input  logic [VAR_W-1:0] i_w_var0,    // Variable index for write port 0.
  input  logic [EDGE_W-1:0] i_w_edge0,  // Edge slot for write port 0.
  input  logic i_din0,                  // Sign bit written by port 0.
  input  logic i_we1,                   // Write enable for write port 1.
  input  logic [VAR_W-1:0] i_w_var1,    // Variable index for write port 1.
  input  logic [EDGE_W-1:0] i_w_edge1,  // Edge slot for write port 1.
  input  logic i_din1                   // Sign bit written by port 1.
);

  timeunit 1ns;
  timeprecision 1ps;

  logic mem [0:N-1][0:W-1];
  integer var_idx;
  integer edge_idx;

  assign o_sign0 = mem[i_r_var0][i_r_edge0];
  assign o_sign1 = mem[i_r_var1][i_r_edge1];

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= 1'b0;
        end
      end
    end else if (i_clear) begin
      for (var_idx = 0; var_idx < N; var_idx++) begin
        for (edge_idx = 0; edge_idx < W; edge_idx++) begin
          mem[var_idx][edge_idx] <= 1'b0;
        end
      end
    end else begin
      if (i_we0) begin
        mem[i_w_var0][i_w_edge0] <= i_din0;
      end
      if (i_we1) begin
        mem[i_w_var1][i_w_edge1] <= i_din1;
      end
    end
  end
endmodule
