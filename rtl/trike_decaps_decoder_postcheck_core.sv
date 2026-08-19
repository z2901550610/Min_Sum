`timescale 1ns / 1ps

// Sequences decoder decision reads through the padded error writer and the
// two-row residual checker. Public runtime geometry is latched once at i_start
// and remains fixed for the complete transaction.
module trike_decaps_decoder_postcheck_core #(
    parameter int R_BITS = 106781,
    parameter int BLOCKS = 3,
    parameter int WEIGHT = 111,
    parameter int PADDED_R_BYTES = ((R_BITS + 511) / 512) * 64,
    parameter int ROW_W = ((R_BITS > 1) ? $clog2(R_BITS) : 1),
    parameter int COL_W = (((BLOCKS * R_BITS) > 1) ? $clog2(BLOCKS * R_BITS) : 1),
    parameter int BLOCK_W = ((BLOCKS > 1) ? $clog2(BLOCKS) : 1),
    parameter int DIAG_W = ((WEIGHT > 1) ? $clog2(WEIGHT) : 1),
    parameter int ERROR_ADDR_W = (((BLOCKS * PADDED_R_BYTES) > 1) ? $clog2(
        BLOCKS * PADDED_R_BYTES
    ) : 1),
    parameter int RESIDUAL_WEIGHT_W = ((R_BITS > 1) ? $clog2(R_BITS + 1) : 1)
) (
    input  logic                         i_clk,
    input  logic                         i_rst_n,
    input  logic                         i_h_we,
    input  logic [          BLOCK_W-1:0] i_h_block_idx,
    input  logic [           DIAG_W-1:0] i_h_diag_idx,
    input  logic [            ROW_W-1:0] i_h_index,
    input  logic                         i_syndrome_we,
    input  logic [            ROW_W-1:0] i_syndrome_addr,
    input  logic                         i_syndrome_data,
    input  logic                         i_start,
    input  logic [                 31:0] i_runtime_r_bits,
    input  logic [                 31:0] i_runtime_weight,
    output logic [            COL_W-1:0] o_decision_col_idx,
    output logic [            COL_W-1:0] o_decision_col_idx_1,
    output logic                         o_decision_valid_1,
    input  logic                         i_decision_data,
    input  logic                         i_decision_data_1,
    input  logic                         i_error_re,
    input  logic [     ERROR_ADDR_W-1:0] i_error_raddr,
    output logic [                  7:0] o_error_rdata,
    output logic                         o_residual_zero,
    output logic [RESIDUAL_WEIGHT_W-1:0] o_residual_weight,
    output logic                         o_busy,
    output logic                         o_done
);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_ERROR_START,
    ST_ERROR_RUN,
    ST_RESIDUAL_START,
    ST_RESIDUAL_RUN
  } state_t;

  state_t             state_q;
  logic   [     31:0] runtime_r_bits_q;
  logic   [     31:0] runtime_weight_q;
  logic   [COL_W-1:0] error_decision_col;
  logic               error_busy;
  logic               error_done;
  logic   [COL_W-1:0] residual_decision_col;
  logic   [COL_W-1:0] residual_decision_col_1;
  logic               residual_decision_valid_1;
  logic               residual_busy;
  logic               residual_done;

  assign o_decision_col_idx = (state_q == ST_ERROR_RUN) ? error_decision_col :
                              (state_q == ST_RESIDUAL_RUN) ? residual_decision_col : '0;
  assign o_decision_col_idx_1 = (state_q == ST_RESIDUAL_RUN) ? residual_decision_col_1 : '0;
  assign o_decision_valid_1 = (state_q == ST_RESIDUAL_RUN) && residual_decision_valid_1;
  assign o_busy = (state_q != ST_IDLE) || error_busy || residual_busy;

  trike_decoder_error_vector #(
      .R_BITS(R_BITS),
      .BLOCKS(BLOCKS),
      .PADDED_R_BYTES(PADDED_R_BYTES),
      .RUNTIME_GEOMETRY(1'b1)
  ) u_error_vector (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (state_q == ST_ERROR_START),
      .i_runtime_r_bits  (runtime_r_bits_q),
      .o_decision_col_idx(error_decision_col),
      .i_decision_data   (i_decision_data),
      .i_error_re        (i_error_re),
      .i_error_raddr     (i_error_raddr),
      .o_error_rdata     (o_error_rdata),
      .o_busy            (error_busy),
      .o_done            (error_done)
  );

  trike_decoder_residual_check #(
      .R_BITS(R_BITS),
      .BLOCKS(BLOCKS),
      .WEIGHT(WEIGHT),
      .RUNTIME_GEOMETRY(1'b1)
  ) u_residual (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_h_we              (i_h_we),
      .i_h_block_idx       (i_h_block_idx),
      .i_h_diag_idx        (i_h_diag_idx),
      .i_h_index           (i_h_index),
      .i_syndrome_we       (i_syndrome_we),
      .i_syndrome_addr     (i_syndrome_addr),
      .i_syndrome_data     (i_syndrome_data),
      .i_start             (state_q == ST_RESIDUAL_START),
      .i_runtime_r_bits    (runtime_r_bits_q),
      .i_runtime_weight    (runtime_weight_q),
      .o_decision_col_idx  (residual_decision_col),
      .o_decision_col_idx_1(residual_decision_col_1),
      .o_decision_valid_1  (residual_decision_valid_1),
      .i_decision_data     (i_decision_data),
      .i_decision_data_1   (i_decision_data_1),
      .o_residual_zero     (o_residual_zero),
      .o_residual_weight   (o_residual_weight),
      .o_busy              (residual_busy),
      .o_done              (residual_done)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      runtime_r_bits_q <= 32'(R_BITS);
      runtime_weight_q <= 32'(WEIGHT);
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            runtime_r_bits_q <= i_runtime_r_bits;
            runtime_weight_q <= i_runtime_weight;
            state_q <= ST_ERROR_START;
          end
        end

        ST_ERROR_START: state_q <= ST_ERROR_RUN;

        ST_ERROR_RUN: begin
          if (error_done) state_q <= ST_RESIDUAL_START;
        end

        ST_RESIDUAL_START: state_q <= ST_RESIDUAL_RUN;

        ST_RESIDUAL_RUN: begin
          if (residual_done) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  initial begin
    if ((R_BITS <= 0) || (BLOCKS <= 0) || (WEIGHT <= 0))
      $fatal(1, "trike_decaps_decoder_postcheck_core requires positive geometry");
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS))
        $fatal(1, "trike_decaps_decoder_postcheck_core runtime r out of range");
      if ((i_runtime_weight < 1) || (i_runtime_weight > WEIGHT))
        $fatal(1, "trike_decaps_decoder_postcheck_core runtime weight out of range");
    end
  end
`endif

endmodule
