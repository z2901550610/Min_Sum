`timescale 1ns / 1ps
// Banked syndrome block RAM with synchronous read and synchronous write.
module ram_syndrome
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_we,
    input  logic [  ROW_IDX_W-1:0] i_wr_addr,
    input  logic                   i_wr_data,
    input  logic                   i_rd_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_rd_row_addr[0:L-1],
    output logic                   o_rd_data[0:L-1]
);

  logic bank_rdata[0:L-1];
  logic read_valid_q[0:L-1];

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
      logic bank_we;

      assign bank_we = i_we && (row_bank_of(i_wr_addr) == LANE_IDX_W'(bank_idx));

      ram_bram #(
          .DATA_W(1),
          .DEPTH (ROW_SEG_SIZE),
          .ADDR_W(ROW_BANK_AW)
      ) u_bram (
          .i_clk  (i_clk),
          .i_we   (bank_we),
          .i_waddr(row_addr_of(i_wr_addr)),
          .i_wdata(i_wr_data),
          .i_re   (i_rd_valid[bank_idx]),
          .i_raddr(i_rd_row_addr[bank_idx]),
          .o_rdata(bank_rdata[bank_idx])
      );

      always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
          read_valid_q[bank_idx] <= 1'b0;
        end else begin
          read_valid_q[bank_idx] <= i_rd_valid[bank_idx];
        end
      end

      assign o_rd_data[bank_idx] = read_valid_q[bank_idx] ? bank_rdata[bank_idx] : 1'b0;
    end
  endgenerate

`ifndef SYNTHESIS
  always @(posedge i_clk) begin
    if (i_we && (int'(i_wr_addr) >= R)) begin
      $fatal(1, "ram_syndrome write address out of range addr=%0d", i_wr_addr);
    end
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      if (i_rd_valid[bank_idx] && (int'(i_rd_row_addr[bank_idx]) >= ROW_SEG_SIZE)) begin
        $fatal(1, "ram_syndrome read address out of range bank=%0d addr=%0d", bank_idx,
               i_rd_row_addr[bank_idx]);
      end
    end
  end
`endif
endmodule
