`timescale 1ns / 1ps
// RAM I: H first-column index storage with fixed-depth duplicate tracking.
module ram_i
  import bike_pkg::*;
(
    input  logic                  i_clk,
    input  logic                  i_rst_n,
    input  logic                  i_clear,
    input  logic                  i_we,
    input  logic [ H_BLOCK_W-1:0] i_h_block_idx,
    input  logic [DIAG_IDX_W-1:0] i_diag_idx_local,
    input  logic [ ROW_IDX_W-1:0] i_base_row_idx,
    input  logic [ H_BLOCK_W-1:0] i_c2v_h_block_idx,
    input  logic [DIAG_IDX_W-1:0] i_c2v_diag_idx_local,
    input  logic [ H_BLOCK_W-1:0] i_v2c_h_block_idx,
    input  logic [DIAG_IDX_W-1:0] i_v2c_diag_idx_local,
    input  logic [   CFG_R_W-1:0] i_cfg_r,
    input  logic [   CFG_W_W-1:0] i_cfg_w,
    output logic [ ROW_IDX_W-1:0] o_c2v_base_row_idx,
    output logic [ ROW_IDX_W-1:0] o_v2c_base_row_idx,
    output logic                  o_loaded,
    output logic                  o_error
);

  localparam int H_ENTRY_COUNT = N0 * W;
  localparam int H_ENTRY_COUNT_W = (H_ENTRY_COUNT > 1) ? $clog2(H_ENTRY_COUNT + 1) : 1;

  logic [      ROW_IDX_W-1:0] mem[0:H_ENTRY_COUNT-1];
  logic                       loaded_bit[0:H_ENTRY_COUNT-1];
  logic [H_ENTRY_COUNT_W-1:0] loaded_count;
  logic                       error_reg;
  logic                       duplicate_seen;
  logic                       write_req_q;
  logic [      H_BLOCK_W-1:0] write_h_block_idx_q;
  logic [     DIAG_IDX_W-1:0] write_diag_idx_local_q;
  logic [      ROW_IDX_W-1:0] write_base_row_idx_q;
  logic                       write_index_valid_q;
  logic                       write_base_row_idx_valid_q;
  logic                       check_valid_q;
  logic [      H_BLOCK_W-1:0] check_h_block_idx_q;
  logic [     DIAG_IDX_W-1:0] check_diag_idx_local_q;
  logic [      ROW_IDX_W-1:0] check_base_row_idx_q;
  logic                       check_index_valid_q;
  logic                       check_base_row_idx_valid_q;
  logic                       check_duplicate_q;

  function automatic int h_entry_addr(input  logic [H_BLOCK_W-1:0] h_block_idx,
                                      input  logic [DIAG_IDX_W-1:0] diag_idx_local);
    begin
      h_entry_addr = (int'(h_block_idx) * W) + int'(diag_idx_local);
    end
  endfunction

  always_comb begin
    logic [H_ENTRY_COUNT_W-1:0] loaded_target;

    loaded_target = H_ENTRY_COUNT_W'(N0 * int'(i_cfg_w));
    o_loaded = (loaded_count == loaded_target) && !error_reg;
    o_error = error_reg;
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_c2v_base_row_idx <= '0;
      o_v2c_base_row_idx <= '0;
    end else if (i_clear) begin
      o_c2v_base_row_idx <= '0;
      o_v2c_base_row_idx <= '0;
    end else begin
      o_c2v_base_row_idx <= mem[h_entry_addr(i_c2v_h_block_idx, i_c2v_diag_idx_local)];
      o_v2c_base_row_idx <= mem[h_entry_addr(i_v2c_h_block_idx, i_v2c_diag_idx_local)];
    end
  end

  always_comb begin
    duplicate_seen = 1'b0;
    if (write_req_q && write_index_valid_q) begin
      for (int diag_scan = 0; diag_scan < W; diag_scan++) begin
        if ((diag_scan < int'(i_cfg_w)) && (diag_scan != int'(write_diag_idx_local_q)) &&
            loaded_bit[h_entry_addr(
                write_h_block_idx_q, DIAG_IDX_W'(diag_scan)
            )] && (mem[h_entry_addr(
                write_h_block_idx_q, DIAG_IDX_W'(diag_scan)
            )] == write_base_row_idx_q)) begin
          duplicate_seen = 1'b1;
        end
      end
      if (check_valid_q && check_index_valid_q && check_base_row_idx_valid_q &&
          (check_h_block_idx_q == write_h_block_idx_q) &&
          (check_diag_idx_local_q != write_diag_idx_local_q) && (check_base_row_idx_q == write_base_row_idx_q)) begin
        duplicate_seen = 1'b1;
      end
    end
  end

  always_ff @(posedge i_clk) begin
    if (check_valid_q && check_index_valid_q && check_base_row_idx_valid_q && !check_duplicate_q) begin
      mem[h_entry_addr(check_h_block_idx_q, check_diag_idx_local_q)] <= check_base_row_idx_q;
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      error_reg <= 1'b0;
      loaded_count <= '0;
      write_req_q <= 1'b0;
      write_h_block_idx_q <= '0;
      write_diag_idx_local_q <= '0;
      write_base_row_idx_q <= '0;
      write_index_valid_q <= 1'b0;
      write_base_row_idx_valid_q <= 1'b0;
      check_valid_q <= 1'b0;
      check_h_block_idx_q <= '0;
      check_diag_idx_local_q <= '0;
      check_base_row_idx_q <= '0;
      check_index_valid_q <= 1'b0;
      check_base_row_idx_valid_q <= 1'b0;
      check_duplicate_q <= 1'b0;
      for (int entry_idx = 0; entry_idx < H_ENTRY_COUNT; entry_idx++) begin
        loaded_bit[entry_idx] <= 1'b0;
      end
    end else if (i_clear) begin
      error_reg <= 1'b0;
      loaded_count <= '0;
      write_req_q <= 1'b0;
      write_h_block_idx_q <= '0;
      write_diag_idx_local_q <= '0;
      write_base_row_idx_q <= '0;
      write_index_valid_q <= 1'b0;
      write_base_row_idx_valid_q <= 1'b0;
      check_valid_q <= 1'b0;
      check_h_block_idx_q <= '0;
      check_diag_idx_local_q <= '0;
      check_base_row_idx_q <= '0;
      check_index_valid_q <= 1'b0;
      check_base_row_idx_valid_q <= 1'b0;
      check_duplicate_q <= 1'b0;
      for (int entry_idx = 0; entry_idx < H_ENTRY_COUNT; entry_idx++) begin
        loaded_bit[entry_idx] <= 1'b0;
      end
    end else begin
      write_req_q <= i_we;
      write_h_block_idx_q <= i_h_block_idx;
      write_diag_idx_local_q <= i_diag_idx_local;
      write_base_row_idx_q <= i_base_row_idx;
      write_index_valid_q <= (int'(i_h_block_idx) < N0) && (int'(i_diag_idx_local) < int'(i_cfg_w));
      write_base_row_idx_valid_q <= int'(i_base_row_idx) < int'(i_cfg_r);

      check_valid_q <= write_req_q;
      check_h_block_idx_q <= write_h_block_idx_q;
      check_diag_idx_local_q <= write_diag_idx_local_q;
      check_base_row_idx_q <= write_base_row_idx_q;
      check_index_valid_q <= write_index_valid_q;
      check_base_row_idx_valid_q <= write_base_row_idx_valid_q;
      check_duplicate_q <= duplicate_seen;

      if (check_valid_q &&
          (!check_index_valid_q || !check_base_row_idx_valid_q || check_duplicate_q)) begin
        error_reg <= 1'b1;
      end else if (check_valid_q) begin
        if (!loaded_bit[h_entry_addr(check_h_block_idx_q, check_diag_idx_local_q)]) begin
          loaded_count <= loaded_count + H_ENTRY_COUNT_W'(1);
        end
        loaded_bit[h_entry_addr(check_h_block_idx_q, check_diag_idx_local_q)] <= 1'b1;
      end
    end
  end
endmodule
