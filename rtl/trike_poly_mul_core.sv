`timescale 1ns / 1ps

// Recursive carry-less Karatsuba base multiplier. LEVELS=0 is the classical
// bit-parallel base case. Each higher level uses three half-size products and
// reconstructs the full polynomial product with XORs.
/* verilator lint_off DECLFILENAME */
module trike_clmul_karatsuba #(
    parameter int WIDTH  = 64,
    parameter int LEVELS = 1
) (
    input  logic [    WIDTH-1:0] i_a,
    input  logic [    WIDTH-1:0] i_b,
    output logic [(2*WIDTH)-1:0] o_product
);

  generate
    if (LEVELS == 0) begin : g_base
      always_comb begin
        o_product = '0;
        for (int bit_idx = 0; bit_idx < WIDTH; bit_idx++) begin
          if (i_a[bit_idx]) begin
            o_product = o_product ^ ({{WIDTH{1'b0}}, i_b} << bit_idx);
          end
        end
      end
    end else begin : g_recursive
      localparam int HALF_W = WIDTH / 2;

      logic [   HALF_W-1:0] a_cross;
      logic [   HALF_W-1:0] b_cross;
      logic [    WIDTH-1:0] product_low;
      logic [    WIDTH-1:0] product_high;
      logic [    WIDTH-1:0] product_cross;
      logic [(2*WIDTH)-1:0] product_low_wide;
      logic [(2*WIDTH)-1:0] product_high_wide;
      logic [(2*WIDTH)-1:0] product_middle_wide;

      assign a_cross = i_a[HALF_W-1:0] ^ i_a[WIDTH-1:HALF_W];
      assign b_cross = i_b[HALF_W-1:0] ^ i_b[WIDTH-1:HALF_W];

      trike_clmul_karatsuba #(
          .WIDTH (HALF_W),
          .LEVELS(LEVELS - 1)
      ) u_low (
          .i_a      (i_a[HALF_W-1:0]),
          .i_b      (i_b[HALF_W-1:0]),
          .o_product(product_low)
      );

      trike_clmul_karatsuba #(
          .WIDTH (HALF_W),
          .LEVELS(LEVELS - 1)
      ) u_high (
          .i_a      (i_a[WIDTH-1:HALF_W]),
          .i_b      (i_b[WIDTH-1:HALF_W]),
          .o_product(product_high)
      );

      trike_clmul_karatsuba #(
          .WIDTH (HALF_W),
          .LEVELS(LEVELS - 1)
      ) u_cross (
          .i_a      (a_cross),
          .i_b      (b_cross),
          .o_product(product_cross)
      );

      assign product_low_wide = {{WIDTH{1'b0}}, product_low};
      assign product_high_wide = {{WIDTH{1'b0}}, product_high} << WIDTH;
      assign product_middle_wide =
          {{WIDTH{1'b0}}, (product_low ^ product_high ^ product_cross)} << HALF_W;
      assign o_product = product_low_wide ^ product_middle_wide ^ product_high_wide;
    end
  endgenerate

`ifndef SYNTHESIS
  initial begin
    if (WIDTH < 1) $error("trike_clmul_karatsuba WIDTH must be positive");
    if (LEVELS < 0) $error("trike_clmul_karatsuba LEVELS must be nonnegative");
    if ((WIDTH % (1 << LEVELS)) != 0) begin
      $error("trike_clmul_karatsuba WIDTH must be divisible by 2^LEVELS");
    end
  end
