`timescale 1ns/1ps
// Converts a sign-magnitude message into signed two's-complement.
module msg_signmag_to_tc
  #(
    parameter int D = 4,
    parameter int MSG_W = D + 1,
    parameter int MSG_MAG_LSB = 0,
    parameter int MSG_SIGN_BIT = D
  )
(
  input  logic        [MSG_W-1:0] i_msg,  // Sign-magnitude message.
  output logic signed [MSG_W-1:0] o_tc    // Signed two's-complement message.
);

  logic signed [MSG_W-1:0] mag_tc;
  logic                    sign_bit;
  logic        [D-1:0]     mag_bits;

  assign sign_bit = i_msg[MSG_SIGN_BIT];
  assign mag_bits = i_msg[MSG_MAG_LSB +: D];
  assign mag_tc = $signed({1'b0, mag_bits});

  always_comb begin
    o_tc = (sign_bit && (mag_bits != '0)) ? -mag_tc : mag_tc;
  end
endmodule
