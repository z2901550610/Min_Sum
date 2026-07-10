`timescale 1ns / 1ps
// RAM M: banked compressed check-state storage for the two iteration pairs.
module ram_m
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_clear_valid,
    input  logic                   i_clear_pair_sel,
    input  logic [ROW_BANK_AW-1:0] i_clear_row_addr,
    input  logic                   i_c2v_pair_sel,
    input  logic                   i_c2v_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_c2v_row_addr[0:L-1],
    output logic [ COMP_C2V_W-1:0] o_c2v_comp[0:L-1],
    input  logic                   i_v2c_pair_sel,
    input  logic                   i_v2c_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_v2c_row_addr[0:L-1],
    output logic [ COMP_C2V_W-1:0] o_v2c_comp[0:L-1],
    input  logic                   i_v2c_write_pair_sel,
    input  logic                   i_v2c_write_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_v2c_write_row_addr[0:L-1],
    input  logic [ COMP_C2V_W-1:0] i_v2c_write_data[0:L-1],
    input  logic                   i_flip_pair_sel,
    input  logic                   i_flip_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_flip_row_addr[0:L-1]
);

  logic [COMP_C2V_W-1:0] bank_rdata[0:1][0:L-1];
  logic                  c2v_bank_read_valid[0:1][0:L-1];
  logic                  v2c_bank_read_valid[0:1][0:L-1];
  logic                  c2v_pair_sel_q;
  logic                  v2c_pair_sel_q;

  generate
    for (genvar pair_idx = 0; pair_idx < 2; pair_idx++) begin : g_pair
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        (* ram_style = "block" *) logic [ COMP_C2V_W-1:0] mem[0:ROW_SEG_SIZE-1];
        logic                   bank_re;
        logic [            1:0] bank_read_kind;
        logic [ROW_BANK_AW-1:0] bank_raddr;
        logic                   bank_we;
        logic [ROW_BANK_AW-1:0] bank_waddr;
        logic [ COMP_C2V_W-1:0] bank_wdata;
        logic                   bank_read_valid_q;
        logic [            1:0] bank_read_kind_q;
        logic [ROW_BANK_AW-1:0] bank_raddr_q;
        logic [ COMP_C2V_W-1:0] mem_rdata_q;
        logic                   read_bypass_valid_q;
        logic [ COMP_C2V_W-1:0] read_bypass_data_q;
        logic                   flip_we;
        logic [ROW_BANK_AW-1:0] flip_waddr;
        logic [ COMP_C2V_W-1:0] flip_wdata;

        localparam logic [1:0] RAM_M_READ_NONE = 2'd0;
        localparam logic [1:0] RAM_M_READ_C2V = 2'd1;
        localparam logic [1:0] RAM_M_READ_V2C = 2'd2;
        localparam logic [1:0] RAM_M_READ_FLIP = 2'd3;

        always_comb begin
          bank_re = 1'b0;
          bank_read_kind = RAM_M_READ_NONE;
          bank_raddr = '0;
          bank_we = 1'b0;
          bank_waddr = '0;
          bank_wdata = '0;
          flip_we = bank_read_valid_q && (bank_read_kind_q == RAM_M_READ_FLIP);
          flip_waddr = bank_raddr_q;
          flip_wdata = bank_rdata[pair_idx][bank_idx];
          flip_wdata[COMP_C2V_SIGN_XOR_BIT] = ~bank_rdata[pair_idx][bank_idx][COMP_C2V_SIGN_XOR_BIT];
          // Scheduler presents one read intent per pair bank; c2v priority is a deterministic guard.
          if (i_c2v_valid[bank_idx] && (int'(i_c2v_pair_sel) == pair_idx)) begin
            bank_re = 1'b1;
            bank_read_kind = RAM_M_READ_C2V;
            bank_raddr = i_c2v_row_addr[bank_idx];
          end else if (i_v2c_valid[bank_idx] && (int'(i_v2c_pair_sel) == pair_idx)) begin
            bank_re = 1'b1;
            bank_read_kind = RAM_M_READ_V2C;
            bank_raddr = i_v2c_row_addr[bank_idx];
          end else if (i_flip_valid[bank_idx] && (int'(i_flip_pair_sel) == pair_idx)) begin
            bank_re = 1'b1;
            bank_read_kind = RAM_M_READ_FLIP;
            bank_raddr = i_flip_row_addr[bank_idx];
          end
          if (i_clear_valid && (int'(i_clear_pair_sel) == pair_idx)) begin
            bank_we = 1'b1;
            bank_waddr = i_clear_row_addr;
            bank_wdata = COMP_C2V_INIT;
          end else if (i_v2c_write_valid[bank_idx] && (int'(i_v2c_write_pair_sel) == pair_idx)) begin
            bank_we = 1'b1;
            bank_waddr = i_v2c_write_row_addr[bank_idx];
            bank_wdata = i_v2c_write_data[bank_idx];
          end
        end

        always_ff @(posedge i_clk or negedge i_rst_n) begin
          if (!i_rst_n) begin
            bank_read_valid_q <= 1'b0;
            bank_read_kind_q <= RAM_M_READ_NONE;
            bank_raddr_q <= '0;
            read_bypass_valid_q <= 1'b0;
            read_bypass_data_q <= '0;
          end else begin
            bank_read_valid_q <= bank_re;
            bank_read_kind_q <= bank_read_kind;
            bank_raddr_q <= bank_raddr;
            read_bypass_valid_q <= bank_re && flip_we && (bank_raddr == flip_waddr);
            read_bypass_data_q <= flip_wdata;
          end
        end

        always_ff @(posedge i_clk) begin
          if (bank_re) begin
            mem_rdata_q <= mem[bank_raddr];
          end
          if (bank_we) begin
            mem[bank_waddr] <= bank_wdata;
          end else if (flip_we) begin
            mem[flip_waddr] <= flip_wdata;
          end
        end

        assign bank_rdata[pair_idx][bank_idx] = read_bypass_valid_q ? read_bypass_data_q :
                                               mem_rdata_q;
        assign c2v_bank_read_valid[pair_idx][bank_idx] =
            bank_read_valid_q && (bank_read_kind_q == RAM_M_READ_C2V);
        assign v2c_bank_read_valid[pair_idx][bank_idx] =
            bank_read_valid_q && (bank_read_kind_q == RAM_M_READ_V2C);
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      c2v_pair_sel_q <= 1'b0;
      v2c_pair_sel_q <= 1'b0;
    end else begin
      c2v_pair_sel_q <= i_c2v_pair_sel;
      v2c_pair_sel_q <= i_v2c_pair_sel;
    end
  end

  always_comb begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      logic c2v_pair_idx;
      logic v2c_pair_idx;
      c2v_pair_idx = c2v_pair_sel_q;
      v2c_pair_idx = v2c_pair_sel_q;
      o_c2v_comp[bank_idx] = c2v_bank_read_valid[c2v_pair_idx][bank_idx] ?
                             bank_rdata[c2v_pair_idx][bank_idx] :
                             COMP_C2V_INIT;
      o_v2c_comp[bank_idx] = v2c_bank_read_valid[v2c_pair_idx][bank_idx] ?
                             bank_rdata[v2c_pair_idx][bank_idx] :
                             COMP_C2V_INIT;
    end
  end
endmodule
