`timescale 1ns / 1ps

// Public-operation dispatcher for a single-issue TRIKE KEM engine.
// The selected operation is fixed from acceptance through completion.
module trike_kem_operation_control (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_start,
    input  logic [1:0] i_operation,
    input  logic       i_keygen_done,
    input  logic       i_encaps_done,
    input  logic       i_decaps_done,
    output logic       o_keygen_start,
    output logic       o_encaps_start,
    output logic       o_decaps_start,
    output logic [1:0] o_active_operation,
    output logic       o_busy,
    output logic       o_done,
    output logic       o_error
);

  localparam logic [1:0] OP_KEYGEN = 2'd0;
  localparam logic [1:0] OP_ENCAPS = 2'd1;
  localparam logic [1:0] OP_DECAPS = 2'd2;

  logic [1:0] active_operation_q;
  logic       busy_q;
  logic       decaps_consumed_q;

  assign o_active_operation = active_operation_q;
  assign o_busy = busy_q;

  always_comb begin
    o_keygen_start = 1'b0;
    o_encaps_start = 1'b0;
    o_decaps_start = 1'b0;
    if (i_start && !busy_q) begin
      case (i_operation)
        OP_KEYGEN: o_keygen_start = 1'b1;
        OP_ENCAPS: o_encaps_start = 1'b1;
        OP_DECAPS: o_decaps_start = 1'b1;
        default:   ;
      endcase
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      active_operation_q <= OP_KEYGEN;
      busy_q <= 1'b0;
      decaps_consumed_q <= 1'b0;
      o_done <= 1'b0;
      o_error <= 1'b0;
    end else begin
      o_done  <= 1'b0;
      o_error <= 1'b0;

      if (!busy_q && i_start) begin
        if ((i_operation == OP_DECAPS) && decaps_consumed_q) begin
          o_done  <= 1'b1;
          o_error <= 1'b1;
        end else if (i_operation <= OP_DECAPS) begin
          active_operation_q <= i_operation;
          busy_q <= 1'b1;
        end else begin
          o_done  <= 1'b1;
          o_error <= 1'b1;
        end
      end else if (busy_q) begin
        case (active_operation_q)
          OP_KEYGEN: begin
            if (i_keygen_done) begin
              busy_q <= 1'b0;
              o_done <= 1'b1;
            end
          end
          OP_ENCAPS: begin
            if (i_encaps_done) begin
              busy_q <= 1'b0;
              o_done <= 1'b1;
            end
          end
          OP_DECAPS: begin
            if (i_decaps_done) begin
              busy_q <= 1'b0;
              decaps_consumed_q <= 1'b1;
              o_done <= 1'b1;
            end
          end
          default: begin
            busy_q  <= 1'b0;
            o_done  <= 1'b1;
            o_error <= 1'b1;
          end
        endcase
      end
    end
  end

endmodule
