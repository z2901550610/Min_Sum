`timescale 1ns / 1ps
// Banked tile-local RAM for K-sign selector working records.
module ram_k_tile
  import bike_pkg::*;
(
    input  logic                            i_clk,
    input  logic                            i_read_valid[0:L-1],
    input  logic [      K_SIGN_WORK_AW-1:0] i_read_addr[0:L-1],
    output logic [K_SIGN_WORK_RECORD_W-1:0] o_read_record[0:L-1],
    input  logic                            i_write_valid[0:L-1],
    input  logic [      K_SIGN_WORK_AW-1:0] i_write_addr[0:L-1],
    input  logic [K_SIGN_WORK_RECORD_W-1:0] i_write_record[0:L-1]
);

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      (* ram_style = "block" *) logic [K_SIGN_WORK_RECORD_W-1:0] mem[0:K_SIGN_WORK_DEPTH-1];

      always_ff @(posedge i_clk) begin
        if (i_read_valid[bank_idx]) begin
          o_read_record[bank_idx] <= mem[i_read_addr[bank_idx]];
        end
        if (i_write_valid[bank_idx]) begin
          mem[i_write_addr[bank_idx]] <= i_write_record[bank_idx];
        end
      end
    end
  endgenerate
endmodule
