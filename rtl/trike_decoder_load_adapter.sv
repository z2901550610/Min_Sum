`timescale 1ns / 1ps

// Fixed-schedule bridge from KEM word streams to decoder_top load ports.
// H support is accepted in block-major sampler order and emitted in ascending
// order within each block. Syndrome words are little-endian by coefficient and
// are serialized into exactly R_BITS single-bit writes.
module trike_decoder_load_adapter #(
    parameter int R_BITS           = 15581,
    parameter int BLOCKS           = 3,
    parameter int WEIGHT           = 35,
    parameter int WORD_W           = 64,
    parameter bit RUNTIME_GEOMETRY = 1'b0,
    parameter int ROW_W            = ((R_BITS > 1) ? $clog2(R_BITS) : 1),
    parameter int BLOCK_W          = ((BLOCKS > 1) ? $clog2(BLOCKS) : 1),
    parameter int DIAG_W           = ((WEIGHT > 1) ? $clog2(WEIGHT) : 1)
) (
    input  logic               i_clk,
    input  logic               i_rst_n,
    input  logic               i_start,
    input  logic [       31:0] i_runtime_r_bits,
    input  logic [       31:0] i_runtime_weight,
    input  logic               i_h_valid,
    input  logic [  ROW_W-1:0] i_h_index,
    output logic               o_h_ready,
    output logic               o_h_we,
    output logic [BLOCK_W-1:0] o_h_block_idx,
    output logic [ DIAG_W-1:0] o_h_diag_idx_local,
    output logic [  ROW_W-1:0] o_h_base_row_idx,
    input  logic               i_h_loaded,
    input  logic               i_h_error,
    input  logic               i_syndrome_valid,
    input  logic [ WORD_W-1:0] i_syndrome_data,
    output logic               o_syndrome_ready,
    output logic               o_syndrome_we,
    output logic [  ROW_W-1:0] o_syndrome_addr,
    output logic               o_syndrome_wdata,
    output logic               o_decoder_start,
    input  logic               i_decoder_done,
    output logic               o_error,
    output logic               o_busy,
    output logic               o_done
);

  localparam int BIT_W = (WORD_W > 1) ? $clog2(WORD_W) : 1;

  typedef enum logic [2:0] {
    ST_IDLE,
    ST_H_LOAD,
    ST_H_WAIT,
    ST_SYNDROME_WORD,
    ST_SYNDROME_BITS,
    ST_DECODER_START,
    ST_DECODER_WAIT
  } state_t;

  state_t               state_q;
  logic   [  BIT_W-1:0] syndrome_bit_q;
  logic   [  ROW_W-1:0] syndrome_addr_q;
  logic   [ WORD_W-1:0] syndrome_data_q;
  logic                 last_syndrome_bit_c;
  logic                 sorter_input_ready;
  logic                 sorter_output_valid;
  logic   [BLOCK_W-1:0] sorter_block_idx;
  logic   [ DIAG_W-1:0] sorter_diag_idx;
  logic   [  ROW_W-1:0] sorter_index;
  logic                 sorter_busy;
  logic                 sorter_done;
  integer               active_r_bits_q;

  assign o_h_ready = (state_q == ST_H_LOAD) && sorter_input_ready;
  assign o_h_we = (state_q == ST_H_LOAD) && sorter_output_valid;
  assign o_h_block_idx = sorter_block_idx;
  assign o_h_diag_idx_local = sorter_diag_idx;
  assign o_h_base_row_idx = sorter_index;

  assign o_syndrome_ready = (state_q == ST_SYNDROME_WORD);
  assign o_syndrome_we = (state_q == ST_SYNDROME_BITS);
  assign o_syndrome_addr = syndrome_addr_q;
  assign o_syndrome_wdata = syndrome_data_q[syndrome_bit_q];
  assign o_decoder_start = (state_q == ST_DECODER_START);
  assign o_busy = (state_q != ST_IDLE) || sorter_busy;

  trike_fixed_support_sorter #(
      .R_BITS(R_BITS),
      .BLOCKS(BLOCKS),
      .WEIGHT(WEIGHT),
      .RUNTIME_GEOMETRY(RUNTIME_GEOMETRY)
  ) support_sorter (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         ((state_q == ST_IDLE) && i_start),
      .i_runtime_r_bits(i_runtime_r_bits),
      .i_runtime_weight(i_runtime_weight),
      .i_valid         (i_h_valid),
      .i_index         (i_h_index),
      .o_ready         (sorter_input_ready),
      .o_valid         (sorter_output_valid),
      .o_block_idx     (sorter_block_idx),
      .o_diag_idx      (sorter_diag_idx),
      .o_index         (sorter_index),
      .i_ready         (state_q == ST_H_LOAD),
      .o_busy          (sorter_busy),
      .o_done          (sorter_done)
  );

  always_comb begin
    last_syndrome_bit_c = (syndrome_addr_q == ROW_W'(active_r_bits_q - 1));
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      syndrome_bit_q <= '0;
      syndrome_addr_q <= '0;
      syndrome_data_q <= '0;
      active_r_bits_q <= R_BITS;
      o_error <= 1'b0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            syndrome_bit_q <= '0;
            syndrome_addr_q <= '0;
            o_error <= 1'b0;
            if (RUNTIME_GEOMETRY) active_r_bits_q <= int'(i_runtime_r_bits);
            else active_r_bits_q <= R_BITS;
            state_q <= ST_H_LOAD;
          end
        end

        ST_H_LOAD: begin
          if (sorter_done) state_q <= ST_H_WAIT;
        end

        ST_H_WAIT: begin
          if (i_h_error) begin
            o_error <= 1'b1;
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end else if (i_h_loaded) begin
            state_q <= ST_SYNDROME_WORD;
          end
        end

        ST_SYNDROME_WORD: begin
          if (i_syndrome_valid) begin
            syndrome_data_q <= i_syndrome_data;
            syndrome_bit_q <= '0;
            state_q <= ST_SYNDROME_BITS;
          end
        end

        ST_SYNDROME_BITS: begin
          if (last_syndrome_bit_c) begin
            state_q <= ST_DECODER_START;
          end else begin
            syndrome_addr_q <= syndrome_addr_q + 1'b1;
            if (syndrome_bit_q == BIT_W'(WORD_W - 1)) begin
              syndrome_bit_q <= '0;
              state_q <= ST_SYNDROME_WORD;
            end else begin
              syndrome_bit_q <= syndrome_bit_q + 1'b1;
            end
          end
        end

        ST_DECODER_START: state_q <= ST_DECODER_WAIT;

        ST_DECODER_WAIT: begin
          if (i_decoder_done) begin
            o_done  <= 1'b1;
            state_q <= ST_IDLE;
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (R_BITS <= 0) $fatal(1, "trike_decoder_load_adapter requires R_BITS > 0");
    if ((BLOCKS <= 0) || (WEIGHT <= 0))
      $fatal(1, "trike_decoder_load_adapter requires positive H geometry");
  end
`endif

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS))
        $fatal(1, "trike_decoder_load_adapter runtime r out of range");
      if ((i_runtime_weight < 1) || (i_runtime_weight > WEIGHT))
        $fatal(1, "trike_decoder_load_adapter runtime weight out of range");
    end
  end
`endif

endmodule
