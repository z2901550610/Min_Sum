`timescale 1ns / 1ps

module tb_trike_decaps_synth_reference;
  `include "generated/trike_decaps_message_minsum_case.svh"

  localparam int INPUT_BYTES = REF_SECRET_KEY_BYTES + REF_CIPHERTEXT_BYTES;

  logic         clk;
  logic         rst_n;
  logic         start;
  logic         input_valid;
  logic   [7:0] input_data;
  logic         input_ready;
  logic         shared_secret_valid;
  logic   [7:0] shared_secret_data;
  logic         shared_secret_last;
  logic         residual_zero;
  logic         ciphertext_equal;
  logic         busy;
  logic         done;
  logic   [1:0] case_id;
  integer       input_count;
  integer       shared_secret_count;
  integer       cycle_count;

  trike_decaps_synth_top dut (
      .i_clk                (clk),
      .i_rst_n              (rst_n),
      .i_start              (start),
      .i_input_valid        (input_valid),
      .i_input_data         (input_data),
      .o_input_ready        (input_ready),
      .o_shared_secret_valid(shared_secret_valid),
      .o_shared_secret_data (shared_secret_data),
      .o_shared_secret_last (shared_secret_last),
      .i_shared_secret_ready(1'b1),
      .o_residual_zero      (residual_zero),
      .o_ciphertext_equal   (ciphertext_equal),
      .o_busy               (busy),
      .o_done               (done)
  );

  always #1 clk = ~clk;

  always_comb begin
    input_valid = input_count < INPUT_BYTES;
    input_data  = '0;
    if (input_count < REF_SECRET_KEY_BYTES) begin
      input_data = REF_SECRET_KEY[8*input_count+:8];
    end else if (input_count < INPUT_BYTES) begin
      unique case (case_id)
        2'd1: input_data = REF_U_TAMPERED_CIPHERTEXT[8*(input_count-REF_SECRET_KEY_BYTES)+:8];
        2'd2: input_data = REF_V_TAMPERED_CIPHERTEXT[8*(input_count-REF_SECRET_KEY_BYTES)+:8];
        2'd3: input_data = REF_TAMPERED_CIPHERTEXT[8*(input_count-REF_SECRET_KEY_BYTES)+:8];
        default: input_data = REF_CIPHERTEXT[8*(input_count-REF_SECRET_KEY_BYTES)+:8];
      endcase
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      input_count <= 0;
      shared_secret_count <= 0;
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (input_valid && input_ready) input_count <= input_count + 1;
      if (shared_secret_valid) begin
        if (shared_secret_last != (shared_secret_count == (REF_M_BYTES - 1)))
          $fatal(1, "wrapper shared-secret last mismatch");
        unique case (case_id)
          2'd1: begin
            if (shared_secret_data != REF_U_TAMPERED_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "wrapper u-tampered SS mismatch at byte %0d", shared_secret_count);
          end
          2'd2: begin
            if (shared_secret_data != REF_V_TAMPERED_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "wrapper v-tampered SS mismatch at byte %0d", shared_secret_count);
          end
          2'd3: begin
            if (shared_secret_data != REF_TAMPERED_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "wrapper c2-tampered SS mismatch at byte %0d", shared_secret_count);
          end
          default: begin
            if (shared_secret_data != REF_SHARED_SECRET[8*shared_secret_count+:8])
              $fatal(1, "wrapper valid SS mismatch at byte %0d", shared_secret_count);
          end
        endcase
        shared_secret_count <= shared_secret_count + 1;
      end
    end
  end

  task automatic reset_wrapper;
    begin
      rst_n = 1'b0;
      repeat (6) @(negedge clk);
      rst_n = 1'b1;
      repeat (4) @(negedge clk);
    end
  endtask

  task automatic run_case(input  logic [1:0] selected_case, input  logic expect_residual_zero,
                          output integer latency);
    integer start_cycle;
    begin
      case_id = selected_case;
      reset_wrapper();
      @(negedge clk);
      start = 1'b1;
      start_cycle = cycle_count;
      @(negedge clk);
      start = 1'b0;
      if (!busy) $fatal(1, "Decaps wrapper did not become busy");
      while (!done) @(negedge clk);
      latency = cycle_count - start_cycle;
      if (input_count != INPUT_BYTES) $fatal(1, "wrapper input byte count mismatch");
      if (shared_secret_count != REF_M_BYTES) $fatal(1, "wrapper SS byte count mismatch");
      if (residual_zero != expect_residual_zero) $fatal(1, "wrapper residual-zero mismatch");
      if (ciphertext_equal != (selected_case == 0))
        $fatal(1, "wrapper ciphertext equality mismatch");
    end
  endtask

  initial begin
    integer valid_latency;
    integer u_tampered_latency;
    integer v_tampered_latency;
    integer c2_tampered_latency;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    case_id = 2'd0;

    run_case(2'd0, 1'b1, valid_latency);
    run_case(2'd1, 1'b0, u_tampered_latency);
    run_case(2'd2, 1'b0, v_tampered_latency);
    run_case(2'd3, 1'b1, c2_tampered_latency);
    if ((valid_latency != u_tampered_latency) || (valid_latency != v_tampered_latency) ||
        (valid_latency != c2_tampered_latency))
      $fatal(1, "data-dependent Decaps wrapper latency");

    $display("tb_trike_decaps_synth_reference PASS cycles=%0d", valid_latency);
    $finish;
  end

  initial begin
    repeat (140000000) @(posedge clk);
    $fatal(1, "tb_trike_decaps_synth_reference timeout");
  end

endmodule
