`timescale 1ns / 1ps

// Repeated ICCS Generate(4 byte) plus fixed-weight index sampling.
//
// The DRNG state is updated once per candidate, matching the Reference C call
// boundary. Random bytes are assembled as a little-endian uint32_t before the
// multiply-high candidate map. With continuous index acceptance, the number
// of Generate calls and sampler scans is exactly WEIGHT.
module trike_drng_weight_sampler #(
    parameter int LENGTH                = 46743,
    parameter int WEIGHT                = 263,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0
) (
    input  logic                                           i_clk,
    input  logic                                           i_rst_n,
    input  logic                                           i_start,
    input  logic [                                  439:0] i_v,
    input  logic [                                  439:0] i_c,
    input  logic [                                  439:0] i_reseed_counter,
    output logic                                           o_index_valid,
    output logic [((WEIGHT > 1) ? $clog2(WEIGHT) : 1)-1:0] o_index_position,
    output logic [((LENGTH > 1) ? $clog2(LENGTH) : 1)-1:0] o_index,
    input  logic                                           i_index_ready,
    output logic                                           o_busy,
    output logic                                           o_done,
    output logic [                                  439:0] o_v,
    output logic [                                  439:0] o_c,
    output logic [                                  439:0] o_reseed_counter,
    output logic                                           o_compress_start,
    output logic [                                  511:0] o_compress_block,
    output logic [                                  255:0] o_compress_state,
    input  logic                                           i_compress_busy,
    input  logic                                           i_compress_done,
    input  logic [                                  255:0] i_compress_state
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_START_SAMPLER,
    ST_START_GENERATE,
    ST_COLLECT_RANDOM,
    ST_WAIT_GENERATE,
    ST_FEED_RANDOM,
    ST_WAIT_INDEX,
    ST_WAIT_SAMPLER_DONE
  } state_t;

  state_t                                           state_q;

  logic   [                                  439:0] v_q;
  logic   [                                  439:0] c_q;
  logic   [                                  439:0] reseed_counter_q;
  logic   [                                   31:0] random_word_q;
  logic   [                                    1:0] random_byte_count_q;

  logic                                             generate_start;
  logic                                             generate_output_ready;
  logic                                             generate_output_valid;
  logic   [                                    7:0] generate_output_data;
  logic                                             generate_done;
  logic   [                                  439:0] generate_v;
  logic   [                                  439:0] generate_c;
  logic   [                                  439:0] generate_reseed_counter;

  logic                                             sampler_start;
  logic                                             sampler_random_valid;
  logic                                             sampler_random_ready;
  logic                                             sampler_index_valid;
  logic   [((WEIGHT > 1) ? $clog2(WEIGHT) : 1)-1:0] sampler_index_position;
  logic   [((LENGTH > 1) ? $clog2(LENGTH) : 1)-1:0] sampler_index;
  logic                                             sampler_index_ready;
  logic                                             sampler_done;

  assign generate_start        = state_q == ST_START_GENERATE;
  assign generate_output_ready = state_q == ST_COLLECT_RANDOM;
  assign sampler_start         = state_q == ST_START_SAMPLER;
  assign sampler_random_valid  = state_q == ST_FEED_RANDOM;
  assign sampler_index_ready   = (state_q == ST_WAIT_INDEX) && i_index_ready;

  assign o_index_valid         = (state_q == ST_WAIT_INDEX) && sampler_index_valid;
  assign o_index_position      = sampler_index_position;
  assign o_index               = sampler_index;
  assign o_busy                = state_q != ST_IDLE;

  trike_sm3_drng_generate_stream #(
      .OUTPUT_BYTES         (4),
      .USE_EXTERNAL_COMPRESS(USE_EXTERNAL_COMPRESS)
  ) u_generate (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (generate_start),
      .i_v             (v_q),
      .i_c             (c_q),
      .i_reseed_counter(reseed_counter_q),
      .i_output_ready  (generate_output_ready),
      .o_output_valid  (generate_output_valid),
      .o_output_data   (generate_output_data),
      .o_busy          (),
      .o_done          (generate_done),
      .o_v             (generate_v),
      .o_c             (generate_c),
      .o_reseed_counter(generate_reseed_counter),
      .o_compress_start(o_compress_start),
      .o_compress_block(o_compress_block),
      .o_compress_state(o_compress_state),
      .i_compress_busy (i_compress_busy),
      .i_compress_done (i_compress_done),
      .i_compress_state(i_compress_state)
  );

  trike_fixed_weight_sampler #(
      .LENGTH(LENGTH),
      .WEIGHT(WEIGHT)
  ) u_sampler (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (sampler_start),
      .i_random_valid  (sampler_random_valid),
      .i_random_data   (random_word_q),
      .o_random_ready  (sampler_random_ready),
      .o_index_valid   (sampler_index_valid),
      .o_index_position(sampler_index_position),
      .o_index         (sampler_index),
      .i_index_ready   (sampler_index_ready),
      .o_busy          (),
      .o_done          (sampler_done)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q             <= ST_IDLE;
      v_q                 <= '0;
      c_q                 <= '0;
      reseed_counter_q    <= '0;
      random_word_q       <= '0;
      random_byte_count_q <= '0;
      o_done              <= 1'b0;
      o_v                 <= '0;
      o_c                 <= '0;
      o_reseed_counter    <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            v_q              <= i_v;
            c_q              <= i_c;
            reseed_counter_q <= i_reseed_counter;
            state_q          <= ST_START_SAMPLER;
          end
        end

        ST_START_SAMPLER: begin
          state_q <= ST_START_GENERATE;
        end

        ST_START_GENERATE: begin
          random_word_q       <= '0;
          random_byte_count_q <= '0;
          state_q             <= ST_COLLECT_RANDOM;
        end

        ST_COLLECT_RANDOM: begin
          if (generate_output_valid) begin
            random_word_q[8*random_byte_count_q+:8] <= generate_output_data;
            if (random_byte_count_q == 2'd3) begin
              state_q <= ST_WAIT_GENERATE;
            end else begin
              random_byte_count_q <= random_byte_count_q + 1'b1;
            end
          end
        end

        ST_WAIT_GENERATE: begin
          if (generate_done) begin
            v_q              <= generate_v;
            c_q              <= generate_c;
            reseed_counter_q <= generate_reseed_counter;
            state_q          <= ST_FEED_RANDOM;
          end
        end

        ST_FEED_RANDOM: begin
          if (sampler_random_ready) begin
            state_q <= ST_WAIT_INDEX;
          end
        end

        ST_WAIT_INDEX: begin
          if (sampler_index_valid && i_index_ready) begin
            if (sampler_index_position == '0) begin
              state_q <= ST_WAIT_SAMPLER_DONE;
            end else begin
              state_q <= ST_START_GENERATE;
            end
          end
        end

        ST_WAIT_SAMPLER_DONE: begin
          if (sampler_done) begin
            o_v              <= v_q;
            o_c              <= c_q;
            o_reseed_counter <= reseed_counter_q;
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
    if (LENGTH < 1) $error("trike_drng_weight_sampler LENGTH must be at least 1");
    if (WEIGHT < 1) $error("trike_drng_weight_sampler WEIGHT must be at least 1");
    if (WEIGHT > LENGTH) $error("trike_drng_weight_sampler WEIGHT must not exceed LENGTH");
  end
`endif

endmodule
