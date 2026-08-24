`timescale 1ns / 1ps

// Fixed-schedule TRIKE Decaps syndrome generation.
//
// The controller loads h0 support, t0, u, and v once, then time-shares one
// polynomial multiplier to evaluate
//
//   syndrome = h0*u + t0*(u+v).
//
// All loop bounds and RAM addresses depend only on public parameters. Input
// and output backpressure may extend the outer transaction, but operand data
// does not alter the accepted word count or internal arithmetic schedule.
module trike_decaps_syndrome_core #(
    parameter int R_BITS = 15581,
    parameter int SECRET_WEIGHT = 35,
    parameter int WORD_W = 64,
    parameter int DIGIT_W = 16,
    parameter bit RUNTIME_GEOMETRY = 1'b0,
    parameter bit USE_EXTERNAL_MUL = 1'b0,
    parameter int MUL_INDEX_W = ((R_BITS > 1) ? $clog2(R_BITS) : 1),
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic                                           i_clk,
    input  logic                                           i_rst_n,
    input  logic                                           i_start,
    input  logic [                                   31:0] i_runtime_r_bits,
    input  logic [                                   31:0] i_runtime_secret_weight,
    input  logic [                                   31:0] i_runtime_words,
    input  logic                                           i_h0_valid,
    input  logic [((R_BITS > 1) ? $clog2(R_BITS) : 1)-1:0] i_h0_index,
    output logic                                           o_h0_ready,
    input  logic                                           i_t0_valid,
    input  logic [                             WORD_W-1:0] i_t0_data,
    output logic                                           o_t0_ready,
    input  logic                                           i_u_valid,
    input  logic [                             WORD_W-1:0] i_u_data,
    output logic                                           o_u_ready,
    input  logic                                           i_v_valid,
    input  logic [                             WORD_W-1:0] i_v_data,
    output logic                                           o_v_ready,
    output logic                                           o_syndrome_valid,
    output logic [                             WORD_W-1:0] o_syndrome_data,
    output logic                                           o_syndrome_last,
    input  logic                                           i_syndrome_ready,
    output logic                                           o_busy,
    output logic                                           o_done,
    output logic                                           o_mul_start,
    output logic [                                   31:0] o_mul_runtime_r_bits,
    output logic [                                   31:0] o_mul_runtime_words,
    output logic [                                   31:0] o_mul_runtime_sparse_weight,
    output logic                                           o_mul_sparse_a,
    output logic                                           o_mul_a_valid,
    output logic [                             WORD_W-1:0] o_mul_a_data,
    input  logic                                           i_mul_a_ready,
    output logic                                           o_mul_sparse_index_valid,
    output logic [                        MUL_INDEX_W-1:0] o_mul_sparse_index,
    input  logic                                           i_mul_sparse_index_ready,
    output logic                                           o_mul_b_valid,
    output logic [                             WORD_W-1:0] o_mul_b_data,
    input  logic                                           i_mul_b_ready,
    input  logic                                           i_mul_result_valid,
    input  logic [                             WORD_W-1:0] i_mul_result_data,
    input  logic                                           i_mul_result_last,
    output logic                                           o_mul_result_ready
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int LAST_BITS = R_BITS - ((WORDS - 1) * WORD_W);
  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int SUPPORT_ADDR_W = (SECRET_WEIGHT > 1) ? $clog2(SECRET_WEIGHT) : 1;

  typedef enum logic [4:0] {
    ST_IDLE,
    ST_LOAD_H0,
    ST_LOAD_T0,
    ST_LOAD_U,
    ST_LOAD_V,
    ST_SPARSE_START,
    ST_SPARSE_H0_FETCH,
    ST_SPARSE_H0_DATA,
    ST_SPARSE_U_FETCH,
    ST_SPARSE_U_DATA,
    ST_SPARSE_RESULT,
    ST_DENSE_START,
    ST_DENSE_T0_FETCH,
    ST_DENSE_T0_DATA,
    ST_DENSE_UV_FETCH,
    ST_DENSE_UV_DATA,
    ST_DENSE_RESULT,
    ST_DENSE_WRITE,
    ST_OUTPUT_FETCH,
    ST_OUTPUT_DATA
  } state_t;

  state_t                      state_q;
  integer                      load_count_q;
  integer                      feed_count_q;
  integer                      result_count_q;
  integer                      output_count_q;
  integer                      active_r_bits_q;
  integer                      active_secret_weight_q;
  integer                      active_words_q;
  integer                      active_last_bits_q;
  logic   [        WORD_W-1:0] active_last_mask_c;
  logic   [        WORD_W-1:0] dense_result_q;
  logic                        dense_last_q;

  logic                        h0_we;
  logic   [SUPPORT_ADDR_W-1:0] h0_waddr;
  logic   [       INDEX_W-1:0] h0_wdata;
  logic                        h0_re;
  logic   [SUPPORT_ADDR_W-1:0] h0_raddr;
  logic   [       INDEX_W-1:0] h0_rdata;

  logic                        t0_we;
  logic   [   WORD_ADDR_W-1:0] t0_waddr;
  logic   [        WORD_W-1:0] t0_wdata;
  logic                        t0_re;
  logic   [   WORD_ADDR_W-1:0] t0_raddr;
  logic   [        WORD_W-1:0] t0_rdata;
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
  logic                        syndrome_we;
  logic   [   WORD_ADDR_W-1:0] syndrome_waddr;
  logic   [        WORD_W-1:0] syndrome_wdata;
  logic                        syndrome_re;
  logic   [   WORD_ADDR_W-1:0] syndrome_raddr;
  logic   [        WORD_W-1:0] syndrome_rdata;

  logic                        mul_start;
  logic                        mul_sparse_a;
  logic                        mul_a_valid;
  logic   [        WORD_W-1:0] mul_a_data;
  logic                        mul_a_ready;
  logic                        mul_sparse_index_valid;
  logic   [       INDEX_W-1:0] mul_sparse_index;
  logic                        mul_sparse_index_ready;
  logic                        mul_b_valid;
  logic   [        WORD_W-1:0] mul_b_data;
  logic                        mul_b_ready;
  logic                        mul_result_valid;
  logic   [        WORD_W-1:0] mul_result_data;
  logic                        mul_result_last;
  logic                        mul_result_ready;
  logic                        mul_busy;
  logic                        mul_done;

  ram_bram #(
      .DATA_W(INDEX_W),
      .DEPTH (SECRET_WEIGHT)
  ) u_h0_mem (
      .i_clk  (i_clk),
      .i_we   (h0_we),
      .i_waddr(h0_waddr),
      .i_wdata(h0_wdata),
      .i_re   (h0_re),
      .i_raddr(h0_raddr),
      .o_rdata(h0_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t0_mem (
      .i_clk  (i_clk),
      .i_we   (t0_we),
      .i_waddr(t0_waddr),
      .i_wdata(t0_wdata),
      .i_re   (t0_re),
      .i_raddr(t0_raddr),
      .o_rdata(t0_rdata)
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

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_syndrome_mem (
      .i_clk  (i_clk),
      .i_we   (syndrome_we),
      .i_waddr(syndrome_waddr),
      .i_wdata(syndrome_wdata),
      .i_re   (syndrome_re),
      .i_raddr(syndrome_raddr),
      .o_rdata(syndrome_rdata)
  );

  assign o_mul_start = mul_start;
  assign o_mul_runtime_r_bits = 32'(active_r_bits_q);
  assign o_mul_runtime_words = 32'(active_words_q);
  assign o_mul_runtime_sparse_weight = 32'(active_secret_weight_q);
  assign o_mul_sparse_a = mul_sparse_a;
  assign o_mul_a_valid = mul_a_valid;
  assign o_mul_a_data = mul_a_data;
  assign o_mul_sparse_index_valid = mul_sparse_index_valid;
  assign o_mul_sparse_index = MUL_INDEX_W'(mul_sparse_index);
  assign o_mul_b_valid = mul_b_valid;
  assign o_mul_b_data = mul_b_data;
  assign o_mul_result_ready = mul_result_ready;

  generate
    if (USE_EXTERNAL_MUL) begin : gen_external_mul
      assign mul_a_ready = i_mul_a_ready;
      assign mul_sparse_index_ready = i_mul_sparse_index_ready;
      assign mul_b_ready = i_mul_b_ready;
      assign mul_result_valid = i_mul_result_valid;
      assign mul_result_data = i_mul_result_data;
      assign mul_result_last = i_mul_result_last;
      assign mul_busy = 1'b0;
      assign mul_done = 1'b0;
    end else begin : gen_local_mul
      trike_poly_mul_core #(
          .R_BITS          (R_BITS),
          .WORD_W          (WORD_W),
          .DIGIT_W         (DIGIT_W),
          .SPARSE_WEIGHT   (SECRET_WEIGHT),
          .RUNTIME_GEOMETRY(RUNTIME_GEOMETRY)
      ) u_mul (
          .i_clk                  (i_clk),
          .i_rst_n                (i_rst_n),
          .i_start                (mul_start),
          .i_runtime_r_bits       (32'(active_r_bits_q)),
          .i_runtime_words        (32'(active_words_q)),
          .i_runtime_sparse_weight(32'(active_secret_weight_q)),
          .i_sparse_a             (mul_sparse_a),
          .i_a_valid              (mul_a_valid),
          .i_a_data               (mul_a_data),
          .o_a_ready              (mul_a_ready),
          .i_sparse_index_valid   (mul_sparse_index_valid),
          .i_sparse_index         (mul_sparse_index),
          .o_sparse_index_ready   (mul_sparse_index_ready),
          .i_b_valid              (mul_b_valid),
          .i_b_data               (mul_b_data),
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
          .o_busy                 (mul_busy),
          .o_done                 (mul_done)
      );
    end
  endgenerate

  always_comb begin
    active_last_mask_c = {WORD_W{1'b1}} >> (WORD_W - active_last_bits_q);
    h0_we = 1'b0;
    h0_waddr = '0;
    h0_wdata = '0;
    h0_re = 1'b0;
    h0_raddr = '0;
    t0_we = 1'b0;
    t0_waddr = '0;
    t0_wdata = '0;
    t0_re = 1'b0;
    t0_raddr = '0;
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
    syndrome_we = 1'b0;
    syndrome_waddr = '0;
    syndrome_wdata = '0;
    syndrome_re = 1'b0;
    syndrome_raddr = '0;

    mul_start = 1'b0;
    mul_sparse_a = 1'b0;
    mul_a_valid = 1'b0;
    mul_a_data = t0_rdata;
    mul_sparse_index_valid = 1'b0;
    mul_sparse_index = h0_rdata;
    mul_b_valid = 1'b0;
    mul_b_data = u_rdata;
    mul_result_ready = 1'b0;

    o_h0_ready = (state_q == ST_LOAD_H0);
    o_t0_ready = (state_q == ST_LOAD_T0);
    o_u_ready = (state_q == ST_LOAD_U);
    o_v_ready = (state_q == ST_LOAD_V);
    o_syndrome_valid = (state_q == ST_OUTPUT_DATA);
    o_syndrome_data = syndrome_rdata;
    o_syndrome_last = (output_count_q == (active_words_q - 1));
    o_busy = (state_q != ST_IDLE);

    unique case (state_q)
      ST_LOAD_H0: begin
        h0_we = i_h0_valid;
        h0_waddr = SUPPORT_ADDR_W'(load_count_q);
        h0_wdata = i_h0_index;
      end

      ST_LOAD_T0: begin
        t0_we = i_t0_valid;
        t0_waddr = WORD_ADDR_W'(load_count_q);
        t0_wdata = (load_count_q == (active_words_q - 1)) ?
            (i_t0_data & active_last_mask_c) : i_t0_data;
      end

      ST_LOAD_U: begin
        u_we = i_u_valid;
        u_waddr = WORD_ADDR_W'(load_count_q);
        u_wdata = (load_count_q == (active_words_q - 1)) ?
            (i_u_data & active_last_mask_c) : i_u_data;
      end

      ST_LOAD_V: begin
        v_we = i_v_valid;
        v_waddr = WORD_ADDR_W'(load_count_q);
        v_wdata = (load_count_q == (active_words_q - 1)) ?
            (i_v_data & active_last_mask_c) : i_v_data;
      end

      ST_SPARSE_START: begin
        mul_start = 1'b1;
        mul_sparse_a = 1'b1;
      end

      ST_SPARSE_H0_FETCH: begin
        h0_re = 1'b1;
        h0_raddr = SUPPORT_ADDR_W'(feed_count_q);
      end

      ST_SPARSE_H0_DATA: mul_sparse_index_valid = 1'b1;

      ST_SPARSE_U_FETCH: begin
        u_re = 1'b1;
        u_raddr = WORD_ADDR_W'(feed_count_q);
      end

      ST_SPARSE_U_DATA: mul_b_valid = 1'b1;

      ST_SPARSE_RESULT: begin
        mul_result_ready = 1'b1;
        if (mul_result_valid) begin
          syndrome_we = 1'b1;
          syndrome_waddr = WORD_ADDR_W'(result_count_q);
          syndrome_wdata = mul_result_data;
        end
      end

      ST_DENSE_START: mul_start = 1'b1;

      ST_DENSE_T0_FETCH: begin
        t0_re = 1'b1;
        t0_raddr = WORD_ADDR_W'(feed_count_q);
      end

      ST_DENSE_T0_DATA: mul_a_valid = 1'b1;

      ST_DENSE_UV_FETCH: begin
        u_re = 1'b1;
        u_raddr = WORD_ADDR_W'(feed_count_q);
        v_re = 1'b1;
        v_raddr = WORD_ADDR_W'(feed_count_q);
      end

      ST_DENSE_UV_DATA: begin
        mul_b_valid = 1'b1;
        mul_b_data  = u_rdata ^ v_rdata;
      end

      ST_DENSE_RESULT: begin
        if (mul_result_valid) begin
          mul_result_ready = 1'b1;
          syndrome_re = 1'b1;
          syndrome_raddr = WORD_ADDR_W'(result_count_q);
        end
      end

      ST_DENSE_WRITE: begin
        syndrome_we = 1'b1;
        syndrome_waddr = WORD_ADDR_W'(result_count_q);
        syndrome_wdata = dense_result_q ^ syndrome_rdata;
      end

      ST_OUTPUT_FETCH: begin
        syndrome_re = 1'b1;
        syndrome_raddr = WORD_ADDR_W'(output_count_q);
      end

      default: begin
      end
    endcase
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      load_count_q <= 0;
      feed_count_q <= 0;
      result_count_q <= 0;
      output_count_q <= 0;
      dense_result_q <= '0;
      dense_last_q <= 1'b0;
      active_r_bits_q <= R_BITS;
      active_secret_weight_q <= SECRET_WEIGHT;
      active_words_q <= WORDS;
      active_last_bits_q <= LAST_BITS;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            load_count_q <= 0;
            if (RUNTIME_GEOMETRY) begin
              active_r_bits_q <= int'(i_runtime_r_bits);
              active_secret_weight_q <= int'(i_runtime_secret_weight);
              active_words_q <= int'(i_runtime_words);
              active_last_bits_q <= int'(i_runtime_r_bits) - ((int'(i_runtime_words) - 1) * WORD_W);
            end else begin
              active_r_bits_q <= R_BITS;
              active_secret_weight_q <= SECRET_WEIGHT;
              active_words_q <= WORDS;
              active_last_bits_q <= LAST_BITS;
            end
            state_q <= ST_LOAD_H0;
          end
        end

        ST_LOAD_H0: begin
          if (i_h0_valid) begin
            if (load_count_q == (active_secret_weight_q - 1)) begin
              load_count_q <= 0;
              state_q <= ST_LOAD_T0;
            end else begin
              load_count_q <= load_count_q + 1;
            end
          end
        end

        ST_LOAD_T0: begin
          if (i_t0_valid) begin
            if (load_count_q == (active_words_q - 1)) begin
              load_count_q <= 0;
              state_q <= ST_LOAD_U;
            end else begin
              load_count_q <= load_count_q + 1;
            end
          end
        end

        ST_LOAD_U: begin
          if (i_u_valid) begin
            if (load_count_q == (active_words_q - 1)) begin
              load_count_q <= 0;
              state_q <= ST_LOAD_V;
            end else begin
              load_count_q <= load_count_q + 1;
            end
          end
        end

        ST_LOAD_V: begin
          if (i_v_valid) begin
            if (load_count_q == (active_words_q - 1)) begin
              state_q <= ST_SPARSE_START;
            end else begin
              load_count_q <= load_count_q + 1;
            end
          end
        end

        ST_SPARSE_START: begin
          feed_count_q <= 0;
          state_q <= ST_SPARSE_H0_FETCH;
        end

        ST_SPARSE_H0_FETCH: state_q <= ST_SPARSE_H0_DATA;

        ST_SPARSE_H0_DATA: begin
          if (mul_sparse_index_ready) begin
            if (feed_count_q == (active_secret_weight_q - 1)) begin
              feed_count_q <= 0;
              state_q <= ST_SPARSE_U_FETCH;
            end else begin
              feed_count_q <= feed_count_q + 1;
              state_q <= ST_SPARSE_H0_FETCH;
            end
          end
        end

        ST_SPARSE_U_FETCH: state_q <= ST_SPARSE_U_DATA;

        ST_SPARSE_U_DATA: begin
          if (mul_b_ready) begin
            if (feed_count_q == (active_words_q - 1)) begin
              result_count_q <= 0;
              state_q <= ST_SPARSE_RESULT;
            end else begin
              feed_count_q <= feed_count_q + 1;
              state_q <= ST_SPARSE_U_FETCH;
            end
          end
        end

        ST_SPARSE_RESULT: begin
          if (mul_result_valid) begin
            if (mul_result_last) begin
              state_q <= ST_DENSE_START;
            end else begin
              result_count_q <= result_count_q + 1;
            end
          end
        end

        ST_DENSE_START: begin
          feed_count_q <= 0;
          state_q <= ST_DENSE_T0_FETCH;
        end

        ST_DENSE_T0_FETCH: state_q <= ST_DENSE_T0_DATA;

        ST_DENSE_T0_DATA: begin
          if (mul_a_ready) begin
            if (feed_count_q == (active_words_q - 1)) begin
              feed_count_q <= 0;
              state_q <= ST_DENSE_UV_FETCH;
            end else begin
              feed_count_q <= feed_count_q + 1;
              state_q <= ST_DENSE_T0_FETCH;
            end
          end
        end

        ST_DENSE_UV_FETCH: state_q <= ST_DENSE_UV_DATA;

        ST_DENSE_UV_DATA: begin
          if (mul_b_ready) begin
            if (feed_count_q == (active_words_q - 1)) begin
              result_count_q <= 0;
              state_q <= ST_DENSE_RESULT;
            end else begin
              feed_count_q <= feed_count_q + 1;
              state_q <= ST_DENSE_UV_FETCH;
            end
          end
        end

        ST_DENSE_RESULT: begin
          if (mul_result_valid) begin
            dense_result_q <= mul_result_data;
            dense_last_q <= mul_result_last;
            state_q <= ST_DENSE_WRITE;
          end
        end

        ST_DENSE_WRITE: begin
          if (dense_last_q) begin
            output_count_q <= 0;
            state_q <= ST_OUTPUT_FETCH;
          end else begin
            result_count_q <= result_count_q + 1;
            state_q <= ST_DENSE_RESULT;
          end
        end

        ST_OUTPUT_FETCH: state_q <= ST_OUTPUT_DATA;

        ST_OUTPUT_DATA: begin
          if (i_syndrome_ready) begin
            if (output_count_q == (active_words_q - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              output_count_q <= output_count_q + 1;
              state_q <= ST_OUTPUT_FETCH;
            end
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  initial begin
    if (SECRET_WEIGHT <= 0) $fatal(1, "trike_decaps_syndrome_core requires SECRET_WEIGHT > 0");
    if ((WORD_W % DIGIT_W) != 0)
      $fatal(1, "trike_decaps_syndrome_core requires WORD_W divisible by DIGIT_W");
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS))
        $fatal(1, "trike_decaps_syndrome_core runtime r out of range");
      if ((i_runtime_secret_weight < 1) || (i_runtime_secret_weight > SECRET_WEIGHT))
        $fatal(1, "trike_decaps_syndrome_core runtime weight out of range");
      if ((i_runtime_words < 1) || (i_runtime_words > WORDS))
        $fatal(1, "trike_decaps_syndrome_core runtime words out of range");
    end
  end
`endif

  /* verilator lint_off UNUSED */
  logic unused_mul_status;
  always_comb unused_mul_status = mul_busy ^ mul_done;
  /* verilator lint_on UNUSED */

endmodule
