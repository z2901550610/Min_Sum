`timescale 1ns / 1ps
// Fixed-window tile scheduler with registered control outputs.
module tile_scheduler
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_start,
    output logic [DEC_STATE_W-1:0] o_state,
    output logic                   o_c2v_valid,
    output logic                   o_v2c_valid,
    output logic [  TILE_ID_W-1:0] o_c2v_tile_linear,
    output logic [  TILE_ID_W-1:0] o_v2c_tile_linear,
    output logic [  H_BLOCK_W-1:0] o_c2v_h_block_idx,
    output logic [ TILE_IDX_W-1:0] o_c2v_tile_idx,
    output logic [  H_BLOCK_W-1:0] o_v2c_h_block_idx,
    output logic [ TILE_IDX_W-1:0] o_v2c_tile_idx,
    output logic [  ONE_IDX_W-1:0] o_one_idx,
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

  logic                    running_q;
  logic                    clear_q;
  logic [ ROW_BANK_AW-1:0] clear_addr_q;
  logic [WINDOW_IDX_W-1:0] window_idx_q;
  logic [   ONE_IDX_W-1:0] one_idx_q;
  logic [     Q_SEQ_W-1:0] q_seq_q;
  logic [      ITER_W-1:0] iter_count_q;
  logic                    done_q;

  logic                    running_d;
  logic                    clear_d;
  logic [ ROW_BANK_AW-1:0] clear_addr_d;
  logic [WINDOW_IDX_W-1:0] window_idx_d;
  logic [   ONE_IDX_W-1:0] one_idx_d;
  logic [     Q_SEQ_W-1:0] q_seq_d;
  logic [      ITER_W-1:0] iter_count_d;
  logic                    done_d;

  logic [ DEC_STATE_W-1:0] state_d;
  logic                    c2v_valid_d;
  logic                    v2c_valid_d;
  logic [   TILE_ID_W-1:0] c2v_tile_linear_d;
  logic [   TILE_ID_W-1:0] v2c_tile_linear_d;
  logic [   H_BLOCK_W-1:0] c2v_h_block_idx_d;
  logic [  TILE_IDX_W-1:0] c2v_tile_idx_d;
  logic [   H_BLOCK_W-1:0] v2c_h_block_idx_d;
  logic [  TILE_IDX_W-1:0] v2c_tile_idx_d;
  logic                    clear_valid_d;
  logic [ ROW_BANK_AW-1:0] clear_addr_out_d;
  logic                    fill_buf_d;
  logic                    active_buf_d;
  logic                    final_iter_d;
  logic                    iter_first_cycle_d;
  logic                    iter_last_cycle_d;

  function automatic logic [H_BLOCK_W-1:0] tile_h_block(input int tile_linear);
    begin
      tile_h_block = H_BLOCK_W'(tile_linear / TILE_COUNT);
    end
  endfunction

  function automatic logic [TILE_IDX_W-1:0] tile_idx_local(input int tile_linear);
    begin
      tile_idx_local = TILE_IDX_W'(tile_linear % TILE_COUNT);
    end
  endfunction

  always_comb begin
    logic current_last_cycle;

    running_d = running_q;
    clear_d = clear_q;
    clear_addr_d = clear_addr_q;
    window_idx_d = window_idx_q;
    one_idx_d = one_idx_q;
    q_seq_d = q_seq_q;
    iter_count_d = iter_count_q;
    done_d = done_q;

    current_last_cycle = running_q && !clear_q && (int'(window_idx_q) == TILES_TOTAL) &&
                         (int'(one_idx_q) == (W - 1)) &&
                         (int'(q_seq_q) == (Q_TILE - 1));

    if (i_start) begin
      running_d = 1'b1;
      clear_d = 1'b1;
      clear_addr_d = '0;
      window_idx_d = '0;
      one_idx_d = '0;
      q_seq_d = '0;
      iter_count_d = '0;
      done_d = 1'b0;
    end else if (running_q) begin
      if (clear_q) begin
        if (int'(clear_addr_q) == (ROW_SEG_SIZE - 1)) begin
          clear_d = 1'b0;
          clear_addr_d = '0;
        end else begin
          clear_addr_d = clear_addr_q + ROW_BANK_AW'(1);
        end
      end else if (current_last_cycle) begin
        if (int'(iter_count_q) == (I_MAX - 1)) begin
          running_d = 1'b0;
          done_d = 1'b1;
          iter_count_d = ITER_W'(I_MAX);
        end else begin
          clear_d = 1'b1;
          clear_addr_d = '0;
          window_idx_d = '0;
          one_idx_d = '0;
          q_seq_d = '0;
          iter_count_d = iter_count_q + ITER_W'(1);
        end
      end else if (int'(q_seq_q) == (Q_TILE - 1)) begin
        q_seq_d = '0;
        if (int'(one_idx_q) == (W - 1)) begin
          one_idx_d = '0;
          window_idx_d = window_idx_q + WINDOW_IDX_W'(1);
        end else begin
          one_idx_d = one_idx_q + ONE_IDX_W'(1);
        end
      end else begin
        q_seq_d = q_seq_q + Q_SEQ_W'(1);
      end
    end
  end

  always_comb begin
    int   c2v_tile_i;
    int   v2c_tile_i;
    logic clear_active_d;

    clear_active_d = running_q && clear_q;
    c2v_tile_i = int'(window_idx_d);
    v2c_tile_i = int'(window_idx_d) - 1;
    c2v_valid_d = running_d && !i_start && !clear_active_d && (c2v_tile_i < TILES_TOTAL);
    v2c_valid_d = running_d && !i_start && !clear_active_d && (int'(window_idx_d) > 0);
    c2v_tile_linear_d = c2v_valid_d ? TILE_ID_W'(c2v_tile_i) : '0;
    v2c_tile_linear_d = v2c_valid_d ? TILE_ID_W'(v2c_tile_i) : '0;
    c2v_h_block_idx_d = c2v_valid_d ? tile_h_block(c2v_tile_i) : '0;
    c2v_tile_idx_d = c2v_valid_d ? tile_idx_local(c2v_tile_i) : '0;
    v2c_h_block_idx_d = v2c_valid_d ? tile_h_block(v2c_tile_i) : '0;
    v2c_tile_idx_d = v2c_valid_d ? tile_idx_local(v2c_tile_i) : '0;
    clear_valid_d = clear_active_d;
    clear_addr_out_d = clear_addr_q;
    fill_buf_d = window_idx_d[0];
    active_buf_d = ~window_idx_d[0];
    final_iter_d = running_d && !clear_active_d && (int'(iter_count_d) == (I_MAX - 1));
    iter_first_cycle_d =
        running_d && !i_start && !clear_active_d && (window_idx_d == '0) && (one_idx_d == '0) &&
        (q_seq_d == '0);
    iter_last_cycle_d = running_d && !clear_active_d && (int'(window_idx_d) == TILES_TOTAL) &&
                        (int'(one_idx_d) == (W - 1)) && (int'(q_seq_d) == (Q_TILE - 1));

    if (!running_d) begin
      state_d = done_d ? DEC_DONE : DEC_WAIT_START;
    end else if (i_start || clear_active_d) begin
      state_d = DEC_ITER_CLEAR;
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
      clear_addr_q <= '0;
      window_idx_q <= '0;
      one_idx_q <= '0;
      q_seq_q <= '0;
      iter_count_q <= '0;
      done_q <= 1'b0;
      o_state <= DEC_WAIT_START;
      o_c2v_valid <= 1'b0;
      o_v2c_valid <= 1'b0;
      o_c2v_tile_linear <= '0;
      o_v2c_tile_linear <= '0;
      o_c2v_h_block_idx <= '0;
      o_c2v_tile_idx <= '0;
      o_v2c_h_block_idx <= '0;
      o_v2c_tile_idx <= '0;
      o_one_idx <= '0;
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
      clear_addr_q <= clear_addr_d;
      window_idx_q <= window_idx_d;
      one_idx_q <= one_idx_d;
      q_seq_q <= q_seq_d;
      iter_count_q <= iter_count_d;
      done_q <= done_d;
      o_state <= state_d;
      o_c2v_valid <= c2v_valid_d;
      o_v2c_valid <= v2c_valid_d;
      o_c2v_tile_linear <= c2v_tile_linear_d;
      o_v2c_tile_linear <= v2c_tile_linear_d;
      o_c2v_h_block_idx <= c2v_h_block_idx_d;
      o_c2v_tile_idx <= c2v_tile_idx_d;
      o_v2c_h_block_idx <= v2c_h_block_idx_d;
      o_v2c_tile_idx <= v2c_tile_idx_d;
      o_one_idx <= one_idx_d;
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
