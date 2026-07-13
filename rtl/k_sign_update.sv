`timescale 1ns / 1ps
// Unordered K-sign working-set update with a balanced worst-slot reduction tree.
module k_sign_update
  import bike_pkg::*;
(
    input  logic [K_SIGN_WORK_RECORD_W-1:0] i_record,
    input  logic                            i_clear,
    input  logic                            i_valid,
    input  logic [          DIAG_IDX_W-1:0] i_diag_idx_local,
    input  logic [               MSG_W-1:0] i_v2c_msg,
    input  logic                            i_base_sign,
    output logic [K_SIGN_WORK_RECORD_W-1:0] o_record
);

  localparam int BASE_SIGN_BIT = 0;
  localparam int SLOT_BASE_LSB = 1;
  localparam int TREE_LEAF_COUNT = 1 << $clog2(K_SIGN_K);
  localparam int TREE_LEVEL_COUNT = $clog2(TREE_LEAF_COUNT);
  localparam int TREE_IDX_W = (TREE_LEAF_COUNT > 1) ? $clog2(TREE_LEAF_COUNT) : 1;

  logic [DIAG_IDX_W-1:0] pos_in[      0:K_SIGN_K-1];
  logic [         D-1:0] mag_in[      0:K_SIGN_K-1];
  logic [         D-1:0] tree_mag[0:TREE_LEVEL_COUNT][0:TREE_LEAF_COUNT-1];
  logic [DIAG_IDX_W-1:0] tree_pos[0:TREE_LEVEL_COUNT][0:TREE_LEAF_COUNT-1];
  logic [TREE_IDX_W-1:0] tree_idx[0:TREE_LEVEL_COUNT][0:TREE_LEAF_COUNT-1];
  logic [DIAG_IDX_W-1:0] cand_pos;
  logic [         D-1:0] cand_mag;
  logic                  cand_valid;
  logic [TREE_IDX_W-1:0] worst_idx;
  logic [         D-1:0] worst_mag;
  logic [DIAG_IDX_W-1:0] worst_pos;
  logic                  candidate_take;

  function automatic int slot_lsb(input int slot_idx);
    begin
      slot_lsb = SLOT_BASE_LSB + (slot_idx * K_SIGN_WORK_SLOT_W);
    end
  endfunction

  function automatic logic left_is_worse(
      input  logic [D-1:0] left_mag, input  logic [DIAG_IDX_W-1:0] left_pos,
      input  logic [D-1:0] right_mag, input  logic [DIAG_IDX_W-1:0] right_pos);
    begin
      left_is_worse =
          (left_mag < right_mag) || ((left_mag == right_mag) && (left_pos >= right_pos));
    end
  endfunction

  always_comb begin
    cand_pos = i_diag_idx_local;
    cand_mag = i_v2c_msg[MSG_MAG_LSB+:D];
    cand_valid = i_valid && (i_v2c_msg[MSG_SIGN_BIT] ^ i_base_sign);
    o_record = i_clear ? '0 : i_record;
    o_record[BASE_SIGN_BIT] = i_base_sign;

    for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
      pos_in[slot_idx] = i_clear ? K_SIGN_DIAG_INVALID : i_record[slot_lsb(slot_idx)+:DIAG_IDX_W];
      mag_in[slot_idx] = i_clear ? '0 : i_record[slot_lsb(slot_idx)+DIAG_IDX_W+:D];
      o_record[slot_lsb(slot_idx)+:DIAG_IDX_W] = pos_in[slot_idx];
      o_record[slot_lsb(slot_idx)+DIAG_IDX_W+:D] = mag_in[slot_idx];
    end

    for (int leaf_idx = 0; leaf_idx < TREE_LEAF_COUNT; leaf_idx++) begin
      tree_mag[0][leaf_idx] = {D{1'b1}};
      tree_pos[0][leaf_idx] = '0;
      tree_idx[0][leaf_idx] = TREE_IDX_W'(leaf_idx);
      if (leaf_idx < K_SIGN_K) begin
        tree_mag[0][leaf_idx] = mag_in[leaf_idx];
        tree_pos[0][leaf_idx] = pos_in[leaf_idx];
      end
    end

    for (int level_idx = 1; level_idx <= TREE_LEVEL_COUNT; level_idx++) begin
      for (int node_idx = 0; node_idx < TREE_LEAF_COUNT; node_idx++) begin
        tree_mag[level_idx][node_idx] = {D{1'b1}};
        tree_pos[level_idx][node_idx] = '0;
        tree_idx[level_idx][node_idx] = {TREE_IDX_W{1'b1}};
        if (node_idx < (TREE_LEAF_COUNT >> level_idx)) begin
          if (left_is_worse(
                  tree_mag[level_idx-1][2*node_idx],
                  tree_pos[level_idx-1][2*node_idx],
                  tree_mag[level_idx-1][2*node_idx+1],
                  tree_pos[level_idx-1][2*node_idx+1]
              )) begin
            tree_mag[level_idx][node_idx] = tree_mag[level_idx-1][2*node_idx];
            tree_pos[level_idx][node_idx] = tree_pos[level_idx-1][2*node_idx];
            tree_idx[level_idx][node_idx] = tree_idx[level_idx-1][2*node_idx];
          end else begin
            tree_mag[level_idx][node_idx] = tree_mag[level_idx-1][2*node_idx+1];
            tree_pos[level_idx][node_idx] = tree_pos[level_idx-1][2*node_idx+1];
            tree_idx[level_idx][node_idx] = tree_idx[level_idx-1][2*node_idx+1];
          end
        end
      end
    end

    worst_idx = tree_idx[TREE_LEVEL_COUNT][0];
    worst_mag = tree_mag[TREE_LEVEL_COUNT][0];
    worst_pos = tree_pos[TREE_LEVEL_COUNT][0];
    candidate_take = cand_valid && ((worst_pos == K_SIGN_DIAG_INVALID) || (cand_mag > worst_mag));
    if (candidate_take) begin
      for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
        if (worst_idx == TREE_IDX_W'(slot_idx)) begin
          o_record[slot_lsb(slot_idx)+:DIAG_IDX_W]   = cand_pos;
          o_record[slot_lsb(slot_idx)+DIAG_IDX_W+:D] = cand_mag;
        end
      end
    end
  end
endmodule
