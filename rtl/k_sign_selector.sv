`timescale 1ns / 1ps
// Tile-local K-sign selection, working-state update, and compressed-record commit.
module k_sign_selector
  import bike_pkg::*;
(
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic [        CFG_W_W-1:0] i_cfg_w,
    input  logic                       i_valid[0:L-1],
    input  logic [          COL_W-1:0] i_col_idx[0:L-1],
    input  logic [     TILE_OFF_W-1:0] i_tile_offset[0:L-1],
    input  logic [     DIAG_IDX_W-1:0] i_diag_idx_local,
    input  logic [          MSG_W-1:0] i_v2c_msg[0:L-1],
    input  logic                       i_base_sign[0:L-1],
    output logic                       o_commit_valid[0:L-1],
    output logic [          COL_W-1:0] o_commit_col_idx[0:L-1],
    output logic [K_SIGN_RECORD_W-1:0] o_commit_record[0:L-1],
    input  logic                       i_corr_read_valid[0:L-1],
    input  logic [          COL_W-1:0] i_corr_col_idx[0:L-1],
    input  logic [     TILE_OFF_W-1:0] i_corr_tile_offset[0:L-1],
    input  logic [     DIAG_IDX_W-1:0] i_corr_diag_idx_local,
    output logic [K_SIGN_RECORD_W-1:0] o_corr_read_record[0:L-1],
    output logic                       o_corr_read_hit[0:L-1]
);

  localparam int ROUTE_W = 1 + COL_W + MSG_W + 1;

  logic                            work_read_valid[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] work_read_addr_common;
  logic [      K_SIGN_WORK_AW-1:0] work_read_addr[0:L-1];
  logic [K_SIGN_WORK_RECORD_W-1:0] work_read_record[0:L-1];
  logic                            work_write_valid[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] work_write_addr[0:L-1];
  logic [K_SIGN_WORK_RECORD_W-1:0] work_write_record[0:L-1];
  logic [               COL_W-1:0] routed_col_idx[0:L-1];
  logic [               MSG_W-1:0] routed_v2c_msg[0:L-1];
  logic                            routed_base_sign[0:L-1];
  logic [             ROUTE_W-1:0] route_in[0:L-1];
  logic [             ROUTE_W-1:0] route_out[0:L-1];
  logic [          LANE_IDX_W-1:0] route_shift;

  logic                            read_valid_q[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] read_addr_q[0:L-1];
  logic [               COL_W-1:0] col_idx_q[0:L-1];
  logic [          DIAG_IDX_W-1:0] diag_idx_local_q[0:L-1];
  logic [               MSG_W-1:0] v2c_msg_q[0:L-1];
  logic                            base_sign_q[0:L-1];
  logic                            last_diag_q[0:L-1];
  logic                            snapshot_write_valid[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] snapshot_write_addr[0:L-1];
  logic [ K_SIGN_POS_RECORD_W-1:0] snapshot_write_record[0:L-1];
  logic                            corr_work_read_valid[0:L-1];
  logic [      K_SIGN_WORK_AW-1:0] corr_work_read_addr_common;
  logic [      K_SIGN_WORK_AW-1:0] corr_work_read_addr[0:L-1];
  logic [ K_SIGN_POS_RECORD_W-1:0] corr_work_read_record[0:L-1];
  logic                            corr_read_valid_q[0:L-1];
  logic [                     0:0] corr_route_in[0:L-1];
  logic [                     0:0] corr_route_out[0:L-1];
  logic [     K_SIGN_RECORD_W-1:0] corr_record_bank[0:L-1];
  logic [     K_SIGN_RECORD_W-1:0] corr_record_route_out[0:L-1];
  logic [                     0:0] corr_hit_route_in[0:L-1];
  logic [                     0:0] corr_hit_route_out[0:L-1];
  logic [          LANE_IDX_W-1:0] corr_route_shift;
  logic [          LANE_IDX_W-1:0] corr_route_shift_q;
  logic [          DIAG_IDX_W-1:0] corr_diag_idx_local_q;

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
    route_shift = col_bank(i_col_idx[0]);
    // One scheduled lane group shares floor(tile_offset / L); only bank-dependent
    // payload crosses the rotation network.
    work_read_addr_common = work_addr(i_tile_offset[0]);
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      route_in[lane_idx] = {
        i_valid[lane_idx], i_col_idx[lane_idx], i_v2c_msg[lane_idx], i_base_sign[lane_idx]
      };
      {work_read_valid[lane_idx], routed_col_idx[lane_idx], routed_v2c_msg[lane_idx],
       routed_base_sign[lane_idx]} = route_out[lane_idx];
      work_read_addr[lane_idx] = work_read_addr_common;
    end
  end

  barrel_rotate #(
      .DATA_W(ROUTE_W)
  ) u_work_route (
      .i_data (route_in),
      .i_shift(LANE_IDX_W'('0 - route_shift)),
      .o_data (route_out)
  );

  always_comb begin
    corr_route_shift = col_bank(i_corr_col_idx[0]);
    // Correction uses the same lane-group address invariant as the main read.
    corr_work_read_addr_common = work_addr(i_corr_tile_offset[0]);
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      corr_route_in[lane_idx][0] = i_corr_read_valid[lane_idx];
      corr_work_read_valid[lane_idx] = corr_route_out[lane_idx][0];
      corr_work_read_addr[lane_idx] = corr_work_read_addr_common;
    end
  end

  barrel_rotate #(
      .DATA_W(1)
  ) u_corr_read_route (
      .i_data (corr_route_in),
      .i_shift(LANE_IDX_W'('0 - corr_route_shift)),
      .o_data (corr_route_out)
  );

  barrel_rotate #(
      .DATA_W(K_SIGN_RECORD_W)
  ) u_corr_read_return (
      .i_data (corr_record_bank),
      .i_shift(corr_route_shift_q),
      .o_data (corr_record_route_out)
  );

  barrel_rotate #(
      .DATA_W(1)
  ) u_corr_hit_return (
      .i_data (corr_hit_route_in),
      .i_shift(corr_route_shift_q),
      .o_data (corr_hit_route_out)
  );

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
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
        snapshot_write_valid[bank_idx] = o_commit_valid[bank_idx];
        snapshot_write_addr[bank_idx] = work_write_addr[bank_idx];
        snapshot_write_record[bank_idx] = '0;
        for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
          o_commit_record[bank_idx][record_slot_lsb(slot_idx)+:DIAG_IDX_W] =
              work_write_record[bank_idx][work_slot_lsb(slot_idx)+:DIAG_IDX_W];
          snapshot_write_record[bank_idx][slot_idx*DIAG_IDX_W+:DIAG_IDX_W] =
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
          corr_read_valid_q[bank_idx] <= 1'b0;
        end else begin
          read_valid_q[bank_idx] <= work_read_valid[bank_idx];
          read_addr_q[bank_idx] <= work_read_addr[bank_idx];
          col_idx_q[bank_idx] <= routed_col_idx[bank_idx];
          diag_idx_local_q[bank_idx] <= i_diag_idx_local;
          v2c_msg_q[bank_idx] <= routed_v2c_msg[bank_idx];
          base_sign_q[bank_idx] <= routed_base_sign[bank_idx];
          last_diag_q[bank_idx] <=
              DIAG_IDX_W'(i_diag_idx_local) == DIAG_IDX_W'(i_cfg_w - CFG_W_W'(1));
          corr_read_valid_q[bank_idx] <= corr_work_read_valid[bank_idx];
        end
      end

      always_comb begin
        corr_record_bank[bank_idx]  = '0;
        corr_hit_route_in[bank_idx] = '0;
        for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
          corr_record_bank[bank_idx][record_slot_lsb(slot_idx)+:DIAG_IDX_W] =
              corr_work_read_record[bank_idx][slot_idx*DIAG_IDX_W+:DIAG_IDX_W];
          if (corr_read_valid_q[bank_idx] &&
              (corr_work_read_record[bank_idx][slot_idx*DIAG_IDX_W+:DIAG_IDX_W] !=
               K_SIGN_DIAG_INVALID) &&
              (corr_work_read_record[bank_idx][slot_idx*DIAG_IDX_W+:DIAG_IDX_W] ==
               corr_diag_idx_local_q)) begin
            corr_hit_route_in[bank_idx][0] = 1'b1;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      corr_route_shift_q <= '0;
      corr_diag_idx_local_q <= '0;
    end else begin
      corr_route_shift_q <= corr_route_shift;
      corr_diag_idx_local_q <= i_corr_diag_idx_local;
    end
  end

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_corr_read_record[lane_idx] = corr_record_route_out[lane_idx];
      o_corr_read_hit[lane_idx] = corr_hit_route_out[lane_idx][0];
    end
  end

  ram_k_tile u_ram_k_tile (
      .i_clk                  (i_clk),
      .i_read_valid           (work_read_valid),
      .i_read_addr            (work_read_addr),
      .o_read_record          (work_read_record),
      .i_write_valid          (work_write_valid),
      .i_write_addr           (work_write_addr),
      .i_write_record         (work_write_record),
      .i_snapshot_write_valid (snapshot_write_valid),
      .i_snapshot_write_addr  (snapshot_write_addr),
      .i_snapshot_write_record(snapshot_write_record),
      .i_corr_read_valid      (corr_work_read_valid),
      .i_corr_read_addr       (corr_work_read_addr),
      .o_corr_read_record     (corr_work_read_record)
  );

`ifndef SYNTHESIS
  always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n) begin
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (i_valid[lane_idx] && (work_addr(
                i_tile_offset[lane_idx]
            ) != work_read_addr_common)) begin
          $fatal(1, "K-sign work addresses must be common within one lane group");
        end
        if (i_corr_read_valid[lane_idx] && (work_addr(
                i_corr_tile_offset[lane_idx]
            ) != corr_work_read_addr_common)) begin
          $fatal(1, "K-sign correction addresses must be common within one lane group");
        end
      end
    end
  end
`endif
endmodule
