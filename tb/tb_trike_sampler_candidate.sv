`timescale 1ns / 1ps

module tb_trike_sampler_candidate;
  logic [31:0] random_data;
  logic [31:0] position;
  logic [31:0] length;
  logic [31:0] candidate;

  trike_sampler_candidate dut (
      .i_random(random_data),
      .i_position(position),
      .i_length(length),
      .o_candidate(candidate)
  );

  task automatic check_candidate(input  logic [31:0] random_value, input  logic [31:0] position_value,
                                 input  logic [31:0] length_value,
                                 input  logic [31:0] expected_candidate);
    begin
      random_data = random_value;
      position    = position_value;
      length      = length_value;
      #1;
      if (candidate != expected_candidate) begin
        $fatal(1, "candidate mismatch: random=%08x pos=%0d len=%0d got=%0d expected=%0d",
               random_value, position_value, length_value, candidate, expected_candidate);
      end
    end
  endtask

  initial begin
    check_candidate(32'h00000000, 32'd4, 32'd17, 32'd4);
    check_candidate(32'hffffffff, 32'd4, 32'd17, 32'd16);
    check_candidate(32'hedb6db6e, 32'd3, 32'd17, 32'd16);
    check_candidate(32'h11111112, 32'd2, 32'd17, 32'd3);
    check_candidate(32'hffffffff, 32'd262, 32'd46743, 32'd46742);

    $display("tb_trike_sampler_candidate PASS");
    $finish;
  end
endmodule
