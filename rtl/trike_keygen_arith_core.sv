`timescale 1ns / 1ps

// Fixed-schedule TRIKE KeyGen polynomial arithmetic.
//
// Inputs are the sparse h0/h1/h2 supports and dense t1/t2/r1 vectors. One
// general multiplier and one fixed-chain inverter execute:
//   t0 = (h0*r1 + h1) * inverse(t1 + r1)
//   r2 = (t0*t2 + h2) * inverse(t0 + h0)
// Operation counts and RAM scans depend only on public parameters.
module trike_keygen_arith_core #(
    parameter int R_BITS = 15581,
    parameter int SECRET_WEIGHT = 35,
    parameter int WORD_W = 64,
    parameter int DIGIT_W = 8,
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic                                                         i_clk,
    input  logic                                                         i_rst_n,
    input  logic                                                         i_support_valid,
    input  logic [                                                  1:0] i_support_block,
    input  logic [((SECRET_WEIGHT > 1) ? $clog2(SECRET_WEIGHT) : 1)-1:0] i_support_position,
    input  logic [              ((R_BITS > 1) ? $clog2(R_BITS) : 1)-1:0] i_support_index,
    output logic                                                         o_support_ready,
    input  logic                                                         i_vector_valid,
    input  logic [                                                  1:0] i_vector_select,
    input  logic [                                      WORD_ADDR_W-1:0] i_vector_word,
    input  logic [                                           WORD_W-1:0] i_vector_data,
    output logic                                                         o_vector_ready,
    input  logic                                                         i_start,
    output logic                                                         o_result_valid,
    output logic                                                         o_result_select,
    output logic [                                      WORD_ADDR_W-1:0] o_result_word,
    output logic [                                           WORD_W-1:0] o_result_data,
    output logic                                                         o_result_last,
    input  logic                                                         i_result_ready,
    output logic                                                         o_busy,
    output logic                                                         o_done
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int POSITION_W = (SECRET_WEIGHT > 1) ? $clog2(SECRET_WEIGHT) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_MUL_START,
    ST_MUL_RUN,
    ST_INV_START,
    ST_INV_RUN,
    ST_OUTPUT_FETCH,
    ST_OUTPUT_VALID
  } state_t;

  typedef enum logic [2:0] {
    OP_MUL_H0_R1,
    OP_INV_T0_DEN,
    OP_MUL_T0,
    OP_INV_R2_DEN,
    OP_MUL_T0_T2,
    OP_MUL_R2
  } operation_t;

  typedef enum logic [3:0] {
    READ_NONE,
    READ_R1,
    READ_NUMERATOR,
    READ_INVERSE,
    READ_T0,
    READ_T2,
    READ_DENOMINATOR1,
    READ_DENOMINATOR2
  } read_source_t;

  typedef enum logic [1:0] {
    READ_OPERAND_NONE,
    READ_OPERAND_MUL_A,
    READ_OPERAND_MUL_B,
    READ_OPERAND_INV
  } read_operand_t;

  state_t                          state_q;
  operation_t                      operation_q;
  logic          [    INDEX_W-1:0] support_q[0:2][0:SECRET_WEIGHT-1];

  integer                          mul_a_request_q;
  integer                          mul_b_request_q;
  integer                          inv_request_q;
  integer                          sparse_position_q;
  integer                          mul_result_word_q;
  integer                          inv_result_word_q;

  logic                            read_pending_q;
  logic                            read_data_valid_q;
  read_source_t                    read_source_q;
  read_operand_t                   read_operand_q;
  logic          [WORD_ADDR_W-1:0] read_addr_q;
  logic          [     WORD_W-1:0] read_data_q;
  logic                            read_issue_c;
  read_source_t                    read_issue_source_c;
  read_operand_t                   read_issue_operand_c;
  logic          [WORD_ADDR_W-1:0] read_issue_addr_c;
  logic          [     WORD_W-1:0] read_capture_data_c;

  logic                            output_select_q;
  integer                          output_word_q;

  logic                            t1_we;
  logic                            t1_re;
  logic          [WORD_ADDR_W-1:0] t1_addr;
  logic          [     WORD_W-1:0] t1_wdata;
  logic          [     WORD_W-1:0] t1_rdata;
  logic                            t2_we;
  logic                            t2_re;
  logic          [WORD_ADDR_W-1:0] t2_addr;
  logic          [     WORD_W-1:0] t2_wdata;
  logic          [     WORD_W-1:0] t2_rdata;
  logic                            r1_we;
  logic                            r1_re;
  logic          [WORD_ADDR_W-1:0] r1_addr;
  logic          [     WORD_W-1:0] r1_wdata;
  logic          [     WORD_W-1:0] r1_rdata;
  logic                            numerator_we;
  logic                            numerator_re;
  logic          [WORD_ADDR_W-1:0] numerator_addr;
  logic          [     WORD_W-1:0] numerator_wdata;
  logic          [     WORD_W-1:0] numerator_rdata;
  logic                            inverse_we;
  logic                            inverse_re;
  logic          [WORD_ADDR_W-1:0] inverse_addr;
  logic          [     WORD_W-1:0] inverse_wdata;
  logic          [     WORD_W-1:0] inverse_rdata;
  logic                            t0_we;
  logic                            t0_re;
  logic          [WORD_ADDR_W-1:0] t0_addr;
  logic          [     WORD_W-1:0] t0_wdata;
  logic          [     WORD_W-1:0] t0_rdata;
  logic                            r2_we;
  logic                            r2_re;
  logic          [WORD_ADDR_W-1:0] r2_addr;
  logic          [     WORD_W-1:0] r2_wdata;
  logic          [     WORD_W-1:0] r2_rdata;

  logic                            mul_start;
  logic                            mul_sparse_mode;
  logic                            mul_a_valid;
  logic          [     WORD_W-1:0] mul_a_data;
  logic                            mul_a_ready;
  logic                            mul_sparse_valid;
  logic          [    INDEX_W-1:0] mul_sparse_index;
  logic                            mul_sparse_ready;
  logic                            mul_b_valid;
  logic          [     WORD_W-1:0] mul_b_data;
  logic                            mul_b_ready;
  logic                            mul_result_valid;
  logic          [     WORD_W-1:0] mul_result_data;
  logic                            mul_result_last;
  logic                            mul_done;

  logic                            inv_start;
  logic                            inv_input_valid;
  logic          [     WORD_W-1:0] inv_input_data;
  logic                            inv_input_ready;
  logic                            inv_result_valid;
  logic          [     WORD_W-1:0] inv_result_data;
  logic                            inv_result_last;
  logic                            inv_done;

  function automatic logic [WORD_W-1:0] support_word(input  logic [1:0] block_index,
                                                     input  logic [WORD_ADDR_W-1:0] word_index);
    logic   [WORD_W-1:0] value;
    integer              coefficient;
    begin
      value = '0;
      for (int position = 0; position < SECRET_WEIGHT; position++) begin
        coefficient = int'(support_q[block_index][position]);
        if ((coefficient / WORD_W) == int'(word_index)) begin
          value[coefficient%WORD_W] = 1'b1;
        end
      end
      support_word = value;
    end
  endfunction

  assign o_support_ready = state_q == ST_IDLE;
  assign o_vector_ready = state_q == ST_IDLE;
  assign o_busy = state_q != ST_IDLE;

  assign mul_start = state_q == ST_MUL_START;
  assign mul_sparse_mode = operation_q == OP_MUL_H0_R1;
  assign mul_a_valid = read_data_valid_q && (read_operand_q == READ_OPERAND_MUL_A);
  assign mul_a_data = read_data_q;
  assign mul_b_valid = read_data_valid_q && (read_operand_q == READ_OPERAND_MUL_B);
  assign mul_b_data = read_data_q;
  assign mul_sparse_valid = (state_q == ST_MUL_RUN) &&
                            (operation_q == OP_MUL_H0_R1) &&
                            (sparse_position_q < SECRET_WEIGHT);
  assign mul_sparse_index = support_q[0][POSITION_W'(sparse_position_q)];

  assign inv_start = state_q == ST_INV_START;
  assign inv_input_valid = read_data_valid_q && (read_operand_q == READ_OPERAND_INV);
  assign inv_input_data = read_data_q;

  assign o_result_valid = state_q == ST_OUTPUT_VALID;
  assign o_result_select = output_select_q;
  assign o_result_word = WORD_ADDR_W'(output_word_q);
  assign o_result_data = output_select_q ? r2_rdata : t0_rdata;
  assign o_result_last = output_word_q == (WORDS - 1);

  /* verilator lint_off PINCONNECTEMPTY */
  trike_poly_mul_core #(
      .R_BITS       (R_BITS),
      .WORD_W       (WORD_W),
      .DIGIT_W      (DIGIT_W),
      .SPARSE_WEIGHT(SECRET_WEIGHT)
  ) u_mul (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_start             (mul_start),
      .i_sparse_a          (mul_sparse_mode),
      .i_a_valid           (mul_a_valid),
      .i_a_data            (mul_a_data),
      .o_a_ready           (mul_a_ready),
      .i_sparse_index_valid(mul_sparse_valid),
      .i_sparse_index      (mul_sparse_index),
      .o_sparse_index_ready(mul_sparse_ready),
      .i_b_valid           (mul_b_valid),
      .i_b_data            (mul_b_data),
      .o_b_ready           (mul_b_ready),
      .o_result_valid      (mul_result_valid),
      .o_result_data       (mul_result_data),
      .o_result_last       (mul_result_last),
      .i_result_ready      (1'b1),
      .o_ext_a_re          (),
      .o_ext_a_raddr       (),
      .i_ext_a_rdata       ('0),
      .o_ext_b_re          (),
      .o_ext_b_raddr       (),
      .i_ext_b_rdata       ('0),
      .o_ext_result_we     (),
      .o_ext_result_waddr  (),
      .o_ext_result_wdata  (),
      .o_busy              (),
      .o_done              (mul_done)
  );

  trike_poly_inv_core #(
      .R_BITS (R_BITS),
      .WORD_W (WORD_W),
      .DIGIT_W(DIGIT_W)
  ) u_inv (
      .i_clk         (i_clk),
      .i_rst_n       (i_rst_n),
      .i_start       (inv_start),
      .i_input_valid (inv_input_valid),
      .i_input_data  (inv_input_data),
      .o_input_ready (inv_input_ready),
      .o_result_valid(inv_result_valid),
      .o_result_data (inv_result_data),
      .o_result_last (inv_result_last),
      .i_result_ready(1'b1),
      .o_busy        (),
      .o_done        (inv_done)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t1_mem (
      .i_clk(i_clk),
      .i_we(t1_we),
      .i_waddr(t1_addr),
      .i_wdata(t1_wdata),
      .i_re(t1_re),
      .i_raddr(t1_addr),
      .o_rdata(t1_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t2_mem (
      .i_clk(i_clk),
      .i_we(t2_we),
      .i_waddr(t2_addr),
      .i_wdata(t2_wdata),
      .i_re(t2_re),
      .i_raddr(t2_addr),
      .o_rdata(t2_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_r1_mem (
      .i_clk(i_clk),
      .i_we(r1_we),
      .i_waddr(r1_addr),
      .i_wdata(r1_wdata),
      .i_re(r1_re),
      .i_raddr(r1_addr),
      .o_rdata(r1_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_numerator_mem (
      .i_clk(i_clk),
      .i_we(numerator_we),
      .i_waddr(numerator_addr),
      .i_wdata(numerator_wdata),
      .i_re(numerator_re),
      .i_raddr(numerator_addr),
      .o_rdata(numerator_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_inverse_mem (
      .i_clk(i_clk),
      .i_we(inverse_we),
      .i_waddr(inverse_addr),
      .i_wdata(inverse_wdata),
      .i_re(inverse_re),
      .i_raddr(inverse_addr),
      .o_rdata(inverse_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t0_mem (
      .i_clk(i_clk),
      .i_we(t0_we),
      .i_waddr(t0_addr),
      .i_wdata(t0_wdata),
      .i_re(t0_re),
      .i_raddr(t0_addr),
      .o_rdata(t0_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_r2_mem (
      .i_clk(i_clk),
      .i_we(r2_we),
      .i_waddr(r2_addr),
      .i_wdata(r2_wdata),
      .i_re(r2_re),
      .i_raddr(r2_addr),
      .o_rdata(r2_rdata)
  );

  always_comb begin
    read_issue_c = 1'b0;
    read_issue_source_c = READ_NONE;
    read_issue_operand_c = READ_OPERAND_NONE;
    read_issue_addr_c = '0;

    if (!read_pending_q && !read_data_valid_q) begin
      if (state_q == ST_MUL_RUN) begin
        if (mul_a_ready && (mul_a_request_q < WORDS)) begin
          read_issue_c = 1'b1;
          read_issue_operand_c = READ_OPERAND_MUL_A;
          read_issue_addr_c = WORD_ADDR_W'(mul_a_request_q);
          unique case (operation_q)
            OP_MUL_T0: read_issue_source_c = READ_NUMERATOR;
            OP_MUL_T0_T2: read_issue_source_c = READ_T0;
            default: read_issue_source_c = READ_NUMERATOR;
          endcase
        end else if (mul_b_ready && (mul_b_request_q < WORDS)) begin
          read_issue_c = 1'b1;
          read_issue_operand_c = READ_OPERAND_MUL_B;
          read_issue_addr_c = WORD_ADDR_W'(mul_b_request_q);
          unique case (operation_q)
            OP_MUL_H0_R1: read_issue_source_c = READ_R1;
            OP_MUL_T0: read_issue_source_c = READ_INVERSE;
            OP_MUL_T0_T2: read_issue_source_c = READ_T2;
            default: read_issue_source_c = READ_INVERSE;
          endcase
        end
      end else if ((state_q == ST_INV_RUN) && inv_input_ready && (inv_request_q < WORDS)) begin
        read_issue_c = 1'b1;
        read_issue_operand_c = READ_OPERAND_INV;
        read_issue_addr_c = WORD_ADDR_W'(inv_request_q);
        read_issue_source_c = (operation_q == OP_INV_T0_DEN) ?
            READ_DENOMINATOR1 : READ_DENOMINATOR2;
      end
    end
  end

  always_comb begin
    read_capture_data_c = '0;
    unique case (read_source_q)
      READ_R1: read_capture_data_c = r1_rdata;
      READ_NUMERATOR: read_capture_data_c = numerator_rdata;
      READ_INVERSE: read_capture_data_c = inverse_rdata;
      READ_T0: read_capture_data_c = t0_rdata;
      READ_T2: read_capture_data_c = t2_rdata;
      READ_DENOMINATOR1: read_capture_data_c = t1_rdata ^ r1_rdata;
      READ_DENOMINATOR2: read_capture_data_c = t0_rdata ^ support_word(2'd0, read_addr_q);
      default: read_capture_data_c = '0;
    endcase
  end

  always_comb begin
    t1_we = 1'b0;
    t1_re = 1'b0;
    t1_addr = '0;
    t1_wdata = i_vector_data;
    t2_we = 1'b0;
    t2_re = 1'b0;
    t2_addr = '0;
    t2_wdata = i_vector_data;
    r1_we = 1'b0;
    r1_re = 1'b0;
    r1_addr = '0;
    r1_wdata = i_vector_data;
    numerator_we = 1'b0;
    numerator_re = 1'b0;
    numerator_addr = '0;
    numerator_wdata = '0;
    inverse_we = 1'b0;
    inverse_re = 1'b0;
    inverse_addr = '0;
    inverse_wdata = inv_result_data;
    t0_we = 1'b0;
    t0_re = 1'b0;
    t0_addr = '0;
    t0_wdata = mul_result_data;
    r2_we = 1'b0;
    r2_re = 1'b0;
    r2_addr = '0;
    r2_wdata = mul_result_data;

    if ((state_q == ST_IDLE) && i_vector_valid) begin
      unique case (i_vector_select)
        2'd0: begin
          t1_we   = 1'b1;
          t1_addr = i_vector_word;
        end
        2'd1: begin
          t2_we   = 1'b1;
          t2_addr = i_vector_word;
        end
        default: begin
          r1_we   = 1'b1;
          r1_addr = i_vector_word;
        end
      endcase
    end

    if (read_issue_c) begin
      unique case (read_issue_source_c)
        READ_R1: begin
          r1_re   = 1'b1;
          r1_addr = read_issue_addr_c;
        end
        READ_NUMERATOR: begin
          numerator_re   = 1'b1;
          numerator_addr = read_issue_addr_c;
        end
        READ_INVERSE: begin
          inverse_re   = 1'b1;
          inverse_addr = read_issue_addr_c;
        end
        READ_T0: begin
          t0_re   = 1'b1;
          t0_addr = read_issue_addr_c;
        end
        READ_T2: begin
          t2_re   = 1'b1;
          t2_addr = read_issue_addr_c;
        end
        READ_DENOMINATOR1: begin
          t1_re   = 1'b1;
          t1_addr = read_issue_addr_c;
          r1_re   = 1'b1;
          r1_addr = read_issue_addr_c;
        end
        READ_DENOMINATOR2: begin
          t0_re   = 1'b1;
          t0_addr = read_issue_addr_c;
        end
        default: begin
        end
      endcase
    end

    if (mul_result_valid) begin
      unique case (operation_q)
        OP_MUL_H0_R1: begin
          numerator_we = 1'b1;
          numerator_addr = WORD_ADDR_W'(mul_result_word_q);
          numerator_wdata = mul_result_data ^ support_word(2'd1, WORD_ADDR_W'(mul_result_word_q));
        end
        OP_MUL_T0: begin
          t0_we   = 1'b1;
          t0_addr = WORD_ADDR_W'(mul_result_word_q);
        end
        OP_MUL_T0_T2: begin
          numerator_we = 1'b1;
          numerator_addr = WORD_ADDR_W'(mul_result_word_q);
          numerator_wdata = mul_result_data ^ support_word(2'd2, WORD_ADDR_W'(mul_result_word_q));
        end
        default: begin
          r2_we   = 1'b1;
          r2_addr = WORD_ADDR_W'(mul_result_word_q);
        end
      endcase
    end

    if (inv_result_valid) begin
      inverse_we   = 1'b1;
      inverse_addr = WORD_ADDR_W'(inv_result_word_q);
    end

    if (state_q == ST_OUTPUT_FETCH) begin
      if (output_select_q) begin
        r2_re   = 1'b1;
        r2_addr = WORD_ADDR_W'(output_word_q);
      end else begin
        t0_re   = 1'b1;
        t0_addr = WORD_ADDR_W'(output_word_q);
      end
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      operation_q <= OP_MUL_H0_R1;
      mul_a_request_q <= 0;
      mul_b_request_q <= 0;
      inv_request_q <= 0;
      sparse_position_q <= 0;
      mul_result_word_q <= 0;
      inv_result_word_q <= 0;
      read_pending_q <= 1'b0;
      read_data_valid_q <= 1'b0;
      read_source_q <= READ_NONE;
      read_operand_q <= READ_OPERAND_NONE;
      read_addr_q <= '0;
      read_data_q <= '0;
      output_select_q <= 1'b0;
      output_word_q <= 0;
      o_done <= 1'b0;
      for (int block = 0; block < 3; block++) begin
        for (int position = 0; position < SECRET_WEIGHT; position++) begin
          support_q[block][position] <= '0;
        end
      end
    end else begin
      o_done <= 1'b0;

      if (i_support_valid && o_support_ready) begin
        support_q[i_support_block][i_support_position] <= i_support_index;
      end

      if (read_issue_c) begin
        read_pending_q <= 1'b1;
        read_source_q <= read_issue_source_c;
        read_operand_q <= read_issue_operand_c;
        read_addr_q <= read_issue_addr_c;
        if (read_issue_operand_c == READ_OPERAND_MUL_A) begin
          mul_a_request_q <= mul_a_request_q + 1;
        end else if (read_issue_operand_c == READ_OPERAND_MUL_B) begin
          mul_b_request_q <= mul_b_request_q + 1;
        end else begin
          inv_request_q <= inv_request_q + 1;
        end
      end
      if (read_pending_q) begin
        read_pending_q <= 1'b0;
        read_data_valid_q <= 1'b1;
        read_data_q <= read_capture_data_c;
      end
      if ((mul_a_valid && mul_a_ready) || (mul_b_valid && mul_b_ready) ||
          (inv_input_valid && inv_input_ready)) begin
        read_data_valid_q <= 1'b0;
      end

      if (mul_sparse_valid && mul_sparse_ready) sparse_position_q <= sparse_position_q + 1;
      if (mul_result_valid) mul_result_word_q <= mul_result_word_q + 1;
      if (inv_result_valid) inv_result_word_q <= inv_result_word_q + 1;

`ifndef SYNTHESIS
      if (mul_result_valid && (mul_result_last != (mul_result_word_q == (WORDS - 1)))) begin
        $error("trike_keygen_arith_core multiplier result framing mismatch");
      end
      if (inv_result_valid && (inv_result_last != (inv_result_word_q == (WORDS - 1)))) begin
        $error("trike_keygen_arith_core inverter result framing mismatch");
      end
