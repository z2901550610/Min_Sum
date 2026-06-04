`timescale 1ns / 1ps
// Row-banked RAM-M pair with L independent issue ports.
module ram_m_bank_array
  import bike_pkg::*;
(
    input  logic                  i_clk,
    input  logic                  i_read_valid[0:L-1],
    input  logic [ ROW_IDX_W-1:0] i_read_row_idx_global[0:L-1],
    input  logic                  i_we[0:L-1],
    input  logic [ ROW_IDX_W-1:0] i_write_row_idx_global[0:L-1],
    input  logic                  i_epoch,
    input  logic [COMP_C2V_W-1:0] i_wdata[0:L-1],
    output logic [COMP_C2V_W-1:0] o_rdata[0:L-1],
    output logic                  o_epoch[0:L-1]
);

  localparam int M_WORD_EPOCH_BIT = COMP_C2V_W;
  localparam int M_WORD_W = COMP_C2V_W + 1;

  logic [         M_WORD_W-1:0] bank_rword[0:M_ROW_BANKS-1];
  logic [M_ROW_BANK_ADDR_W-1:0] bank_read_addr[0:M_ROW_BANKS-1];
  logic                         bank_we[0:M_ROW_BANKS-1];
  logic [M_ROW_BANK_ADDR_W-1:0] bank_write_addr[0:M_ROW_BANKS-1];
  logic [         M_WORD_W-1:0] bank_wdata[0:M_ROW_BANKS-1];
  logic [ M_ROW_BANK_IDX_W-1:0] read_bank[          0:L-1];
  logic [ M_ROW_BANK_IDX_W-1:0] read_bank_d1[          0:L-1];
  logic [ M_ROW_BANK_IDX_W-1:0] write_bank[          0:L-1];
  logic [M_ROW_BANK_ADDR_W-1:0] read_addr[          0:L-1];
  logic [M_ROW_BANK_ADDR_W-1:0] write_addr[          0:L-1];
`ifdef BIKE_SIM_DEBUG
  /* verilator lint_off UNUSEDSIGNAL */
  logic [M_WORD_W-1:0] bank_debug_mem[0:M_ROW_BANKS-1][0:M_ROW_BANK_DEPTH-1];
  /* verilator lint_on UNUSEDSIGNAL */
