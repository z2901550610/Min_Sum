`timescale 1ns / 1ps
// Double-buffered tile accumulator storage.
module tile_accum_ram
  import bike_pkg::*;
(
    input  logic                         i_clk,
    input  logic                         i_fill_buf,
    input  logic                         i_c2v_valid[0:L-1],
    input  logic        [TILE_OFF_W-1:0] i_c2v_tile_offset[0:L-1],
    output logic signed [     ACC_W-1:0] o_c2v_rdata[0:L-1],
    input  logic signed [     ACC_W-1:0] i_c2v_wdata[0:L-1],
    input  logic                         i_active_buf,
    input  logic                         i_v2c_valid[0:L-1],
    input  logic        [TILE_OFF_W-1:0] i_v2c_tile_offset[0:L-1],
    output logic signed [     ACC_W-1:0] o_v2c_rdata[0:L-1]
);

  localparam int ACCUM_BANK_DEPTH = Q_BASE;
  localparam int ACCUM_BANK_AW = (ACCUM_BANK_DEPTH > 1) ? $clog2(ACCUM_BANK_DEPTH) : 1;

  logic signed [ACC_W-1:0] c2v_bank_rdata[0:1][0:L-1];
  logic signed [ACC_W-1:0] v2c_bank_rdata[0:1][0:L-1];

  function automatic logic [LANE_IDX_W-1:0] offset_bank(input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      offset_bank = LANE_IDX_W'(int'(tile_offset) % L);
    end
  endfunction

  function automatic logic [ACCUM_BANK_AW-1:0] offset_addr(
      input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      offset_addr = ACCUM_BANK_AW'(int'(tile_offset) / L);
    end
  endfunction

  generate
    for (genvar buf_idx = 0; buf_idx < 2; buf_idx++) begin : g_buf
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        (* ram_style = "distributed" *) logic signed [        ACC_W-1:0] mem[0:ACCUM_BANK_DEPTH-1];
        logic                            c2v_bank_re;
        logic        [ACCUM_BANK_AW-1:0] c2v_bank_raddr;
        logic                            v2c_bank_re;
        logic        [ACCUM_BANK_AW-1:0] v2c_bank_raddr;
        logic                            c2v_bank_we;
        logic        [ACCUM_BANK_AW-1:0] c2v_bank_waddr;
        logic signed [        ACC_W-1:0] c2v_bank_wdata;

        always_comb begin
          c2v_bank_re = 1'b0;
          c2v_bank_raddr = '0;
          v2c_bank_re = 1'b0;
          v2c_bank_raddr = '0;
          c2v_bank_we = 1'b0;
          c2v_bank_waddr = '0;
          c2v_bank_wdata = '0;
          for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
            if (i_c2v_valid[lane_idx] && (int'(i_fill_buf) == buf_idx) && (int'(offset_bank(
                    i_c2v_tile_offset[lane_idx]
                )) == bank_idx)) begin
              c2v_bank_re = 1'b1;
              c2v_bank_raddr = offset_addr(i_c2v_tile_offset[lane_idx]);
              c2v_bank_we = 1'b1;
              c2v_bank_waddr = offset_addr(i_c2v_tile_offset[lane_idx]);
              c2v_bank_wdata = i_c2v_wdata[lane_idx];
            end
            if (i_v2c_valid[lane_idx] && (int'(i_active_buf) == buf_idx) && (int'(offset_bank(
                    i_v2c_tile_offset[lane_idx]
                )) == bank_idx)) begin
              v2c_bank_re = 1'b1;
              v2c_bank_raddr = offset_addr(i_v2c_tile_offset[lane_idx]);
            end
          end
        end

        assign c2v_bank_rdata[buf_idx][bank_idx] = c2v_bank_re ? mem[c2v_bank_raddr] : '0;
        assign v2c_bank_rdata[buf_idx][bank_idx] = v2c_bank_re ? mem[v2c_bank_raddr] : '0;

        always_ff @(posedge i_clk) begin
          if (c2v_bank_we) begin
            mem[c2v_bank_waddr] <= c2v_bank_wdata;
          end
        end
      end
    end
  endgenerate

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_c2v_rdata[lane_idx] = '0;
      o_v2c_rdata[lane_idx] = '0;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        if (i_c2v_valid[lane_idx] && (int'(offset_bank(
                i_c2v_tile_offset[lane_idx]
            )) == bank_idx)) begin
          o_c2v_rdata[lane_idx] = c2v_bank_rdata[int'(i_fill_buf)][bank_idx];
        end
        if (i_v2c_valid[lane_idx] && (int'(offset_bank(
                i_v2c_tile_offset[lane_idx]
            )) == bank_idx)) begin
          o_v2c_rdata[lane_idx] = v2c_bank_rdata[int'(i_active_buf)][bank_idx];
        end
      end
    end
  end
endmodule
