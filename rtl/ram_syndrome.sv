`timescale 1ns / 1ps
// Syndrome bit store with one load/write port and row-banked registered reads.
module ram_syndrome
  import bike_pkg::*;
(
    input  logic                 i_clk,
    input  logic                 i_we,
    input  logic [ROW_IDX_W-1:0] i_write_row_idx,
    input  logic                 i_wdata,
    input  logic                 i_read_valid[0:L-1],
    input  logic [ROW_IDX_W-1:0] i_read_row_idx[0:L-1],
    output logic                 o_rdata[0:L-1]
);

`ifdef BIKE_SIM_DEBUG
  /* verilator lint_off UNUSEDSIGNAL */
  logic debug_mem[0:M_ROW_BANKS-1][0:M_ROW_BANK_DEPTH-1];
  /* verilator lint_on UNUSEDSIGNAL */
`endif

  logic [ M_ROW_BANK_IDX_W-1:0] read_bank[          0:L-1];
  logic [M_ROW_BANK_ADDR_W-1:0] read_addr[          0:L-1];
  logic [ M_ROW_BANK_IDX_W-1:0] read_bank_d1[          0:L-1];
  logic                         read_valid_d1[          0:L-1];
  logic [M_ROW_BANK_ADDR_W-1:0] bank_read_addr[0:M_ROW_BANKS-1];
  logic                         bank_we[0:M_ROW_BANKS-1];
  logic                         bank_rdata[0:M_ROW_BANKS-1];
  logic [ M_ROW_BANK_IDX_W-1:0] write_bank;
  logic [M_ROW_BANK_ADDR_W-1:0] write_addr;

  function automatic logic [M_ROW_BANK_IDX_W-1:0] bank_idx(
      input  logic [ROW_IDX_W-1:0] row_idx_global);
    begin
      if (M_ROW_BANKS == 1) begin
        bank_idx = '0;
      end else begin
        bank_idx = M_ROW_BANK_IDX_W'(int'(row_idx_global) % M_ROW_BANKS);
      end
    end
  endfunction

  function automatic logic [M_ROW_BANK_ADDR_W-1:0] bank_addr(
      input  logic [ROW_IDX_W-1:0] row_idx_global);
    begin
      bank_addr = M_ROW_BANK_ADDR_W'(int'(row_idx_global) / M_ROW_BANKS);
    end
  endfunction

  initial begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_bank_d1[lane_idx]  = '0;
      read_valid_d1[lane_idx] = 1'b0;
    end
  end

  always_comb begin
    write_bank = bank_idx(i_write_row_idx);
    write_addr = bank_addr(i_write_row_idx);

    for (int bank_idx_i = 0; bank_idx_i < M_ROW_BANKS; bank_idx_i++) begin
      bank_read_addr[bank_idx_i] = '0;
      bank_we[bank_idx_i] = i_we && (write_bank == M_ROW_BANK_IDX_W'(bank_idx_i));
    end

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_bank[lane_idx] = bank_idx(i_read_row_idx[lane_idx]);
      read_addr[lane_idx] = bank_addr(i_read_row_idx[lane_idx]);
      o_rdata[lane_idx]   = read_valid_d1[lane_idx] ? bank_rdata[read_bank_d1[lane_idx]] : 1'b0;
      if (i_read_valid[lane_idx]) begin
        bank_read_addr[read_bank[lane_idx]] = read_addr[lane_idx];
      end
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    for (int lhs = 0; lhs < L; lhs++) begin
      for (int rhs = lhs + 1; rhs < L; rhs++) begin
        if (i_read_valid[lhs] && i_read_valid[rhs] && (read_bank[lhs] == read_bank[rhs])) begin
          $fatal(1, "ram_syndrome read bank conflict bank=%0d", read_bank[lhs]);
        end
      end
    end
  end
`endif

  always_ff @(posedge i_clk) begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_bank_d1[lane_idx]  <= read_bank[lane_idx];
      read_valid_d1[lane_idx] <= i_read_valid[lane_idx];
    end
  end

  for (genvar bank_idx_i = 0; bank_idx_i < M_ROW_BANKS; bank_idx_i++) begin : g_syndrome_bank
    ram_1r1w_sync_read #(
        .DATA_W(1),
        .DEPTH(M_ROW_BANK_DEPTH),
        .ADDR_W(M_ROW_BANK_ADDR_W),
        .RAM_STYLE("block")
    ) u_mem (
        .i_clk(i_clk),
        .i_we(bank_we[bank_idx_i]),
        .i_write_addr(write_addr),
        .i_wdata(i_wdata),
        .i_read_addr(bank_read_addr[bank_idx_i]),
`ifdef BIKE_SIM_DEBUG
        .o_rdata(bank_rdata[bank_idx_i]),
        .o_debug_mem(debug_mem[bank_idx_i])
`else
        .o_rdata(bank_rdata[bank_idx_i])
`endif
    );
  end
endmodule
