`timescale 1ns / 1ps
// Banked tile-local RAM for K-sign selector working records.
module ram_k_tile
  import bike_pkg::*;
(
    input  logic                            i_clk,
    input  logic                            i_work_buf_sel,
    input  logic                            i_read_valid[0:L-1],
    input  logic [      K_SIGN_WORK_AW-1:0] i_read_addr[0:L-1],
    output logic [K_SIGN_WORK_RECORD_W-1:0] o_read_record[0:L-1],
    input  logic                            i_write_valid[0:L-1],
    input  logic [      K_SIGN_WORK_AW-1:0] i_write_addr[0:L-1],
    input  logic [K_SIGN_WORK_RECORD_W-1:0] i_write_record[0:L-1],
    input  logic                            i_corr_buf_sel,
    input  logic                            i_corr_read_valid[0:L-1],
    input  logic [      K_SIGN_WORK_AW-1:0] i_corr_read_addr[0:L-1],
    output logic [K_SIGN_WORK_RECORD_W-1:0] o_corr_read_record[0:L-1]
);

  logic                            work_buf_sel_q;
  logic                            corr_buf_sel_q;
  logic [K_SIGN_WORK_RECORD_W-1:0] buf_rdata[0:1][0:L-1];

  generate
    for (genvar buf_idx = 0; buf_idx < 2; buf_idx++) begin : g_buf
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        logic                      read_valid;
        logic [K_SIGN_WORK_AW-1:0] read_addr;

        always_comb begin
          read_valid = 1'b0;
          read_addr  = '0;
          if ((int'(i_work_buf_sel) == buf_idx) && i_read_valid[bank_idx]) begin
            read_valid = 1'b1;
            read_addr  = i_read_addr[bank_idx];
          end else if ((int'(i_corr_buf_sel) == buf_idx) && i_corr_read_valid[bank_idx]) begin
            read_valid = 1'b1;
            read_addr  = i_corr_read_addr[bank_idx];
          end
        end

        ram_bram #(
            .DATA_W         (K_SIGN_WORK_RECORD_W),
            .DEPTH          (K_SIGN_WORK_DEPTH),
            .ADDR_W         (K_SIGN_WORK_AW),
            .USE_DISTRIBUTED(1'b1)
        ) u_bram (
            .i_clk  (i_clk),
            .i_we   ((int'(i_work_buf_sel) == buf_idx) && i_write_valid[bank_idx]),
            .i_waddr(i_write_addr[bank_idx]),
            .i_wdata(i_write_record[bank_idx]),
            .i_re   (read_valid),
            .i_raddr(read_addr),
            .o_rdata(buf_rdata[buf_idx][bank_idx])
        );
      end
    end
  endgenerate

  always_ff @(posedge i_clk) begin
    work_buf_sel_q <= i_work_buf_sel;
    corr_buf_sel_q <= i_corr_buf_sel;
  end

  always_comb begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      o_read_record[bank_idx] = buf_rdata[work_buf_sel_q][bank_idx];
      o_corr_read_record[bank_idx] = buf_rdata[corr_buf_sel_q][bank_idx];
    end
  end
endmodule
