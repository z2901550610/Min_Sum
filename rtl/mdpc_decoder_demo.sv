module mdpc_decoder_demo (
  input  logic clk,
  input  logic rst_n,
  input  logic start,
  input  logic [H_SEL_W-1:0] h_sel,
  input  logic [N-1:0] x_in,
  output logic done,
  output logic success,
  output logic [N-1:0] x_out,
  output logic [$clog2(I_MAX + 1)-1:0] iter_count
);

  import mdpc_demo_pkg::*;

  localparam logic [VAR_W-1:0] LAST_VAR = VAR_W'(N - 1);
  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam int HIST_IDX_W = (I_MAX > 1) ? $clog2(I_MAX) : 1;
  localparam logic [EDGE_W-1:0] VNU_LAST_SLOT = EDGE_W'(((W + L) - 1) / L - 1);

  logic [DEC_STATE_W-1:0] state;
  logic [R-1:0] syndrome_reg;
  logic [R-1:0] syndrome_hist [0:I_MAX-1];

  logic [VAR_W-1:0] active_var_idx;
  logic [EDGE_W-1:0] scan_slot;
  logic [BANK_W-1:0] current_bank;
  logic [I_ENTRY_W-1:0] current_lane_entries [0:L-1][0:W-1];
  logic [LANE_COUNT_W-1:0] current_lane_count [0:L-1];
  logic [LANE_COUNT_W-1:0] current_scan_limit;
  logic [LANE_EDGE_W-1:0] current_lane_edges [0:L-1][0:W-1];
  logic [LANE_EDGE_W-1:0] lane_edge0;
  logic [LANE_EDGE_W-1:0] lane_edge1;
  logic lane_edge0_valid;
  logic lane_edge1_valid;
  logic [ROW_W-1:0] lane_edge0_row_global;
  logic [ROW_W-1:0] lane_edge1_row_global;
  logic [EDGE_W-1:0] lane_edge0_edge_slot;
  logic [EDGE_W-1:0] lane_edge1_edge_slot;

  logic c0_rd_bit;
  logic [N-1:0] c0_bits;
  logic [N-1:0] c1_bits;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_a1;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_rd_b1;
  logic [MSG_W-1:0] v2c_msg0;
  logic [MSG_W-1:0] v2c_msg1;
  logic v2c_sign0;
  logic v2c_sign1;
  logic c1_rd_unused;
  logic signed [MSG_W-1:0] t_msgs [0:W-1];

  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr0;
  logic [ROW_STATE_W-1:0] c2v_compact_msg_wr1;
  logic v2c_sign_wr0;
  logic v2c_sign_wr1;
  logic cnu_a_out_valid0;
  logic cnu_a_out_valid1;
  logic [MSG_W-1:0] c2v_msg0;
  logic [MSG_W-1:0] c2v_msg1;
  logic signed [MSG_W-1:0] c2v_msg_tc0;
  logic signed [MSG_W-1:0] c2v_msg_tc1;
  logic signed [APP_W-1:0] prior_msg;
  logic signed [APP_W-1:0] vnu_app;
  logic vnu_x_out;
  logic vnu_result_valid;
  logic vnu_start_var;
  logic vnu_last_accum;
  logic vnu_accum_valid0;
  logic vnu_accum_valid1;
  logic signed [MSG_W-1:0] vnu_accum_c2v0;
  logic signed [MSG_W-1:0] vnu_accum_c2v1;
  logic [MSG_W-1:0] vnu_u_next [0:W-1];
  logic [R-1:0] syndrome_next;
  logic cnu_a_flush_pending;
  logic cnu_a_issue_phase;
  logic [ROW_W-1:0] cnu_a_wr_row0;
  logic [ROW_W-1:0] cnu_a_wr_row1;
  logic [EDGE_W-1:0] cnu_a_wr_edge0;
  logic [EDGE_W-1:0] cnu_a_wr_edge1;
  logic [VAR_W-1:0] cnu_a_wr_var0;
  logic [VAR_W-1:0] cnu_a_wr_var1;

  logic advance_var;
  logic [ITER_W-1:0] next_iter_count;
  logic stop_decode;
  logic continue_decode;

  logic c0_load_en;
  logic c1_load_en;
  logic c1_wr_en;
  logic m_clear_en;
  logic m_wr_en0;
  logic m_wr_en1;
  logic s_clear_en;
  logic s_wr_en0;
  logic s_wr_en1;
  logic t_clear_en;
  logic t_wr_en0;
  logic t_wr_en1;
  logic u_init_en;
  logic u_wr_en;
  logic i_load_first_col_en;
  logic i_shift_en;

  // Top-level message-format convention:
  // - RAM U and the CNU-side interfaces use sign-magnitude messages.
  // - RAM T and the VNU-side interfaces use signed 2's-complement messages.
  // The only sign-magnitude <-> 2's-complement conversions are placed on
  // those two boundaries.

  assign current_bank = BANK_W'(int'(active_var_idx) / R);
  assign current_scan_limit =
    (current_lane_count[0] >= current_lane_count[1]) ? current_lane_count[0] : current_lane_count[1];
  assign lane_edge0 = current_lane_edges[0][scan_slot];
  assign lane_edge1 = current_lane_edges[1][scan_slot];
  assign lane_edge0_valid = lane_edge0[LANE_EDGE_VALID_BIT];
  assign lane_edge1_valid = lane_edge1[LANE_EDGE_VALID_BIT];
  assign lane_edge0_row_global = lane_edge0[LANE_EDGE_ROW_GLOBAL_LSB +: ROW_W];
  assign lane_edge1_row_global = lane_edge1[LANE_EDGE_ROW_GLOBAL_LSB +: ROW_W];
  assign lane_edge0_edge_slot = lane_edge0[LANE_EDGE_EDGE_SLOT_LSB +: EDGE_W];
  assign lane_edge1_edge_slot = lane_edge1[LANE_EDGE_EDGE_SLOT_LSB +: EDGE_W];
  assign prior_msg = c0_rd_bit ? -$signed(APP_W'(C_VAL)) : $signed(APP_W'(C_VAL));
  assign next_iter_count = iter_count + 1'b1;
  assign cnu_a_issue_phase = (state == DEC_CNU_A) && !cnu_a_flush_pending;
  assign c0_load_en = (state == DEC_LOAD);
  assign c1_load_en = (state == DEC_LOAD);
  assign c1_wr_en = (state == DEC_VNU) && vnu_result_valid;
  assign s_clear_en = (state == DEC_LOAD);
  assign t_clear_en = (state == DEC_LOAD);
  assign u_init_en = (state == DEC_LOAD);
  assign i_load_first_col_en = (state == DEC_LOAD);
  assign m_wr_en0 = cnu_a_out_valid0;
  assign m_wr_en1 = cnu_a_out_valid1;
  assign s_wr_en0 = cnu_a_out_valid0;
  assign s_wr_en1 = cnu_a_out_valid1;
  assign t_wr_en0 = (state == DEC_CNU_B) && lane_edge0_valid;
  assign t_wr_en1 = (state == DEC_CNU_B) && lane_edge1_valid;
  assign u_wr_en = (state == DEC_VNU) && vnu_result_valid;
  assign vnu_start_var = (state == DEC_VNU) && (scan_slot == '0);
  assign vnu_last_accum = (state == DEC_VNU) && (scan_slot == VNU_LAST_SLOT);

  function automatic logic signed [MSG_W-1:0] signmag_to_tc_msg(
    input logic [MSG_W-1:0] signmag_msg
  );
    logic signed [MSG_W-1:0] mag_tc;
    begin
      mag_tc = $signed({1'b0, signmag_msg[MSG_MAG_LSB +: D]});
      if (signmag_msg[MSG_SIGN_BIT] && (signmag_msg[MSG_MAG_LSB +: D] != '0)) begin
        signmag_to_tc_msg = -mag_tc;
      end else begin
        signmag_to_tc_msg = mag_tc;
      end
    end
  endfunction

  always_comb begin
    integer var_idx_local;
    integer bank_idx_local;
    integer col_idx_local;
    integer edge_idx_local;
    integer row_idx_local;

    syndrome_next = '0;
    bank_idx_local = 0;
    col_idx_local = 0;
    row_idx_local = 0;
    for (var_idx_local = 0; var_idx_local < N; var_idx_local++) begin
      if (c1_bits[var_idx_local]) begin
        bank_idx_local = var_idx_local / R;
        col_idx_local = var_idx_local % R;
        for (edge_idx_local = 0; edge_idx_local < W; edge_idx_local++) begin
          row_idx_local = (H_BASE[h_sel][bank_idx_local][edge_idx_local] + col_idx_local) % R;
          syndrome_next[row_idx_local] ^= 1'b1;
        end
      end
    end
  end

  always_comb begin
    advance_var = ((scan_slot + 1'b1) >= current_scan_limit);
    stop_decode = 1'b0;
    continue_decode = 1'b0;
    if (state == DEC_CHECK) begin
      stop_decode = (syndrome_next == '0) || (int'(next_iter_count) >= I_MAX);
      continue_decode = !stop_decode;
    end
  end

  always_comb begin
    integer edge_linear_idx;

    vnu_accum_valid0 = 1'b0;
    vnu_accum_valid1 = 1'b0;
    vnu_accum_c2v0 = '0;
    vnu_accum_c2v1 = '0;

    edge_linear_idx = int'(scan_slot) * L;
    if ((state == DEC_VNU) && (edge_linear_idx < W)) begin
      vnu_accum_valid0 = 1'b1;
      vnu_accum_c2v0 = t_msgs[edge_linear_idx];
    end

    edge_linear_idx = (int'(scan_slot) * L) + 1;
    if ((state == DEC_VNU) && (edge_linear_idx < W)) begin
      vnu_accum_valid1 = 1'b1;
      vnu_accum_c2v1 = t_msgs[edge_linear_idx];
    end
  end

  // Convert CNU_B's sign-magnitude c2v output once before caching it in RAM T.
  assign c2v_msg_tc0 = signmag_to_tc_msg(c2v_msg0);
  assign c2v_msg_tc1 = signmag_to_tc_msg(c2v_msg1);

  assign m_clear_en = (state == DEC_LOAD) || continue_decode;
  assign i_shift_en = (cnu_a_issue_phase || (state == DEC_CNU_B)) && advance_var;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnu_a_wr_row0 <= '0;
      cnu_a_wr_row1 <= '0;
      cnu_a_wr_edge0 <= '0;
      cnu_a_wr_edge1 <= '0;
      cnu_a_wr_var0 <= '0;
      cnu_a_wr_var1 <= '0;
    end else if (m_clear_en) begin
      cnu_a_wr_row0 <= '0;
      cnu_a_wr_row1 <= '0;
      cnu_a_wr_edge0 <= '0;
      cnu_a_wr_edge1 <= '0;
      cnu_a_wr_var0 <= '0;
      cnu_a_wr_var1 <= '0;
    end else if (cnu_a_issue_phase) begin
      cnu_a_wr_row0 <= lane_edge0_row_global;
      cnu_a_wr_row1 <= lane_edge1_row_global;
      cnu_a_wr_edge0 <= lane_edge0_edge_slot;
      cnu_a_wr_edge1 <= lane_edge1_edge_slot;
      cnu_a_wr_var0 <= active_var_idx;
      cnu_a_wr_var1 <= active_var_idx;
    end
  end

  mdpc_i_ram u_i_ram (
    .clk(clk),
    .rst_n(rst_n),
    .load_first_col_en(i_load_first_col_en),
    .shift_en(i_shift_en),
    .h_sel(h_sel),
    .bank_sel(current_bank),
    .lane_entries(current_lane_entries),
    .lane_count(current_lane_count)
  );

  mdpc_h_shift u_h_shift (
    .var_idx(active_var_idx),
    .lane_entries(current_lane_entries),
    .lane_count(current_lane_count),
    .lane_edges(current_lane_edges)
  );

  mdpc_bit_ram_c u_c0_ram (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(1'b0),
    .load_en(c0_load_en),
    .load_bits(x_in),
    .wr_en(1'b0),
    .wr_addr('0),
    .wr_bit(1'b0),
    .rd_addr(active_var_idx),
    .rd_bit(c0_rd_bit),
    .bits_out(c0_bits)
  );

  mdpc_bit_ram_c u_c1_ram (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(1'b0),
    .load_en(c1_load_en),
    .load_bits(x_in),
    .wr_en(c1_wr_en),
    .wr_addr(active_var_idx),
    .wr_bit(vnu_x_out),
    .rd_addr(active_var_idx),
    .rd_bit(c1_rd_unused),
    .bits_out(c1_bits)
  );

  mdpc_row_state_ram_m u_m_ram (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(m_clear_en),
    .rd_addr_a0(lane_edge0_row_global),
    .rd_addr_a1(lane_edge1_row_global),
    .rd_addr_b0(lane_edge0_row_global),
    .rd_addr_b1(lane_edge1_row_global),
    .rd_data_a0(c2v_compact_msg_rd_a0),
    .rd_data_a1(c2v_compact_msg_rd_a1),
    .rd_data_b0(c2v_compact_msg_rd_b0),
    .rd_data_b1(c2v_compact_msg_rd_b1),
    .wr_en0(m_wr_en0),
    .wr_addr0(cnu_a_wr_row0),
    .wr_data0(c2v_compact_msg_wr0),
    .wr_en1(m_wr_en1),
    .wr_addr1(cnu_a_wr_row1),
    .wr_data1(c2v_compact_msg_wr1)
  );

  mdpc_sign_ram_s u_s_ram (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(s_clear_en),
    .rd_var0(active_var_idx),
    .rd_edge0(lane_edge0_edge_slot),
    .rd_var1(active_var_idx),
    .rd_edge1(lane_edge1_edge_slot),
    .rd_sign0(v2c_sign0),
    .rd_sign1(v2c_sign1),
    .wr_en0(s_wr_en0),
    .wr_var0(cnu_a_wr_var0),
    .wr_edge0(cnu_a_wr_edge0),
    .wr_sign0(v2c_sign_wr0),
    .wr_en1(s_wr_en1),
    .wr_var1(cnu_a_wr_var1),
    .wr_edge1(cnu_a_wr_edge1),
    .wr_sign1(v2c_sign_wr1)
  );

  mdpc_msg_ram_t u_t_ram (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(t_clear_en),
    .rd_var(active_var_idx),
    .rd_msgs(t_msgs),
    .wr_en0(t_wr_en0),
    .wr_var0(active_var_idx),
    .wr_edge0(lane_edge0_edge_slot),
    .wr_msg0(c2v_msg_tc0),
    .wr_en1(t_wr_en1),
    .wr_var1(active_var_idx),
    .wr_edge1(lane_edge1_edge_slot),
    .wr_msg1(c2v_msg_tc1)
  );

  mdpc_msg_ram_u u_u_ram (
    .clk(clk),
    .rst_n(rst_n),
    .init_en(u_init_en),
    .init_bits(x_in),
    .rd_var0(active_var_idx),
    .rd_edge0(lane_edge0_edge_slot),
    .rd_var1(active_var_idx),
    .rd_edge1(lane_edge1_edge_slot),
    .rd_msg0(v2c_msg0),
    .rd_msg1(v2c_msg1),
    .wr_en(u_wr_en),
    .wr_var(active_var_idx),
    .wr_msgs(vnu_u_next)
  );

  mdpc_cnu_a u_cnu_a_lane0 (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(m_clear_en),
    .in_valid(cnu_a_issue_phase && lane_edge0_valid),
    .v2c_msg_in(v2c_msg0),
    .src_var_idx(active_var_idx),
    .c2v_compact_msg_in(c2v_compact_msg_rd_a0),
    .c2v_compact_msg_out(c2v_compact_msg_wr0),
    .v2c_sign_out(v2c_sign_wr0),
    .out_valid(cnu_a_out_valid0)
  );

  mdpc_cnu_a u_cnu_a_lane1 (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(m_clear_en),
    .in_valid(cnu_a_issue_phase && lane_edge1_valid),
    .v2c_msg_in(v2c_msg1),
    .src_var_idx(active_var_idx),
    .c2v_compact_msg_in(c2v_compact_msg_rd_a1),
    .c2v_compact_msg_out(c2v_compact_msg_wr1),
    .v2c_sign_out(v2c_sign_wr1),
    .out_valid(cnu_a_out_valid1)
  );

  mdpc_cnu_b u_cnu_b_lane0 (
    .c2v_compact_msg_in(c2v_compact_msg_rd_b0),
    .v2c_sign_in(v2c_sign0),
    .src_var_idx(active_var_idx),
    .c2v_msg_out(c2v_msg0)
  );

  mdpc_cnu_b u_cnu_b_lane1 (
    .c2v_compact_msg_in(c2v_compact_msg_rd_b1),
    .v2c_sign_in(v2c_sign1),
    .src_var_idx(active_var_idx),
    .c2v_msg_out(c2v_msg1)
  );

  mdpc_vnu u_vnu (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en((state == DEC_LOAD) || continue_decode),
    .start_var(vnu_start_var),
    .last_accum(vnu_last_accum),
    .prior_msg_in(prior_msg),
    .accum_valid0(vnu_accum_valid0),
    .accum_c2v0(vnu_accum_c2v0),
    .accum_valid1(vnu_accum_valid1),
    .accum_c2v1(vnu_accum_c2v1),
    .cached_c2v_in(t_msgs),
    .result_valid(vnu_result_valid),
    .app_out(vnu_app),
    .x_out(vnu_x_out),
    .u_next_out(vnu_u_next)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    integer row_idx_local;

    if (!rst_n) begin
      state <= DEC_IDLE;
      done <= 1'b0;
      success <= 1'b0;
      x_out <= '0;
      iter_count <= '0;
      active_var_idx <= '0;
      scan_slot <= '0;
      cnu_a_flush_pending <= 1'b0;
      syndrome_reg <= '0;

      for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
        syndrome_hist[row_idx_local] <= '0;
      end
    end else begin
      case (state)
        DEC_IDLE: begin
          done <= 1'b0;
          success <= 1'b0;
          if (start) begin
            state <= DEC_LOAD;
          end
        end

        DEC_LOAD: begin
          done <= 1'b0;
          success <= 1'b0;
          x_out <= x_in;
          iter_count <= '0;
          active_var_idx <= '0;
          scan_slot <= '0;
          cnu_a_flush_pending <= 1'b0;
          syndrome_reg <= '0;
          for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
            syndrome_hist[row_idx_local] <= '0;
          end
          state <= DEC_CNU_A;
        end

        DEC_CNU_A: begin
          if (cnu_a_flush_pending) begin
            cnu_a_flush_pending <= 1'b0;
            active_var_idx <= '0;
            scan_slot <= '0;
            state <= DEC_CNU_B;
          end else if (advance_var) begin
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              cnu_a_flush_pending <= 1'b1;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_CNU_B: begin
          if (advance_var) begin
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_VNU;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_VNU: begin
          if (vnu_result_valid) begin
            x_out[active_var_idx] <= vnu_x_out;
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_CHECK;
            end else begin
              active_var_idx <= active_var_idx + 1'b1;
            end
          end else begin
            scan_slot <= scan_slot + 1'b1;
          end
        end

        DEC_CHECK: begin
          syndrome_reg <= syndrome_next;
          syndrome_hist[iter_count[HIST_IDX_W-1:0]] <= syndrome_next;
          iter_count <= next_iter_count;

          if (stop_decode) begin
            done <= 1'b1;
            success <= (syndrome_next == '0);
            x_out <= c1_bits;
            state <= DEC_DONE;
          end else begin
            active_var_idx <= '0;
            scan_slot <= '0;
            cnu_a_flush_pending <= 1'b0;
            state <= DEC_CNU_A;
          end
        end

        DEC_DONE: begin
          done <= 1'b1;
          x_out <= c1_bits;
        end

        default: begin
          state <= DEC_IDLE;
          cnu_a_flush_pending <= 1'b0;
        end
      endcase
    end
  end
endmodule
