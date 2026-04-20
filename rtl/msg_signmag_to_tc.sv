// Converts a sign-magnitude min-sum message into signed two's-complement.
module msg_signmag_to_tc
  import bike_pkg::*;
(
  input  logic i_valid,                   // Input message valid qualifier.
  input  logic i_sign,                    // Sign bit in sign-magnitude format.
  input  logic [D-1:0] i_mag,             // Magnitude in sign-magnitude format.
  output logic o_valid,                   // Output valid qualifier.
  output logic signed [MSG_W-1:0] o_tc    // Signed two's-complement message.
);

  timeunit 1ns;
  timeprecision 1ps;

  logic signed [MSG_W-1:0] mag_tc;

  always_comb begin
    o_valid = i_valid;
    mag_tc = $signed({1'b0, i_mag});
    if (i_valid && i_sign && (i_mag != '0)) begin
      o_tc = -mag_tc;
    end else if (i_valid) begin
      o_tc = mag_tc;
    end else begin
      o_tc = '0;
    end
  end
endmodule
