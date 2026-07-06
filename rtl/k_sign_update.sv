`timescale 1ns / 1ps
// K-sign record update and edge-sign reconstruction helpers.
module k_sign_update
  import bike_pkg::*;
(
    input  logic [K_SIGN_RECORD_W-1:0] i_record,
    input  logic                       i_clear,
    input  logic                       i_valid,
    input  logic [     DIAG_IDX_W-1:0] i_diag_idx,
    input  logic [          MSG_W-1:0] i_v2c_msg,
    input  logic                       i_base_sign,
    output logic [K_SIGN_RECORD_W-1:0] o_record
);

  localparam int BASE_SIGN_BIT = 0;
  localparam int SLOT_BASE_LSB = 1;

  logic [DIAG_IDX_W-1:0] pos_in[0:K_SIGN_K-1];
  logic [         D-1:0] mag_in[0:K_SIGN_K-1];
  logic [DIAG_IDX_W-1:0] pos_next[0:K_SIGN_K-1];
  logic [         D-1:0] mag_next[0:K_SIGN_K-1];
  logic [DIAG_IDX_W-1:0] cand_pos;
  logic [         D-1:0] cand_mag;
  logic                  cand_valid;
  logic                  slot_take[0:K_SIGN_K-1];
  logic                  inserted;

  function automatic int slot_lsb(input int slot_idx);
    begin
      slot_lsb = SLOT_BASE_LSB + (slot_idx * K_SIGN_SLOT_W);
    end
  endfunction

  function automatic logic candidate_better(
      input  logic cand_is_valid, input  logic [D-1:0] candidate_mag,
      input  logic [DIAG_IDX_W-1:0] candidate_pos, input  logic [DIAG_IDX_W-1:0] slot_pos,
      input  logic [D-1:0] slot_mag);
    logic slot_valid;
    begin
      slot_valid = slot_pos != K_SIGN_DIAG_INVALID;
      candidate_better = cand_is_valid &&
          (!slot_valid || (candidate_mag > slot_mag) ||
           ((candidate_mag == slot_mag) && (candidate_pos < slot_pos)));
    end
  endfunction

  always_comb begin
    cand_pos = i_diag_idx;
    cand_mag = i_v2c_msg[MSG_MAG_LSB+:D];
    cand_valid = i_valid && (i_v2c_msg[MSG_SIGN_BIT] ^ i_base_sign);
    inserted = 1'b0;
    o_record = '0;
    o_record[BASE_SIGN_BIT] = i_base_sign;

    for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
      pos_in[slot_idx] = i_clear ? K_SIGN_DIAG_INVALID : i_record[slot_lsb(slot_idx)+:DIAG_IDX_W];
      mag_in[slot_idx] = i_clear ? '0 : i_record[slot_lsb(slot_idx)+DIAG_IDX_W+:D];
      pos_next[slot_idx] = pos_in[slot_idx];
      mag_next[slot_idx] = mag_in[slot_idx];
      slot_take[slot_idx] = 1'b0;
    end

    for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
      slot_take[slot_idx] = !inserted &&
          candidate_better(cand_valid, cand_mag, cand_pos, pos_in[slot_idx], mag_in[slot_idx]);
      if (slot_take[slot_idx]) begin
        pos_next[slot_idx] = cand_pos;
        mag_next[slot_idx] = cand_mag;
        for (int shift_idx = slot_idx + 1; shift_idx < K_SIGN_K; shift_idx++) begin
          pos_next[shift_idx] = pos_in[shift_idx-1];
          mag_next[shift_idx] = mag_in[shift_idx-1];
        end
        inserted = 1'b1;
      end
    end

    for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
      o_record[slot_lsb(slot_idx)+:DIAG_IDX_W]   = pos_next[slot_idx];
      o_record[slot_lsb(slot_idx)+DIAG_IDX_W+:D] = mag_next[slot_idx];
    end
  end
endmodule
