module cnu_a
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_clear,
  input  logic i_en,
  input  logic [MSG_W-1:0] i_v2c,
  input  logic [VAR_W-1:0] i_idx,
  input  logic [ROW_STATE_W-1:0] i_comp_c2v,
  output logic [ROW_STATE_W-1:0] o_comp_c2v,
  output logic o_sign,
  output logic o_valid
);

  timeunit 1ns;
  timeprecision 1ps;

  // CNU_A compresses one check row into {min1, min2, min_id, sign_xor}. The
  // sign-magnitude v2c/u format lets sign feed sign_xor and magnitude feed the
  // min1/min2 update without conversion.

  logic               v2c_sign;
  logic [D-1:0]       v2c_mag;
  logic [D-1:0]       c2v_min1_mag;
  logic [D-1:0]       c2v_min2_mag;
  logic               c2v_sign_xor;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_next;

  assign v2c_sign = i_v2c[MSG_SIGN_BIT];
  assign v2c_mag = i_v2c[MSG_MAG_LSB +: D];

  assign c2v_min1_mag = i_comp_c2v[ROW_STATE_MIN1_LSB +: D];
  assign c2v_min2_mag = i_comp_c2v[ROW_STATE_MIN2_LSB +: D];
  assign c2v_sign_xor = i_comp_c2v[ROW_STATE_SIGN_XOR_BIT];

  always_comb begin
    c2v_compact_msg_next = i_comp_c2v;
    c2v_compact_msg_next[ROW_STATE_SIGN_XOR_BIT] = c2v_sign_xor ^ v2c_sign;

    if (v2c_mag <= c2v_min1_mag) begin
      c2v_compact_msg_next[ROW_STATE_MIN2_LSB +: D] = c2v_min1_mag;
      c2v_compact_msg_next[ROW_STATE_MIN1_LSB +: D] = v2c_mag;
      c2v_compact_msg_next[ROW_STATE_MIN_ID_LSB +: VAR_W] = i_idx;
    end else if (v2c_mag < c2v_min2_mag) begin
      c2v_compact_msg_next[ROW_STATE_MIN2_LSB +: D] = v2c_mag;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_comp_c2v <= ROW_STATE_INIT;
      o_sign <= 1'b0;
      o_valid <= 1'b0;
    end else if (i_clear) begin
      o_comp_c2v <= ROW_STATE_INIT;
      o_sign <= 1'b0;
      o_valid <= 1'b0;
    end else begin
      o_valid <= i_en;
      if (i_en) begin
        o_comp_c2v <= c2v_compact_msg_next;
        o_sign <= v2c_sign;
      end
    end
  end
endmodule
