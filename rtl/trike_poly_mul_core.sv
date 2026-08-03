`timescale 1ns / 1ps

// Fixed-schedule multiplication in GF(2)[x]/(x^R_BITS - 1).
//
// Operands are little-endian by coefficient: bit zero is x^0. Dense mode
// accepts WORDS words for operand A. Sparse mode accepts SPARSE_WEIGHT
// coefficient indices and directly XOR-accumulates cyclic shifts of B. Dense
// mode uses one digit-serial carryless multiplier, a double-length product
// RAM, and a fixed reduction schedule.
//
// With continuous input and output, busy cycles are:
//   dense:  11*WORDS + WORDS*WORDS*(1 + 4*WORD_W/DIGIT_W)
//   sparse: 4*WORDS + 2*SPARSE_WEIGHT + 7*SPARSE_WEIGHT*WORDS
// External dense RAM mode bypasses operand loading and result streaming:
//   external dense: 7*WORDS + WORDS*WORDS*(1 + 4*WORD_W/DIGIT_W)
module trike_poly_mul_core #(
    parameter int R_BITS = 15581,
    parameter int WORD_W = 64,
    parameter int DIGIT_W = 8,
    parameter int SPARSE_WEIGHT = 263,
    parameter bit USE_EXTERNAL_DENSE_RAM = 1'b0,
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
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
    output logic                                           o_ext_a_re,
    output logic [                        WORD_ADDR_W-1:0] o_ext_a_raddr,
    input  logic [                             WORD_W-1:0] i_ext_a_rdata,
    output logic                                           o_ext_b_re,
    output logic [                        WORD_ADDR_W-1:0] o_ext_b_raddr,
    input  logic [                             WORD_W-1:0] i_ext_b_rdata,
    output logic                                           o_ext_result_we,
    output logic [                        WORD_ADDR_W-1:0] o_ext_result_waddr,
    output logic [                             WORD_W-1:0] o_ext_result_wdata,
    output logic                                           o_busy,
    output logic                                           o_done
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int PRODUCT_WORDS = 2 * WORDS;
  localparam int DIGITS_PER_WORD = WORD_W / DIGIT_W;
  localparam int LAST_BITS = R_BITS - ((WORDS - 1) * WORD_W);
  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int PRODUCT_ADDR_W = (PRODUCT_WORDS > 1) ? $clog2(PRODUCT_WORDS) : 1;
  localparam int SPARSE_ADDR_W = (SPARSE_WEIGHT > 1) ? $clog2(SPARSE_WEIGHT) : 1;
  localparam logic [WORD_W-1:0] LAST_MASK = {WORD_W{1'b1}} >> (WORD_W - LAST_BITS);

  typedef enum logic [4:0] {
    ST_IDLE,
    ST_LOAD_A,
    ST_LOAD_SPARSE,
    ST_LOAD_B,
    ST_CLEAR_PRODUCT,
    ST_CLEAR_RESULT,
    ST_MUL_FETCH_A,
    ST_MUL_FETCH_B,
    ST_MUL_READ_LOW,
    ST_MUL_WRITE_LOW,
    ST_MUL_READ_HIGH,
    ST_MUL_WRITE_HIGH,
    ST_REDUCE_READ_LOW,
    ST_REDUCE_READ_HIGH0,
    ST_REDUCE_READ_HIGH1,
    ST_REDUCE_WRITE,
    ST_SPARSE_FETCH_INDEX,
    ST_SPARSE_FETCH_B,
    ST_SPARSE_READ_0,
    ST_SPARSE_WRITE_0,
    ST_SPARSE_READ_1,
    ST_SPARSE_WRITE_1,
    ST_SPARSE_READ_2,
    ST_SPARSE_WRITE_2,
    ST_OUTPUT_FETCH,
    ST_OUTPUT_VALID
  } state_t;

  state_t                                           state_q;
  logic                                             sparse_mode_q;

  integer                                           word_idx_q;
  integer                                           sparse_idx_q;
  integer                                           a_word_idx_q;
  integer                                           b_word_idx_q;
  integer                                           digit_idx_q;
  integer                                           product_idx_q;
  integer                                           output_idx_q;

  logic   [((R_BITS > 1) ? $clog2(R_BITS) : 1)-1:0] sparse_index_q;
  logic   [                             WORD_W-1:0] a_word_q;
  logic   [                             WORD_W-1:0] reduce_low_q;
  logic   [                             WORD_W-1:0] reduce_high0_q;

  // These controls are intentionally inactive in the external dense-RAM
  // elaboration used by trike_poly_inv_core.
  /* verilator lint_off UNUSEDSIGNAL */
  logic                                             sparse_we;
  logic   [                      SPARSE_ADDR_W-1:0] sparse_waddr;
  logic   [                            INDEX_W-1:0] sparse_wdata;
  logic                                             sparse_re;
  logic   [                      SPARSE_ADDR_W-1:0] sparse_raddr;
  logic   [                            INDEX_W-1:0] sparse_rdata;

  logic                                             a_we;
  logic   [                        WORD_ADDR_W-1:0] a_waddr;
  logic   [                             WORD_W-1:0] a_wdata;
  logic                                             a_re;
  logic   [                        WORD_ADDR_W-1:0] a_raddr;
  logic   [                             WORD_W-1:0] a_rdata;
  logic   [                             WORD_W-1:0] a_mem_rdata;

  logic                                             b_we;
  logic   [                        WORD_ADDR_W-1:0] b_waddr;
  logic   [                             WORD_W-1:0] b_wdata;
  logic                                             b_re;
  logic   [                        WORD_ADDR_W-1:0] b_raddr;
  logic   [                             WORD_W-1:0] b_rdata;
  logic   [                             WORD_W-1:0] b_mem_rdata;

  logic                                             product_we;
  logic   [                     PRODUCT_ADDR_W-1:0] product_waddr;
  logic   [                             WORD_W-1:0] product_wdata;
  logic                                             product_re;
  logic   [                     PRODUCT_ADDR_W-1:0] product_raddr;
  logic   [                             WORD_W-1:0] product_rdata;

  logic                                             result_we;
  logic   [                        WORD_ADDR_W-1:0] result_waddr;
  logic   [                             WORD_W-1:0] result_wdata;
  logic                                             result_re;
  logic   [                        WORD_ADDR_W-1:0] result_raddr;
  /* verilator lint_on UNUSEDSIGNAL */
  logic   [                             WORD_W-1:0] result_rdata;
  logic   [                             WORD_W-1:0] result_mem_rdata;

  logic   [                             WORD_W-1:0] b_word_c;
  logic   [                            DIGIT_W-1:0] a_digit_c;
  logic   [                         (2*WORD_W)-1:0] partial_base_c;
  logic   [                         (2*WORD_W)-1:0] partial_shifted_c;
  logic   [                             WORD_W-1:0] reduced_word_c;
  logic   [                             WORD_W-1:0] sparse_source_word_c;
  logic   [                             WORD_W-1:0] sparse_first_mask_c;
  logic   [                         (2*WORD_W)-1:0] sparse_first_wide_c;
  logic   [                             WORD_W-1:0] sparse_contribution_c[0:2];
  logic   [                        WORD_ADDR_W-1:0] sparse_result_addr_c[0:2];

  integer                                           sparse_sum_c;
  integer                                           sparse_dest_start_c;
  integer                                           sparse_dest_word_c;
  integer                                           sparse_dest_offset_c;
  integer                                           sparse_source_bits_c;
  integer                                           sparse_first_len_c;

  generate
    if (!USE_EXTERNAL_DENSE_RAM) begin : g_internal_operand_ram
      ram_bram #(
          .DATA_W(INDEX_W),
          .DEPTH (SPARSE_WEIGHT)
      ) u_sparse_index_mem (
          .i_clk  (i_clk),
          .i_we   (sparse_we),
          .i_waddr(sparse_waddr),
          .i_wdata(sparse_wdata),
          .i_re   (sparse_re),
          .i_raddr(sparse_raddr),
          .o_rdata(sparse_rdata)
      );

      ram_bram #(
          .DATA_W(WORD_W),
          .DEPTH (WORDS)
      ) u_a_mem (
          .i_clk  (i_clk),
          .i_we   (a_we),
          .i_waddr(a_waddr),
          .i_wdata(a_wdata),
          .i_re   (a_re),
          .i_raddr(a_raddr),
          .o_rdata(a_mem_rdata)
      );

      ram_bram #(
          .DATA_W(WORD_W),
          .DEPTH (WORDS)
      ) u_b_mem (
          .i_clk  (i_clk),
          .i_we   (b_we),
          .i_waddr(b_waddr),
          .i_wdata(b_wdata),
          .i_re   (b_re),
          .i_raddr(b_raddr),
          .o_rdata(b_mem_rdata)
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
          .o_rdata(result_mem_rdata)
      );
    end else begin : g_external_operand_ram
      assign sparse_rdata = '0;
      assign a_mem_rdata = '0;
      assign b_mem_rdata = '0;
      assign result_mem_rdata = '0;
    end
  endgenerate

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (PRODUCT_WORDS)
  ) u_product_mem (
      .i_clk  (i_clk),
      .i_we   (product_we),
      .i_waddr(product_waddr),
      .i_wdata(product_wdata),
      .i_re   (product_re),
      .i_raddr(product_raddr),
      .o_rdata(product_rdata)
  );

  assign a_rdata = USE_EXTERNAL_DENSE_RAM ? i_ext_a_rdata : a_mem_rdata;
  assign b_rdata = USE_EXTERNAL_DENSE_RAM ? i_ext_b_rdata : b_mem_rdata;
  assign result_rdata = result_mem_rdata;

  assign o_ext_a_re = USE_EXTERNAL_DENSE_RAM && a_re;
  assign o_ext_a_raddr = a_raddr;
  assign o_ext_b_re = USE_EXTERNAL_DENSE_RAM && b_re;
  assign o_ext_b_raddr = b_raddr;
  assign o_ext_result_we = USE_EXTERNAL_DENSE_RAM && result_we;
  assign o_ext_result_waddr = result_waddr;
  assign o_ext_result_wdata = result_wdata;

  always_comb begin
    b_word_c = b_rdata;
    if (b_word_idx_q == (WORDS - 1)) b_word_c = b_word_c & LAST_MASK;

    a_digit_c = a_word_q[(digit_idx_q*DIGIT_W)+:DIGIT_W];
    partial_base_c = '0;
    for (int bit_idx = 0; bit_idx < DIGIT_W; bit_idx++) begin
      if (a_digit_c[bit_idx]) begin
        partial_base_c = partial_base_c ^ ({{WORD_W{1'b0}}, b_word_c} << bit_idx);
      end
    end
    partial_shifted_c = partial_base_c << (digit_idx_q * DIGIT_W);

    sparse_source_word_c = b_rdata;
    if (b_word_idx_q == (WORDS - 1)) begin
      sparse_source_word_c = sparse_source_word_c & LAST_MASK;
    end
    sparse_sum_c = 0;
    sparse_dest_start_c = 0;
    sparse_dest_word_c = 0;
    sparse_dest_offset_c = 0;
    sparse_source_bits_c = WORD_W;
    if (b_word_idx_q == (WORDS - 1)) sparse_source_bits_c = LAST_BITS;
    sparse_first_len_c  = WORD_W;
    sparse_first_mask_c = {WORD_W{1'b1}};
    sparse_first_wide_c = '0;
    for (int contribution_idx = 0; contribution_idx < 3; contribution_idx++) begin
      sparse_contribution_c[contribution_idx] = '0;
      sparse_result_addr_c[contribution_idx]  = '0;
    end
    if (int'(sparse_index_q) < R_BITS) begin
      sparse_sum_c = (b_word_idx_q * WORD_W) + int'(sparse_index_q);
      if (sparse_sum_c >= R_BITS) begin
        sparse_dest_start_c = sparse_sum_c - R_BITS;
      end else begin
        sparse_dest_start_c = sparse_sum_c;
      end
      sparse_dest_word_c   = sparse_dest_start_c / WORD_W;
      sparse_dest_offset_c = sparse_dest_start_c % WORD_W;
      sparse_first_len_c   = R_BITS - sparse_dest_start_c;
      if (sparse_first_len_c > sparse_source_bits_c) begin
        sparse_first_len_c = sparse_source_bits_c;
      end
      sparse_first_mask_c = {WORD_W{1'b1}} >> (WORD_W - sparse_first_len_c);
      sparse_first_wide_c =
          {{WORD_W{1'b0}}, (sparse_source_word_c & sparse_first_mask_c)}
          << sparse_dest_offset_c;
      sparse_contribution_c[0] = sparse_first_wide_c[WORD_W-1:0];
      sparse_result_addr_c[0] = WORD_ADDR_W'(sparse_dest_word_c);
      sparse_contribution_c[1] = sparse_first_wide_c[(2*WORD_W)-1:WORD_W];
      if ((sparse_dest_word_c + 1) < WORDS) begin
        sparse_result_addr_c[1] = WORD_ADDR_W'(sparse_dest_word_c + 1);
      end
      sparse_contribution_c[2] = sparse_source_word_c >> sparse_first_len_c;
    end

    if (LAST_BITS == WORD_W) begin
      reduced_word_c = reduce_low_q ^ product_rdata;
    end else begin
      reduced_word_c = reduce_low_q ^ (reduce_high0_q >> LAST_BITS) ^
                       (product_rdata << (WORD_W - LAST_BITS));
    end
    if (product_idx_q == (WORDS - 1)) reduced_word_c = reduced_word_c & LAST_MASK;
  end

  always_comb begin
    sparse_we = 1'b0;
    sparse_waddr = '0;
    sparse_wdata = '0;
    sparse_re = 1'b0;
    sparse_raddr = '0;
    a_we = 1'b0;
    a_waddr = '0;
    a_wdata = '0;
    a_re = 1'b0;
    a_raddr = '0;
    b_we = 1'b0;
    b_waddr = '0;
    b_wdata = '0;
    b_re = 1'b0;
    b_raddr = '0;
    product_we = 1'b0;
    product_waddr = '0;
    product_wdata = '0;
    product_re = 1'b0;
    product_raddr = '0;
    result_we = 1'b0;
    result_waddr = '0;
    result_wdata = '0;
    result_re = 1'b0;
    result_raddr = '0;

    unique case (state_q)
      ST_LOAD_A: begin
        if (i_a_valid) begin
          a_we = 1'b1;
          a_waddr = WORD_ADDR_W'(word_idx_q);
          if (word_idx_q == (WORDS - 1)) begin
            a_wdata = i_a_data & LAST_MASK;
          end else begin
            a_wdata = i_a_data;
          end
        end
      end

      ST_LOAD_SPARSE: begin
        if (i_sparse_index_valid) begin
          sparse_we = 1'b1;
          sparse_waddr = SPARSE_ADDR_W'(sparse_idx_q);
          sparse_wdata = i_sparse_index;
        end
      end

      ST_LOAD_B: begin
        if (i_b_valid) begin
          b_we = 1'b1;
          b_waddr = WORD_ADDR_W'(word_idx_q);
          if (word_idx_q == (WORDS - 1)) begin
            b_wdata = i_b_data & LAST_MASK;
          end else begin
            b_wdata = i_b_data;
          end
        end
      end

      ST_CLEAR_PRODUCT: begin
        product_we = 1'b1;
        product_waddr = PRODUCT_ADDR_W'(word_idx_q);
      end

      ST_CLEAR_RESULT: begin
        result_we = 1'b1;
        result_waddr = WORD_ADDR_W'(word_idx_q);
      end

      ST_MUL_FETCH_A: begin
        a_re = 1'b1;
        a_raddr = WORD_ADDR_W'(a_word_idx_q);
      end

      ST_MUL_FETCH_B: begin
        b_re = 1'b1;
        b_raddr = WORD_ADDR_W'(b_word_idx_q);
      end

      ST_MUL_READ_LOW: begin
        product_re = 1'b1;
        product_raddr = PRODUCT_ADDR_W'(a_word_idx_q + b_word_idx_q);
      end

      ST_MUL_WRITE_LOW: begin
        product_we = 1'b1;
        product_waddr = PRODUCT_ADDR_W'(a_word_idx_q + b_word_idx_q);
        product_wdata = product_rdata ^ partial_shifted_c[WORD_W-1:0];
      end

      ST_MUL_READ_HIGH: begin
        product_re = 1'b1;
        product_raddr = PRODUCT_ADDR_W'(a_word_idx_q + b_word_idx_q + 1);
      end

      ST_MUL_WRITE_HIGH: begin
        product_we = 1'b1;
        product_waddr = PRODUCT_ADDR_W'(a_word_idx_q + b_word_idx_q + 1);
        product_wdata = product_rdata ^ partial_shifted_c[(2*WORD_W)-1:WORD_W];
      end

      ST_REDUCE_READ_LOW: begin
        product_re = 1'b1;
        product_raddr = PRODUCT_ADDR_W'(product_idx_q);
      end

      ST_REDUCE_READ_HIGH0: begin
        product_re = 1'b1;
        product_raddr = PRODUCT_ADDR_W'(product_idx_q + WORDS - 1);
      end

      ST_REDUCE_READ_HIGH1: begin
        product_re = 1'b1;
        product_raddr = PRODUCT_ADDR_W'(product_idx_q + WORDS);
      end

      ST_REDUCE_WRITE: begin
        result_we = 1'b1;
        result_waddr = WORD_ADDR_W'(product_idx_q);
        result_wdata = reduced_word_c;
      end

      ST_SPARSE_FETCH_INDEX: begin
        sparse_re = 1'b1;
        sparse_raddr = SPARSE_ADDR_W'(sparse_idx_q);
      end

      ST_SPARSE_FETCH_B: begin
        b_re = 1'b1;
        b_raddr = WORD_ADDR_W'(b_word_idx_q);
      end

      ST_SPARSE_READ_0: begin
        result_re = 1'b1;
        result_raddr = sparse_result_addr_c[0];
      end

      ST_SPARSE_WRITE_0: begin
        result_we = 1'b1;
        result_waddr = sparse_result_addr_c[0];
        result_wdata = result_rdata ^ sparse_contribution_c[0];
      end

      ST_SPARSE_READ_1: begin
        result_re = 1'b1;
        result_raddr = sparse_result_addr_c[1];
      end

      ST_SPARSE_WRITE_1: begin
        result_we = 1'b1;
        result_waddr = sparse_result_addr_c[1];
        result_wdata = result_rdata ^ sparse_contribution_c[1];
      end

      ST_SPARSE_READ_2: begin
        result_re = 1'b1;
        result_raddr = sparse_result_addr_c[2];
      end

      ST_SPARSE_WRITE_2: begin
        result_we = 1'b1;
        result_waddr = sparse_result_addr_c[2];
        result_wdata = result_rdata ^ sparse_contribution_c[2];
      end

      ST_OUTPUT_FETCH: begin
        result_re = 1'b1;
        result_raddr = WORD_ADDR_W'(output_idx_q);
      end

      default: begin
      end
    endcase
  end

  assign o_a_ready = (state_q == ST_LOAD_A);
  assign o_sparse_index_ready = (state_q == ST_LOAD_SPARSE);
  assign o_b_ready = (state_q == ST_LOAD_B);
  assign o_result_valid = (state_q == ST_OUTPUT_VALID);
  assign o_result_data = result_rdata;
  assign o_result_last = (output_idx_q == (WORDS - 1));
  assign o_busy = (state_q != ST_IDLE);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q        <= ST_IDLE;
      sparse_mode_q  <= 1'b0;
      word_idx_q     <= 0;
      sparse_idx_q   <= 0;
      a_word_idx_q   <= 0;
      b_word_idx_q   <= 0;
      digit_idx_q    <= 0;
      product_idx_q  <= 0;
      output_idx_q   <= 0;
      sparse_index_q <= '0;
      a_word_q       <= '0;
      reduce_low_q   <= '0;
      reduce_high0_q <= '0;
      o_done         <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            sparse_mode_q <= i_sparse_a;
            word_idx_q    <= 0;
            if (USE_EXTERNAL_DENSE_RAM) begin
              state_q <= ST_CLEAR_PRODUCT;
            end else if (i_sparse_a) begin
              sparse_idx_q <= 0;
              state_q      <= ST_LOAD_SPARSE;
            end else begin
              state_q <= ST_LOAD_A;
            end
          end
        end

        ST_LOAD_A: begin
          if (i_a_valid) begin
            if (word_idx_q == (WORDS - 1)) begin
              word_idx_q <= 0;
              state_q    <= ST_LOAD_B;
            end else begin
              word_idx_q <= word_idx_q + 1;
            end
          end
        end

        ST_LOAD_SPARSE: begin
          if (i_sparse_index_valid) begin
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
              word_idx_q <= 0;
              if (sparse_mode_q) begin
                state_q <= ST_CLEAR_RESULT;
              end else begin
                state_q <= ST_CLEAR_PRODUCT;
              end
            end else begin
              word_idx_q <= word_idx_q + 1;
            end
          end
        end

        ST_CLEAR_RESULT: begin
          if (word_idx_q == (WORDS - 1)) begin
            sparse_idx_q <= 0;
            b_word_idx_q <= 0;
            state_q      <= ST_SPARSE_FETCH_INDEX;
          end else begin
            word_idx_q <= word_idx_q + 1;
          end
        end

        ST_CLEAR_PRODUCT: begin
          if (word_idx_q == (PRODUCT_WORDS - 1)) begin
            a_word_idx_q <= 0;
            b_word_idx_q <= 0;
            digit_idx_q  <= 0;
            state_q      <= ST_MUL_FETCH_A;
          end else begin
            word_idx_q <= word_idx_q + 1;
          end
        end

        ST_MUL_FETCH_A: begin
          state_q <= ST_MUL_FETCH_B;
        end

        ST_MUL_FETCH_B: begin
          a_word_q <= a_rdata;
          if (a_word_idx_q == (WORDS - 1)) a_word_q <= a_rdata & LAST_MASK;
          state_q <= ST_MUL_READ_LOW;
        end

        ST_MUL_READ_LOW: begin
          state_q <= ST_MUL_WRITE_LOW;
        end

        ST_MUL_WRITE_LOW: begin
          state_q <= ST_MUL_READ_HIGH;
        end

        ST_MUL_READ_HIGH: begin
          state_q <= ST_MUL_WRITE_HIGH;
        end

        ST_MUL_WRITE_HIGH: begin
          if (digit_idx_q == (DIGITS_PER_WORD - 1)) begin
            digit_idx_q <= 0;
            if (b_word_idx_q == (WORDS - 1)) begin
              b_word_idx_q <= 0;
              if (a_word_idx_q == (WORDS - 1)) begin
                product_idx_q <= 0;
                state_q       <= ST_REDUCE_READ_LOW;
              end else begin
                a_word_idx_q <= a_word_idx_q + 1;
                state_q      <= ST_MUL_FETCH_A;
              end
            end else begin
              b_word_idx_q <= b_word_idx_q + 1;
              state_q      <= ST_MUL_FETCH_B;
            end
          end else begin
            digit_idx_q <= digit_idx_q + 1;
            state_q     <= ST_MUL_READ_LOW;
          end
        end

        ST_REDUCE_READ_LOW: begin
          state_q <= ST_REDUCE_READ_HIGH0;
        end

        ST_REDUCE_READ_HIGH0: begin
          reduce_low_q <= product_rdata;
          state_q      <= ST_REDUCE_READ_HIGH1;
        end

        ST_REDUCE_READ_HIGH1: begin
          reduce_high0_q <= product_rdata;
          state_q        <= ST_REDUCE_WRITE;
        end

        ST_REDUCE_WRITE: begin
          if (product_idx_q == (WORDS - 1)) begin
            if (USE_EXTERNAL_DENSE_RAM) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              output_idx_q <= 0;
              state_q      <= ST_OUTPUT_FETCH;
            end
          end else begin
            product_idx_q <= product_idx_q + 1;
            state_q       <= ST_REDUCE_READ_LOW;
          end
        end

        ST_SPARSE_FETCH_INDEX: begin
          state_q <= ST_SPARSE_FETCH_B;
        end

        ST_SPARSE_FETCH_B: begin
          sparse_index_q <= sparse_rdata;
          state_q        <= ST_SPARSE_READ_0;
        end

        ST_SPARSE_READ_0: begin
          state_q <= ST_SPARSE_WRITE_0;
        end

        ST_SPARSE_WRITE_0: begin
          state_q <= ST_SPARSE_READ_1;
        end

        ST_SPARSE_READ_1: begin
          state_q <= ST_SPARSE_WRITE_1;
        end

        ST_SPARSE_WRITE_1: begin
          state_q <= ST_SPARSE_READ_2;
        end

        ST_SPARSE_READ_2: begin
          state_q <= ST_SPARSE_WRITE_2;
        end

        ST_SPARSE_WRITE_2: begin
          if (b_word_idx_q == (WORDS - 1)) begin
            b_word_idx_q <= 0;
            if (sparse_idx_q == (SPARSE_WEIGHT - 1)) begin
              output_idx_q <= 0;
              state_q      <= ST_OUTPUT_FETCH;
            end else begin
              sparse_idx_q <= sparse_idx_q + 1;
              state_q      <= ST_SPARSE_FETCH_INDEX;
            end
          end else begin
            b_word_idx_q <= b_word_idx_q + 1;
            state_q      <= ST_SPARSE_FETCH_B;
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
              state_q      <= ST_OUTPUT_FETCH;
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
  always_ff @(posedge i_clk) begin
    if ((state_q == ST_IDLE) && i_start && USE_EXTERNAL_DENSE_RAM && i_sparse_a) begin
      $error("trike_poly_mul_core external RAM mode supports dense multiplication only");
    end
  end

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
    if (WORD_ADDR_W != ((WORDS > 1) ? $clog2(WORDS) : 1)) begin
      $error("trike_poly_mul_core WORD_ADDR_W must match WORDS");
    end
  end
`endif

endmodule
