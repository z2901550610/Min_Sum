`timescale 1ns / 1ps
// CNU_B reconstructs an outgoing c2v message from compressed-c2v state.
module cnu_b
  import bike_pkg::*;
(
    input  logic [COMP_C2V_W-1:0] i_c2v_comp,  // Compressed-c2v state.
    input  logic i_v2c_sign,  // Stored sign of this global diagonal's prior v2c.
    input  logic i_syndrome_bit,  // Syndrome target bit for this check.
    input  logic [DIAG_GLOBAL_W-1:0] i_diag_idx_global,  // Global diagonal index requesting c2v.
    output logic [MSG_W-1:0] o_c2v_msg  // Reconstructed sign-magnitude c2v.
);

  logic [            D-1:0] c2v_min1_mag;
  logic [            D-1:0] c2v_min2_mag;
  logic [DIAG_GLOBAL_W-1:0] c2v_min_diag_idx_global;
  logic                     c2v_sign_xor;
  logic [            D-1:0] c2v_msg_mag;
  logic                     c2v_msg_sign;

  assign c2v_min1_mag = i_c2v_comp[COMP_C2V_MIN1_LSB+:D];
  assign c2v_min2_mag = i_c2v_comp[COMP_C2V_MIN2_LSB+:D];
  assign c2v_min_diag_idx_global = i_c2v_comp[COMP_C2V_MIN_DIAG_GLOBAL_LSB+:DIAG_GLOBAL_W];
  assign c2v_sign_xor = i_c2v_comp[COMP_C2V_SIGN_XOR_BIT];

  always_comb begin
    if (i_diag_idx_global == c2v_min_diag_idx_global) begin
      c2v_msg_mag = c2v_min2_mag;
    end else begin
      c2v_msg_mag = c2v_min1_mag;
    end

    c2v_msg_sign = c2v_sign_xor ^ i_v2c_sign ^ i_syndrome_bit;
  end

  assign o_c2v_msg = {c2v_msg_sign, c2v_msg_mag};
endmodule
