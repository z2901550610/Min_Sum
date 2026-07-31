`timescale 1ns / 1ps

// Fixed-structure equality check and data selection for KEM implicit
// rejection. The module has no data-dependent control flow or latency.
module kem_ct_compare_select #(
    parameter int COMPARE_W = 256,
    parameter int DATA_W    = 256
) (
    input  logic [COMPARE_W-1:0] i_compare_a,
    input  logic [COMPARE_W-1:0] i_compare_b,
    input  logic [   DATA_W-1:0] i_match_data,
    input  logic [   DATA_W-1:0] i_mismatch_data,
    output logic                 o_equal,
    output logic [   DATA_W-1:0] o_selected_data
);

  logic              difference;
  logic [DATA_W-1:0] match_mask;

  always_comb begin
    difference      = |(i_compare_a ^ i_compare_b);
    o_equal         = ~difference;
    match_mask      = {DATA_W{o_equal}};
    o_selected_data = (i_match_data & match_mask) | (i_mismatch_data & ~match_mask);
  end

endmodule
