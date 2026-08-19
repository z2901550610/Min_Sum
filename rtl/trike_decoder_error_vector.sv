`timescale 1ns / 1ps

// Reads the complete decoder decision at a fixed one-bit-per-cycle rate and
// stores e0 || e1 || e2 with zero padding at each active block boundary.
// Runtime geometry is a public transaction descriptor sampled with i_start;
// the memory allocation remains sized for the maximum configured profile.
module trike_decoder_error_vector #(
    parameter int R_BITS = 12589,
    parameter int BLOCKS = 3,
    parameter int PADDED_R_BYTES = ((R_BITS + 511) / 512) * 64,
    parameter bit RUNTIME_GEOMETRY = 1'b0,
    parameter int COL_W = (((BLOCKS * R_BITS) > 1) ? $clog2(BLOCKS * R_BITS) : 1),
    parameter int ERROR_ADDR_W = (((BLOCKS * PADDED_R_BYTES) > 1) ? $clog2(
        BLOCKS * PADDED_R_BYTES
    ) : 1)
) (
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    input  logic                    i_start,
    input  logic [            31:0] i_runtime_r_bits,
    output logic [       COL_W-1:0] o_decision_col_idx,
    input  logic                    i_decision_data,
    input  logic                    i_error_re,
    input  logic [ERROR_ADDR_W-1:0] i_error_raddr,
    output logic [             7:0] o_error_rdata,
    output logic                    o_busy,
    output logic                    o_done
);

  localparam int ERROR_BYTES = BLOCKS * PADDED_R_BYTES;
  localparam int BLOCK_W = (BLOCKS > 1) ? $clog2(BLOCKS) : 1;
  localparam int LOCAL_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_CLEAR,
    ST_SCAN
  } state_t;

  state_t                    state_q;
  integer                    clear_addr_q;
  logic   [       COL_W-1:0] issue_col_q;
  logic   [     BLOCK_W-1:0] issue_block_q;
  logic   [     LOCAL_W-1:0] issue_local_q;
  logic                      response_valid_q;
  logic   [             2:0] response_bit_q;
  logic   [ERROR_ADDR_W-1:0] response_error_addr_q;
  logic                      response_byte_last_q;
  logic                      response_last_q;
  logic   [             7:0] byte_accum_q;
  logic                      error_we;
  logic   [ERROR_ADDR_W-1:0] error_waddr;
  logic   [             7:0] error_wdata;
  logic                      error_re;
  integer                    active_r_bits_q;
  integer                    active_padded_r_bytes_q;
  integer                    active_error_bytes_q;

  ram_bram #(
      .DATA_W(8),
      .DEPTH (ERROR_BYTES),
      .ADDR_W(ERROR_ADDR_W)
  ) u_error_mem (
      .i_clk  (i_clk),
      .i_we   (error_we),
      .i_waddr(error_waddr),
      .i_wdata(error_wdata),
      .i_re   (error_re),
      .i_raddr(i_error_raddr),
      .o_rdata(o_error_rdata)
  );

  assign o_decision_col_idx = issue_col_q;
  assign o_busy = state_q != ST_IDLE;

  always_comb begin
    error_we = 1'b0;
    error_waddr = '0;
    error_wdata = '0;
    error_re = (state_q == ST_IDLE) && i_error_re;

    if (state_q == ST_CLEAR) begin
      error_we = 1'b1;
      error_waddr = ERROR_ADDR_W'(clear_addr_q);
    end else if (state_q == ST_SCAN && response_valid_q && response_byte_last_q) begin
      error_we = 1'b1;
      error_waddr = response_error_addr_q;
      error_wdata = byte_accum_q | (8'(i_decision_data) << response_bit_q);
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      clear_addr_q <= 0;
      issue_col_q <= '0;
      issue_block_q <= '0;
      issue_local_q <= '0;
      response_valid_q <= 1'b0;
      response_bit_q <= '0;
      response_error_addr_q <= '0;
      response_byte_last_q <= 1'b0;
      response_last_q <= 1'b0;
      byte_accum_q <= '0;
      active_r_bits_q <= R_BITS;
      active_padded_r_bytes_q <= PADDED_R_BYTES;
      active_error_bytes_q <= ERROR_BYTES;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            clear_addr_q <= 0;
            issue_col_q <= '0;
            issue_block_q <= '0;
            issue_local_q <= '0;
            response_valid_q <= 1'b0;
            byte_accum_q <= '0;
            if (RUNTIME_GEOMETRY) begin
              active_r_bits_q <= int'(i_runtime_r_bits);
              active_padded_r_bytes_q <= ((int'(i_runtime_r_bits) + 511) / 512) * 64;
              active_error_bytes_q <= BLOCKS * (((int'(i_runtime_r_bits) + 511) / 512) * 64);
            end else begin
              active_r_bits_q <= R_BITS;
              active_padded_r_bytes_q <= PADDED_R_BYTES;
              active_error_bytes_q <= ERROR_BYTES;
            end
            state_q <= ST_CLEAR;
          end
        end

        ST_CLEAR: begin
          if (clear_addr_q == (active_error_bytes_q - 1)) begin
            response_valid_q <= 1'b0;
            state_q <= ST_SCAN;
          end else begin
            clear_addr_q <= clear_addr_q + 1;
          end
        end

        ST_SCAN: begin
          if (response_valid_q) begin
            if (response_byte_last_q) byte_accum_q <= '0;
            else byte_accum_q[response_bit_q] <= i_decision_data;
            if (response_last_q) begin
              response_valid_q <= 1'b0;
              o_done <= 1'b1;
              state_q <= ST_IDLE;
            end
          end

          if (!response_valid_q || !response_last_q) begin
            response_valid_q <= 1'b1;
            response_bit_q <= issue_local_q[2:0];
            response_error_addr_q <= ERROR_ADDR_W'(
                (int'(issue_block_q) * active_padded_r_bytes_q) + (int'(issue_local_q) / 8));
            response_byte_last_q <= (issue_local_q[2:0] == 3'd7) ||
                                    (issue_local_q == LOCAL_W'(active_r_bits_q - 1));
            response_last_q <= issue_col_q == COL_W'((BLOCKS * active_r_bits_q) - 1);
            if (issue_col_q != COL_W'((BLOCKS * active_r_bits_q) - 1)) begin
              issue_col_q <= issue_col_q + 1'b1;
              if (issue_local_q == LOCAL_W'(active_r_bits_q - 1)) begin
                issue_local_q <= '0;
                issue_block_q <= issue_block_q + 1'b1;
              end else begin
                issue_local_q <= issue_local_q + 1'b1;
              end
            end
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  initial begin
    if ((R_BITS <= 0) || (BLOCKS <= 0))
      $fatal(1, "trike_decoder_error_vector requires positive geometry");
    if (PADDED_R_BYTES < ((R_BITS + 7) / 8))
      $fatal(1, "trike_decoder_error_vector padding is too small");
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS))
        $fatal(1, "trike_decoder_error_vector runtime r out of range");
      if ((((int'(i_runtime_r_bits) + 511) / 512) * 64) > PADDED_R_BYTES)
        $fatal(1, "trike_decoder_error_vector runtime padding exceeds allocation");
    end
  end
`endif

endmodule
