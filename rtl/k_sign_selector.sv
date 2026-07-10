`timescale 1ns / 1ps
// Tile-local K-sign selection, working-state update, and compressed-record commit.
module k_sign_selector
  import bike_pkg::*;
(
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic [        CFG_W_W-1:0] i_cfg_w,
    input  logic                       i_pair_sel,
    input  logic                       i_valid[0:L-1],
    input  logic [          COL_W-1:0] i_col_idx[0:L-1],
    input  logic [     TILE_OFF_W-1:0] i_tile_offset[0:L-1],
    input  logic [     DIAG_IDX_W-1:0] i_diag_idx_local,
    input  logic [          MSG_W-1:0] i_v2c_msg[0:L-1],
    input  logic                       i_base_sign[0:L-1],
    output logic                       o_commit_pair_sel,
    output logic                       o_commit_valid[0:L-1],
    output logic [          COL_W-1:0] o_commit_col_idx[0:L-1],
    output logic [K_SIGN_RECORD_W-1:0] o_commit_record[0:L-1]
);

  logic                            work_read_valid[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] work_read_addr[0:L-1];
  logic [K_SIGN_WORK_RECORD_W-1:0] work_read_record[0:L-1];
  logic                            work_write_valid[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] work_write_addr[0:L-1];
  logic [K_SIGN_WORK_RECORD_W-1:0] work_write_record[0:L-1];

  logic                            read_valid_q[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] read_addr_q[0:L-1];
  logic [               COL_W-1:0] col_idx_q[0:L-1];
  logic [          DIAG_IDX_W-1:0] diag_idx_local_q[0:L-1];
  logic [               MSG_W-1:0] v2c_msg_q[0:L-1];
  logic                            base_sign_q[0:L-1];
  logic                            last_diag_q[0:L-1];
  logic                            pair_sel_q;

  function automatic logic [LANE_IDX_W-1:0] col_bank(input  logic [COL_W-1:0] col_idx);
    begin
      col_bank = LANE_IDX_W'(int'(col_idx) & (L - 1));
    end
  endfunction

  function automatic logic [K_SIGN_WORK_AW-1:0] work_addr(input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      work_addr = K_SIGN_WORK_AW'(tile_offset >> L_SHIFT);
    end
  endfunction

  function automatic int record_slot_lsb(input int slot_idx);
    begin
      record_slot_lsb = 1 + (slot_idx * DIAG_IDX_W);
    end
  endfunction

  function automatic int work_slot_lsb(input int slot_idx);
    begin
      work_slot_lsb = 1 + (slot_idx * K_SIGN_WORK_SLOT_W);
    end
  endfunction

  always_comb begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      work_read_valid[bank_idx] = 1'b0;
      work_read_addr[bank_idx]  = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (i_valid[lane_idx] && (col_bank(i_col_idx[lane_idx]) == LANE_IDX_W'(bank_idx))) begin
          work_read_valid[bank_idx] = 1'b1;
          work_read_addr[bank_idx]  = work_addr(i_tile_offset[lane_idx]);
        end
      end
    end
  end

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      logic [COL_W-1:0] bank_col_idx;
      logic [MSG_W-1:0] bank_v2c_msg;
      logic             bank_base_sign;

      always_comb begin
        bank_col_idx   = '0;
        bank_v2c_msg   = '0;
        bank_base_sign = 1'b0;
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (i_valid[lane_idx] && (col_bank(i_col_idx[lane_idx]) == LANE_IDX_W'(bank_idx))) begin
            bank_col_idx   = i_col_idx[lane_idx];
            bank_v2c_msg   = i_v2c_msg[lane_idx];
            bank_base_sign = i_base_sign[lane_idx];
          end
        end
      end

      k_sign_update u_k_sign_update (
          .i_record        (work_read_record[bank_idx]),
          .i_clear         (diag_idx_local_q[bank_idx] == '0),
          .i_valid         (read_valid_q[bank_idx]),
          .i_diag_idx_local(diag_idx_local_q[bank_idx]),
          .i_v2c_msg       (v2c_msg_q[bank_idx]),
          .i_base_sign     (base_sign_q[bank_idx]),
          .o_record        (work_write_record[bank_idx])
      );

      always_comb begin
        work_write_valid[bank_idx] = read_valid_q[bank_idx];
        work_write_addr[bank_idx] = read_addr_q[bank_idx];
        o_commit_valid[bank_idx] = read_valid_q[bank_idx] && last_diag_q[bank_idx];
        o_commit_col_idx[bank_idx] = col_idx_q[bank_idx];
        o_commit_record[bank_idx] = '0;
        o_commit_record[bank_idx][0] = work_write_record[bank_idx][0];
        for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
          o_commit_record[bank_idx][record_slot_lsb(slot_idx)+:DIAG_IDX_W] =
              work_write_record[bank_idx][work_slot_lsb(slot_idx)+:DIAG_IDX_W];
        end
      end

      always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
          read_valid_q[bank_idx] <= 1'b0;
          read_addr_q[bank_idx] <= '0;
          col_idx_q[bank_idx] <= '0;
          diag_idx_local_q[bank_idx] <= '0;
          v2c_msg_q[bank_idx] <= '0;
          base_sign_q[bank_idx] <= 1'b0;
          last_diag_q[bank_idx] <= 1'b0;
        end else begin
          read_valid_q[bank_idx] <= work_read_valid[bank_idx];
          read_addr_q[bank_idx] <= work_read_addr[bank_idx];
          col_idx_q[bank_idx] <= bank_col_idx;
          diag_idx_local_q[bank_idx] <= i_diag_idx_local;
          v2c_msg_q[bank_idx] <= bank_v2c_msg;
          base_sign_q[bank_idx] <= bank_base_sign;
          last_diag_q[bank_idx] <=
              DIAG_IDX_W'(i_diag_idx_local) == DIAG_IDX_W'(i_cfg_w - CFG_W_W'(1));
        end
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      pair_sel_q <= 1'b0;
    end else begin
      pair_sel_q <= i_pair_sel;
    end
  end

  assign o_commit_pair_sel = pair_sel_q;

  ram_k_tile u_ram_k_tile (
      .i_clk         (i_clk),
      .i_read_valid  (work_read_valid),
      .i_read_addr   (work_read_addr),
      .o_read_record (work_read_record),
      .i_write_valid (work_write_valid),
      .i_write_addr  (work_write_addr),
      .i_write_record(work_write_record)
  );
endmodule
