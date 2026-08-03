`timescale 1ns / 1ps

// Fixed-schedule inversion in GF(2)[x]/(x^R_BITS - 1).
//
// The public R-dependent addition chain matches the TRIKE Reference C. Each
// Frobenius map is a fixed 2*R_BITS-cycle bit permutation. All polynomial
// products use one dense trike_poly_mul_core instance connected directly to
// the f/g/t scratch RAMs.
module trike_poly_inv_core #(
    parameter int R_BITS  = 15581,
    parameter int WORD_W  = 64,
    parameter int DIGIT_W = 8
) (
    input  logic              i_clk,
    input  logic              i_rst_n,
    input  logic              i_start,
    input  logic              i_input_valid,
    input  logic [WORD_W-1:0] i_input_data,
    output logic              o_input_ready,
    output logic              o_result_valid,
    output logic [WORD_W-1:0] o_result_data,
    output logic              o_result_last,
    input  logic              i_result_ready,
    output logic              o_busy,
    output logic              o_done
);

  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int LAST_BITS = R_BITS - ((WORDS - 1) * WORD_W);
  localparam int WORD_ADDR_W = (WORDS > 1) ? $clog2(WORDS) : 1;
  localparam int STAGE_COUNT = trike_inv_schedule_pkg::trike_inv_stage_count(R_BITS);
  localparam logic [WORD_W-1:0] LAST_MASK = {WORD_W{1'b1}} >> (WORD_W - LAST_BITS);

  typedef enum logic [3:0] {
    ST_IDLE,
    ST_LOAD,
    ST_PERM_READ,
    ST_PERM_CAPTURE,
    ST_MUL_START,
    ST_MUL_WAIT,
    ST_OUTPUT_FETCH,
    ST_OUTPUT_VALID
  } state_t;

  state_t                   state_q;

  integer                   word_idx_q;
  integer                   stage_q;
  integer                   perm_bit_idx_q;
  integer                   perm_pos_q;
  integer                   perm_l_q;

  logic                     perm_source_t_q;
  logic                     perm_final_q;
  logic                     perm_mul_dest_t_q;
  logic                     mul_dest_t_q;
  logic   [     WORD_W-1:0] perm_word_accum_q;

  logic                     f_we;
  logic   [WORD_ADDR_W-1:0] f_waddr;
  logic   [     WORD_W-1:0] f_wdata;
  logic                     f_re;
  logic   [WORD_ADDR_W-1:0] f_raddr;
  logic   [     WORD_W-1:0] f_rdata;

  logic                     g_we;
  logic   [WORD_ADDR_W-1:0] g_waddr;
  logic   [     WORD_W-1:0] g_wdata;
  logic                     g_re;
  logic   [WORD_ADDR_W-1:0] g_raddr;
  logic   [     WORD_W-1:0] g_rdata;

  logic                     t_we;
  logic   [WORD_ADDR_W-1:0] t_waddr;
  logic   [     WORD_W-1:0] t_wdata;
  logic                     t_re;
  logic   [WORD_ADDR_W-1:0] t_raddr;
  logic   [     WORD_W-1:0] t_rdata;

  logic                     mul_start;
  logic                     mul_ext_a_re;
  logic   [WORD_ADDR_W-1:0] mul_ext_a_raddr;
  logic                     mul_ext_b_re;
  logic   [WORD_ADDR_W-1:0] mul_ext_b_raddr;
  logic                     mul_ext_result_we;
  logic   [WORD_ADDR_W-1:0] mul_ext_result_waddr;
  logic   [     WORD_W-1:0] mul_ext_result_wdata;
  logic                     mul_busy;
  logic                     mul_done;
  logic                     mul_stream_a_ready;
  logic                     mul_stream_sparse_ready;
  logic                     mul_stream_b_ready;
  logic                     mul_stream_result_valid;
  logic   [     WORD_W-1:0] mul_stream_result_data;
  logic                     mul_stream_result_last;

  logic   [     WORD_W-1:0] perm_source_rdata_c;
  logic                     perm_source_bit_c;
  logic   [     WORD_W-1:0] perm_bit_mask_c;
  logic                     perm_word_end_c;

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_f_mem (
      .i_clk  (i_clk),
      .i_we   (f_we),
      .i_waddr(f_waddr),
      .i_wdata(f_wdata),
      .i_re   (f_re),
      .i_raddr(f_raddr),
      .o_rdata(f_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_g_mem (
      .i_clk  (i_clk),
      .i_we   (g_we),
      .i_waddr(g_waddr),
      .i_wdata(g_wdata),
      .i_re   (g_re),
      .i_raddr(g_raddr),
      .o_rdata(g_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t_mem (
      .i_clk  (i_clk),
      .i_we   (t_we),
      .i_waddr(t_waddr),
      .i_wdata(t_wdata),
      .i_re   (t_re),
      .i_raddr(t_raddr),
      .o_rdata(t_rdata)
  );

  trike_poly_mul_core #(
      .R_BITS                (R_BITS),
      .WORD_W                (WORD_W),
      .DIGIT_W               (DIGIT_W),
      .SPARSE_WEIGHT         (1),
      .USE_EXTERNAL_DENSE_RAM(1'b1)
  ) u_mul (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_start             (mul_start),
      .i_sparse_a          (1'b0),
      .i_a_valid           (1'b0),
      .i_a_data            ('0),
      .o_a_ready           (mul_stream_a_ready),
      .i_sparse_index_valid(1'b0),
      .i_sparse_index      ('0),
      .o_sparse_index_ready(mul_stream_sparse_ready),
      .i_b_valid           (1'b0),
      .i_b_data            ('0),
      .o_b_ready           (mul_stream_b_ready),
      .o_result_valid      (mul_stream_result_valid),
      .o_result_data       (mul_stream_result_data),
      .o_result_last       (mul_stream_result_last),
      .i_result_ready      (1'b0),
      .o_ext_a_re          (mul_ext_a_re),
      .o_ext_a_raddr       (mul_ext_a_raddr),
      .i_ext_a_rdata       (mul_dest_t_q ? t_rdata : f_rdata),
      .o_ext_b_re          (mul_ext_b_re),
      .o_ext_b_raddr       (mul_ext_b_raddr),
      .i_ext_b_rdata       (g_rdata),
      .o_ext_result_we     (mul_ext_result_we),
      .o_ext_result_waddr  (mul_ext_result_waddr),
      .o_ext_result_wdata  (mul_ext_result_wdata),
      .o_busy              (mul_busy),
      .o_done              (mul_done)
  );

  always_comb begin
    perm_source_rdata_c = perm_source_t_q ? t_rdata : f_rdata;
    perm_source_bit_c = perm_source_rdata_c[perm_pos_q%WORD_W];
    perm_bit_mask_c = {{(WORD_W - 1) {1'b0}}, perm_source_bit_c} << (perm_bit_idx_q % WORD_W);
    perm_word_end_c = ((perm_bit_idx_q % WORD_W) == (WORD_W - 1)) ||
                      (perm_bit_idx_q == (R_BITS - 1));
  end

  always_comb begin
    f_we = 1'b0;
    f_waddr = '0;
    f_wdata = '0;
    f_re = 1'b0;
    f_raddr = '0;
    g_we = 1'b0;
    g_waddr = '0;
    g_wdata = '0;
    g_re = 1'b0;
    g_raddr = '0;
    t_we = 1'b0;
    t_waddr = '0;
    t_wdata = '0;
    t_re = 1'b0;
    t_raddr = '0;

    mul_start = 1'b0;

    unique case (state_q)
      ST_LOAD: begin
        if (i_input_valid) begin
          f_we = 1'b1;
          f_waddr = WORD_ADDR_W'(word_idx_q);
          t_we = 1'b1;
          t_waddr = WORD_ADDR_W'(word_idx_q);
          if (word_idx_q == (WORDS - 1)) begin
            f_wdata = i_input_data & LAST_MASK;
            t_wdata = i_input_data & LAST_MASK;
          end else begin
            f_wdata = i_input_data;
            t_wdata = i_input_data;
          end
        end
      end

      ST_PERM_READ: begin
        if (perm_source_t_q) begin
          t_re = 1'b1;
          t_raddr = WORD_ADDR_W'(perm_pos_q / WORD_W);
        end else begin
          f_re = 1'b1;
          f_raddr = WORD_ADDR_W'(perm_pos_q / WORD_W);
        end
      end

      ST_PERM_CAPTURE: begin
        if (perm_word_end_c) begin
          g_we = 1'b1;
          g_waddr = WORD_ADDR_W'(perm_bit_idx_q / WORD_W);
          g_wdata = perm_word_accum_q | perm_bit_mask_c;
        end
      end

      ST_MUL_START: begin
        mul_start = 1'b1;
      end

      ST_MUL_WAIT: begin
        if (mul_ext_a_re) begin
          if (mul_dest_t_q) begin
            t_re = 1'b1;
            t_raddr = mul_ext_a_raddr;
          end else begin
            f_re = 1'b1;
            f_raddr = mul_ext_a_raddr;
          end
        end
        if (mul_ext_b_re) begin
          g_re = 1'b1;
          g_raddr = mul_ext_b_raddr;
        end
        if (mul_ext_result_we) begin
          if (mul_dest_t_q) begin
            t_we = 1'b1;
            t_waddr = mul_ext_result_waddr;
            t_wdata = mul_ext_result_wdata;
          end else begin
            f_we = 1'b1;
            f_waddr = mul_ext_result_waddr;
            f_wdata = mul_ext_result_wdata;
          end
        end
      end

      ST_OUTPUT_FETCH: begin
        g_re = 1'b1;
        g_raddr = WORD_ADDR_W'(word_idx_q);
      end

      default: begin
      end
    endcase
  end

  assign o_input_ready = (state_q == ST_LOAD);
  assign o_result_valid = (state_q == ST_OUTPUT_VALID);
  assign o_result_data = g_rdata;
  assign o_result_last = (word_idx_q == (WORDS - 1));
  assign o_busy = (state_q != ST_IDLE) || mul_busy;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q           <= ST_IDLE;
      word_idx_q        <= 0;
      stage_q           <= 1;
      perm_bit_idx_q    <= 0;
      perm_pos_q        <= 0;
      perm_l_q          <= 0;
      perm_source_t_q   <= 1'b0;
      perm_final_q      <= 1'b0;
      perm_mul_dest_t_q <= 1'b0;
      mul_dest_t_q      <= 1'b0;
      perm_word_accum_q <= '0;
      o_done            <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            word_idx_q <= 0;
            state_q    <= ST_LOAD;
          end
        end

        ST_LOAD: begin
          if (i_input_valid) begin
            if (word_idx_q == (WORDS - 1)) begin
              stage_q           <= 1;
              perm_bit_idx_q    <= 0;
              perm_pos_q        <= 0;
              perm_l_q          <= trike_inv_schedule_pkg::trike_inv_l0(R_BITS, 1);
              perm_source_t_q   <= 1'b0;
              perm_final_q      <= 1'b0;
              perm_mul_dest_t_q <= 1'b0;
              perm_word_accum_q <= '0;
              state_q           <= ST_PERM_READ;
            end else begin
              word_idx_q <= word_idx_q + 1;
            end
          end
        end

        ST_PERM_READ: begin
          state_q <= ST_PERM_CAPTURE;
        end

        ST_PERM_CAPTURE: begin
          if (perm_word_end_c) begin
            perm_word_accum_q <= '0;
          end else begin
            perm_word_accum_q <= perm_word_accum_q | perm_bit_mask_c;
          end

          if (perm_bit_idx_q == (R_BITS - 1)) begin
            if (perm_final_q) begin
              word_idx_q <= 0;
              state_q    <= ST_OUTPUT_FETCH;
            end else begin
              mul_dest_t_q <= perm_mul_dest_t_q;
              state_q      <= ST_MUL_START;
            end
          end else begin
            perm_bit_idx_q <= perm_bit_idx_q + 1;
            if ((perm_pos_q + perm_l_q) >= R_BITS) begin
              perm_pos_q <= perm_pos_q + perm_l_q - R_BITS;
            end else begin
              perm_pos_q <= perm_pos_q + perm_l_q;
            end
            state_q <= ST_PERM_READ;
          end
        end

        ST_MUL_START: begin
          state_q <= ST_MUL_WAIT;
        end

        ST_MUL_WAIT: begin
          if (mul_ext_result_we && (mul_ext_result_waddr == WORD_ADDR_W'(WORDS - 1))) begin
            if (!mul_dest_t_q && (trike_inv_schedule_pkg::trike_inv_l1(R_BITS, stage_q) != 0)) begin
              perm_bit_idx_q    <= 0;
              perm_pos_q        <= 0;
              perm_l_q          <= trike_inv_schedule_pkg::trike_inv_l1(R_BITS, stage_q);
              perm_source_t_q   <= 1'b0;
              perm_final_q      <= 1'b0;
              perm_mul_dest_t_q <= 1'b1;
              perm_word_accum_q <= '0;
              state_q           <= ST_PERM_READ;
            end else if (stage_q == (STAGE_COUNT - 1)) begin
              perm_bit_idx_q    <= 0;
              perm_pos_q        <= 0;
              perm_l_q          <= trike_inv_schedule_pkg::trike_inv_l0(R_BITS, 1);
              perm_source_t_q   <= 1'b1;
              perm_final_q      <= 1'b1;
              perm_mul_dest_t_q <= 1'b0;
              perm_word_accum_q <= '0;
              state_q           <= ST_PERM_READ;
            end else begin
              stage_q           <= stage_q + 1;
              perm_bit_idx_q    <= 0;
              perm_pos_q        <= 0;
              perm_l_q          <= trike_inv_schedule_pkg::trike_inv_l0(R_BITS, stage_q + 1);
              perm_source_t_q   <= 1'b0;
              perm_final_q      <= 1'b0;
              perm_mul_dest_t_q <= 1'b0;
              perm_word_accum_q <= '0;
              state_q           <= ST_PERM_READ;
            end
          end
        end

        ST_OUTPUT_FETCH: begin
          state_q <= ST_OUTPUT_VALID;
        end

        ST_OUTPUT_VALID: begin
          if (i_result_ready) begin
            if (word_idx_q == (WORDS - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              word_idx_q <= word_idx_q + 1;
              state_q    <= ST_OUTPUT_FETCH;
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
    if (state_q != ST_IDLE) begin
      if (mul_stream_a_ready || mul_stream_sparse_ready || mul_stream_b_ready) begin
        $error("trike_poly_inv_core external multiplier requested streamed input");
      end
      if (mul_stream_result_valid) begin
        $error("trike_poly_inv_core external multiplier emitted stream data=%h last=%b",
               mul_stream_result_data, mul_stream_result_last);
      end
    end
    if (mul_done && (state_q == ST_IDLE)) begin
      $error("trike_poly_inv_core multiplier completed outside inversion schedule");
    end
  end

  initial begin
    if (STAGE_COUNT == 0) begin
      $error("trike_poly_inv_core unsupported R_BITS");
    end
    if (WORD_W < 2) $error("trike_poly_inv_core WORD_W must be at least 2");
    if ((WORD_W % DIGIT_W) != 0) begin
      $error("trike_poly_inv_core WORD_W must be divisible by DIGIT_W");
    end
  end
`endif

endmodule
