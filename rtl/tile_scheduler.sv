`timescale 1ns / 1ps
// Fixed-window tile scheduler with registered control outputs.
module tile_scheduler
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_start,
    input  logic [    CFG_W_W-1:0] i_cfg_w,
    input  logic [ TILE_IDX_W-1:0] i_cfg_tile_count,
    input  logic [ROW_BANK_AW-1:0] i_cfg_row_seg_size,
    output logic [DEC_STATE_W-1:0] o_state,
    output logic                   o_c2v_valid,
    output logic                   o_v2c_valid,
    output logic                   o_ksign_corr_valid,
    output logic [  TILE_ID_W-1:0] o_c2v_tile_linear,
    output logic [  TILE_ID_W-1:0] o_v2c_tile_linear,
    output logic [  H_BLOCK_W-1:0] o_c2v_h_block_idx,
    output logic [ TILE_IDX_W-1:0] o_c2v_tile_idx,
    output logic [  H_BLOCK_W-1:0] o_v2c_h_block_idx,
    output logic [ TILE_IDX_W-1:0] o_v2c_tile_idx,
    output logic [ DIAG_IDX_W-1:0] o_diag_idx_local,
    output logic [    Q_SEQ_W-1:0] o_q_seq,
    output logic                   o_clear_valid,
    output logic [ROW_BANK_AW-1:0] o_clear_addr,
    output logic                   o_fill_buf,
    output logic                   o_active_buf,
    output logic                   o_final_iter,
    output logic                   o_iter_first_cycle,
    output logic                   o_iter_last_cycle,
    output logic                   o_done,
    output logic [     ITER_W-1:0] o_iter_count
);

  localparam int WINDOW_COUNT = TILES_TOTAL + 1;
  localparam int WINDOW_IDX_W = (WINDOW_COUNT > 1) ? $clog2(WINDOW_COUNT) : 1;
  localparam int KSIGN_CORR_GUARD_CYCLES = 8;
  localparam int KSIGN_CORR_GUARD_W = $clog2(KSIGN_CORR_GUARD_CYCLES + 1);

  logic                          running_q;
  logic                          clear_q;
  logic                          ksign_corr_q;
  logic [KSIGN_CORR_GUARD_W-1:0] ksign_corr_guard_q;
  logic [       ROW_BANK_AW-1:0] clear_addr_q;
  logic [      WINDOW_IDX_W-1:0] window_idx_q;
  logic [        DIAG_IDX_W-1:0] diag_idx_local_q;
  logic [           Q_SEQ_W-1:0] q_seq_q;
  logic [            ITER_W-1:0] iter_count_q;
  logic                          c2v_tile_active_q;
  logic                          v2c_tile_active_q;
  logic [         TILE_ID_W-1:0] c2v_tile_linear_state_q;
  logic [         TILE_ID_W-1:0] v2c_tile_linear_state_q;
  logic [         H_BLOCK_W-1:0] c2v_h_block_state_q;
  logic [        TILE_IDX_W-1:0] c2v_tile_idx_state_q;
  logic [         H_BLOCK_W-1:0] v2c_h_block_state_q;
  logic [        TILE_IDX_W-1:0] v2c_tile_idx_state_q;
  logic                          done_q;

  logic                          running_d;
  logic                          clear_d;
  logic                          ksign_corr_d;
  logic [KSIGN_CORR_GUARD_W-1:0] ksign_corr_guard_d;
  logic [       ROW_BANK_AW-1:0] clear_addr_d;
  logic [      WINDOW_IDX_W-1:0] window_idx_d;
  logic [        DIAG_IDX_W-1:0] diag_idx_local_d;
  logic [           Q_SEQ_W-1:0] q_seq_d;
  logic [            ITER_W-1:0] iter_count_d;
  logic                          c2v_tile_active_d;
  logic                          v2c_tile_active_d;
  logic [         TILE_ID_W-1:0] c2v_tile_linear_state_d;
  logic [         TILE_ID_W-1:0] v2c_tile_linear_state_d;
  logic [         H_BLOCK_W-1:0] c2v_h_block_state_d;
  logic [        TILE_IDX_W-1:0] c2v_tile_idx_state_d;
  logic [         H_BLOCK_W-1:0] v2c_h_block_state_d;
  logic [        TILE_IDX_W-1:0] v2c_tile_idx_state_d;
  logic                          done_d;

  logic [       DEC_STATE_W-1:0] state_d;
  logic                          c2v_valid_d;
  logic                          v2c_valid_d;
  logic [         TILE_ID_W-1:0] c2v_tile_linear_d;
  logic [         TILE_ID_W-1:0] v2c_tile_linear_d;
  logic [         H_BLOCK_W-1:0] c2v_h_block_idx_d;
  logic [        TILE_IDX_W-1:0] c2v_tile_idx_d;
  logic [         H_BLOCK_W-1:0] v2c_h_block_idx_d;
  logic [        TILE_IDX_W-1:0] v2c_tile_idx_d;
  logic                          clear_valid_d;
  logic                          ksign_corr_valid_d;
  logic [       ROW_BANK_AW-1:0] clear_addr_out_d;
  logic                          fill_buf_d;
  logic                          active_buf_d;
  logic                          final_iter_d;
  logic                          iter_first_cycle_d;
  logic                          iter_last_cycle_d;

  function automatic logic [TILE_ID_W-1:0] next_tile_linear(
      input  logic [TILE_ID_W-1:0] tile_linear);
    begin
      next_tile_linear = tile_linear + TILE_ID_W'(1);
    end
  endfunction

  always_comb begin
    logic current_last_cycle;
    logic last_diag_idx_local;
    logic last_q_seq;
    logic last_clear_addr;
    logic last_tile_idx;
    logic last_tile_linear;

    running_d = running_q;
    clear_d = clear_q;
    ksign_corr_d = ksign_corr_q;
    ksign_corr_guard_d = ksign_corr_guard_q;
    clear_addr_d = clear_addr_q;
    window_idx_d = window_idx_q;
    diag_idx_local_d = diag_idx_local_q;
    q_seq_d = q_seq_q;
    iter_count_d = iter_count_q;
    c2v_tile_active_d = c2v_tile_active_q;
    v2c_tile_active_d = v2c_tile_active_q;
    c2v_tile_linear_state_d = c2v_tile_linear_state_q;
    v2c_tile_linear_state_d = v2c_tile_linear_state_q;
    c2v_h_block_state_d = c2v_h_block_state_q;
    c2v_tile_idx_state_d = c2v_tile_idx_state_q;
    v2c_h_block_state_d = v2c_h_block_state_q;
    v2c_tile_idx_state_d = v2c_tile_idx_state_q;
    done_d = done_q;

    last_diag_idx_local = int'(diag_idx_local_q) == (int'(i_cfg_w) - 1);
    last_q_seq = int'(q_seq_q) == (Q_TILE - 1);
    last_clear_addr = int'(clear_addr_q) == (int'(i_cfg_row_seg_size) - 1);
    last_tile_idx = int'(c2v_tile_idx_state_q) == (int'(i_cfg_tile_count) - 1);
    last_tile_linear = int'(c2v_tile_linear_state_q) == ((N0 * int'(i_cfg_tile_count)) - 1);
    current_last_cycle = running_q && !clear_q && !c2v_tile_active_q && v2c_tile_active_q &&
                         last_diag_idx_local && last_q_seq;

    if (i_start) begin
      running_d = 1'b1;
      clear_d = 1'b1;
      ksign_corr_d = 1'b0;
      ksign_corr_guard_d = '0;
      clear_addr_d = '0;
      window_idx_d = '0;
      diag_idx_local_d = '0;
      q_seq_d = '0;
      iter_count_d = '0;
      c2v_tile_active_d = 1'b1;
      v2c_tile_active_d = 1'b0;
      c2v_tile_linear_state_d = '0;
      v2c_tile_linear_state_d = '0;
      c2v_h_block_state_d = '0;
      c2v_tile_idx_state_d = '0;
      v2c_h_block_state_d = '0;
      v2c_tile_idx_state_d = '0;
      done_d = 1'b0;
    end else if (running_q) begin
      if (clear_q) begin
        if (last_clear_addr) begin
          clear_d = 1'b0;
          clear_addr_d = '0;
        end else begin
          clear_addr_d = clear_addr_q + ROW_BANK_AW'(1);
        end
      end else if (ksign_corr_q && (ksign_corr_guard_q != '0)) begin
        ksign_corr_guard_d = ksign_corr_guard_q - KSIGN_CORR_GUARD_W'(1);
      end else if (ksign_corr_q && last_tile_linear && last_diag_idx_local && last_q_seq) begin
        ksign_corr_d = 1'b0;
        if (int'(iter_count_q) == (I_MAX - 1)) begin
          running_d = 1'b0;
          done_d = 1'b1;
          iter_count_d = ITER_W'(I_MAX);
        end else begin
          clear_d = 1'b1;
          clear_addr_d = '0;
          window_idx_d = '0;
          diag_idx_local_d = '0;
          q_seq_d = '0;
          iter_count_d = iter_count_q + ITER_W'(1);
          c2v_tile_active_d = 1'b1;
          v2c_tile_active_d = 1'b0;
          c2v_tile_linear_state_d = '0;
          v2c_tile_linear_state_d = '0;
          c2v_h_block_state_d = '0;
          c2v_tile_idx_state_d = '0;
          v2c_h_block_state_d = '0;
          v2c_tile_idx_state_d = '0;
        end
      end else if (ksign_corr_q) begin
        if (last_q_seq) begin
          q_seq_d = '0;
          if (last_diag_idx_local) begin
            diag_idx_local_d = '0;
            c2v_tile_linear_state_d = next_tile_linear(c2v_tile_linear_state_q);
            c2v_h_block_state_d = last_tile_idx ? c2v_h_block_state_q + H_BLOCK_W'(1) :
                c2v_h_block_state_q;
            c2v_tile_idx_state_d = last_tile_idx ? '0 : c2v_tile_idx_state_q + TILE_IDX_W'(1);
          end else begin
            diag_idx_local_d = diag_idx_local_q + DIAG_IDX_W'(1);
          end
        end else begin
          q_seq_d = q_seq_q + Q_SEQ_W'(1);
        end
      end else if (current_last_cycle) begin
        if (K_SIGN_ENABLE) begin
          ksign_corr_d = 1'b1;
          ksign_corr_guard_d = KSIGN_CORR_GUARD_W'(KSIGN_CORR_GUARD_CYCLES);
          window_idx_d = '0;
          diag_idx_local_d = '0;
          q_seq_d = '0;
          c2v_tile_active_d = 1'b0;
          v2c_tile_active_d = 1'b0;
          c2v_tile_linear_state_d = '0;
          c2v_h_block_state_d = '0;
          c2v_tile_idx_state_d = '0;
        end else if (int'(iter_count_q) == (I_MAX - 1)) begin
          running_d = 1'b0;
          done_d = 1'b1;
          iter_count_d = ITER_W'(I_MAX);
        end else begin
          clear_d = 1'b1;
          clear_addr_d = '0;
          window_idx_d = '0;
          diag_idx_local_d = '0;
          q_seq_d = '0;
          iter_count_d = iter_count_q + ITER_W'(1);
          c2v_tile_active_d = 1'b1;
          v2c_tile_active_d = 1'b0;
          c2v_tile_linear_state_d = '0;
          v2c_tile_linear_state_d = '0;
          c2v_h_block_state_d = '0;
          c2v_tile_idx_state_d = '0;
          v2c_h_block_state_d = '0;
          v2c_tile_idx_state_d = '0;
        end
      end else if (last_q_seq) begin
        q_seq_d = '0;
        if (last_diag_idx_local) begin
          diag_idx_local_d = '0;
          window_idx_d = window_idx_q + WINDOW_IDX_W'(1);
          c2v_tile_active_d = c2v_tile_active_q && !last_tile_linear;
          v2c_tile_active_d = c2v_tile_active_q;
          v2c_tile_linear_state_d = c2v_tile_linear_state_q;
          v2c_h_block_state_d = c2v_h_block_state_q;
          v2c_tile_idx_state_d = c2v_tile_idx_state_q;
          c2v_tile_linear_state_d = next_tile_linear(c2v_tile_linear_state_q);
          c2v_h_block_state_d = last_tile_idx ? c2v_h_block_state_q + H_BLOCK_W'(1) :
              c2v_h_block_state_q;
          c2v_tile_idx_state_d = last_tile_idx ? '0 : c2v_tile_idx_state_q + TILE_IDX_W'(1);
        end else begin
          diag_idx_local_d = diag_idx_local_q + DIAG_IDX_W'(1);
        end
      end else begin
        q_seq_d = q_seq_q + Q_SEQ_W'(1);
      end
    end
  end

  always_comb begin
    logic clear_active_d;
    logic ksign_corr_last_active;

    clear_active_d = running_q && clear_q;
    ksign_corr_last_active = K_SIGN_ENABLE && running_q && ksign_corr_q &&
        (ksign_corr_guard_q == '0) &&
        (int'(c2v_tile_linear_state_q) == ((N0 * int'(i_cfg_tile_count)) - 1)) &&
        (int'(diag_idx_local_q) == (int'(i_cfg_w) - 1)) && (int'(q_seq_q) == (Q_TILE - 1));
    ksign_corr_valid_d = running_d && !i_start && !clear_active_d && ksign_corr_d &&
        (ksign_corr_guard_d == '0);
    c2v_valid_d = running_d && !i_start && !clear_active_d && !ksign_corr_valid_d &&
        c2v_tile_active_d;
    v2c_valid_d = running_d && !i_start && !clear_active_d && !ksign_corr_valid_d &&
        v2c_tile_active_d;
    c2v_tile_linear_d = (c2v_valid_d || ksign_corr_valid_d) ? c2v_tile_linear_state_d : '0;
    v2c_tile_linear_d = v2c_valid_d ? v2c_tile_linear_state_d : '0;
    c2v_h_block_idx_d = (c2v_valid_d || ksign_corr_valid_d) ? c2v_h_block_state_d : '0;
    c2v_tile_idx_d = (c2v_valid_d || ksign_corr_valid_d) ? c2v_tile_idx_state_d : '0;
    v2c_h_block_idx_d = v2c_valid_d ? v2c_h_block_state_d : '0;
    v2c_tile_idx_d = v2c_valid_d ? v2c_tile_idx_state_d : '0;
    clear_valid_d = clear_active_d;
    clear_addr_out_d = clear_addr_q;
    fill_buf_d = window_idx_d[0];
    active_buf_d = ~window_idx_d[0];
    final_iter_d = running_d && !clear_active_d && (int'(iter_count_d) == (I_MAX - 1));
    iter_first_cycle_d = running_d && !i_start && !clear_active_d && c2v_tile_active_d &&
                         !v2c_tile_active_d && (diag_idx_local_d == '0) && (q_seq_d == '0);
    iter_last_cycle_d = running_d && !clear_active_d &&
        ((!K_SIGN_ENABLE && !c2v_tile_active_d && v2c_tile_active_d &&
          (int'(diag_idx_local_d) == (int'(i_cfg_w) - 1)) && (int'(q_seq_d) == (Q_TILE - 1))) ||
         ksign_corr_last_active);

    if (!running_d) begin
      state_d = done_d ? DEC_DONE : DEC_WAIT_START;
    end else if (i_start || clear_active_d) begin
      state_d = DEC_ITER_CLEAR;
    end else if (ksign_corr_valid_d) begin
      state_d = DEC_ITER_KSIGN_CORR;
    end else if (!v2c_valid_d) begin
      state_d = DEC_ITER_C2V_PRIME;
    end else if (!c2v_valid_d) begin
      state_d = DEC_ITER_V2C_DRAIN;
    end else begin
      state_d = DEC_ITER_OVERLAP;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      running_q <= 1'b0;
      clear_q <= 1'b0;
      ksign_corr_q <= 1'b0;
      ksign_corr_guard_q <= '0;
      clear_addr_q <= '0;
      window_idx_q <= '0;
      diag_idx_local_q <= '0;
      q_seq_q <= '0;
      iter_count_q <= '0;
      c2v_tile_active_q <= 1'b0;
      v2c_tile_active_q <= 1'b0;
      c2v_tile_linear_state_q <= '0;
      v2c_tile_linear_state_q <= '0;
      c2v_h_block_state_q <= '0;
      c2v_tile_idx_state_q <= '0;
      v2c_h_block_state_q <= '0;
      v2c_tile_idx_state_q <= '0;
      done_q <= 1'b0;
      o_state <= DEC_WAIT_START;
      o_c2v_valid <= 1'b0;
      o_v2c_valid <= 1'b0;
      o_ksign_corr_valid <= 1'b0;
      o_c2v_tile_linear <= '0;
      o_v2c_tile_linear <= '0;
      o_c2v_h_block_idx <= '0;
      o_c2v_tile_idx <= '0;
      o_v2c_h_block_idx <= '0;
      o_v2c_tile_idx <= '0;
      o_diag_idx_local <= '0;
      o_q_seq <= '0;
      o_clear_valid <= 1'b0;
      o_clear_addr <= '0;
      o_fill_buf <= 1'b0;
      o_active_buf <= 1'b1;
      o_final_iter <= 1'b0;
      o_iter_first_cycle <= 1'b0;
      o_iter_last_cycle <= 1'b0;
      o_done <= 1'b0;
      o_iter_count <= '0;
    end else begin
      running_q <= running_d;
      clear_q <= clear_d;
      ksign_corr_q <= ksign_corr_d;
      ksign_corr_guard_q <= ksign_corr_guard_d;
      clear_addr_q <= clear_addr_d;
      window_idx_q <= window_idx_d;
      diag_idx_local_q <= diag_idx_local_d;
      q_seq_q <= q_seq_d;
      iter_count_q <= iter_count_d;
      c2v_tile_active_q <= c2v_tile_active_d;
      v2c_tile_active_q <= v2c_tile_active_d;
      c2v_tile_linear_state_q <= c2v_tile_linear_state_d;
      v2c_tile_linear_state_q <= v2c_tile_linear_state_d;
      c2v_h_block_state_q <= c2v_h_block_state_d;
      c2v_tile_idx_state_q <= c2v_tile_idx_state_d;
      v2c_h_block_state_q <= v2c_h_block_state_d;
      v2c_tile_idx_state_q <= v2c_tile_idx_state_d;
      done_q <= done_d;
      o_state <= state_d;
      o_c2v_valid <= c2v_valid_d;
      o_v2c_valid <= v2c_valid_d;
      o_ksign_corr_valid <= ksign_corr_valid_d;
      o_c2v_tile_linear <= c2v_tile_linear_d;
      o_v2c_tile_linear <= v2c_tile_linear_d;
      o_c2v_h_block_idx <= c2v_h_block_idx_d;
      o_c2v_tile_idx <= c2v_tile_idx_d;
      o_v2c_h_block_idx <= v2c_h_block_idx_d;
      o_v2c_tile_idx <= v2c_tile_idx_d;
      o_diag_idx_local <= diag_idx_local_d;
      o_q_seq <= q_seq_d;
      o_clear_valid <= clear_valid_d;
      o_clear_addr <= clear_addr_out_d;
      o_fill_buf <= fill_buf_d;
      o_active_buf <= active_buf_d;
      o_final_iter <= final_iter_d;
      o_iter_first_cycle <= iter_first_cycle_d;
      o_iter_last_cycle <= iter_last_cycle_d;
      o_done <= done_d;
      o_iter_count <= iter_count_d;
    end
  end
endmodule
