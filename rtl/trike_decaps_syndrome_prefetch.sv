`timescale 1ns / 1ps

// Fixed-order synchronous-memory reader for the Decaps syndrome operands.
// The public profile bounds are sampled with i_start. Each read uses a
// dedicated request cycle followed by a held valid/data cycle, so downstream
// backpressure cannot repeat a memory access or change the payload.
module trike_decaps_syndrome_prefetch #(
    parameter int WORD_W            = 64,
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
    output logic                      o_h0_valid,
    output logic [       INDEX_W-1:0] o_h0_index,
    input  logic                      i_h0_ready,
    output logic                      o_t0_valid,
    output logic [        WORD_W-1:0] o_t0_data,
    input  logic                      i_t0_ready,
    output logic                      o_u_valid,
    output logic [        WORD_W-1:0] o_u_data,
    input  logic                      i_u_ready,
    output logic                      o_v_valid,
    output logic [        WORD_W-1:0] o_v_data,
    input  logic                      i_v_ready,
    output logic                      o_busy,
    output logic                      o_done
);

  localparam int MAX_WORDS = (MAX_R_BITS + WORD_W - 1) / WORD_W;

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_H0_FETCH,
    ST_H0_DATA,
    ST_T0_FETCH,
    ST_T0_DATA,
    ST_U_FETCH,
    ST_U_DATA,
    ST_V_FETCH,
    ST_V_DATA
  } state_t;

  state_t state_q;
  integer active_secret_weight_q;
  integer active_words_q;
  integer item_count_q;

  always_comb begin
    o_support_re = state_q == ST_H0_FETCH;
    o_support_raddr = SUPPORT_ADDR_W'(item_count_q);
    o_t0_re = state_q == ST_T0_FETCH;
    o_t0_raddr = WORD_ADDR_W'(item_count_q);
    o_u_re = state_q == ST_U_FETCH;
    o_u_raddr = WORD_ADDR_W'(item_count_q);
    o_v_re = state_q == ST_V_FETCH;
    o_v_raddr = WORD_ADDR_W'(item_count_q);

    o_h0_valid = state_q == ST_H0_DATA;
    o_h0_index = i_support_rdata;
    o_t0_valid = state_q == ST_T0_DATA;
    o_t0_data = i_t0_rdata;
    o_u_valid = state_q == ST_U_DATA;
    o_u_data = i_u_rdata;
    o_v_valid = state_q == ST_V_DATA;
    o_v_data = i_v_rdata;
    o_busy = state_q != ST_IDLE;
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      active_secret_weight_q <= MAX_SECRET_WEIGHT;
      active_words_q <= MAX_WORDS;
      item_count_q <= 0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;
      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            active_secret_weight_q <= int'(i_secret_weight);
            active_words_q <= int'(i_words);
            item_count_q <= 0;
            if (EXTERNAL_H0) state_q <= ST_T0_FETCH;
            else state_q <= ST_H0_FETCH;
          end
        end

        ST_H0_FETCH: state_q <= ST_H0_DATA;

        ST_H0_DATA: begin
          if (i_h0_ready) begin
            if (item_count_q == (active_secret_weight_q - 1)) begin
              item_count_q <= 0;
              state_q <= ST_T0_FETCH;
            end else begin
              item_count_q <= item_count_q + 1;
              state_q <= ST_H0_FETCH;
            end
          end
        end

        ST_T0_FETCH: state_q <= ST_T0_DATA;

        ST_T0_DATA: begin
          if (i_t0_ready) begin
            if (item_count_q == (active_words_q - 1)) begin
              item_count_q <= 0;
              state_q <= ST_U_FETCH;
            end else begin
              item_count_q <= item_count_q + 1;
              state_q <= ST_T0_FETCH;
            end
          end
        end

        ST_U_FETCH: state_q <= ST_U_DATA;

        ST_U_DATA: begin
          if (i_u_ready) begin
            if (item_count_q == (active_words_q - 1)) begin
              item_count_q <= 0;
              state_q <= ST_V_FETCH;
            end else begin
              item_count_q <= item_count_q + 1;
              state_q <= ST_U_FETCH;
            end
          end
        end

        ST_V_FETCH: state_q <= ST_V_DATA;

        ST_V_DATA: begin
          if (i_v_ready) begin
            if (item_count_q == (active_words_q - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              item_count_q <= item_count_q + 1;
              state_q <= ST_V_FETCH;
            end
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start) begin
      if ((i_secret_weight < 1) || (i_secret_weight > MAX_SECRET_WEIGHT))
        $fatal(1, "trike_decaps_syndrome_prefetch secret weight out of range");
      if ((i_words < 1) || (i_words > MAX_WORDS))
        $fatal(1, "trike_decaps_syndrome_prefetch word count out of range");
    end
  end
`endif

endmodule
