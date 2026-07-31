`timescale 1ns / 1ps

// Fixed-schedule multiplication in GF(2)[x]/(x^R_BITS - 1).
//
// Operands are stored little-endian by coefficient: bit zero is x^0. Dense
// mode accepts WORDS words for operand A. Sparse mode accepts SPARSE_WEIGHT
// coefficient indices and expands them into the same A storage. Both modes
// use one digit-serial carryless multiplier and the same product/reduction RAM.
//
// With continuous input and output, busy cycles are:
//   dense:  6*WORDS + 2*WORDS*WORDS*(WORD_W/DIGIT_W)
//   sparse: dense + SPARSE_WEIGHT
module trike_poly_mul_core #(
    parameter int R_BITS        = 15581,
    parameter int WORD_W        = 64,
    parameter int DIGIT_W       = 8,
    parameter int SPARSE_WEIGHT = 263
) (
    input  logic                                           i_clk,
    input  logic                                           i_rst_n,
    input  logic                                           i_start,
    input  logic                                           i_sparse_a,
    input  logic                                           i_a_valid,
    input  logic [                             WORD_W-1:0] i_a_data,
    output logic                                           o_a_ready,
    input  logic                                           i_sparse_index_valid,
    input  logic [((R_BITS > 1) ? $clog2(R_BITS) : 1)-1:0] i_sparse_index,
    output logic                                           o_sparse_index_ready,
    input  logic                                           i_b_valid,
    input  logic [                             WORD_W-1:0] i_b_data,
    output logic                                           o_b_ready,
    output logic                                           o_result_valid,
    output logic [                             WORD_W-1:0] o_result_data,
    output logic                                           o_result_last,
    input  logic                                           i_result_ready,
    output logic                                           o_busy,
    output logic                                           o_done
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int PRODUCT_WORDS = 2 * WORDS;
  localparam int DIGITS_PER_WORD = WORD_W / DIGIT_W;
  localparam int LAST_BITS = R_BITS - ((WORDS - 1) * WORD_W);
  localparam logic [WORD_W-1:0] LAST_MASK = {WORD_W{1'b1}} >> (WORD_W - LAST_BITS);

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_CLEAR_A,
    ST_LOAD_A,
    ST_LOAD_SPARSE,
    ST_LOAD_B,
    ST_CLEAR_PRODUCT,
    ST_MUL_LOW,
    ST_MUL_HIGH,
    ST_REDUCE,
    ST_OUTPUT
  } state_t;

  state_t                  state_q;

  (* ram_style = "block" *) logic   [    WORD_W-1:0] a_mem[        0:WORDS-1];
  (* ram_style = "block" *) logic   [    WORD_W-1:0] b_mem[        0:WORDS-1];
  (* ram_style = "block" *) logic   [    WORD_W-1:0] product_mem[0:PRODUCT_WORDS-1];
  (* ram_style = "block" *) logic   [    WORD_W-1:0] result_mem[        0:WORDS-1];

  integer                  word_idx_q;
  integer                  sparse_idx_q;
  integer                  a_word_idx_q;
  integer                  b_word_idx_q;
  integer                  digit_idx_q;
  integer                  product_idx_q;
  integer                  output_idx_q;

  logic   [    WORD_W-1:0] a_word_c;
  logic   [    WORD_W-1:0] b_word_c;
  logic   [   DIGIT_W-1:0] a_digit_c;
  logic   [(2*WORD_W)-1:0] partial_base_c;
  logic   [(2*WORD_W)-1:0] partial_shifted_c;
  logic   [    WORD_W-1:0] reduced_word_c;

  always_comb begin
    a_word_c = a_mem[a_word_idx_q];
    b_word_c = b_mem[b_word_idx_q];
    if (a_word_idx_q == (WORDS - 1)) a_word_c = a_word_c & LAST_MASK;
    if (b_word_idx_q == (WORDS - 1)) b_word_c = b_word_c & LAST_MASK;

    a_digit_c = a_word_c[(digit_idx_q*DIGIT_W)+:DIGIT_W];
    partial_base_c = '0;
    for (int bit_idx = 0; bit_idx < DIGIT_W; bit_idx++) begin
      if (a_digit_c[bit_idx]) begin
        partial_base_c = partial_base_c ^ ({{WORD_W{1'b0}}, b_word_c} << bit_idx);
      end
    end
    partial_shifted_c = partial_base_c << (digit_idx_q * DIGIT_W);

    if (LAST_BITS == WORD_W) begin
      reduced_word_c = product_mem[product_idx_q] ^ product_mem[product_idx_q+WORDS];
    end else begin
      reduced_word_c =
          product_mem[product_idx_q] ^
          (product_mem[product_idx_q+WORDS-1] >> LAST_BITS) ^
          (product_mem[product_idx_q+WORDS] << (WORD_W - LAST_BITS));
    end
    if (product_idx_q == (WORDS - 1)) reduced_word_c = reduced_word_c & LAST_MASK;
  end

  assign o_a_ready = (state_q == ST_LOAD_A);
  assign o_sparse_index_ready = (state_q == ST_LOAD_SPARSE);
  assign o_b_ready = (state_q == ST_LOAD_B);
  assign o_result_valid = (state_q == ST_OUTPUT);
  assign o_result_data = result_mem[output_idx_q];
  assign o_result_last = (output_idx_q == (WORDS - 1));
  assign o_busy = (state_q != ST_IDLE);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q       <= ST_IDLE;
      word_idx_q    <= 0;
      sparse_idx_q  <= 0;
      a_word_idx_q  <= 0;
      b_word_idx_q  <= 0;
      digit_idx_q   <= 0;
      product_idx_q <= 0;
      output_idx_q  <= 0;
      o_done        <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            word_idx_q <= 0;
            if (i_sparse_a) begin
              state_q <= ST_CLEAR_A;
            end else begin
              state_q <= ST_LOAD_A;
            end
          end
        end

        ST_CLEAR_A: begin
          a_mem[word_idx_q] <= '0;
          if (word_idx_q == (WORDS - 1)) begin
            sparse_idx_q <= 0;
            state_q      <= ST_LOAD_SPARSE;
          end else begin
            word_idx_q <= word_idx_q + 1;
          end
        end

        ST_LOAD_A: begin
          if (i_a_valid) begin
            if (word_idx_q == (WORDS - 1)) begin
              a_mem[word_idx_q] <= i_a_data & LAST_MASK;
              word_idx_q        <= 0;
              state_q           <= ST_LOAD_B;
            end else begin
              a_mem[word_idx_q] <= i_a_data;
              word_idx_q        <= word_idx_q + 1;
            end
          end
        end

        ST_LOAD_SPARSE: begin
          if (i_sparse_index_valid) begin
            if (int'(i_sparse_index) < R_BITS) begin
              a_mem[int'(i_sparse_index)/WORD_W][int'(i_sparse_index)%WORD_W] <= 1'b1;
            end
            if (sparse_idx_q == (SPARSE_WEIGHT - 1)) begin
              word_idx_q <= 0;
              state_q    <= ST_LOAD_B;
            end else begin
              sparse_idx_q <= sparse_idx_q + 1;
            end
          end
        end

        ST_LOAD_B: begin
          if (i_b_valid) begin
            if (word_idx_q == (WORDS - 1)) begin
              b_mem[word_idx_q] <= i_b_data & LAST_MASK;
              word_idx_q        <= 0;
              state_q           <= ST_CLEAR_PRODUCT;
            end else begin
              b_mem[word_idx_q] <= i_b_data;
              word_idx_q        <= word_idx_q + 1;
            end
          end
        end

        ST_CLEAR_PRODUCT: begin
          product_mem[word_idx_q] <= '0;
          if (word_idx_q == (PRODUCT_WORDS - 1)) begin
            a_word_idx_q <= 0;
            b_word_idx_q <= 0;
            digit_idx_q  <= 0;
            state_q      <= ST_MUL_LOW;
          end else begin
            word_idx_q <= word_idx_q + 1;
          end
        end

        ST_MUL_LOW: begin
          product_mem[a_word_idx_q+b_word_idx_q] <=
              product_mem[a_word_idx_q+b_word_idx_q] ^ partial_shifted_c[WORD_W-1:0];
          state_q <= ST_MUL_HIGH;
        end

        ST_MUL_HIGH: begin
          product_mem[a_word_idx_q+b_word_idx_q+1] <=
              product_mem[a_word_idx_q+b_word_idx_q+1] ^
              partial_shifted_c[(2*WORD_W)-1:WORD_W];

          if (digit_idx_q == (DIGITS_PER_WORD - 1)) begin
            digit_idx_q <= 0;
            if (b_word_idx_q == (WORDS - 1)) begin
              b_word_idx_q <= 0;
              if (a_word_idx_q == (WORDS - 1)) begin
                product_idx_q <= 0;
                state_q       <= ST_REDUCE;
              end else begin
                a_word_idx_q <= a_word_idx_q + 1;
                state_q      <= ST_MUL_LOW;
              end
            end else begin
              b_word_idx_q <= b_word_idx_q + 1;
              state_q      <= ST_MUL_LOW;
            end
          end else begin
            digit_idx_q <= digit_idx_q + 1;
            state_q     <= ST_MUL_LOW;
          end
        end

        ST_REDUCE: begin
          result_mem[product_idx_q] <= reduced_word_c;
          if (product_idx_q == (WORDS - 1)) begin
            output_idx_q <= 0;
            state_q      <= ST_OUTPUT;
          end else begin
            product_idx_q <= product_idx_q + 1;
          end
        end

        ST_OUTPUT: begin
          if (i_result_ready) begin
            if (output_idx_q == (WORDS - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              output_idx_q <= output_idx_q + 1;
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
    if (R_BITS < 1) $error("trike_poly_mul_core R_BITS must be at least 1");
    if (WORD_W < 2) $error("trike_poly_mul_core WORD_W must be at least 2");
    if (DIGIT_W < 1) $error("trike_poly_mul_core DIGIT_W must be at least 1");
    if ((WORD_W % DIGIT_W) != 0) begin
      $error("trike_poly_mul_core WORD_W must be divisible by DIGIT_W");
    end
    if (SPARSE_WEIGHT < 1) begin
      $error("trike_poly_mul_core SPARSE_WEIGHT must be at least 1");
    end
    if (SPARSE_WEIGHT > R_BITS) begin
      $error("trike_poly_mul_core SPARSE_WEIGHT must not exceed R_BITS");
    end
  end
`endif

endmodule
