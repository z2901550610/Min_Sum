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

  logic [         M_WORD_W-1:0] mem[0:M_ROW_BANKS-1][0:M_ROW_BANK_DEPTH-1];
  logic [         M_WORD_W-1:0] rword[          0:L-1];
  logic [ M_ROW_BANK_IDX_W-1:0] read_bank[          0:L-1];
  logic [ M_ROW_BANK_IDX_W-1:0] write_bank[          0:L-1];
  logic [M_ROW_BANK_ADDR_W-1:0] read_addr[          0:L-1];
  logic [M_ROW_BANK_ADDR_W-1:0] write_addr[          0:L-1];

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
    for (int bank = 0; bank < M_ROW_BANKS; bank++) begin
      for (int addr = 0; addr < M_ROW_BANK_DEPTH; addr++) begin
        mem[bank][addr] = {1'b0, COMP_C2V_INIT};
      end
    end
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      rword[lane_idx] = {1'b0, COMP_C2V_INIT};
    end
  end

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_bank[lane_idx] = bank_idx(i_read_row_idx_global[lane_idx]);
      write_bank[lane_idx] = bank_idx(i_write_row_idx_global[lane_idx]);
      read_addr[lane_idx] = bank_addr(i_read_row_idx_global[lane_idx]);
      write_addr[lane_idx] = bank_addr(i_write_row_idx_global[lane_idx]);
      o_rdata[lane_idx] = rword[lane_idx][COMP_C2V_W-1:0];
      o_epoch[lane_idx] = rword[lane_idx][M_WORD_EPOCH_BIT];
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
      if (i_we[lane_idx]) begin
        mem[write_bank[lane_idx]][write_addr[lane_idx]] <= {i_epoch, i_wdata[lane_idx]};
      end
      rword[lane_idx] <= mem[read_bank[lane_idx]][read_addr[lane_idx]];
    end
  end
endmodule
