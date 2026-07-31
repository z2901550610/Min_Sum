`timescale 1ns / 1ps

// Unbiased 32-bit multiply-high mapping used by TRIKE generate_random_idx:
// candidate = pos + high32(random * (len - pos)).
module trike_sampler_candidate #(
    parameter int OUTPUT_W = 32
) (
    input  logic [        31:0] i_random,
    input  logic [        31:0] i_position,
    input  logic [        31:0] i_length,
    output logic [OUTPUT_W-1:0] o_candidate
);

  logic [31:0] remaining;

  always_comb begin
    remaining   = i_length - i_position;
    o_candidate = OUTPUT_W'(i_position + (({32'b0, i_random} * remaining) >> 32));
  end

endmodule
