`timescale 1ns / 1ps
// Banked double-buffered K-sign record RAM indexed by variable column.
module ram_k_sign
  import bike_pkg::*;
(
    input  logic                  i_clk,
    input  logic                  i_rst_n,
    input  logic                  i_c2v_pair_sel,
    input  logic                  i_c2v_valid[0:L-1],
    input  logic [     COL_W-1:0] i_c2v_col_idx[0:L-1],
    input  logic [DIAG_IDX_W-1:0] i_c2v_diag_idx,
    output logic                  o_c2v_sign[0:L-1],
    output logic                  o_c2v_hit[0:L-1],
    input  logic                  i_v2c_pair_sel,
    input  logic                  i_v2c_valid[0:L-1],
    input  logic [     COL_W-1:0] i_v2c_col_idx[0:L-1],
    input  logic [DIAG_IDX_W-1:0] i_v2c_diag_idx,
    input  logic [     MSG_W-1:0] i_v2c_msg[0:L-1],
    input  logic                  i_v2c_base_sign[0:L-1]
);

  localparam int KSIGN_BANK_DEPTH = (N + L - 1) / L;
  localparam int KSIGN_BANK_AW = (KSIGN_BANK_DEPTH > 1) ? $clog2(KSIGN_BANK_DEPTH) : 1;

  logic [K_SIGN_RECORD_W-1:0] c2v_bank_rdata[  0:1][0:L-1];
  logic [K_SIGN_RECORD_W-1:0] v2c_bank_rdata[  0:1][0:L-1];
  logic [K_SIGN_RECORD_W-1:0] v2c_record_next[  0:1][0:L-1];
  logic                       v2c_read_valid[  0:1][0:L-1];
  logic                       c2v_pair_sel_q;
  logic                       v2c_pair_sel_q;
  logic [     DIAG_IDX_W-1:0] c2v_diag_idx_q;
  logic [     LANE_IDX_W-1:0] c2v_lane_bank_q[0:L-1];
  logic                       c2v_lane_valid_q[0:L-1];
  logic [     DIAG_IDX_W-1:0] v2c_diag_idx_q[  0:1][0:L-1];
  logic [          MSG_W-1:0] v2c_msg_q[  0:1][0:L-1];
  logic                       v2c_base_sign_q[  0:1][0:L-1];
  logic [  KSIGN_BANK_AW-1:0] v2c_waddr_q[  0:1][0:L-1];

  function automatic logic [LANE_IDX_W-1:0] col_bank(input  logic [COL_W-1:0] col_idx);
    begin
      col_bank = LANE_IDX_W'(int'(col_idx) & (L - 1));
    end
  endfunction

  function automatic logic [KSIGN_BANK_AW-1:0] col_addr(input  logic [COL_W-1:0] col_idx);
    begin
      col_addr = KSIGN_BANK_AW'(col_idx >> L_SHIFT);
    end
  endfunction

  function automatic int slot_lsb(input int slot_idx);
    begin
      slot_lsb = 1 + (slot_idx * K_SIGN_SLOT_W);
    end
  endfunction

  generate
    for (genvar pair_idx = 0; pair_idx < 2; pair_idx++) begin : g_pair
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        (* ram_style = "block" *) logic [K_SIGN_RECORD_W-1:0] mem[0:KSIGN_BANK_DEPTH-1];
        logic                       c2v_bank_re;
        logic                       v2c_bank_re;
        logic [  KSIGN_BANK_AW-1:0] c2v_bank_raddr;
        logic [  KSIGN_BANK_AW-1:0] v2c_bank_raddr;
        logic                       v2c_bank_input_valid;
        logic [          COL_W-1:0] v2c_bank_col_idx;
        logic [          MSG_W-1:0] v2c_bank_msg;
        logic                       v2c_bank_base_sign;

        always_comb begin
          c2v_bank_re = 1'b0;
          v2c_bank_re = 1'b0;
          c2v_bank_raddr = '0;
          v2c_bank_raddr = '0;
          v2c_bank_input_valid = 1'b0;
          v2c_bank_col_idx = '0;
          v2c_bank_msg = '0;
          v2c_bank_base_sign = 1'b0;

          for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
            if (i_c2v_valid[lane_idx] && (int'(i_c2v_pair_sel) == pair_idx) && (int'(col_bank(
                    i_c2v_col_idx[lane_idx]
                )) == bank_idx)) begin
              c2v_bank_re = 1'b1;
              c2v_bank_raddr = col_addr(i_c2v_col_idx[lane_idx]);
            end
            if (i_v2c_valid[lane_idx] && (int'(i_v2c_pair_sel) == pair_idx) && (int'(col_bank(
                    i_v2c_col_idx[lane_idx]
                )) == bank_idx)) begin
              v2c_bank_input_valid = 1'b1;
              v2c_bank_col_idx = i_v2c_col_idx[lane_idx];
              v2c_bank_msg = i_v2c_msg[lane_idx];
              v2c_bank_base_sign = i_v2c_base_sign[lane_idx];
            end
          end

          v2c_bank_re = v2c_bank_input_valid;
          v2c_bank_raddr = col_addr(v2c_bank_col_idx);
        end

        k_sign_update u_k_sign_update (
            .i_record   (v2c_bank_rdata[pair_idx][bank_idx]),
            .i_clear    (v2c_diag_idx_q[pair_idx][bank_idx] == '0),
            .i_valid    (v2c_read_valid[pair_idx][bank_idx]),
            .i_diag_idx (v2c_diag_idx_q[pair_idx][bank_idx]),
            .i_v2c_msg  (v2c_msg_q[pair_idx][bank_idx]),
            .i_base_sign(v2c_base_sign_q[pair_idx][bank_idx]),
            .o_record   (v2c_record_next[pair_idx][bank_idx])
        );

        always_ff @(posedge i_clk or negedge i_rst_n) begin
          if (!i_rst_n) begin
            v2c_read_valid[pair_idx][bank_idx] <= 1'b0;
            v2c_diag_idx_q[pair_idx][bank_idx] <= '0;
            v2c_msg_q[pair_idx][bank_idx] <= '0;
            v2c_base_sign_q[pair_idx][bank_idx] <= 1'b0;
            v2c_waddr_q[pair_idx][bank_idx] <= '0;
          end else begin
            v2c_read_valid[pair_idx][bank_idx] <= v2c_bank_re;
            v2c_diag_idx_q[pair_idx][bank_idx] <= i_v2c_diag_idx;
            v2c_msg_q[pair_idx][bank_idx] <= v2c_bank_msg;
            v2c_base_sign_q[pair_idx][bank_idx] <= v2c_bank_base_sign;
            v2c_waddr_q[pair_idx][bank_idx] <= v2c_bank_raddr;
          end
        end

        always_ff @(posedge i_clk) begin
          if (c2v_bank_re) begin
            c2v_bank_rdata[pair_idx][bank_idx] <= mem[c2v_bank_raddr];
          end
          if (v2c_bank_re) begin
            v2c_bank_rdata[pair_idx][bank_idx] <= mem[v2c_bank_raddr];
          end
          if (v2c_read_valid[pair_idx][bank_idx]) begin
            mem[v2c_waddr_q[pair_idx][bank_idx]] <= v2c_record_next[pair_idx][bank_idx];
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      c2v_pair_sel_q <= 1'b0;
      v2c_pair_sel_q <= 1'b0;
      c2v_diag_idx_q <= '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_lane_bank_q[lane_idx]  <= '0;
        c2v_lane_valid_q[lane_idx] <= 1'b0;
      end
    end else begin
      c2v_pair_sel_q <= i_c2v_pair_sel;
      v2c_pair_sel_q <= i_v2c_pair_sel;
      c2v_diag_idx_q <= i_c2v_diag_idx;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        c2v_lane_bank_q[lane_idx]  <= col_bank(i_c2v_col_idx[lane_idx]);
        c2v_lane_valid_q[lane_idx] <= i_c2v_valid[lane_idx];
      end
    end
  end

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      logic pair_idx;
      logic sign_hit;
      pair_idx = c2v_pair_sel_q;
      sign_hit = 1'b0;
      for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
        if ((c2v_bank_rdata[pair_idx][c2v_lane_bank_q[lane_idx]][slot_lsb(
                slot_idx
            )+:DIAG_IDX_W] != K_SIGN_DIAG_INVALID) &&
                (c2v_bank_rdata[pair_idx][c2v_lane_bank_q[lane_idx]][slot_lsb(
                slot_idx
            )+:DIAG_IDX_W] == c2v_diag_idx_q)) begin
          sign_hit = 1'b1;
        end
      end
      o_c2v_sign[lane_idx] = c2v_lane_valid_q[lane_idx] ?
          (c2v_bank_rdata[pair_idx][c2v_lane_bank_q[lane_idx]][0] ^ sign_hit) : 1'b0;
      o_c2v_hit[lane_idx] = c2v_lane_valid_q[lane_idx] ? sign_hit : 1'b0;
    end
  end

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_v2c_pair_sel_q;
  assign unused_v2c_pair_sel_q = v2c_pair_sel_q;
  /* verilator lint_on UNUSEDSIGNAL */
endmodule
