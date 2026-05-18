`timescale 1ns / 1ps
// Steers RAM-S/RAM-T edge-message storage and prepares VNU inputs.
module edge_message_pipe
  import bike_pkg::*;
(
    input  logic                            i_clk,
    input  logic                            i_rst_n,
    input  logic                            i_start,
    input  logic                            i_c2v_read_d1,
    input  logic                            i_c2v_write_t,
    input  logic                            i_v2c_emit_to_cnu_a,
    input  logic                            i_vnu_accum_t,
    input  logic                            i_cnu_a_writeback,
    input  logic        [        COL_W-1:0] i_c2v_col_idx,
    input  logic        [        COL_W-1:0] i_c2v_read_col_d1,
    input  logic                            i_v2c_read,
    input  logic        [  ENTRY_POS_W-1:0] i_c2v_entry_pos,
    input  logic        [  ENTRY_POS_W-1:0] i_c2v_read_entry_pos_d1,
    input  logic        [  ENTRY_POS_W-1:0] i_v2c_entry_pos,
    input  logic        [  ENTRY_POS_W-1:0] i_v2c_read_entry_pos_d1,
    input  logic        [  ENTRY_POS_W-1:0] i_c2v_latched_entry_pos,
    input  logic                            i_c2v_latched_entry_pos_last,
    input  logic        [        COL_W-1:0] i_v2c_m_latched_col,
    input  logic        [  ENTRY_POS_W-1:0] i_v2c_m_latched_entry_pos,
    input  logic                            i_v2c_m_latched_group_valid[0:L-1],
    input  logic                            i_c2v_latched_group_valid[0:L-1],
    input  logic        [GROUP_COUNT_W-1:0] i_col_meta_slot_count,
    input  logic                            i_cnu_a_valid[0:L-1],
    input  logic                            i_cnu_a_sign[0:L-1],
    input  logic signed [        MSG_W-1:0] i_c2v_tc[0:L-1],
    input  logic        [     S_PACK_W-1:0] i_s_word_rdata[0:L-1],
    input  logic                            i_t_rvalid[0:L-1],
    input  logic        [        MSG_W-1:0] i_t_rdata[0:L-1],
    output logic                            o_s_rdata[0:L-1],
    output logic                            o_s_word_we[0:L-1],
    output logic        [S_WORD_ADDR_W-1:0] o_s_read_word_addr[0:L-1],
    output logic        [S_WORD_ADDR_W-1:0] o_s_write_word_addr[0:L-1],
    output logic        [     S_PACK_W-1:0] o_s_word_wdata[0:L-1],
    output logic                            o_t_push[0:L-1],
    output logic                            o_t_pop[0:L-1],
    output logic                            o_t_valid[0:L-1],
    output logic        [  ENTRY_POS_W-1:0] o_t_write_entry_idx,
    output logic        [  ENTRY_POS_W-1:0] o_t_read_entry_idx,
    output logic        [        MSG_W-1:0] o_t_wdata[0:L-1],
    output logic                            o_vnu_col_start,
    output logic                            o_vnu_col_end,
    output logic                            o_vnu_accum_valid[0:L-1],
    output logic                            o_vnu_prev_c2v_valid[0:L-1],
    output logic signed [        MSG_W-1:0] o_vnu_prev_c2v[0:L-1]
);

  logic [   S_PACK_W-1:0] s_write_word[0:L-1];
  logic                   s_we[0:L-1];
  logic [      COL_W-1:0] s_read_col_idx[0:L-1];
  logic [ENTRY_POS_W-1:0] s_read_entry_idx[0:L-1];
  logic [ENTRY_POS_W-1:0] s_write_entry_idx[0:L-1];
  logic                   s_wdata[0:L-1];
  logic                   s_read_word_load_pending[0:L-1];

  function automatic logic [S_WORD_ADDR_W-1:0] s_word_addr(input  logic [COL_W-1:0] col_idx,
                                                           input  logic [ENTRY_POS_W-1:0] entry_idx);
    begin
      s_word_addr = S_WORD_ADDR_W'(int'(col_idx) * S_WORDS_PER_COL + int'(entry_idx) / S_PACK_W);
    end
  endfunction

  function automatic logic [S_PACK_IDX_W-1:0] s_word_bit_idx(
      input  logic [ENTRY_POS_W-1:0] entry_idx);
    begin
      s_word_bit_idx = S_PACK_IDX_W'(int'(entry_idx) % S_PACK_W);
    end
  endfunction

  task automatic set_s_write_bit(input  logic [LANE_IDX_W-1:0] lane_idx,
                                 input  logic [ENTRY_POS_W-1:0] entry_idx, input  logic sign_bit);
    begin
      s_we[lane_idx] = 1'b1;
      s_write_entry_idx[lane_idx] = entry_idx;
      s_wdata[lane_idx] = sign_bit;
    end
  endtask

  assign o_vnu_col_start = i_vnu_accum_t && (i_c2v_latched_entry_pos == '0);
  assign o_vnu_col_end   = i_vnu_accum_t && i_c2v_latched_entry_pos_last;

  always_comb begin
    integer                    lane_idx;
    logic   [S_PACK_IDX_W-1:0] write_bit_idx;
    logic                      write_lane_last;

    write_bit_idx   = '0;
    write_lane_last = 1'b0;

    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      s_we[lane_idx] = 1'b0;
      s_read_col_idx[lane_idx] = i_c2v_read_d1 ? i_c2v_read_col_d1 : i_c2v_col_idx;
      s_read_entry_idx[lane_idx] = i_c2v_read_d1 ? i_c2v_read_entry_pos_d1 : i_c2v_entry_pos;
      s_write_entry_idx[lane_idx] = i_c2v_latched_entry_pos;
      s_wdata[lane_idx] = 1'b0;
      o_s_word_we[lane_idx] = 1'b0;
      o_s_read_word_addr[lane_idx] =
          s_word_addr(s_read_col_idx[lane_idx], s_read_entry_idx[lane_idx]);
      o_s_write_word_addr[lane_idx] = '0;
      o_s_word_wdata[lane_idx] = '0;
    end

    if (i_cnu_a_writeback) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        write_bit_idx = s_word_bit_idx(i_v2c_m_latched_entry_pos);
        write_lane_last = ((int'(i_v2c_m_latched_entry_pos) + 1) >= int'(i_col_meta_slot_count));
        o_s_write_word_addr[lane_idx] = s_word_addr(i_v2c_m_latched_col, i_v2c_m_latched_entry_pos);
        o_s_word_wdata[lane_idx] = s_write_word[lane_idx];
        o_s_word_we[lane_idx] = (write_bit_idx == S_PACK_IDX_W'(S_PACK_W - 1)) || write_lane_last;

        if (i_cnu_a_valid[lane_idx] && i_v2c_m_latched_group_valid[lane_idx]) begin
          set_s_write_bit(LANE_IDX_W'(lane_idx), i_v2c_m_latched_entry_pos, i_cnu_a_sign[lane_idx]);
          o_s_word_wdata[lane_idx] = s_write_word[lane_idx];
        end
      end
    end
  end

  always_comb begin
    integer lane_idx;

    o_t_write_entry_idx = i_c2v_latched_entry_pos;
    o_t_read_entry_idx  = i_v2c_read ? i_v2c_entry_pos : i_v2c_read_entry_pos_d1;
    for (lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_t_push[lane_idx]  = 1'b0;
      o_t_pop[lane_idx]   = 1'b0;
      o_t_valid[lane_idx] = 1'b0;
      o_t_wdata[lane_idx] = '0;
    end

    if (i_c2v_write_t) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        o_t_push[lane_idx] = 1'b1;
        if (i_c2v_latched_group_valid[lane_idx]) begin
          o_t_valid[lane_idx] = 1'b1;
          o_t_wdata[lane_idx] = i_c2v_tc[lane_idx];
        end
      end
    end

    if (i_v2c_emit_to_cnu_a) begin
      for (lane_idx = 0; lane_idx < L; lane_idx++) begin
        o_t_pop[lane_idx] = 1'b1;
      end
    end
  end

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_vnu_accum_valid[lane_idx] = i_vnu_accum_t && i_c2v_latched_group_valid[lane_idx];
      o_vnu_prev_c2v_valid[lane_idx] = i_v2c_emit_to_cnu_a && i_t_rvalid[lane_idx];
      o_vnu_prev_c2v[lane_idx] = $signed(i_t_rdata[lane_idx]);
    end
  end

  for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_sign_pack
    sign_bit_pack #(
        .PACK_W (S_PACK_W),
        .INDEX_W(S_PACK_IDX_W)
    ) u_sign_bit_pack (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_clear(i_start),
        .i_read_shift(i_c2v_write_t),
        .i_load_read_word(s_read_word_load_pending[lane_idx]),
        .i_read_word(i_s_word_rdata[lane_idx]),
        .i_write_en(s_we[lane_idx]),
        .i_write_bit_idx(s_word_bit_idx(s_write_entry_idx[lane_idx])),
        .i_write_bit(s_wdata[lane_idx]),
        .i_flush_write_word(o_s_word_we[lane_idx]),
        .o_read_bit(o_s_rdata[lane_idx]),
        .o_write_word(s_write_word[lane_idx])
    );
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        s_read_word_load_pending[lane_idx] <= 1'b0;
      end
    end else begin
      if (i_start) begin
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          s_read_word_load_pending[lane_idx] <= 1'b0;
        end
      end else begin
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          s_read_word_load_pending[lane_idx] <= i_c2v_read_d1 &&
              (s_word_bit_idx(s_read_entry_idx[lane_idx]) == '0);
        end
      end
    end
  end
endmodule
