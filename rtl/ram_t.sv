`timescale 1ns / 1ps
// RAM T: double-buffered two's-complement C2V tile cache.
module ram_t
  import bike_pkg::*;
(
    input  logic                         i_clk,
    input  logic                         i_fill_buf,
    input  logic                         i_c2v_write_valid[0:L-1],
    input  logic        [DIAG_IDX_W-1:0] i_c2v_write_diag_idx_local,
    input  logic        [TILE_OFF_W-1:0] i_c2v_write_tile_offset[0:L-1],
    input  logic signed [     MSG_W-1:0] i_c2v_tc[0:L-1],
    input  logic                         i_active_buf,
    input  logic                         i_v2c_valid[0:L-1],
    input  logic        [DIAG_IDX_W-1:0] i_v2c_diag_idx_local,
    input  logic        [TILE_OFF_W-1:0] i_v2c_tile_offset[0:L-1],
    output logic signed [     MSG_W-1:0] o_c2v_edge[0:L-1]
);

  localparam int T_DEPTH = W * Q_BASE;
  localparam int T_ADDR_W = (T_DEPTH > 1) ? $clog2(T_DEPTH) : 1;
  localparam int READ_ROUTE_W = 1 + T_ADDR_W;
  localparam int WRITE_ROUTE_W = READ_ROUTE_W + MSG_W;

  logic signed [        MSG_W-1:0] bank_rdata[  0:1][0:L-1];
  logic        [ READ_ROUTE_W-1:0] read_route_in[0:L-1];
  logic        [ READ_ROUTE_W-1:0] read_route_out[0:L-1];
  logic        [WRITE_ROUTE_W-1:0] write_route_in[0:L-1];
  logic        [WRITE_ROUTE_W-1:0] write_route_out[0:L-1];
  logic        [        MSG_W-1:0] selected_bank_rdata[0:L-1];
  logic        [        MSG_W-1:0] lane_rdata[0:L-1];
  logic        [   LANE_IDX_W-1:0] read_shift;
  logic        [   LANE_IDX_W-1:0] read_shift_q;
  logic                            read_buf_q;
  logic        [   LANE_IDX_W-1:0] write_shift;
  logic                            routed_read_valid[0:L-1];
  logic        [     T_ADDR_W-1:0] routed_read_addr[0:L-1];
  logic                            routed_write_valid[0:L-1];
  logic        [     T_ADDR_W-1:0] routed_write_addr[0:L-1];
  logic signed [        MSG_W-1:0] routed_write_data[0:L-1];

  function automatic logic [LANE_IDX_W-1:0] offset_bank(input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      offset_bank = LANE_IDX_W'(int'(tile_offset) & (L - 1));
    end
  endfunction

  function automatic logic [T_ADDR_W-1:0] t_addr(input  logic [DIAG_IDX_W-1:0] diag_idx_local,
                                                 input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      t_addr = T_ADDR_W'((int'(diag_idx_local) * Q_BASE) + (int'(tile_offset) >> L_SHIFT));
    end
  endfunction

  always_comb begin
    read_shift  = offset_bank(i_v2c_tile_offset[0]);
    write_shift = offset_bank(i_c2v_write_tile_offset[0]);
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      read_route_in[lane_idx] = {
        i_v2c_valid[lane_idx], t_addr(i_v2c_diag_idx_local, i_v2c_tile_offset[lane_idx])
      };
      write_route_in[lane_idx] = {
        i_c2v_write_valid[lane_idx],
        t_addr(i_c2v_write_diag_idx_local, i_c2v_write_tile_offset[lane_idx]),
        i_c2v_tc[lane_idx]
      };
      selected_bank_rdata[lane_idx] = bank_rdata[int'(read_buf_q)][lane_idx];
      {routed_read_valid[lane_idx], routed_read_addr[lane_idx]} = read_route_out[lane_idx];
      {routed_write_valid[lane_idx], routed_write_addr[lane_idx],
       routed_write_data[lane_idx]} = write_route_out[lane_idx];
      o_c2v_edge[lane_idx] = $signed(lane_rdata[lane_idx]);
    end
  end

  barrel_rotate #(
      .DATA_W(READ_ROUTE_W)
  ) u_read_route (
      .i_data (read_route_in),
      .i_shift(LANE_IDX_W'('0 - read_shift)),
      .o_data (read_route_out)
  );

  barrel_rotate #(
      .DATA_W(WRITE_ROUTE_W)
  ) u_write_route (
      .i_data (write_route_in),
      .i_shift(LANE_IDX_W'('0 - write_shift)),
      .o_data (write_route_out)
  );

  barrel_rotate #(
      .DATA_W(MSG_W)
  ) u_read_return (
      .i_data (selected_bank_rdata),
      .i_shift(read_shift_q),
      .o_data (lane_rdata)
  );

  always_ff @(posedge i_clk) begin
    read_shift_q <= read_shift;
    read_buf_q   <= i_active_buf;
  end

  generate
    for (genvar buf_idx = 0; buf_idx < 2; buf_idx++) begin : g_buf
      for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
        logic                       bank_re;
        logic        [T_ADDR_W-1:0] bank_raddr;
        logic                       bank_we;
        logic        [T_ADDR_W-1:0] bank_waddr;
        logic                       bank_read_valid_q;
        logic signed [   MSG_W-1:0] mem_rdata;

        always_comb begin
          bank_re = routed_read_valid[bank_idx] && (int'(i_active_buf) == buf_idx);
          bank_raddr = routed_read_addr[bank_idx];
          bank_we = routed_write_valid[bank_idx] && (int'(i_fill_buf) == buf_idx);
          bank_waddr = routed_write_addr[bank_idx];
        end

        always_ff @(posedge i_clk) begin
          bank_read_valid_q <= bank_re;
        end

        ram_bram #(
            .DATA_W(MSG_W),
            .DEPTH (T_DEPTH),
            .ADDR_W(T_ADDR_W)
        ) u_bram (
            .i_clk  (i_clk),
            .i_we   (bank_we),
            .i_waddr(bank_waddr),
            .i_wdata(routed_write_data[bank_idx]),
            .i_re   (bank_re),
            .i_raddr(bank_raddr),
            .o_rdata(mem_rdata)
        );

        assign bank_rdata[buf_idx][bank_idx] = bank_read_valid_q ? mem_rdata : '0;
      end
    end
  endgenerate

`ifndef SYNTHESIS
  always @(posedge i_clk) begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      if (i_c2v_write_valid[lane_idx] &&
          ((int'(i_c2v_write_tile_offset[lane_idx]) >> L_SHIFT) >= Q_BASE)) begin
        $fatal(1, "ram_t C2V tile offset address out of range lane=%0d offset=%0d", lane_idx,
               i_c2v_write_tile_offset[lane_idx]);
      end
      if (i_v2c_valid[lane_idx] && ((int'(i_v2c_tile_offset[lane_idx]) >> L_SHIFT) >= Q_BASE)) begin
        $fatal(1, "ram_t V2C tile offset address out of range lane=%0d offset=%0d", lane_idx,
               i_v2c_tile_offset[lane_idx]);
      end
    end
  end
`endif
endmodule
