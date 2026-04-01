module mdpc_cnu_b (
  input  logic [ROW_STATE_W-1:0] c2v_compact_msg_in,
  input  logic v2c_sign_in,
  input  logic [VAR_W-1:0] src_var_idx,
  output logic [MSG_W-1:0] c2v_msg_out
);

  import mdpc_demo_pkg::*;

  // CNU_B stays in sign-magnitude domain so it can emit the outgoing c2v sign
  // and selected min magnitude directly from the row-state summary.

  logic [D-1:0] c2v_min1_mag;
  logic [D-1:0] c2v_min2_mag;
  logic [VAR_W-1:0] c2v_min_var_idx;
  logic c2v_sign_xor;
  logic [D-1:0] c2v_msg_mag;
  logic c2v_msg_sign;

  assign c2v_min1_mag = c2v_compact_msg_in[ROW_STATE_MIN1_LSB +: D];
  assign c2v_min2_mag = c2v_compact_msg_in[ROW_STATE_MIN2_LSB +: D];
  assign c2v_min_var_idx = c2v_compact_msg_in[ROW_STATE_MIN_ID_LSB +: VAR_W];
  assign c2v_sign_xor = c2v_compact_msg_in[ROW_STATE_SIGN_XOR_BIT];

  always_comb begin
    if (src_var_idx == c2v_min_var_idx) begin
      c2v_msg_mag = c2v_min2_mag;
    end else begin
      c2v_msg_mag = c2v_min1_mag;
    end

    c2v_msg_sign = c2v_sign_xor ^ v2c_sign_in;
  end

  assign c2v_msg_out = {c2v_msg_sign, c2v_msg_mag};
endmodule
