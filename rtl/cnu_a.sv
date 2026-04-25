// CNU_A updates one compressed-c2v state from an incoming v2c message.
module cnu_a
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_en,                          // Enables this cycle's compressed-c2v update.
  input  logic [MSG_W-1:0] i_v2c,             // Incoming v2c/u sign-magnitude message.
  input  logic [VAR_W-1:0] i_var_idx,         // Which variable column j sent i_v2c.
  input  logic [COMP_C2V_W-1:0] i_comp_c2v,   // Current compressed-c2v state.
  output logic [COMP_C2V_W-1:0] o_comp_c2v,   // Next compressed-c2v state.
  output logic o_sign,                        // sign(i_v2c), stored in RAM S for CNU_B.
  output logic o_valid                   
);

  timeunit 1ns;
  timeprecision 1ps;

  logic               v2c_sign;
  logic [D-1:0]       v2c_mag;
  logic [D-1:0]       c2v_min1_mag;
  logic [D-1:0]       c2v_min2_mag;
  logic               c2v_sign_xor;
  logic [COMP_C2V_W-1:0] comp_c2v_next;

  assign v2c_sign = i_v2c[MSG_SIGN_BIT];
  assign v2c_mag = i_v2c[MSG_MAG_LSB +: D];

  assign c2v_min1_mag = i_comp_c2v[COMP_C2V_MIN1_LSB +: D];
  assign c2v_min2_mag = i_comp_c2v[COMP_C2V_MIN2_LSB +: D];
  assign c2v_sign_xor = i_comp_c2v[COMP_C2V_SIGN_XOR_BIT];

  always_comb begin
    comp_c2v_next = i_comp_c2v;
    comp_c2v_next[COMP_C2V_SIGN_XOR_BIT] = c2v_sign_xor ^ v2c_sign;

    if (v2c_mag <= c2v_min1_mag) begin
      comp_c2v_next[COMP_C2V_MIN2_LSB +: D] = c2v_min1_mag;
      comp_c2v_next[COMP_C2V_MIN1_LSB +: D] = v2c_mag;
      comp_c2v_next[COMP_C2V_MIN_ID_LSB +: VAR_W] = i_var_idx;
    end else if (v2c_mag < c2v_min2_mag) begin
      comp_c2v_next[COMP_C2V_MIN2_LSB +: D] = v2c_mag;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_comp_c2v <= COMP_C2V_INIT;
      o_sign <= 1'b0;
      o_valid <= 1'b0;
    end else begin
      o_valid <= i_en;
      if (i_en) begin
        o_comp_c2v <= comp_c2v_next;
        o_sign <= v2c_sign;
      end
    end
  end
endmodule
