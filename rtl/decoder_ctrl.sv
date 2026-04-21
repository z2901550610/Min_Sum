// Decoder control FSM for Fig.8-style column-overlap scheduling with
// single-port RAM accesses.
module decoder_ctrl
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_start,                                        // Starts a new decode pass.
  input  logic i_finish_decode,                                // Requests transition to DONE after the check phase.
  input  logic i_decode_success,                               // Indicates whether the residual syndrome is zero.
  input  logic i_c2v_column_slot_last,                         // Producer side: current slot is the last valid entry.
  input  logic i_v2c_column_slot_last,                         // Consumer side: current slot is the last valid entry.
  output logic [DEC_STATE_W-1:0] o_state,                      // Coarse decoder state for debug/observation.
  output logic [DEC_PHASE_W-1:0] o_phase,                      // Current pipeline micro-stage.
  output logic [VAR_W-1:0] o_work_var,                         // Debug-selected active column.
  output logic [EDGE_W-1:0] o_work_edge_slot,                  // Debug-selected active packed slot.
  output logic [VAR_W-1:0] o_c2v_var_idx,                      // Producer column used by the c2v phase.
  output logic [VAR_W-1:0] o_v2c_var_idx,                      // Consumer column used by the v2c phase.
  output logic [EDGE_W-1:0] o_c2v_slot_idx,                    // Producer packed slot index.
  output logic [EDGE_W-1:0] o_v2c_slot_idx,                    // Consumer packed slot index.
  output logic [EDGE_W-1:0] o_col_slot_idx,                    // Debug-selected slot index.
  output logic o_active_m_pair,                                // Current RAM-M read pair.
  output logic o_next_m_pair,                                  // Current RAM-M write pair.
  output logic o_comp_c2v_read_bank,                           // RAM-M pair selected for compressed-c2v reads.
  output logic o_comp_c2v_write_bank,                          // RAM-M pair selected for compressed-c2v writes.
  output logic o_seed_active,                                  // Loads static first-column RAM-I metadata.
  output logic [BANK_W-1:0] o_seed_circ_idx,                   // Which circulant block's first-column RAM-I list is seeded.
  output logic o_init_clear,                                   // Clears/init RAMs for a new decode.
  output logic o_clear_next_m,                                 // Clears the next RAM-M pair before overlap starts.
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
  localparam logic HAS_MULTIPLE_COLS = (N > 1);

  logic [ITER_W-1:0] next_iter_count;
  logic prod_valid;

  function automatic logic [VAR_W-1:0] next_var(
    input logic [VAR_W-1:0] var_idx
  );
    begin
      next_var = var_idx + VAR_W'(1);
    end
  endfunction

  assign next_iter_count = o_iter_count + 1'b1;
  assign o_next_m_pair = ~o_active_m_pair;
  assign o_comp_c2v_read_bank = o_active_m_pair;
  assign o_comp_c2v_write_bank = o_next_m_pair;

  assign o_init_clear = (o_phase == DEC_PH_INIT_CLEAR);
  assign o_clear_next_m = (o_phase == DEC_PH_CLEAR_NEXT_M);
  assign o_init_m_read = (o_phase == DEC_PH_INIT_M_READ);
  assign o_init_cnu_a = (o_phase == DEC_PH_INIT_CNU_A);
  assign o_init_m_write = (o_phase == DEC_PH_INIT_M_WRITE);

  assign o_c2v_read =
    (o_phase == DEC_PH_PRIME_READ) ||
    (o_phase == DEC_PH_OVERLAP_ACCUM_READ) ||
    ((o_phase == DEC_PH_OVERLAP_EMIT_READ) && prod_valid) ||
    (o_phase == DEC_PH_PROD_FINISH_READ);

  assign o_c2v_write_t =
    (o_phase == DEC_PH_PRIME_WRITE) ||
    (o_phase == DEC_PH_OVERLAP_ACCUM_USE && prod_valid) ||
    (o_phase == DEC_PH_OVERLAP_EMIT_CNU_A && prod_valid) ||
    (o_phase == DEC_PH_PROD_FINISH_WRITE);

  assign o_vnu_read_t =
    (o_phase == DEC_PH_OVERLAP_ACCUM_READ) ||
    (o_phase == DEC_PH_DRAIN_ACCUM_READ);

  assign o_vnu_accum_t =
    (o_phase == DEC_PH_OVERLAP_ACCUM_USE) ||
    (o_phase == DEC_PH_DRAIN_ACCUM_USE);

  assign o_vnu_prep_write =
    (o_phase == DEC_PH_OVERLAP_PREP) ||
    (o_phase == DEC_PH_DRAIN_PREP);

  assign o_vnu_read_next_m =
    (o_phase == DEC_PH_OVERLAP_EMIT_READ) ||
    (o_phase == DEC_PH_DRAIN_EMIT_READ);

  assign o_vnu_cnu_a =
    (o_phase == DEC_PH_OVERLAP_EMIT_CNU_A) ||
    (o_phase == DEC_PH_DRAIN_EMIT_CNU_A);

  assign o_vnu_write_next =
    (o_phase == DEC_PH_OVERLAP_EMIT_WRITE) ||
    (o_phase == DEC_PH_DRAIN_EMIT_WRITE);

  assign o_iter_check = (o_phase == DEC_PH_ITER_CHECK);

  assign o_c2v_pipe_valid = o_c2v_read || o_c2v_write_t;
  assign o_v2c_pipe_valid =
    o_vnu_read_t || o_vnu_accum_t || o_vnu_prep_write ||
    o_vnu_read_next_m || o_vnu_cnu_a || o_vnu_write_next;

  assign o_work_var = o_v2c_pipe_valid ? o_v2c_var_idx : o_c2v_var_idx;
  assign o_work_edge_slot = o_v2c_pipe_valid ? o_v2c_slot_idx : o_c2v_slot_idx;
  assign o_col_slot_idx = o_work_edge_slot;

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      o_state <= DEC_WAIT_START;
      o_phase <= DEC_PH_WAIT;
      o_c2v_var_idx <= '0;
      o_v2c_var_idx <= '0;
      o_c2v_slot_idx <= '0;
      o_v2c_slot_idx <= '0;
      o_active_m_pair <= 1'b0;
      o_seed_active <= 1'b0;
      o_seed_circ_idx <= '0;
      prod_valid <= 1'b0;
      o_c2v_v2c_overlap_seen <= 1'b0;
      o_done <= 1'b0;
      o_success <= 1'b0;
      o_iter_count <= '0;
    end else begin
      case (o_phase)
        DEC_PH_WAIT: begin
          o_state <= DEC_WAIT_START;
          o_done <= 1'b0;
          o_success <= 1'b0;
          if (i_start) begin
            o_phase <= DEC_PH_SEED_I;
            o_seed_active <= 1'b1;
            o_seed_circ_idx <= '0;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_slot_idx <= '0;
            o_active_m_pair <= 1'b0;
            prod_valid <= 1'b0;
            o_c2v_v2c_overlap_seen <= 1'b0;
            o_iter_count <= '0;
          end
        end

        DEC_PH_SEED_I: begin
          o_state <= DEC_INIT_DECODER;
          if (o_seed_circ_idx == BANK_W'(N0 - 1)) begin
            o_seed_active <= 1'b0;
            o_phase <= DEC_PH_INIT_CLEAR;
          end else begin
            o_seed_circ_idx <= o_seed_circ_idx + BANK_W'(1);
          end
        end

        DEC_PH_INIT_CLEAR: begin
          o_state <= DEC_INIT_DECODER;
          o_c2v_var_idx <= '0;
          o_c2v_slot_idx <= '0;
          o_v2c_var_idx <= '0;
          o_v2c_slot_idx <= '0;
          prod_valid <= 1'b0;
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
          if (i_c2v_column_slot_last) begin
            o_c2v_slot_idx <= '0;
            if (o_c2v_var_idx == LAST_VAR) begin
              o_c2v_var_idx <= '0;
              o_v2c_var_idx <= '0;
              o_v2c_slot_idx <= '0;
              o_phase <= DEC_PH_CLEAR_NEXT_M;
            end else begin
              o_c2v_var_idx <= next_var(o_c2v_var_idx);
              o_phase <= DEC_PH_INIT_M_READ;
            end
          end else begin
            o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
            o_phase <= DEC_PH_INIT_M_READ;
          end
        end

        DEC_PH_CLEAR_NEXT_M: begin
          o_state <= DEC_ITER_C2V_PRIME;
          o_c2v_var_idx <= '0;
          o_c2v_slot_idx <= '0;
          o_v2c_var_idx <= '0;
          o_v2c_slot_idx <= '0;
          prod_valid <= 1'b0;
          o_phase <= DEC_PH_PRIME_READ;
        end

        DEC_PH_PRIME_READ: begin
          o_state <= DEC_ITER_C2V_PRIME;
          o_phase <= DEC_PH_PRIME_WRITE;
        end

        DEC_PH_PRIME_WRITE: begin
          o_state <= DEC_ITER_C2V_PRIME;
          if (i_c2v_column_slot_last) begin
            o_c2v_slot_idx <= '0;
            o_v2c_var_idx <= o_c2v_var_idx;
            o_v2c_slot_idx <= '0;
            if (o_c2v_var_idx == LAST_VAR) begin
              prod_valid <= 1'b0;
              o_phase <= DEC_PH_DRAIN_ACCUM_READ;
            end else begin
              o_c2v_var_idx <= next_var(o_c2v_var_idx);
              prod_valid <= HAS_MULTIPLE_COLS;
              o_c2v_v2c_overlap_seen <= HAS_MULTIPLE_COLS;
              o_phase <= DEC_PH_OVERLAP_ACCUM_READ;
            end
          end else begin
            o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
            o_phase <= DEC_PH_PRIME_READ;
          end
        end

        DEC_PH_OVERLAP_ACCUM_READ: begin
          o_state <= DEC_ITER_OVERLAP;
          o_phase <= DEC_PH_OVERLAP_ACCUM_USE;
        end

        DEC_PH_OVERLAP_ACCUM_USE: begin
          o_state <= DEC_ITER_OVERLAP;
          if (prod_valid) begin
            if (i_c2v_column_slot_last) begin
              o_c2v_slot_idx <= '0;
              prod_valid <= 1'b0;
            end else begin
              o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
            end
          end

          if (i_v2c_column_slot_last) begin
            o_v2c_slot_idx <= '0;
            o_phase <= DEC_PH_OVERLAP_PREP;
          end else begin
            o_v2c_slot_idx <= o_v2c_slot_idx + EDGE_W'(1);
            o_phase <= DEC_PH_OVERLAP_ACCUM_READ;
          end
        end

        DEC_PH_OVERLAP_PREP: begin
          o_state <= DEC_ITER_OVERLAP;
          o_phase <= DEC_PH_OVERLAP_EMIT_READ;
        end

        DEC_PH_OVERLAP_EMIT_READ: begin
          o_state <= DEC_ITER_OVERLAP;
          o_phase <= DEC_PH_OVERLAP_EMIT_CNU_A;
        end

        DEC_PH_OVERLAP_EMIT_CNU_A: begin
          o_state <= DEC_ITER_OVERLAP;
          if (prod_valid) begin
            if (i_c2v_column_slot_last) begin
              o_c2v_slot_idx <= '0;
              prod_valid <= 1'b0;
            end else begin
              o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
            end
          end
          o_phase <= DEC_PH_OVERLAP_EMIT_WRITE;
        end

        DEC_PH_OVERLAP_EMIT_WRITE: begin
          logic [VAR_W-1:0] next_consumer_var;
          next_consumer_var = next_var(o_v2c_var_idx);

          o_state <= DEC_ITER_OVERLAP;
          if (i_v2c_column_slot_last) begin
            o_v2c_slot_idx <= '0;
            if (prod_valid) begin
              o_phase <= DEC_PH_PROD_FINISH_READ;
            end else begin
              o_v2c_var_idx <= next_consumer_var;
              if (next_consumer_var == LAST_VAR) begin
                o_phase <= DEC_PH_DRAIN_ACCUM_READ;
              end else begin
                o_c2v_var_idx <= next_var(next_consumer_var);
                o_c2v_slot_idx <= '0;
                prod_valid <= 1'b1;
                o_phase <= DEC_PH_OVERLAP_ACCUM_READ;
              end
            end
          end else begin
            o_v2c_slot_idx <= o_v2c_slot_idx + EDGE_W'(1);
            o_phase <= DEC_PH_OVERLAP_EMIT_READ;
          end
        end

        DEC_PH_PROD_FINISH_READ: begin
          o_state <= DEC_ITER_OVERLAP;
          o_phase <= DEC_PH_PROD_FINISH_WRITE;
        end

        DEC_PH_PROD_FINISH_WRITE: begin
          logic [VAR_W-1:0] next_consumer_var;
          next_consumer_var = next_var(o_v2c_var_idx);

          o_state <= DEC_ITER_OVERLAP;
          if (i_c2v_column_slot_last) begin
            o_c2v_slot_idx <= '0;
            prod_valid <= 1'b0;
            o_v2c_var_idx <= next_consumer_var;
            o_v2c_slot_idx <= '0;
            if (next_consumer_var == LAST_VAR) begin
              o_phase <= DEC_PH_DRAIN_ACCUM_READ;
            end else begin
              o_c2v_var_idx <= next_var(next_consumer_var);
              o_c2v_slot_idx <= '0;
              prod_valid <= 1'b1;
              o_phase <= DEC_PH_OVERLAP_ACCUM_READ;
            end
          end else begin
            o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
            o_phase <= DEC_PH_PROD_FINISH_READ;
          end
        end

        DEC_PH_DRAIN_ACCUM_READ: begin
          o_state <= DEC_ITER_V2C_DRAIN;
          o_phase <= DEC_PH_DRAIN_ACCUM_USE;
        end

        DEC_PH_DRAIN_ACCUM_USE: begin
          o_state <= DEC_ITER_V2C_DRAIN;
          if (i_v2c_column_slot_last) begin
            o_v2c_slot_idx <= '0;
            o_phase <= DEC_PH_DRAIN_PREP;
          end else begin
            o_v2c_slot_idx <= o_v2c_slot_idx + EDGE_W'(1);
            o_phase <= DEC_PH_DRAIN_ACCUM_READ;
          end
        end

        DEC_PH_DRAIN_PREP: begin
          o_state <= DEC_ITER_V2C_DRAIN;
          o_phase <= DEC_PH_DRAIN_EMIT_READ;
        end

        DEC_PH_DRAIN_EMIT_READ: begin
          o_state <= DEC_ITER_V2C_DRAIN;
          o_phase <= DEC_PH_DRAIN_EMIT_CNU_A;
        end

        DEC_PH_DRAIN_EMIT_CNU_A: begin
          o_state <= DEC_ITER_V2C_DRAIN;
          o_phase <= DEC_PH_DRAIN_EMIT_WRITE;
        end

        DEC_PH_DRAIN_EMIT_WRITE: begin
          o_state <= DEC_ITER_V2C_DRAIN;
          if (i_v2c_column_slot_last) begin
            o_v2c_slot_idx <= '0;
            o_phase <= DEC_PH_ITER_CHECK;
          end else begin
            o_v2c_slot_idx <= o_v2c_slot_idx + EDGE_W'(1);
            o_phase <= DEC_PH_DRAIN_EMIT_READ;
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
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_slot_idx <= '0;
            prod_valid <= 1'b0;
            o_phase <= DEC_PH_CLEAR_NEXT_M;
          end
        end

        DEC_PH_DONE: begin
          o_state <= DEC_DONE;
          o_done <= 1'b1;
          if (i_start) begin
            o_phase <= DEC_PH_SEED_I;
            o_seed_active <= 1'b1;
            o_seed_circ_idx <= '0;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_slot_idx <= '0;
            o_active_m_pair <= 1'b0;
            prod_valid <= 1'b0;
            o_c2v_v2c_overlap_seen <= 1'b0;
            o_done <= 1'b0;
            o_success <= 1'b0;
            o_iter_count <= '0;
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
