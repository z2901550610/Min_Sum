`timescale 1ns / 1ps

module tb_trike_decaps_pipeline_reference;
  import bike_pkg::*;
  `include "generated/trike_decaps_message_minsum_case.svh"

  localparam int R_BYTES = (REF_R_BITS + 7) / 8;
  localparam int R_ADDR_W = $clog2(R_BYTES);
  localparam int CT_ADDR_W = $clog2(REF_CIPHERTEXT_BYTES);
  localparam int SS_IDX_W = $clog2(REF_M_BYTES);

  logic                       clk;
  logic                       rst_n;
  logic                       start;
  logic                       h_valid;
  logic   [REF_ROW_WIDTH-1:0] h_index;
  logic                       h_ready;
  logic                       t0_valid;
  logic   [   REF_WORD_W-1:0] t0_data;
  logic                       t0_ready;
  logic                       u_valid;
  logic   [   REF_WORD_W-1:0] u_data;
  logic                       u_ready;
  logic                       v_valid;
  logic   [   REF_WORD_W-1:0] v_data;
  logic                       v_ready;
  logic                       c2_valid;
  logic   [              7:0] c2_data;
  logic                       c2_ready;
  logic                       r2_re;
  logic   [     R_ADDR_W-1:0] r2_raddr;
  logic   [              7:0] r2_rdata;
  logic                       ciphertext_re;
  logic   [    CT_ADDR_W-1:0] ciphertext_raddr;
  logic   [              7:0] ciphertext_rdata;
  logic                       residual_zero;
  logic   [    ROW_IDX_W-1:0] residual_weight;
  logic                       ciphertext_equal;
  logic                       shared_secret_valid;
  logic   [     SS_IDX_W-1:0] shared_secret_index;
  logic   [              7:0] shared_secret_data;
  logic                       shared_secret_last;
  logic                       busy;
  logic                       done;
  logic   [              1:0] case_id;
  integer                     h_count;
  integer                     t0_count;
  integer                     u_count;
  integer                     v_count;
  integer                     c2_count;
  integer                     shared_secret_count;
  integer                     cycle_count;

  trike_decaps_pipeline_core #(
      .M_BYTES         (REF_M_BYTES),
      .WORD_W          (REF_WORD_W),
      .CIPHERTEXT_BYTES(REF_CIPHERTEXT_BYTES)
  ) dut (
      .i_clk                (clk),
      .i_rst_n              (rst_n),
      .i_start              (start),
      .i_h_valid            (h_valid),
      .i_h_index            (h_index),
      .o_h_ready            (h_ready),
      .i_t0_valid           (t0_valid),
      .i_t0_data            (t0_data),
      .o_t0_ready           (t0_ready),
      .i_u_valid            (u_valid),
      .i_u_data             (u_data),
      .o_u_ready            (u_ready),
      .i_v_valid            (v_valid),
      .i_v_data             (v_data),
      .o_v_ready            (v_ready),
      .i_sigma2             (REF_SIGMA2),
      .i_c2_valid           (c2_valid),
      .i_c2_data            (c2_data),
      .o_c2_ready           (c2_ready),
      .o_r2_re              (r2_re),
      .o_r2_raddr           (r2_raddr),
      .i_r2_rdata           (r2_rdata),
      .o_ciphertext_re      (ciphertext_re),
      .o_ciphertext_raddr   (ciphertext_raddr),
      .i_ciphertext_rdata   (ciphertext_rdata),
      .o_residual_zero      (residual_zero),
      .o_residual_weight    (residual_weight),
      .o_ciphertext_equal   (ciphertext_equal),
      .o_shared_secret_valid(shared_secret_valid),
      .o_shared_secret_index(shared_secret_index),
      .o_shared_secret_data (shared_secret_data),
      .o_shared_secret_last (shared_secret_last),
      .i_shared_secret_ready(1'b1),
      .o_busy               (busy),
      .o_done               (done)
  );

  always #1 clk = ~clk;

  always_comb begin
    h_valid = h_count < (REF_BLOCKS * REF_SECRET_WEIGHT);
    h_index = REF_H_SUPPORT_RAW[REF_ROW_WIDTH*((h_count<(REF_BLOCKS*REF_SECRET_WEIGHT))?h_count:0)+:
                                REF_ROW_WIDTH];
    t0_valid = t0_count < REF_WORDS;
    t0_data = REF_T0_WORDS[REF_WORD_W*((t0_count<REF_WORDS)?t0_count : 0)+:REF_WORD_W];
    u_valid = u_count < REF_WORDS;
    u_data = (case_id == 2'd1) ?
        REF_U_TAMPERED_WORDS[REF_WORD_W*((u_count<REF_WORDS)?u_count:0)+:REF_WORD_W] :
        REF_U_WORDS[REF_WORD_W*((u_count<REF_WORDS)?u_count:0)+:REF_WORD_W];
    v_valid = v_count < REF_WORDS;
    v_data = (case_id == 2'd2) ?
        REF_V_TAMPERED_WORDS[REF_WORD_W*((v_count<REF_WORDS)?v_count:0)+:REF_WORD_W] :
        REF_V_WORDS[REF_WORD_W*((v_count<REF_WORDS)?v_count:0)+:REF_WORD_W];
    c2_valid = c2_count < REF_M_BYTES;
    c2_data = (case_id == 2'd3) ?
        REF_TAMPERED_C2[8*((c2_count<REF_M_BYTES)?c2_count:0)+:8] :
        REF_C2[8*((c2_count<REF_M_BYTES)?c2_count:0)+:8];
  end

  always_ff @(posedge clk) begin
    if (r2_re) r2_rdata <= REF_R2[8*r2_raddr+:8];
    if (ciphertext_re) begin
      unique case (case_id)
        2'd1: ciphertext_rdata <= REF_U_TAMPERED_CIPHERTEXT[8*ciphertext_raddr+:8];
        2'd2: ciphertext_rdata <= REF_V_TAMPERED_CIPHERTEXT[8*ciphertext_raddr+:8];
        2'd3: ciphertext_rdata <= REF_TAMPERED_CIPHERTEXT[8*ciphertext_raddr+:8];
        default: ciphertext_rdata <= REF_CIPHERTEXT[8*ciphertext_raddr+:8];
      endcase
    end

    if (!rst_n) begin
      h_count <= 0;
      t0_count <= 0;
      u_count <= 0;
      v_count <= 0;
      c2_count <= 0;
      shared_secret_count <= 0;
      cycle_count <= 0;
      r2_rdata <= '0;
      ciphertext_rdata <= '0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (h_valid && h_ready) h_count <= h_count + 1;
      if (t0_valid && t0_ready) t0_count <= t0_count + 1;
      if (u_valid && u_ready) u_count <= u_count + 1;
      if (v_valid && v_ready) v_count <= v_count + 1;
      if (c2_valid && c2_ready) c2_count <= c2_count + 1;
      if (shared_secret_valid) begin
        if (shared_secret_index != SS_IDX_W'(shared_secret_count))
          $fatal(1, "pipeline shared-secret index mismatch");
        if (shared_secret_last != (shared_secret_count == (REF_M_BYTES - 1)))
          $fatal(1, "pipeline shared-secret last mismatch");
        unique case (case_id)
          2'd1: begin
            if (shared_secret_data != REF_U_TAMPERED_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "u-tampered shared-secret mismatch at byte %0d", shared_secret_count);
          end
          2'd2: begin
            if (shared_secret_data != REF_V_TAMPERED_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "v-tampered shared-secret mismatch at byte %0d", shared_secret_count);
          end
          2'd3: begin
            if (shared_secret_data != REF_TAMPERED_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "c2-tampered shared-secret mismatch at byte %0d", shared_secret_count);
          end
          default: begin
            if (shared_secret_data != REF_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "valid shared-secret mismatch at byte %0d", shared_secret_count);
          end
        endcase
        shared_secret_count <= shared_secret_count + 1;
      end
    end
  end

  task automatic reset_pipeline;
    begin
      rst_n = 1'b0;
      repeat (4) @(negedge clk);
      rst_n = 1'b1;
      repeat (3) @(negedge clk);
    end
  endtask

  task automatic run_case(input  logic [1:0] selected_case, input  logic expect_residual_zero,
                          output integer latency, output integer observed_residual);
    integer start_cycle;
    begin
      case_id = selected_case;
      reset_pipeline();
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "Decaps pipeline did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (h_count != (REF_BLOCKS * REF_SECRET_WEIGHT)) $fatal(1, "H count mismatch");
      if ((t0_count != REF_WORDS) || (u_count != REF_WORDS) || (v_count != REF_WORDS))
        $fatal(1, "polynomial word count mismatch");
      if (c2_count != REF_M_BYTES) $fatal(1, "c2 count mismatch");
      if (shared_secret_count != REF_M_BYTES) $fatal(1, "shared-secret byte count mismatch");
      if (residual_zero != expect_residual_zero) $fatal(1, "decoder residual-zero mismatch");
      observed_residual = integer'(residual_weight);
      if (ciphertext_equal != (selected_case == 0)) $fatal(1, "ciphertext equality mismatch");
    end
  endtask

  initial begin
    integer valid_latency;
    integer u_tampered_latency;
    integer v_tampered_latency;
    integer c2_tampered_latency;
    integer valid_residual;
    integer u_tampered_residual;
    integer v_tampered_residual;
    integer c2_tampered_residual;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    case_id = 2'd0;

    run_case(2'd0, 1'b1, valid_latency, valid_residual);
    run_case(2'd1, 1'b0, u_tampered_latency, u_tampered_residual);
    run_case(2'd2, 1'b0, v_tampered_latency, v_tampered_residual);
    run_case(2'd3, 1'b1, c2_tampered_latency, c2_tampered_residual);
    if ((valid_latency != u_tampered_latency) || (valid_latency != v_tampered_latency) ||
        (valid_latency != c2_tampered_latency))
      $fatal(1, "data-dependent full Decaps latency");

    $display("tb_trike_decaps_pipeline_reference PASS cycles=%0d residuals=%0d/%0d/%0d/%0d",
             valid_latency, valid_residual, u_tampered_residual, v_tampered_residual,
             c2_tampered_residual);
    $display("nonconvergent C-model residuals u/v=%0d/%0d", REF_U_TAMPERED_RESIDUAL_WEIGHT,
             REF_V_TAMPERED_RESIDUAL_WEIGHT);
    $finish;
  end

  initial begin
    repeat (120000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_pipeline_reference timeout");
  end

endmodule
