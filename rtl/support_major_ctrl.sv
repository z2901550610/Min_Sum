`timescale 1ns / 1ps
// Fixed-window support-major tile scheduler.
module support_major_ctrl
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

  logic                    running;
  logic [WINDOW_IDX_W-1:0] window_idx;

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
    int c2v_tile_i;
    int v2c_tile_i;

    c2v_tile_i = int'(window_idx);
    v2c_tile_i = int'(window_idx) - 1;
    o_c2v_valid = running && (c2v_tile_i < TILES_TOTAL);
    o_v2c_valid = running && (int'(window_idx) > 0);
    o_c2v_tile_linear = o_c2v_valid ? TILE_ID_W'(c2v_tile_i) : '0;
    o_v2c_tile_linear = o_v2c_valid ? TILE_ID_W'(v2c_tile_i) : '0;
    o_c2v_h_block_idx = o_c2v_valid ? tile_h_block(c2v_tile_i) : '0;
    o_c2v_tile_idx = o_c2v_valid ? tile_idx_local(c2v_tile_i) : '0;
    o_v2c_h_block_idx = o_v2c_valid ? tile_h_block(v2c_tile_i) : '0;
    o_v2c_tile_idx = o_v2c_valid ? tile_idx_local(v2c_tile_i) : '0;
    o_fill_buf = window_idx[0];
    o_active_buf = ~window_idx[0];
    o_final_iter = running && (int'(o_iter_count) == (I_MAX - 1));
    o_iter_first_cycle = running && (window_idx == '0) && (o_one_idx == '0) && (o_q_seq == '0);
    o_iter_last_cycle = running && (int'(window_idx) == TILES_TOTAL) &&
                        (int'(o_one_idx) == (W - 1)) && (int'(o_q_seq) == (Q_TILE - 1));

    if (!running) begin
      o_state = o_done ? DEC_DONE : DEC_WAIT_START;
    end else if (!o_v2c_valid) begin
      o_state = DEC_ITER_C2V_PRIME;
    end else if (!o_c2v_valid) begin
      o_state = DEC_ITER_V2C_DRAIN;
    end else begin
      o_state = DEC_ITER_OVERLAP;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      running <= 1'b0;
      window_idx <= '0;
      o_one_idx <= '0;
      o_q_seq <= '0;
      o_done <= 1'b0;
      o_iter_count <= '0;
    end else begin
      if (i_start) begin
        running <= 1'b1;
        window_idx <= '0;
        o_one_idx <= '0;
        o_q_seq <= '0;
        o_done <= 1'b0;
        o_iter_count <= '0;
      end else if (running) begin
        if (o_iter_last_cycle) begin
          if (int'(o_iter_count) == (I_MAX - 1)) begin
            running <= 1'b0;
            o_done <= 1'b1;
            o_iter_count <= ITER_W'(I_MAX);
          end else begin
            window_idx <= '0;
            o_one_idx <= '0;
            o_q_seq <= '0;
            o_iter_count <= o_iter_count + ITER_W'(1);
          end
        end else if (int'(o_q_seq) == (Q_TILE - 1)) begin
          o_q_seq <= '0;
          if (int'(o_one_idx) == (W - 1)) begin
            o_one_idx  <= '0;
            window_idx <= window_idx + WINDOW_IDX_W'(1);
          end else begin
            o_one_idx <= o_one_idx + ONE_IDX_W'(1);
          end
        end else begin
          o_q_seq <= o_q_seq + Q_SEQ_W'(1);
        end
      end
    end
  end
endmodule
