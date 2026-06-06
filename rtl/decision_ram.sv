`timescale 1ns / 1ps
// Banked final decision RAM with L write lanes and one async read port.
module decision_ram
  import bike_pkg::*;
(
    input  logic             i_clk,
    input  logic             i_we[0:L-1],
    input  logic [COL_W-1:0] i_write_col_idx[0:L-1],
    input  logic             i_wdata[0:L-1],
    input  logic [COL_W-1:0] i_read_col_idx,
    output logic             o_rdata
);

  localparam int DEC_BANK_DEPTH = (N + L - 1) / L;
  localparam int DEC_BANK_AW = (DEC_BANK_DEPTH > 1) ? $clog2(DEC_BANK_DEPTH) : 1;

  logic bank_rdata[0:L-1];

  function automatic logic [LANE_IDX_W-1:0] col_bank(input  logic [COL_W-1:0] col_idx);
    begin
      col_bank = LANE_IDX_W'(int'(col_idx) % L);
    end
  endfunction

  function automatic logic [DEC_BANK_AW-1:0] col_addr(input  logic [COL_W-1:0] col_idx);
    begin
      col_addr = DEC_BANK_AW'(int'(col_idx) / L);
    end
  endfunction

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      (* ram_style = "distributed" *) logic                   mem[0:DEC_BANK_DEPTH-1];
      logic                   bank_we;
      logic [DEC_BANK_AW-1:0] bank_waddr;
      logic                   bank_wdata;

      always_comb begin
        bank_we = 1'b0;
        bank_waddr = '0;
        bank_wdata = 1'b0;
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (i_we[lane_idx] && (int'(col_bank(i_write_col_idx[lane_idx])) == bank_idx)) begin
            bank_we = 1'b1;
            bank_waddr = col_addr(i_write_col_idx[lane_idx]);
            bank_wdata = i_wdata[lane_idx];
          end
        end
      end

      assign bank_rdata[bank_idx] = mem[col_addr(i_read_col_idx)];

      always_ff @(posedge i_clk) begin
        if (bank_we) begin
          mem[bank_waddr] <= bank_wdata;
        end
      end
    end
  endgenerate

  always_comb begin
    o_rdata = bank_rdata[int'(col_bank(i_read_col_idx))];
  end
endmodule
