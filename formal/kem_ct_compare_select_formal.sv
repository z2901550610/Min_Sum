`timescale 1ns / 1ps

// Exhaustive functional proof for the fixed-structure compare-and-select block.
module kem_ct_compare_select_formal #(
    parameter int COMPARE_W = 8,
    parameter int DATA_W    = 8
) (
    input  logic [COMPARE_W-1:0] i_compare_a,
    input  logic [COMPARE_W-1:0] i_compare_b,
    input  logic [   DATA_W-1:0] i_match_data,
    input  logic [   DATA_W-1:0] i_mismatch_data
);

  logic              equal;
  logic [DATA_W-1:0] selected_data;

  kem_ct_compare_select #(
      .COMPARE_W(COMPARE_W),
      .DATA_W   (DATA_W)
  ) u_dut (
      .i_compare_a    (i_compare_a),
      .i_compare_b    (i_compare_b),
      .i_match_data   (i_match_data),
      .i_mismatch_data(i_mismatch_data),
      .o_equal        (equal),
      .o_selected_data(selected_data)
  );

  always_comb begin
    assert (equal == (i_compare_a == i_compare_b));
    if (i_compare_a == i_compare_b) begin
      assert (selected_data == i_match_data);
    end else begin
      assert (selected_data == i_mismatch_data);
    end
    cover (equal);
    cover (!equal);
  end

endmodule
