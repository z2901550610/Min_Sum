`timescale 1ns / 1ps
// RAM S: banked V2C sign storage indexed by edge and tile word.
module ram_s
  import bike_pkg::*;
(
    input  logic                        i_clk,
    input  logic                        i_rst_n,
    input  logic                        i_c2v_valid[0:L-1],
    input  logic [      TILE_IDX_W-1:0] i_c2v_tile_idx,
    input  logic [      TILE_OFF_W-1:0] i_c2v_tile_offset[0:L-1],
    input  logic [   DIAG_GLOBAL_W-1:0] i_c2v_diag_idx_global[0:L-1],
    output logic                        o_c2v_sign[0:L-1],
    input  logic                        i_v2c_phase_valid,
    input  logic [      TILE_IDX_W-1:0] i_v2c_tile_idx,
    input  logic [LANE_GROUP_IDX_W-1:0] i_v2c_lane_group_idx,
    input  logic [   DIAG_GLOBAL_W-1:0] i_v2c_diag_idx_global,
    input  logic                        i_v2c_write_valid[0:L-1],
    input  logic [      TILE_OFF_W-1:0] i_v2c_tile_offset[0:L-1],
    input  logic                        i_v2c_sign[0:L-1]
);

  localparam int SIGN_WORD_W = Q_BASE;
  localparam int SIGN_FRAME_W = L * SIGN_WORD_W;
  localparam int SIGN_WORD_AW = (SIGN_WORD_W > 1) ? $clog2(SIGN_WORD_W) : 1;
  localparam int SIGN_BANK_DEPTH = DIAG_GLOBAL_COUNT * TILE_COUNT;
  localparam int SIGN_BANK_AW = (SIGN_BANK_DEPTH > 1) ? $clog2(SIGN_BANK_DEPTH) : 1;
  localparam int SIGN_CHUNK_DEPTH = 4096;
  localparam int SIGN_CHUNK_COUNT = (SIGN_BANK_DEPTH + SIGN_CHUNK_DEPTH - 1) / SIGN_CHUNK_DEPTH;
  localparam int SIGN_CHUNK_IDX_W = (SIGN_CHUNK_COUNT > 1) ? $clog2(SIGN_CHUNK_COUNT) : 1;
  localparam int SIGN_CHUNK_AW = $clog2(SIGN_CHUNK_DEPTH);

  typedef logic [SIGN_WORD_AW-1:0] sign_word_idx_t;
  typedef logic [SIGN_WORD_W-1:0] sign_word_t;
  typedef logic [SIGN_FRAME_W-1:0] sign_frame_t;

  function automatic logic [SIGN_BANK_AW-1:0] diag_global_base(
      input  logic [DIAG_GLOBAL_W-1:0] diag_idx_global);
    logic [SIGN_BANK_AW-1:0] acc;
    begin
      acc = '0;
      for (int bit_idx = 0; bit_idx < SIGN_BANK_AW; bit_idx++) begin
        if (((TILE_COUNT >> bit_idx) & 1) != 0) begin
          acc = acc + (SIGN_BANK_AW'(diag_idx_global) << bit_idx);
        end
      end
      diag_global_base = acc;
    end
  endfunction

  function automatic logic [SIGN_BANK_AW-1:0] bank_addr(
      input  logic [DIAG_GLOBAL_W-1:0] diag_idx_global, input  logic [TILE_IDX_W-1:0] tile_idx);
    begin
      bank_addr = diag_global_base(diag_idx_global) + SIGN_BANK_AW'(tile_idx);
    end
  endfunction

  function automatic logic [SIGN_WORD_AW-1:0] word_bit(input  logic [TILE_OFF_W-1:0] tile_offset);
    begin
      word_bit = SIGN_WORD_AW'(tile_offset >> L_SHIFT);
    end
  endfunction

  function automatic logic [SIGN_CHUNK_IDX_W-1:0] sign_chunk_idx(
      input  logic [SIGN_BANK_AW-1:0] addr);
    begin
      sign_chunk_idx = SIGN_CHUNK_IDX_W'(int'(addr) / SIGN_CHUNK_DEPTH);
    end
  endfunction

  function automatic logic [SIGN_CHUNK_AW-1:0] sign_chunk_addr(input  logic [SIGN_BANK_AW-1:0] addr);
    begin
      sign_chunk_addr = SIGN_CHUNK_AW'(int'(addr) % SIGN_CHUNK_DEPTH);
    end
  endfunction

  logic           [    SIGN_BANK_AW-1:0] read_addr;
  logic           [SIGN_CHUNK_IDX_W-1:0] read_chunk;
  logic           [   SIGN_CHUNK_AW-1:0] read_addr_local;
  logic                                  read_valid;
  logic           [SIGN_CHUNK_IDX_W-1:0] read_chunk_q;
  logic                                  read_valid_q;
  sign_word_idx_t                        lane_rbit        [               0:L-1];
  sign_word_idx_t                        lane_rbit_q      [               0:L-1];
  logic                                  lane_read_valid_q[               0:L-1];
  sign_word_t                            lane_word_q      [               0:L-1];
  sign_word_t                            lane_word_next   [               0:L-1];
  logic                                  lane_sign_next[               0:L-1];
  logic                                  lane_sign_q[               0:L-1];
  logic                                  word_start;
  logic                                  word_flush;
  logic           [    SIGN_BANK_AW-1:0] write_addr;
  logic           [SIGN_CHUNK_IDX_W-1:0] write_chunk;
  logic           [   SIGN_CHUNK_AW-1:0] write_addr_local;
  sign_word_idx_t                        write_bit;
  sign_frame_t                           write_frame_next;
  sign_frame_t                           read_frame_next;
  sign_frame_t                           chunk_rframe_q   [0:SIGN_CHUNK_COUNT-1];

  always_comb begin
    logic [DIAG_GLOBAL_W-1:0] read_diag_idx_global;

    read_valid = 1'b0;
    read_diag_idx_global = '0;
    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      lane_rbit[lane_idx] = '0;
      if (i_c2v_valid[lane_idx]) begin
        if (!read_valid) begin
          read_diag_idx_global = i_c2v_diag_idx_global[lane_idx];
        end
        read_valid = 1'b1;
        lane_rbit[lane_idx] = word_bit(i_c2v_tile_offset[lane_idx]);
      end
    end

    read_addr = bank_addr(read_diag_idx_global, i_c2v_tile_idx);
    read_chunk = sign_chunk_idx(read_addr);
    read_addr_local = sign_chunk_addr(read_addr);
  end

  always_comb begin
    word_start = i_v2c_phase_valid && (i_v2c_lane_group_idx == '0);
    word_flush = i_v2c_phase_valid && (i_v2c_lane_group_idx == LANE_GROUP_IDX_W'(Q_TILE - 1));
    write_addr = bank_addr(i_v2c_diag_idx_global, i_v2c_tile_idx);
    write_chunk = sign_chunk_idx(write_addr);
    write_addr_local = sign_chunk_addr(write_addr);
    write_frame_next = '0;

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      write_bit = '0;
      lane_word_next[lane_idx] = word_start ? '0 : lane_word_q[lane_idx];
      if (i_v2c_write_valid[lane_idx]) begin
        write_bit = word_bit(i_v2c_tile_offset[lane_idx]);
        lane_word_next[lane_idx][write_bit] = i_v2c_sign[lane_idx];
      end
      write_frame_next[(lane_idx*SIGN_WORD_W)+:SIGN_WORD_W] = lane_word_next[lane_idx];
    end
  end

  always_comb begin
    read_frame_next = '0;
    for (int chunk_sel = 0; chunk_sel < SIGN_CHUNK_COUNT; chunk_sel++) begin
      if (read_valid_q && (int'(read_chunk_q) == chunk_sel)) begin
        read_frame_next = chunk_rframe_q[chunk_sel];
      end
    end

    for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
      lane_sign_next[lane_idx] = lane_read_valid_q[lane_idx] ?
          read_frame_next[(lane_idx*SIGN_WORD_W)+int'(lane_rbit_q[lane_idx])] : 1'b0;
      o_c2v_sign[lane_idx] = lane_sign_q[lane_idx];
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      read_chunk_q <= '0;
      read_valid_q <= 1'b0;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        lane_word_q[lane_idx] <= '0;
        lane_rbit_q[lane_idx] <= '0;
        lane_read_valid_q[lane_idx] <= 1'b0;
        lane_sign_q[lane_idx] <= 1'b0;
      end
    end else begin
      read_chunk_q <= read_chunk;
      read_valid_q <= read_valid;
      for (int lane_idx = 0; lane_idx < L; lane_idx++) begin
        lane_word_q[lane_idx] <= word_flush ? '0 : lane_word_next[lane_idx];
        lane_rbit_q[lane_idx] <= lane_rbit[lane_idx];
        lane_read_valid_q[lane_idx] <= i_c2v_valid[lane_idx];
        lane_sign_q[lane_idx] <= lane_sign_next[lane_idx];
      end
    end
  end

  for (genvar chunk_idx = 0; chunk_idx < SIGN_CHUNK_COUNT; chunk_idx++) begin : g_chunk
    (* ram_style = "block" *)sign_frame_t                     mem          [0:SIGN_CHUNK_DEPTH-1];
    logic                            write_we_q;
    logic        [SIGN_CHUNK_AW-1:0] write_addr_q;
    sign_frame_t                     write_data_q;

    always_ff @(posedge i_clk) begin
      if (read_valid && (int'(read_chunk) == chunk_idx)) begin
        chunk_rframe_q[chunk_idx] <= mem[read_addr_local];
      end
      if (write_we_q) begin
        mem[write_addr_q] <= write_data_q;
      end
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
      if (!i_rst_n) begin
        write_we_q   <= 1'b0;
        write_addr_q <= '0;
        write_data_q <= '0;
      end else begin
        write_we_q <= 1'b0;
        if (word_flush && (int'(write_chunk) == chunk_idx)) begin
          write_we_q   <= 1'b1;
          write_addr_q <= write_addr_local;
          write_data_q <= write_frame_next;
        end
      end
    end
  end
endmodule
