`timescale 1ns / 1ps

module tb_kem_ct_compare_select;
  localparam int COMPARE_W = 257;
  localparam int DATA_W = 193;

  logic [COMPARE_W-1:0] compare_a;
  logic [COMPARE_W-1:0] compare_b;
  logic [   DATA_W-1:0] match_data;
  logic [   DATA_W-1:0] mismatch_data;
  logic                 equal;
  logic [   DATA_W-1:0] selected_data;

  kem_ct_compare_select #(
      .COMPARE_W(COMPARE_W),
      .DATA_W   (DATA_W)
  ) dut (
      .i_compare_a    (compare_a),
      .i_compare_b    (compare_b),
      .i_match_data   (match_data),
      .i_mismatch_data(mismatch_data),
      .o_equal        (equal),
      .o_selected_data(selected_data)
  );

  task automatic check_result(input  logic expected_equal);
    logic [DATA_W-1:0] expected_data;
    begin
      #1;
      expected_data = expected_equal ? match_data : mismatch_data;
      if (equal != expected_equal) begin
        $fatal(1, "equality mismatch: got=%0b expected=%0b", equal, expected_equal);
      end
      if (selected_data != expected_data) begin
        $fatal(1, "selected data mismatch");
      end
    end
  endtask

  initial begin
    compare_a    = '0;
    compare_b    = '0;
    match_data   = {DATA_W{1'b1}};
    mismatch_data = '0;
    check_result(1'b1);

    for (int bit_idx = 0; bit_idx < COMPARE_W; bit_idx++) begin
      compare_b          = compare_a;
      compare_b[bit_idx] = ~compare_a[bit_idx];
      check_result(1'b0);
    end

    for (int trial = 0; trial < 100; trial++) begin
      for (int bit_idx = 0; bit_idx < COMPARE_W; bit_idx++) begin
        compare_a[bit_idx] = 1'($urandom);
      end
      compare_b = compare_a;
      for (int bit_idx = 0; bit_idx < DATA_W; bit_idx++) begin
        match_data[bit_idx]    = 1'($urandom);
        mismatch_data[bit_idx] = 1'($urandom);
      end
      check_result(1'b1);

      compare_b[trial%COMPARE_W] = ~compare_b[trial%COMPARE_W];
      check_result(1'b0);
    end

    $display("tb_kem_ct_compare_select PASS");
    $finish;
  end
endmodule
