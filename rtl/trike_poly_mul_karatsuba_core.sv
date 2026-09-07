`timescale 1ns / 1ps

// Fixed-schedule one-level Karatsuba dense multiplier in
// GF(2)[x]/(x^R_BITS - 1). Operands are split into banked low/high halves.
// One Comba datapath sequentially computes Z0, Z2, and Z1. Each shifted
// subproduct word is cyclically folded into an independent WORDS-word result
// RAM. Operand banks remain intact until the entire result is available.
// Fold addresses and optional second-word RMW depend only on public geometry.
module trike_poly_mul_karatsuba_core #(
    parameter int R_BITS               = 15581,
    parameter int WORD_W               = 64,
    parameter int BASE_KARATSUBA_DEPTH = 1
) (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_start,
    input  logic              i_a_valid,
    input  logic [WORD_W-1:0] i_a_data,
    output logic              o_a_ready,
    input  logic              i_b_valid,
    input  logic [WORD_W-1:0] i_b_data,
    output logic              o_b_ready,
    output logic              o_result_valid,
    output logic [WORD_W-1:0] o_result_data,
    output logic              o_result_last,
    input  logic              i_result_ready,
    output logic              o_busy,
    output logic              o_done
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int HALF_WORDS = (WORDS + 1) / 2;
  localparam int SUBPRODUCT_WORDS = 2 * HALF_WORDS;
  localparam int LAST_BITS = R_BITS - ((WORDS - 1) * WORD_W);
  localparam bit ODD_WORDS = (WORDS % 2) != 0;
  localparam int HALF_ADDR_W = (HALF_WORDS > 1) ? $clog2(HALF_WORDS) : 1;
  localparam int RESULT_ADDR_W = (WORDS > 1) ? $clog2(WORDS) : 1;
  localparam logic [WORD_W-1:0] LAST_MASK = {WORD_W{1'b1}} >> (WORD_W - LAST_BITS);

  typedef enum logic [4:0] {
    ST_IDLE,
    ST_LOAD_A,
    ST_PAD_A,
    ST_LOAD_B,
    ST_PAD_B,
    ST_CLEAR_RESULT,
    ST_SUB_PREFETCH,
    ST_SUB_ACCUM,
    ST_MIX_READ_0,
    ST_MIX_WRITE_0,
    ST_MIX_READ_1,
    ST_MIX_WRITE_1,
    ST_SUB_ADVANCE,
    ST_OUTPUT_FETCH,
    ST_OUTPUT_VALID
  } state_t;

  state_t                     state_q;

  integer                     word_idx_q;
  integer                     clear_idx_q;
  integer                     phase_q;
  integer                     diagonal_idx_q;
  integer                     a_word_idx_q;
  integer                     b_word_idx_q;
  integer                     sub_word_idx_q;
  integer                     output_idx_q;

  logic                       sub_is_carry_q;
  logic                       mix_term_q;
  logic   [       WORD_W-1:0] diagonal_low_q;
  logic   [       WORD_W-1:0] diagonal_high_q;
  logic   [       WORD_W-1:0] carry_word_q;
  logic   [       WORD_W-1:0] sub_word_q;

  logic                       a0_we;
  logic   [  HALF_ADDR_W-1:0] a0_waddr;
  logic   [       WORD_W-1:0] a0_wdata;
  logic                       a0_re;
  logic   [  HALF_ADDR_W-1:0] a0_raddr;
  logic   [       WORD_W-1:0] a0_rdata;
  logic                       a1_we;
  logic   [  HALF_ADDR_W-1:0] a1_waddr;
  logic   [       WORD_W-1:0] a1_wdata;
  logic                       a1_re;
  logic   [  HALF_ADDR_W-1:0] a1_raddr;
  logic   [       WORD_W-1:0] a1_rdata;
  logic                       b0_we;
  logic   [  HALF_ADDR_W-1:0] b0_waddr;
  logic   [       WORD_W-1:0] b0_wdata;
  logic                       b0_re;
  logic   [  HALF_ADDR_W-1:0] b0_raddr;
  logic   [       WORD_W-1:0] b0_rdata;
  logic                       b1_we;
  logic   [  HALF_ADDR_W-1:0] b1_waddr;
  logic   [       WORD_W-1:0] b1_wdata;
  logic                       b1_re;
  logic   [  HALF_ADDR_W-1:0] b1_raddr;
  logic   [       WORD_W-1:0] b1_rdata;

  logic                       result_we;
  logic   [RESULT_ADDR_W-1:0] result_waddr;
  logic   [       WORD_W-1:0] result_wdata;
  logic                       result_re;
  logic   [RESULT_ADDR_W-1:0] result_raddr;
  logic   [       WORD_W-1:0] result_rdata;

  logic   [       WORD_W-1:0] base_a_c;
  logic   [       WORD_W-1:0] base_b_c;
  logic   [   (2*WORD_W)-1:0] base_product_c;
  integer                     mix_word_idx_c;
  logic   [RESULT_ADDR_W-1:0] fold_addr0_c;
  logic   [RESULT_ADDR_W-1:0] fold_addr1_c;
  logic   [       WORD_W-1:0] fold_data0_c;
  logic   [       WORD_W-1:0] fold_data1_c;
  logic                       fold_second_c;
  logic                       pair_end_c;

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (HALF_WORDS)
  ) u_a0_mem (
      .i_clk  (i_clk),
      .i_we   (a0_we),
      .i_waddr(a0_waddr),
      .i_wdata(a0_wdata),
      .i_re   (a0_re),
      .i_raddr(a0_raddr),
      .o_rdata(a0_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (HALF_WORDS)
  ) u_a1_mem (
      .i_clk  (i_clk),
      .i_we   (a1_we),
      .i_waddr(a1_waddr),
      .i_wdata(a1_wdata),
      .i_re   (a1_re),
      .i_raddr(a1_raddr),
      .o_rdata(a1_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (HALF_WORDS)
  ) u_b0_mem (
      .i_clk  (i_clk),
      .i_we   (b0_we),
      .i_waddr(b0_waddr),
      .i_wdata(b0_wdata),
      .i_re   (b0_re),
      .i_raddr(b0_raddr),
      .o_rdata(b0_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (HALF_WORDS)
  ) u_b1_mem (
      .i_clk  (i_clk),
      .i_we   (b1_we),
      .i_waddr(b1_waddr),
      .i_wdata(b1_wdata),
      .i_re   (b1_re),
      .i_raddr(b1_raddr),
      .o_rdata(b1_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_result_mem (
      .i_clk  (i_clk),
      .i_we   (result_we),
      .i_waddr(result_waddr),
      .i_wdata(result_wdata),
      .i_re   (result_re),
      .i_raddr(result_raddr),
      .o_rdata(result_rdata)
  );

  trike_clmul_karatsuba #(
      .WIDTH (WORD_W),
      .LEVELS(BASE_KARATSUBA_DEPTH)
  ) u_base_multiplier (
      .i_a      (base_a_c),
      .i_b      (base_b_c),
      .o_product(base_product_c)
  );

  always_comb begin
    unique case (phase_q)
      0: begin
        base_a_c = a0_rdata;
        base_b_c = b0_rdata;
      end
      1: begin
        base_a_c = a1_rdata;
        base_b_c = b1_rdata;
      end
      default: begin
        base_a_c = a0_rdata ^ a1_rdata;
        base_b_c = b0_rdata ^ b1_rdata;
      end
    endcase

    pair_end_c = (b_word_idx_q == 0) || (a_word_idx_q == (HALF_WORDS - 1));

    mix_word_idx_c = sub_word_idx_q;
    if (mix_term_q || (phase_q == 2)) begin
      mix_word_idx_c = sub_word_idx_q + HALF_WORDS;
    end else if (phase_q == 1) begin
      mix_word_idx_c = sub_word_idx_q + (2 * HALF_WORDS);
    end

    // Reduction and recombination are linear over GF(2). Recombination terms
    // above degree 2*R_BITS-1 cancel in the complete product, so truncate them
    // consistently instead of wrapping padded intermediate terms a second time.
    // Every retained word produces at most two masked result contributions.
    fold_addr0_c  = '0;
    fold_addr1_c  = '0;
    fold_data0_c  = '0;
    fold_data1_c  = '0;
    fold_second_c = 1'b0;
    if (mix_word_idx_c < WORDS) begin
      fold_addr0_c = RESULT_ADDR_W'(mix_word_idx_c);
      fold_data0_c = sub_word_q;
      if ((LAST_BITS != WORD_W) && (mix_word_idx_c == (WORDS - 1))) begin
        fold_second_c = 1'b1;
        fold_data1_c  = sub_word_q >> LAST_BITS;
      end
    end else begin
      if ((mix_word_idx_c - WORDS) < WORDS) begin
        fold_addr0_c = RESULT_ADDR_W'(mix_word_idx_c - WORDS);
        fold_data0_c = sub_word_q << (WORD_W - LAST_BITS);
      end
      if ((LAST_BITS != WORD_W) && ((mix_word_idx_c - WORDS + 1) < WORDS)) begin
        fold_second_c = 1'b1;
        fold_addr1_c  = RESULT_ADDR_W'(mix_word_idx_c - WORDS + 1);
        fold_data1_c  = sub_word_q >> LAST_BITS;
      end
    end
    if (fold_addr0_c == RESULT_ADDR_W'(WORDS - 1)) fold_data0_c &= LAST_MASK;
    if (fold_addr1_c == RESULT_ADDR_W'(WORDS - 1)) fold_data1_c &= LAST_MASK;
  end

  always_comb begin
    a0_we = 1'b0;
    a0_waddr = '0;
    a0_wdata = '0;
    a0_re = 1'b0;
    a0_raddr = '0;
    a1_we = 1'b0;
    a1_waddr = '0;
    a1_wdata = '0;
    a1_re = 1'b0;
    a1_raddr = '0;
    b0_we = 1'b0;
    b0_waddr = '0;
    b0_wdata = '0;
    b0_re = 1'b0;
    b0_raddr = '0;
    b1_we = 1'b0;
    b1_waddr = '0;
    b1_wdata = '0;
    b1_re = 1'b0;
    b1_raddr = '0;
    result_we = 1'b0;
    result_waddr = '0;
    result_wdata = '0;
    result_re = 1'b0;
    result_raddr = '0;

    unique case (state_q)
      ST_LOAD_A: begin
        if (i_a_valid) begin
          if (word_idx_q < HALF_WORDS) begin
            a0_we = 1'b1;
            a0_waddr = HALF_ADDR_W'(word_idx_q);
            a0_wdata = (word_idx_q == (WORDS - 1)) ? (i_a_data & LAST_MASK) : i_a_data;
          end else begin
            a1_we = 1'b1;
            a1_waddr = HALF_ADDR_W'(word_idx_q - HALF_WORDS);
            a1_wdata = (word_idx_q == (WORDS - 1)) ? (i_a_data & LAST_MASK) : i_a_data;
          end
        end
      end

      ST_PAD_A: begin
        a1_we = 1'b1;
        a1_waddr = HALF_ADDR_W'(HALF_WORDS - 1);
      end

      ST_LOAD_B: begin
        if (i_b_valid) begin
          if (word_idx_q < HALF_WORDS) begin
            b0_we = 1'b1;
            b0_waddr = HALF_ADDR_W'(word_idx_q);
            b0_wdata = (word_idx_q == (WORDS - 1)) ? (i_b_data & LAST_MASK) : i_b_data;
          end else begin
            b1_we = 1'b1;
            b1_waddr = HALF_ADDR_W'(word_idx_q - HALF_WORDS);
            b1_wdata = (word_idx_q == (WORDS - 1)) ? (i_b_data & LAST_MASK) : i_b_data;
          end
        end
      end

      ST_PAD_B: begin
        b1_we = 1'b1;
        b1_waddr = HALF_ADDR_W'(HALF_WORDS - 1);
      end

      ST_CLEAR_RESULT: begin
        result_we = 1'b1;
        result_waddr = RESULT_ADDR_W'(clear_idx_q);
      end

      ST_SUB_PREFETCH: begin
        a0_re = 1'b1;
        a0_raddr = HALF_ADDR_W'(a_word_idx_q);
        a1_re = 1'b1;
        a1_raddr = HALF_ADDR_W'(a_word_idx_q);
        b0_re = 1'b1;
        b0_raddr = HALF_ADDR_W'(b_word_idx_q);
        b1_re = 1'b1;
        b1_raddr = HALF_ADDR_W'(b_word_idx_q);
      end

      ST_SUB_ACCUM: begin
        if (!pair_end_c) begin
          a0_re = 1'b1;
          a0_raddr = HALF_ADDR_W'(a_word_idx_q + 1);
          a1_re = 1'b1;
          a1_raddr = HALF_ADDR_W'(a_word_idx_q + 1);
          b0_re = 1'b1;
          b0_raddr = HALF_ADDR_W'(b_word_idx_q - 1);
          b1_re = 1'b1;
          b1_raddr = HALF_ADDR_W'(b_word_idx_q - 1);
        end
      end

      ST_MIX_READ_0: begin
        result_re = 1'b1;
        result_raddr = fold_addr0_c;
      end

      ST_MIX_WRITE_0: begin
        result_we = 1'b1;
        result_waddr = fold_addr0_c;
        result_wdata = result_rdata ^ fold_data0_c;
      end

      ST_MIX_READ_1: begin
        result_re = 1'b1;
        result_raddr = fold_addr1_c;
      end

      ST_MIX_WRITE_1: begin
        result_we = 1'b1;
        result_waddr = fold_addr1_c;
        result_wdata = result_rdata ^ fold_data1_c;
      end

      ST_OUTPUT_FETCH: begin
        result_re = 1'b1;
        result_raddr = RESULT_ADDR_W'(output_idx_q);
      end

      default: begin
      end
    endcase
  end

  assign o_a_ready = (state_q == ST_LOAD_A);
  assign o_b_ready = (state_q == ST_LOAD_B);
  assign o_result_valid = (state_q == ST_OUTPUT_VALID);
  assign o_result_data = result_rdata;
  assign o_result_last = (output_idx_q == (WORDS - 1));
  assign o_busy = (state_q != ST_IDLE);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      word_idx_q <= 0;
      clear_idx_q <= 0;
      phase_q <= 0;
      diagonal_idx_q <= 0;
      a_word_idx_q <= 0;
      b_word_idx_q <= 0;
      sub_word_idx_q <= 0;
      output_idx_q <= 0;
      sub_is_carry_q <= 1'b0;
      mix_term_q <= 1'b0;
      diagonal_low_q <= '0;
      diagonal_high_q <= '0;
      carry_word_q <= '0;
      sub_word_q <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            word_idx_q <= 0;
            state_q <= ST_LOAD_A;
          end
        end

        ST_LOAD_A: begin
          if (i_a_valid) begin
            if (word_idx_q == (WORDS - 1)) begin
              word_idx_q <= 0;
              state_q <= ODD_WORDS ? ST_PAD_A : ST_LOAD_B;
            end else begin
              word_idx_q <= word_idx_q + 1;
            end
          end
        end

        ST_PAD_A: begin
          state_q <= ST_LOAD_B;
        end

        ST_LOAD_B: begin
          if (i_b_valid) begin
            if (word_idx_q == (WORDS - 1)) begin
              clear_idx_q <= 0;
              state_q <= ODD_WORDS ? ST_PAD_B : ST_CLEAR_RESULT;
            end else begin
              word_idx_q <= word_idx_q + 1;
            end
          end
        end

        ST_PAD_B: begin
          clear_idx_q <= 0;
          state_q <= ST_CLEAR_RESULT;
        end

        ST_CLEAR_RESULT: begin
          if (clear_idx_q == (WORDS - 1)) begin
            phase_q <= 0;
            diagonal_idx_q <= 0;
            a_word_idx_q <= 0;
            b_word_idx_q <= 0;
            diagonal_low_q <= '0;
            diagonal_high_q <= '0;
            state_q <= ST_SUB_PREFETCH;
          end else begin
            clear_idx_q <= clear_idx_q + 1;
          end
        end

        ST_SUB_PREFETCH: begin
          state_q <= ST_SUB_ACCUM;
        end

        ST_SUB_ACCUM: begin
          diagonal_low_q  <= diagonal_low_q ^ base_product_c[WORD_W-1:0];
          diagonal_high_q <= diagonal_high_q ^ base_product_c[(2*WORD_W)-1:WORD_W];
          if (pair_end_c) begin
            sub_word_idx_q <= diagonal_idx_q;
            sub_word_q <= diagonal_low_q ^ base_product_c[WORD_W-1:0];
            carry_word_q <= diagonal_high_q ^ base_product_c[(2*WORD_W)-1:WORD_W];
            sub_is_carry_q <= 1'b0;
            mix_term_q <= 1'b0;
            state_q <= ST_MIX_READ_0;
          end else begin
            a_word_idx_q <= a_word_idx_q + 1;
            b_word_idx_q <= b_word_idx_q - 1;
          end
        end

        ST_MIX_READ_0: begin
          state_q <= ST_MIX_WRITE_0;
        end

        ST_MIX_WRITE_0: begin
          if (fold_second_c) begin
            state_q <= ST_MIX_READ_1;
          end else if ((phase_q != 2) && !mix_term_q) begin
            mix_term_q <= 1'b1;
            state_q <= ST_MIX_READ_0;
          end else begin
            state_q <= ST_SUB_ADVANCE;
          end
        end

        ST_MIX_READ_1: begin
          state_q <= ST_MIX_WRITE_1;
        end

        ST_MIX_WRITE_1: begin
          if ((phase_q != 2) && !mix_term_q) begin
            mix_term_q <= 1'b1;
            state_q <= ST_MIX_READ_0;
          end else begin
            state_q <= ST_SUB_ADVANCE;
          end
        end

        ST_SUB_ADVANCE: begin
          if (!sub_is_carry_q && (diagonal_idx_q == (SUBPRODUCT_WORDS - 2))) begin
            sub_word_idx_q <= SUBPRODUCT_WORDS - 1;
            sub_word_q <= carry_word_q;
            sub_is_carry_q <= 1'b1;
            mix_term_q <= 1'b0;
            state_q <= ST_MIX_READ_0;
          end else if (sub_is_carry_q) begin
            if (phase_q == 2) begin
              output_idx_q <= 0;
              state_q <= ST_OUTPUT_FETCH;
            end else begin
              phase_q <= phase_q + 1;
              diagonal_idx_q <= 0;
              a_word_idx_q <= 0;
              b_word_idx_q <= 0;
              diagonal_low_q <= '0;
              diagonal_high_q <= '0;
              state_q <= ST_SUB_PREFETCH;
            end
          end else begin
            diagonal_idx_q  <= diagonal_idx_q + 1;
            diagonal_low_q  <= carry_word_q;
            diagonal_high_q <= '0;
            if ((diagonal_idx_q + 1) < HALF_WORDS) begin
              a_word_idx_q <= 0;
              b_word_idx_q <= diagonal_idx_q + 1;
            end else begin
              a_word_idx_q <= (diagonal_idx_q + 1) - (HALF_WORDS - 1);
              b_word_idx_q <= HALF_WORDS - 1;
            end
            state_q <= ST_SUB_PREFETCH;
          end
        end

        ST_OUTPUT_FETCH: begin
          state_q <= ST_OUTPUT_VALID;
        end

        ST_OUTPUT_VALID: begin
          if (i_result_ready) begin
            if (output_idx_q == (WORDS - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              output_idx_q <= output_idx_q + 1;
              state_q <= ST_OUTPUT_FETCH;
            end
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
    if (R_BITS < 2) $error("trike_poly_mul_karatsuba_core R_BITS must be at least 2");
    if (WORD_W < 2) $error("trike_poly_mul_karatsuba_core WORD_W must be at least 2");
    if ((WORD_W % (1 << BASE_KARATSUBA_DEPTH)) != 0) begin
      $error("trike_poly_mul_karatsuba_core invalid base recursion depth");
    end
  end
`endif

endmodule
