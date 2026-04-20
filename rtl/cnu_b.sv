// CNU_B reconstructs an outgoing c2v message from compressed-c2v state.
module cnu_b
  import bike_pkg::*;
(
  input  logic [COMP_C2V_W-1:0] i_comp_c2v,   // Compressed-c2v state for this check node.
  input  logic i_v2c_sign,                    // Stored sign of the edge's prior v2c/u message.
  input  logic i_syndrome_bit,                // Syndrome target bit for this check equation.
  input  logic [VAR_W-1:0] i_var_idx,         // Variable index of the requested edge.
  output logic [MSG_W-1:0] o_c2v_msg          // Reconstructed c2v sign-magnitude message.
);

  timeunit 1ns;
  timeprecision 1ps;

  // CNU_B reconstructs each c2v from the compressed-c2v state: use min2 for
  // the variable that supplied min1, otherwise min1; sign removes this edge's
  // original v2c/u sign from the row parity. For syndrome decoding, the check
  // equation target also contributes to the outgoing sign.

  logic [D-1:0] c2v_min1_mag;
  logic [D-1:0] c2v_min2_mag;
  logic [VAR_W-1:0] c2v_min_var_idx;
  logic c2v_sign_xor;
  logic [D-1:0] c2v_msg_mag;
  logic c2v_msg_sign;

  assign c2v_min1_mag = i_comp_c2v[COMP_C2V_MIN1_LSB +: D];
  assign c2v_min2_mag = i_comp_c2v[COMP_C2V_MIN2_LSB +: D];
  assign c2v_min_var_idx = i_comp_c2v[COMP_C2V_MIN_ID_LSB +: VAR_W];
  assign c2v_sign_xor = i_comp_c2v[COMP_C2V_SIGN_XOR_BIT];

  always_comb begin
    if (i_var_idx == c2v_min_var_idx) begin
      c2v_msg_mag = c2v_min2_mag;
    end else begin
      c2v_msg_mag = c2v_min1_mag;
    end

    c2v_msg_sign = c2v_sign_xor ^ i_v2c_sign ^ i_syndrome_bit;
  end

  assign o_c2v_msg = {c2v_msg_sign, c2v_msg_mag};
endmodule
