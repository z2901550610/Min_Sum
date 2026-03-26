module mdpc_cnu_b (
  input  logic [ROW_STATE_W-1:0] row_state_in,
  input  logic u_sign_in,
  input  logic [VAR_W-1:0] var_idx,
  output logic [MSG_W-1:0] v_out
);

  import mdpc_demo_pkg::*;

  logic [D-1:0] state_min1;
  logic [D-1:0] state_min2;
  logic [VAR_W-1:0] state_min_id;
  logic state_sign_xor;
  logic [D-1:0] selected_mag;
  logic selected_sign;

  assign state_min1 = row_state_in[ROW_STATE_MIN1_LSB +: D];
  assign state_min2 = row_state_in[ROW_STATE_MIN2_LSB +: D];
  assign state_min_id = row_state_in[ROW_STATE_MIN_ID_LSB +: VAR_W];
  assign state_sign_xor = row_state_in[ROW_STATE_SIGN_XOR_BIT];

  always_comb begin
    if (var_idx == state_min_id) begin
      selected_mag = state_min2;
    end else begin
      selected_mag = state_min1;
    end

    selected_sign = state_sign_xor ^ u_sign_in;
  end

  assign v_out = {selected_sign, selected_mag};
endmodule
