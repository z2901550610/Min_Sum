// Converts a signed two's-complement message into saturated sign-magnitude.
module msg_tc_to_signmag_sat
  import bike_pkg::*;
#(
  parameter int TC_W = MSG_W
)(
  input  logic i_valid,                    // Input message valid qualifier.
  input  logic signed [TC_W-1:0] i_tc,     // Signed two's-complement message.
  output logic o_valid,                    // Output valid qualifier.
  output logic [MSG_W-1:0] o_msg           // Saturated sign-magnitude message.
);

  timeunit 1ns;
  timeprecision 1ps;

  logic tc_sign;
  logic [TC_W-1:0] abs_value;
  logic [D-1:0] sat_mag;

  always_comb begin
    o_valid = i_valid;
    tc_sign = i_tc[TC_W-1];
    if (tc_sign) begin
      abs_value = (~i_tc) + {{(TC_W - 1){1'b0}}, 1'b1};
    end else begin
      abs_value = i_tc[TC_W-1:0];
    end

    if (|abs_value[TC_W-1:D]) begin
      sat_mag = D'(MAG_MAX);
    end else begin
      sat_mag = abs_value[D-1:0];
    end

    if (i_valid) begin
      o_msg = {tc_sign && (sat_mag != '0), sat_mag};
    end else begin
      o_msg = '0;
    end
  end
endmodule
