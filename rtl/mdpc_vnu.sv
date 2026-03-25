import mdpc_demo_pkg::*;

module mdpc_vnu (
  input  logic signed [APP_W-1:0] gamma_in,
  input  logic [MSG_W-1:0] c2v_in [0:W-1],
  output logic signed [APP_W-1:0] app_out,
  output logic x_out,
  output logic [MSG_W-1:0] u_next_out [0:W-1]
);

  integer edge_idx;
  integer sum_c2v;
  integer signed_c2v [0:W-1];
  integer gamma_value;
  integer app_value;
  integer u_value;

  always_comb begin
    sum_c2v = 0;
    gamma_value = int'($signed(gamma_in));
    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      signed_c2v[edge_idx] = msg_to_signed(c2v_in[edge_idx]);
      sum_c2v += signed_c2v[edge_idx];
    end

    app_value = gamma_value + alpha_scale(sum_c2v);
    app_out = app_from_int(app_value);
    x_out = (app_value < 0);

    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      u_value = app_value - alpha_scale(signed_c2v[edge_idx]);
      u_next_out[edge_idx] = msg_from_signed(u_value);
    end
  end
endmodule
