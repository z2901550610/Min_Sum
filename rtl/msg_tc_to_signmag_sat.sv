`timescale 1ns/1ps
// Converts a signed two's-complement message into saturated sign-magnitude.
module msg_tc_to_signmag_sat
  #(
    parameter int W = 3,
    parameter int D = 4,
    parameter int MSG_W = D + 1,
    parameter int VNU_TC_W = MSG_W + ((W > 1) ? $clog2(W + 1) : 1),
    parameter int MAG_MAX = (1 << D) - 1
  )
(
  input  logic signed [VNU_TC_W-1:0] i_tc,   // Signed two's-complement message.
  output logic        [MSG_W-1:0]    o_msg   // Saturated sign-magnitude message.
);

  logic                tc_sign;
  logic [VNU_TC_W-1:0] abs_value;
  logic [D-1:0]        sat_mag;

  always_comb begin
    tc_sign = i_tc[VNU_TC_W-1];
    if (tc_sign) begin
      abs_value = (~i_tc) + {{(VNU_TC_W - 1){1'b0}}, 1'b1};
    end else begin
      abs_value = i_tc[VNU_TC_W-1:0];
    end

    if (abs_value > VNU_TC_W'(MAG_MAX)) begin
      sat_mag = D'(MAG_MAX);
    end else begin
      sat_mag = abs_value[D-1:0];
    end

    o_msg = {tc_sign && (sat_mag != '0), sat_mag};
  end
endmodule
