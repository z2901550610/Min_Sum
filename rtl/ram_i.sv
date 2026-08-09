`timescale 1ns / 1ps
// RAM I: replicated block memory with fixed-cycle H-column validation.
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
    input  logic [ H_BLOCK_W-1:0] i_corr_h_block_idx,
    input  logic [DIAG_IDX_W-1:0] i_corr_diag_idx_local,
    input  logic [   CFG_R_W-1:0] i_cfg_r,
    input  logic [   CFG_W_W-1:0] i_cfg_w,
    output logic [ ROW_IDX_W-1:0] o_c2v_base_row_idx,
    output logic [ ROW_IDX_W-1:0] o_v2c_base_row_idx,
    output logic [ ROW_IDX_W-1:0] o_corr_base_row_idx,
    output logic                  o_loaded,
    output logic                  o_error
);

  localparam int H_ENTRY_COUNT   = N0 * W;
  localparam int H_ENTRY_ADDR_W  = (H_ENTRY_COUNT > 1) ? $clog2(H_ENTRY_COUNT) : 1;
  localparam int H_ENTRY_COUNT_W = (H_ENTRY_COUNT > 1) ? $clog2(H_ENTRY_COUNT + 1) : 1;

  logic [  H_ENTRY_COUNT-1:0] loaded_bit;
  logic [H_ENTRY_COUNT_W-1:0] request_count;
  logic [H_ENTRY_COUNT_W-1:0] loaded_count;

  logic                       error_reg;
  logic                       validation_active;
  logic                       validation_done;
  logic [      H_BLOCK_W-1:0] validation_h_block_idx;
  logic [     DIAG_IDX_W-1:0] validation_diag_idx;
  logic [     DIAG_IDX_W-1:0] validation_scan_idx;
  logic                       compare_valid_q;
  logic                       compare_same_entry_q;
  logic                       compare_last_q;

  logic                       write_index_valid;
  logic                       write_row_valid;
  logic                       write_entry_new;
  logic                       write_accept;
  logic [ H_ENTRY_ADDR_W-1:0] write_addr;
  logic [ H_ENTRY_ADDR_W-1:0] read_addr_a;
  logic [ H_ENTRY_ADDR_W-1:0] read_addr_b;
  logic [ H_ENTRY_ADDR_W-1:0] read_addr_c;
  logic [      ROW_IDX_W-1:0] read_data_a;
  logic [      ROW_IDX_W-1:0] read_data_b;
  logic [      ROW_IDX_W-1:0] read_data_c;
  logic [H_ENTRY_COUNT_W-1:0] loaded_target;
  logic                       validation_diag_last;
  logic                       validation_scan_last;
  logic                       validation_block_last;
  logic                       validation_tuple_last;

  function automatic logic [H_ENTRY_ADDR_W-1:0] h_entry_addr(
      input  logic [H_BLOCK_W-1:0] h_block_idx, input  logic [DIAG_IDX_W-1:0] diag_idx_local);
    begin
      h_entry_addr = H_ENTRY_ADDR_W'((int'(h_block_idx) * W) + int'(diag_idx_local));
    end
  endfunction

  always_comb begin
    loaded_target = H_ENTRY_COUNT_W'(N0 * int'(i_cfg_w));

    write_addr = h_entry_addr(i_h_block_idx, i_diag_idx_local);
    write_index_valid = (int'(i_h_block_idx) < N0) && (int'(i_diag_idx_local) < int'(i_cfg_w));
    write_row_valid = int'(i_base_row_idx) < int'(i_cfg_r);
    write_entry_new = 1'b0;
    if (write_index_valid && write_row_valid) begin
      write_entry_new = !loaded_bit[write_addr];
    end
    write_accept =
        i_we && i_rst_n && !i_clear && !validation_active && !validation_done && write_entry_new;

    validation_diag_last = (int'(validation_diag_idx) + 1) >= int'(i_cfg_w);
    validation_scan_last = (int'(validation_scan_idx) + 1) >= int'(i_cfg_w);
    validation_block_last = (int'(validation_h_block_idx) + 1) >= N0;
    validation_tuple_last = validation_diag_last && validation_scan_last && validation_block_last;

    if (validation_active) begin
      read_addr_a = h_entry_addr(validation_h_block_idx, validation_diag_idx);
      read_addr_b = h_entry_addr(validation_h_block_idx, validation_scan_idx);
    end else begin
      read_addr_a = h_entry_addr(i_c2v_h_block_idx, i_c2v_diag_idx_local);
      read_addr_b = h_entry_addr(i_v2c_h_block_idx, i_v2c_diag_idx_local);
    end
    read_addr_c = h_entry_addr(i_corr_h_block_idx, i_corr_diag_idx_local);

    o_c2v_base_row_idx = validation_done ? read_data_a : '0;
    o_v2c_base_row_idx = validation_done ? read_data_b : '0;
    o_corr_base_row_idx = validation_done ? read_data_c : '0;
    o_loaded = validation_done && !error_reg;
    o_error = validation_done && error_reg;
  end

  ram_bram #(
      .DATA_W(ROW_IDX_W),
      .DEPTH (H_ENTRY_COUNT),
      .ADDR_W(H_ENTRY_ADDR_W)
  ) u_mem_c2v (
      .i_clk  (i_clk),
      .i_we   (write_accept),
      .i_waddr(write_addr),
      .i_wdata(i_base_row_idx),
      .i_re   (1'b1),
      .i_raddr(read_addr_a),
      .o_rdata(read_data_a)
  );

  ram_bram #(
      .DATA_W(ROW_IDX_W),
      .DEPTH (H_ENTRY_COUNT),
      .ADDR_W(H_ENTRY_ADDR_W)
  ) u_mem_v2c (
      .i_clk  (i_clk),
      .i_we   (write_accept),
      .i_waddr(write_addr),
      .i_wdata(i_base_row_idx),
      .i_re   (1'b1),
      .i_raddr(read_addr_b),
      .o_rdata(read_data_b)
  );

  ram_bram #(
      .DATA_W(ROW_IDX_W),
      .DEPTH (H_ENTRY_COUNT),
      .ADDR_W(H_ENTRY_ADDR_W)
  ) u_mem_corr (
      .i_clk  (i_clk),
      .i_we   (write_accept),
      .i_waddr(write_addr),
      .i_wdata(i_base_row_idx),
      .i_re   (1'b1),
      .i_raddr(read_addr_c),
      .o_rdata(read_data_c)
  );

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      loaded_bit <= '0;
      request_count <= '0;
      loaded_count <= '0;
      error_reg <= 1'b0;
      validation_active <= 1'b0;
      validation_done <= 1'b0;
      validation_h_block_idx <= '0;
      validation_diag_idx <= '0;
      validation_scan_idx <= '0;
      compare_valid_q <= 1'b0;
      compare_same_entry_q <= 1'b0;
      compare_last_q <= 1'b0;
    end else if (i_clear) begin
      loaded_bit <= '0;
      request_count <= '0;
      loaded_count <= '0;
      error_reg <= 1'b0;
      validation_active <= 1'b0;
      validation_done <= 1'b0;
      validation_h_block_idx <= '0;
      validation_diag_idx <= '0;
      validation_scan_idx <= '0;
      compare_valid_q <= 1'b0;
      compare_same_entry_q <= 1'b0;
      compare_last_q <= 1'b0;
    end else begin
      compare_valid_q <= validation_active;
      compare_same_entry_q <= validation_diag_idx == validation_scan_idx;
      compare_last_q <= validation_active && validation_tuple_last;

      if (compare_valid_q) begin
        if (!compare_same_entry_q && (read_data_a == read_data_b)) begin
          error_reg <= 1'b1;
        end
        if (compare_last_q) begin
          validation_done <= 1'b1;
        end
      end

      if (validation_active) begin
        if (validation_scan_last) begin
          validation_scan_idx <= '0;
          if (validation_diag_last) begin
            validation_diag_idx <= '0;
            if (validation_block_last) begin
              validation_h_block_idx <= '0;
              validation_active <= 1'b0;
            end else begin
              validation_h_block_idx <= validation_h_block_idx + H_BLOCK_W'(1);
            end
          end else begin
            validation_diag_idx <= validation_diag_idx + DIAG_IDX_W'(1);
          end
        end else begin
          validation_scan_idx <= validation_scan_idx + DIAG_IDX_W'(1);
        end
      end

      if (i_we) begin
        if (validation_active || validation_done) begin
          error_reg <= 1'b1;
        end else begin
          request_count <= request_count + H_ENTRY_COUNT_W'(1);

          if (!write_index_valid || !write_row_valid || !write_entry_new) begin
            error_reg <= 1'b1;
          end else begin
            loaded_bit[write_addr] <= 1'b1;
            loaded_count <= loaded_count + H_ENTRY_COUNT_W'(1);
          end

          if ((loaded_target != '0) &&
              (request_count == (loaded_target - H_ENTRY_COUNT_W'(1)))) begin
            validation_active <= 1'b1;
            validation_h_block_idx <= '0;
            validation_diag_idx <= '0;
            validation_scan_idx <= '0;
            if ((loaded_count + H_ENTRY_COUNT_W'(write_accept)) != loaded_target) begin
              error_reg <= 1'b1;
            end
          end
        end
      end
    end
  end
endmodule
