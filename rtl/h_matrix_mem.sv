`timescale 1ns / 1ps
// H first-column index RAM with fixed-depth duplicate tracking.
module h_matrix_mem
  import bike_pkg::*;
(
    input  logic                 i_clk,
    input  logic                 i_rst_n,
    input  logic                 i_clear,
    input  logic                 i_we,
    input  logic [H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_one_idx,
    input  logic [ROW_IDX_W-1:0] i_base_row,
    input  logic [H_BLOCK_W-1:0] i_c2v_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_c2v_one_idx,
    input  logic [H_BLOCK_W-1:0] i_v2c_h_block_idx,
    input  logic [ONE_IDX_W-1:0] i_v2c_one_idx,
    output logic [ROW_IDX_W-1:0] o_c2v_base_row,
    output logic [EDGE_ID_W-1:0] o_c2v_edge_id,
    output logic [ROW_IDX_W-1:0] o_v2c_base_row,
    output logic [EDGE_ID_W-1:0] o_v2c_edge_id,
    output logic                 o_loaded,
    output logic                 o_error
);

  localparam int H_ENTRY_COUNT = N0 * W;
  localparam int H_ENTRY_COUNT_W = (H_ENTRY_COUNT > 1) ? $clog2(H_ENTRY_COUNT + 1) : 1;

  logic [      ROW_IDX_W-1:0] mem[0:N0-1][0:W-1];
  logic                       loaded_bit[0:N0-1][0:W-1];
  logic [H_ENTRY_COUNT_W-1:0] loaded_count;
  logic                       error_reg;
  logic                       duplicate_seen;
  logic                       write_req_q;
  logic [      H_BLOCK_W-1:0] write_h_block_idx_q;
  logic [      ONE_IDX_W-1:0] write_one_idx_q;
  logic [      ROW_IDX_W-1:0] write_base_row_q;
  logic                       write_index_valid_q;
  logic                       write_base_row_valid_q;
  logic                       check_valid_q;
  logic [      H_BLOCK_W-1:0] check_h_block_idx_q;
  logic [      ONE_IDX_W-1:0] check_one_idx_q;
  logic [      ROW_IDX_W-1:0] check_base_row_q;
  logic                       check_index_valid_q;
  logic                       check_base_row_valid_q;
  logic                       check_duplicate_q;

  function automatic logic [EDGE_ID_W-1:0] edge_id_of(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                                      input  logic [ONE_IDX_W-1:0] one_idx);
    begin
      edge_id_of = EDGE_ID_W'(int'(h_block_idx) * W + int'(one_idx));
    end
  endfunction

  always_comb begin
    o_c2v_base_row = mem[int'(i_c2v_h_block_idx)][int'(i_c2v_one_idx)];
    o_c2v_edge_id = edge_id_of(i_c2v_h_block_idx, i_c2v_one_idx);
    o_v2c_base_row = mem[int'(i_v2c_h_block_idx)][int'(i_v2c_one_idx)];
    o_v2c_edge_id = edge_id_of(i_v2c_h_block_idx, i_v2c_one_idx);
    o_loaded = (loaded_count == H_ENTRY_COUNT_W'(H_ENTRY_COUNT)) && !error_reg;
    o_error = error_reg;
  end

  always_comb begin
    duplicate_seen = 1'b0;
    if (write_req_q && write_index_valid_q) begin
      for (int one_scan = 0; one_scan < W; one_scan++) begin
        if ((one_scan != int'(write_one_idx_q)) &&
            loaded_bit[int'(write_h_block_idx_q)][one_scan] &&
            (mem[int'(write_h_block_idx_q)][one_scan] == write_base_row_q)) begin
          duplicate_seen = 1'b1;
        end
      end
      if (check_valid_q && check_index_valid_q && check_base_row_valid_q &&
          (check_h_block_idx_q == write_h_block_idx_q) &&
          (check_one_idx_q != write_one_idx_q) && (check_base_row_q == write_base_row_q)) begin
        duplicate_seen = 1'b1;
      end
    end
  end

  always_ff @(posedge i_clk) begin
    if (check_valid_q && check_index_valid_q && check_base_row_valid_q && !check_duplicate_q) begin
      mem[int'(check_h_block_idx_q)][int'(check_one_idx_q)] <= check_base_row_q;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      error_reg <= 1'b0;
      loaded_count <= '0;
      write_req_q <= 1'b0;
      write_h_block_idx_q <= '0;
      write_one_idx_q <= '0;
      write_base_row_q <= '0;
      write_index_valid_q <= 1'b0;
      write_base_row_valid_q <= 1'b0;
      check_valid_q <= 1'b0;
      check_h_block_idx_q <= '0;
      check_one_idx_q <= '0;
      check_base_row_q <= '0;
      check_index_valid_q <= 1'b0;
      check_base_row_valid_q <= 1'b0;
      check_duplicate_q <= 1'b0;
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          loaded_bit[h_block_idx][one_idx] <= 1'b0;
        end
      end
    end else if (i_clear) begin
      error_reg <= 1'b0;
      loaded_count <= '0;
      write_req_q <= 1'b0;
      write_h_block_idx_q <= '0;
      write_one_idx_q <= '0;
      write_base_row_q <= '0;
      write_index_valid_q <= 1'b0;
      write_base_row_valid_q <= 1'b0;
      check_valid_q <= 1'b0;
      check_h_block_idx_q <= '0;
      check_one_idx_q <= '0;
      check_base_row_q <= '0;
      check_index_valid_q <= 1'b0;
      check_base_row_valid_q <= 1'b0;
      check_duplicate_q <= 1'b0;
      for (int h_block_idx = 0; h_block_idx < N0; h_block_idx++) begin
        for (int one_idx = 0; one_idx < W; one_idx++) begin
          loaded_bit[h_block_idx][one_idx] <= 1'b0;
        end
      end
    end else begin
      write_req_q <= i_we;
      write_h_block_idx_q <= i_h_block_idx;
      write_one_idx_q <= i_one_idx;
      write_base_row_q <= i_base_row;
      write_index_valid_q <= (int'(i_h_block_idx) < N0) && (int'(i_one_idx) < W);
      write_base_row_valid_q <= int'(i_base_row) < R;

      check_valid_q <= write_req_q;
      check_h_block_idx_q <= write_h_block_idx_q;
      check_one_idx_q <= write_one_idx_q;
      check_base_row_q <= write_base_row_q;
      check_index_valid_q <= write_index_valid_q;
      check_base_row_valid_q <= write_base_row_valid_q;
      check_duplicate_q <= duplicate_seen;

      if (check_valid_q &&
          (!check_index_valid_q || !check_base_row_valid_q || check_duplicate_q)) begin
        error_reg <= 1'b1;
      end else if (check_valid_q) begin
        if (!loaded_bit[int'(check_h_block_idx_q)][int'(check_one_idx_q)]) begin
          loaded_count <= loaded_count + H_ENTRY_COUNT_W'(1);
        end
        loaded_bit[int'(check_h_block_idx_q)][int'(check_one_idx_q)] <= 1'b1;
      end
    end
  end
endmodule
