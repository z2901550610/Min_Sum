`timescale 1ns / 1ps

module tb_trike_decaps_syndrome_reference;
  `include "generated/trike_decaps_syndrome_reference_case.svh"

  logic                     clk;
  logic                     rst_n;
  logic                     start;
  logic                     h0_valid;
  logic   [REF_INDEX_W-1:0] h0_index;
  logic                     h0_ready;
  logic                     t0_valid;
  logic   [ REF_WORD_W-1:0] t0_data;
  logic                     t0_ready;
  logic                     u_valid;
  logic   [ REF_WORD_W-1:0] u_data;
  logic                     u_ready;
  logic                     v_valid;
  logic   [ REF_WORD_W-1:0] v_data;
  logic                     v_ready;
  logic                     syndrome_valid;
  logic   [ REF_WORD_W-1:0] syndrome_data;
  logic                     syndrome_last;
  logic                     syndrome_ready;
  logic                     busy;
  logic                     done;

  integer                   h0_count;
  integer                   t0_count;
  integer                   u_count;
  integer                   v_count;
  integer                   syndrome_count;
  integer                   busy_cycles;

  trike_decaps_syndrome_core #(
      .R_BITS       (REF_R_BITS),
      .SECRET_WEIGHT(REF_SECRET_WEIGHT),
      .WORD_W       (REF_WORD_W),
      .DIGIT_W      (8)
  ) dut (
      .i_clk           (clk),
      .i_rst_n         (rst_n),
      .i_start         (start),
      .i_h0_valid      (h0_valid),
      .i_h0_index      (h0_index),
      .o_h0_ready      (h0_ready),
      .i_t0_valid      (t0_valid),
      .i_t0_data       (t0_data),
      .o_t0_ready      (t0_ready),
      .i_u_valid       (u_valid),
      .i_u_data        (u_data),
      .o_u_ready       (u_ready),
      .i_v_valid       (v_valid),
      .i_v_data        (v_data),
      .o_v_ready       (v_ready),
      .o_syndrome_valid(syndrome_valid),
      .o_syndrome_data (syndrome_data),
      .o_syndrome_last (syndrome_last),
      .i_syndrome_ready(syndrome_ready),
      .o_busy          (busy),
      .o_done          (done)
  );

  always #1 clk = ~clk;

  always_comb begin
    h0_valid = (h0_count < REF_SECRET_WEIGHT);
    h0_index = REF_H0_SUPPORT[(h0_count<REF_SECRET_WEIGHT)?h0_count : 0];
    t0_valid = (t0_count < REF_WORDS);
    t0_data  = REF_T0_WORDS[(t0_count<REF_WORDS)?t0_count : 0];
    u_valid  = (u_count < REF_WORDS);
    u_data   = REF_U_WORDS[(u_count<REF_WORDS)?u_count : 0];
    v_valid  = (v_count < REF_WORDS);
    v_data   = REF_V_WORDS[(v_count<REF_WORDS)?v_count : 0];
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      h0_count <= 0;
      t0_count <= 0;
      u_count <= 0;
      v_count <= 0;
      syndrome_count <= 0;
      busy_cycles <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;
      if (h0_valid && h0_ready) h0_count <= h0_count + 1;
      if (t0_valid && t0_ready) t0_count <= t0_count + 1;
      if (u_valid && u_ready) u_count <= u_count + 1;
      if (v_valid && v_ready) v_count <= v_count + 1;
      if (syndrome_valid && syndrome_ready) begin
        if (syndrome_data != REF_SYNDROME_WORDS[syndrome_count]) begin
          $fatal(1, "syndrome mismatch word=%0d got=%h expected=%h", syndrome_count, syndrome_data,
                 REF_SYNDROME_WORDS[syndrome_count]);
        end
        if (syndrome_last != (syndrome_count == (REF_WORDS - 1))) begin
          $fatal(1, "syndrome last mismatch word=%0d", syndrome_count);
        end
        syndrome_count <= syndrome_count + 1;
      end
    end
  end

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    syndrome_ready = 1'b1;

    repeat (3) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    while (!done && (busy_cycles < 4000000)) @(negedge clk);
    if (!done) $fatal(1, "decaps syndrome reference timeout");
    if (h0_count != REF_SECRET_WEIGHT) $fatal(1, "h0 transfer count mismatch");
    if (t0_count != REF_WORDS) $fatal(1, "t0 transfer count mismatch");
    if (u_count != REF_WORDS) $fatal(1, "u transfer count mismatch");
    if (v_count != REF_WORDS) $fatal(1, "v transfer count mismatch");
    if (syndrome_count != REF_WORDS) $fatal(1, "syndrome transfer count mismatch");

    $display("tb_trike_decaps_syndrome_reference PASS cycles=%0d", busy_cycles);
    $finish;
  end

endmodule
