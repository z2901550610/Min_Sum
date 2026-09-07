`timescale 1ns / 1ps

// Recomputes syndrome xor H*e' with a fixed two-row schedule. Every active row
// performs BLOCKS*active_weight synchronous decision reads, regardless of e'
// data. Runtime geometry is a public descriptor sampled with i_start.
module trike_decoder_residual_check #(
    parameter int R_BITS           = 12589,
    parameter int BLOCKS           = 3,
    parameter int WEIGHT           = 35,
    parameter bit RUNTIME_GEOMETRY = 1'b0,
    parameter int ROW_W            = ((R_BITS > 1) ? $clog2(R_BITS) : 1),
    parameter int COL_W            = (((BLOCKS * R_BITS) > 1) ? $clog2(BLOCKS * R_BITS) : 1),
    parameter int BLOCK_W          = ((BLOCKS > 1) ? $clog2(BLOCKS) : 1),
    parameter int DIAG_W           = ((WEIGHT > 1) ? $clog2(WEIGHT) : 1),
    parameter int WEIGHT_W         = ((R_BITS > 1) ? $clog2(R_BITS + 1) : 1)
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
    input  logic [        31:0] i_runtime_r_bits,
    input  logic [        31:0] i_runtime_weight,
    output logic [   COL_W-1:0] o_decision_col_idx,
    output logic [   COL_W-1:0] o_decision_col_idx_1,
    output logic                o_decision_valid_1,
    input  logic                i_decision_data,
    input  logic                i_decision_data_1,
    output logic                o_residual_zero,
    output logic [WEIGHT_W-1:0] o_residual_weight,
    output logic                o_busy,
    output logic                o_done
);

  localparam int SUPPORT_COUNT  = BLOCKS * WEIGHT;
  localparam int SUPPORT_ADDR_W = (SUPPORT_COUNT > 1) ? $clog2(SUPPORT_COUNT) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_ROW0_FETCH,
    ST_ROW1_FETCH,
    ST_ROW_INIT,
    ST_DECISION_ISSUE,
    ST_DECISION_CONSUME
  } state_t;

  state_t                      state_q;
  logic   [         ROW_W-1:0] row_q;
  logic   [       BLOCK_W-1:0] block_q;
  logic   [        DIAG_W-1:0] diag_q;
  logic                        parity_q[0:1];
  logic   [      WEIGHT_W-1:0] residual_weight_q;
  logic                        support_re;
  logic   [SUPPORT_ADDR_W-1:0] support_raddr;
  logic   [         ROW_W-1:0] support_rdata;
  logic                        syndrome_re;
  logic   [         ROW_W-1:0] syndrome_raddr;
  logic                        syndrome_rdata;
  logic   [SUPPORT_ADDR_W-1:0] support_addr_c;
  logic                        final_support_c;
  logic   [         COL_W-1:0] decision_col_0_q;
  logic   [         COL_W-1:0] decision_col_1_q;
  logic                        final_parity_0_c;
  logic                        final_parity_1_c;
  logic                        row1_active_c;
  logic                        row1_active_q;
  logic   [      WEIGHT_W-1:0] row_residual_count_c;
  integer                      active_r_bits_q;
  integer                      active_weight_q;

  function automatic logic [COL_W-1:0] decision_col(
      input integer row_value, input integer block_value, input  logic [ROW_W-1:0] support_value,
      input integer r_bits_value);
    integer local_col;
    begin
      if (row_value >= int'(support_value)) begin
        local_col = row_value - int'(support_value);
      end else begin
        local_col = row_value + r_bits_value - int'(support_value);
      end
      decision_col = COL_W'((block_value * r_bits_value) + local_col);
    end
  endfunction

  // The sorted H support uses a sequential synchronous-RAM read schedule.
  // The registered decision columns form a physical timing boundary before the decoder's
  // global K-sign RAM address network.
  ram_bram #(
      .DATA_W(ROW_W),
      .DEPTH (SUPPORT_COUNT)
  ) u_support_mem (
      .i_clk  (i_clk),
      .i_we   (i_h_we),
      .i_waddr(SUPPORT_ADDR_W'((int'(i_h_block_idx) * WEIGHT) + int'(i_h_diag_idx))),
      .i_wdata(i_h_index),
      .i_re   (support_re),
      .i_raddr(support_raddr),
      .o_rdata(support_rdata)
  );

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
    final_support_c = (block_q == BLOCK_W'(BLOCKS - 1)) && (diag_q == DIAG_W'(active_weight_q - 1));
    support_re = state_q == ST_ROW0_FETCH;
    support_raddr = support_addr_c;
    if ((state_q == ST_DECISION_ISSUE) && !final_support_c) begin
      support_re = 1'b1;
      if (diag_q == DIAG_W'(active_weight_q - 1)) begin
        support_raddr = SUPPORT_ADDR_W'((int'(block_q) + 1) * WEIGHT);
      end else begin
        support_raddr = support_addr_c + 1'b1;
      end
    end

    row1_active_c = int'(row_q) + 1 < active_r_bits_q;
    final_parity_0_c = parity_q[0] ^ i_decision_data;
    final_parity_1_c = parity_q[1] ^ i_decision_data_1;
    o_decision_col_idx = decision_col_0_q;
    o_decision_col_idx_1 = decision_col_1_q;
    o_decision_valid_1 = (state_q == ST_DECISION_ISSUE) && row1_active_q;
    row_residual_count_c = WEIGHT_W'(final_parity_0_c) +
        WEIGHT_W'(row1_active_q && final_parity_1_c);
    syndrome_re = (state_q == ST_ROW0_FETCH) || ((state_q == ST_ROW1_FETCH) && row1_active_c);
    syndrome_raddr = (state_q == ST_ROW1_FETCH) ? row_q + 1'b1 : row_q;
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      row_q <= '0;
      block_q <= '0;
      diag_q <= '0;
      parity_q[0] <= 1'b0;
      parity_q[1] <= 1'b0;
      residual_weight_q <= '0;
      decision_col_0_q <= '0;
      decision_col_1_q <= '0;
      row1_active_q <= 1'b0;
      active_r_bits_q <= R_BITS;
      active_weight_q <= WEIGHT;
      o_residual_zero <= 1'b0;
      o_residual_weight <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            row_q <= '0;
            block_q <= '0;
            diag_q <= '0;
            residual_weight_q <= '0;
            if (RUNTIME_GEOMETRY) begin
              active_r_bits_q <= int'(i_runtime_r_bits);
              active_weight_q <= int'(i_runtime_weight);
            end else begin
              active_r_bits_q <= R_BITS;
              active_weight_q <= WEIGHT;
            end
            state_q <= ST_ROW0_FETCH;
          end
        end

        ST_ROW0_FETCH: state_q <= ST_ROW1_FETCH;

        ST_ROW1_FETCH: begin
          parity_q[0] <= syndrome_rdata;
          row1_active_q <= row1_active_c;
          state_q <= ST_ROW_INIT;
        end

        ST_ROW_INIT: begin
          parity_q[1] <= row1_active_q ? syndrome_rdata : 1'b0;
          decision_col_0_q <= decision_col(
              int'(row_q), int'(block_q), support_rdata, active_r_bits_q
          );
          decision_col_1_q <= decision_col(
              int'(row_q) + 1, int'(block_q), support_rdata, active_r_bits_q
          );
          state_q <= ST_DECISION_ISSUE;
        end

        ST_DECISION_ISSUE: state_q <= ST_DECISION_CONSUME;

        ST_DECISION_CONSUME: begin
          if (final_support_c) begin
            residual_weight_q <= residual_weight_q + row_residual_count_c;
            if ((int'(row_q) + 2) >= active_r_bits_q) begin
              o_residual_weight <= residual_weight_q + row_residual_count_c;
              o_residual_zero <= (residual_weight_q + row_residual_count_c) == '0;
              o_done <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              row_q   <= row_q + 2;
              block_q <= '0;
              diag_q  <= '0;
              state_q <= ST_ROW0_FETCH;
            end
          end else begin
            parity_q[0] <= final_parity_0_c;
            parity_q[1] <= final_parity_1_c;
            if (diag_q == DIAG_W'(active_weight_q - 1)) begin
              decision_col_0_q <= decision_col(
                  int'(row_q), int'(block_q) + 1, support_rdata, active_r_bits_q
              );
              decision_col_1_q <= decision_col(
                  int'(row_q) + 1, int'(block_q) + 1, support_rdata, active_r_bits_q
              );
              diag_q <= '0;
              block_q <= block_q + 1'b1;
            end else begin
              decision_col_0_q <= decision_col(
                  int'(row_q), int'(block_q), support_rdata, active_r_bits_q
              );
              decision_col_1_q <= decision_col(
                  int'(row_q) + 1, int'(block_q), support_rdata, active_r_bits_q
              );
              diag_q <= diag_q + 1'b1;
            end
            state_q <= ST_DECISION_ISSUE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if ((R_BITS <= 0) || (BLOCKS <= 0) || (WEIGHT <= 0))
      $fatal(1, "trike_decoder_residual_check requires positive geometry");
  end
`endif

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS))
        $fatal(1, "trike_decoder_residual_check runtime r out of range");
      if ((i_runtime_weight < 1) || (i_runtime_weight > WEIGHT))
        $fatal(1, "trike_decoder_residual_check runtime weight out of range");
    end
  end
`endif

endmodule
