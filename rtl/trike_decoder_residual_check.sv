`timescale 1ns / 1ps

// Recomputes syndrome xor H*e' with a fixed row-major schedule. Every row
// performs BLOCKS*WEIGHT synchronous decision reads, regardless of e' data.
module trike_decoder_residual_check #(
    parameter int R_BITS   = 12589,
    parameter int BLOCKS   = 3,
    parameter int WEIGHT   = 35,
    parameter int ROW_W    = ((R_BITS > 1) ? $clog2(R_BITS) : 1),
    parameter int COL_W    = (((BLOCKS * R_BITS) > 1) ? $clog2(BLOCKS * R_BITS) : 1),
    parameter int BLOCK_W  = ((BLOCKS > 1) ? $clog2(BLOCKS) : 1),
    parameter int DIAG_W   = ((WEIGHT > 1) ? $clog2(WEIGHT) : 1),
    parameter int WEIGHT_W = ((R_BITS > 1) ? $clog2(R_BITS + 1) : 1)
) (
    input  logic                i_clk,
    input  logic                i_rst_n,
    input  logic                i_h_we,
    input  logic [ BLOCK_W-1:0] i_h_block_idx,
    input  logic [  DIAG_W-1:0] i_h_diag_idx,
    input  logic [   ROW_W-1:0] i_h_index,
    input  logic                i_syndrome_we,
    input  logic [   ROW_W-1:0] i_syndrome_addr,
    input  logic                i_syndrome_data,
    input  logic                i_start,
    output logic [   COL_W-1:0] o_decision_col_idx,
    input  logic                i_decision_data,
    output logic                o_residual_zero,
    output logic [WEIGHT_W-1:0] o_residual_weight,
    output logic                o_busy,
    output logic                o_done
);

  localparam int SUPPORT_COUNT = BLOCKS * WEIGHT;
  localparam int SUPPORT_ADDR_W = (SUPPORT_COUNT > 1) ? $clog2(SUPPORT_COUNT) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_ROW_FETCH,
    ST_ROW_INIT,
    ST_DECISION_ISSUE,
    ST_DECISION_CONSUME
  } state_t;

  state_t                      state_q;
  logic   [         ROW_W-1:0] support_q[0:SUPPORT_COUNT-1];
  logic   [         ROW_W-1:0] row_q;
  logic   [       BLOCK_W-1:0] block_q;
  logic   [        DIAG_W-1:0] diag_q;
  logic                        parity_q;
  logic   [      WEIGHT_W-1:0] residual_weight_q;
  logic                        syndrome_re;
  logic   [         ROW_W-1:0] syndrome_raddr;
  logic                        syndrome_rdata;
  logic   [SUPPORT_ADDR_W-1:0] support_addr_c;
  integer                      column_c;
  logic   [         COL_W-1:0] decision_col_c;
  logic                        final_parity_c;

  ram_bram #(
      .DATA_W(1),
      .DEPTH (R_BITS),
      .ADDR_W(ROW_W)
  ) u_syndrome_mem (
      .i_clk  (i_clk),
      .i_we   (i_syndrome_we),
      .i_waddr(i_syndrome_addr),
      .i_wdata(i_syndrome_data),
      .i_re   (syndrome_re),
      .i_raddr(syndrome_raddr),
      .o_rdata(syndrome_rdata)
  );

  assign o_busy = state_q != ST_IDLE;

  always_comb begin
    support_addr_c = SUPPORT_ADDR_W'((int'(block_q) * WEIGHT) + int'(diag_q));
    if (int'(row_q) >= int'(support_q[support_addr_c])) begin
      column_c = int'(row_q) - int'(support_q[support_addr_c]);
    end else begin
      column_c = int'(row_q) + R_BITS - int'(support_q[support_addr_c]);
    end
    decision_col_c = COL_W'((int'(block_q) * R_BITS) + column_c);
    o_decision_col_idx = decision_col_c;
    final_parity_c = parity_q ^ i_decision_data;
    syndrome_re = state_q == ST_ROW_FETCH;
    syndrome_raddr = row_q;
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      row_q <= '0;
      block_q <= '0;
      diag_q <= '0;
      parity_q <= 1'b0;
      residual_weight_q <= '0;
      o_residual_zero <= 1'b0;
      o_residual_weight <= '0;
      o_done <= 1'b0;
      for (int idx = 0; idx < SUPPORT_COUNT; idx++) support_q[idx] <= '0;
    end else begin
      o_done <= 1'b0;

      if (i_h_we) begin
        support_q[(int'(i_h_block_idx)*WEIGHT)+int'(i_h_diag_idx)] <= i_h_index;
      end

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            row_q <= '0;
            block_q <= '0;
            diag_q <= '0;
            residual_weight_q <= '0;
            state_q <= ST_ROW_FETCH;
          end
        end

        ST_ROW_FETCH: state_q <= ST_ROW_INIT;

        ST_ROW_INIT: begin
          parity_q <= syndrome_rdata;
          block_q  <= '0;
          diag_q   <= '0;
          state_q  <= ST_DECISION_ISSUE;
        end

        ST_DECISION_ISSUE: state_q <= ST_DECISION_CONSUME;

        ST_DECISION_CONSUME: begin
          if ((block_q == BLOCK_W'(BLOCKS - 1)) && (diag_q == DIAG_W'(WEIGHT - 1))) begin
            residual_weight_q <= residual_weight_q + WEIGHT_W'(final_parity_c);
            if (row_q == ROW_W'(R_BITS - 1)) begin
              o_residual_weight <= residual_weight_q + WEIGHT_W'(final_parity_c);
              o_residual_zero <= (residual_weight_q + WEIGHT_W'(final_parity_c)) == '0;
              o_done <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              row_q   <= row_q + 1'b1;
              state_q <= ST_ROW_FETCH;
            end
          end else begin
            parity_q <= final_parity_c;
            if (diag_q == DIAG_W'(WEIGHT - 1)) begin
              diag_q  <= '0;
              block_q <= block_q + 1'b1;
            end else begin
              diag_q <= diag_q + 1'b1;
            end
            state_q <= ST_DECISION_ISSUE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  initial begin
    if ((R_BITS <= 0) || (BLOCKS <= 0) || (WEIGHT <= 0))
      $fatal(1, "trike_decoder_residual_check requires positive geometry");
  end

endmodule
