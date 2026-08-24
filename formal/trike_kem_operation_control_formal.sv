`timescale 1ns / 1ps

module trike_kem_operation_control_formal;

  (* gclk *) logic       clk;
  (* anyseq *) logic       rst_n;
  (* anyseq *) logic       start;
  (* anyseq *) logic [1:0] operation;
  (* anyseq *) logic       keygen_done;
  (* anyseq *) logic       encaps_done;
  (* anyseq *) logic       decaps_done;
  logic       keygen_start;
  logic       encaps_start;
  logic       decaps_start;
  logic [1:0] active_operation;
  logic       busy;
  logic       done;
  logic       error;

  trike_kem_operation_control dut (
      .i_clk             (clk),
      .i_rst_n           (rst_n),
      .i_start           (start),
      .i_operation       (operation),
      .i_keygen_done     (keygen_done),
      .i_encaps_done     (encaps_done),
      .i_decaps_done     (decaps_done),
      .o_keygen_start    (keygen_start),
      .o_encaps_start    (encaps_start),
      .o_decaps_start    (decaps_start),
      .o_active_operation(active_operation),
      .o_busy            (busy),
      .o_done            (done),
      .o_error           (error)
  );

  always_ff @(posedge clk) begin
    if ($initstate) begin
      assume (!rst_n);
    end else begin
      assume (rst_n);
    end

    assert ($onehot0({keygen_start, encaps_start, decaps_start}));
    if (busy) assert (!(keygen_start || encaps_start || decaps_start));
    if (!$initstate && $past(rst_n && busy) && !$past(done))
      assert (active_operation == $past(active_operation));

    cover (rst_n && keygen_start);
    cover (rst_n && encaps_start);
    cover (rst_n && decaps_start);
    cover (rst_n && done && !error);
    cover (rst_n && done && error);
  end

endmodule
