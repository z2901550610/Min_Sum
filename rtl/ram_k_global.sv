`timescale 1ns / 1ps
// Banked double-buffered global RAM for compressed per-variable K-sign records.
module ram_k_global
  import bike_pkg::*;
(
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic                       i_read_pair_sel,
    input  logic                       i_read_valid[0:L-1],
    input  logic [          COL_W-1:0] i_read_col_idx[0:L-1],
    output logic [K_SIGN_RECORD_W-1:0] o_read_record[0:L-1],
    input  logic                       i_write_pair_sel,
    input  logic                       i_write_valid[0:L-1],
    input  logic [          COL_W-1:0] i_write_col_idx[0:L-1],
    input  logic [K_SIGN_RECORD_W-1:0] i_write_record[0:L-1]
);

  localparam int KSIGN_BANK_DEPTH = (N + L - 1) / L;
  localparam int KSIGN_BANK_AW = (KSIGN_BANK_DEPTH > 1) ? $clog2(KSIGN_BANK_DEPTH) : 1;

  logic [K_SIGN_RECORD_W-1:0] bank_rdata[  0:1][0:L-1];
  logic                       read_pair_sel_q;
  logic [     LANE_IDX_W-1:0] read_lane_bank_q[0:L-1];

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

  generate
    for (genvar pair_idx = 0; pair_idx < 2; pair_idx++) begin : g_pair
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        (* ram_style = "block" *) logic [K_SIGN_RECORD_W-1:0] mem[0:KSIGN_BANK_DEPTH-1];
        logic                       bank_re;
        logic [  KSIGN_BANK_AW-1:0] bank_raddr;
        logic                       bank_we;
        logic [  KSIGN_BANK_AW-1:0] bank_waddr;
        logic [K_SIGN_RECORD_W-1:0] bank_wdata;

        always_comb begin
          bank_re = 1'b0;
          bank_raddr = '0;
          bank_we = 1'b0;
          bank_waddr = '0;
          bank_wdata = '0;
          for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
            if (i_read_valid[lane_idx] && (int'(i_read_pair_sel) == pair_idx) && (col_bank(
                    i_read_col_idx[lane_idx]
                ) == LANE_IDX_W'(bank_idx))) begin
              bank_re = 1'b1;
              bank_raddr = col_addr(i_read_col_idx[lane_idx]);
            end
            if (i_write_valid[lane_idx] && (int'(i_write_pair_sel) == pair_idx) && (col_bank(
                    i_write_col_idx[lane_idx]
                ) == LANE_IDX_W'(bank_idx))) begin
              bank_we = 1'b1;
              bank_waddr = col_addr(i_write_col_idx[lane_idx]);
              bank_wdata = i_write_record[lane_idx];
            end
          end
        end

        always_ff @(posedge i_clk) begin
          if (bank_re) begin
            bank_rdata[pair_idx][bank_idx] <= mem[bank_raddr];
          end
          if (bank_we) begin
            mem[bank_waddr] <= bank_wdata;
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_pair_sel_q <= 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        read_lane_bank_q[lane_idx] <= '0;
      end
    end else begin
      read_pair_sel_q <= i_read_pair_sel;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        read_lane_bank_q[lane_idx] <= col_bank(i_read_col_idx[lane_idx]);
      end
    end
  end

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_read_record[lane_idx] = bank_rdata[read_pair_sel_q][read_lane_bank_q[lane_idx]];
    end
  end
endmodule
