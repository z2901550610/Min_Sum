`timescale 1ns / 1ps

// Runtime-profile syndrome engine connected to maximum-geometry input-store
// read ports. The prefetch transaction and arithmetic core start together;
// the core's load-state ready signals provide the fixed stream schedule.
module trike_decaps_syndrome_store_core #(
    parameter int WORD_W            = 64,
    parameter int DIGIT_W           = 16,
    parameter int MAX_R_BITS        = bike_pkg::P_R_VALS                        [3],
    parameter int MAX_SECRET_WEIGHT = bike_pkg::P_W_VALS                        [3],
    parameter bit EXTERNAL_H0       = 1'b0,
    parameter int SUPPORT_ADDR_W    = $clog2(3 * MAX_SECRET_WEIGHT),
    parameter int WORD_ADDR_W       = $clog2((MAX_R_BITS + WORD_W - 1) / WORD_W),
    parameter int INDEX_W           = $clog2(MAX_R_BITS)
) (
    input  logic                      i_clk,
    input  logic                      i_rst_n,
    input  logic                      i_start,
    input  logic [              31:0] i_r_bits,
    input  logic [              31:0] i_secret_weight,
    input  logic [              31:0] i_words,
    output logic                      o_support_re,
    output logic [SUPPORT_ADDR_W-1:0] o_support_raddr,
    input  logic [       INDEX_W-1:0] i_support_rdata,
    output logic                      o_t0_re,
    output logic [   WORD_ADDR_W-1:0] o_t0_raddr,
    input  logic [        WORD_W-1:0] i_t0_rdata,
    output logic                      o_u_re,
    output logic [   WORD_ADDR_W-1:0] o_u_raddr,
    input  logic [        WORD_W-1:0] i_u_rdata,
    output logic                      o_v_re,
    output logic [   WORD_ADDR_W-1:0] o_v_raddr,
    input  logic [        WORD_W-1:0] i_v_rdata,
    input  logic                      i_h0_valid,
    input  logic [       INDEX_W-1:0] i_h0_index,
    output logic                      o_h0_ready,
    output logic                      o_syndrome_valid,
    output logic [        WORD_W-1:0] o_syndrome_data,
    output logic                      o_syndrome_last,
    input  logic                      i_syndrome_ready,
    output logic                      o_busy,
    output logic                      o_done
);

  logic               h0_valid;
  logic [INDEX_W-1:0] h0_index;
  logic               t0_valid;
  logic [ WORD_W-1:0] t0_data;
  logic               t0_ready;
  logic               u_valid;
  logic [ WORD_W-1:0] u_data;
  logic               u_ready;
  logic               v_valid;
  logic [ WORD_W-1:0] v_data;
  logic               v_ready;
  logic               prefetch_busy;
  logic               prefetch_done;
  logic               syndrome_busy;
  logic               selected_h0_valid;
  logic [INDEX_W-1:0] selected_h0_index;
  logic               syndrome_h0_ready;

  assign selected_h0_valid = EXTERNAL_H0 ? i_h0_valid : h0_valid;
  assign selected_h0_index = EXTERNAL_H0 ? i_h0_index : h0_index;
  assign o_h0_ready = EXTERNAL_H0 && syndrome_h0_ready;

  trike_decaps_syndrome_prefetch #(
      .WORD_W           (WORD_W),
      .MAX_R_BITS       (MAX_R_BITS),
      .MAX_SECRET_WEIGHT(MAX_SECRET_WEIGHT),
      .EXTERNAL_H0      (EXTERNAL_H0),
      .SUPPORT_ADDR_W   (SUPPORT_ADDR_W),
      .WORD_ADDR_W      (WORD_ADDR_W),
      .INDEX_W          (INDEX_W)
  ) u_prefetch (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_start        (i_start),
      .i_secret_weight(i_secret_weight),
      .i_words        (i_words),
      .o_support_re   (o_support_re),
      .o_support_raddr(o_support_raddr),
      .i_support_rdata(i_support_rdata),
      .o_t0_re        (o_t0_re),
      .o_t0_raddr     (o_t0_raddr),
      .i_t0_rdata     (i_t0_rdata),
      .o_u_re         (o_u_re),
      .o_u_raddr      (o_u_raddr),
      .i_u_rdata      (i_u_rdata),
      .o_v_re         (o_v_re),
      .o_v_raddr      (o_v_raddr),
      .i_v_rdata      (i_v_rdata),
      .o_h0_valid     (h0_valid),
      .o_h0_index     (h0_index),
      .i_h0_ready     (syndrome_h0_ready),
      .o_t0_valid     (t0_valid),
      .o_t0_data      (t0_data),
      .i_t0_ready     (t0_ready),
      .o_u_valid      (u_valid),
      .o_u_data       (u_data),
      .i_u_ready      (u_ready),
      .o_v_valid      (v_valid),
      .o_v_data       (v_data),
      .i_v_ready      (v_ready),
      .o_busy         (prefetch_busy),
      .o_done         (prefetch_done)
  );

  trike_decaps_syndrome_core #(
      .R_BITS          (MAX_R_BITS),
      .SECRET_WEIGHT   (MAX_SECRET_WEIGHT),
      .WORD_W          (WORD_W),
      .DIGIT_W         (DIGIT_W),
      .RUNTIME_GEOMETRY(1'b1),
      .WORD_ADDR_W     (WORD_ADDR_W)
  ) u_syndrome (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_start                (i_start),
      .i_runtime_r_bits       (i_r_bits),
      .i_runtime_secret_weight(i_secret_weight),
      .i_runtime_words        (i_words),
      .i_h0_valid             (selected_h0_valid),
      .i_h0_index             (selected_h0_index),
      .o_h0_ready             (syndrome_h0_ready),
      .i_t0_valid             (t0_valid),
      .i_t0_data              (t0_data),
      .o_t0_ready             (t0_ready),
      .i_u_valid              (u_valid),
      .i_u_data               (u_data),
      .o_u_ready              (u_ready),
      .i_v_valid              (v_valid),
      .i_v_data               (v_data),
      .o_v_ready              (v_ready),
      .o_syndrome_valid       (o_syndrome_valid),
      .o_syndrome_data        (o_syndrome_data),
      .o_syndrome_last        (o_syndrome_last),
      .i_syndrome_ready       (i_syndrome_ready),
      .o_busy                 (syndrome_busy),
      .o_done                 (o_done)
  );

  assign o_busy = prefetch_busy || syndrome_busy;

  /* verilator lint_off UNUSED */
  logic unused_prefetch_done;
  always_comb unused_prefetch_done = prefetch_done;
  /* verilator lint_on UNUSED */

endmodule
