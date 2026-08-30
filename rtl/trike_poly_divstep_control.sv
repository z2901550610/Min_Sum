`timescale 1ns / 1ps

// Generate the public fixed-count control sequence for a batch of divsteps.
// The low control windows are independent of the word being updated and can
// therefore be broadcast to every f/g/v/w word update.
module trike_poly_divstep_control #(
    parameter int STEPS   = 8,
    parameter int DELTA_W = 17
) (
    input  logic signed [DELTA_W-1:0] i_delta,
    input  logic        [    STEPS:0] i_f_control,
    input  logic        [    STEPS:0] i_g_control,
    output logic signed [DELTA_W-1:0] o_delta,
    output logic        [  STEPS-1:0] o_swap,
    output logic        [  STEPS-1:0] o_alpha
);

  logic signed [DELTA_W-1:0] delta_c[  0:STEPS];
  logic        [    STEPS:0] f_control_c[0:STEPS-1];
  logic        [    STEPS:0] g_control_c[0:STEPS-1];

  always_comb begin
    delta_c[0] = i_delta;
    f_control_c[0] = i_f_control;
    g_control_c[0] = i_g_control;

    for (int step_idx = 0; step_idx < STEPS; step_idx++) begin
      o_alpha[step_idx] = g_control_c[step_idx][0];
      o_swap[step_idx] = (delta_c[step_idx] > 0) && o_alpha[step_idx];
      delta_c[step_idx+1] =
          o_swap[step_idx] ? (-delta_c[step_idx] + DELTA_W'(1)) :
                             (delta_c[step_idx] + DELTA_W'(1));
      if (step_idx < STEPS - 1) begin
        f_control_c[step_idx+1] = o_swap[step_idx] ? g_control_c[step_idx] : f_control_c[step_idx];
        g_control_c[step_idx+1] =
            (o_alpha[step_idx] ?
                 (g_control_c[step_idx] ^ f_control_c[step_idx]) :
                 g_control_c[step_idx]) >> 1;
      end
    end

    o_delta = delta_c[STEPS];
  end

`ifndef SYNTHESIS
  initial begin
    if (STEPS < 1) $error("trike_poly_divstep_control STEPS must be positive");
    if (DELTA_W < 3) $error("trike_poly_divstep_control DELTA_W must be at least 3");
  end
`endif

endmodule
