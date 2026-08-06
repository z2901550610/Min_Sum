`timescale 1ns / 1ps

// Fixed-candidate TRIKE KeyGen secret-support generation.
//
// The seed is instantiated once. Every candidate consumes three consecutive
// fixed-weight samples for h0, h1, and h2, followed by all six Reference C
// weak-key tests. Exactly CANDIDATE_COUNT candidates are evaluated. The first
// acceptable candidate is retained with a data mask; candidate acceptance does
// not change the state schedule, SM3 call count, or weak-test RAM addresses.
module trike_keygen_secret_sampler #(
    parameter int M_BYTES               = 32,
    parameter int R_BITS                = 15581,
    parameter int SECRET_WEIGHT         = 35,
    parameter int CANDIDATE_COUNT       = 16,
    parameter int SELF_THRESHOLD        = 46,
    parameter int CROSS_THRESHOLD       = 83,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0
) (
    input  logic                                                             i_clk,
    input  logic                                                             i_rst_n,
    input  logic                                                             i_start,
    input  logic                                                             i_seed_valid,
    input  logic [                                                      7:0] i_seed_data,
    output logic                                                             o_seed_ready,
    output logic                                                             o_seed_pass,
    output logic                                                             o_support_valid,
    output logic [                                                      1:0] o_support_block,
    output logic [    ((SECRET_WEIGHT > 1) ? $clog2(SECRET_WEIGHT) : 1)-1:0] o_support_position,
    output logic [                  ((R_BITS > 1) ? $clog2(R_BITS) : 1)-1:0] o_support_index,
    input  logic                                                             i_support_ready,
    output logic                                                             o_busy,
    output logic                                                             o_done,
    output logic                                                             o_success,
    output logic [((CANDIDATE_COUNT > 1) ? $clog2(CANDIDATE_COUNT) : 1)-1:0] o_selected_candidate,
    output logic [                                                    191:0] o_selected_scores,
    output logic [                                                    439:0] o_v,
    output logic [                                                    439:0] o_c,
    output logic [                                                    439:0] o_reseed_counter,
    output logic                                                             o_compress_start,
    output logic [                                                    511:0] o_compress_block,
    output logic [                                                    255:0] o_compress_state,
    input  logic                                                             i_compress_busy,
    input  logic                                                             i_compress_done,
    input  logic [                                                    255:0] i_compress_state
);

  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int POSITION_W = (SECRET_WEIGHT > 1) ? $clog2(SECRET_WEIGHT) : 1;
  localparam int CANDIDATE_W = (CANDIDATE_COUNT > 1) ? $clog2(CANDIDATE_COUNT) : 1;

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_START_INSTANTIATE,
    ST_WAIT_INSTANTIATE,
    ST_START_SAMPLE,
    ST_WAIT_SAMPLE,
    ST_START_WEAK_TEST,
    ST_WAIT_WEAK_TEST,
    ST_COPY_SELECTED,
    ST_OUTPUT
  } state_t;

  state_t                   state_q;

  logic   [    INDEX_W-1:0] candidate_support_q[0:2][0:SECRET_WEIGHT-1];
  logic   [    INDEX_W-1:0] selected_support_q[0:2][0:SECRET_WEIGHT-1];
  logic   [            1:0] sample_block_q;
  logic   [CANDIDATE_W-1:0] candidate_q;
  logic   [            1:0] copy_block_q;
  logic   [ POSITION_W-1:0] copy_position_q;
  logic   [            1:0] output_block_q;
  logic   [ POSITION_W-1:0] output_position_q;
  logic                     selected_valid_q;
  logic                     take_candidate_q;
  logic   [          439:0] v_q;
  logic   [          439:0] c_q;
  logic   [          439:0] reseed_counter_q;

  logic                     instantiate_start;
  logic                     instantiate_seed_ready;
  logic                     instantiate_seed_pass;
  logic                     instantiate_done;
  logic   [          439:0] instantiate_v;
  logic   [          439:0] instantiate_c;
  logic   [          439:0] instantiate_reseed_counter;
  logic                     instantiate_compress_start;
  logic   [          511:0] instantiate_compress_block;
  logic   [          255:0] instantiate_compress_state;

  logic                     sample_start;
  logic                     sample_index_valid;
  logic   [ POSITION_W-1:0] sample_index_position;
  logic   [    INDEX_W-1:0] sample_index;
  logic                     sample_index_ready;
  logic                     sample_done;
  logic   [          439:0] sample_v;
  logic   [          439:0] sample_c;
  logic   [          439:0] sample_reseed_counter;
  logic                     sample_compress_start;
  logic   [          511:0] sample_compress_block;
  logic   [          255:0] sample_compress_state;

  logic                     weak_support_ready;
  logic                     weak_start;
  logic                     weak_done;
  logic                     weak_result;
  logic   [          191:0] weak_scores;

  logic                     select_sample_compress;
  logic                     shared_compress_start;
  logic   [          511:0] shared_compress_block;
  logic   [          255:0] shared_compress_state;
  logic                     shared_compress_busy;
  logic                     shared_compress_done;
  logic   [          255:0] shared_compress_result;
  logic                     internal_compress_busy;
  logic                     internal_compress_done;
  logic   [          255:0] internal_compress_result;

  assign instantiate_start = state_q == ST_START_INSTANTIATE;
  assign sample_start = state_q == ST_START_SAMPLE;
  assign weak_start = state_q == ST_START_WEAK_TEST;

  assign o_seed_ready = (state_q == ST_WAIT_INSTANTIATE) && instantiate_seed_ready;
  assign o_seed_pass = instantiate_seed_pass;

  assign sample_index_ready = (state_q == ST_WAIT_SAMPLE) && weak_support_ready;
  assign o_support_valid = state_q == ST_OUTPUT;
  assign o_support_block = output_block_q;
  assign o_support_position = output_position_q;
  assign o_support_index = selected_support_q[output_block_q][output_position_q];
  assign o_busy = state_q != ST_IDLE;
  assign o_success = selected_valid_q;
  assign o_v = v_q;
  assign o_c = c_q;
  assign o_reseed_counter = reseed_counter_q;

  assign select_sample_compress = (state_q == ST_START_SAMPLE) || (state_q == ST_WAIT_SAMPLE);
  assign shared_compress_start =
      select_sample_compress ? sample_compress_start : instantiate_compress_start;
  assign shared_compress_block =
      select_sample_compress ? sample_compress_block : instantiate_compress_block;
  assign shared_compress_state =
      select_sample_compress ? sample_compress_state : instantiate_compress_state;
  assign o_compress_start = shared_compress_start;
  assign o_compress_block = shared_compress_block;
  assign o_compress_state = shared_compress_state;
  assign shared_compress_busy = USE_EXTERNAL_COMPRESS ? i_compress_busy : internal_compress_busy;
  assign shared_compress_done = USE_EXTERNAL_COMPRESS ? i_compress_done : internal_compress_done;
  assign shared_compress_result =
      USE_EXTERNAL_COMPRESS ? i_compress_state : internal_compress_result;

  trike_sm3_drng_instantiate_stream #(
      .SEED_BYTES           (M_BYTES),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_instantiate (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (instantiate_start),
      .i_seed_valid    (i_seed_valid && (state_q == ST_WAIT_INSTANTIATE)),
      .i_seed_data     (i_seed_data),
      .o_seed_ready    (instantiate_seed_ready),
      .o_seed_pass     (instantiate_seed_pass),
      .o_busy          (),
      .o_done          (instantiate_done),
      .o_v             (instantiate_v),
      .o_c             (instantiate_c),
      .o_reseed_counter(instantiate_reseed_counter),
      .o_compress_start(instantiate_compress_start),
      .o_compress_block(instantiate_compress_block),
      .o_compress_state(instantiate_compress_state),
      .i_compress_busy (shared_compress_busy),
      .i_compress_done (shared_compress_done),
      .i_compress_state(shared_compress_result)
  );

  trike_drng_weight_sampler #(
      .LENGTH               (R_BITS),
      .WEIGHT               (SECRET_WEIGHT),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_sampler (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (sample_start),
      .i_v             (v_q),
      .i_c             (c_q),
      .i_reseed_counter(reseed_counter_q),
      .o_index_valid   (sample_index_valid),
      .o_index_position(sample_index_position),
      .o_index         (sample_index),
      .i_index_ready   (sample_index_ready),
      .o_busy          (),
      .o_done          (sample_done),
      .o_v             (sample_v),
      .o_c             (sample_c),
      .o_reseed_counter(sample_reseed_counter),
      .o_compress_start(sample_compress_start),
      .o_compress_block(sample_compress_block),
      .o_compress_state(sample_compress_state),
      .i_compress_busy (shared_compress_busy),
      .i_compress_done (shared_compress_done),
      .i_compress_state(shared_compress_result)
  );

  trike_weak_key_test #(
      .R_BITS         (R_BITS),
      .WEIGHT         (SECRET_WEIGHT),
      .SELF_THRESHOLD (SELF_THRESHOLD),
      .CROSS_THRESHOLD(CROSS_THRESHOLD)
  ) u_weak_key_test (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_support_valid   (sample_index_valid && sample_index_ready),
      .i_support_block   (sample_block_q),
      .i_support_position(sample_index_position),
      .i_support_index   (sample_index),
      .o_support_ready   (weak_support_ready),
      .i_start           (weak_start),
      .o_busy            (),
      .o_done            (weak_done),
      .o_weak            (weak_result),
      .o_scores          (weak_scores)
  );

  generate
    if (!USE_EXTERNAL_COMPRESS) begin : g_internal_compress
      trike_sm3_service u_sm3_service (
          .i_clk  (i_clk),
          .i_rst_n(i_rst_n),
          .i_start(shared_compress_start),
          .i_block(shared_compress_block),
          .i_state(shared_compress_state),
          .o_busy (internal_compress_busy),
          .o_done (internal_compress_done),
          .o_state(internal_compress_result)
      );
    end else begin : g_external_compress
      assign internal_compress_busy   = 1'b0;
      assign internal_compress_done   = 1'b0;
      assign internal_compress_result = '0;
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      sample_block_q <= '0;
      candidate_q <= '0;
      copy_block_q <= '0;
      copy_position_q <= '0;
      output_block_q <= '0;
      output_position_q <= '0;
      selected_valid_q <= 1'b0;
      take_candidate_q <= 1'b0;
      v_q <= '0;
      c_q <= '0;
      reseed_counter_q <= '0;
      o_done <= 1'b0;
      o_selected_candidate <= '0;
      o_selected_scores <= '0;
      for (int block = 0; block < 3; block++) begin
        for (int position = 0; position < SECRET_WEIGHT; position++) begin
          candidate_support_q[block][position] <= '0;
          selected_support_q[block][position]  <= '0;
        end
      end
    end else begin
      o_done <= 1'b0;

      if (sample_index_valid && sample_index_ready) begin
        candidate_support_q[sample_block_q][sample_index_position] <= sample_index;
      end

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            sample_block_q <= '0;
            candidate_q <= '0;
            selected_valid_q <= 1'b0;
            take_candidate_q <= 1'b0;
            o_selected_candidate <= '0;
            o_selected_scores <= '0;
            for (int block = 0; block < 3; block++) begin
              for (int position = 0; position < SECRET_WEIGHT; position++) begin
                selected_support_q[block][position] <= '0;
              end
            end
            state_q <= ST_START_INSTANTIATE;
          end
        end

        ST_START_INSTANTIATE: begin
          state_q <= ST_WAIT_INSTANTIATE;
        end

        ST_WAIT_INSTANTIATE: begin
          if (instantiate_done) begin
            v_q <= instantiate_v;
            c_q <= instantiate_c;
            reseed_counter_q <= instantiate_reseed_counter;
            sample_block_q <= '0;
            state_q <= ST_START_SAMPLE;
          end
        end

        ST_START_SAMPLE: begin
          state_q <= ST_WAIT_SAMPLE;
        end

        ST_WAIT_SAMPLE: begin
          if (sample_done) begin
            v_q <= sample_v;
            c_q <= sample_c;
            reseed_counter_q <= sample_reseed_counter;
            if (sample_block_q == 2'd2) begin
              state_q <= ST_START_WEAK_TEST;
            end else begin
              sample_block_q <= sample_block_q + 1'b1;
              state_q <= ST_START_SAMPLE;
            end
          end
        end

        ST_START_WEAK_TEST: begin
          state_q <= ST_WAIT_WEAK_TEST;
        end

        ST_WAIT_WEAK_TEST: begin
          if (weak_done) begin
            take_candidate_q <= !weak_result && !selected_valid_q;
            copy_block_q <= '0;
            copy_position_q <= '0;
            if (!weak_result && !selected_valid_q) begin
              selected_valid_q <= 1'b1;
              o_selected_candidate <= candidate_q;
              o_selected_scores <= weak_scores;
            end
            state_q <= ST_COPY_SELECTED;
          end
        end

        ST_COPY_SELECTED: begin
          if (take_candidate_q) begin
            selected_support_q[copy_block_q][copy_position_q] <=
                candidate_support_q[copy_block_q][copy_position_q];
          end
          if (copy_position_q == POSITION_W'(SECRET_WEIGHT - 1)) begin
            copy_position_q <= '0;
            if (copy_block_q == 2'd2) begin
              if (candidate_q == CANDIDATE_W'(CANDIDATE_COUNT - 1)) begin
                output_block_q <= '0;
                output_position_q <= '0;
                state_q <= ST_OUTPUT;
              end else begin
                candidate_q <= candidate_q + 1'b1;
                sample_block_q <= '0;
                state_q <= ST_START_SAMPLE;
              end
            end else begin
              copy_block_q <= copy_block_q + 1'b1;
            end
          end else begin
            copy_position_q <= copy_position_q + 1'b1;
          end
        end

        ST_OUTPUT: begin
          if (i_support_ready) begin
            if (output_position_q == POSITION_W'(SECRET_WEIGHT - 1)) begin
              output_position_q <= '0;
              if (output_block_q == 2'd2) begin
                o_done  <= 1'b1;
                state_q <= ST_IDLE;
              end else begin
                output_block_q <= output_block_q + 1'b1;
              end
            end else begin
              output_position_q <= output_position_q + 1'b1;
            end
          end
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (M_BYTES < 1) $error("trike_keygen_secret_sampler M_BYTES must be at least 1");
    if (R_BITS < 3) $error("trike_keygen_secret_sampler R_BITS must be at least 3");
    if (SECRET_WEIGHT < 2) begin
      $error("trike_keygen_secret_sampler SECRET_WEIGHT must be at least 2");
    end
    if (SECRET_WEIGHT > R_BITS) begin
      $error("trike_keygen_secret_sampler SECRET_WEIGHT must not exceed R_BITS");
    end
    if (CANDIDATE_COUNT < 1) begin
      $error("trike_keygen_secret_sampler CANDIDATE_COUNT must be at least 1");
    end
  end
`endif

endmodule
