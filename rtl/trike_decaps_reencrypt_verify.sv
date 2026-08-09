`timescale 1ns / 1ps

// Regenerates e_calc = H4(m' || r2), compares every padded error byte with
// decoder e', and selects m' or sigma2 without data-dependent termination.
module trike_decaps_reencrypt_verify #(
    parameter int M_BYTES               = 32,
    parameter int R_BITS                = 12589,
    parameter int ERROR_WEIGHT          = 263,
    parameter int PADDED_R_BYTES        = ((R_BITS + 511) / 512) * 64,
    parameter bit USE_EXTERNAL_COMPRESS = 1'b0,
    parameter int DATA_W                = 8 * M_BYTES,
    parameter int ERROR_BYTES           = 3 * PADDED_R_BYTES,
    parameter int ERROR_ADDR_W          = ((ERROR_BYTES > 1) ? $clog2(ERROR_BYTES) : 1)
) (
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    input  logic                    i_start,
    input  logic                    i_decoder_ok,
    input  logic                    i_seed_valid,
    input  logic [             7:0] i_seed_data,
    output logic                    o_seed_ready,
    output logic                    o_seed_pass,
    output logic                    o_reference_re,
    output logic [ERROR_ADDR_W-1:0] o_reference_raddr,
    input  logic [             7:0] i_reference_rdata,
    input  logic [      DATA_W-1:0] i_match_data,
    input  logic [      DATA_W-1:0] i_mismatch_data,
    output logic                    o_equal,
    output logic [      DATA_W-1:0] o_selected_data,
    output logic                    o_busy,
    output logic                    o_done,
    output logic                    o_compress_start,
    output logic [           511:0] o_compress_block,
    output logic [           255:0] o_compress_state,
    input  logic                    i_compress_busy,
    input  logic                    i_compress_done,
    input  logic [           255:0] i_compress_state
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_H4_START,
    ST_H4_RUN,
    ST_VERIFY_START,
    ST_VERIFY_RUN
  } state_t;

  state_t                    state_q;
  logic   [ERROR_ADDR_W-1:0] verify_addr_q;
  logic                      h4_error_re;
  logic   [ERROR_ADDR_W-1:0] h4_error_raddr;
  logic   [             7:0] h4_error_rdata;
  logic                      h4_done;
  logic                      verify_reference_ready;
  logic                      verify_candidate_ready;
  logic                      verify_equal;
  logic   [      DATA_W-1:0] verify_selected_data;
  logic                      verify_done;

  assign o_busy = state_q != ST_IDLE;

  trike_h4_error_vector #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (R_BITS),
      .ERROR_WEIGHT         (ERROR_WEIGHT),
      .PADDED_R_BYTES       (PADDED_R_BYTES),
      .USE_EXTERNAL_COMPRESS(USE_EXTERNAL_COMPRESS)
  ) u_h4 (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (state_q == ST_H4_START),
      .i_seed_valid    (i_seed_valid && (state_q == ST_H4_RUN)),
      .i_seed_data     (i_seed_data),
      .o_seed_ready    (o_seed_ready),
      .o_seed_pass     (o_seed_pass),
      .i_support_re    (1'b0),
      .i_support_raddr ('0),
      .o_support_rdata (),
      .i_error_re      (h4_error_re),
      .i_error_raddr   (h4_error_raddr),
      .o_error_rdata   (h4_error_rdata),
      .o_busy          (),
      .o_done          (h4_done),
      .o_v             (),
      .o_c             (),
      .o_reseed_counter(),
      .o_compress_start(o_compress_start),
      .o_compress_block(o_compress_block),
      .o_compress_state(o_compress_state),
      .i_compress_busy (i_compress_busy),
      .i_compress_done (i_compress_done),
      .i_compress_state(i_compress_state)
  );

  trike_ct_verify_stream #(
      .WORD_W    (8),
      .WORD_COUNT(ERROR_BYTES),
      .DATA_W    (DATA_W)
  ) u_verify (
      .i_clk            (i_clk),
      .i_rst_n          (i_rst_n),
      .i_start          (state_q == ST_VERIFY_START),
      .i_decoder_ok     (i_decoder_ok),
      .i_reference_data (i_reference_rdata),
      .i_reference_valid(state_q == ST_VERIFY_RUN),
      .o_reference_ready(verify_reference_ready),
      .i_candidate_data (h4_error_rdata),
      .i_candidate_valid(state_q == ST_VERIFY_RUN),
      .o_candidate_ready(verify_candidate_ready),
      .i_match_data     (i_match_data),
      .i_mismatch_data  (i_mismatch_data),
      .o_equal          (verify_equal),
      .o_selected_data  (verify_selected_data),
      .o_busy           (),
      .o_done           (verify_done)
  );

  always_comb begin
    o_reference_re = 1'b0;
    o_reference_raddr = verify_addr_q;
    h4_error_re = 1'b0;
    h4_error_raddr = verify_addr_q;
    if (state_q == ST_VERIFY_START) begin
      o_reference_re = 1'b1;
      o_reference_raddr = '0;
      h4_error_re = 1'b1;
      h4_error_raddr = '0;
    end else if ((state_q == ST_VERIFY_RUN) && verify_reference_ready &&
                 verify_candidate_ready) begin
      o_reference_re = 1'b1;
      o_reference_raddr = (verify_addr_q == ERROR_ADDR_W'(ERROR_BYTES - 1)) ?
          '0 : verify_addr_q + 1'b1;
      h4_error_re = 1'b1;
      h4_error_raddr = (verify_addr_q == ERROR_ADDR_W'(ERROR_BYTES - 1)) ?
          '0 : verify_addr_q + 1'b1;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      verify_addr_q <= '0;
      o_equal <= 1'b0;
      o_selected_data <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) state_q <= ST_H4_START;
        end

        ST_H4_START: state_q <= ST_H4_RUN;

        ST_H4_RUN: begin
          if (h4_done) begin
            verify_addr_q <= '0;
            state_q <= ST_VERIFY_START;
          end
        end

        ST_VERIFY_START: state_q <= ST_VERIFY_RUN;

        ST_VERIFY_RUN: begin
          if (verify_reference_ready && verify_candidate_ready) begin
            verify_addr_q <= (verify_addr_q == ERROR_ADDR_W'(ERROR_BYTES - 1)) ?
                '0 : verify_addr_q + 1'b1;
          end
          if (verify_done) begin
            o_equal <= verify_equal;
            o_selected_data <= verify_selected_data;
            o_done <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

endmodule
