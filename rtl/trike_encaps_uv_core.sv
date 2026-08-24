`timescale 1ns / 1ps

// Fixed-schedule Encaps u/v calculation.
//
// The ERROR_WEIGHT global support indices cover e0 || e1 || e2 in [0,3R).
// One sparse multiplier is reused for, in order:
//   e1*r1, e2*r2, e1*t1, e2*t2.
// Every multiplication receives exactly ERROR_WEIGHT indices. Indices outside
// the selected block are converted to the out-of-range value R_BITS, which the
// multiplier executes as a zero-contribution dummy with the same RAM schedule.
module trike_encaps_uv_core #(
    parameter int R_BITS = 15581,
    parameter int WORD_W = 64,
    parameter int ERROR_WEIGHT = 263,
    parameter bit USE_EXTERNAL_MUL = 1'b0,
    parameter int MUL_INDEX_W = ((R_BITS > 1) ? $clog2(R_BITS) : 1),
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic                                                       i_clk,
    input  logic                                                       i_rst_n,
    input  logic                                                       i_start,
    input  logic                                                       i_error_valid,
    input  logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] i_error_position,
    input  logic [  (((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] i_error_index,
    output logic                                                       o_error_ready,
    output logic [                                                1:0] o_operand_select,
    output logic [                                    WORD_ADDR_W-1:0] o_operand_word,
    input  logic                                                       i_operand_valid,
    input  logic [                                         WORD_W-1:0] i_operand_data,
    output logic                                                       o_operand_ready,
    output logic                                                       o_result_valid,
    output logic                                                       o_result_select,
    output logic [                                         WORD_W-1:0] o_result_data,
    output logic                                                       o_result_last,
    input  logic                                                       i_result_ready,
    output logic                                                       o_busy,
    output logic                                                       o_done,
    output logic                                                       o_mul_start,
    output logic [                                               31:0] o_mul_runtime_r_bits,
    output logic [                                               31:0] o_mul_runtime_words,
    output logic [                                               31:0] o_mul_runtime_sparse_weight,
    output logic                                                       o_mul_sparse_a,
    output logic                                                       o_mul_a_valid,
    output logic [                                         WORD_W-1:0] o_mul_a_data,
    input  logic                                                       i_mul_a_ready,
    output logic                                                       o_mul_sparse_index_valid,
    output logic [                                    MUL_INDEX_W-1:0] o_mul_sparse_index,
    input  logic                                                       i_mul_sparse_index_ready,
    output logic                                                       o_mul_b_valid,
    output logic [                                         WORD_W-1:0] o_mul_b_data,
    input  logic                                                       i_mul_b_ready,
    input  logic                                                       i_mul_result_valid,
    input  logic [                                         WORD_W-1:0] i_mul_result_data,
    input  logic                                                       i_mul_result_last,
    output logic                                                       o_mul_result_ready
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int LAST_BITS = R_BITS - ((WORDS - 1) * WORD_W);
  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int GLOBAL_INDEX_W = ((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1;
  localparam int ERROR_ADDR_W = (ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1;
  localparam logic [WORD_W-1:0] LAST_MASK = {WORD_W{1'b1}} >> (WORD_W - LAST_BITS);
  localparam logic [INDEX_W-1:0] DUMMY_INDEX = INDEX_W'(R_BITS);

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_CLEAR_E0,
    ST_LOAD_ERROR_READ,
    ST_LOAD_ERROR_WRITE,
    ST_START_MUL,
    ST_REPLAY_SUPPORT,
    ST_LOAD_OPERAND,
    ST_PRODUCT_READ,
    ST_PRODUCT_WRITE,
    ST_OUTPUT_FETCH,
    ST_OUTPUT_VALID
  } state_t;

  state_t                      state_q;
  integer                      clear_word_q;
  integer                      error_count_q;
  integer                      replay_count_q;
  integer                      operand_word_q;
  integer                      product_word_q;
  integer                      output_word_q;
  logic   [               1:0] mul_select_q;
  logic                        output_select_q;
  logic   [GLOBAL_INDEX_W-1:0] error_index_q;

  logic                        support_we;
  logic   [  ERROR_ADDR_W-1:0] support_waddr;
  logic   [GLOBAL_INDEX_W-1:0] support_wdata;
  logic                        support_re;
  logic   [  ERROR_ADDR_W-1:0] support_raddr;
  logic   [GLOBAL_INDEX_W-1:0] support_rdata;

  logic                        e0_we;
  logic   [   WORD_ADDR_W-1:0] e0_waddr;
  logic   [        WORD_W-1:0] e0_wdata;
  logic                        e0_re;
  logic   [   WORD_ADDR_W-1:0] e0_raddr;
  logic   [        WORD_W-1:0] e0_rdata;

  logic                        u_we;
  logic   [   WORD_ADDR_W-1:0] u_waddr;
  logic   [        WORD_W-1:0] u_wdata;
  logic                        u_re;
  logic   [   WORD_ADDR_W-1:0] u_raddr;
  logic   [        WORD_W-1:0] u_rdata;

  logic                        v_we;
  logic   [   WORD_ADDR_W-1:0] v_waddr;
  logic   [        WORD_W-1:0] v_wdata;
  logic                        v_re;
  logic   [   WORD_ADDR_W-1:0] v_raddr;
  logic   [        WORD_W-1:0] v_rdata;

  logic                        mul_start;
  logic                        mul_sparse_index_valid;
  logic   [       INDEX_W-1:0] mul_sparse_index;
  logic                        mul_sparse_index_ready;
  logic                        mul_b_ready;
  logic                        mul_result_valid;
  logic   [        WORD_W-1:0] mul_result_data;
  logic                        mul_result_last;
  logic                        mul_result_ready;

  integer                      selected_block_c;
  integer                      selected_base_c;
  integer                      local_index_c;
  integer                      e0_bit_c;
  logic   [        WORD_W-1:0] combined_product_c;

  ram_bram #(
      .DATA_W(GLOBAL_INDEX_W),
      .DEPTH (ERROR_WEIGHT)
  ) u_support_mem (
      .i_clk  (i_clk),
      .i_we   (support_we),
      .i_waddr(support_waddr),
      .i_wdata(support_wdata),
      .i_re   (support_re),
      .i_raddr(support_raddr),
      .o_rdata(support_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_e0_mem (
      .i_clk  (i_clk),
      .i_we   (e0_we),
      .i_waddr(e0_waddr),
      .i_wdata(e0_wdata),
      .i_re   (e0_re),
      .i_raddr(e0_raddr),
      .o_rdata(e0_rdata)
  );

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

  assign o_mul_start = mul_start;
  assign o_mul_runtime_r_bits = 32'(R_BITS);
  assign o_mul_runtime_words = 32'(WORDS);
  assign o_mul_runtime_sparse_weight = 32'(ERROR_WEIGHT);
  assign o_mul_sparse_a = 1'b1;
  assign o_mul_a_valid = 1'b0;
  assign o_mul_a_data = '0;
  assign o_mul_sparse_index_valid = mul_sparse_index_valid;
  assign o_mul_sparse_index = MUL_INDEX_W'(mul_sparse_index);
  assign o_mul_b_valid = i_operand_valid && (state_q == ST_LOAD_OPERAND);
  assign o_mul_b_data = i_operand_data;
  assign o_mul_result_ready = mul_result_ready;

  /* verilator lint_off PINCONNECTEMPTY */
  generate
    if (USE_EXTERNAL_MUL) begin : gen_external_mul
      assign mul_sparse_index_ready = i_mul_sparse_index_ready;
      assign mul_b_ready = i_mul_b_ready;
      assign mul_result_valid = i_mul_result_valid;
      assign mul_result_data = i_mul_result_data;
      assign mul_result_last = i_mul_result_last;
    end else begin : gen_local_mul
      trike_poly_mul_core #(
          .R_BITS       (R_BITS),
          .WORD_W       (WORD_W),
          .DIGIT_W      (8),
          .SPARSE_WEIGHT(ERROR_WEIGHT)
      ) u_mul (
          .i_clk                  (i_clk),
          .i_rst_n                (i_rst_n),
          .i_start                (mul_start),
          .i_runtime_r_bits       ('0),
          .i_runtime_words        ('0),
          .i_runtime_sparse_weight('0),
          .i_sparse_a             (1'b1),
          .i_a_valid              (1'b0),
          .i_a_data               ('0),
          .o_a_ready              (),
          .i_sparse_index_valid   (mul_sparse_index_valid),
          .i_sparse_index         (mul_sparse_index),
          .o_sparse_index_ready   (mul_sparse_index_ready),
          .i_b_valid              (i_operand_valid && (state_q == ST_LOAD_OPERAND)),
          .i_b_data               (i_operand_data),
          .o_b_ready              (mul_b_ready),
          .o_result_valid         (mul_result_valid),
          .o_result_data          (mul_result_data),
          .o_result_last          (mul_result_last),
          .i_result_ready         (mul_result_ready),
          .o_ext_a_re             (),
          .o_ext_a_raddr          (),
          .i_ext_a_rdata          ('0),
          .o_ext_b_re             (),
          .o_ext_b_raddr          (),
          .i_ext_b_rdata          ('0),
          .o_ext_result_we        (),
          .o_ext_result_waddr     (),
          .o_ext_result_wdata     (),
          .o_busy                 (),
          .o_done                 ()
      );
    end
  endgenerate
  /* verilator lint_on PINCONNECTEMPTY */

  always_comb begin
    selected_block_c = ((mul_select_q == 2'd0) || (mul_select_q == 2'd2)) ? 1 : 2;
    selected_base_c = selected_block_c * R_BITS;
    local_index_c = R_BITS;
    if ((int'(support_rdata) >= selected_base_c) &&
        (int'(support_rdata) < (selected_base_c + R_BITS))) begin
      local_index_c = int'(support_rdata) - selected_base_c;
    end
    mul_sparse_index = (local_index_c < R_BITS) ? INDEX_W'(local_index_c) : DUMMY_INDEX;

    e0_bit_c = int'(error_index_q) % WORD_W;

    combined_product_c = mul_result_data;
    if ((mul_select_q == 2'd1) || (mul_select_q == 2'd3)) begin
      combined_product_c = mul_result_data ^ e0_rdata;
      if (mul_select_q == 2'd1) begin
        combined_product_c = combined_product_c ^ u_rdata;
      end else begin
        combined_product_c = combined_product_c ^ v_rdata;
      end
    end
    if (product_word_q == (WORDS - 1)) combined_product_c &= LAST_MASK;
  end

  always_comb begin
    support_we = 1'b0;
    support_waddr = '0;
    support_wdata = i_error_index;
    support_re = 1'b0;
    support_raddr = '0;
    e0_we = 1'b0;
    e0_waddr = '0;
    e0_wdata = '0;
    e0_re = 1'b0;
    e0_raddr = '0;
    u_we = 1'b0;
    u_waddr = '0;
    u_wdata = '0;
    u_re = 1'b0;
    u_raddr = '0;
    v_we = 1'b0;
    v_waddr = '0;
    v_wdata = '0;
    v_re = 1'b0;
    v_raddr = '0;

    mul_start = state_q == ST_START_MUL;
    mul_sparse_index_valid = state_q == ST_REPLAY_SUPPORT;
    mul_result_ready = state_q == ST_PRODUCT_WRITE;

    o_error_ready = state_q == ST_LOAD_ERROR_READ;
    o_operand_select = mul_select_q;
    o_operand_word = WORD_ADDR_W'(operand_word_q);
    o_operand_ready = (state_q == ST_LOAD_OPERAND) && mul_b_ready;
    o_result_valid = state_q == ST_OUTPUT_VALID;
    o_result_select = output_select_q;
    o_result_data = output_select_q ? v_rdata : u_rdata;
    o_result_last = output_word_q == (WORDS - 1);
    o_busy = state_q != ST_IDLE;

    unique case (state_q)
      ST_CLEAR_E0: begin
        e0_we = 1'b1;
        e0_waddr = WORD_ADDR_W'(clear_word_q);
      end

      ST_LOAD_ERROR_READ: begin
        if (i_error_valid) begin
          support_we = 1'b1;
          support_waddr = i_error_position;
          if (int'(i_error_index) < R_BITS) begin
            e0_raddr = WORD_ADDR_W'(int'(i_error_index) / WORD_W);
          end
          e0_re = 1'b1;
        end
      end

      ST_LOAD_ERROR_WRITE: begin
        e0_we = 1'b1;
        if (int'(error_index_q) < R_BITS) begin
          e0_waddr = WORD_ADDR_W'(int'(error_index_q) / WORD_W);
          e0_wdata = e0_rdata ^ ({{(WORD_W - 1) {1'b0}}, 1'b1} << e0_bit_c);
        end else begin
          e0_waddr = '0;
          e0_wdata = e0_rdata;
        end
      end

      ST_START_MUL: begin
        support_re = 1'b1;
        support_raddr = '0;
      end

      ST_REPLAY_SUPPORT: begin
        if ((replay_count_q < (ERROR_WEIGHT - 1)) && mul_sparse_index_ready) begin
          support_re = 1'b1;
          support_raddr = ERROR_ADDR_W'(replay_count_q + 1);
        end
      end

      ST_PRODUCT_READ: begin
        e0_re = mul_result_valid;
        e0_raddr = WORD_ADDR_W'(product_word_q);
        if (mul_select_q < 2) begin
          u_re = mul_result_valid;
          u_raddr = WORD_ADDR_W'(product_word_q);
        end else begin
          v_re = mul_result_valid;
          v_raddr = WORD_ADDR_W'(product_word_q);
        end
      end

      ST_PRODUCT_WRITE: begin
        if (mul_select_q < 2) begin
          u_we = 1'b1;
          u_waddr = WORD_ADDR_W'(product_word_q);
          u_wdata = combined_product_c;
        end else begin
          v_we = 1'b1;
          v_waddr = WORD_ADDR_W'(product_word_q);
          v_wdata = combined_product_c;
        end
      end

      ST_OUTPUT_FETCH: begin
        if (output_select_q) begin
          v_re = 1'b1;
          v_raddr = WORD_ADDR_W'(output_word_q);
        end else begin
          u_re = 1'b1;
          u_raddr = WORD_ADDR_W'(output_word_q);
        end
      end

      default: begin
      end
    endcase
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      clear_word_q <= 0;
      error_count_q <= 0;
      replay_count_q <= 0;
      operand_word_q <= 0;
      product_word_q <= 0;
      output_word_q <= 0;
      mul_select_q <= '0;
      output_select_q <= 1'b0;
      error_index_q <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            clear_word_q <= 0;
            error_count_q <= 0;
            state_q <= ST_CLEAR_E0;
          end
        end

        ST_CLEAR_E0: begin
          if (clear_word_q == (WORDS - 1)) begin
            state_q <= ST_LOAD_ERROR_READ;
          end else begin
            clear_word_q <= clear_word_q + 1;
          end
        end

        ST_LOAD_ERROR_READ: begin
          if (i_error_valid) begin
            error_index_q <= i_error_index;
            state_q <= ST_LOAD_ERROR_WRITE;
          end
        end

        ST_LOAD_ERROR_WRITE: begin
          if (error_count_q == (ERROR_WEIGHT - 1)) begin
            mul_select_q <= 0;
            replay_count_q <= 0;
            state_q <= ST_START_MUL;
          end else begin
            error_count_q <= error_count_q + 1;
            state_q <= ST_LOAD_ERROR_READ;
          end
        end

        ST_START_MUL: begin
          replay_count_q <= 0;
          state_q <= ST_REPLAY_SUPPORT;
        end

        ST_REPLAY_SUPPORT: begin
          if (mul_sparse_index_ready) begin
            if (replay_count_q == (ERROR_WEIGHT - 1)) begin
              operand_word_q <= 0;
              state_q <= ST_LOAD_OPERAND;
            end else begin
              replay_count_q <= replay_count_q + 1;
            end
          end
        end

        ST_LOAD_OPERAND: begin
          if (i_operand_valid && mul_b_ready) begin
            if (operand_word_q == (WORDS - 1)) begin
              product_word_q <= 0;
              state_q <= ST_PRODUCT_READ;
            end else begin
              operand_word_q <= operand_word_q + 1;
            end
          end
        end

        ST_PRODUCT_READ: begin
          if (mul_result_valid) state_q <= ST_PRODUCT_WRITE;
        end

        ST_PRODUCT_WRITE: begin
          if (mul_result_valid) begin
            if (mul_result_last) begin
              if (mul_select_q == 2'd3) begin
                output_select_q <= 1'b0;
                output_word_q <= 0;
                state_q <= ST_OUTPUT_FETCH;
              end else begin
                mul_select_q <= mul_select_q + 1'b1;
                state_q <= ST_START_MUL;
              end
            end else begin
              product_word_q <= product_word_q + 1;
              state_q <= ST_PRODUCT_READ;
            end
          end
        end

        ST_OUTPUT_FETCH: begin
          state_q <= ST_OUTPUT_VALID;
        end

        ST_OUTPUT_VALID: begin
          if (i_result_ready) begin
            if (output_word_q == (WORDS - 1)) begin
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
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if ((state_q == ST_REPLAY_SUPPORT) && !mul_sparse_index_ready) begin
      $error("trike_encaps_uv_core unexpected sparse-index backpressure");
    end
    if ((state_q == ST_PRODUCT_WRITE) && !mul_result_valid) begin
      $error("trike_encaps_uv_core multiplier result changed before acceptance");
    end
  end

  initial begin
    if (R_BITS < 2) $error("trike_encaps_uv_core R_BITS must be at least 2");
    if ((R_BITS & (R_BITS - 1)) == 0) begin
      $error("trike_encaps_uv_core requires a representable out-of-range dummy index");
    end
    if (WORD_W < 8) $error("trike_encaps_uv_core WORD_W must be at least 8");
    if ((WORD_W % 8) != 0) $error("trike_encaps_uv_core WORD_W must be divisible by 8");
    if (ERROR_WEIGHT < 1) $error("trike_encaps_uv_core ERROR_WEIGHT must be at least 1");
    if (ERROR_WEIGHT > R_BITS) begin
      $error("trike_encaps_uv_core ERROR_WEIGHT must not exceed R_BITS");
    end
    if (WORD_ADDR_W != ((WORDS > 1) ? $clog2(WORDS) : 1)) begin
      $error("trike_encaps_uv_core WORD_ADDR_W must match WORDS");
    end
  end
`endif

endmodule
