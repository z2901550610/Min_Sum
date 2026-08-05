`timescale 1ns / 1ps

// Fixed-schedule storage for an H4 support and its padded dense error vector.
//
// Each accepted global index is written to support RAM and performs one dense
// byte read/modify/write. The dense layout is e0 || e1 || e2, with every block
// padded independently to PADDED_R_BYTES for the TRIKE L(e) input.
module trike_error_support_store #(
    parameter int R_BITS         = 15581,
    parameter int ERROR_WEIGHT   = 263,
    parameter int PADDED_R_BYTES = ((R_BITS + 511) / 512) * 64
) (
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_start,
    input  logic i_index_valid,
    input  logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] i_index_position,
    input  logic [(((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] i_index,
    output logic o_index_ready,
    input  logic i_support_re,
    input  logic [((ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1)-1:0] i_support_raddr,
    output logic [(((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1)-1:0] o_support_rdata,
    input  logic i_error_re,
    input  logic [(((3 * PADDED_R_BYTES) > 1) ? $clog2(
        3 * PADDED_R_BYTES
    ) : 1)-1:0] i_error_raddr,
    output logic [7:0] o_error_rdata,
    output logic o_busy,
    output logic o_done
);

  localparam int ERROR_BYTES = 3 * PADDED_R_BYTES;
  localparam int ERROR_ADDR_W = (ERROR_BYTES > 1) ? $clog2(ERROR_BYTES) : 1;
  localparam int SUPPORT_ADDR_W = (ERROR_WEIGHT > 1) ? $clog2(ERROR_WEIGHT) : 1;
  localparam int GLOBAL_INDEX_W = ((3 * R_BITS) > 1) ? $clog2(3 * R_BITS) : 1;

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_CLEAR_ERROR,
    ST_LOAD_READ,
    ST_LOAD_WRITE
  } state_t;

  state_t                      state_q;
  integer                      clear_addr_q;
  integer                      index_count_q;
  logic   [  ERROR_ADDR_W-1:0] error_addr_q;
  logic   [               2:0] error_bit_q;

  logic                        support_we;
  logic   [SUPPORT_ADDR_W-1:0] support_waddr;
  logic   [GLOBAL_INDEX_W-1:0] support_wdata;
  logic                        support_re;
  logic   [SUPPORT_ADDR_W-1:0] support_raddr;

  logic                        error_we;
  logic   [  ERROR_ADDR_W-1:0] error_waddr;
  logic   [               7:0] error_wdata;
  logic                        error_re;
  logic   [  ERROR_ADDR_W-1:0] error_raddr;
  logic   [               7:0] error_rdata;

  integer                      input_block_c;
  integer                      input_local_c;
  logic   [  ERROR_ADDR_W-1:0] input_error_addr_c;

  ram_bram #(
      .DATA_W(GLOBAL_INDEX_W),
      .DEPTH (ERROR_WEIGHT)
  ) u_support_mem (
      .i_clk  (i_clk),
      .i_we   (support_we),
      .i_waddr(support_waddr),
      .i_wdata(support_wdata),
      .i_re   (support_re),
      .i_raddr(support_raddr),
      .o_rdata(o_support_rdata)
  );

  ram_bram #(
      .DATA_W(8),
      .DEPTH (ERROR_BYTES)
  ) u_error_mem (
      .i_clk  (i_clk),
      .i_we   (error_we),
      .i_waddr(error_waddr),
      .i_wdata(error_wdata),
      .i_re   (error_re),
      .i_raddr(error_raddr),
      .o_rdata(error_rdata)
  );

  assign o_error_rdata = error_rdata;
  assign o_index_ready = state_q == ST_LOAD_READ;
  assign o_busy = state_q != ST_IDLE;

  always_comb begin
    input_block_c = int'(i_index) / R_BITS;
    input_local_c = int'(i_index) % R_BITS;
    input_error_addr_c = ERROR_ADDR_W'((input_block_c * PADDED_R_BYTES) + (input_local_c / 8));

    support_we = 1'b0;
    support_waddr = i_index_position;
    support_wdata = i_index;
    support_re = (state_q == ST_IDLE) && i_support_re;
    support_raddr = i_support_raddr;
    error_we = 1'b0;
    error_waddr = '0;
    error_wdata = '0;
    error_re = (state_q == ST_IDLE) && i_error_re;
    error_raddr = i_error_raddr;

    unique case (state_q)
      ST_CLEAR_ERROR: begin
        error_we = 1'b1;
        error_waddr = ERROR_ADDR_W'(clear_addr_q);
      end

      ST_LOAD_READ: begin
        if (i_index_valid) begin
          support_we = 1'b1;
          error_re = 1'b1;
          error_raddr = ERROR_ADDR_W'(input_error_addr_c);
        end
      end

      ST_LOAD_WRITE: begin
        error_we = 1'b1;
        error_waddr = error_addr_q;
        error_wdata = error_rdata ^ (8'h01 << error_bit_q);
      end

      default: begin
      end
    endcase
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      clear_addr_q <= 0;
      index_count_q <= 0;
      error_addr_q <= '0;
      error_bit_q <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            clear_addr_q <= 0;
            index_count_q <= 0;
            state_q <= ST_CLEAR_ERROR;
          end
        end

        ST_CLEAR_ERROR: begin
          if (clear_addr_q == (ERROR_BYTES - 1)) begin
            state_q <= ST_LOAD_READ;
          end else begin
            clear_addr_q <= clear_addr_q + 1;
          end
        end

        ST_LOAD_READ: begin
          if (i_index_valid) begin
            error_addr_q <= ERROR_ADDR_W'(input_error_addr_c);
            error_bit_q <= 3'(input_local_c % 8);
            state_q <= ST_LOAD_WRITE;
          end
        end

        ST_LOAD_WRITE: begin
          if (index_count_q == (ERROR_WEIGHT - 1)) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end else begin
            index_count_q <= index_count_q + 1;
            state_q <= ST_LOAD_READ;
          end
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if ((state_q == ST_LOAD_READ) && i_index_valid && (int'(i_index) >= (3 * R_BITS))) begin
      $error("trike_error_support_store index out of range");
    end
  end

  initial begin
    if (R_BITS < 1) $error("trike_error_support_store R_BITS must be at least 1");
    if (ERROR_WEIGHT < 1) begin
      $error("trike_error_support_store ERROR_WEIGHT must be at least 1");
    end
    if (PADDED_R_BYTES < ((R_BITS + 7) / 8)) begin
      $error("trike_error_support_store PADDED_R_BYTES is too small");
    end
  end
`endif

endmodule
