module workflow_counter_formal;

  localparam int unsigned WIDTH = 4;

  (* gclk *) logic clk;
  logic rst_n = 1'b0;
  (* anyseq *) logic enable;
  (* anyseq *) logic load;
  (* anyseq *) logic [WIDTH-1:0] load_value;
  logic [WIDTH-1:0] count;
  logic wrap;
  logic past_valid = 1'b0;

  workflow_counter #(
      .WIDTH(WIDTH)
  ) dut (
      .i_clk       (clk),
      .i_rst_n     (rst_n),
      .i_enable    (enable),
      .i_load      (load),
      .i_load_value(load_value),
      .o_count     (count),
      .o_wrap      (wrap)
  );

  always_ff @(posedge clk) begin
    past_valid <= 1'b1;
    rst_n      <= 1'b1;

    if (past_valid) begin
      if (!$past(rst_n)) begin
        assert (count == '0);
        assert (!wrap);
      end else begin
        if ($past(load)) begin
          assert (count == $past(load_value));
          assert (!wrap);
        end else if ($past(enable)) begin
          assert (count == $past(count) + 1'b1);
          assert (wrap == &$past(count));
        end else begin
          assert (count == $past(count));
          assert (!wrap);
        end
      end
    end

    cover (past_valid && count == {WIDTH{1'b1}});
    cover (past_valid && wrap && count == '0);
  end

endmodule
