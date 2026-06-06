`timescale 1ns / 1ps
// Banked v2c sign storage indexed by edge and check row.
module msg_sign_ram
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_c2v_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_c2v_row_addr[0:L-1],
    input  logic [  EDGE_ID_W-1:0] i_c2v_edge_id[0:L-1],
    output logic                   o_c2v_sign[0:L-1],
    input  logic                   i_v2c_write_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_v2c_row_addr[0:L-1],
    input  logic [  EDGE_ID_W-1:0] i_v2c_edge_id[0:L-1],
    input  logic                   i_v2c_sign[0:L-1]
);

  localparam int SIGN_BANK_DEPTH = ROW_EDGE_COUNT * ROW_SEG_SIZE;
  localparam int SIGN_BANK_AW = (SIGN_BANK_DEPTH > 1) ? $clog2(SIGN_BANK_DEPTH) : 1;

  function automatic logic [SIGN_BANK_AW-1:0] edge_base(input  logic [EDGE_ID_W-1:0] edge_id);
    logic [SIGN_BANK_AW-1:0] acc;
    begin
      acc = '0;
      for (int bit_idx = 0; bit_idx < SIGN_BANK_AW; bit_idx++) begin
        if (((ROW_SEG_SIZE >> bit_idx) & 1) != 0) begin
          acc = acc + (SIGN_BANK_AW'(edge_id) << bit_idx);
        end
      end
      edge_base = acc;
    end
  endfunction

  function automatic logic [SIGN_BANK_AW-1:0] bank_addr(input  logic [EDGE_ID_W-1:0] edge_id,
                                                        input  logic [ROW_BANK_AW-1:0] row_addr);
    begin
      bank_addr = edge_base(edge_id) + SIGN_BANK_AW'(row_addr);
    end
  endfunction

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      (* ram_style = "block" *) logic                    mem[0:SIGN_BANK_DEPTH-1];
      logic [SIGN_BANK_AW-1:0] bank_raddr;
      logic                    bank_we;
      logic [SIGN_BANK_AW-1:0] bank_waddr;
      logic                    bank_wdata;

      always_comb begin
        bank_raddr = '0;
        bank_we = 1'b0;
        bank_waddr = '0;
        bank_wdata = 1'b0;
        if (i_c2v_valid[bank_idx]) begin
          bank_raddr = bank_addr(i_c2v_edge_id[bank_idx], i_c2v_row_addr[bank_idx]);
        end
        if (i_v2c_write_valid[bank_idx]) begin
          bank_we = 1'b1;
          bank_waddr = bank_addr(i_v2c_edge_id[bank_idx], i_v2c_row_addr[bank_idx]);
          bank_wdata = i_v2c_sign[bank_idx];
        end
      end

      always_ff @(posedge i_clk) begin
        o_c2v_sign[bank_idx] <= i_c2v_valid[bank_idx] ? mem[bank_raddr] : 1'b0;
        if (bank_we) begin
          mem[bank_waddr] <= bank_wdata;
        end
      end
    end
  endgenerate
endmodule
