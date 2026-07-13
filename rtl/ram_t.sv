`timescale 1ns / 1ps
// RAM T: address-interleaved double-buffered two's-complement C2V tile cache.
module ram_t
  import bike_pkg::*;
(
    input  logic                               i_clk,
    input  logic                               i_fill_buf,
    input  logic                               i_c2v_write_valid[0:L-1],
    input  logic        [      DIAG_IDX_W-1:0] i_c2v_write_diag_idx_local,
    input  logic        [LANE_GROUP_IDX_W-1:0] i_c2v_write_lane_group_idx,
    input  logic signed [           MSG_W-1:0] i_c2v_tc[0:L-1],
    input  logic                               i_active_buf,
    input  logic                               i_v2c_valid[0:L-1],
    input  logic        [      DIAG_IDX_W-1:0] i_v2c_diag_idx_local,
    input  logic        [LANE_GROUP_IDX_W-1:0] i_v2c_lane_group_idx,
    output logic signed [           MSG_W-1:0] o_c2v_edge[0:L-1]
);

  localparam int T_DEPTH = W * Q_TILE;
  localparam int T_ADDR_W = (T_DEPTH > 1) ? $clog2(T_DEPTH) : 1;
  localparam int T_BUF_DEPTH = 2 * T_DEPTH;
  localparam int T_BUF_ADDR_W = T_ADDR_W + 1;

  logic signed [MSG_W-1:0] bank_rdata[0:L-1];

  function automatic logic [T_ADDR_W-1:0] t_addr(input  logic [DIAG_IDX_W-1:0] diag_idx_local,
                                                 input  logic [LANE_GROUP_IDX_W-1:0] lane_group_idx);
    begin
      t_addr = T_ADDR_W'((int'(diag_idx_local) * Q_TILE) + int'(lane_group_idx));
    end
  endfunction

  function automatic logic [T_BUF_ADDR_W-1:0] t_buf_addr(
      input  logic buffer_sel, input  logic [DIAG_IDX_W-1:0] diag_idx_local,
      input  logic [LANE_GROUP_IDX_W-1:0] lane_group_idx);
    begin
      t_buf_addr = {t_addr(diag_idx_local, lane_group_idx), buffer_sel};
    end
  endfunction

  generate
    for (genvar lane_idx = 0; lane_idx < L; lane_idx++) begin : g_lane
      logic                           bank_re;
      logic        [T_BUF_ADDR_W-1:0] bank_raddr;
      logic                           bank_we;
      logic        [T_BUF_ADDR_W-1:0] bank_waddr;
      logic                           bank_read_valid_q;
      logic signed [       MSG_W-1:0] mem_rdata;

      always_comb begin
        bank_re = i_v2c_valid[lane_idx];
        bank_raddr = t_buf_addr(i_active_buf, i_v2c_diag_idx_local, i_v2c_lane_group_idx);
        bank_we = i_c2v_write_valid[lane_idx];
        bank_waddr = t_buf_addr(i_fill_buf, i_c2v_write_diag_idx_local, i_c2v_write_lane_group_idx);
      end

      always_ff @(posedge i_clk) begin
        bank_read_valid_q <= bank_re;
      end

      ram_bram #(
          .DATA_W(MSG_W),
          .DEPTH (T_BUF_DEPTH),
          .ADDR_W(T_BUF_ADDR_W)
      ) u_bram (
          .i_clk  (i_clk),
          .i_we   (bank_we),
          .i_waddr(bank_waddr),
          .i_wdata(i_c2v_tc[lane_idx]),
          .i_re   (bank_re),
          .i_raddr(bank_raddr),
          .o_rdata(mem_rdata)
      );

      assign bank_rdata[lane_idx] = bank_read_valid_q ? mem_rdata : '0;
    end
  endgenerate

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_c2v_edge[lane_idx] = bank_rdata[lane_idx];
    end
  end
endmodule
