`timescale 1ns / 1ps
// Banked v2c sign storage indexed by edge and check row.
module msg_sign_ram
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_c2v_valid[0:L-1],
    input  logic [ LANE_IDX_W-1:0] i_c2v_row_bank[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_c2v_row_addr[0:L-1],
    input  logic [  EDGE_ID_W-1:0] i_c2v_edge_id[0:L-1],
    output logic                   o_c2v_sign[0:L-1],
    input  logic                   i_v2c_valid[0:L-1],
    input  logic [ LANE_IDX_W-1:0] i_v2c_row_bank[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_v2c_row_addr[0:L-1],
    input  logic [  EDGE_ID_W-1:0] i_v2c_edge_id[0:L-1],
    input  logic                   i_v2c_sign[0:L-1]
);

  localparam int SIGN_BANK_DEPTH = ROW_EDGE_COUNT * ROW_SEG_SIZE;
  localparam int SIGN_BANK_AW = (SIGN_BANK_DEPTH > 1) ? $clog2(SIGN_BANK_DEPTH) : 1;

  logic bank_rdata[0:L-1];

  function automatic logic [SIGN_BANK_AW-1:0] bank_addr(input  logic [EDGE_ID_W-1:0] edge_id,
                                                        input  logic [ROW_BANK_AW-1:0] row_addr);
    begin
      bank_addr = SIGN_BANK_AW'((int'(edge_id) * ROW_SEG_SIZE) + int'(row_addr));
    end
  endfunction

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      (* ram_style = "distributed" *) logic                    mem[0:SIGN_BANK_DEPTH-1];
      logic                    bank_re;
      logic [SIGN_BANK_AW-1:0] bank_raddr;
      logic                    bank_we;
      logic [SIGN_BANK_AW-1:0] bank_waddr;
      logic                    bank_wdata;

      always_comb begin
        bank_re = 1'b0;
        bank_raddr = '0;
        bank_we = 1'b0;
        bank_waddr = '0;
        bank_wdata = 1'b0;
        for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
          if (i_c2v_valid[lane_idx] && (int'(i_c2v_row_bank[lane_idx]) == bank_idx)) begin
            bank_re = 1'b1;
            bank_raddr = bank_addr(i_c2v_edge_id[lane_idx], i_c2v_row_addr[lane_idx]);
          end
          if (i_v2c_valid[lane_idx] && (int'(i_v2c_row_bank[lane_idx]) == bank_idx)) begin
            bank_we = 1'b1;
            bank_waddr = bank_addr(i_v2c_edge_id[lane_idx], i_v2c_row_addr[lane_idx]);
            bank_wdata = i_v2c_sign[lane_idx];
          end
        end
      end

      assign bank_rdata[bank_idx] = bank_re ? mem[bank_raddr] : 1'b0;

      always_ff @(posedge i_clk) begin
        if (bank_we) begin
          mem[bank_waddr] <= bank_wdata;
        end
      end
    end
  endgenerate

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_c2v_sign[lane_idx] = 1'b0;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        if (i_c2v_valid[lane_idx] && (int'(i_c2v_row_bank[lane_idx]) == bank_idx)) begin
          o_c2v_sign[lane_idx] = bank_rdata[bank_idx];
        end
      end
    end
  end
endmodule
