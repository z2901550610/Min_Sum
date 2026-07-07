`timescale 1ns / 1ps
// Reconstructs an approximated V2C sign from a K-sign record and edge position.
module k_sign_reconstruct
  import bike_pkg::*;
(
    input  logic [K_SIGN_RECORD_W-1:0] i_record,
    input  logic [     DIAG_IDX_W-1:0] i_diag_idx_local,
    output logic                       o_sign
);

  localparam int BASE_SIGN_BIT = 0;
  localparam int SLOT_BASE_LSB = 1;

  logic hit;

  function automatic int slot_lsb(input int slot_idx);
    begin
      slot_lsb = SLOT_BASE_LSB + (slot_idx * K_SIGN_SLOT_W);
    end
  endfunction

  always_comb begin
    hit = 1'b0;
    for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
      if ((i_record[slot_lsb(
              slot_idx
          )+:DIAG_IDX_W] != K_SIGN_DIAG_INVALID) && (i_record[slot_lsb(
              slot_idx
          )+:DIAG_IDX_W] == i_diag_idx_local)) begin
        hit = 1'b1;
      end
    end
    o_sign = i_record[BASE_SIGN_BIT] ^ hit;
  end
endmodule
