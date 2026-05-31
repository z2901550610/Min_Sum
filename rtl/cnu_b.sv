`timescale 1ns / 1ps
// CNU_B reconstructs an outgoing c2v message from compressed-c2v state.
module cnu_b
  import bike_pkg::*;
(
    input  logic [COMP_C2V_W-1:0] i_comp_c2v,      // Compressed-c2v state.
    input  logic                  i_v2c_sign,      // Stored sign of this edge's prior v2c.
    input  logic                  i_syndrome_bit,  // Syndrome target bit for this check.
    input  logic [ EDGE_ID_W-1:0] i_edge_id,       // Row-local edge identity requesting c2v.
    output logic [     MSG_W-1:0] o_c2v_msg        // Reconstructed sign-magnitude c2v.
);

  logic [        D-1:0] c2v_min1_mag;
  logic [        D-1:0] c2v_min2_mag;
  logic [EDGE_ID_W-1:0] c2v_min_edge_id;
  logic                 c2v_sign_xor;
  logic [        D-1:0] c2v_msg_mag;
  logic                 c2v_msg_sign;

  assign c2v_min1_mag = i_comp_c2v[COMP_C2V_MIN1_LSB+:D];
  assign c2v_min2_mag = i_comp_c2v[COMP_C2V_MIN2_LSB+:D];
  assign c2v_min_edge_id = i_comp_c2v[COMP_C2V_MIN_ID_LSB+:EDGE_ID_W];
  assign c2v_sign_xor = i_comp_c2v[COMP_C2V_SIGN_XOR_BIT];

  always_comb begin
    if (i_edge_id == c2v_min_edge_id) begin
      c2v_msg_mag = c2v_min2_mag;
    end else begin
      c2v_msg_mag = c2v_min1_mag;
    end

    c2v_msg_sign = c2v_sign_xor ^ i_v2c_sign ^ i_syndrome_bit;
  end

  assign o_c2v_msg = {c2v_msg_sign, c2v_msg_mag};
endmodule
