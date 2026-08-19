`timescale 1ns / 1ps

// Sorts each block of sparse support coordinates in ascending order. The
// compare-swap loop executes active_weight*(active_weight-1)/2 cycles per
// block; coordinate values affect only the data muxes. Runtime geometry is a
// public transaction descriptor sampled only with i_start.
module trike_fixed_support_sorter #(
    parameter int R_BITS           = 12589,
    parameter int BLOCKS           = 3,
    parameter int WEIGHT           = 35,
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
    input  logic               i_valid,
    input  logic [  ROW_W-1:0] i_index,
    output logic               o_ready,
    output logic               o_valid,
    output logic [BLOCK_W-1:0] o_block_idx,
    output logic [ DIAG_W-1:0] o_diag_idx,
    output logic [  ROW_W-1:0] o_index,
    input  logic               i_ready,
    output logic               o_busy,
    output logic               o_done
);

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_LOAD,
    ST_SORT,
    ST_OUTPUT
  } state_t;

  state_t               state_q;
  logic   [  ROW_W-1:0] support_q[0:WEIGHT-1];
  logic   [BLOCK_W-1:0] block_q;
  logic   [ DIAG_W-1:0] load_q;
  logic   [ DIAG_W-1:0] pass_q;
  logic   [ DIAG_W-1:0] compare_q;
  logic   [ DIAG_W-1:0] output_q;
  integer               active_r_bits_q;
  integer               active_weight_q;

  assign o_ready = (state_q == ST_LOAD);
  assign o_valid = (state_q == ST_OUTPUT);
  assign o_block_idx = block_q;
  assign o_diag_idx = output_q;
  assign o_index = support_q[output_q];
  assign o_busy = (state_q != ST_IDLE);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      block_q <= '0;
      load_q <= '0;
      pass_q <= '0;
      compare_q <= '0;
      output_q <= '0;
      active_r_bits_q <= R_BITS;
      active_weight_q <= WEIGHT;
      o_done <= 1'b0;
      for (int idx = 0; idx < WEIGHT; idx++) support_q[idx] <= '0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            block_q <= '0;
            load_q  <= '0;
            if (RUNTIME_GEOMETRY) begin
              active_r_bits_q <= int'(i_runtime_r_bits);
              active_weight_q <= int'(i_runtime_weight);
            end else begin
              active_r_bits_q <= R_BITS;
              active_weight_q <= WEIGHT;
            end
            state_q <= ST_LOAD;
          end
        end

        ST_LOAD: begin
          if (i_valid) begin
            support_q[load_q] <= i_index;
            if (load_q == DIAG_W'(active_weight_q - 1)) begin
              load_q <= '0;
              pass_q <= '0;
              compare_q <= '0;
              output_q <= '0;
              if (active_weight_q == 1) state_q <= ST_OUTPUT;
              else state_q <= ST_SORT;
            end else begin
              load_q <= load_q + 1'b1;
            end
          end
        end

        ST_SORT: begin
          if (support_q[compare_q] > support_q[compare_q+1'b1]) begin
            support_q[compare_q] <= support_q[compare_q+1'b1];
            support_q[compare_q+1'b1] <= support_q[compare_q];
          end
          if (compare_q == DIAG_W'(active_weight_q - 2) - pass_q) begin
            compare_q <= '0;
            if (pass_q == DIAG_W'(active_weight_q - 2)) begin
              output_q <= '0;
              state_q  <= ST_OUTPUT;
            end else begin
              pass_q <= pass_q + 1'b1;
            end
          end else begin
            compare_q <= compare_q + 1'b1;
          end
        end

        ST_OUTPUT: begin
          if (i_ready) begin
            if (output_q == DIAG_W'(active_weight_q - 1)) begin
              output_q <= '0;
              if (block_q == BLOCK_W'(BLOCKS - 1)) begin
                o_done  <= 1'b1;
                state_q <= ST_IDLE;
              end else begin
                block_q <= block_q + 1'b1;
                load_q  <= '0;
                state_q <= ST_LOAD;
              end
            end else begin
              output_q <= output_q + 1'b1;
            end
          end
        end

        default: state_q <= ST_IDLE;
      endcase
    end
  end

  initial begin
    if (R_BITS <= 0) $fatal(1, "trike_fixed_support_sorter requires R_BITS > 0");
    if ((BLOCKS <= 0) || (WEIGHT <= 0))
      $fatal(1, "trike_fixed_support_sorter requires positive support geometry");
  end

`ifndef SYNTHESIS
  always_ff @(posedge i_clk) begin
    if (i_rst_n && (state_q == ST_IDLE) && i_start && RUNTIME_GEOMETRY) begin
      if ((i_runtime_r_bits < 1) || (i_runtime_r_bits > R_BITS))
        $fatal(1, "trike_fixed_support_sorter runtime r out of range");
      if ((i_runtime_weight < 1) || (i_runtime_weight > WEIGHT))
        $fatal(1, "trike_fixed_support_sorter runtime weight out of range");
    end
    if (i_rst_n && (state_q == ST_LOAD) && i_valid && (int'(i_index) >= active_r_bits_q))
      $fatal(1, "trike_fixed_support_sorter support index out of range");
  end
`endif

endmodule
