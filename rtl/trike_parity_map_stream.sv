`timescale 1ns / 1ps

// Fixed-length parity mapping for the TRIKE H1/H2/H3 vectors.
//
// Bytes use the Reference C little-endian polynomial layout. The coefficient
// at R-1 is replaced so that the parity of coefficients [0, R-1] equals
// i_target_parity. Padding bits above coefficient R-1 are cleared.
module trike_parity_map_stream #(
    parameter int R = 15581
) (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_start,
    input  logic       i_target_parity,
    input  logic       i_input_valid,
    input  logic [7:0] i_input_data,
    output logic       o_input_ready,
    output logic       o_output_valid,
    output logic [7:0] o_output_data,
    input  logic       i_output_ready,
    output logic       o_busy,
    output logic       o_done
);

  localparam int R_BYTES = (R + 7) / 8;
  localparam int BYTE_IDX_W = (R_BYTES > 1) ? $clog2(R_BYTES) : 1;
  localparam int PARITY_BIT_IDX = (R - 1) & 7;
  localparam logic [7:0] LAST_LOW_MASK = 8'((9'b000000001 << PARITY_BIT_IDX) - 1'b1);
  localparam logic [BYTE_IDX_W-1:0] LAST_BYTE_IDX = BYTE_IDX_W'(R_BYTES - 1);

  typedef enum logic [1:0] {
    ST_IDLE,
    ST_LOAD,
    ST_READ_FIRST,
    ST_OUTPUT
  } state_t;

  state_t                  state_q;

  (* ram_style = "block" *) logic   [           7:0] vector_mem[0:R_BYTES-1];

  logic   [BYTE_IDX_W-1:0] input_byte_idx_q;
  logic   [BYTE_IDX_W-1:0] output_byte_idx_q;
  logic                    parity_q;
  logic                    target_parity_q;
  logic   [           7:0] output_data_q;

  logic   [           7:0] sanitized_last_byte;
  logic                    final_parity_bit;
  logic   [           7:0] corrected_last_byte;

  always_comb begin
    sanitized_last_byte = i_input_data & LAST_LOW_MASK;
    final_parity_bit = target_parity_q ^ parity_q ^ (^sanitized_last_byte);
    corrected_last_byte = sanitized_last_byte;
    corrected_last_byte[PARITY_BIT_IDX] = final_parity_bit;
  end

  assign o_input_ready = (state_q == ST_LOAD);
  assign o_output_valid = (state_q == ST_OUTPUT);
  assign o_output_data = output_data_q;
  assign o_busy = (state_q != ST_IDLE);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q           <= ST_IDLE;
      input_byte_idx_q  <= '0;
      output_byte_idx_q <= '0;
      parity_q          <= 1'b0;
      target_parity_q   <= 1'b0;
      output_data_q     <= '0;
      o_done            <= 1'b0;
    end else begin
      o_done <= 1'b0;

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            input_byte_idx_q <= '0;
            parity_q         <= 1'b0;
            target_parity_q  <= i_target_parity;
            state_q          <= ST_LOAD;
          end
        end

        ST_LOAD: begin
          if (i_input_valid) begin
            if (input_byte_idx_q == LAST_BYTE_IDX) begin
              vector_mem[input_byte_idx_q] <= corrected_last_byte;
              output_byte_idx_q            <= '0;
              state_q                      <= ST_READ_FIRST;
            end else begin
              vector_mem[input_byte_idx_q] <= i_input_data;
              parity_q                     <= parity_q ^ (^i_input_data);
              input_byte_idx_q             <= input_byte_idx_q + 1'b1;
            end
          end
        end

        ST_READ_FIRST: begin
          output_data_q <= vector_mem[0];
          state_q       <= ST_OUTPUT;
        end

        ST_OUTPUT: begin
          if (i_output_ready) begin
            if (output_byte_idx_q == LAST_BYTE_IDX) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              output_byte_idx_q <= output_byte_idx_q + 1'b1;
              output_data_q     <= vector_mem[output_byte_idx_q+1'b1];
            end
          end
        end

        default: begin
          state_q <= ST_IDLE;
        end
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if (R < 1) $error("trike_parity_map_stream R must be at least 1");
  end
`endif

endmodule
