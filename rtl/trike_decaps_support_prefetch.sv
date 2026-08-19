`timescale 1ns / 1ps

// Reads the three block-major support lists from one synchronous RAM port.
// The first block is delivered atomically to both the syndrome H0 loader and
// the complete-H sorter; the remaining blocks feed only the sorter. Runtime
// weight is a public transaction descriptor sampled with i_start.
module trike_decaps_support_prefetch #(
    parameter int BLOCKS            = 3,
    parameter int MAX_SECRET_WEIGHT = bike_pkg::P_W_VALS                [3],
    parameter int SUPPORT_ADDR_W    = $clog2(BLOCKS * MAX_SECRET_WEIGHT),
    parameter int INDEX_W           = $clog2(bike_pkg::P_R_VALS            [3])
) (
    input  logic                      i_clk,
    input  logic                      i_rst_n,
    input  logic                      i_start,
    input  logic [              31:0] i_secret_weight,
    output logic                      o_support_re,
    output logic [SUPPORT_ADDR_W-1:0] o_support_raddr,
    input  logic [       INDEX_W-1:0] i_support_rdata,
    output logic                      o_h_valid,
    output logic [       INDEX_W-1:0] o_h_index,
    input  logic                      i_h_ready,
    output logic                      o_h0_valid,
    output logic [       INDEX_W-1:0] o_h0_index,
    input  logic                      i_h0_ready,
    output logic                      o_busy,
    output logic                      o_done
);

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_FETCH,
    ST_DATA
  } state_t;

  state_t state_q;
  integer active_weight_q;
  integer active_total_q;
  integer item_count_q;
  logic   first_block_c;
  logic   accept_c;

  always_comb begin
    first_block_c = item_count_q < active_weight_q;
    o_support_re = state_q == ST_FETCH;
    o_support_raddr = SUPPORT_ADDR_W'(item_count_q);
    o_h_valid = (state_q == ST_DATA) && (!first_block_c || i_h0_ready);
    o_h_index = i_support_rdata;
    o_h0_valid = (state_q == ST_DATA) && first_block_c && i_h_ready;
    o_h0_index = i_support_rdata;
    accept_c = (state_q == ST_DATA) && i_h_ready && (!first_block_c || i_h0_ready);
    o_busy = state_q != ST_IDLE;
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      active_weight_q <= MAX_SECRET_WEIGHT;
      active_total_q <= BLOCKS * MAX_SECRET_WEIGHT;
      item_count_q <= 0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;
      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            active_weight_q <= int'(i_secret_weight);
            active_total_q <= BLOCKS * int'(i_secret_weight);
            item_count_q <= 0;
            state_q <= ST_FETCH;
          end
        end

        ST_FETCH: state_q <= ST_DATA;

        ST_DATA: begin
          if (accept_c) begin
            if (item_count_q == (active_total_q - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              item_count_q <= item_count_q + 1;
              state_q <= ST_FETCH;
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
        $fatal(1, "trike_decaps_support_prefetch weight out of range");
    end
  end
`endif

endmodule
