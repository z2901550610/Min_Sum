`timescale 1ns/1ps

module tb_mdpc_decoder_paper;
  import mdpc_paper_pkg::*;

  localparam int ERR_COUNT = 84;
  localparam int TIMEOUT_CYCLES = 50_000_000;
  localparam int ERR_POS [0:ERR_COUNT-1] = '{
    122, 233, 251, 343, 372, 373, 441, 455, 529, 616, 618, 619,
    711, 1086, 1093, 1224, 1311, 1312, 1316, 1366, 1423, 1555, 1598, 1681,
    1819, 2282, 2754, 2771, 2814, 2816, 2983, 3024, 3033, 3042, 3152, 3167,
    3266, 3447, 3540, 3719, 3841, 3883, 3986, 4006, 4241, 4331, 4439, 4748,
    4750, 4765, 5181, 5184, 5308, 5354, 5484, 5643, 5859, 5975, 6040, 6045,
    6093, 6232, 6283, 6307, 6483, 6664, 6796, 6996, 7082, 7144, 7207, 7247,
    7576, 7823, 7829, 7933, 8259, 8346, 8381, 8427, 8740, 8764, 8788, 9322
  };

  logic clk;
  logic rst_n;
  logic start;
  logic [H_SEL_W-1:0] h_sel;
  logic [N-1:0] x_in;
  logic done;
  logic success;
  logic [N-1:0] x_out;
  logic [$clog2(I_MAX + 1)-1:0] iter_count;

  decoder_top dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_h_sel(h_sel),
    .i_x(x_in),
    .o_done(done),
    .o_success(success),
    .o_x(x_out),
    .o_iter_count(iter_count)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic apply_reset;
    begin
      rst_n = 1'b0;
      start = 1'b0;
      x_in = '0;
      repeat (2) @(posedge clk);
      rst_n = 1'b1;
      @(posedge clk);
    end
  endtask

  task automatic run_case;
    int idx;
    int cycles;
    int out_weight;
    begin
      h_sel = '0;
      apply_reset();

      x_in = '0;
      for (idx = 0; idx < ERR_COUNT; idx++) begin
        x_in[ERR_POS[idx]] = 1'b1;
      end

      start = 1'b1;
      @(posedge clk);
      start = 1'b0;

      cycles = 0;
      while ((done !== 1'b1) && (cycles < TIMEOUT_CYCLES)) begin
        @(posedge clk);
        cycles++;
      end

      if (done !== 1'b1) begin
        $fatal(1, "paper case timed out after %0d cycles", cycles);
      end

      @(posedge clk);
      out_weight = 0;
      for (idx = 0; idx < N; idx++) begin
        out_weight += int'(x_out[idx]);
      end

      $display("paper case: success=%0d iterations=%0d out_weight=%0d cycles=%0d",
               success, iter_count, out_weight, cycles);

      if (success !== 1'b1) begin
        $fatal(1, "paper case did not report success");
      end
      if (int'(iter_count) != 4) begin
        $fatal(1, "paper case iterations mismatch: got %0d exp 4", iter_count);
      end
      if (out_weight != 0) begin
        $fatal(1, "paper case did not recover zero codeword: output weight=%0d", out_weight);
      end
    end
  endtask

  initial begin
    h_sel = '0;
    rst_n = 1'b0;
    start = 1'b0;
    x_in = '0;

    run_case();

    $display("tb_mdpc_decoder_paper PASS");
    $finish;
  end
endmodule
