`timescale 1ns / 1ps
// Banked per-check parity of retained K-sign deviations for two iteration pairs.
module ram_sign_delta
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_clear_valid,
    input  logic                   i_clear_pair_sel,
    input  logic [ROW_BANK_AW-1:0] i_clear_row_addr,
    input  logic                   i_read_pair_sel,
    input  logic                   i_read_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_read_row_addr[0:L-1],
    output logic                   o_read_delta[0:L-1],
    input  logic                   i_flip_pair_sel,
    input  logic                   i_flip_valid[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_flip_row_addr[0:L-1]
);

  logic read_data[0:1][0:L-1];
  logic read_valid_q[0:1][0:L-1];
  logic read_pair_sel_q;

  generate
    for (genvar pair_idx = 0; pair_idx < 2; pair_idx++) begin : g_pair
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        logic                   mem_re;
        logic [ROW_BANK_AW-1:0] mem_raddr;
        logic                   mem_rdata;
        logic                   flip_read_q;
        logic [ROW_BANK_AW-1:0] flip_addr_q;
        logic                   effective_rdata;
        logic                   flip_wdata;
        logic                   read_bypass_valid_q;
        logic                   read_bypass_data_q;

        always_comb begin
          mem_re = 1'b0;
          mem_raddr = '0;
          if (i_read_valid[bank_idx] && (int'(i_read_pair_sel) == pair_idx)) begin
            mem_re = 1'b1;
            mem_raddr = i_read_row_addr[bank_idx];
          end else if (i_flip_valid[bank_idx] && (int'(i_flip_pair_sel) == pair_idx)) begin
            mem_re = 1'b1;
            mem_raddr = i_flip_row_addr[bank_idx];
          end
          effective_rdata = read_bypass_valid_q ? read_bypass_data_q : mem_rdata;
          flip_wdata = ~effective_rdata;
        end

        always_ff @(posedge i_clk or negedge i_rst_n) begin
          if (!i_rst_n) begin
            flip_read_q <= 1'b0;
            flip_addr_q <= '0;
            read_bypass_valid_q <= 1'b0;
            read_bypass_data_q <= 1'b0;
            read_valid_q[pair_idx][bank_idx] <= 1'b0;
          end else begin
            flip_read_q <= i_flip_valid[bank_idx] && (int'(i_flip_pair_sel) == pair_idx);
            flip_addr_q <= i_flip_row_addr[bank_idx];
            read_bypass_valid_q <= mem_re && flip_read_q && (mem_raddr == flip_addr_q);
            read_bypass_data_q <= flip_wdata;
            read_valid_q[pair_idx][bank_idx] <=
                i_read_valid[bank_idx] && (int'(i_read_pair_sel) == pair_idx);
          end
        end

        ram_bram #(
            .DATA_W(1),
            .DEPTH (ROW_SEG_SIZE),
            .ADDR_W(ROW_BANK_AW)
        ) u_mem (
            .i_clk(i_clk),
            .i_we((i_clear_valid && (int'(i_clear_pair_sel) == pair_idx)) || flip_read_q),
            .i_waddr((i_clear_valid && (int'(i_clear_pair_sel) == pair_idx)) ?
                     i_clear_row_addr : flip_addr_q),
            .i_wdata((i_clear_valid && (int'(i_clear_pair_sel) == pair_idx)) ? 1'b0 : flip_wdata),
            .i_re(mem_re),
            .i_raddr(mem_raddr),
            .o_rdata(mem_rdata)
        );

        assign read_data[pair_idx][bank_idx] = effective_rdata;
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_pair_sel_q <= 1'b0;
    end else begin
      read_pair_sel_q <= i_read_pair_sel;
    end
  end

  always_comb begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      o_read_delta[bank_idx] = read_valid_q[read_pair_sel_q][bank_idx] ?
          read_data[read_pair_sel_q][bank_idx] : 1'b0;
    end
  end
endmodule