`endif

endmodule
/* verilator lint_on DECLFILENAME */

// Fixed-schedule dense Karatsuba-Comba with direct cyclic fold, and sparse
// cyclic shifts. Both modes share the B operand and W-word result memory.
// External operand binding uses fixed in-place XOR and restore scans.
module trike_poly_mul_core #(
    parameter int R_BITS = 15581,
    parameter int WORD_W = 64,
    parameter int BASE_KARATSUBA_DEPTH = 1,
    parameter int SPARSE_WEIGHT = 263,
    parameter bit RUNTIME_GEOMETRY = 1'b0,
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic                                           i_clk,
    input  logic                                           i_rst_n,
    input  logic                                           i_start,
    input  logic [                                   31:0] i_runtime_r_bits,
    input  logic [                                   31:0] i_runtime_words,
    input  logic [                                   31:0] i_runtime_sparse_weight,
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
  localparam int LAST_BITS = R_BITS - ((WORDS - 1) * WORD_W);
  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int SPARSE_ADDR_W = (SPARSE_WEIGHT > 1) ? $clog2(SPARSE_WEIGHT) : 1;
  localparam int SPARSE_SUM_W = INDEX_W + 1;
  localparam int SOURCE_BITS_W = $clog2(WORD_W + 1);

  typedef enum logic [4:0] {
    ST_IDLE,
    ST_LOAD_A,
    ST_LOAD_SPARSE,
    ST_LOAD_B,
    ST_CLEAR_RESULT,
    ST_DENSE_START,
    ST_DENSE_WAIT,
    ST_SPARSE_FETCH_INDEX,
    ST_SPARSE_FETCH_B,
    ST_SPARSE_PREPARE,
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
  integer                                           b_word_idx_q;
  integer                                           output_idx_q;
  integer                                           active_r_bits_q;
  integer                                           active_words_q;
  integer                                           active_sparse_weight_q;
  integer                                           active_last_bits_q;
  logic   [                             WORD_W-1:0] active_last_mask_c;

  logic   [((R_BITS > 1) ? $clog2(R_BITS) : 1)-1:0] sparse_index_q;

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
  logic   [                             WORD_W-1:0] a_mem_rdata;

  logic                                             b_we;
  logic   [                        WORD_ADDR_W-1:0] b_waddr;
  logic   [                             WORD_W-1:0] b_wdata;
  logic                                             b_re;
  logic   [                        WORD_ADDR_W-1:0] b_raddr;
  logic   [                             WORD_W-1:0] b_rdata;
  logic   [                             WORD_W-1:0] b_mem_rdata;

  logic                                             result_we;
  logic   [                        WORD_ADDR_W-1:0] result_waddr;
  logic   [                             WORD_W-1:0] result_wdata;
  logic                                             result_re;
  logic   [                        WORD_ADDR_W-1:0] result_raddr;
  /* verilator lint_on UNUSEDSIGNAL */
  logic   [                             WORD_W-1:0] result_rdata;
  logic   [                             WORD_W-1:0] result_mem_rdata;

  logic   [                             WORD_W-1:0] sparse_source_word_c;
  logic   [                             WORD_W-1:0] sparse_source_word_q;
  logic   [                             WORD_W-1:0] sparse_first_mask_c;
  logic   [                         (2*WORD_W)-1:0] sparse_first_wide_c;
  logic   [                             WORD_W-1:0] sparse_contribution_c[0:2];
  logic   [                        WORD_ADDR_W-1:0] sparse_result_addr_c[0:2];
  logic   [                             WORD_W-1:0] sparse_contribution_q[0:2];
  logic   [                        WORD_ADDR_W-1:0] sparse_result_addr_q[0:2];

  logic   [                       SPARSE_SUM_W-1:0] sparse_sum_c;
  logic   [                       SPARSE_SUM_W-1:0] sparse_dest_start_c;
  logic   [                       SPARSE_SUM_W-1:0] sparse_dest_start_q;
  logic   [                       SPARSE_SUM_W-1:0] sparse_available_c;
  logic   [                      SOURCE_BITS_W-1:0] sparse_source_bits_c;
  logic   [                      SOURCE_BITS_W-1:0] sparse_source_bits_q;
  integer                                           sparse_dest_word_c;
  integer                                           sparse_dest_offset_c;
  integer                                           sparse_first_len_c;

  logic dense_operand_re, dense_done, dense_valid, dense_last;
  logic [WORD_ADDR_W-1:0] dense_a0_addr, dense_b0_addr;
  logic [WORD_W-1:0] dense_data;
  logic dense_acc_we, dense_acc_re;
  logic [WORD_ADDR_W-1:0] dense_acc_waddr, dense_acc_raddr;
  logic [WORD_W-1:0] dense_acc_wdata;
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
  assign b_rdata = b_mem_rdata;
  assign result_rdata = result_mem_rdata;
  logic                   dense_operand_we;
  logic [WORD_ADDR_W-1:0] dense_operand_waddr;
  logic [WORD_W-1:0] dense_a_wdata, dense_b_wdata;
  // Stream or RAM outputs unused in this binding.
  /* verilator lint_off PINCONNECTEMPTY */
  trike_poly_mul_karatsuba_core #(
      .R_BITS(R_BITS),
      .WORD_W(WORD_W),
      .BASE_KARATSUBA_DEPTH(BASE_KARATSUBA_DEPTH),
      .EXTERNAL_OPERANDS(1'b1),
      .EXTERNAL_RESULT(1'b1),
      .RUNTIME_GEOMETRY(RUNTIME_GEOMETRY)
  ) u_dense (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_start(state_q == ST_DENSE_START),
      .i_runtime_r_bits(32'(active_r_bits_q)),
      .i_runtime_words(32'(active_words_q)),
      .o_operand_re(dense_operand_re),
      .o_operand_we(dense_operand_we),
      .o_operand_waddr(dense_operand_waddr),
      .o_operand_a_wdata(dense_a_wdata),
      .o_operand_b_wdata(dense_b_wdata),
      .o_a0_addr(dense_a0_addr),

      .o_b0_addr(dense_b0_addr),

      .i_a0_data(a_mem_rdata),

      .i_b0_data(b_mem_rdata),

      .o_acc_we(dense_acc_we),
      .o_acc_re(dense_acc_re),
      .o_acc_waddr(dense_acc_waddr),
      .o_acc_raddr(dense_acc_raddr),
      .o_acc_wdata(dense_acc_wdata),
      .i_acc_rdata(result_rdata),
      .i_a_valid(1'b0),
      .i_a_data('0),
      .o_a_ready(),
      .i_b_valid(1'b0),
      .i_b_data('0),
      .o_b_ready(),
      .o_result_valid(dense_valid),
      .o_result_data(dense_data),
      .o_result_last(dense_last),
      .i_result_ready(i_result_ready),
      .o_busy(),
      .o_done(dense_done)
  );

  /* verilator lint_on PINCONNECTEMPTY */
  always_comb begin
    active_last_mask_c   = {WORD_W{1'b1}} >> (WORD_W - active_last_bits_q);
    sparse_source_word_c = b_rdata;
    if (b_word_idx_q == (active_words_q - 1)) begin
      sparse_source_word_c = sparse_source_word_c & active_last_mask_c;
    end
    sparse_sum_c = SPARSE_SUM_W'(b_word_idx_q) * SPARSE_SUM_W'(WORD_W) +
                   SPARSE_SUM_W'(sparse_index_q);
    sparse_dest_start_c = sparse_sum_c;
    if (sparse_sum_c >= SPARSE_SUM_W'(active_r_bits_q)) begin
      sparse_dest_start_c = sparse_sum_c - SPARSE_SUM_W'(active_r_bits_q);
    end
    sparse_source_bits_c = SOURCE_BITS_W'(WORD_W);
    if (b_word_idx_q == (active_words_q - 1))
      sparse_source_bits_c = SOURCE_BITS_W'(active_last_bits_q);

    // Register the public cyclic-address reduction before the masks and
    // variable shifts.  This splits the carry chain without adding a
    // data-dependent branch to the sparse multiplication schedule.
    sparse_available_c   = SPARSE_SUM_W'(active_r_bits_q) - sparse_dest_start_q;
    sparse_dest_word_c   = 0;
    sparse_dest_offset_c = 0;
    sparse_first_len_c   = WORD_W;
    sparse_first_mask_c  = {WORD_W{1'b1}};
    sparse_first_wide_c  = '0;
    for (int contribution_idx = 0; contribution_idx < 3; contribution_idx++) begin
      sparse_contribution_c[contribution_idx] = '0;
      sparse_result_addr_c[contribution_idx]  = '0;
    end
    if (int'(sparse_index_q) < active_r_bits_q) begin
      sparse_dest_word_c   = int'(sparse_dest_start_q) / WORD_W;
      sparse_dest_offset_c = int'(sparse_dest_start_q) % WORD_W;
      sparse_first_len_c   = int'(sparse_available_c);
      if (sparse_first_len_c > int'(sparse_source_bits_q)) begin
        sparse_first_len_c = int'(sparse_source_bits_q);
      end
      sparse_first_mask_c = {WORD_W{1'b1}} >> (WORD_W - sparse_first_len_c);
      sparse_first_wide_c =
          {{WORD_W{1'b0}}, (sparse_source_word_q & sparse_first_mask_c)}
          << sparse_dest_offset_c;
      sparse_contribution_c[0] = sparse_first_wide_c[WORD_W-1:0];
      sparse_result_addr_c[0] = WORD_ADDR_W'(sparse_dest_word_c);
      sparse_contribution_c[1] = sparse_first_wide_c[(2*WORD_W)-1:WORD_W];
      if ((sparse_dest_word_c + 1) < active_words_q) begin
        sparse_result_addr_c[1] = WORD_ADDR_W'(sparse_dest_word_c + 1);
      end
      sparse_contribution_c[2] = sparse_source_word_q >> sparse_first_len_c;
    end

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
          if (word_idx_q == (active_words_q - 1)) begin
            a_wdata = i_a_data & active_last_mask_c;
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
          if (word_idx_q == (active_words_q - 1)) begin
            b_wdata = i_b_data & active_last_mask_c;
          end else begin
            b_wdata = i_b_data;
          end
        end
      end

      ST_CLEAR_RESULT: begin
        result_we = 1'b1;
        result_waddr = WORD_ADDR_W'(word_idx_q);
      end

      ST_DENSE_WAIT: begin
        a_we = dense_operand_we;
        a_waddr = dense_operand_waddr;
        a_wdata = dense_a_wdata;
        b_we = dense_operand_we;
        b_waddr = dense_operand_waddr;
        b_wdata = dense_b_wdata;
        a_re = dense_operand_re;
        a_raddr = dense_a0_addr;
        b_re = dense_operand_re;
        b_raddr = dense_b0_addr;
        result_we = dense_acc_we;
        result_waddr = dense_acc_waddr;
        result_wdata = dense_acc_wdata;
        result_re = dense_acc_re;
        result_raddr = dense_acc_raddr;
      end

      ST_SPARSE_FETCH_INDEX: begin
        sparse_re = 1'b1;
        sparse_raddr = SPARSE_ADDR_W'(sparse_idx_q);
      end

      ST_SPARSE_FETCH_B: begin
        b_re = 1'b1;
        b_raddr = WORD_ADDR_W'(b_word_idx_q);
      end

      ST_SPARSE_PREPARE: begin
      end

      ST_SPARSE_READ_0: begin
        result_re = 1'b1;
        result_raddr = sparse_result_addr_c[0];
      end

      ST_SPARSE_WRITE_0: begin
        result_we = 1'b1;
        result_waddr = sparse_result_addr_q[0];
        result_wdata = result_rdata ^ sparse_contribution_q[0];
      end

      ST_SPARSE_READ_1: begin
        result_re = 1'b1;
        result_raddr = sparse_result_addr_q[1];
      end

      ST_SPARSE_WRITE_1: begin
        result_we = 1'b1;
        result_waddr = sparse_result_addr_q[1];
        result_wdata = result_rdata ^ sparse_contribution_q[1];
      end

      ST_SPARSE_READ_2: begin
        result_re = 1'b1;
        result_raddr = sparse_result_addr_q[2];
      end

      ST_SPARSE_WRITE_2: begin
        result_we = 1'b1;
        result_waddr = sparse_result_addr_q[2];
        result_wdata = result_rdata ^ sparse_contribution_q[2];
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
  assign o_result_valid = (state_q == ST_DENSE_WAIT) ? dense_valid : (state_q == ST_OUTPUT_VALID);
  assign o_result_data = (state_q == ST_DENSE_WAIT) ? dense_data : result_rdata;
  assign o_result_last = (state_q == ST_DENSE_WAIT) ? dense_last : (output_idx_q == (active_words_q - 1));
  assign o_busy = (state_q != ST_IDLE);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q                <= ST_IDLE;
      sparse_mode_q          <= 1'b0;
      word_idx_q             <= 0;
      sparse_idx_q           <= 0;

      b_word_idx_q           <= 0;

      output_idx_q           <= 0;
      sparse_index_q         <= '0;

      active_r_bits_q        <= R_BITS;
      active_words_q         <= WORDS;
      active_sparse_weight_q <= SPARSE_WEIGHT;
      active_last_bits_q     <= LAST_BITS;
      o_done                 <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            sparse_mode_q <= i_sparse_a;
            word_idx_q    <= 0;
            if (RUNTIME_GEOMETRY) begin
              active_r_bits_q <= int'(i_runtime_r_bits);
              active_words_q <= int'(i_runtime_words);
              active_sparse_weight_q <= int'(i_runtime_sparse_weight);
              active_last_bits_q <= int'(i_runtime_r_bits) - ((int'(i_runtime_words) - 1) * WORD_W);
            end else begin
              active_r_bits_q <= R_BITS;
              active_words_q <= WORDS;
              active_sparse_weight_q <= SPARSE_WEIGHT;
              active_last_bits_q <= LAST_BITS;
            end
            if (i_sparse_a) begin
              sparse_idx_q <= 0;
              state_q      <= ST_LOAD_SPARSE;
            end else begin
              state_q <= ST_LOAD_A;
            end
          end
        end

        ST_LOAD_A: begin
          if (i_a_valid) begin
            if (word_idx_q == (active_words_q - 1)) begin
              word_idx_q <= 0;
              state_q    <= ST_LOAD_B;
            end else begin
              word_idx_q <= word_idx_q + 1;
            end
          end
        end

        ST_LOAD_SPARSE: begin
          if (i_sparse_index_valid) begin
            if (sparse_idx_q == (active_sparse_weight_q - 1)) begin
              word_idx_q <= 0;
              state_q    <= ST_LOAD_B;
            end else begin
              sparse_idx_q <= sparse_idx_q + 1;
            end
          end
        end

        ST_LOAD_B: begin
          if (i_b_valid) begin
            if (word_idx_q == (active_words_q - 1)) begin
              word_idx_q <= 0;
              if (sparse_mode_q) begin
                state_q <= ST_CLEAR_RESULT;
              end else begin

                b_word_idx_q <= 0;

                state_q      <= ST_DENSE_START;
              end
            end else begin
              word_idx_q <= word_idx_q + 1;
            end
          end
        end

        ST_CLEAR_RESULT: begin
          if (word_idx_q == (active_words_q - 1)) begin
            sparse_idx_q <= 0;
            b_word_idx_q <= 0;
            state_q      <= ST_SPARSE_FETCH_INDEX;
          end else begin
            word_idx_q <= word_idx_q + 1;
          end
        end

        ST_DENSE_START: state_q <= ST_DENSE_WAIT;
        ST_DENSE_WAIT: begin

          if (dense_done) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        ST_SPARSE_FETCH_INDEX: begin
          state_q <= ST_SPARSE_FETCH_B;
        end

        ST_SPARSE_FETCH_B: begin
          sparse_index_q <= sparse_rdata;
          state_q        <= ST_SPARSE_PREPARE;
        end

        ST_SPARSE_PREPARE: begin
          sparse_source_word_q <= sparse_source_word_c;
          sparse_dest_start_q  <= sparse_dest_start_c;
          sparse_source_bits_q <= sparse_source_bits_c;
          state_q              <= ST_SPARSE_READ_0;
        end

        ST_SPARSE_READ_0: begin
          for (int contribution_idx = 0; contribution_idx < 3; contribution_idx++) begin
            sparse_contribution_q[contribution_idx] <= sparse_contribution_c[contribution_idx];
            sparse_result_addr_q[contribution_idx]  <= sparse_result_addr_c[contribution_idx];
          end
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
          if (b_word_idx_q == (active_words_q - 1)) begin
            b_word_idx_q <= 0;
            if (sparse_idx_q == (active_sparse_weight_q - 1)) begin
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
            if (output_idx_q == (active_words_q - 1)) begin
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
    if ((state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS))
        $error("trike_poly_mul_core runtime r out of range");
      if ((i_runtime_words < 1) || (i_runtime_words > WORDS))
        $error("trike_poly_mul_core runtime words out of range");
      if ((i_runtime_sparse_weight < 1) || (i_runtime_sparse_weight > SPARSE_WEIGHT))
        $error("trike_poly_mul_core runtime sparse weight out of range");
      if (i_runtime_words != ((i_runtime_r_bits + WORD_W - 1) / WORD_W))
        $error("trike_poly_mul_core runtime word count mismatch");
    end
  end

  initial begin
    if (R_BITS < 1) $error("trike_poly_mul_core R_BITS must be at least 1");
    if (WORD_W < 2) $error("trike_poly_mul_core WORD_W must be at least 2");
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
