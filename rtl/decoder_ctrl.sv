// Decoder control FSM for column scheduling, phase transitions, and bank swaps.
module decoder_ctrl
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_start,                                        // Starts a new decode pass.
  input  logic i_slot_last,                                    // Marks the last active slot in the current phase.
  input  logic i_finish_decode,                                // Requests transition to DONE after the check phase.
  input  logic i_decode_success,                               // Indicates whether the residual syndrome is zero.
  output logic [DEC_STATE_W-1:0] o_state,                      // Current decoder FSM state.
  output logic [VAR_W-1:0] o_c2v_var_idx,                      // Variable index for the active c2v scan.
  output logic [VAR_W-1:0] o_v2c_var_idx,                      // Variable index for the active v2c emission.
  output logic [EDGE_W-1:0] o_col_slot_idx,                    // Slot index within the current lane-packed column.
  output logic o_comp_c2v_read_bank,                          // RAM M bank selected for compressed-c2v reads.
  output logic o_comp_c2v_write_bank,                         // RAM M bank selected for compressed-c2v writes.
  output logic o_c2v_edge_list_buf_sel,                        // Edge-list buffer being filled by the c2v phase.
  output logic o_v2c_edge_list_buf_sel,                        // Edge-list buffer being drained by the v2c phase.
  output logic o_done,                                         // Decode completion flag.
  output logic o_success,                                      // Decode success flag.
  output logic [$clog2(I_MAX + 1)-1:0] o_iter_count            // Completed iteration count.
);

  timeunit 1ns;
  timeprecision 1ps;

  localparam logic [VAR_W-1:0] LAST_VAR = VAR_W'(N - 1);
  localparam int ITER_W = $clog2(I_MAX + 1);

  logic [ITER_W-1:0] next_iter_count;

  assign next_iter_count = o_iter_count + 1'b1;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_state <= DEC_WAIT_START;
      o_done <= 1'b0;
      o_success <= 1'b0;
      o_iter_count <= '0;
      o_c2v_var_idx <= '0;
      o_v2c_var_idx <= '0;
      o_col_slot_idx <= '0;
      o_comp_c2v_read_bank <= 1'b0;
      o_comp_c2v_write_bank <= 1'b1;
      o_c2v_edge_list_buf_sel <= 1'b0;
      o_v2c_edge_list_buf_sel <= 1'b0;
    end else begin
      case (o_state)
        DEC_WAIT_START: begin
          o_done <= 1'b0;
          o_success <= 1'b0;
          if (i_start) begin
            o_state <= DEC_INIT_DECODER;
          end
        end

        DEC_INIT_DECODER: begin
          o_done <= 1'b0;
          o_success <= 1'b0;
          o_iter_count <= '0;
          o_c2v_var_idx <= '0;
          o_v2c_var_idx <= '0;
          o_col_slot_idx <= '0;
          o_comp_c2v_read_bank <= 1'b0;
          o_comp_c2v_write_bank <= 1'b1;
          o_c2v_edge_list_buf_sel <= 1'b0;
          o_v2c_edge_list_buf_sel <= 1'b0;
          o_state <= DEC_INIT_ROW_ACCUM;
        end

        DEC_INIT_ROW_ACCUM: begin
          if (i_slot_last) begin
            o_col_slot_idx <= '0;
            if (o_c2v_var_idx == LAST_VAR) begin
              o_c2v_var_idx <= '0;
              o_state <= DEC_INIT_ROW_FLUSH;
            end else begin
              o_c2v_var_idx <= o_c2v_var_idx + 1'b1;
            end
          end else begin
            o_col_slot_idx <= o_col_slot_idx + 1'b1;
          end
        end

        DEC_INIT_ROW_FLUSH: begin
          o_c2v_var_idx <= '0;
          o_v2c_var_idx <= '0;
          o_col_slot_idx <= '0;
          o_c2v_edge_list_buf_sel <= 1'b0;
          o_v2c_edge_list_buf_sel <= 1'b0;
          o_state <= DEC_ITER_C2V_PRIME;
        end

        DEC_ITER_C2V_PRIME: begin
          if (i_slot_last) begin
            o_col_slot_idx <= '0;
            o_v2c_var_idx <= o_c2v_var_idx;
            o_v2c_edge_list_buf_sel <= o_c2v_edge_list_buf_sel;
            o_c2v_edge_list_buf_sel <= ~o_c2v_edge_list_buf_sel;
            if (o_c2v_var_idx == LAST_VAR) begin
              o_c2v_var_idx <= '0;
              o_state <= DEC_ITER_V2C_DRAIN;
            end else begin
              o_c2v_var_idx <= o_c2v_var_idx + 1'b1;
              o_state <= DEC_ITER_OVERLAP;
            end
          end else begin
            o_col_slot_idx <= o_col_slot_idx + 1'b1;
          end
        end

        DEC_ITER_OVERLAP: begin
          if (i_slot_last) begin
            o_col_slot_idx <= '0;
            o_v2c_var_idx <= o_c2v_var_idx;
            o_v2c_edge_list_buf_sel <= o_c2v_edge_list_buf_sel;
            o_c2v_edge_list_buf_sel <= ~o_c2v_edge_list_buf_sel;
            if (o_c2v_var_idx == LAST_VAR) begin
              o_c2v_var_idx <= '0;
              o_state <= DEC_ITER_V2C_DRAIN;
            end else begin
              o_c2v_var_idx <= o_c2v_var_idx + 1'b1;
            end
          end else begin
            o_col_slot_idx <= o_col_slot_idx + 1'b1;
          end
        end

        DEC_ITER_V2C_DRAIN: begin
          if (i_slot_last) begin
            o_col_slot_idx <= '0;
            o_state <= DEC_ITER_WRITE_FLUSH;
          end else begin
            o_col_slot_idx <= o_col_slot_idx + 1'b1;
          end
        end

        DEC_ITER_WRITE_FLUSH: begin
          o_state <= DEC_ITER_CHECK;
        end

        DEC_ITER_CHECK: begin
          o_iter_count <= next_iter_count;
          if (i_finish_decode) begin
            o_done <= 1'b1;
            o_success <= i_decode_success;
            o_state <= DEC_DONE;
          end else begin
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_col_slot_idx <= '0;
            o_comp_c2v_read_bank <= o_comp_c2v_write_bank;
            o_comp_c2v_write_bank <= o_comp_c2v_read_bank;
            o_c2v_edge_list_buf_sel <= 1'b0;
            o_v2c_edge_list_buf_sel <= 1'b0;
            o_state <= DEC_ITER_C2V_PRIME;
          end
        end

        DEC_DONE: begin
          o_done <= 1'b1;
        end

        default: begin
          o_state <= DEC_WAIT_START;
        end
      endcase
    end
  end
endmodule
