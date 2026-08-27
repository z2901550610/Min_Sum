`timescale 1ns / 1ps

module tb_trike_clmul_karatsuba;

  logic [ 63:0] operand_a;
  logic [ 63:0] operand_b;
  logic [127:0] product_depth0;
  logic [127:0] product_depth1;
  logic [127:0] product_depth2;
  logic [127:0] product_depth3;

  trike_clmul_karatsuba #(
      .WIDTH (64),
      .LEVELS(0)
  ) u_depth0 (
      .i_a      (operand_a),
      .i_b      (operand_b),
      .o_product(product_depth0)
  );

  trike_clmul_karatsuba #(
      .WIDTH (64),
      .LEVELS(1)
  ) u_depth1 (
      .i_a      (operand_a),
      .i_b      (operand_b),
      .o_product(product_depth1)
  );

  trike_clmul_karatsuba #(
      .WIDTH (64),
      .LEVELS(2)
  ) u_depth2 (
      .i_a      (operand_a),
      .i_b      (operand_b),
      .o_product(product_depth2)
  );

  trike_clmul_karatsuba #(
      .WIDTH (64),
      .LEVELS(3)
  ) u_depth3 (
      .i_a      (operand_a),
      .i_b      (operand_b),
      .o_product(product_depth3)
  );

  function automatic logic [127:0] reference_clmul(input  logic [63:0] a, input  logic [63:0] b);
    logic [127:0] product;
    begin
      product = '0;
      for (int bit_idx = 0; bit_idx < 64; bit_idx++) begin
        if (a[bit_idx]) product = product ^ ({64'b0, b} << bit_idx);
      end
      return product;
    end
  endfunction

  task automatic check_case(input  logic [63:0] a, input  logic [63:0] b);
    logic [127:0] expected;
    begin
      operand_a = a;
      operand_b = b;
      #1;
      expected = reference_clmul(a, b);
      if ((product_depth0 != expected) || (product_depth1 != expected) ||
          (product_depth2 != expected) || (product_depth3 != expected)) begin
        $fatal(1, "clmul mismatch a=%016x b=%016x expected=%032x", a, b, expected);
      end
    end
  endtask

  initial begin
    operand_a = '0;
    operand_b = '0;

    check_case(64'b0, 64'b0);
    check_case(64'd1, 64'h8000_0000_0000_0000);
    check_case(64'hffff_ffff_ffff_ffff, 64'hffff_ffff_ffff_ffff);
    check_case(64'ha5a5_5a5a_0123_4567, 64'h89ab_cdef_fedc_ba98);

    for (int case_idx = 0; case_idx < 256; case_idx++) begin
      check_case({$urandom, $urandom}, {$urandom, $urandom});
    end

    $display("tb_trike_clmul_karatsuba PASS cases=260");
    $finish;
  end

endmodule
