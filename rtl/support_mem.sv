`timescale 1ns / 1ps
// First-column support storage with fixed-depth duplicate tracking.
module support_mem
  import bike_pkg::*;
(
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_clear,
    input  logic                 i_we,
    input  logic [H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_one_idx,
    input  logic [ROW_IDX_W-1:0] i_support_row,
    input  logic [H_BLOCK_W-1:0] i_c2v_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_c2v_one_idx,
    input  logic [H_BLOCK_W-1:0] i_v2c_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_v2c_one_idx,
    output logic [ROW_IDX_W-1:0] o_c2v_support_row,
    output logic [EDGE_ID_W-1:0] o_c2v_edge_id,
    output logic [ROW_IDX_W-1:0] o_v2c_support_row,
    output logic [EDGE_ID_W-1:0] o_v2c_edge_id,
    output logic                 o_loaded,
    output logic                 o_error
);

  localparam int SUPPORT_COUNT = N0 * W;
  localparam int SUPPORT_COUNT_W = (SUPPORT_COUNT > 1) ? $clog2(SUPPORT_COUNT + 1) : 1;

  logic [      ROW_IDX_W-1:0] mem[0:N0-1][0:W-1];
  logic                       loaded_bit[0:N0-1][0:W-1];
  logic [SUPPORT_COUNT_W-1:0] loaded_count;
  logic                       error_reg;
  logic                       duplicate_seen;
  logic                       index_valid;

  function automatic logic [EDGE_ID_W-1:0] edge_id_of(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                                      input  logic [ONE_IDX_W-1:0] one_idx);
    begin
      edge_id_of = EDGE_ID_W'(int'(h_block_idx) * W + int'(one_idx));
    end
  endfunction

  always_comb begin
    o_c2v_support_row = mem[int'(i_c2v_h_block_idx)][int'(i_c2v_one_idx)];
    o_c2v_edge_id = edge_id_of(i_c2v_h_block_idx, i_c2v_one_idx);
    o_v2c_support_row = mem[int'(i_v2c_h_block_idx)][int'(i_v2c_one_idx)];
    o_v2c_edge_id = edge_id_of(i_v2c_h_block_idx, i_v2c_one_idx);
    o_loaded = (loaded_count == SUPPORT_COUNT_W'(SUPPORT_COUNT)) && !error_reg;
    o_error = error_reg;
  end

  always_comb begin
    duplicate_seen = 1'b0;
    index_valid = (int'(i_h_block_idx) < N0) && (int'(i_one_idx) < W);
    if (index_valid) begin
      for (int one_scan = 0; one_scan < W; one_scan++) begin
        if ((one_scan != int'(i_one_idx)) && loaded_bit[int'(i_h_block_idx)][one_scan] &&
            (mem[int'(i_h_block_idx)][one_scan] == i_support_row)) begin
          duplicate_seen = 1'b1;
        end
      end
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      error_reg <= 1'b0;
      loaded_count <= '0;
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          mem[h_block_idx][one_idx] <= '0;
          loaded_bit[h_block_idx][one_idx] <= 1'b0;
        end
      end
    end else if (i_clear) begin
      error_reg <= 1'b0;
      loaded_count <= '0;
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          loaded_bit[h_block_idx][one_idx] <= 1'b0;
        end
      end
    end else if (i_we) begin
      if (!index_valid || (int'(i_support_row) >= R) || duplicate_seen) begin
        error_reg <= 1'b1;
      end else begin
        mem[int'(i_h_block_idx)][int'(i_one_idx)] <= i_support_row;
        if (!loaded_bit[int'(i_h_block_idx)][int'(i_one_idx)]) begin
          loaded_count <= loaded_count + SUPPORT_COUNT_W'(1);
        end
        loaded_bit[int'(i_h_block_idx)][int'(i_one_idx)] <= 1'b1;
      end
    end
  end
endmodule
