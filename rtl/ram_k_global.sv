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
  localparam int BASE_SIGN_BIT = 0;
  localparam int SLOT_BASE_LSB = 1;
  localparam int DIAG_SEG_MAX_AW = 12;
  localparam int DIAG_SEG_AW = (KSIGN_BANK_AW < DIAG_SEG_MAX_AW) ? KSIGN_BANK_AW : DIAG_SEG_MAX_AW;
  localparam int DIAG_SEG_DEPTH = 1 << DIAG_SEG_AW;
  localparam int DIAG_SEG_COUNT = (KSIGN_BANK_DEPTH + DIAG_SEG_DEPTH - 1) / DIAG_SEG_DEPTH;
  localparam int DIAG_SEG_IDX_W = (DIAG_SEG_COUNT > 1) ? $clog2(DIAG_SEG_COUNT) : 1;

  logic [K_SIGN_RECORD_W-1:0] bank_rdata[0:L-1];
  logic [                0:0] bank_base_sign_rdata[0:L-1];
  logic [     DIAG_IDX_W-1:0] bank_diag_rdata[0:L-1][0:K_SIGN_K-1];
  logic [     DIAG_IDX_W-1:0] bank_diag_segment_rdata[0:L-1] [0:K_SIGN_K-1] [0:DIAG_SEG_COUNT-1];
  logic [   READ_ROUTE_W-1:0] read_route_in[0:L-1];
  logic [   READ_ROUTE_W-1:0] read_route_out[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] read_record_route_out[0:L-1];
  logic                       routed_read_valid[0:L-1];
  logic [  KSIGN_BANK_AW-1:0] routed_read_addr[0:L-1];
  logic                       routed_write_valid[0:L-1];
  logic [  KSIGN_BANK_AW-1:0] routed_write_addr[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] routed_write_data[0:L-1];
  logic                       write_valid_q[0:L-1];
  logic [  KSIGN_BANK_AW-1:0] write_addr_q[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] write_data_q[0:L-1];
  logic [ DIAG_SEG_IDX_W-1:0] diag_read_segment_idx[0:L-1];
  logic [ DIAG_SEG_IDX_W-1:0] diag_read_segment_idx_q[0:L-1];
  logic [    DIAG_SEG_AW-1:0] diag_read_local_addr[0:L-1];
  logic [ DIAG_SEG_IDX_W-1:0] diag_write_segment_idx[0:L-1];
  logic [    DIAG_SEG_AW-1:0] diag_write_local_addr[0:L-1];
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

  function automatic int slot_lsb(input int slot_idx);
    begin
      slot_lsb = SLOT_BASE_LSB + (slot_idx * DIAG_IDX_W);
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
      diag_read_segment_idx[bank_idx] = DIAG_SEG_IDX_W'(routed_read_addr[bank_idx] >> DIAG_SEG_AW);
      diag_read_local_addr[bank_idx] = DIAG_SEG_AW'(routed_read_addr[bank_idx]);
      diag_write_segment_idx[bank_idx] = DIAG_SEG_IDX_W'(write_addr_q[bank_idx] >> DIAG_SEG_AW);
      diag_write_local_addr[bank_idx] = DIAG_SEG_AW'(write_addr_q[bank_idx]);
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
          .DATA_W(1),
          .DEPTH (KSIGN_BANK_DEPTH),
          .ADDR_W(KSIGN_BANK_AW)
      ) u_base_bram (
          .i_clk  (i_clk),
          .i_we   (write_valid_q[bank_idx]),
          .i_waddr(write_addr_q[bank_idx]),
          .i_wdata(write_data_q[bank_idx][BASE_SIGN_BIT]),
          .i_re   (routed_read_valid[bank_idx]),
          .i_raddr(routed_read_addr[bank_idx]),
          .o_rdata(bank_base_sign_rdata[bank_idx])
      );

      for (genvar slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin : g_slot
        for (genvar segment_idx = 0; segment_idx < DIAG_SEG_COUNT; segment_idx++) begin : g_segment
          ram_bram #(
              .DATA_W(DIAG_IDX_W),
              .DEPTH (DIAG_SEG_DEPTH),
              .ADDR_W(DIAG_SEG_AW)
          ) u_diag_bram (
              .i_clk(i_clk),
              .i_we(write_valid_q[bank_idx] &&
                    (diag_write_segment_idx[bank_idx] == DIAG_SEG_IDX_W'(segment_idx))),
              .i_waddr(diag_write_local_addr[bank_idx]),
              .i_wdata(write_data_q[bank_idx][slot_lsb(slot_idx)+:DIAG_IDX_W]),
              .i_re(routed_read_valid[bank_idx] &&
                    (diag_read_segment_idx[bank_idx] == DIAG_SEG_IDX_W'(segment_idx))),
              .i_raddr(diag_read_local_addr[bank_idx]),
              .o_rdata(bank_diag_segment_rdata[bank_idx][slot_idx][segment_idx])
          );
        end
      end

      always_comb begin
        bank_rdata[bank_idx] = '0;
        bank_rdata[bank_idx][BASE_SIGN_BIT] = bank_base_sign_rdata[bank_idx][0];
        for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
          bank_diag_rdata[bank_idx][slot_idx] = '0;
          for (int segment_idx = 0; segment_idx < DIAG_SEG_COUNT; segment_idx++) begin
            if (diag_read_segment_idx_q[bank_idx] == DIAG_SEG_IDX_W'(segment_idx)) begin
              bank_diag_rdata[bank_idx][slot_idx] =
                  bank_diag_segment_rdata[bank_idx][slot_idx][segment_idx];
            end
          end
          bank_rdata[bank_idx][slot_lsb(slot_idx)+:DIAG_IDX_W] =
              bank_diag_rdata[bank_idx][slot_idx];
        end
      end
    end
  endgenerate

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_route_shift_q <= '0;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        diag_read_segment_idx_q[bank_idx] <= '0;
        write_valid_q[bank_idx] <= 1'b0;
      end
    end else begin
      read_route_shift_q <= read_route_shift;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        diag_read_segment_idx_q[bank_idx] <= diag_read_segment_idx[bank_idx];
        write_valid_q[bank_idx] <= routed_write_valid[bank_idx];
      end
    end
  end

  always_ff @(posedge i_clk) begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      write_addr_q[bank_idx] <= routed_write_addr[bank_idx];
      write_data_q[bank_idx] <= routed_write_data[bank_idx];
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
      if (i_read_valid[bank_idx] && (int'(i_read_col_idx[bank_idx]) >= N)) begin
        $fatal(1, "ram_k_global read column out of range lane=%0d col=%0d", bank_idx,
               i_read_col_idx[bank_idx]);
      end
      if (i_write_valid[bank_idx] && (int'(i_write_col_idx[bank_idx]) >= N)) begin
        $fatal(1, "ram_k_global write column out of range lane=%0d col=%0d", bank_idx,
               i_write_col_idx[bank_idx]);
      end
      if (i_write_valid[bank_idx] && (col_bank(
              i_write_col_idx[bank_idx]
          ) != LANE_IDX_W'(bank_idx))) begin
        $fatal(1, "ram_k_global write lane/bank mismatch lane=%0d col=%0d", bank_idx,
               i_write_col_idx[bank_idx]);
      end
      if (routed_read_valid[bank_idx] && (int'(routed_read_addr[bank_idx]) >= KSIGN_BANK_DEPTH)) begin
        $fatal(1, "ram_k_global routed read address out of range bank=%0d addr=%0d", bank_idx,
               routed_read_addr[bank_idx]);
      end
      if (write_valid_q[bank_idx] && (int'(write_addr_q[bank_idx]) >= KSIGN_BANK_DEPTH)) begin
        $fatal(1, "ram_k_global routed write address out of range bank=%0d addr=%0d", bank_idx,
               write_addr_q[bank_idx]);
      end
      if (routed_read_valid[bank_idx] && write_valid_q[bank_idx] &&
          (routed_read_addr[bank_idx] == write_addr_q[bank_idx])) begin
        $fatal(1, "ram_k_global in-place read/write collision bank=%0d addr=%0d", bank_idx,
               routed_read_addr[bank_idx]);
      end
    end
  end
`endif
endmodule
