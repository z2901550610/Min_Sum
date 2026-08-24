`timescale 1ns / 1ps

// Complete H4 service with persistent support and padded dense error storage.
module trike_h4_error_vector #(
    parameter int M_BYTES               = 32,
    parameter int R_BITS                = 15581,
    parameter int ERROR_WEIGHT          = 263,
    parameter int PADDED_R_BYTES        = ((R_BITS + 511) / 512) * 64,
    parameter bit RUNTIME_GEOMETRY      = 1'b0,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0,
    parameter bit USE_EXTERNAL_SAMPLER  = 1'b0,
    parameter bit USE_EXTERNAL_STORE    = 1'b0
) (
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_start,
    input  logic [31:0] i_runtime_r_bits,
    input  logic [31:0] i_runtime_error_weight,
    input  logic [31:0] i_runtime_padded_r_bytes,
    input  logic i_seed_valid,
    input  logic [7:0] i_seed_data,
    output logic o_seed_ready,
    output logic o_seed_pass,
    input  logic i_support_re,
    input  logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] i_support_raddr,
    output logic [(((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] o_support_rdata,
    input  logic i_error_re,
    input  logic [(((3 * PADDED_R_BYTES) > 1) ? $clog2(
        3 * PADDED_R_BYTES
    ) : 1)-1:0] i_error_raddr,
    output logic [7:0] o_error_rdata,
    output logic o_busy,
    output logic o_done,
    output logic [439:0] o_v,
    output logic [439:0] o_c,
    output logic [439:0] o_reseed_counter,
    output logic o_compress_start,
    output logic [511:0] o_compress_block,
    output logic [255:0] o_compress_state,
    input  logic i_compress_busy,
    input  logic i_compress_done,
    input  logic [255:0] i_compress_state,
    output logic o_sampler_start,
    output logic [31:0] o_sampler_runtime_length,
    output logic [31:0] o_sampler_runtime_weight,
    output logic [439:0] o_sampler_v,
    output logic [439:0] o_sampler_c,
    output logic [439:0] o_sampler_reseed_counter,
    input  logic i_sampler_index_valid,
    input  logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] i_sampler_index_position,
    input  logic [(((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] i_sampler_index,
    output logic o_sampler_index_ready,
    input  logic i_sampler_done,
    input  logic [439:0] i_sampler_v,
    input  logic [439:0] i_sampler_c,
    input  logic [439:0] i_sampler_reseed_counter,
    /* verilator lint_off UNUSEDSIGNAL */
    output logic o_store_start,
    output logic [31:0] o_store_runtime_r_bits,
    output logic [31:0] o_store_runtime_error_weight,
    output logic [31:0] o_store_runtime_padded_r_bytes,
    output logic o_store_index_valid,
    output logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] o_store_index_position,
    output logic [(((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] o_store_index,
    input  logic i_store_index_ready,
    output logic o_store_support_re,
    output logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] o_store_support_raddr,
    input  logic [(((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] i_store_support_rdata,
    output logic o_store_error_re,
    output logic [(((3 * PADDED_R_BYTES) > 1) ? $clog2(
3 * PADDED_R_BYTES
) : 1)-1:0] o_store_error_raddr,
    input  logic [7:0] i_store_error_rdata,
    input  logic i_store_done
    /* verilator lint_on UNUSEDSIGNAL */
);

  typedef enum logic {
    ST_IDLE,
    ST_RUN
  } state_t;

  state_t                                                       state_q;
  logic                                                         h4_start;
  logic                                                         h4_index_valid;
  logic   [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] h4_index_position;
  logic   [  (((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] h4_index;
  logic                                                         h4_index_ready;
  logic                                                         h4_done;
  logic                                                         store_start;
  logic                                                         store_done;
  logic                                                         h4_done_seen_q;
  logic                                                         store_done_seen_q;

  assign h4_start = (state_q == ST_IDLE) && i_start;
  assign store_start = h4_start;
  assign o_busy = state_q != ST_IDLE;
  assign o_store_start = store_start;
  assign o_store_runtime_r_bits = RUNTIME_GEOMETRY ? i_runtime_r_bits : 32'(R_BITS);
  assign o_store_runtime_error_weight =
      RUNTIME_GEOMETRY ? i_runtime_error_weight : 32'(ERROR_WEIGHT);
  assign o_store_runtime_padded_r_bytes =
      RUNTIME_GEOMETRY ? i_runtime_padded_r_bytes : 32'(PADDED_R_BYTES);
  assign o_store_index_valid = h4_index_valid && (state_q == ST_RUN);
  assign o_store_index_position = h4_index_position;
  assign o_store_index = h4_index;
  assign o_store_support_re = i_support_re && (state_q == ST_IDLE);
  assign o_store_support_raddr = i_support_raddr;
  assign o_store_error_re = i_error_re && (state_q == ST_IDLE);
  assign o_store_error_raddr = i_error_raddr;

  trike_h4_error_sampler #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (R_BITS),
      .ERROR_WEIGHT         (ERROR_WEIGHT),
      .RUNTIME_GEOMETRY     (RUNTIME_GEOMETRY),
      .USE_EXTERNAL_COMPRESS(USE_EXTERNAL_COMPRESS),
      .USE_EXTERNAL_SAMPLER (USE_EXTERNAL_SAMPLER)
  ) u_h4 (
      .i_clk                   (i_clk),
      .i_rst_n                 (i_rst_n),
      .i_start                 (h4_start),
      .i_runtime_r_bits        (i_runtime_r_bits),
      .i_runtime_error_weight  (i_runtime_error_weight),
      .i_seed_valid            (i_seed_valid && (state_q == ST_RUN)),
      .i_seed_data             (i_seed_data),
      .o_seed_ready            (o_seed_ready),
      .o_seed_pass             (o_seed_pass),
      .o_index_valid           (h4_index_valid),
      .o_index_position        (h4_index_position),
      .o_index                 (h4_index),
      .i_index_ready           (h4_index_ready),
      .o_busy                  (),
      .o_done                  (h4_done),
      .o_v                     (o_v),
      .o_c                     (o_c),
      .o_reseed_counter        (o_reseed_counter),
      .o_compress_start        (o_compress_start),
      .o_compress_block        (o_compress_block),
      .o_compress_state        (o_compress_state),
      .i_compress_busy         (i_compress_busy),
      .i_compress_done         (i_compress_done),
      .i_compress_state        (i_compress_state),
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

  generate
    if (USE_EXTERNAL_STORE) begin : gen_external_store
      assign h4_index_ready = i_store_index_ready;
      assign o_support_rdata = i_store_support_rdata;
      assign o_error_rdata = i_store_error_rdata;
      assign store_done = i_store_done;
    end else begin : gen_local_store
      trike_error_support_store #(
          .R_BITS          (R_BITS),
          .ERROR_WEIGHT    (ERROR_WEIGHT),
          .PADDED_R_BYTES  (PADDED_R_BYTES),
          .RUNTIME_GEOMETRY(RUNTIME_GEOMETRY)
      ) u_store (
          .i_clk                   (i_clk),
          .i_rst_n                 (i_rst_n),
          .i_start                 (store_start),
          .i_runtime_r_bits        (i_runtime_r_bits),
          .i_runtime_error_weight  (i_runtime_error_weight),
          .i_runtime_padded_r_bytes(i_runtime_padded_r_bytes),
          .i_index_valid           (h4_index_valid && (state_q == ST_RUN)),
          .i_index_position        (h4_index_position),
          .i_index                 (h4_index),
          .o_index_ready           (h4_index_ready),
          .i_support_re            (i_support_re && (state_q == ST_IDLE)),
          .i_support_raddr         (i_support_raddr),
          .o_support_rdata         (o_support_rdata),
          .i_error_re              (i_error_re && (state_q == ST_IDLE)),
          .i_error_raddr           (i_error_raddr),
          .o_error_rdata           (o_error_rdata),
          .o_busy                  (),
          .o_done                  (store_done)
      );
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      h4_done_seen_q <= 1'b0;
      store_done_seen_q <= 1'b0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            h4_done_seen_q <= 1'b0;
            store_done_seen_q <= 1'b0;
            state_q <= ST_RUN;
          end
        end

        ST_RUN: begin
          if (h4_done) h4_done_seen_q <= 1'b1;
          if (store_done) store_done_seen_q <= 1'b1;
          if ((h4_done || h4_done_seen_q) && (store_done || store_done_seen_q)) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

endmodule
