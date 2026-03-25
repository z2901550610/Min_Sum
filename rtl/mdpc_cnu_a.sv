import mdpc_demo_pkg::*;

module mdpc_cnu_a (
  input  logic [MSG_W-1:0] u_in,
  input  logic [VAR_W-1:0] var_idx,
  input  logic [ROW_STATE_W-1:0] row_state_in,
  output logic [ROW_STATE_W-1:0] row_state_out,
  output logic sign_bit_out
);

  logic [ROW_STATE_W-1:0] next_state;
  int abs_mag;
  int next_count;

  always_comb begin
    next_state = row_state_in;
    sign_bit_out = msg_sign(u_in);
    abs_mag = int'(msg_mag(u_in));
    next_count = int'(row_state_valid_count(row_state_in));

    if (row_state_valid_count(row_state_in) == 0) begin
      next_state = row_state_pack(
        mag_from_int(abs_mag),
        mag_from_int(MAG_MAX),
        var_idx,
        msg_sign(u_in),
        2'd1
      );
    end else begin
      next_count = int'(row_state_valid_count(row_state_in)) + 1;
      if (next_count > W) begin
        next_count = W;
      end

      next_state = row_state_set_sign_xor(next_state, row_state_sign_xor(row_state_in) ^ msg_sign(u_in));
      next_state = row_state_set_valid_count(next_state, next_count[1:0]);

      if (abs_mag < int'(row_state_min1(row_state_in))) begin
        next_state = row_state_set_min2(next_state, row_state_min1(row_state_in));
        next_state = row_state_set_min1(next_state, mag_from_int(abs_mag));
        next_state = row_state_set_min_id(next_state, var_idx);
      end else if (abs_mag < int'(row_state_min2(row_state_in))) begin
        next_state = row_state_set_min2(next_state, mag_from_int(abs_mag));
      end
    end
  end

  assign row_state_out = next_state;
endmodule
