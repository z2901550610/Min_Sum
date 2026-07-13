`timescale 1ns / 1ps
// Fixed-cycle serial correction over the retained K-sign positions.
module k_sign_correction
  import bike_pkg::*;
(
    input  logic                         i_clk,
    input  logic                         i_rst_n,
    input  logic                         i_phase_valid,
    input  logic [        H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [       TILE_IDX_W-1:0] i_tile_idx,
    input  logic [ LANE_GROUP_IDX_W-1:0] i_lane_group_idx,
    input  logic [K_SIGN_SLOT_IDX_W-1:0] i_slot_idx,
    input  logic [       LANE_IDX_W-1:0] i_lane_idx,
    input  logic [          CFG_R_W-1:0] i_cfg_r,
    input  logic [          CFG_W_W-1:0] i_cfg_w,
    output logic                         o_record_read_valid[0:L-1],
    output logic [            COL_W-1:0] o_record_read_col_idx[0:L-1],
    input  logic [  K_SIGN_RECORD_W-1:0] i_record[0:L-1],
    output logic                         o_h_read_valid,
    output logic [        H_BLOCK_W-1:0] o_h_block_idx,
    output logic [       DIAG_IDX_W-1:0] o_h_diag_idx_local,
    input  logic [        ROW_IDX_W-1:0] i_h_base_row_idx,
    output logic                         o_flip_valid[0:L-1],
    output logic [      ROW_BANK_AW-1:0] o_flip_row_addr[0:L-1]
);

  localparam int SLOT_BASE_LSB = 1;

  logic                         request_valid;
  logic [          CFG_R_W-1:0] request_col_local;
  logic [            COL_W-1:0] request_col_global;
  logic                         record_valid_q;
  logic [        H_BLOCK_W-1:0] record_h_block_idx_q;
  logic [K_SIGN_SLOT_IDX_W-1:0] record_slot_idx_q;
  logic [          CFG_R_W-1:0] record_col_local_q;
  logic [       DIAG_IDX_W-1:0] selected_diag_idx;
  logic                         selected_diag_valid;
  logic                         base_valid_q;
  logic [          CFG_R_W-1:0] base_col_local_q;
  logic [          CFG_R_W-1:0] row_sum;
  logic [          CFG_R_W-1:0] row_idx;
  logic [       LANE_IDX_W-1:0] row_bank;
  logic [      ROW_BANK_AW-1:0] row_addr;

  function automatic int slot_lsb(input int slot_idx);
    begin
      slot_lsb = SLOT_BASE_LSB + (slot_idx * DIAG_IDX_W);
    end
  endfunction

  function automatic logic [COL_W-1:0] h_block_col_base(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                                        input  logic [CFG_R_W-1:0] cfg_r);
    logic [COL_W-1:0] cfg_r_ext;
    begin
      cfg_r_ext = COL_W'(cfg_r);
      unique case (h_block_idx)
        H_BLOCK_W'(0): h_block_col_base = '0;
        H_BLOCK_W'(1): h_block_col_base = cfg_r_ext;
        default:       h_block_col_base = cfg_r_ext + cfg_r_ext;
      endcase
    end
  endfunction

  always_comb begin
    logic [CFG_R_W-1:0] tile_base;
    logic [CFG_R_W-1:0] tile_offset;

    tile_base = CFG_R_W'(i_tile_idx) * CFG_R_W'(COLS_PER_TILE);
    tile_offset = (CFG_R_W'(i_lane_group_idx) << L_SHIFT) + CFG_R_W'(i_lane_idx);
    request_col_local = tile_base + tile_offset;
    request_col_global = h_block_col_base(i_h_block_idx, i_cfg_r) + COL_W'(request_col_local);
    request_valid = i_phase_valid && (request_col_local < CFG_R_W'(i_cfg_r)) &&
        (tile_offset < CFG_R_W'(COLS_PER_TILE));

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_record_read_valid[lane_idx]   = 1'b0;
      o_record_read_col_idx[lane_idx] = '0;
    end
    o_record_read_valid[0]   = request_valid;
    o_record_read_col_idx[0] = request_col_global;
  end

  always_comb begin
    selected_diag_idx = K_SIGN_DIAG_INVALID;
    for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
      if (record_slot_idx_q == K_SIGN_SLOT_IDX_W'(slot_idx)) begin
        selected_diag_idx = i_record[0][slot_lsb(slot_idx)+:DIAG_IDX_W];
      end
    end
    selected_diag_valid = record_valid_q && (selected_diag_idx != K_SIGN_DIAG_INVALID) &&
        (CFG_W_W'(selected_diag_idx) < i_cfg_w);
    o_h_read_valid = selected_diag_valid;
    o_h_block_idx = record_h_block_idx_q;
    o_h_diag_idx_local = selected_diag_valid ? selected_diag_idx : '0;
  end

  always_comb begin
    row_sum  = CFG_R_W'(i_h_base_row_idx) + base_col_local_q;
    row_idx  = (row_sum >= i_cfg_r) ? row_sum - i_cfg_r : row_sum;
    row_bank = LANE_IDX_W'(row_idx & CFG_R_W'(L - 1));
    row_addr = ROW_BANK_AW'(row_idx >> L_SHIFT);
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      record_valid_q <= 1'b0;
      record_h_block_idx_q <= '0;
      record_slot_idx_q <= '0;
      record_col_local_q <= '0;
      base_valid_q <= 1'b0;
      base_col_local_q <= '0;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        o_flip_valid[bank_idx] <= 1'b0;
        o_flip_row_addr[bank_idx] <= '0;
      end
    end else begin
      record_valid_q <= request_valid;
      record_h_block_idx_q <= i_h_block_idx;
      record_slot_idx_q <= i_slot_idx;
      record_col_local_q <= request_col_local;
      base_valid_q <= selected_diag_valid;
      base_col_local_q <= record_col_local_q;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        o_flip_valid[bank_idx] <= 1'b0;
        o_flip_row_addr[bank_idx] <= '0;
      end
      if (base_valid_q) begin
        o_flip_valid[row_bank] <= 1'b1;
        o_flip_row_addr[row_bank] <= row_addr;
      end
    end
  end
endmodule
