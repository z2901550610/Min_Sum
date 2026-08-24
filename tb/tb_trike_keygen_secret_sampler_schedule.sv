`timescale 1ns / 1ps

module tb_trike_keygen_secret_sampler_schedule;

  `include "generated/trike_keygen_reference_case.svh"

  localparam int POSITION_W = $clog2(REF_SECRET_WEIGHT);
  localparam int CANDIDATE_W = $clog2(REF_CANDIDATE_COUNT);
  localparam int EXPECTED_BUSY_CYCLES = 4778975;

  logic                   clk;
  logic                   rst_n;
  logic                   start;
  logic                   seed_valid;
  logic [            7:0] seed_data;
  logic                   seed_ready;
  logic                   seed_pass;
  logic                   support_valid;
  logic [            1:0] support_block;
  logic [ POSITION_W-1:0] support_position;
  logic [REF_INDEX_W-1:0] support_index;
  logic                   busy;
  logic                   done;
  logic                   success;
  logic [CANDIDATE_W-1:0] selected_candidate;
  logic [          191:0] selected_scores;
  logic [          439:0] final_v;
  logic [          439:0] final_c;
  logic [          439:0] final_reseed_counter;

  int                     seed_index;
  int                     received_count;
  int                     busy_cycles;

  assign seed_data = REF_ALT_KEY_SEED[seed_index];

  /* verilator lint_off PINCONNECTEMPTY */
  trike_keygen_secret_sampler #(
      .M_BYTES        (32),
      .R_BITS         (REF_R_BITS),
      .SECRET_WEIGHT  (REF_SECRET_WEIGHT),
      .CANDIDATE_COUNT(REF_CANDIDATE_COUNT)
  ) dut (
      .i_clk                   (clk),
      .i_rst_n                 (rst_n),
      .i_start                 (start),
      .i_seed_valid            (seed_valid),
      .i_seed_data             (seed_data),
      .o_seed_ready            (seed_ready),
      .o_seed_pass             (seed_pass),
      .o_support_valid         (support_valid),
      .o_support_block         (support_block),
      .o_support_position      (support_position),
      .o_support_index         (support_index),
      .i_support_ready         (1'b1),
      .o_busy                  (busy),
      .o_done                  (done),
      .o_success               (success),
      .o_selected_candidate    (selected_candidate),
      .o_selected_scores       (selected_scores),
      .o_v                     (final_v),
      .o_c                     (final_c),
      .o_reseed_counter        (final_reseed_counter),
      .o_compress_start        (),
      .o_compress_block        (),
      .o_compress_state        (),
      .i_compress_busy         (1'b0),
      .i_compress_done         (1'b0),
      .i_compress_state        ('0),
      .o_sampler_start         (),
      .o_sampler_runtime_length(),
      .o_sampler_runtime_weight(),
      .o_sampler_v             (),
      .o_sampler_c             (),
      .o_sampler_reseed_counter(),
      .i_sampler_index_valid   (1'b0),
      .i_sampler_index_position('0),
      .i_sampler_index         ('0),
      .o_sampler_index_ready   (),
      .i_sampler_done          (1'b0),
      .i_sampler_v             ('0),
      .i_sampler_c             ('0),
      .i_sampler_reseed_counter('0)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy_cycles <= 0;
      received_count <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;
      if (support_valid) begin
        if (support_index !=
            REF_ALT_SELECTED_SUPPORT[int'(support_block)*REF_SECRET_WEIGHT+
                                     int'(support_position)]) begin
          $fatal(1, "alternate support mismatch block=%0d position=%0d", support_block,
                 support_position);
        end
        received_count <= received_count + 1;
      end
    end
  end

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    seed_valid = 1'b0;
    seed_index = 0;

    repeat (4) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    seed_valid = 1'b1;
    for (int pass = 0; pass < 2; pass++) begin
      seed_index = 0;
      while (seed_index < 32) begin
        @(posedge clk);
        if (seed_valid && seed_ready) begin
          if (seed_pass != pass[0]) begin
            $fatal(1, "seed pass mismatch got=%0d expected=%0d", seed_pass, pass);
          end
          @(negedge clk);
          seed_index++;
        end
      end
    end
    seed_valid = 1'b0;

    wait (done);
    #1;
    if (!success) $fatal(1, "alternate fixed candidate budget failed");
    if (selected_candidate != CANDIDATE_W'(REF_ALT_SELECTED_CANDIDATE)) begin
      $fatal(1, "alternate selected candidate mismatch got=%0d expected=%0d", selected_candidate,
             REF_ALT_SELECTED_CANDIDATE);
    end
    if (received_count != 3 * REF_SECRET_WEIGHT) begin
      $fatal(1, "alternate support count mismatch got=%0d", received_count);
    end
    for (int score_index = 0; score_index < 6; score_index++) begin
      if (selected_scores[32*score_index+:32] != REF_ALT_SELECTED_SCORES[score_index]) begin
        $fatal(1, "alternate score %0d mismatch got=%0d expected=%0d", score_index,
               selected_scores[32*score_index+:32], REF_ALT_SELECTED_SCORES[score_index]);
      end
    end
    if (final_v != REF_ALT_FINAL_V || final_c != REF_ALT_FINAL_C ||
        final_reseed_counter != REF_ALT_FINAL_RESEED) begin
      $fatal(1, "alternate final DRNG state mismatch");
    end
    if (busy_cycles != EXPECTED_BUSY_CYCLES) begin
      $fatal(1, "alternate cycle mismatch got=%0d expected=%0d", busy_cycles, EXPECTED_BUSY_CYCLES);
    end

    $display("tb_trike_keygen_secret_sampler_schedule PASS selected=%0d cycles=%0d",
             selected_candidate, busy_cycles);
    $finish;
  end

  initial begin
    repeat (8000000) @(posedge clk);
    $fatal(1, "tb_trike_keygen_secret_sampler_schedule timeout");
  end

endmodule
