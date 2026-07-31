`timescale 1ns / 1ps

// Byte-aligned ICCS SM3-DRNG Generate operation.
//
// OUTPUT_BYTES is public. With continuous output acceptance, the number of
// SM3 invocations and all state-update work are fixed by OUTPUT_BYTES.
module trike_sm3_drng_generate_stream #(
    parameter int OUTPUT_BYTES = 32
) (
    input  logic         i_clk,
    input  logic         i_rst_n,
    input  logic         i_start,
    input  logic [439:0] i_v,
    input  logic [439:0] i_c,
    input  logic [439:0] i_reseed_counter,
    input  logic         i_output_ready,
    output logic         o_output_valid,
    output logic [  7:0] o_output_data,
    output logic         o_busy,
    output logic         o_done,
    output logic [439:0] o_v,
    output logic [439:0] o_c,
    output logic [439:0] o_reseed_counter
);

  localparam int OUTPUT_COUNT_W = (OUTPUT_BYTES > 1) ? $clog2(OUTPUT_BYTES) : 1;
  localparam logic [OUTPUT_COUNT_W-1:0] OUTPUT_LAST = OUTPUT_COUNT_W'(OUTPUT_BYTES - 1);

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_GENERATE_HASH_START,
    ST_GENERATE_HASH_FEED,
    ST_GENERATE_HASH_WAIT,
    ST_OUTPUT,
    ST_UPDATE_HASH_START,
    ST_UPDATE_HASH_FEED,
    ST_UPDATE_HASH_WAIT
  } state_t;

  state_t                      state_q;

  logic   [             439:0] v_q;
  logic   [             439:0] c_q;
  logic   [             439:0] reseed_counter_q;
  logic   [             439:0] data_q;
  logic   [             255:0] digest_q;
  logic   [               5:0] generate_feed_idx_q;
  logic   [               5:0] update_feed_idx_q;
  logic   [               5:0] digest_byte_idx_q;
  logic   [OUTPUT_COUNT_W-1:0] output_count_q;

  logic                        generate_hash_start;
  logic                        generate_hash_input_ready;
  logic                        generate_hash_done;
  logic   [             255:0] generate_hash_digest;
  logic   [               7:0] generate_hash_input_data;

  logic                        update_hash_start;
  logic                        update_hash_input_ready;
  logic                        update_hash_done;
  logic   [             255:0] update_hash_digest;
  logic   [               7:0] update_hash_input_data;
  logic   [             439:0] update_h;

  function automatic logic [7:0] state_byte(input  logic [439:0] value, input  logic [5:0] byte_idx);
    begin
      state_byte = value[439-8*byte_idx-:8];
    end
  endfunction

  assign o_output_valid = (state_q == ST_OUTPUT);
  assign o_output_data = digest_q[255-8*digest_byte_idx_q-:8];

  assign generate_hash_start = (state_q == ST_GENERATE_HASH_START);
  assign generate_hash_input_data = data_q[439-8*generate_feed_idx_q-:8];

  assign update_hash_start = (state_q == ST_UPDATE_HASH_START);
  assign update_hash_input_data = (update_feed_idx_q == 0) ? 8'h03 : state_byte(
      v_q, update_feed_idx_q - 6'd1
  );
  assign update_h = {184'b0, update_hash_digest};

  /* verilator lint_off PINCONNECTEMPTY */
  sm3_hash_stream #(
      .INPUT_BYTES(55)
  ) u_generate_hash (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (generate_hash_start),
      .i_input_valid(state_q == ST_GENERATE_HASH_FEED),
      .i_input_data (generate_hash_input_data),
      .o_input_ready(generate_hash_input_ready),
      .o_busy       (),
      .o_done       (generate_hash_done),
      .o_digest     (generate_hash_digest)
  );

  sm3_hash_stream #(
      .INPUT_BYTES(56)
  ) u_update_hash (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .i_start      (update_hash_start),
      .i_input_valid(state_q == ST_UPDATE_HASH_FEED),
      .i_input_data (update_hash_input_data),
      .o_input_ready(update_hash_input_ready),
      .o_busy       (),
      .o_done       (update_hash_done),
      .o_digest     (update_hash_digest)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q             <= ST_IDLE;
      v_q                 <= '0;
      c_q                 <= '0;
      reseed_counter_q    <= '0;
      data_q              <= '0;
      digest_q            <= '0;
      generate_feed_idx_q <= '0;
      update_feed_idx_q   <= '0;
      digest_byte_idx_q   <= '0;
      output_count_q      <= '0;
      o_busy              <= 1'b0;
      o_done              <= 1'b0;
      o_v                 <= '0;
      o_c                 <= '0;
      o_reseed_counter    <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            v_q                 <= i_v;
            c_q                 <= i_c;
            reseed_counter_q    <= i_reseed_counter;
            data_q              <= i_v;
            generate_feed_idx_q <= '0;
            output_count_q      <= '0;
            o_busy              <= 1'b1;
            state_q             <= ST_GENERATE_HASH_START;
          end
        end

        ST_GENERATE_HASH_START: begin
          generate_feed_idx_q <= '0;
          state_q             <= ST_GENERATE_HASH_FEED;
        end

        ST_GENERATE_HASH_FEED: begin
          if (generate_hash_input_ready) begin
            if (generate_feed_idx_q == 6'd54) begin
              state_q <= ST_GENERATE_HASH_WAIT;
            end else begin
              generate_feed_idx_q <= generate_feed_idx_q + 1'b1;
            end
          end
        end

        ST_GENERATE_HASH_WAIT: begin
          if (generate_hash_done) begin
            digest_q          <= generate_hash_digest;
            digest_byte_idx_q <= '0;
            state_q           <= ST_OUTPUT;
          end
        end

        ST_OUTPUT: begin
          if (o_output_valid && i_output_ready) begin
            if (output_count_q == OUTPUT_LAST) begin
              update_feed_idx_q <= '0;
              state_q           <= ST_UPDATE_HASH_START;
            end else begin
              output_count_q <= output_count_q + 1'b1;
              if (digest_byte_idx_q == 6'd31) begin
                data_q              <= data_q + 1'b1;
                generate_feed_idx_q <= '0;
                state_q             <= ST_GENERATE_HASH_START;
              end else begin
                digest_byte_idx_q <= digest_byte_idx_q + 1'b1;
              end
            end
          end
        end

        ST_UPDATE_HASH_START: begin
          update_feed_idx_q <= '0;
          state_q           <= ST_UPDATE_HASH_FEED;
        end

        ST_UPDATE_HASH_FEED: begin
          if (update_hash_input_ready) begin
            if (update_feed_idx_q == 6'd55) begin
              state_q <= ST_UPDATE_HASH_WAIT;
            end else begin
              update_feed_idx_q <= update_feed_idx_q + 1'b1;
            end
          end
        end

        ST_UPDATE_HASH_WAIT: begin
          if (update_hash_done) begin
            o_v              <= v_q + update_h + c_q + reseed_counter_q;
            o_c              <= c_q;
            o_reseed_counter <= reseed_counter_q + 1'b1;
            o_busy           <= 1'b0;
            o_done           <= 1'b1;
            state_q          <= ST_IDLE;
          end
        end

        default: begin
          o_busy  <= 1'b0;
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (OUTPUT_BYTES < 1) $error("trike_sm3_drng_generate_stream OUTPUT_BYTES must be at least 1");
  end
`endif

endmodule
