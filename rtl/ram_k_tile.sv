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
      ram_bram #(
          .DATA_W(K_SIGN_WORK_RECORD_W),
          .DEPTH (K_SIGN_WORK_DEPTH),
          .ADDR_W(K_SIGN_WORK_AW)
      ) u_bram (
          .i_clk  (i_clk),
          .i_we   (i_write_valid[bank_idx]),
          .i_waddr(i_write_addr[bank_idx]),
          .i_wdata(i_write_record[bank_idx]),
          .i_re   (i_read_valid[bank_idx]),
          .i_raddr(i_read_addr[bank_idx]),
          .o_rdata(o_read_record[bank_idx])
      );
    end
  endgenerate
endmodule
