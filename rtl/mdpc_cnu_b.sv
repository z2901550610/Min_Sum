import mdpc_demo_pkg::*;

module mdpc_cnu_b (
  input  logic [ROW_STATE_W-1:0] row_state_in,
  input  logic u_sign_in,
  input  logic [VAR_W-1:0] var_idx,
  output logic [MSG_W-1:0] v_out
);

  logic [MSG_W-1:0] next_msg;
  logic [D-1:0] selected_mag;

  always_comb begin
    if (var_idx == row_state_min_id(row_state_in)) begin
      selected_mag = row_state_min2(row_state_in);
    end else begin
      selected_mag = row_state_min1(row_state_in);
    end

    next_msg = msg_pack(row_state_sign_xor(row_state_in) ^ u_sign_in, selected_mag);
  end

  assign v_out = next_msg;
endmodule