`endif

  localparam bit M_ROW_BANKS_POW2 = ((M_ROW_BANKS & (M_ROW_BANKS - 1)) == 0);

  function automatic logic [M_ROW_BANK_IDX_W-1:0] bank_idx(
      input  logic [ROW_IDX_W-1:0] row_idx_global);
    begin
      if (M_ROW_BANKS == 1) begin
        bank_idx = '0;
      end else if (M_ROW_BANKS_POW2) begin
        bank_idx = row_idx_global[M_ROW_BANK_IDX_W-1:0];
      end else begin
        bank_idx = M_ROW_BANK_IDX_W'(int'(row_idx_global) % M_ROW_BANKS);
      end
    end
  endfunction

  function automatic logic [M_ROW_BANK_ADDR_W-1:0] bank_addr(
      input  logic [ROW_IDX_W-1:0] row_idx_global);
    begin
      if (M_ROW_BANKS == 1) begin
        bank_addr = M_ROW_BANK_ADDR_W'(row_idx_global);
      end else if (M_ROW_BANKS_POW2) begin
        bank_addr = M_ROW_BANK_ADDR_W'(row_idx_global >> M_ROW_BANK_IDX_W);
      end else begin
        bank_addr = M_ROW_BANK_ADDR_W'(int'(row_idx_global) / M_ROW_BANKS);
      end
    end
  endfunction

  initial begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_bank_d1[lane_idx] = '0;
    end
  end

  always_comb begin
    for (int bank = 0; bank < M_ROW_BANKS; bank++) begin
      bank_read_addr[bank] = '0;
      bank_we[bank] = 1'b0;
      bank_write_addr[bank] = '0;
      bank_wdata[bank] = {i_epoch, COMP_C2V_INIT};
    end

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_bank[lane_idx] = bank_idx(i_read_row_idx_global[lane_idx]);
      write_bank[lane_idx] = bank_idx(i_write_row_idx_global[lane_idx]);
      read_addr[lane_idx] = bank_addr(i_read_row_idx_global[lane_idx]);
      write_addr[lane_idx] = bank_addr(i_write_row_idx_global[lane_idx]);
      o_rdata[lane_idx] = bank_rword[read_bank_d1[lane_idx]][COMP_C2V_W-1:0];
      o_epoch[lane_idx] = bank_rword[read_bank_d1[lane_idx]][M_WORD_EPOCH_BIT];

      if (i_read_valid[lane_idx]) begin
        bank_read_addr[read_bank[lane_idx]] = read_addr[lane_idx];
      end
      if (i_we[lane_idx]) begin
        bank_we[write_bank[lane_idx]] = 1'b1;
        bank_write_addr[write_bank[lane_idx]] = write_addr[lane_idx];
        bank_wdata[write_bank[lane_idx]] = {i_epoch, i_wdata[lane_idx]};
      end
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    for (int lhs = 0; lhs < L; lhs++) begin
      for (int rhs = lhs + 1; rhs < L; rhs++) begin
        if (i_read_valid[lhs] && i_read_valid[rhs] && (read_bank[lhs] == read_bank[rhs])) begin
          $fatal(1, "ram_m_bank_array read bank conflict bank=%0d", read_bank[lhs]);
        end
        if (i_we[lhs] && i_we[rhs] && (write_bank[lhs] == write_bank[rhs])) begin
          $fatal(1, "ram_m_bank_array write bank conflict bank=%0d", write_bank[lhs]);
        end
      end
    end
  end
`endif

  always_ff @(posedge i_clk) begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_bank_d1[lane_idx] <= read_bank[lane_idx];
    end
  end

  for (genvar bank_idx_i = 0; bank_idx_i < M_ROW_BANKS; bank_idx_i++) begin : g_bank
    ram_m_bank_mem u_mem (
        .i_clk(i_clk),
        .i_we(bank_we[bank_idx_i]),
        .i_write_addr(bank_write_addr[bank_idx_i]),
        .i_wdata(bank_wdata[bank_idx_i]),
        .i_read_addr(bank_read_addr[bank_idx_i]),
`ifdef BIKE_SIM_DEBUG
        .o_rdata(bank_rword[bank_idx_i]),
        .o_debug_mem(bank_debug_mem[bank_idx_i])
`else
        .o_rdata(bank_rword[bank_idx_i])
`endif
    );
  end
endmodule

/* verilator lint_off DECLFILENAME */
// One shallow RAM-M row bank. Keeping this as a dedicated one-dimensional
// memory gives Vivado a simple LUTRAM target for small row-bank depths.
module ram_m_bank_mem
  import bike_pkg::*;
(
    input  logic                         i_clk,
    input  logic                         i_we,
    input  logic [M_ROW_BANK_ADDR_W-1:0] i_write_addr,
    input  logic [         COMP_C2V_W:0] i_wdata,
    input  logic [M_ROW_BANK_ADDR_W-1:0] i_read_addr,
`ifdef BIKE_SIM_DEBUG
    output logic [         COMP_C2V_W:0] o_rdata,
    output logic [         COMP_C2V_W:0] o_debug_mem[0:M_ROW_BANK_DEPTH-1]
`else
    output logic [         COMP_C2V_W:0] o_rdata
`endif
);

  localparam int M_WORD_W = COMP_C2V_W + 1;

  (* ram_style = "distributed" *) logic [M_WORD_W-1:0] mem[0:M_ROW_BANK_DEPTH-1];

`ifdef BIKE_SIM_DEBUG
  always_comb begin
    for (int addr = 0; addr < M_ROW_BANK_DEPTH; addr++) begin
      o_debug_mem[addr] = mem[addr];
    end
  end
`endif

  initial begin
    o_rdata = {1'b0, COMP_C2V_INIT};
    for (int addr = 0; addr < M_ROW_BANK_DEPTH; addr++) begin
      mem[addr] = {1'b0, COMP_C2V_INIT};
    end
  end

  always_ff @(posedge i_clk) begin
    if (i_we) begin
      mem[i_write_addr] <= i_wdata;
    end
    o_rdata <= mem[i_read_addr];
  end
endmodule
/* verilator lint_on DECLFILENAME */
