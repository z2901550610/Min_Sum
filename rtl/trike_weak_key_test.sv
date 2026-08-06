`timescale 1ns / 1ps

// Fixed-schedule TRIKE weak-key test.
//
// Three self-distance tests and three cross-distance tests reuse one distance
// histogram RAM. For each test, the score is
//   sum_d count[d] * (count[d] - 1) / 2,
// which is equivalent to the cnt[] accumulation in the Reference C. Every
// clear, pair update, and score scan count depends only on R_BITS and WEIGHT.
module trike_weak_key_test #(
    parameter int R_BITS          = 15581,
    parameter int WEIGHT          = 35,
    parameter int SELF_THRESHOLD  = 46,
    parameter int CROSS_THRESHOLD = 83
) (
    input  logic                                           i_clk,
    input  logic                                           i_rst_n,
    input  logic                                           i_support_valid,
    input  logic [                                    1:0] i_support_block,
    input  logic [((WEIGHT > 1) ? $clog2(WEIGHT) : 1)-1:0] i_support_position,
    input  logic [((R_BITS > 1) ? $clog2(R_BITS) : 1)-1:0] i_support_index,
    output logic                                           o_support_ready,
    input  logic                                           i_start,
    output logic                                           o_busy,
    output logic                                           o_done,
    output logic                                           o_weak,
    output logic [                                  191:0] o_scores
);

  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int POSITION_W = (WEIGHT > 1) ? $clog2(WEIGHT) : 1;
  localparam int HALF_R = (R_BITS + 1) / 2;
  localparam logic [INDEX_W-1:0] LAST_CLEAR_ADDR = INDEX_W'(R_BITS - 1);
  localparam logic [INDEX_W-1:0] LAST_SELF_SCAN_ADDR = INDEX_W'(HALF_R - 1);

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_CLEAR,
    ST_PAIR_READ,
    ST_PAIR_WRITE,
    ST_SCORE_READ,
    ST_SCORE_ACCUM
  } state_t;

  state_t                  state_q;

  logic   [   INDEX_W-1:0] support_q[0:2][0:WEIGHT-1];
  logic   [           2:0] test_q;
  logic   [POSITION_W-1:0] pair_i_q;
  logic   [POSITION_W-1:0] pair_j_q;
  logic   [   INDEX_W-1:0] clear_addr_q;
  logic   [   INDEX_W-1:0] pair_addr_q;
  logic   [   INDEX_W-1:0] score_addr_q;
  logic   [          31:0] score_q;
  logic                    weak_q;

  logic                    dist_we;
  logic   [   INDEX_W-1:0] dist_waddr;
  logic   [           7:0] dist_wdata;
  logic                    dist_re;
  logic   [   INDEX_W-1:0] dist_raddr;
  logic   [           7:0] dist_rdata;

  logic                    self_test_c;
  logic   [           1:0] left_block_c;
  logic   [           1:0] right_block_c;
  logic   [   INDEX_W-1:0] left_index_c;
  logic   [   INDEX_W-1:0] right_index_c;
  logic   [     INDEX_W:0] difference_wide_c;
  logic   [   INDEX_W-1:0] difference_mod_c;
  logic   [   INDEX_W-1:0] pair_address_c;
  logic   [   INDEX_W-1:0] last_score_addr_c;
  logic   [          15:0] pair_count_c;
  logic   [          31:0] score_add_c;
  logic   [          31:0] final_score_c;
  logic   [          31:0] threshold_c;
  logic                    final_weak_c;

  ram_bram #(
      .DATA_W(8),
      .DEPTH (R_BITS)
  ) u_distance_mem (
      .i_clk  (i_clk),
      .i_we   (dist_we),
      .i_waddr(dist_waddr),
      .i_wdata(dist_wdata),
      .i_re   (dist_re),
      .i_raddr(dist_raddr),
      .o_rdata(dist_rdata)
  );

  assign o_support_ready = state_q == ST_IDLE;
  assign o_busy = state_q != ST_IDLE;

  always_comb begin
    self_test_c   = test_q < 3;
    left_block_c  = '0;
    right_block_c = '0;
    unique case (test_q)
      3'd0: begin
        left_block_c  = 2'd0;
        right_block_c = 2'd0;
      end
      3'd1: begin
        left_block_c  = 2'd1;
        right_block_c = 2'd1;
      end
      3'd2: begin
        left_block_c  = 2'd2;
        right_block_c = 2'd2;
      end
      3'd3: begin
        left_block_c  = 2'd0;
        right_block_c = 2'd1;
      end
      3'd4: begin
        left_block_c  = 2'd1;
        right_block_c = 2'd2;
      end
      default: begin
        left_block_c  = 2'd2;
        right_block_c = 2'd0;
      end
    endcase

    left_index_c = support_q[left_block_c][pair_i_q];
    right_index_c = support_q[right_block_c][pair_j_q];
    difference_wide_c = {1'b0, right_index_c} + (INDEX_W + 1)'(R_BITS) - {1'b0, left_index_c};
    if (difference_wide_c >= (INDEX_W + 1)'(R_BITS)) begin
      difference_mod_c = INDEX_W'(difference_wide_c - R_BITS);
    end else begin
      difference_mod_c = difference_wide_c[INDEX_W-1:0];
    end
    if (self_test_c && (difference_mod_c >= INDEX_W'(HALF_R))) begin
      pair_address_c = INDEX_W'(R_BITS - difference_mod_c);
    end else begin
      pair_address_c = difference_mod_c;
    end

    last_score_addr_c = self_test_c ? LAST_SELF_SCAN_ADDR : LAST_CLEAR_ADDR;
    pair_count_c = {8'b0, dist_rdata} * ({8'b0, dist_rdata} - 1'b1);
    score_add_c = (dist_rdata < 2) ? 32'd0 : 32'(pair_count_c >> 1);
    final_score_c = score_q + score_add_c;
    threshold_c = self_test_c ? SELF_THRESHOLD : CROSS_THRESHOLD;
    final_weak_c = final_score_c > threshold_c;
  end

  always_comb begin
    dist_we = 1'b0;
    dist_waddr = '0;
    dist_wdata = '0;
    dist_re = 1'b0;
    dist_raddr = '0;

    unique case (state_q)
      ST_CLEAR: begin
        dist_we = 1'b1;
        dist_waddr = clear_addr_q;
      end
      ST_PAIR_READ: begin
        dist_re = 1'b1;
        dist_raddr = pair_address_c;
      end
      ST_PAIR_WRITE: begin
        dist_we = 1'b1;
        dist_waddr = pair_addr_q;
        dist_wdata = dist_rdata + 1'b1;
      end
      ST_SCORE_READ: begin
        dist_re = 1'b1;
        dist_raddr = score_addr_q;
      end
      default: begin
      end
    endcase
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      test_q <= '0;
      pair_i_q <= '0;
      pair_j_q <= '0;
      clear_addr_q <= '0;
      pair_addr_q <= '0;
      score_addr_q <= '0;
      score_q <= '0;
      weak_q <= 1'b0;
      o_done <= 1'b0;
      o_weak <= 1'b0;
      o_scores <= '0;
    end else begin
      o_done <= 1'b0;
      if (i_support_valid && o_support_ready) begin
        support_q[i_support_block][i_support_position] <= i_support_index;
      end

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            test_q <= '0;
            clear_addr_q <= '0;
            weak_q <= 1'b0;
            o_weak <= 1'b0;
            score_q <= '0;
            o_scores <= '0;
            state_q <= ST_CLEAR;
          end
        end

        ST_CLEAR: begin
          if (clear_addr_q == LAST_CLEAR_ADDR) begin
            pair_i_q <= self_test_c ? POSITION_W'(1) : '0;
            pair_j_q <= '0;
            state_q  <= ST_PAIR_READ;
          end else begin
            clear_addr_q <= clear_addr_q + 1'b1;
          end
        end

        ST_PAIR_READ: begin
          pair_addr_q <= pair_address_c;
          state_q <= ST_PAIR_WRITE;
        end

        ST_PAIR_WRITE: begin
          if (self_test_c) begin
            if (pair_j_q == (pair_i_q - 1'b1)) begin
              if (pair_i_q == POSITION_W'(WEIGHT - 1)) begin
                score_addr_q <= '0;
                score_q <= '0;
                state_q <= ST_SCORE_READ;
              end else begin
                pair_i_q <= pair_i_q + 1'b1;
                pair_j_q <= '0;
                state_q  <= ST_PAIR_READ;
              end
            end else begin
              pair_j_q <= pair_j_q + 1'b1;
              state_q  <= ST_PAIR_READ;
            end
          end else begin
            if (pair_j_q == POSITION_W'(WEIGHT - 1)) begin
              if (pair_i_q == POSITION_W'(WEIGHT - 1)) begin
                score_addr_q <= '0;
                score_q <= '0;
                state_q <= ST_SCORE_READ;
              end else begin
                pair_i_q <= pair_i_q + 1'b1;
                pair_j_q <= '0;
                state_q  <= ST_PAIR_READ;
              end
            end else begin
              pair_j_q <= pair_j_q + 1'b1;
              state_q  <= ST_PAIR_READ;
            end
          end
        end

        ST_SCORE_READ: begin
          state_q <= ST_SCORE_ACCUM;
        end

        ST_SCORE_ACCUM: begin
          if (score_addr_q == last_score_addr_c) begin
            o_scores[32*test_q+:32] <= final_score_c;
            weak_q <= weak_q | final_weak_c;
            if (test_q == 3'd5) begin
              o_weak  <= weak_q | final_weak_c;
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              test_q <= test_q + 1'b1;
              clear_addr_q <= '0;
              score_q <= '0;
              state_q <= ST_CLEAR;
            end
          end else begin
            score_q <= final_score_c;
            score_addr_q <= score_addr_q + 1'b1;
            state_q <= ST_SCORE_READ;
          end
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (R_BITS < 3) $error("trike_weak_key_test R_BITS must be at least 3");
    if (WEIGHT < 2) $error("trike_weak_key_test WEIGHT must be at least 2");
    if (WEIGHT > R_BITS) $error("trike_weak_key_test WEIGHT must not exceed R_BITS");
  end
`endif

endmodule
