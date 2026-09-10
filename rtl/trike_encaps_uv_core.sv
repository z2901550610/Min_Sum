`timescale 1ns / 1ps
// Fixed-schedule dense Encaps UV. Read padded e0/e1/e2 bytes from the existing
// synchronous error store. Initialize U/V with e0, then XOR four dense products.
module trike_encaps_uv_core #(
    parameter int R_BITS = 15581,
    parameter int WORD_W = 64,
    parameter int PADDED_R_BYTES = ((R_BITS + 511) / 512) * 64,
    parameter int ERROR_ADDR_W = $clog2(3 * PADDED_R_BYTES),
    parameter bit USE_EXTERNAL_MUL = 1'b0,
    parameter bit USE_EXTERNAL_UV_STORE = 1'b0,
    parameter int MUL_INDEX_W = ((R_BITS > 1) ? $clog2(R_BITS) : 1),
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    input  logic                    i_start,
    output logic                    o_error_re,
    output logic [ERROR_ADDR_W-1:0] o_error_raddr,
    input  logic [             7:0] i_error_rdata,
    output logic [             1:0] o_operand_select,
    output logic [ WORD_ADDR_W-1:0] o_operand_word,
    input  logic                    i_operand_valid,
    input  logic [      WORD_W-1:0] i_operand_data,
    output logic                    o_operand_ready,
    output logic                    o_result_valid,
    output logic                    o_result_select,
    output logic [      WORD_W-1:0] o_result_data,
    output logic                    o_result_last,
    input  logic                    i_result_ready,
    output logic                    o_busy,
    output logic                    o_done,
    output logic                    o_mul_start,
    output logic [            31:0] o_mul_runtime_r_bits,
    output logic [            31:0] o_mul_runtime_words,
    output logic [            31:0] o_mul_runtime_sparse_weight,
    output logic                    o_mul_sparse_a,
    output logic                    o_mul_a_valid,
    output logic [      WORD_W-1:0] o_mul_a_data,
    input  logic                    i_mul_a_ready,
    output logic                    o_mul_sparse_index_valid,
    output logic [ MUL_INDEX_W-1:0] o_mul_sparse_index,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic                    i_mul_sparse_index_ready,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic                    o_mul_b_valid,
    output logic [      WORD_W-1:0] o_mul_b_data,
    input  logic                    i_mul_b_ready,
    input  logic                    i_mul_result_valid,
    input  logic [      WORD_W-1:0] i_mul_result_data,
    input  logic                    i_mul_result_last,
    output logic                    o_mul_result_ready,
    output logic                    o_store_u_we,
    output logic [ WORD_ADDR_W-1:0] o_store_u_waddr,
    output logic [      WORD_W-1:0] o_store_u_wdata,
    output logic                    o_store_u_re,
    output logic [ WORD_ADDR_W-1:0] o_store_u_raddr,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [      WORD_W-1:0] i_store_u_rdata,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic                    o_store_v_we,
    output logic [ WORD_ADDR_W-1:0] o_store_v_waddr,
    output logic [      WORD_W-1:0] o_store_v_wdata,
    output logic                    o_store_v_re,
    output logic [ WORD_ADDR_W-1:0] o_store_v_raddr,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [      WORD_W-1:0] i_store_v_rdata
    /* verilator lint_on UNUSEDSIGNAL */
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int WORD_BYTES = WORD_W / 8;
  localparam int LAST_BITS = R_BITS - (WORDS - 1) * WORD_W;
  localparam logic [WORD_W-1:0] LAST_MASK = {WORD_W{1'b1}} >> (WORD_W - LAST_BITS);
  typedef enum logic [3:0] {
    ST_IDLE,
    ST_ERROR_READ,
    ST_ERROR_CAPTURE,
    ST_ERROR_EMIT,
    ST_START_MUL,
    ST_DRAIN_MUL,
    ST_LOAD_OPERAND,
    ST_PRODUCT_READ,
    ST_PRODUCT_WRITE,
    ST_OUTPUT_FETCH,
    ST_OUTPUT_VALID
  } state_t;
  state_t state_q;
  integer error_word_q, error_byte_q, operand_word_q, product_word_q, output_word_q;
  logic       init_e0_q;
  logic [1:0] mul_select_q;
  logic       output_select_q;
  logic [WORD_W-1:0] packed_word_q, packed_word_c, combined_product_c;
  logic mul_start, mul_a_ready, mul_b_ready, mul_result_valid, mul_result_last, mul_result_ready;
  logic [WORD_W-1:0] mul_result_data;
  logic u_we, u_re, v_we, v_re;
  logic [WORD_ADDR_W-1:0] u_waddr, u_raddr, v_waddr, v_raddr;
  logic [WORD_W-1:0] u_wdata, u_rdata, v_wdata, v_rdata;
  integer error_block_c;
  assign error_block_c = init_e0_q ? 0 : (mul_select_q[0] ? 2 : 1);
  assign o_error_re = state_q == ST_ERROR_READ;
  assign o_error_raddr = ERROR_ADDR_W'(error_block_c * PADDED_R_BYTES + error_word_q * WORD_BYTES + error_byte_q);
  assign packed_word_c = error_word_q == WORDS - 1 ? packed_word_q & LAST_MASK : packed_word_q;
  assign o_mul_start = mul_start;
  assign o_mul_runtime_r_bits = 32'(R_BITS);
  assign o_mul_runtime_words = 32'(WORDS);
  assign o_mul_runtime_sparse_weight = 32'd1;
  assign o_mul_sparse_a = 1'b0;
  assign o_mul_a_valid = state_q == ST_ERROR_EMIT && !init_e0_q;
  assign o_mul_a_data = packed_word_c;
  assign o_mul_sparse_index_valid = 1'b0;
  assign o_mul_sparse_index = '0;
  assign o_mul_b_valid = i_operand_valid && state_q == ST_LOAD_OPERAND;
  assign o_mul_b_data = i_operand_data;
  assign o_mul_result_ready = mul_result_ready;
  assign o_store_u_we = u_we;
  assign o_store_u_waddr = u_waddr;
  assign o_store_u_wdata = u_wdata;
  assign o_store_u_re = u_re;
  assign o_store_u_raddr = u_raddr;
  assign o_store_v_we = v_we;
  assign o_store_v_waddr = v_waddr;
  assign o_store_v_wdata = v_wdata;
  assign o_store_v_re = v_re;
  assign o_store_v_raddr = v_raddr;

  generate
    if (USE_EXTERNAL_UV_STORE) begin : gen_external_uv_store
      assign u_rdata = i_store_u_rdata;
      assign v_rdata = i_store_v_rdata;
    end else begin : gen_local_uv_store
      ram_bram #(
          .DATA_W(WORD_W),
          .DEPTH (WORDS)
      ) u_u_mem (
          .i_clk  (i_clk),
          .i_we   (u_we),
          .i_waddr(u_waddr),
          .i_wdata(u_wdata),
          .i_re   (u_re),
          .i_raddr(u_raddr),
          .o_rdata(u_rdata)
      );

      ram_bram #(
          .DATA_W(WORD_W),
          .DEPTH (WORDS)
      ) u_v_mem (
          .i_clk  (i_clk),
          .i_we   (v_we),
          .i_waddr(v_waddr),
          .i_wdata(v_wdata),
          .i_re   (v_re),
          .i_raddr(v_raddr),
          .o_rdata(v_rdata)
      );
    end
  endgenerate

  /* verilator lint_off PINCONNECTEMPTY */
  generate
    if (USE_EXTERNAL_MUL) begin : gen_external_mul
      assign mul_a_ready = i_mul_a_ready;
      assign mul_b_ready = i_mul_b_ready;
      assign mul_result_valid = i_mul_result_valid;
      assign mul_result_data = i_mul_result_data;
      assign mul_result_last = i_mul_result_last;
    end else begin : gen_local_mul
      trike_poly_mul_core #(
          .R_BITS(R_BITS),
          .WORD_W(WORD_W),

          .SPARSE_WEIGHT(1)
      ) u_mul (
          .i_clk                  (i_clk),
          .i_rst_n                (i_rst_n),
          .i_start                (mul_start),
          .i_runtime_r_bits       ('0),
          .i_runtime_words        ('0),
          .i_runtime_sparse_weight('0),
          .i_sparse_a             (1'b0),
          .i_a_valid              (o_mul_a_valid),
          .i_a_data               (packed_word_c),
          .o_a_ready              (mul_a_ready),
          .i_sparse_index_valid   (1'b0),
          .i_sparse_index         ('0),
          .o_sparse_index_ready   (),
          .i_b_valid              (i_operand_valid && (state_q == ST_LOAD_OPERAND)),
          .i_b_data               (i_operand_data),
          .o_b_ready              (mul_b_ready),
          .o_result_valid         (mul_result_valid),
          .o_result_data          (mul_result_data),
          .o_result_last          (mul_result_last),
          .i_result_ready         (mul_result_ready),

          .o_busy(),
          .o_done()
      );
    end
  endgenerate
  /* verilator lint_on PINCONNECTEMPTY */

  always_comb begin
    u_we = 1'b0;
    v_we = 1'b0;
    u_re = 1'b0;
    v_re = 1'b0;
    u_waddr = WORD_ADDR_W'(product_word_q);
    v_waddr = WORD_ADDR_W'(product_word_q);
    u_raddr = WORD_ADDR_W'(product_word_q);
    v_raddr = WORD_ADDR_W'(product_word_q);
    combined_product_c = mul_result_data ^ (mul_select_q[1] ? v_rdata : u_rdata);
    if (product_word_q == WORDS - 1) combined_product_c &= LAST_MASK;
    u_wdata = combined_product_c;
    v_wdata = combined_product_c;
    mul_start = state_q == ST_START_MUL;
    mul_result_ready = state_q == ST_PRODUCT_WRITE;
    o_operand_select = mul_select_q;
    o_operand_word = WORD_ADDR_W'(operand_word_q);
    o_operand_ready = state_q == ST_LOAD_OPERAND && mul_b_ready;
    o_result_valid = state_q == ST_OUTPUT_VALID;
    o_result_select = output_select_q;
    o_result_data = output_select_q ? v_rdata : u_rdata;
    o_result_last = output_word_q == WORDS - 1;
    o_busy = state_q != ST_IDLE;
    case (state_q)
      ST_ERROR_EMIT:
      if (init_e0_q) begin
        u_we = 1'b1;
        v_we = 1'b1;
        u_waddr = WORD_ADDR_W'(error_word_q);
        v_waddr = WORD_ADDR_W'(error_word_q);
        u_wdata = packed_word_c;
        v_wdata = packed_word_c;
      end
      ST_PRODUCT_READ: begin
        u_re = mul_result_valid && !mul_select_q[1];
        v_re = mul_result_valid && mul_select_q[1];
      end
      ST_PRODUCT_WRITE: begin
        u_we = mul_result_valid && !mul_select_q[1];
        v_we = mul_result_valid && mul_select_q[1];
      end
      ST_OUTPUT_FETCH: begin
        u_re = !output_select_q;
        v_re = output_select_q;
        u_raddr = WORD_ADDR_W'(output_word_q);
        v_raddr = WORD_ADDR_W'(output_word_q);
      end
      default: begin
      end
    endcase
  end
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      error_word_q <= 0;
      error_byte_q <= 0;
      operand_word_q <= 0;
      product_word_q <= 0;
      output_word_q <= 0;
      init_e0_q <= 1'b0;
      mul_select_q <= '0;
      output_select_q <= 1'b0;
      packed_word_q <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;
      case (state_q)
        ST_IDLE:
        if (i_start) begin
          init_e0_q <= 1'b1;
          error_word_q <= 0;
          error_byte_q <= 0;
          packed_word_q <= '0;
          mul_select_q <= 0;
          state_q <= ST_ERROR_READ;
        end
        ST_ERROR_READ: state_q <= ST_ERROR_CAPTURE;
        ST_ERROR_CAPTURE: begin
          packed_word_q[8*error_byte_q+:8] <= i_error_rdata;
          if (error_byte_q == WORD_BYTES - 1) state_q <= ST_ERROR_EMIT;
          else begin
            error_byte_q <= error_byte_q + 1;
            state_q <= ST_ERROR_READ;
          end
        end
        ST_ERROR_EMIT:
        if (init_e0_q || mul_a_ready) begin
          error_byte_q <= 0;
          if (error_word_q == WORDS - 1) begin
            error_word_q <= 0;
            if (init_e0_q) begin
              init_e0_q <= 1'b0;
              state_q   <= ST_START_MUL;
            end else begin
              operand_word_q <= 0;
              state_q <= ST_LOAD_OPERAND;
            end
          end else begin
            error_word_q <= error_word_q + 1;
            state_q <= ST_ERROR_READ;
          end
        end
        ST_START_MUL: begin
          error_word_q <= 0;
          error_byte_q <= 0;
          state_q <= ST_ERROR_READ;
        end
        // The shared dense wrapper retires one cycle after its last output.
        ST_DRAIN_MUL: state_q <= ST_START_MUL;
        ST_LOAD_OPERAND:
        if (i_operand_valid && mul_b_ready) begin
          if (operand_word_q == WORDS - 1) begin
            product_word_q <= 0;
            state_q <= ST_PRODUCT_READ;
          end else operand_word_q <= operand_word_q + 1;
        end
        ST_PRODUCT_READ: if (mul_result_valid) state_q <= ST_PRODUCT_WRITE;
        ST_PRODUCT_WRITE:
        if (mul_result_valid) begin
          if (mul_result_last) begin
            if (mul_select_q == 3) begin
              output_select_q <= 1'b0;
              output_word_q <= 0;
              state_q <= ST_OUTPUT_FETCH;
            end else begin
              mul_select_q <= mul_select_q + 1'b1;
              state_q <= ST_DRAIN_MUL;
            end
          end else begin
            product_word_q <= product_word_q + 1;
            state_q <= ST_PRODUCT_READ;
          end
        end
        ST_OUTPUT_FETCH: state_q <= ST_OUTPUT_VALID;
        ST_OUTPUT_VALID:
        if (i_result_ready) begin
          if (output_word_q == WORDS - 1) begin
            if (!output_select_q) begin
              output_select_q <= 1'b1;
              output_word_q <= 0;
              state_q <= ST_OUTPUT_FETCH;
            end else begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end
          end else begin
            output_word_q <= output_word_q + 1;
            state_q <= ST_OUTPUT_FETCH;
          end
        end
        default: state_q <= ST_IDLE;
      endcase
    end
  end
`ifndef SYNTHESIS
  initial begin
    if (R_BITS < 2 || WORD_W < 8 || WORD_W % 8 != 0 || PADDED_R_BYTES < WORDS * WORD_BYTES)
      $error("trike_encaps_uv_core invalid byte/word geometry");
  end
`endif
endmodule
