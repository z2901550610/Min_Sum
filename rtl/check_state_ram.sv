`timescale 1ns / 1ps
// Banked compressed check-state storage for the two iteration pairs.
module check_state_ram
  import bike_pkg::*;
(
    input  logic                   i_clk,
    input  logic                   i_rst_n,
    input  logic                   i_c2v_pair_sel,
    input  logic                   i_c2v_epoch,
    input  logic                   i_c2v_valid[0:L-1],
    input  logic [ LANE_IDX_W-1:0] i_c2v_row_bank[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_c2v_row_addr[0:L-1],
    output logic [ COMP_C2V_W-1:0] o_c2v_comp[0:L-1],
    input  logic                   i_v2c_pair_sel,
    input  logic                   i_v2c_epoch,
    input  logic                   i_v2c_valid[0:L-1],
    input  logic [ LANE_IDX_W-1:0] i_v2c_row_bank[0:L-1],
    input  logic [ROW_BANK_AW-1:0] i_v2c_row_addr[0:L-1],
    output logic [ COMP_C2V_W-1:0] o_v2c_comp[0:L-1],
    input  logic [ COMP_C2V_W-1:0] i_v2c_wdata[0:L-1]
);

  logic [COMP_C2V_W-1:0] c2v_bank_rdata[0:1][0:L-1];
  logic [COMP_C2V_W-1:0] v2c_bank_rdata[0:1][0:L-1];

  generate
    for (genvar pair_idx = 0; pair_idx < 2; pair_idx++) begin : g_pair
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        (* ram_style = "distributed" *) logic [ COMP_C2V_W-1:0] mem[0:ROW_SEG_SIZE-1];
        logic                   epoch_mem[0:ROW_SEG_SIZE-1];
        logic                   c2v_bank_re;
        logic [ROW_BANK_AW-1:0] c2v_bank_raddr;
        logic                   v2c_bank_re;
        logic [ROW_BANK_AW-1:0] v2c_bank_raddr;
        logic                   v2c_bank_we;
        logic [ROW_BANK_AW-1:0] v2c_bank_waddr;
        logic [ COMP_C2V_W-1:0] v2c_bank_wdata;

        always_comb begin
          c2v_bank_re = 1'b0;
          c2v_bank_raddr = '0;
          v2c_bank_re = 1'b0;
          v2c_bank_raddr = '0;
          v2c_bank_we = 1'b0;
          v2c_bank_waddr = '0;
          v2c_bank_wdata = '0;
          for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
            if (i_c2v_valid[lane_idx] && (int'(i_c2v_pair_sel) == pair_idx) &&
                (int'(i_c2v_row_bank[lane_idx]) == bank_idx)) begin
              c2v_bank_re = 1'b1;
              c2v_bank_raddr = i_c2v_row_addr[lane_idx];
            end
            if (i_v2c_valid[lane_idx] && (int'(i_v2c_pair_sel) == pair_idx) &&
                (int'(i_v2c_row_bank[lane_idx]) == bank_idx)) begin
              v2c_bank_re = 1'b1;
              v2c_bank_raddr = i_v2c_row_addr[lane_idx];
              v2c_bank_we = 1'b1;
              v2c_bank_waddr = i_v2c_row_addr[lane_idx];
              v2c_bank_wdata = i_v2c_wdata[lane_idx];
            end
          end
        end

        assign c2v_bank_rdata[pair_idx][bank_idx] =
            (c2v_bank_re && (epoch_mem[c2v_bank_raddr] == i_c2v_epoch)) ? mem[c2v_bank_raddr] :
                                                                          COMP_C2V_INIT;
        assign v2c_bank_rdata[pair_idx][bank_idx] =
            (v2c_bank_re && (epoch_mem[v2c_bank_raddr] == i_v2c_epoch)) ? mem[v2c_bank_raddr] :
                                                                          COMP_C2V_INIT;

        always_ff @(posedge i_clk) begin
          if (v2c_bank_we) begin
            mem[v2c_bank_waddr] <= v2c_bank_wdata;
          end
        end

        always_ff @(posedge i_clk or negedge i_rst_n) begin
          if (!i_rst_n) begin
            for (int row_addr = 0; row_addr < ROW_SEG_SIZE; row_addr++) begin
              epoch_mem[row_addr] <= 1'b0;
            end
          end else if (v2c_bank_we) begin
            epoch_mem[v2c_bank_waddr] <= i_v2c_epoch;
          end
        end
      end
    end
  endgenerate

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_c2v_comp[lane_idx] = COMP_C2V_INIT;
      o_v2c_comp[lane_idx] = COMP_C2V_INIT;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        if (i_c2v_valid[lane_idx] && (int'(i_c2v_row_bank[lane_idx]) == bank_idx)) begin
          o_c2v_comp[lane_idx] = c2v_bank_rdata[int'(i_c2v_pair_sel)][bank_idx];
        end
        if (i_v2c_valid[lane_idx] && (int'(i_v2c_row_bank[lane_idx]) == bank_idx)) begin
          o_v2c_comp[lane_idx] = v2c_bank_rdata[int'(i_v2c_pair_sel)][bank_idx];
        end
      end
    end
  end
endmodule
