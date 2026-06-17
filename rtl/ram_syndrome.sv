`timescale 1ns / 1ps
// Banked distributed syndrome RAM with combinational read and synchronous write.
module ram_syndrome
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_we,
    input  logic [  ROW_IDX_W-1:0] i_wr_addr,
    input  logic                   i_wr_data,
    input  logic                   i_rd_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_rd_row_addr[0:L-1],
    output logic                   o_rd_data[0:L-1]
);

  function automatic logic [LANE_IDX_W-1:0] row_bank_of(input  logic [ROW_IDX_W-1:0] row_idx);
    begin
      row_bank_of = LANE_IDX_W'(int'(row_idx) & (L - 1));
    end
  endfunction

  function automatic logic [ROW_BANK_AW-1:0] row_addr_of(input  logic [ROW_IDX_W-1:0] row_idx);
    begin
      row_addr_of = ROW_BANK_AW'(row_idx >> L_SHIFT);
    end
  endfunction

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      (* ram_style = "distributed" *) logic mem[0:ROW_SEG_SIZE-1];

      assign o_rd_data[bank_idx] = i_rd_valid[bank_idx] ? mem[i_rd_row_addr[bank_idx]] : 1'b0;

      always_ff @(posedge i_clk) begin
        if (i_we && (int'(row_bank_of(i_wr_addr)) == bank_idx)) begin
          mem[row_addr_of(i_wr_addr)] <= i_wr_data;
        end
      end
    end
  endgenerate
endmodule
