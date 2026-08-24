`timescale 1ns / 1ps

// Fixed-schedule Decaps post-processing:
//   L(e') -> m' -> H4(m'||r2) -> full error compare -> select -> K(selected||ct).
// L, H4, and K execute sequentially and share one SM3 compression service.
module trike_decaps_postprocess_core #(
    parameter int M_BYTES               = 32,
    parameter int R_BITS                = 12589,
    parameter int ERROR_WEIGHT          = 263,
    parameter int PADDED_R_BYTES        = ((R_BITS + 511) / 512) * 64,
    parameter int CIPHERTEXT_BYTES      = (2 * ((R_BITS + 7) / 8)) + M_BYTES,
    parameter bit RUNTIME_GEOMETRY      = 1'b0,
    parameter int DATA_W                = 8 * M_BYTES,
    parameter int ERROR_BYTES           = 3 * PADDED_R_BYTES,
    parameter int R_BYTES               = (R_BITS + 7) / 8,
    parameter int ERROR_ADDR_W          = ((ERROR_BYTES > 1) ? $clog2(ERROR_BYTES) : 1),
    parameter int R_ADDR_W              = ((R_BYTES > 1) ? $clog2(R_BYTES) : 1),
    parameter int CT_ADDR_W             = ((CIPHERTEXT_BYTES > 1) ? $clog2(CIPHERTEXT_BYTES) : 1),
    parameter int SS_IDX_W              = ((M_BYTES > 1) ? $clog2(M_BYTES) : 1),
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0,
    parameter bit USE_EXTERNAL_SAMPLER  = 1'b0
) (
    input  logic                                                       i_clk,
    input  logic                                                       i_rst_n,
    input  logic                                                       i_start,
    input  logic [                                               31:0] i_runtime_r_bits,
    input  logic [                                               31:0] i_runtime_error_weight,
    input  logic [                                               31:0] i_runtime_r_bytes,
    input  logic [                                               31:0] i_runtime_padded_r_bytes,
    input  logic [                                               31:0] i_runtime_error_bytes,
    input  logic [                                               31:0] i_runtime_ciphertext_bytes,
    input  logic                                                       i_decoder_ok,
    input  logic [                                         DATA_W-1:0] i_sigma2,
    input  logic                                                       i_c2_valid,
    input  logic [                                                7:0] i_c2_data,
    output logic                                                       o_c2_ready,
    output logic                                                       o_reference_re,
    output logic [                                   ERROR_ADDR_W-1:0] o_reference_raddr,
    input  logic [                                                7:0] i_reference_rdata,
    output logic                                                       o_r2_re,
    output logic [                                       R_ADDR_W-1:0] o_r2_raddr,
    input  logic [                                                7:0] i_r2_rdata,
    output logic                                                       o_ciphertext_re,
    output logic [                                      CT_ADDR_W-1:0] o_ciphertext_raddr,
    input  logic [                                                7:0] i_ciphertext_rdata,
    output logic                                                       o_ciphertext_equal,
    output logic                                                       o_shared_secret_valid,
    output logic [                                       SS_IDX_W-1:0] o_shared_secret_index,
    output logic [                                                7:0] o_shared_secret_data,
    output logic                                                       o_shared_secret_last,
    input  logic                                                       i_shared_secret_ready,
    output logic                                                       o_busy,
    output logic                                                       o_done,
    output logic                                                       o_compress_start,
    output logic [                                              511:0] o_compress_block,
    output logic [                                              255:0] o_compress_state,
    input  logic                                                       i_compress_busy,
    input  logic                                                       i_compress_done,
    input  logic [                                              255:0] i_compress_state,
    output logic                                                       o_sampler_start,
    output logic [                                               31:0] o_sampler_runtime_length,
    output logic [                                               31:0] o_sampler_runtime_weight,
    output logic [                                              439:0] o_sampler_v,
    output logic [                                              439:0] o_sampler_c,
    output logic [                                              439:0] o_sampler_reseed_counter,
    input  logic                                                       i_sampler_index_valid,
    input  logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] i_sampler_index_position,
    input  logic [  (((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] i_sampler_index,
    output logic                                                       o_sampler_index_ready,
    input  logic                                                       i_sampler_done,
    input  logic [                                              439:0] i_sampler_v,
    input  logic [                                              439:0] i_sampler_c,
    input  logic [                                              439:0] i_sampler_reseed_counter
);

  localparam int SEED_BYTES = M_BYTES + R_BYTES;
  localparam int MESSAGE_IDX_W = (M_BYTES > 1) ? $clog2(M_BYTES) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_MESSAGE_START,
    ST_MESSAGE_RUN,
    ST_VERIFY_START,
    ST_VERIFY_RUN,
    ST_K_START,
    ST_K_RUN
  } state_t;

  state_t                     state_q;
  logic   [       DATA_W-1:0] sigma2_q;
  logic                       decoder_ok_q;
  logic   [       DATA_W-1:0] recovered_message_q;
  integer                     seed_count_q;
  integer                     r2_byte_c;
  logic   [             31:0] active_r_bits_q;
  logic   [             31:0] active_error_weight_q;
  logic   [             31:0] active_r_bytes_q;
  logic   [             31:0] active_padded_r_bytes_q;
  logic   [             31:0] active_error_bytes_q;
  logic   [             31:0] active_ciphertext_bytes_q;
  logic   [             31:0] active_seed_bytes_q;

  logic                       message_error_re;
  logic   [ ERROR_ADDR_W-1:0] message_error_raddr;
  logic                       message_valid;
  logic   [MESSAGE_IDX_W-1:0] message_index;
  logic   [              7:0] message_data;
  logic                       message_done;
  logic                       message_compress_start;
  logic   [            511:0] message_compress_block;
  logic   [            255:0] message_compress_state;

  logic                       verify_seed_ready;
  logic                       verify_seed_pass;
  logic   [              7:0] verify_seed_data;
  logic                       verify_reference_re;
  logic   [ ERROR_ADDR_W-1:0] verify_reference_raddr;
  logic                       verify_equal;
  logic   [       DATA_W-1:0] verify_selected_data;
  logic                       verify_done;
  logic                       verify_compress_start;
  logic   [            511:0] verify_compress_block;
  logic   [            255:0] verify_compress_state;

  logic                       k_ciphertext_re;
  logic   [    CT_ADDR_W-1:0] k_ciphertext_raddr;
  logic                       k_done;
  logic                       k_compress_start;
  logic   [            511:0] k_compress_block;
  logic   [            255:0] k_compress_state;

  logic                       shared_compress_start;
  logic   [            511:0] shared_compress_block;
  logic   [            255:0] shared_compress_input_state;
  logic                       shared_compress_busy;
  logic                       shared_compress_done;
  logic   [            255:0] shared_compress_output_state;

  function automatic logic [7:0] wide_byte(input  logic [DATA_W-1:0] value,
                                           input int unsigned byte_idx);
    begin
      wide_byte = value[8*byte_idx+:8];
    end
  endfunction

  assign r2_byte_c = seed_count_q - M_BYTES;
  assign verify_seed_data = (seed_count_q < M_BYTES) ? wide_byte(
      recovered_message_q, seed_count_q
  ) : i_r2_rdata;
  assign o_busy = state_q != ST_IDLE;

  trike_decaps_message_recover #(
      .M_BYTES              (M_BYTES),
      .ERROR_BYTES          (ERROR_BYTES),
      .RUNTIME_LENGTH       (RUNTIME_GEOMETRY),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_message (
      .i_clk                (i_clk),
      .i_rst_n              (i_rst_n),
      .i_start              (state_q == ST_MESSAGE_START),
      .i_runtime_error_bytes(active_error_bytes_q),
      .i_c2_valid           (i_c2_valid && (state_q == ST_MESSAGE_RUN)),
      .i_c2_data            (i_c2_data),
      .o_c2_ready           (o_c2_ready),
      .o_error_re           (message_error_re),
      .o_error_raddr        (message_error_raddr),
      .i_error_rdata        (i_reference_rdata),
      .o_message_valid      (message_valid),
      .o_message_index      (message_index),
      .o_message_data       (message_data),
      .o_message_last       (),
      .i_message_ready      (state_q == ST_MESSAGE_RUN),
      .o_busy               (),
      .o_done               (message_done),
      .o_l_digest           (),
      .o_compress_start     (message_compress_start),
      .o_compress_block     (message_compress_block),
      .o_compress_state     (message_compress_state),
      .i_compress_busy      (shared_compress_busy),
      .i_compress_done      (shared_compress_done),
      .i_compress_state     (shared_compress_output_state)
  );

  trike_decaps_reencrypt_verify #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (R_BITS),
      .ERROR_WEIGHT         (ERROR_WEIGHT),
      .PADDED_R_BYTES       (PADDED_R_BYTES),
      .RUNTIME_GEOMETRY     (RUNTIME_GEOMETRY),
      .USE_EXTERNAL_COMPRESS(1'b1),
      .USE_EXTERNAL_SAMPLER (USE_EXTERNAL_SAMPLER)
  ) u_verify (
      .i_clk                   (i_clk),
      .i_rst_n                 (i_rst_n),
      .i_start                 (state_q == ST_VERIFY_START),
      .i_runtime_r_bits        (active_r_bits_q),
      .i_runtime_error_weight  (active_error_weight_q),
      .i_runtime_padded_r_bytes(active_padded_r_bytes_q),
      .i_runtime_error_bytes   (active_error_bytes_q),
      .i_decoder_ok            (decoder_ok_q),
      .i_seed_valid            (state_q == ST_VERIFY_RUN),
      .i_seed_data             (verify_seed_data),
      .o_seed_ready            (verify_seed_ready),
      .o_seed_pass             (verify_seed_pass),
      .o_reference_re          (verify_reference_re),
      .o_reference_raddr       (verify_reference_raddr),
      .i_reference_rdata       (i_reference_rdata),
      .i_match_data            (recovered_message_q),
      .i_mismatch_data         (sigma2_q),
      .o_equal                 (verify_equal),
      .o_selected_data         (verify_selected_data),
      .o_busy                  (),
      .o_done                  (verify_done),
      .o_compress_start        (verify_compress_start),
      .o_compress_block        (verify_compress_block),
      .o_compress_state        (verify_compress_state),
      .i_compress_busy         (shared_compress_busy),
      .i_compress_done         (shared_compress_done),
      .i_compress_state        (shared_compress_output_state),
      .o_sampler_start         (o_sampler_start),
      .o_sampler_runtime_length(o_sampler_runtime_length),
      .o_sampler_runtime_weight(o_sampler_runtime_weight),
      .o_sampler_v             (o_sampler_v),
      .o_sampler_c             (o_sampler_c),
      .o_sampler_reseed_counter(o_sampler_reseed_counter),
      .i_sampler_index_valid   (i_sampler_index_valid),
      .i_sampler_index_position(i_sampler_index_position),
      .i_sampler_index         (i_sampler_index),
      .o_sampler_index_ready   (o_sampler_index_ready),
      .i_sampler_done          (i_sampler_done),
      .i_sampler_v             (i_sampler_v),
      .i_sampler_c             (i_sampler_c),
      .i_sampler_reseed_counter(i_sampler_reseed_counter)
  );

  trike_decaps_kdf #(
      .M_BYTES              (M_BYTES),
      .CIPHERTEXT_BYTES     (CIPHERTEXT_BYTES),
      .RUNTIME_LENGTH       (RUNTIME_GEOMETRY),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_k (
      .i_clk                     (i_clk),
      .i_rst_n                   (i_rst_n),
      .i_start                   (state_q == ST_K_START),
      .i_runtime_ciphertext_bytes(active_ciphertext_bytes_q),
      .i_selected_message        (verify_selected_data),
      .o_ciphertext_re           (k_ciphertext_re),
      .o_ciphertext_raddr        (k_ciphertext_raddr),
      .i_ciphertext_rdata        (i_ciphertext_rdata),
      .o_shared_secret_valid     (o_shared_secret_valid),
      .o_shared_secret_index     (o_shared_secret_index),
      .o_shared_secret_data      (o_shared_secret_data),
      .o_shared_secret_last      (o_shared_secret_last),
      .i_shared_secret_ready     (i_shared_secret_ready && (state_q == ST_K_RUN)),
      .o_busy                    (),
      .o_done                    (k_done),
      .o_k_digest                (),
      .o_compress_start          (k_compress_start),
      .o_compress_block          (k_compress_block),
      .o_compress_state          (k_compress_state),
      .i_compress_busy           (shared_compress_busy),
      .i_compress_done           (shared_compress_done),
      .i_compress_state          (shared_compress_output_state)
  );

  assign o_compress_start = shared_compress_start;
  assign o_compress_block = shared_compress_block;
  assign o_compress_state = shared_compress_input_state;

  generate
    if (USE_EXTERNAL_COMPRESS) begin : gen_external_compress
      assign shared_compress_busy = i_compress_busy;
      assign shared_compress_done = i_compress_done;
      assign shared_compress_output_state = i_compress_state;
    end else begin : gen_local_compress
      trike_sm3_service u_sm3_service (
          .i_clk  (i_clk),
          .i_rst_n(i_rst_n),
          .i_start(shared_compress_start),
          .i_block(shared_compress_block),
          .i_state(shared_compress_input_state),
          .o_busy (shared_compress_busy),
          .o_done (shared_compress_done),
          .o_state(shared_compress_output_state)
      );
    end
  endgenerate

  always_comb begin
    o_reference_re = 1'b0;
    o_reference_raddr = '0;
    if ((state_q == ST_MESSAGE_START) || (state_q == ST_MESSAGE_RUN)) begin
      o_reference_re = message_error_re;
      o_reference_raddr = message_error_raddr;
    end else if ((state_q == ST_VERIFY_START) || (state_q == ST_VERIFY_RUN)) begin
      o_reference_re = verify_reference_re;
      o_reference_raddr = verify_reference_raddr;
    end

    o_r2_re = 1'b0;
    o_r2_raddr = '0;
    if (state_q == ST_VERIFY_START) begin
      o_r2_re = 1'b1;
    end else if ((state_q == ST_VERIFY_RUN) && verify_seed_ready && (seed_count_q >= M_BYTES)) begin
      o_r2_re = 1'b1;
      o_r2_raddr = (r2_byte_c == (active_r_bytes_q - 1'b1)) ? '0 : R_ADDR_W'(r2_byte_c + 1);
    end

    o_ciphertext_re = ((state_q == ST_K_START) || (state_q == ST_K_RUN)) && k_ciphertext_re;
    o_ciphertext_raddr = k_ciphertext_raddr;

    shared_compress_start = 1'b0;
    shared_compress_block = '0;
    shared_compress_input_state = '0;
    if ((state_q == ST_MESSAGE_START) || (state_q == ST_MESSAGE_RUN)) begin
      shared_compress_start = message_compress_start;
      shared_compress_block = message_compress_block;
      shared_compress_input_state = message_compress_state;
    end else if ((state_q == ST_VERIFY_START) || (state_q == ST_VERIFY_RUN)) begin
      shared_compress_start = verify_compress_start;
      shared_compress_block = verify_compress_block;
      shared_compress_input_state = verify_compress_state;
    end else if ((state_q == ST_K_START) || (state_q == ST_K_RUN)) begin
      shared_compress_start = k_compress_start;
      shared_compress_block = k_compress_block;
      shared_compress_input_state = k_compress_state;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      sigma2_q <= '0;
      decoder_ok_q <= 1'b0;
      recovered_message_q <= '0;
      seed_count_q <= 0;
      o_ciphertext_equal <= 1'b0;
      o_done <= 1'b0;
      active_r_bits_q <= 32'(R_BITS);
      active_error_weight_q <= 32'(ERROR_WEIGHT);
      active_r_bytes_q <= 32'(R_BYTES);
      active_padded_r_bytes_q <= 32'(PADDED_R_BYTES);
      active_error_bytes_q <= 32'(ERROR_BYTES);
      active_ciphertext_bytes_q <= 32'(CIPHERTEXT_BYTES);
      active_seed_bytes_q <= 32'(SEED_BYTES);
    end else begin
      o_done <= 1'b0;

      if ((state_q == ST_MESSAGE_RUN) && message_valid) begin
        recovered_message_q[8*message_index+:8] <= message_data;
      end

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            sigma2_q <= i_sigma2;
            decoder_ok_q <= i_decoder_ok;
            recovered_message_q <= '0;
            o_ciphertext_equal <= 1'b0;
            if (RUNTIME_GEOMETRY) begin
              active_r_bits_q <= i_runtime_r_bits;
              active_error_weight_q <= i_runtime_error_weight;
              active_r_bytes_q <= i_runtime_r_bytes;
              active_padded_r_bytes_q <= i_runtime_padded_r_bytes;
              active_error_bytes_q <= i_runtime_error_bytes;
              active_ciphertext_bytes_q <= i_runtime_ciphertext_bytes;
              active_seed_bytes_q <= 32'(M_BYTES) + i_runtime_r_bytes;
            end else begin
              active_r_bits_q <= 32'(R_BITS);
              active_error_weight_q <= 32'(ERROR_WEIGHT);
              active_r_bytes_q <= 32'(R_BYTES);
              active_padded_r_bytes_q <= 32'(PADDED_R_BYTES);
              active_error_bytes_q <= 32'(ERROR_BYTES);
              active_ciphertext_bytes_q <= 32'(CIPHERTEXT_BYTES);
              active_seed_bytes_q <= 32'(SEED_BYTES);
            end
            state_q <= ST_MESSAGE_START;
          end
        end

        ST_MESSAGE_START: state_q <= ST_MESSAGE_RUN;

        ST_MESSAGE_RUN: begin
          if (message_done) begin
            seed_count_q <= 0;
            state_q <= ST_VERIFY_START;
          end
        end

        ST_VERIFY_START: state_q <= ST_VERIFY_RUN;

        ST_VERIFY_RUN: begin
          if (verify_seed_ready) begin
            seed_count_q <= (seed_count_q == (active_seed_bytes_q - 1'b1)) ? 0 : seed_count_q + 1;
          end
          if (verify_done) begin
            o_ciphertext_equal <= verify_equal;
            state_q <= ST_K_START;
          end
        end

        ST_K_START: state_q <= ST_K_RUN;

        ST_K_RUN: begin
          if (k_done) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS) ||
          (i_runtime_r_bytes != ((i_runtime_r_bits + 7) >> 3)) ||
          (i_runtime_r_bytes > R_BYTES))
        $fatal(1, "trike_decaps_postprocess_core runtime r geometry out of range");
      if ((i_runtime_error_weight < 1) || (i_runtime_error_weight > ERROR_WEIGHT) ||
          (i_runtime_error_weight > (3 * i_runtime_r_bits)))
        $fatal(1, "trike_decaps_postprocess_core runtime weight out of range");
      if ((i_runtime_padded_r_bytes < i_runtime_r_bytes) ||
          (i_runtime_padded_r_bytes > PADDED_R_BYTES) ||
          (i_runtime_error_bytes != (3 * i_runtime_padded_r_bytes)) ||
          (i_runtime_error_bytes > ERROR_BYTES))
        $fatal(1, "trike_decaps_postprocess_core runtime error geometry out of range");
      if ((i_runtime_ciphertext_bytes < 1) || (i_runtime_ciphertext_bytes > CIPHERTEXT_BYTES))
        $fatal(1, "trike_decaps_postprocess_core runtime ciphertext length out of range");
    end
  end
`endif

endmodule
