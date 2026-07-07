`timescale 1ns / 1ps
// CNU_A combinationally updates one compressed-c2v state from an incoming v2c message.
module cnu_a
  import bike_pkg::*;
(
    input  logic [MSG_W-1:0] i_v2c_msg,  // Incoming v2c/u sign-magnitude message.
    input  logic [ DIAG_GLOBAL_W-1:0] i_diag_idx_global,      // Global diagonal index for this v2c message.
    input  logic [COMP_C2V_W-1:0] i_c2v_comp,  // Current compressed-c2v state.
    output logic [COMP_C2V_W-1:0] o_c2v_comp,  // Next compressed-c2v state.
    output logic o_sign  // sign(i_v2c_msg), stored in RAM S for CNU_B.
);

  logic         v2c_sign;
  logic [D-1:0] v2c_mag;
  logic [D-1:0] c2v_min1_mag;
  logic [D-1:0] c2v_min2_mag;
  logic         c2v_sign_xor;

  assign v2c_sign = i_v2c_msg[MSG_SIGN_BIT];
  assign v2c_mag = i_v2c_msg[MSG_MAG_LSB+:D];

  assign c2v_min1_mag = i_c2v_comp[COMP_C2V_MIN1_LSB+:D];
  assign c2v_min2_mag = i_c2v_comp[COMP_C2V_MIN2_LSB+:D];
  assign c2v_sign_xor = i_c2v_comp[COMP_C2V_SIGN_XOR_BIT];

  always_comb begin
    o_c2v_comp = i_c2v_comp;
    o_c2v_comp[COMP_C2V_SIGN_XOR_BIT] = c2v_sign_xor ^ v2c_sign;
    o_sign = v2c_sign;

    if (v2c_mag <= c2v_min1_mag) begin
      o_c2v_comp[COMP_C2V_MIN2_LSB+:D] = c2v_min1_mag;
      o_c2v_comp[COMP_C2V_MIN1_LSB+:D] = v2c_mag;
      o_c2v_comp[COMP_C2V_MIN_DIAG_GLOBAL_LSB+:DIAG_GLOBAL_W] = i_diag_idx_global;
    end else if (v2c_mag < c2v_min2_mag) begin
      o_c2v_comp[COMP_C2V_MIN2_LSB+:D] = v2c_mag;
    end
  end
endmodule
