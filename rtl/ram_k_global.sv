`timescale 1ns / 1ps
// Banked global RAM for in-place per-variable K-sign records.
module ram_k_global
  import bike_pkg::*;
(
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic                       i_read_valid[0:L-1],
    input  logic [          COL_W-1:0] i_read_col_idx[0:L-1],
    output logic [K_SIGN_RECORD_W-1:0] o_read_record[0:L-1],
    input  logic                       i_write_valid[0:L-1],
    input  logic [          COL_W-1:0] i_write_col_idx[0:L-1],
    input  logic [K_SIGN_RECORD_W-1:0] i_write_record[0:L-1]
);

  localparam int KSIGN_BANK_DEPTH = (N + L - 1) / L;
  localparam int KSIGN_BANK_AW = (KSIGN_BANK_DEPTH > 1) ? $clog2(KSIGN_BANK_DEPTH) : 1;
  localparam int READ_ROUTE_W = 1 + KSIGN_BANK_AW;

  logic [K_SIGN_RECORD_W-1:0] bank_rdata[0:L-1];
  logic [   READ_ROUTE_W-1:0] read_route_in[0:L-1];
  logic [   READ_ROUTE_W-1:0] read_route_out[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] read_record_route_out[0:L-1];
  logic                       routed_read_valid[0:L-1];
  logic [  KSIGN_BANK_AW-1:0] routed_read_addr[0:L-1];
  logic                       routed_write_valid[0:L-1];
  logic [  KSIGN_BANK_AW-1:0] routed_write_addr[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] routed_write_data[0:L-1];
  logic [     LANE_IDX_W-1:0] read_route_shift;
  logic [     LANE_IDX_W-1:0] read_route_shift_q;

  function automatic logic [LANE_IDX_W-1:0] col_bank(input  logic [COL_W-1:0] col_idx);
    begin
      col_bank = LANE_IDX_W'(int'(col_idx) & (L - 1));
    end
  endfunction

  function automatic logic [KSIGN_BANK_AW-1:0] col_addr(input  logic [COL_W-1:0] col_idx);
    begin
      col_addr = KSIGN_BANK_AW'(col_idx >> L_SHIFT);
    end
  endfunction

  always_comb begin
    read_route_shift = col_bank(i_read_col_idx[0]);
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      read_route_in[bank_idx] = {i_read_valid[bank_idx], col_addr(i_read_col_idx[bank_idx])};
      {routed_read_valid[bank_idx], routed_read_addr[bank_idx]} = read_route_out[bank_idx];
      routed_write_valid[bank_idx] = i_write_valid[bank_idx];
      routed_write_addr[bank_idx] = col_addr(i_write_col_idx[bank_idx]);
      routed_write_data[bank_idx] = i_write_record[bank_idx];
    end
  end

  barrel_rotate #(
      .DATA_W(READ_ROUTE_W)
  ) u_read_route (
      .i_data (read_route_in),
      .i_shift(LANE_IDX_W'('0 - read_route_shift)),
      .o_data (read_route_out)
  );

  barrel_rotate #(
      .DATA_W(K_SIGN_RECORD_W)
  ) u_read_return (
      .i_data (bank_rdata),
      .i_shift(read_route_shift_q),
      .o_data (read_record_route_out)
  );

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      ram_bram #(
          .DATA_W(K_SIGN_RECORD_W),
          .DEPTH (KSIGN_BANK_DEPTH),
          .ADDR_W(KSIGN_BANK_AW)
      ) u_bram (
          .i_clk  (i_clk),
          .i_we   (routed_write_valid[bank_idx]),
          .i_waddr(routed_write_addr[bank_idx]),
          .i_wdata(routed_write_data[bank_idx]),
          .i_re   (routed_read_valid[bank_idx]),
          .i_raddr(routed_read_addr[bank_idx]),
          .o_rdata(bank_rdata[bank_idx])
      );
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_route_shift_q <= '0;
    end else begin
      read_route_shift_q <= read_route_shift;
    end
  end

  always_comb begin
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      o_read_record[lane_idx] = read_record_route_out[lane_idx];
    end
  end

`ifndef SYNTHESIS
  always @(posedge i_clk) begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      if (routed_read_valid[bank_idx] && routed_write_valid[bank_idx] &&
          (routed_read_addr[bank_idx] == routed_write_addr[bank_idx])) begin
        $fatal(1, "ram_k_global in-place read/write collision bank=%0d addr=%0d", bank_idx,
               routed_read_addr[bank_idx]);
      end
    end
  end
`endif
endmodule
