`timescale 1ns / 1ps
// VNU tile accumulator storage for C2V sums.
module ram_accum
  import bike_pkg::*;
(
    input  logic                         i_clk,
    input  logic                         i_c2v_read_buf,
    input  logic                         i_c2v_read_valid[0:L-1],
    input  logic        [TILE_OFF_W-1:0] i_c2v_read_tile_offset[0:L-1],
    output logic signed [     ACC_W-1:0] o_old_c2v_sum[0:L-1],
    input  logic                         i_c2v_write_buf,
    input  logic                         i_c2v_write_valid[0:L-1],
    input  logic        [TILE_OFF_W-1:0] i_c2v_write_tile_offset[0:L-1],
    input  logic signed [     ACC_W-1:0] i_updated_c2v_sum[0:L-1],
    input  logic                         i_active_buf,
    input  logic                         i_v2c_valid[0:L-1],
    input  logic        [TILE_OFF_W-1:0] i_v2c_tile_offset[0:L-1],
    output logic signed [     ACC_W-1:0] o_c2v_sum[0:L-1]
);

  localparam int ACCUM_BANK_DEPTH = Q_BASE;
  localparam int ACCUM_BANK_AW = (ACCUM_BANK_DEPTH > 1) ? $clog2(ACCUM_BANK_DEPTH) : 1;

  logic signed [        ACC_W-1:0] c2v_bank_rdata[  0:1][0:L-1];
  logic signed [        ACC_W-1:0] v2c_bank_rdata[  0:1][0:L-1];
  logic                            routed_c2v_read_valid[0:L-1];
  logic        [ACCUM_BANK_AW-1:0] routed_c2v_read_addr[0:L-1];
  logic                            routed_c2v_write_valid[0:L-1];
  logic        [ACCUM_BANK_AW-1:0] routed_c2v_write_addr[0:L-1];
  logic signed [        ACC_W-1:0] routed_c2v_write_data[0:L-1];
  logic                            routed_v2c_read_valid[0:L-1];
  logic        [ACCUM_BANK_AW-1:0] routed_v2c_read_addr[0:L-1];

  function automatic logic [LANE_IDX_W-1:0] offset_bank(input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      offset_bank = LANE_IDX_W'(int'(tile_offset) & (L - 1));
    end
  endfunction

  function automatic logic [ACCUM_BANK_AW-1:0] offset_addr(
      input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      offset_addr = ACCUM_BANK_AW'(tile_offset >> L_SHIFT);
    end
  endfunction

  always_comb begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      routed_c2v_read_valid[bank_idx]  = 1'b0;
      routed_c2v_read_addr[bank_idx]   = '0;
      routed_c2v_write_valid[bank_idx] = 1'b0;
      routed_c2v_write_addr[bank_idx]  = '0;
      routed_c2v_write_data[bank_idx]  = '0;
      routed_v2c_read_valid[bank_idx]  = 1'b0;
      routed_v2c_read_addr[bank_idx]   = '0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        if (i_c2v_read_valid[lane_idx] && (offset_bank(
                i_c2v_read_tile_offset[lane_idx]
            ) == LANE_IDX_W'(bank_idx))) begin
          routed_c2v_read_valid[bank_idx] = 1'b1;
          routed_c2v_read_addr[bank_idx]  = offset_addr(i_c2v_read_tile_offset[lane_idx]);
        end
        if (i_c2v_write_valid[lane_idx] && (offset_bank(
                i_c2v_write_tile_offset[lane_idx]
            ) == LANE_IDX_W'(bank_idx))) begin
          routed_c2v_write_valid[bank_idx] = 1'b1;
          routed_c2v_write_addr[bank_idx]  = offset_addr(i_c2v_write_tile_offset[lane_idx]);
          routed_c2v_write_data[bank_idx]  = i_updated_c2v_sum[lane_idx];
        end
        if (i_v2c_valid[lane_idx] && (offset_bank(
                i_v2c_tile_offset[lane_idx]
            ) == LANE_IDX_W'(bank_idx))) begin
          routed_v2c_read_valid[bank_idx] = 1'b1;
          routed_v2c_read_addr[bank_idx]  = offset_addr(i_v2c_tile_offset[lane_idx]);
        end
      end
    end
  end

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
          c2v_bank_re = routed_c2v_read_valid[bank_idx] && (int'(i_c2v_read_buf) == buf_idx);
          c2v_bank_raddr = routed_c2v_read_addr[bank_idx];
          v2c_bank_re = routed_v2c_read_valid[bank_idx] && (int'(i_active_buf) == buf_idx);
          v2c_bank_raddr = routed_v2c_read_addr[bank_idx];
          c2v_bank_we = routed_c2v_write_valid[bank_idx] && (int'(i_c2v_write_buf) == buf_idx);
          c2v_bank_waddr = routed_c2v_write_addr[bank_idx];
          c2v_bank_wdata = routed_c2v_write_data[bank_idx];
        end

        assign c2v_bank_rdata[buf_idx][bank_idx] =
            c2v_bank_re ? ((c2v_bank_we && (c2v_bank_waddr == c2v_bank_raddr)) ?
                           c2v_bank_wdata : mem[c2v_bank_raddr]) : '0;
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
      o_old_c2v_sum[lane_idx] = i_c2v_read_valid[lane_idx] ?
          c2v_bank_rdata[int'(i_c2v_read_buf)][int'(offset_bank(i_c2v_read_tile_offset[lane_idx]))]
          : '0;
      o_c2v_sum[lane_idx] = i_v2c_valid[lane_idx] ?
          v2c_bank_rdata[int'(i_active_buf)][int'(offset_bank(i_v2c_tile_offset[lane_idx]))] : '0;
    end
  end
endmodule
