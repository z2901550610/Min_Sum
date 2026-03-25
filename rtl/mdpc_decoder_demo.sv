import mdpc_demo_pkg::*;

module mdpc_decoder_demo (
  input  logic clk,
  input  logic rst_n,
  input  logic start,
  input  logic [N-1:0] x_in,
  output logic done,
  output logic success,
  output logic [N-1:0] x_out,
  output logic [$clog2(I_MAX + 1)-1:0] iter_count
);

  localparam logic [VAR_W-1:0] LAST_VAR = var_idx_from_int(N - 1);
  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam int HIST_IDX_W = (I_MAX > 1) ? $clog2(I_MAX) : 1;

  logic [DEC_STATE_W-1:0] state;
  logic [R-1:0] syndrome_reg;
  logic [R-1:0] syndrome_hist [0:I_MAX-1];

  logic [VAR_W-1:0] active_var_idx;
  logic [EDGE_W-1:0] scan_slot;
  logic [0:0] current_bank;
  logic [I_ENTRY_W-1:0] current_lane_entries [0:L-1][0:W-1];
  logic [1:0] current_lane_count [0:L-1];
  logic [1:0] current_scan_limit;
  logic [LANE_EDGE_W-1:0] current_lane_edges [0:L-1][0:W-1];
  logic [LANE_EDGE_W-1:0] lane_edge0;
  logic [LANE_EDGE_W-1:0] lane_edge1;

  logic c0_rd_bit;
  logic [N-1:0] c0_bits;
  logic [N-1:0] c1_bits;
  logic [ROW_STATE_W-1:0] m_row_state_a0;
  logic [ROW_STATE_W-1:0] m_row_state_a1;
  logic [ROW_STATE_W-1:0] m_row_state_b0;
  logic [ROW_STATE_W-1:0] m_row_state_b1;
  logic [MSG_W-1:0] u_msg0;
  logic [MSG_W-1:0] u_msg1;
  logic s_sign0;
  logic s_sign1;
  logic c1_rd_unused;
  logic [MSG_W-1:0] t_msgs [0:W-1];

  logic [ROW_STATE_W-1:0] cnu_a_state0;
  logic [ROW_STATE_W-1:0] cnu_a_state1;
  logic cnu_a_sign0;
  logic cnu_a_sign1;
  logic [MSG_W-1:0] cnu_b_v0;
  logic [MSG_W-1:0] cnu_b_v1;
  logic signed [APP_W-1:0] vnu_gamma;
  logic signed [APP_W-1:0] vnu_app;
  logic vnu_x_out;
  logic [MSG_W-1:0] vnu_u_next [0:W-1];
  logic [R-1:0] syndrome_next;

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

  assign current_bank = active_var_idx[VAR_W-1];
  assign current_scan_limit =
    (current_lane_count[0] >= current_lane_count[1]) ? current_lane_count[0] : current_lane_count[1];
  assign lane_edge0 = current_lane_edges[0][scan_slot];
  assign lane_edge1 = current_lane_edges[1][scan_slot];
  assign vnu_gamma = app_from_int(gamma_from_bit(c0_rd_bit));
  assign syndrome_next = syndrome_vector(c1_bits);
  assign next_iter_count = iter_count + 1'b1;
  assign c0_load_en = (state == DEC_LOAD);
  assign c1_load_en = (state == DEC_LOAD);
  assign c1_wr_en = (state == DEC_VNU);
  assign s_clear_en = (state == DEC_LOAD);
  assign t_clear_en = (state == DEC_LOAD);
  assign u_init_en = (state == DEC_LOAD);
  assign i_load_first_col_en = (state == DEC_LOAD);
  assign m_wr_en0 = (state == DEC_CNU_A) && lane_edge_valid(lane_edge0);
  assign m_wr_en1 = (state == DEC_CNU_A) && lane_edge_valid(lane_edge1);
  assign s_wr_en0 = (state == DEC_CNU_A) && lane_edge_valid(lane_edge0);
  assign s_wr_en1 = (state == DEC_CNU_A) && lane_edge_valid(lane_edge1);
  assign t_wr_en0 = (state == DEC_CNU_B) && lane_edge_valid(lane_edge0);
  assign t_wr_en1 = (state == DEC_CNU_B) && lane_edge_valid(lane_edge1);
  assign u_wr_en = (state == DEC_VNU);

  always_comb begin
    advance_var = ((scan_slot + 1'b1) >= current_scan_limit);
    stop_decode = 1'b0;
    continue_decode = 1'b0;
    if (state == DEC_CHECK) begin
      stop_decode = (syndrome_next == '0) || (int'(next_iter_count) >= I_MAX);
      continue_decode = !stop_decode;
    end
  end

  assign m_clear_en = (state == DEC_LOAD) || continue_decode;
  assign i_shift_en = ((state == DEC_CNU_A) || (state == DEC_CNU_B)) && advance_var;

  mdpc_i_ram u_i_ram (
    .clk(clk),
    .rst_n(rst_n),
    .load_first_col_en(i_load_first_col_en),
    .shift_en(i_shift_en),
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
    .rd_addr_a0(lane_edge_row_global(lane_edge0)),
    .rd_addr_a1(lane_edge_row_global(lane_edge1)),
    .rd_addr_b0(lane_edge_row_global(lane_edge0)),
    .rd_addr_b1(lane_edge_row_global(lane_edge1)),
    .rd_data_a0(m_row_state_a0),
    .rd_data_a1(m_row_state_a1),
    .rd_data_b0(m_row_state_b0),
    .rd_data_b1(m_row_state_b1),
    .wr_en0(m_wr_en0),
    .wr_addr0(lane_edge_row_global(lane_edge0)),
    .wr_data0(cnu_a_state0),
    .wr_en1(m_wr_en1),
    .wr_addr1(lane_edge_row_global(lane_edge1)),
    .wr_data1(cnu_a_state1)
  );

  mdpc_sign_ram_s u_s_ram (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(s_clear_en),
    .rd_var0(active_var_idx),
    .rd_edge0(lane_edge_edge_slot(lane_edge0)),
    .rd_var1(active_var_idx),
    .rd_edge1(lane_edge_edge_slot(lane_edge1)),
    .rd_sign0(s_sign0),
    .rd_sign1(s_sign1),
    .wr_en0(s_wr_en0),
    .wr_var0(active_var_idx),
    .wr_edge0(lane_edge_edge_slot(lane_edge0)),
    .wr_sign0(cnu_a_sign0),
    .wr_en1(s_wr_en1),
    .wr_var1(active_var_idx),
    .wr_edge1(lane_edge_edge_slot(lane_edge1)),
    .wr_sign1(cnu_a_sign1)
  );

  mdpc_msg_ram_t u_t_ram (
    .clk(clk),
    .rst_n(rst_n),
    .clear_en(t_clear_en),
    .rd_var(active_var_idx),
    .rd_msgs(t_msgs),
    .wr_en0(t_wr_en0),
    .wr_var0(active_var_idx),
    .wr_edge0(lane_edge_edge_slot(lane_edge0)),
    .wr_msg0(cnu_b_v0),
    .wr_en1(t_wr_en1),
    .wr_var1(active_var_idx),
    .wr_edge1(lane_edge_edge_slot(lane_edge1)),
    .wr_msg1(cnu_b_v1)
  );

  mdpc_msg_ram_u u_u_ram (
    .clk(clk),
    .rst_n(rst_n),
    .init_en(u_init_en),
    .init_bits(x_in),
    .rd_var0(active_var_idx),
    .rd_edge0(lane_edge_edge_slot(lane_edge0)),
    .rd_var1(active_var_idx),
    .rd_edge1(lane_edge_edge_slot(lane_edge1)),
    .rd_msg0(u_msg0),
    .rd_msg1(u_msg1),
    .wr_en(u_wr_en),
    .wr_var(active_var_idx),
    .wr_msgs(vnu_u_next)
  );

  mdpc_cnu_a u_cnu_a_lane0 (
    .u_in(u_msg0),
    .var_idx(active_var_idx),
    .row_state_in(m_row_state_a0),
    .row_state_out(cnu_a_state0),
    .sign_bit_out(cnu_a_sign0)
  );

  mdpc_cnu_a u_cnu_a_lane1 (
    .u_in(u_msg1),
    .var_idx(active_var_idx),
    .row_state_in(m_row_state_a1),
    .row_state_out(cnu_a_state1),
    .sign_bit_out(cnu_a_sign1)
  );

  mdpc_cnu_b u_cnu_b_lane0 (
    .row_state_in(m_row_state_b0),
    .u_sign_in(s_sign0),
    .var_idx(active_var_idx),
    .v_out(cnu_b_v0)
  );

  mdpc_cnu_b u_cnu_b_lane1 (
    .row_state_in(m_row_state_b1),
    .u_sign_in(s_sign1),
    .var_idx(active_var_idx),
    .v_out(cnu_b_v1)
  );

  mdpc_vnu u_vnu (
    .gamma_in(vnu_gamma),
    .c2v_in(t_msgs),
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
          syndrome_reg <= '0;
          for (row_idx_local = 0; row_idx_local < I_MAX; row_idx_local++) begin
            syndrome_hist[row_idx_local] <= '0;
          end
          state <= DEC_CNU_A;
        end

        DEC_CNU_A: begin
          if (advance_var) begin
            scan_slot <= '0;
            if (active_var_idx == LAST_VAR) begin
              active_var_idx <= '0;
              state <= DEC_CNU_B;
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
          x_out[active_var_idx] <= vnu_x_out;
          if (active_var_idx == LAST_VAR) begin
            active_var_idx <= '0;
            state <= DEC_CHECK;
          end else begin
            active_var_idx <= active_var_idx + 1'b1;
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
            state <= DEC_CNU_A;
          end
        end

        DEC_DONE: begin
          done <= 1'b1;
          x_out <= c1_bits;
        end

        default: begin
          state <= DEC_IDLE;
        end
      endcase
    end
  end
endmodule
