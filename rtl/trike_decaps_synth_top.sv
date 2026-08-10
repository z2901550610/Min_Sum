`timescale 1ns / 1ps

// Narrow-I/O Min-Sum Decaps wrapper for Vivado implementation. Fixed-profile
// simulation uses TRIKE160; TRIKE_UNIFIED_PARAMS measures the maximum geometry.
// One transaction is accepted after each reset. The input stream is
//   secret_key || ciphertext,
// using the project TRIKE_MINSUM_KAT_V1 byte layout.
module trike_decaps_synth_top
  import bike_pkg::*;
(
                       input  logic       i_clk,
                       input  logic       i_rst_n,
                       input  logic       i_start,
                       input  logic       i_input_valid,
                       input  logic [7:0] i_input_data,
    (* IOB = "TRUE" *) output logic       o_input_ready,
    (* IOB = "TRUE" *) output logic       o_shared_secret_valid,
    (* IOB = "TRUE" *) output logic [7:0] o_shared_secret_data,
    (* IOB = "TRUE" *) output logic       o_shared_secret_last,
                       input  logic       i_shared_secret_ready,
    (* IOB = "TRUE" *) output logic       o_residual_zero,
    (* IOB = "TRUE" *) output logic       o_ciphertext_equal,
    (* IOB = "TRUE" *) output logic       o_busy,
    (* IOB = "TRUE" *) output logic       o_done
);

  localparam int M_BYTES = 32;
  localparam int WORD_W = 64;
  localparam int WORD_BYTES = WORD_W / 8;
  localparam int R_BYTES = (R + 7) / 8;
  localparam int WORDS = (R + WORD_W - 1) / WORD_W;
  localparam int SUPPORT_COUNT = N0 * W;
  localparam int SUPPORT_BYTES = SUPPORT_COUNT * 4;
  localparam int SK_BYTES = SUPPORT_BYTES + (3 * R_BYTES) + (2 * M_BYTES);
  localparam int CIPHERTEXT_BYTES = (2 * R_BYTES) + M_BYTES;
  localparam int INPUT_BYTES = SK_BYTES + CIPHERTEXT_BYTES;
  localparam int H0_OFFSET = SUPPORT_BYTES;
  localparam int T0_OFFSET = H0_OFFSET + R_BYTES;
  localparam int R2_OFFSET = T0_OFFSET + R_BYTES;
  localparam int SIGMA_OFFSET = R2_OFFSET + R_BYTES;
  localparam int SIGMA2_OFFSET = SIGMA_OFFSET + M_BYTES;
  localparam int CT_OFFSET = SK_BYTES;
  localparam int U_OFFSET = CT_OFFSET;
  localparam int V_OFFSET = U_OFFSET + R_BYTES;
  localparam int INPUT_ADDR_W = $clog2(INPUT_BYTES);
  localparam int SUPPORT_ADDR_W = $clog2(SUPPORT_COUNT);
  localparam int WORD_ADDR_W = $clog2(WORDS);
  localparam int R_ADDR_W = $clog2(R_BYTES);
  localparam int CT_ADDR_W = $clog2(CIPHERTEXT_BYTES);
  localparam int SS_IDX_W = $clog2(M_BYTES);

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_LOAD,
    ST_CORE_START,
    ST_CORE_RUN
  } state_t;

  state_t                      state_q;
  logic                        rst_n_sync;
  logic   [  INPUT_ADDR_W-1:0] input_count_q;
  logic                        transaction_complete_q;
  logic   [              31:0] support_accum_q;
  logic   [        WORD_W-1:0] t0_accum_q;
  logic   [        WORD_W-1:0] u_accum_q;
  logic   [        WORD_W-1:0] v_accum_q;
  logic   [     8*M_BYTES-1:0] sigma2_q;
  logic                        load_accept_c;

  logic                        support_we;
  logic   [SUPPORT_ADDR_W-1:0] support_waddr;
  logic   [     ROW_IDX_W-1:0] support_wdata;
  logic                        support_re;
  logic   [SUPPORT_ADDR_W-1:0] support_raddr;
  logic   [     ROW_IDX_W-1:0] support_rdata;

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

  logic                        r2_we;
  logic   [      R_ADDR_W-1:0] r2_waddr;
  logic   [               7:0] r2_wdata;
  logic                        core_r2_re;
  logic   [      R_ADDR_W-1:0] core_r2_raddr;
  logic   [               7:0] r2_rdata;

  logic                        ct_we;
  logic   [     CT_ADDR_W-1:0] ct_waddr;
  logic   [               7:0] ct_wdata;
  logic                        ct_re;
  logic   [     CT_ADDR_W-1:0] ct_raddr;
  logic   [               7:0] ct_rdata;
  logic                        core_ct_re;
  logic   [     CT_ADDR_W-1:0] core_ct_raddr;

  logic                        core_start;
  logic                        core_h_ready;
  logic                        core_t0_ready;
  logic                        core_u_ready;
  logic                        core_v_ready;
  logic                        core_c2_ready;
  logic                        core_residual_zero;
  logic   [     ROW_IDX_W-1:0] core_residual_weight;
  logic                        core_ciphertext_equal;
  logic                        core_ss_valid;
  logic   [      SS_IDX_W-1:0] core_ss_index;
  logic   [               7:0] core_ss_data;
  logic                        core_ss_last;
  logic                        core_ss_ready;
  logic                        core_busy;
  logic                        core_done;

  integer                      h_issue_count_q;
  logic                        h_fetch_pending_q;
  logic                        h_valid_q;
  logic   [     ROW_IDX_W-1:0] h_data_q;
  integer                      t0_issue_count_q;
  logic                        t0_fetch_pending_q;
  logic                        t0_valid_q;
  logic   [        WORD_W-1:0] t0_data_q;
  integer                      u_issue_count_q;
  logic                        u_fetch_pending_q;
  logic                        u_valid_q;
  logic   [        WORD_W-1:0] u_data_q;
  integer                      v_issue_count_q;
  logic                        v_fetch_pending_q;
  logic                        v_valid_q;
  logic   [        WORD_W-1:0] v_data_q;
  integer                      c2_issue_count_q;
  logic                        c2_fetch_pending_q;
  logic                        c2_valid_q;
  logic   [               7:0] c2_data_q;

  logic                        ss_buffer_valid_q;
  logic   [               7:0] ss_buffer_data_q;
  logic                        ss_buffer_last_q;

  integer                      support_byte_c;
  integer                      t0_byte_c;
  integer                      u_byte_c;
  integer                      v_byte_c;
  integer                      r2_byte_c;
  integer                      ct_byte_c;
  logic   [              31:0] support_word_c;
  logic   [        WORD_W-1:0] t0_word_c;
  logic   [        WORD_W-1:0] u_word_c;
  logic   [        WORD_W-1:0] v_word_c;
  logic                        c2_fetch_c;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  assign core_start = state_q == ST_CORE_START;
  assign core_ss_ready = !ss_buffer_valid_q;
  assign load_accept_c = (state_q == ST_LOAD) && o_input_ready && i_input_valid;

  assign support_re = (state_q == ST_CORE_RUN) && (h_issue_count_q < SUPPORT_COUNT) &&
      !h_valid_q && !h_fetch_pending_q;
  assign support_raddr = SUPPORT_ADDR_W'(h_issue_count_q);
  assign t0_re = (state_q == ST_CORE_RUN) && (t0_issue_count_q < WORDS) &&
      !t0_valid_q && !t0_fetch_pending_q;
  assign t0_raddr = WORD_ADDR_W'(t0_issue_count_q);
  assign u_re = (state_q == ST_CORE_RUN) && (u_issue_count_q < WORDS) &&
      !u_valid_q && !u_fetch_pending_q;
  assign u_raddr = WORD_ADDR_W'(u_issue_count_q);
  assign v_re = (state_q == ST_CORE_RUN) && (v_issue_count_q < WORDS) &&
      !v_valid_q && !v_fetch_pending_q;
  assign v_raddr = WORD_ADDR_W'(v_issue_count_q);
  assign c2_fetch_c = (state_q == ST_CORE_RUN) && (c2_issue_count_q < M_BYTES) &&
      !c2_valid_q && !c2_fetch_pending_q;

  always_comb begin
    support_byte_c = int'(input_count_q);
    t0_byte_c = int'(input_count_q) - T0_OFFSET;
    r2_byte_c = int'(input_count_q) - R2_OFFSET;
    ct_byte_c = int'(input_count_q) - CT_OFFSET;
    u_byte_c = int'(input_count_q) - U_OFFSET;
    v_byte_c = int'(input_count_q) - V_OFFSET;

    support_word_c = support_accum_q;
    t0_word_c = t0_accum_q;
    u_word_c = u_accum_q;
    v_word_c = v_accum_q;
    support_we = 1'b0;
    support_waddr = '0;
    support_wdata = '0;
    t0_we = 1'b0;
    t0_waddr = '0;
    t0_wdata = '0;
    u_we = 1'b0;
    u_waddr = '0;
    u_wdata = '0;
    v_we = 1'b0;
    v_waddr = '0;
    v_wdata = '0;
    r2_we = 1'b0;
    r2_waddr = '0;
    r2_wdata = i_input_data;
    ct_we = 1'b0;
    ct_waddr = '0;
    ct_wdata = i_input_data;

    if (load_accept_c && (support_byte_c < SUPPORT_BYTES)) begin
      support_word_c[8*(support_byte_c%4)+:8] = i_input_data;
      if ((support_byte_c % 4) == 3) begin
        support_we = 1'b1;
        support_waddr = SUPPORT_ADDR_W'(support_byte_c / 4);
        support_wdata = support_word_c[ROW_IDX_W-1:0];
      end
    end

    if (load_accept_c && (t0_byte_c >= 0) && (t0_byte_c < R_BYTES)) begin
      t0_word_c[8*(t0_byte_c%WORD_BYTES)+:8] = i_input_data;
      if (((t0_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (t0_byte_c == (R_BYTES - 1))) begin
        t0_we = 1'b1;
        t0_waddr = WORD_ADDR_W'(t0_byte_c / WORD_BYTES);
        t0_wdata = t0_word_c;
      end
    end

    if (load_accept_c && (r2_byte_c >= 0) && (r2_byte_c < R_BYTES)) begin
      r2_we = 1'b1;
      r2_waddr = R_ADDR_W'(r2_byte_c);
    end

    if (load_accept_c && (ct_byte_c >= 0) && (ct_byte_c < CIPHERTEXT_BYTES)) begin
      ct_we = 1'b1;
      ct_waddr = CT_ADDR_W'(ct_byte_c);
    end

    if (load_accept_c && (u_byte_c >= 0) && (u_byte_c < R_BYTES)) begin
      u_word_c[8*(u_byte_c%WORD_BYTES)+:8] = i_input_data;
      if (((u_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (u_byte_c == (R_BYTES - 1))) begin
        u_we = 1'b1;
        u_waddr = WORD_ADDR_W'(u_byte_c / WORD_BYTES);
        u_wdata = u_word_c;
      end
    end

    if (load_accept_c && (v_byte_c >= 0) && (v_byte_c < R_BYTES)) begin
      v_word_c[8*(v_byte_c%WORD_BYTES)+:8] = i_input_data;
      if (((v_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (v_byte_c == (R_BYTES - 1))) begin
        v_we = 1'b1;
        v_waddr = WORD_ADDR_W'(v_byte_c / WORD_BYTES);
        v_wdata = v_word_c;
      end
    end

    ct_re = c2_fetch_c || core_ct_re;
    if (c2_fetch_c) ct_raddr = CT_ADDR_W'((2 * R_BYTES) + c2_issue_count_q);
    else ct_raddr = core_ct_raddr;
  end

  ram_bram #(
      .DATA_W(ROW_IDX_W),
      .DEPTH (SUPPORT_COUNT),
      .ADDR_W(SUPPORT_ADDR_W)
  ) u_support_mem (
      .i_clk(i_clk),
      .i_we(support_we),
      .i_waddr(support_waddr),
      .i_wdata(support_wdata),
      .i_re(support_re),
      .i_raddr(support_raddr),
      .o_rdata(support_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS),
      .ADDR_W(WORD_ADDR_W)
  ) u_t0_mem (
      .i_clk(i_clk),
      .i_we(t0_we),
      .i_waddr(t0_waddr),
      .i_wdata(t0_wdata),
      .i_re(t0_re),
      .i_raddr(t0_raddr),
      .o_rdata(t0_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS),
      .ADDR_W(WORD_ADDR_W)
  ) u_u_mem (
      .i_clk(i_clk),
      .i_we(u_we),
      .i_waddr(u_waddr),
      .i_wdata(u_wdata),
      .i_re(u_re),
      .i_raddr(u_raddr),
      .o_rdata(u_rdata)
  );
  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS),
      .ADDR_W(WORD_ADDR_W)
  ) u_v_mem (
      .i_clk(i_clk),
      .i_we(v_we),
      .i_waddr(v_waddr),
      .i_wdata(v_wdata),
      .i_re(v_re),
      .i_raddr(v_raddr),
      .o_rdata(v_rdata)
  );
  ram_bram #(
      .DATA_W(8),
      .DEPTH (R_BYTES),
      .ADDR_W(R_ADDR_W)
  ) u_r2_mem (
      .i_clk(i_clk),
      .i_we(r2_we),
      .i_waddr(r2_waddr),
      .i_wdata(r2_wdata),
      .i_re(core_r2_re),
      .i_raddr(core_r2_raddr),
      .o_rdata(r2_rdata)
  );
  ram_bram #(
      .DATA_W(8),
      .DEPTH (CIPHERTEXT_BYTES),
      .ADDR_W(CT_ADDR_W)
  ) u_ct_mem (
      .i_clk(i_clk),
      .i_we(ct_we),
      .i_waddr(ct_waddr),
      .i_wdata(ct_wdata),
      .i_re(ct_re),
      .i_raddr(ct_raddr),
      .o_rdata(ct_rdata)
  );

  always_ff @(posedge i_clk) begin
    if (!rst_n_sync) begin
      state_q <= ST_IDLE;
      input_count_q <= '0;
      transaction_complete_q <= 1'b0;
      support_accum_q <= '0;
      t0_accum_q <= '0;
      u_accum_q <= '0;
      v_accum_q <= '0;
      sigma2_q <= '0;
      h_issue_count_q <= 0;
      h_fetch_pending_q <= 1'b0;
      h_valid_q <= 1'b0;
      h_data_q <= '0;
      t0_issue_count_q <= 0;
      t0_fetch_pending_q <= 1'b0;
      t0_valid_q <= 1'b0;
      t0_data_q <= '0;
      u_issue_count_q <= 0;
      u_fetch_pending_q <= 1'b0;
      u_valid_q <= 1'b0;
      u_data_q <= '0;
      v_issue_count_q <= 0;
      v_fetch_pending_q <= 1'b0;
      v_valid_q <= 1'b0;
      v_data_q <= '0;
      c2_issue_count_q <= 0;
      c2_fetch_pending_q <= 1'b0;
      c2_valid_q <= 1'b0;
      c2_data_q <= '0;
      ss_buffer_valid_q <= 1'b0;
      ss_buffer_data_q <= '0;
      ss_buffer_last_q <= 1'b0;
      o_input_ready <= 1'b0;
      o_shared_secret_valid <= 1'b0;
      o_shared_secret_data <= '0;
      o_shared_secret_last <= 1'b0;
      o_residual_zero <= 1'b0;
      o_ciphertext_equal <= 1'b0;
      o_busy <= 1'b0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;
      o_busy <= (state_q != ST_IDLE) || ss_buffer_valid_q || o_shared_secret_valid;

      unique case (state_q)
        ST_IDLE: begin
          o_input_ready <= 1'b0;
          if (i_start && !transaction_complete_q) begin
            input_count_q <= '0;
            support_accum_q <= '0;
            t0_accum_q <= '0;
            u_accum_q <= '0;
            v_accum_q <= '0;
            sigma2_q <= '0;
            h_issue_count_q <= 0;
            t0_issue_count_q <= 0;
            u_issue_count_q <= 0;
            v_issue_count_q <= 0;
            c2_issue_count_q <= 0;
            o_residual_zero <= 1'b0;
            o_ciphertext_equal <= 1'b0;
            o_input_ready <= 1'b1;
            o_busy <= 1'b1;
            state_q <= ST_LOAD;
          end
        end

        ST_LOAD: begin
          if (load_accept_c) begin
            if ((support_byte_c % 4) == 3) support_accum_q <= '0;
            else if (support_byte_c < SUPPORT_BYTES) support_accum_q <= support_word_c;

            if ((t0_byte_c >= 0) && (t0_byte_c < R_BYTES)) begin
              if (((t0_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (t0_byte_c == (R_BYTES - 1)))
                t0_accum_q <= '0;
              else t0_accum_q <= t0_word_c;
            end
            if ((u_byte_c >= 0) && (u_byte_c < R_BYTES)) begin
              if (((u_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (u_byte_c == (R_BYTES - 1)))
                u_accum_q <= '0;
              else u_accum_q <= u_word_c;
            end
            if ((v_byte_c >= 0) && (v_byte_c < R_BYTES)) begin
              if (((v_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (v_byte_c == (R_BYTES - 1)))
                v_accum_q <= '0;
              else v_accum_q <= v_word_c;
            end
            if ((int'(input_count_q) >= SIGMA2_OFFSET) &&
                (int'(input_count_q) < (SIGMA2_OFFSET + M_BYTES)))
              sigma2_q[8*(int'(input_count_q)-SIGMA2_OFFSET)+:8] <= i_input_data;

            if (input_count_q == INPUT_ADDR_W'(INPUT_BYTES - 1)) begin
              o_input_ready <= 1'b0;
              state_q <= ST_CORE_START;
            end else begin
              input_count_q <= input_count_q + 1'b1;
            end
          end
        end

        ST_CORE_START: state_q <= ST_CORE_RUN;

        ST_CORE_RUN: begin
          o_residual_zero <= core_residual_zero;
          o_ciphertext_equal <= core_ciphertext_equal;
          if (o_shared_secret_valid && i_shared_secret_ready && o_shared_secret_last) begin
            o_shared_secret_valid <= 1'b0;
            o_done <= 1'b1;
            o_busy <= 1'b0;
            transaction_complete_q <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase

      if (support_re) h_fetch_pending_q <= 1'b1;
      else if (h_fetch_pending_q) begin
        h_fetch_pending_q <= 1'b0;
        h_valid_q <= 1'b1;
        h_data_q <= support_rdata;
      end
      if (h_valid_q && core_h_ready) begin
        h_valid_q <= 1'b0;
        h_issue_count_q <= h_issue_count_q + 1;
      end

      if (t0_re) t0_fetch_pending_q <= 1'b1;
      else if (t0_fetch_pending_q) begin
        t0_fetch_pending_q <= 1'b0;
        t0_valid_q <= 1'b1;
        t0_data_q <= t0_rdata;
      end
      if (t0_valid_q && core_t0_ready) begin
        t0_valid_q <= 1'b0;
        t0_issue_count_q <= t0_issue_count_q + 1;
      end

      if (u_re) u_fetch_pending_q <= 1'b1;
      else if (u_fetch_pending_q) begin
        u_fetch_pending_q <= 1'b0;
        u_valid_q <= 1'b1;
        u_data_q <= u_rdata;
      end
      if (u_valid_q && core_u_ready) begin
        u_valid_q <= 1'b0;
        u_issue_count_q <= u_issue_count_q + 1;
      end

      if (v_re) v_fetch_pending_q <= 1'b1;
      else if (v_fetch_pending_q) begin
        v_fetch_pending_q <= 1'b0;
        v_valid_q <= 1'b1;
        v_data_q <= v_rdata;
      end
      if (v_valid_q && core_v_ready) begin
        v_valid_q <= 1'b0;
        v_issue_count_q <= v_issue_count_q + 1;
      end

      if (c2_fetch_c) c2_fetch_pending_q <= 1'b1;
      else if (c2_fetch_pending_q) begin
        c2_fetch_pending_q <= 1'b0;
        c2_valid_q <= 1'b1;
        c2_data_q <= ct_rdata;
      end
      if (c2_valid_q && core_c2_ready) begin
        c2_valid_q <= 1'b0;
        c2_issue_count_q <= c2_issue_count_q + 1;
      end

      if (!ss_buffer_valid_q && core_ss_valid) begin
        ss_buffer_valid_q <= 1'b1;
        ss_buffer_data_q  <= core_ss_data;
        ss_buffer_last_q  <= core_ss_last;
      end
      if (!o_shared_secret_valid && ss_buffer_valid_q) begin
        o_shared_secret_valid <= 1'b1;
        o_shared_secret_data <= ss_buffer_data_q;
        o_shared_secret_last <= ss_buffer_last_q;
        ss_buffer_valid_q <= 1'b0;
      end else if (o_shared_secret_valid && i_shared_secret_ready) begin
        o_shared_secret_valid <= 1'b0;
      end
    end
  end

  trike_decaps_pipeline_core u_pipeline (
      .i_clk                (i_clk),
      .i_rst_n              (rst_n_sync),
      .i_start              (core_start),
      .i_h_valid            (h_valid_q),
      .i_h_index            (h_data_q),
      .o_h_ready            (core_h_ready),
      .i_t0_valid           (t0_valid_q),
      .i_t0_data            (t0_data_q),
      .o_t0_ready           (core_t0_ready),
      .i_u_valid            (u_valid_q),
      .i_u_data             (u_data_q),
      .o_u_ready            (core_u_ready),
      .i_v_valid            (v_valid_q),
      .i_v_data             (v_data_q),
      .o_v_ready            (core_v_ready),
      .i_sigma2             (sigma2_q),
      .i_c2_valid           (c2_valid_q),
      .i_c2_data            (c2_data_q),
      .o_c2_ready           (core_c2_ready),
      .o_r2_re              (core_r2_re),
      .o_r2_raddr           (core_r2_raddr),
      .i_r2_rdata           (r2_rdata),
      .o_ciphertext_re      (core_ct_re),
      .o_ciphertext_raddr   (core_ct_raddr),
      .i_ciphertext_rdata   (ct_rdata),
      .o_residual_zero      (core_residual_zero),
      .o_residual_weight    (core_residual_weight),
      .o_ciphertext_equal   (core_ciphertext_equal),
      .o_shared_secret_valid(core_ss_valid),
      .o_shared_secret_index(core_ss_index),
      .o_shared_secret_data (core_ss_data),
      .o_shared_secret_last (core_ss_last),
      .i_shared_secret_ready(core_ss_ready),
      .o_busy               (core_busy),
      .o_done               (core_done)
  );

`ifndef SYNTHESIS
  initial begin
    if ((R != 12589) || (W != 35) || (T != 263) || (N0 != 3))
      $fatal(1, "trike_decaps_synth_top requires TRIKE160 fixed parameters");
  end
`endif

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_core_status;
  assign unused_core_status = core_busy ^ core_done ^ (^core_ss_index) ^ (^core_residual_weight);
  /* verilator lint_on UNUSEDSIGNAL */

endmodule
