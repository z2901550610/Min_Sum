`timescale 1ns / 1ps
// Final decision block RAM with L write banks and one synchronous read port.
module ram_decision
  import bike_pkg::*;
(
    input  logic             i_clk,
    input  logic             i_rst_n,
    input  logic             i_we[0:L-1],
    input  logic [COL_W-1:0] i_write_col_idx[0:L-1],
    input  logic             i_wdata[0:L-1],
    input  logic [COL_W-1:0] i_read_col_idx,
    output logic             o_rdata
);

  localparam int DEC_BANK_DEPTH = (N + L - 1) / L;
  localparam int DEC_BANK_AW = (DEC_BANK_DEPTH > 1) ? $clog2(DEC_BANK_DEPTH) : 1;

  logic                  bank_rdata[0:L-1];
  logic [LANE_IDX_W-1:0] read_bank_q;

  function automatic logic [LANE_IDX_W-1:0] col_bank(input  logic [COL_W-1:0] col_idx);
    begin
      col_bank = LANE_IDX_W'(int'(col_idx) & (L - 1));
    end
  endfunction

  function automatic logic [DEC_BANK_AW-1:0] col_addr(input  logic [COL_W-1:0] col_idx);
    begin
      col_addr = DEC_BANK_AW'(col_idx >> L_SHIFT);
    end
  endfunction

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      logic                   bank_we;
      logic [DEC_BANK_AW-1:0] bank_waddr;
      logic                   bank_wdata;
      logic                   bank_re;

      always_comb begin
        bank_we = 1'b0;
        bank_waddr = '0;
        bank_wdata = 1'b0;
        bank_re = col_bank(i_read_col_idx) == LANE_IDX_W'(bank_idx);
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (i_we[lane_idx] && (col_bank(
                  i_write_col_idx[lane_idx]
              ) == LANE_IDX_W'(bank_idx))) begin
            bank_we = 1'b1;
            bank_waddr = col_addr(i_write_col_idx[lane_idx]);
            bank_wdata = i_wdata[lane_idx];
          end
        end
      end

      ram_bram #(
          .DATA_W(1),
          .DEPTH (DEC_BANK_DEPTH),
          .ADDR_W(DEC_BANK_AW)
      ) u_bram (
          .i_clk  (i_clk),
          .i_we   (bank_we),
          .i_waddr(bank_waddr),
          .i_wdata(bank_wdata),
          .i_re   (bank_re),
          .i_raddr(col_addr(i_read_col_idx)),
          .o_rdata(bank_rdata[bank_idx])
      );
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_bank_q <= '0;
    end else begin
      read_bank_q <= col_bank(i_read_col_idx);
    end
  end

  assign o_rdata = bank_rdata[read_bank_q];

`ifndef SYNTHESIS
  always @(posedge i_clk) begin
    if (int'(i_read_col_idx) >= N) begin
      $fatal(1, "ram_decision read column out of range col=%0d", i_read_col_idx);
    end
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (i_we[lane_idx] && (int'(i_write_col_idx[lane_idx]) >= N)) begin
        $fatal(1, "ram_decision write column out of range lane=%0d col=%0d", lane_idx,
               i_write_col_idx[lane_idx]);
      end
    end
  end
`endif
endmodule
