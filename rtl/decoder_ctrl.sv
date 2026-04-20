// Decoder control FSM for micro-staged single-port RAM scheduling.
module decoder_ctrl
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_start,                                        // Starts a new decode pass.
  input  logic i_finish_decode,                                // Requests transition to DONE after the check phase.
  input  logic i_decode_success,                               // Indicates whether the residual syndrome is zero.
  output logic [DEC_STATE_W-1:0] o_state,                      // Coarse decoder state for debug/observation.
  output logic [DEC_PHASE_W-1:0] o_phase,                      // Current single-port RAM micro-stage.
  output logic [VAR_W-1:0] o_work_var,                         // Variable index for the active micro-stage.
  output logic [EDGE_W-1:0] o_work_edge,                       // Edge index for the active micro-stage.
  output logic [VAR_W-1:0] o_c2v_var_idx,                      // Alias for the active c2v variable.
  output logic [VAR_W-1:0] o_v2c_var_idx,                      // Alias for the active v2c variable.
  output logic [EDGE_W-1:0] o_col_slot_idx,                    // Alias for the active edge slot.
  output logic o_active_m_pair,                                // Current RAM-M read pair.
  output logic o_next_m_pair,                                  // Current RAM-M write pair.
  output logic o_comp_c2v_read_bank,                           // RAM-M pair selected for compressed-c2v reads.
  output logic o_comp_c2v_write_bank,                          // RAM-M pair selected for compressed-c2v writes.
  output logic o_seed_active,                                  // Loads static first-column RAM-I metadata.
  output logic [BANK_W-1:0] o_seed_bank,                       // RAM-I bank being seeded.
  output logic o_init_clear,                                   // Clears/init RAMs for a new decode.
  output logic o_clear_next_m,                                 // Clears the next RAM-M pair before accumulation.
  output logic o_init_m_read,                                  // Reads RAM-M/RAM-U for initial CNU_A.
  output logic o_init_cnu_a,                                   // Enables CNU_A for initial accumulation.
  output logic o_init_m_write,                                 // Writes initial CNU_A result.
  output logic o_c2v_read,                                     // Reads RAM-M/RAM-S for CNU_B.
  output logic o_c2v_write_t,                                  // Writes CNU_B/codec result to RAM-T.
  output logic o_vnu_read_t,                                   // Reads RAM-T for VNU accumulation.
  output logic o_vnu_accum_t,                                  // Accumulates one RAM-T value in VNU.
  output logic o_vnu_prep_write,                               // Captures VNU decision.
  output logic o_vnu_read_next_m,                              // Reads next RAM-M pair before CNU_A.
  output logic o_vnu_cnu_a,                                    // Enables CNU_A with VNU-emitted v2c.
  output logic o_vnu_write_next,                               // Writes RAM-U/RAM-M/RAM-S for next iteration.
  output logic o_iter_check,                                   // Iteration completion/check cycle.
  output logic o_c2v_pipe_valid,                               // Debug c2v activity flag.
  output logic o_v2c_pipe_valid,                               // Debug v2c activity flag.
  output logic o_c2v_v2c_overlap_seen,                         // Debug flag for exposed overlap.
  output logic o_done,                                         // Decode completion flag.
  output logic o_success,                                      // Decode success flag.
  output logic [$clog2(I_MAX + 1)-1:0] o_iter_count            // Completed iteration count.
);

  timeunit 1ns;
  timeprecision 1ps;

  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam logic [VAR_W-1:0] LAST_VAR = VAR_W'(N - 1);
  localparam logic [EDGE_W-1:0] LAST_EDGE = EDGE_W'(W - 1);

  logic [ITER_W-1:0] next_iter_count;

  assign next_iter_count = o_iter_count + 1'b1;
  assign o_next_m_pair = ~o_active_m_pair;
  assign o_comp_c2v_read_bank = o_active_m_pair;
  assign o_comp_c2v_write_bank = o_next_m_pair;
  assign o_c2v_var_idx = o_work_var;
  assign o_v2c_var_idx = o_work_var;
  assign o_col_slot_idx = o_work_edge;

  assign o_init_clear = (o_phase == DEC_PH_INIT_CLEAR);
  assign o_clear_next_m = (o_phase == DEC_PH_CLEAR_NEXT_M);
  assign o_init_m_read = (o_phase == DEC_PH_INIT_M_READ);
  assign o_init_cnu_a = (o_phase == DEC_PH_INIT_CNU_A);
  assign o_init_m_write = (o_phase == DEC_PH_INIT_M_WRITE);
  assign o_c2v_read = (o_phase == DEC_PH_C2V_READ);
  assign o_c2v_write_t = (o_phase == DEC_PH_C2V_WRITE_T);
  assign o_vnu_read_t = (o_phase == DEC_PH_VNU_READ_T);
  assign o_vnu_accum_t = (o_phase == DEC_PH_VNU_ACCUM_T);
  assign o_vnu_prep_write = (o_phase == DEC_PH_VNU_PREP_WRITE);
  assign o_vnu_read_next_m = (o_phase == DEC_PH_VNU_READ_NEXT_M);
  assign o_vnu_cnu_a = (o_phase == DEC_PH_VNU_CNU_A);
  assign o_vnu_write_next = (o_phase == DEC_PH_VNU_WRITE_NEXT);
  assign o_iter_check = (o_phase == DEC_PH_ITER_CHECK);

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_state <= DEC_WAIT_START;
      o_phase <= DEC_PH_WAIT;
      o_work_var <= '0;
      o_work_edge <= '0;
      o_active_m_pair <= 1'b0;
      o_seed_active <= 1'b0;
      o_seed_bank <= '0;
      o_c2v_pipe_valid <= 1'b0;
      o_v2c_pipe_valid <= 1'b0;
      o_c2v_v2c_overlap_seen <= 1'b0;
      o_done <= 1'b0;
      o_success <= 1'b0;
      o_iter_count <= '0;
    end else begin
      o_c2v_pipe_valid <= 1'b0;
      o_v2c_pipe_valid <= 1'b0;

      case (o_phase)
        DEC_PH_WAIT: begin
          o_state <= DEC_WAIT_START;
          o_done <= 1'b0;
          o_success <= 1'b0;
          if (i_start) begin
            o_phase <= DEC_PH_SEED_I;
            o_seed_active <= 1'b1;
            o_seed_bank <= '0;
            o_iter_count <= '0;
            o_work_var <= '0;
            o_work_edge <= '0;
            o_active_m_pair <= 1'b0;
            o_c2v_v2c_overlap_seen <= 1'b0;
          end
        end

        DEC_PH_SEED_I: begin
          o_state <= DEC_INIT_DECODER;
          if (o_seed_bank == BANK_W'(N0 - 1)) begin
            o_seed_active <= 1'b0;
            o_phase <= DEC_PH_INIT_CLEAR;
          end else begin
            o_seed_bank <= o_seed_bank + 1'b1;
          end
        end

        DEC_PH_INIT_CLEAR: begin
          o_state <= DEC_INIT_DECODER;
          o_work_var <= '0;
          o_work_edge <= '0;
          o_phase <= DEC_PH_INIT_M_READ;
        end

        DEC_PH_INIT_M_READ: begin
          o_state <= DEC_INIT_ROW_ACCUM;
          o_phase <= DEC_PH_INIT_CNU_A;
        end

        DEC_PH_INIT_CNU_A: begin
          o_state <= DEC_INIT_ROW_ACCUM;
          o_phase <= DEC_PH_INIT_M_WRITE;
        end

        DEC_PH_INIT_M_WRITE: begin
          o_state <= DEC_INIT_ROW_ACCUM;
          if (o_work_edge == LAST_EDGE) begin
            o_work_edge <= '0;
            if (o_work_var == LAST_VAR) begin
              o_work_var <= '0;
              o_phase <= DEC_PH_C2V_READ;
            end else begin
              o_work_var <= o_work_var + 1'b1;
              o_phase <= DEC_PH_INIT_M_READ;
            end
          end else begin
            o_work_edge <= o_work_edge + 1'b1;
            o_phase <= DEC_PH_INIT_M_READ;
          end
        end

        DEC_PH_C2V_READ: begin
          o_state <= DEC_ITER_C2V_PRIME;
          o_c2v_pipe_valid <= 1'b1;
          o_phase <= DEC_PH_C2V_WRITE_T;
        end

        DEC_PH_C2V_WRITE_T: begin
          o_state <= DEC_ITER_C2V_PRIME;
          o_c2v_pipe_valid <= 1'b1;
          if (o_work_edge == LAST_EDGE) begin
            o_work_edge <= '0;
            if (o_work_var == LAST_VAR) begin
              o_work_var <= '0;
              o_phase <= DEC_PH_CLEAR_NEXT_M;
            end else begin
              o_work_var <= o_work_var + 1'b1;
              o_phase <= DEC_PH_C2V_READ;
            end
          end else begin
            o_work_edge <= o_work_edge + 1'b1;
            o_phase <= DEC_PH_C2V_READ;
          end
        end

        DEC_PH_CLEAR_NEXT_M: begin
          o_state <= DEC_ITER_OVERLAP;
          o_c2v_pipe_valid <= 1'b1;
          o_v2c_pipe_valid <= 1'b1;
          o_c2v_v2c_overlap_seen <= 1'b1;
          o_work_var <= '0;
          o_work_edge <= '0;
          o_phase <= DEC_PH_VNU_READ_T;
        end

        DEC_PH_VNU_READ_T: begin
          o_state <= DEC_ITER_OVERLAP;
          o_v2c_pipe_valid <= 1'b1;
          o_phase <= DEC_PH_VNU_ACCUM_T;
        end

        DEC_PH_VNU_ACCUM_T: begin
          o_state <= DEC_ITER_OVERLAP;
          o_v2c_pipe_valid <= 1'b1;
          if (o_work_edge == LAST_EDGE) begin
            o_work_edge <= '0;
            o_phase <= DEC_PH_VNU_PREP_WRITE;
          end else begin
            o_work_edge <= o_work_edge + 1'b1;
            o_phase <= DEC_PH_VNU_READ_T;
          end
        end

        DEC_PH_VNU_PREP_WRITE: begin
          o_state <= DEC_ITER_OVERLAP;
          o_v2c_pipe_valid <= 1'b1;
          o_work_edge <= '0;
          o_phase <= DEC_PH_VNU_READ_NEXT_M;
        end

        DEC_PH_VNU_READ_NEXT_M: begin
          o_state <= DEC_ITER_OVERLAP;
          o_v2c_pipe_valid <= 1'b1;
          o_phase <= DEC_PH_VNU_CNU_A;
        end

        DEC_PH_VNU_CNU_A: begin
          o_state <= DEC_ITER_OVERLAP;
          o_v2c_pipe_valid <= 1'b1;
          o_phase <= DEC_PH_VNU_WRITE_NEXT;
        end

        DEC_PH_VNU_WRITE_NEXT: begin
          o_state <= DEC_ITER_OVERLAP;
          o_v2c_pipe_valid <= 1'b1;
          if (o_work_edge == LAST_EDGE) begin
            o_work_edge <= '0;
            if (o_work_var == LAST_VAR) begin
              o_work_var <= '0;
              o_phase <= DEC_PH_ITER_CHECK;
            end else begin
              o_work_var <= o_work_var + 1'b1;
              o_phase <= DEC_PH_VNU_READ_T;
            end
          end else begin
            o_work_edge <= o_work_edge + 1'b1;
            o_phase <= DEC_PH_VNU_READ_NEXT_M;
          end
        end

        DEC_PH_ITER_CHECK: begin
          o_state <= DEC_ITER_CHECK;
          o_iter_count <= next_iter_count;
          if (i_finish_decode) begin
            o_done <= 1'b1;
            o_success <= i_decode_success;
            o_phase <= DEC_PH_DONE;
          end else begin
            o_active_m_pair <= o_next_m_pair;
            o_work_var <= '0;
            o_work_edge <= '0;
            o_phase <= DEC_PH_C2V_READ;
          end
        end

        DEC_PH_DONE: begin
          o_state <= DEC_DONE;
          o_done <= 1'b1;
          if (i_start) begin
            o_phase <= DEC_PH_SEED_I;
            o_seed_active <= 1'b1;
            o_seed_bank <= '0;
            o_iter_count <= '0;
            o_work_var <= '0;
            o_work_edge <= '0;
            o_active_m_pair <= 1'b0;
            o_c2v_v2c_overlap_seen <= 1'b0;
            o_done <= 1'b0;
            o_success <= 1'b0;
          end
        end

        default: begin
          o_state <= DEC_WAIT_START;
          o_phase <= DEC_PH_WAIT;
        end
      endcase
    end
  end
endmodule