`endif

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            operation_q <= OP_MUL_H0_R1;
            state_q <= ST_MUL_START;
          end
        end

        ST_MUL_START: begin
          mul_a_request_q <= 0;
          mul_b_request_q <= 0;
          sparse_position_q <= 0;
          mul_result_word_q <= 0;
          read_pending_q <= 1'b0;
          read_data_valid_q <= 1'b0;
          state_q <= ST_MUL_RUN;
        end

        ST_MUL_RUN: begin
          if (mul_done) begin
            unique case (operation_q)
              OP_MUL_H0_R1: begin
                operation_q <= OP_INV_T0_DEN;
                state_q <= ST_INV_START;
              end
              OP_MUL_T0: begin
                operation_q <= OP_INV_R2_DEN;
                state_q <= ST_INV_START;
              end
              OP_MUL_T0_T2: begin
                operation_q <= OP_MUL_R2;
                state_q <= ST_MUL_START;
              end
              default: begin
                output_select_q <= 1'b0;
                output_word_q <= 0;
                state_q <= ST_OUTPUT_FETCH;
              end
            endcase
          end
        end

        ST_INV_START: begin
          inv_request_q <= 0;
          inv_result_word_q <= 0;
          read_pending_q <= 1'b0;
          read_data_valid_q <= 1'b0;
          state_q <= ST_INV_RUN;
        end

        ST_INV_RUN: begin
          if (inv_done) begin
            if (operation_q == OP_INV_T0_DEN) begin
              operation_q <= OP_MUL_T0;
            end else begin
              operation_q <= OP_MUL_T0_T2;
            end
            state_q <= ST_MUL_START;
          end
        end

        ST_OUTPUT_FETCH: begin
          state_q <= ST_OUTPUT_VALID;
        end

        ST_OUTPUT_VALID: begin
          if (i_result_ready) begin
            if (output_word_q == (WORDS - 1)) begin
              output_word_q <= 0;
              if (output_select_q) begin
                o_done  <= 1'b1;
                state_q <= ST_IDLE;
              end else begin
                output_select_q <= 1'b1;
                state_q <= ST_OUTPUT_FETCH;
              end
            end else begin
              output_word_q <= output_word_q + 1;
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
    if (R_BITS < 3) $error("trike_keygen_arith_core R_BITS must be at least 3");
    if (SECRET_WEIGHT < 1) begin
      $error("trike_keygen_arith_core SECRET_WEIGHT must be at least 1");
    end
    if (SECRET_WEIGHT > R_BITS) begin
      $error("trike_keygen_arith_core SECRET_WEIGHT must not exceed R_BITS");
    end
  end
`endif

endmodule
