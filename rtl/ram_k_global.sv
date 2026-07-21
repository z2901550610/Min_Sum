`timescale 1ns / 1ps
// Banked global RAM for in-place per-variable K-sign records.
module ram_k_global
  import bike_pkg::*;
(
    input  logic                       i_clk,
    input  logic                       i_rst_n,
    input  logic                       i_read_valid[0:L-1],
    input  logic [          COL_W-1:0] i_read_col_idx[0:L-1],
    input  logic [     DIAG_IDX_W-1:0] i_read_diag_idx_local,
    output logic [K_SIGN_RECORD_W-1:0] o_read_record[0:L-1],
    output logic                       o_read_sign[0:L-1],
    output logic                       o_read_hit[0:L-1],
    output logic                       o_read_base_sign[0:L-1],
    input  logic                       i_write_valid[0:L-1],
    input  logic [          COL_W-1:0] i_write_col_idx[0:L-1],
    input  logic [K_SIGN_RECORD_W-1:0] i_write_record[0:L-1]
);

  localparam int KSIGN_BANK_DEPTH = (N + L - 1) / L;
  localparam int KSIGN_BANK_AW = (KSIGN_BANK_DEPTH > 1) ? $clog2(KSIGN_BANK_DEPTH) : 1;
  localparam int READ_ROUTE_W = 1 + KSIGN_BANK_AW;
  localparam int READ_RESULT_W = 3;
  localparam int BASE_SIGN_BIT = 0;
  localparam int SLOT_BASE_LSB = 1;
  localparam int DIAG_SEG_MAX_AW = 12;
  localparam int DIAG_SEG_AW = (KSIGN_BANK_AW < DIAG_SEG_MAX_AW) ? KSIGN_BANK_AW : DIAG_SEG_MAX_AW;
  localparam int DIAG_SEG_DEPTH = 1 << DIAG_SEG_AW;
  localparam int DIAG_SEG_COUNT = (KSIGN_BANK_DEPTH + DIAG_SEG_DEPTH - 1) / DIAG_SEG_DEPTH;
  localparam int DIAG_SEG_IDX_W = (DIAG_SEG_COUNT > 1) ? $clog2(DIAG_SEG_COUNT) : 1;
  // For the 32-lane K=4 geometry, pair two 7-bit positions into each 18-bit RAM field.
  // At the maximum profile this maps each 10,181-deep bank to two sets of five
  // 2Kx18 RAMB36 segments, including base_sign in the first field.
  localparam bit USE_K4_PAIR_FIELDS = (L == 32) && (K_SIGN_K == 4) && (DIAG_IDX_W == 7);
  localparam int PAIR_FIELD_COUNT = 2;
  localparam int PAIR_FIELD_W = 18;
  localparam int PAIR_SEG_MAX_AW = 11;
  localparam int PAIR_SEG_AW = (KSIGN_BANK_AW < PAIR_SEG_MAX_AW) ? KSIGN_BANK_AW : PAIR_SEG_MAX_AW;
  localparam int PAIR_SEG_DEPTH = 1 << PAIR_SEG_AW;
  localparam int PAIR_SEG_COUNT = (KSIGN_BANK_DEPTH + PAIR_SEG_DEPTH - 1) / PAIR_SEG_DEPTH;
  localparam int PAIR_SEG_IDX_W = (PAIR_SEG_COUNT > 1) ? $clog2(PAIR_SEG_COUNT) : 1;

  logic [K_SIGN_RECORD_W-1:0] bank_rdata[0:L-1];
  // Exactly one physical layout is elaborated. Verilator otherwise reports the
  // declarations owned by the inactive generate branch as unused.
  /* verilator lint_off UNUSEDSIGNAL */
  logic [0:0] bank_base_sign_rdata[0:L-1];
  logic [DIAG_IDX_W-1:0] bank_diag_rdata[0:L-1][0:K_SIGN_K-1];
  logic [DIAG_IDX_W-1:0] bank_diag_segment_rdata[0:L-1][0:K_SIGN_K-1][0:DIAG_SEG_COUNT-1];
  logic [PAIR_FIELD_W-1:0] bank_pair_rdata[0:L-1][0:PAIR_FIELD_COUNT-1];
  logic [PAIR_FIELD_W-1:0] bank_pair_segment_rdata[0:L-1][0:PAIR_FIELD_COUNT-1][0:PAIR_SEG_COUNT-1];
  logic [READ_ROUTE_W-1:0] read_route_in[0:L-1];
  logic [READ_ROUTE_W-1:0] read_route_out[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] read_record_route_out[0:L-1];
  logic [READ_RESULT_W-1:0] bank_read_result[0:L-1];
  logic [READ_RESULT_W-1:0] read_result_route_out[0:L-1];
  logic routed_read_valid[0:L-1];
  logic [KSIGN_BANK_AW-1:0] routed_read_addr[0:L-1];
  logic routed_write_valid[0:L-1];
  logic [KSIGN_BANK_AW-1:0] routed_write_addr[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] routed_write_data[0:L-1];
  logic write_valid_q[0:L-1];
  logic [KSIGN_BANK_AW-1:0] write_addr_q[0:L-1];
  logic [K_SIGN_RECORD_W-1:0] write_data_q[0:L-1];
  logic [DIAG_SEG_IDX_W-1:0] diag_read_segment_idx[0:L-1];
  logic [DIAG_SEG_IDX_W-1:0] diag_read_segment_idx_q[0:L-1];
  logic [DIAG_SEG_AW-1:0] diag_read_local_addr[0:L-1];
  logic [DIAG_SEG_IDX_W-1:0] diag_write_segment_idx[0:L-1];
  logic [DIAG_SEG_AW-1:0] diag_write_local_addr[0:L-1];
  logic [PAIR_SEG_IDX_W-1:0] pair_read_segment_idx[0:L-1];
  logic [PAIR_SEG_IDX_W-1:0] pair_read_segment_idx_q[0:L-1];
  logic [PAIR_SEG_AW-1:0] pair_read_local_addr[0:L-1];
  logic [PAIR_SEG_IDX_W-1:0] pair_write_segment_idx[0:L-1];
  logic [PAIR_SEG_AW-1:0] pair_write_local_addr[0:L-1];
  /* verilator lint_on UNUSEDSIGNAL */
  logic [LANE_IDX_W-1:0] read_route_shift;
  logic [LANE_IDX_W-1:0] read_route_shift_q;
  logic [DIAG_IDX_W-1:0] read_diag_idx_local_q;

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

  function automatic logic [PAIR_FIELD_W-1:0] pair_field_data(
      input  logic [K_SIGN_RECORD_W-1:0] record, input int field_idx);
    logic [PAIR_FIELD_W-1:0] result;
    begin
      result = '0;
      if (field_idx == 0) begin
        result[0+:DIAG_IDX_W] = record[slot_lsb(0)+:DIAG_IDX_W];
        result[DIAG_IDX_W+:DIAG_IDX_W] = record[slot_lsb(1)+:DIAG_IDX_W];
        result[2*DIAG_IDX_W] = record[BASE_SIGN_BIT];
      end else begin
        result[0+:DIAG_IDX_W] = record[slot_lsb(2)+:DIAG_IDX_W];
        result[DIAG_IDX_W+:DIAG_IDX_W] = record[slot_lsb(3)+:DIAG_IDX_W];
      end
      pair_field_data = result;
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
      pair_read_segment_idx[bank_idx] = PAIR_SEG_IDX_W'(routed_read_addr[bank_idx] >> PAIR_SEG_AW);
      pair_read_local_addr[bank_idx] = PAIR_SEG_AW'(routed_read_addr[bank_idx]);
      pair_write_segment_idx[bank_idx] = PAIR_SEG_IDX_W'(write_addr_q[bank_idx] >> PAIR_SEG_AW);
      pair_write_local_addr[bank_idx] = PAIR_SEG_AW'(write_addr_q[bank_idx]);
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

  barrel_rotate #(
      .DATA_W(READ_RESULT_W)
  ) u_read_result_return (
      .i_data (bank_read_result),
      .i_shift(read_route_shift_q),
      .o_data (read_result_route_out)
  );

  generate
    for (genvar bank_idx = 0; bank_idx < L; bank_idx++) begin : g_bank
      if (USE_K4_PAIR_FIELDS) begin : g_pair_fields
        for (genvar field_idx = 0; field_idx < PAIR_FIELD_COUNT; field_idx++) begin : g_field
          for (
              genvar segment_idx = 0; segment_idx < PAIR_SEG_COUNT; segment_idx++
          ) begin : g_segment
            ram_bram #(
                .DATA_W(PAIR_FIELD_W),
                .DEPTH (PAIR_SEG_DEPTH),
                .ADDR_W(PAIR_SEG_AW)
            ) u_pair_bram (
                .i_clk(i_clk),
                .i_we(write_valid_q[bank_idx] &&
                      (pair_write_segment_idx[bank_idx] == PAIR_SEG_IDX_W'(segment_idx))),
                .i_waddr(pair_write_local_addr[bank_idx]),
                .i_wdata(pair_field_data(write_data_q[bank_idx], field_idx)),
                .i_re(routed_read_valid[bank_idx] &&
                      (pair_read_segment_idx[bank_idx] == PAIR_SEG_IDX_W'(segment_idx))),
                .i_raddr(pair_read_local_addr[bank_idx]),
                .o_rdata(bank_pair_segment_rdata[bank_idx][field_idx][segment_idx])
            );
          end
        end

        always_comb begin
          bank_rdata[bank_idx] = '0;
          for (int field_idx = 0; field_idx < PAIR_FIELD_COUNT; field_idx++) begin
            bank_pair_rdata[bank_idx][field_idx] = '0;
            for (int segment_idx = 0; segment_idx < PAIR_SEG_COUNT; segment_idx++) begin
              if (pair_read_segment_idx_q[bank_idx] == PAIR_SEG_IDX_W'(segment_idx)) begin
                bank_pair_rdata[bank_idx][field_idx] =
                    bank_pair_segment_rdata[bank_idx][field_idx][segment_idx];
              end
            end
          end
          bank_rdata[bank_idx][BASE_SIGN_BIT] = bank_pair_rdata[bank_idx][0][2*DIAG_IDX_W];
          bank_rdata[bank_idx][slot_lsb(0)+:DIAG_IDX_W] =
              bank_pair_rdata[bank_idx][0][0+:DIAG_IDX_W];
          bank_rdata[bank_idx][slot_lsb(1)+:DIAG_IDX_W] =
              bank_pair_rdata[bank_idx][0][DIAG_IDX_W+:DIAG_IDX_W];
          bank_rdata[bank_idx][slot_lsb(2)+:DIAG_IDX_W] =
              bank_pair_rdata[bank_idx][1][0+:DIAG_IDX_W];
          bank_rdata[bank_idx][slot_lsb(3)+:DIAG_IDX_W] =
              bank_pair_rdata[bank_idx][1][DIAG_IDX_W+:DIAG_IDX_W];
        end
      end else begin : g_slot_fields
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
          for (
              genvar segment_idx = 0; segment_idx < DIAG_SEG_COUNT; segment_idx++
          ) begin : g_segment
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
    end
  endgenerate

  always_comb begin
    for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
      logic hit;
      hit = 1'b0;
      for (int slot_idx = 0; slot_idx < K_SIGN_K; slot_idx++) begin
        if ((bank_rdata[bank_idx][slot_lsb(
                slot_idx
            )+:DIAG_IDX_W] != K_SIGN_DIAG_INVALID) && (bank_rdata[bank_idx][slot_lsb(
                slot_idx
            )+:DIAG_IDX_W] == read_diag_idx_local_q)) begin
          hit = 1'b1;
        end
      end
      bank_read_result[bank_idx][0] = bank_rdata[bank_idx][BASE_SIGN_BIT];
      bank_read_result[bank_idx][1] = hit;
      bank_read_result[bank_idx][2] = bank_rdata[bank_idx][BASE_SIGN_BIT] ^ hit;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_route_shift_q <= '0;
      read_diag_idx_local_q <= '0;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        diag_read_segment_idx_q[bank_idx] <= '0;
        pair_read_segment_idx_q[bank_idx] <= '0;
        write_valid_q[bank_idx] <= 1'b0;
      end
    end else begin
      read_route_shift_q <= read_route_shift;
      read_diag_idx_local_q <= i_read_diag_idx_local;
      for (int bank_idx = 0; bank_idx < L; bank_idx++) begin
        diag_read_segment_idx_q[bank_idx] <= diag_read_segment_idx[bank_idx];
        pair_read_segment_idx_q[bank_idx] <= pair_read_segment_idx[bank_idx];
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
      o_read_base_sign[lane_idx] = read_result_route_out[lane_idx][0];
      o_read_hit[lane_idx] = read_result_route_out[lane_idx][1];
      o_read_sign[lane_idx] = read_result_route_out[lane_idx][2];
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
