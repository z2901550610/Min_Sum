`timescale 1ns / 1ps

// TRIKE H1/H2/H3 vector generation.
//
// One DRNG context is instantiated from sigma, followed by three sequential
// Generate(R_BYTES) calls. The generated vectors are mapped to even, even,
// and odd parity respectively. All hash work can use one external compressor.
module trike_h123_vectors #(
    parameter int M_BYTES               = 32,
    parameter int R_BITS                = 15581,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0
) (
    input  logic                                                                 i_clk,
    input  logic                                                                 i_rst_n,
    input  logic                                                                 i_start,
    input  logic                                                                 i_seed_valid,
    input  logic [                                                          7:0] i_seed_data,
    output logic                                                                 o_seed_ready,
    output logic                                                                 o_seed_pass,
    output logic                                                                 o_vector_valid,
    output logic [                                                          1:0] o_vector_select,
    output logic [((((R_BITS + 7) / 8) > 1) ? $clog2((R_BITS + 7) / 8) : 1)-1:0] o_vector_byte,
    output logic [                                                          7:0] o_vector_data,
    input  logic                                                                 i_vector_ready,
    output logic                                                                 o_busy,
    output logic                                                                 o_done,
    output logic [                                                        439:0] o_v,
    output logic [                                                        439:0] o_c,
    output logic [                                                        439:0] o_reseed_counter,
    output logic                                                                 o_compress_start,
    output logic [                                                        511:0] o_compress_block,
    output logic [                                                        255:0] o_compress_state,
    input  logic                                                                 i_compress_busy,
    input  logic                                                                 i_compress_done,
    input  logic [                                                        255:0] i_compress_state
);

  localparam int R_BYTES = (R_BITS + 7) / 8;
  localparam int BYTE_COUNT_W = (R_BYTES > 1) ? $clog2(R_BYTES) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_START_INSTANTIATE,
    ST_WAIT_INSTANTIATE,
    ST_START_VECTOR,
    ST_RUN_VECTOR
  } state_t;

  state_t                    state_q;
  logic   [             1:0] vector_select_q;
  logic   [BYTE_COUNT_W-1:0] vector_byte_q;
  logic   [           439:0] v_q;
  logic   [           439:0] c_q;
  logic   [           439:0] reseed_counter_q;
  logic                      generate_done_seen_q;
  logic                      parity_done_seen_q;

  logic                      instantiate_start;
  logic                      instantiate_seed_ready;
  logic                      instantiate_seed_pass;
  logic                      instantiate_done;
  logic   [           439:0] instantiate_v;
  logic   [           439:0] instantiate_c;
  logic   [           439:0] instantiate_reseed_counter;
  logic                      instantiate_compress_start;
  logic   [           511:0] instantiate_compress_block;
  logic   [           255:0] instantiate_compress_state;

  logic                      generate_start;
  logic                      generate_output_valid;
  logic   [             7:0] generate_output_data;
  logic                      generate_output_ready;
  logic                      generate_done;
  logic   [           439:0] generate_v;
  logic   [           439:0] generate_c;
  logic   [           439:0] generate_reseed_counter;
  logic                      generate_compress_start;
  logic   [           511:0] generate_compress_block;
  logic   [           255:0] generate_compress_state;

  logic                      parity_start;
  logic                      parity_input_ready;
  logic                      parity_output_valid;
  logic   [             7:0] parity_output_data;
  logic                      parity_done;

  logic                      select_generate_compress;
  logic                      shared_compress_start;
  logic   [           511:0] shared_compress_block;
  logic   [           255:0] shared_compress_state;
  logic                      shared_compress_busy;
  logic                      shared_compress_done;
  logic   [           255:0] shared_compress_result;
  logic                      internal_compress_busy;
  logic                      internal_compress_done;
  logic   [           255:0] internal_compress_result;

  assign instantiate_start = state_q == ST_START_INSTANTIATE;
  assign generate_start = state_q == ST_START_VECTOR;
  assign parity_start = state_q == ST_START_VECTOR;

  assign o_seed_ready = (state_q == ST_WAIT_INSTANTIATE) && instantiate_seed_ready;
  assign o_seed_pass = instantiate_seed_pass;
  assign generate_output_ready = (state_q == ST_RUN_VECTOR) && parity_input_ready;
  assign o_vector_valid = (state_q == ST_RUN_VECTOR) && parity_output_valid;
  assign o_vector_select = vector_select_q;
  assign o_vector_byte = vector_byte_q;
  assign o_vector_data = parity_output_data;
  assign o_busy = state_q != ST_IDLE;

  assign select_generate_compress = (state_q == ST_START_VECTOR) || (state_q == ST_RUN_VECTOR);
  assign shared_compress_start =
      select_generate_compress ? generate_compress_start : instantiate_compress_start;
  assign shared_compress_block =
      select_generate_compress ? generate_compress_block : instantiate_compress_block;
  assign shared_compress_state =
      select_generate_compress ? generate_compress_state : instantiate_compress_state;
  assign o_compress_start = shared_compress_start;
  assign o_compress_block = shared_compress_block;
  assign o_compress_state = shared_compress_state;
  assign shared_compress_busy = USE_EXTERNAL_COMPRESS ? i_compress_busy : internal_compress_busy;
  assign shared_compress_done = USE_EXTERNAL_COMPRESS ? i_compress_done : internal_compress_done;
  assign shared_compress_result =
      USE_EXTERNAL_COMPRESS ? i_compress_state : internal_compress_result;

  /* verilator lint_off PINCONNECTEMPTY */
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

  trike_sm3_drng_generate_stream #(
      .OUTPUT_BYTES         (R_BYTES),
      .USE_EXTERNAL_COMPRESS(1'b1)
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
      .o_compress_start(generate_compress_start),
      .o_compress_block(generate_compress_block),
      .o_compress_state(generate_compress_state),
      .i_compress_busy (shared_compress_busy),
      .i_compress_done (shared_compress_done),
      .i_compress_state(shared_compress_result)
  );

  trike_parity_map_stream #(
      .R(R_BITS)
  ) u_parity (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_start        (parity_start),
      .i_target_parity(vector_select_q == 2'd2),
      .i_input_valid  (generate_output_valid && (state_q == ST_RUN_VECTOR)),
      .i_input_data   (generate_output_data),
      .o_input_ready  (parity_input_ready),
      .o_output_valid (parity_output_valid),
      .o_output_data  (parity_output_data),
      .i_output_ready (i_vector_ready && (state_q == ST_RUN_VECTOR)),
      .o_busy         (),
      .o_done         (parity_done)
  );
  /* verilator lint_on PINCONNECTEMPTY */

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
      vector_select_q <= '0;
      vector_byte_q <= '0;
      v_q <= '0;
      c_q <= '0;
      reseed_counter_q <= '0;
      generate_done_seen_q <= 1'b0;
      parity_done_seen_q <= 1'b0;
      o_done <= 1'b0;
      o_v <= '0;
      o_c <= '0;
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
          if (instantiate_done) begin
            v_q <= instantiate_v;
            c_q <= instantiate_c;
            reseed_counter_q <= instantiate_reseed_counter;
            vector_select_q <= 0;
            state_q <= ST_START_VECTOR;
          end
        end

        ST_START_VECTOR: begin
          vector_byte_q <= '0;
          generate_done_seen_q <= 1'b0;
          parity_done_seen_q <= 1'b0;
          state_q <= ST_RUN_VECTOR;
        end

        ST_RUN_VECTOR: begin
          if (o_vector_valid && i_vector_ready) vector_byte_q <= vector_byte_q + 1'b1;
          if (generate_done) begin
            v_q <= generate_v;
            c_q <= generate_c;
            reseed_counter_q <= generate_reseed_counter;
            generate_done_seen_q <= 1'b1;
          end
          if (parity_done) parity_done_seen_q <= 1'b1;

          if ((generate_done || generate_done_seen_q) && (parity_done || parity_done_seen_q)) begin
            if (vector_select_q == 2'd2) begin
              o_v <= generate_done ? generate_v : v_q;
              o_c <= generate_done ? generate_c : c_q;
              o_reseed_counter <= generate_done ? generate_reseed_counter : reseed_counter_q;
              o_done <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              vector_select_q <= vector_select_q + 1'b1;
              state_q <= ST_START_VECTOR;
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
    if (M_BYTES < 1) $error("trike_h123_vectors M_BYTES must be at least 1");
    if (R_BITS < 1) $error("trike_h123_vectors R_BITS must be at least 1");
  end
`endif

endmodule
