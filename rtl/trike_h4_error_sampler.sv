`timescale 1ns / 1ps

// TRIKE H4 error-support service.
//
// The caller replays m || r2 for the two Instantiate seed passes. One SM3
// compression lane is shared by Instantiate and the subsequent sequence of
// Generate(4 byte) calls. The output indices cover [0, 3*R_BITS).
module trike_h4_error_sampler #(
    parameter int M_BYTES               = 32,
    parameter int R_BITS                = 15581,
    parameter int ERROR_WEIGHT          = 263,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0
) (
    input  logic                                                       i_clk,
    input  logic                                                       i_rst_n,
    input  logic                                                       i_start,
    input  logic                                                       i_seed_valid,
    input  logic [                                                7:0] i_seed_data,
    output logic                                                       o_seed_ready,
    output logic                                                       o_seed_pass,
    output logic                                                       o_index_valid,
    output logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] o_index_position,
    output logic [  (((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] o_index,
    input  logic                                                       i_index_ready,
    output logic                                                       o_busy,
    output logic                                                       o_done,
    output logic [                                              439:0] o_v,
    output logic [                                              439:0] o_c,
    output logic [                                              439:0] o_reseed_counter,
    output logic                                                       o_compress_start,
    output logic [                                              511:0] o_compress_block,
    output logic [                                              255:0] o_compress_state,
    input  logic                                                       i_compress_busy,
    input  logic                                                       i_compress_done,
    input  logic [                                              255:0] i_compress_state
);

  localparam int R_BYTES = (R_BITS + 7) / 8;
  localparam int SEED_BYTES = M_BYTES + R_BYTES;
  localparam int ERROR_LENGTH = 3 * R_BITS;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_START_INSTANTIATE,
    ST_WAIT_INSTANTIATE,
    ST_START_SAMPLE,
    ST_WAIT_SAMPLE
  } state_t;

  state_t                                                       state_q;

  logic                                                         instantiate_start;
  logic                                                         instantiate_seed_ready;
  logic                                                         instantiate_seed_pass;
  logic                                                         instantiate_done;
  logic   [                                              439:0] instantiate_v;
  logic   [                                              439:0] instantiate_c;
  logic   [                                              439:0] instantiate_reseed_counter;
  logic                                                         instantiate_compress_start;
  logic   [                                              511:0] instantiate_compress_block;
  logic   [                                              255:0] instantiate_compress_state;

  logic                                                         sample_start;
  logic                                                         sample_index_valid;
  logic   [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] sample_index_position;
  logic   [((ERROR_LENGTH > 1) ? $clog2(ERROR_LENGTH) : 1)-1:0] sample_index;
  logic                                                         sample_index_ready;
  logic                                                         sample_done;
  logic   [                                              439:0] sample_v;
  logic   [                                              439:0] sample_c;
  logic   [                                              439:0] sample_reseed_counter;
  logic                                                         sample_compress_start;
  logic   [                                              511:0] sample_compress_block;
  logic   [                                              255:0] sample_compress_state;

  logic                                                         select_sample_compress;
  logic                                                         shared_compress_start;
  logic   [                                              511:0] shared_compress_block;
  logic   [                                              255:0] shared_compress_state;
  logic                                                         shared_compress_busy;
  logic                                                         shared_compress_done;
  logic   [                                              255:0] shared_compress_result;
  logic                                                         internal_compress_busy;
  logic                                                         internal_compress_done;
  logic   [                                              255:0] internal_compress_result;

  assign instantiate_start = state_q == ST_START_INSTANTIATE;
  assign sample_start = state_q == ST_START_SAMPLE;

  assign o_seed_ready = (state_q == ST_WAIT_INSTANTIATE) && instantiate_seed_ready;
  assign o_seed_pass = instantiate_seed_pass;

  assign sample_index_ready = (state_q == ST_WAIT_SAMPLE) && i_index_ready;
  assign o_index_valid = (state_q == ST_WAIT_SAMPLE) && sample_index_valid;
  assign o_index_position = sample_index_position;
  assign o_index = sample_index;
  assign o_busy = state_q != ST_IDLE;

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
      .SEED_BYTES           (SEED_BYTES),
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
      .LENGTH               (ERROR_LENGTH),
      .WEIGHT               (ERROR_WEIGHT),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_sampler (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (sample_start),
      .i_v             (instantiate_v),
      .i_c             (instantiate_c),
      .i_reseed_counter(instantiate_reseed_counter),
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
      state_q          <= ST_IDLE;
      o_done           <= 1'b0;
      o_v              <= '0;
      o_c              <= '0;
      o_reseed_counter <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) state_q <= ST_START_INSTANTIATE;
        end

        ST_START_INSTANTIATE: begin
          state_q <= ST_WAIT_INSTANTIATE;
        end

        ST_WAIT_INSTANTIATE: begin
          if (instantiate_done) state_q <= ST_START_SAMPLE;
        end

        ST_START_SAMPLE: begin
          state_q <= ST_WAIT_SAMPLE;
        end

        ST_WAIT_SAMPLE: begin
          if (sample_done) begin
            o_v              <= sample_v;
            o_c              <= sample_c;
            o_reseed_counter <= sample_reseed_counter;
            o_done           <= 1'b1;
            state_q          <= ST_IDLE;
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
    if (M_BYTES < 1) $error("trike_h4_error_sampler M_BYTES must be at least 1");
    if (R_BITS < 1) $error("trike_h4_error_sampler R_BITS must be at least 1");
    if (ERROR_WEIGHT < 1) $error("trike_h4_error_sampler ERROR_WEIGHT must be at least 1");
    if (ERROR_WEIGHT > ERROR_LENGTH) begin
      $error("trike_h4_error_sampler ERROR_WEIGHT must not exceed 3*R_BITS");
    end
  end
`endif

endmodule
