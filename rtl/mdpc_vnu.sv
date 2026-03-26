module mdpc_vnu (
  input  logic signed [APP_W-1:0] gamma_in,
  input  logic [MSG_W-1:0] c2v_in [0:W-1],
  output logic signed [APP_W-1:0] app_out,
  output logic x_out,
  output logic [MSG_W-1:0] u_next_out [0:W-1]
);

  import mdpc_demo_pkg::*;

  integer edge_idx;
  integer sum_c2v;
  integer signed_c2v [0:W-1];
  integer gamma_value;
  integer app_value;
  integer u_value;
  integer abs_value;
  integer scaled_value;
  logic [D-1:0] sat_mag;

  always_comb begin
    sum_c2v = 0;
    gamma_value = int'($signed(gamma_in));
    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      if (c2v_in[edge_idx][MSG_SIGN_BIT]) begin
        signed_c2v[edge_idx] = -int'(c2v_in[edge_idx][MSG_MAG_LSB +: D]);
      end else begin
        signed_c2v[edge_idx] = int'(c2v_in[edge_idx][MSG_MAG_LSB +: D]);
      end
      sum_c2v += signed_c2v[edge_idx];
    end

    abs_value = (sum_c2v < 0) ? -sum_c2v : sum_c2v;
    scaled_value = ((ALPHA_NUM * abs_value) + (1 << (ALPHA_SHIFT - 1))) >>> ALPHA_SHIFT;
    if (sum_c2v < 0) begin
      scaled_value = -scaled_value;
    end

    app_value = gamma_value + scaled_value;
    app_out = app_value[APP_W-1:0];
    x_out = (app_value < 0);

    for (edge_idx = 0; edge_idx < W; edge_idx++) begin
      abs_value = (signed_c2v[edge_idx] < 0) ? -signed_c2v[edge_idx] : signed_c2v[edge_idx];
      scaled_value = ((ALPHA_NUM * abs_value) + (1 << (ALPHA_SHIFT - 1))) >>> ALPHA_SHIFT;
      if (signed_c2v[edge_idx] < 0) begin
        scaled_value = -scaled_value;
      end

      u_value = app_value - scaled_value;
      abs_value = (u_value < 0) ? -u_value : u_value;
      if (abs_value > MAG_MAX) begin
        sat_mag = D'(MAG_MAX);
      end else begin
        sat_mag = abs_value[D-1:0];
      end
      u_next_out[edge_idx] = {(u_value < 0), sat_mag};
    end
  end
endmodule
