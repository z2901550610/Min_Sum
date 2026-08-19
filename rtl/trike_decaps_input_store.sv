`timescale 1ns / 1ps

// Maximum-geometry storage boundary for the runtime-profile Decaps input
// transaction. Only the active public-profile ranges are written and later
// exposed to the fixed-schedule syndrome and post-processing readers.
module trike_decaps_input_store #(
    parameter int WORD_W            = 64,
    parameter int M_BYTES           = 32,
    parameter int MAX_R_BITS        = bike_pkg::P_R_VALS                [3],
    parameter int MAX_SECRET_WEIGHT = bike_pkg::P_W_VALS                [3],
    parameter int MAX_R_BYTES       = (MAX_R_BITS + 7) / 8,
    parameter int MAX_WORDS         = (MAX_R_BITS + WORD_W - 1) / WORD_W,
    parameter int MAX_SUPPORT_COUNT = 3 * MAX_SECRET_WEIGHT,
    parameter int MAX_CT_BYTES      = (2 * MAX_R_BYTES) + M_BYTES,
    parameter int SUPPORT_ADDR_W    = $clog2(MAX_SUPPORT_COUNT),
    parameter int ROW_ADDR_W        = $clog2(MAX_R_BITS),
    parameter int WORD_ADDR_W       = $clog2(MAX_WORDS),
    parameter int R_ADDR_W          = $clog2(MAX_R_BYTES),
    parameter int CT_ADDR_W         = $clog2(MAX_CT_BYTES)
) (
    input  logic                              i_clk,
    input  logic                              i_rst_n,
    input  logic                              i_start,
    input  logic [bike_pkg::PROFILE_ID_W-1:0] i_param_level,
    input  logic                              i_valid,
    input  logic [                       7:0] i_data,
    output logic                              o_ready,
    input  logic                              i_support_re,
    input  logic [        SUPPORT_ADDR_W-1:0] i_support_raddr,
    output logic [            ROW_ADDR_W-1:0] o_support_rdata,
    input  logic                              i_t0_re,
    input  logic [           WORD_ADDR_W-1:0] i_t0_raddr,
    output logic [                WORD_W-1:0] o_t0_rdata,
    input  logic                              i_r2_re,
    input  logic [              R_ADDR_W-1:0] i_r2_raddr,
    output logic [                       7:0] o_r2_rdata,
    input  logic                              i_u_re,
    input  logic [           WORD_ADDR_W-1:0] i_u_raddr,
    output logic [                WORD_W-1:0] o_u_rdata,
    input  logic                              i_v_re,
    input  logic [           WORD_ADDR_W-1:0] i_v_raddr,
    output logic [                WORD_W-1:0] o_v_rdata,
    input  logic                              i_ciphertext_re,
    input  logic [             CT_ADDR_W-1:0] i_ciphertext_raddr,
    output logic [                       7:0] o_ciphertext_rdata,
    output logic [             8*M_BYTES-1:0] o_sigma2,
    output logic [bike_pkg::PROFILE_ID_W-1:0] o_param_level,
    output logic [                      31:0] o_r_bits,
    output logic [                      31:0] o_secret_weight,
    output logic [                      31:0] o_error_weight,
    output logic [                      31:0] o_r_bytes,
    output logic [                      31:0] o_padded_r_bytes,
    output logic [                      31:0] o_words,
    output logic [                      31:0] o_support_count,
    output logic [                      31:0] o_secret_key_bytes,
    output logic [                      31:0] o_ciphertext_bytes,
    output logic [                      31:0] o_input_bytes,
    output logic [                      31:0] o_error_bytes,
    output logic                              o_busy,
    output logic                              o_done
);
  import bike_pkg::*;

  localparam int SIGMA_ADDR_W = $clog2(M_BYTES);

  logic                      support_we;
  logic [SUPPORT_ADDR_W-1:0] support_waddr;
  logic [    ROW_ADDR_W-1:0] support_wdata;
  logic                      t0_we;
  logic [   WORD_ADDR_W-1:0] t0_waddr;
  logic [        WORD_W-1:0] t0_wdata;
  logic                      r2_we;
  logic [      R_ADDR_W-1:0] r2_waddr;
  logic [               7:0] r2_wdata;
  logic                      u_we;
  logic [   WORD_ADDR_W-1:0] u_waddr;
  logic [        WORD_W-1:0] u_wdata;
  logic                      v_we;
  logic [   WORD_ADDR_W-1:0] v_waddr;
  logic [        WORD_W-1:0] v_wdata;
  logic                      ciphertext_we;
  logic [     CT_ADDR_W-1:0] ciphertext_waddr;
  logic [               7:0] ciphertext_wdata;
  logic                      sigma2_we;
  logic [  SIGMA_ADDR_W-1:0] sigma2_waddr;
  logic [               7:0] sigma2_wdata;

  trike_decaps_input_loader #(
      .WORD_W           (WORD_W),
      .M_BYTES          (M_BYTES),
      .MAX_R_BITS       (MAX_R_BITS),
      .MAX_SECRET_WEIGHT(MAX_SECRET_WEIGHT),
      .SUPPORT_ADDR_W   (SUPPORT_ADDR_W),
      .ROW_ADDR_W       (ROW_ADDR_W),
      .WORD_ADDR_W      (WORD_ADDR_W),
      .R_ADDR_W         (R_ADDR_W),
      .CT_ADDR_W        (CT_ADDR_W),
      .SIGMA_ADDR_W     (SIGMA_ADDR_W)
  ) u_loader (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (i_start),
      .i_param_level     (i_param_level),
      .i_valid           (i_valid),
      .i_data            (i_data),
      .o_ready           (o_ready),
      .o_support_we      (support_we),
      .o_support_waddr   (support_waddr),
      .o_support_wdata   (support_wdata),
      .o_t0_we           (t0_we),
      .o_t0_waddr        (t0_waddr),
      .o_t0_wdata        (t0_wdata),
      .o_r2_we           (r2_we),
      .o_r2_waddr        (r2_waddr),
      .o_r2_wdata        (r2_wdata),
      .o_u_we            (u_we),
      .o_u_waddr         (u_waddr),
      .o_u_wdata         (u_wdata),
      .o_v_we            (v_we),
      .o_v_waddr         (v_waddr),
      .o_v_wdata         (v_wdata),
      .o_ct_we           (ciphertext_we),
      .o_ct_waddr        (ciphertext_waddr),
      .o_ct_wdata        (ciphertext_wdata),
      .o_sigma2_we       (sigma2_we),
      .o_sigma2_waddr    (sigma2_waddr),
      .o_sigma2_wdata    (sigma2_wdata),
      .o_param_level     (o_param_level),
      .o_r_bits          (o_r_bits),
      .o_secret_weight   (o_secret_weight),
      .o_error_weight    (o_error_weight),
      .o_r_bytes         (o_r_bytes),
      .o_padded_r_bytes  (o_padded_r_bytes),
      .o_words           (o_words),
      .o_support_count   (o_support_count),
      .o_secret_key_bytes(o_secret_key_bytes),
      .o_ciphertext_bytes(o_ciphertext_bytes),
      .o_input_bytes     (o_input_bytes),
      .o_error_bytes     (o_error_bytes),
      .o_busy            (o_busy),
      .o_done            (o_done)
  );

  ram_bram #(
      .DATA_W(ROW_ADDR_W),
      .DEPTH (MAX_SUPPORT_COUNT),
      .ADDR_W(SUPPORT_ADDR_W)
  ) u_support_mem (
      .i_clk  (i_clk),
      .i_we   (support_we),
      .i_waddr(support_waddr),
      .i_wdata(support_wdata),
      .i_re   (i_support_re),
      .i_raddr(i_support_raddr),
      .o_rdata(o_support_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (MAX_WORDS),
      .ADDR_W(WORD_ADDR_W)
  ) u_t0_mem (
      .i_clk  (i_clk),
      .i_we   (t0_we),
      .i_waddr(t0_waddr),
      .i_wdata(t0_wdata),
      .i_re   (i_t0_re),
      .i_raddr(i_t0_raddr),
      .o_rdata(o_t0_rdata)
  );

  ram_bram #(
      .DATA_W(8),
      .DEPTH (MAX_R_BYTES),
      .ADDR_W(R_ADDR_W)
  ) u_r2_mem (
      .i_clk  (i_clk),
      .i_we   (r2_we),
      .i_waddr(r2_waddr),
      .i_wdata(r2_wdata),
      .i_re   (i_r2_re),
      .i_raddr(i_r2_raddr),
      .o_rdata(o_r2_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (MAX_WORDS),
      .ADDR_W(WORD_ADDR_W)
  ) u_u_mem (
      .i_clk  (i_clk),
      .i_we   (u_we),
      .i_waddr(u_waddr),
      .i_wdata(u_wdata),
      .i_re   (i_u_re),
      .i_raddr(i_u_raddr),
      .o_rdata(o_u_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (MAX_WORDS),
      .ADDR_W(WORD_ADDR_W)
  ) u_v_mem (
      .i_clk  (i_clk),
      .i_we   (v_we),
      .i_waddr(v_waddr),
      .i_wdata(v_wdata),
      .i_re   (i_v_re),
      .i_raddr(i_v_raddr),
      .o_rdata(o_v_rdata)
  );

  ram_bram #(
      .DATA_W(8),
      .DEPTH (MAX_CT_BYTES),
      .ADDR_W(CT_ADDR_W)
  ) u_ciphertext_mem (
      .i_clk  (i_clk),
      .i_we   (ciphertext_we),
      .i_waddr(ciphertext_waddr),
      .i_wdata(ciphertext_wdata),
      .i_re   (i_ciphertext_re),
      .i_raddr(i_ciphertext_raddr),
      .o_rdata(o_ciphertext_rdata)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_sigma2 <= '0;
    end else if (sigma2_we) begin
      o_sigma2[8*sigma2_waddr+:8] <= sigma2_wdata;
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (MAX_R_BITS != P_R_VALS[3])
      $fatal(1, "trike_decaps_input_store requires maximum TRIKE geometry");
  end
`endif

endmodule
