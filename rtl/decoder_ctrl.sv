// Decoder control for Fig.8-style column-overlap scheduling using a small
// set of macro states plus producer/consumer contexts.
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
  output logic [DEC_PHASE_W-1:0] o_phase,                      // Current debug micro-stage.
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
  output logic o_capture_consumer_col_now,                     // Producer column becomes the current consumer column.
  output logic o_capture_consumer_col_next,                    // Producer column becomes the next buffered consumer column.
  output logic o_promote_consumer_col_next,                    // Buffered next consumer column becomes current.
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

  localparam logic [2:0] CTRL_WAIT = 3'd0;
  localparam logic [2:0] CTRL_SEED = 3'd1;
  localparam logic [2:0] CTRL_INIT = 3'd2;
  localparam logic [2:0] CTRL_ITER = 3'd3;
  localparam logic [2:0] CTRL_DONE = 3'd4;

  localparam logic [1:0] INIT_STEP_READ = 2'd0;
  localparam logic [1:0] INIT_STEP_CNU_A = 2'd1;
  localparam logic [1:0] INIT_STEP_WRITE = 2'd2;

  localparam logic PROD_STEP_READ = 1'b0;
  localparam logic PROD_STEP_WRITE = 1'b1;

  localparam logic CONS_MODE_ACCUM = 1'b0;
  localparam logic CONS_MODE_EMIT = 1'b1;

  localparam logic [2:0] CONS_STEP_READ = 3'd0;
  localparam logic [2:0] CONS_STEP_USE = 3'd1;
  localparam logic [2:0] CONS_STEP_PREP = 3'd2;
  localparam logic [2:0] CONS_STEP_READ_NEXT_M = 3'd3;
  localparam logic [2:0] CONS_STEP_CNU_A = 3'd4;
  localparam logic [2:0] CONS_STEP_WRITE = 3'd5;

  logic [2:0] ctrl_state;
  logic init_clear_pending;
  logic [1:0] init_step;
  logic clear_next_m_pending;
  logic iter_check_pending;
  logic producer_active;
  logic producer_step;
  logic consumer_active;
  logic consumer_mode;
  logic [2:0] consumer_step;
  logic [ITER_W-1:0] next_iter_count;
  logic producer_is_prime;
  logic consumer_is_drain;
  logic producer_write_last;
  logic consumer_emit_write_last;

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
  assign o_seed_active = (ctrl_state == CTRL_SEED);

  assign o_init_clear = (ctrl_state == CTRL_INIT) && init_clear_pending;
  assign o_clear_next_m = (ctrl_state == CTRL_ITER) && clear_next_m_pending;
  assign o_init_m_read = (ctrl_state == CTRL_INIT) && !init_clear_pending && (init_step == INIT_STEP_READ);
  assign o_init_cnu_a = (ctrl_state == CTRL_INIT) && !init_clear_pending && (init_step == INIT_STEP_CNU_A);
  assign o_init_m_write = (ctrl_state == CTRL_INIT) && !init_clear_pending && (init_step == INIT_STEP_WRITE);

  assign o_c2v_read = (ctrl_state == CTRL_ITER) && producer_active && (producer_step == PROD_STEP_READ) && !clear_next_m_pending && !iter_check_pending;
  assign o_c2v_write_t = (ctrl_state == CTRL_ITER) && producer_active && (producer_step == PROD_STEP_WRITE) && !clear_next_m_pending && !iter_check_pending;

  assign o_vnu_read_t =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_ACCUM) && (consumer_step == CONS_STEP_READ) &&
    !clear_next_m_pending && !iter_check_pending;

  assign o_vnu_accum_t =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_ACCUM) && (consumer_step == CONS_STEP_USE) &&
    !clear_next_m_pending && !iter_check_pending;

  assign o_vnu_prep_write =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_EMIT) && (consumer_step == CONS_STEP_PREP) &&
    !clear_next_m_pending && !iter_check_pending;

  assign o_vnu_read_next_m =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_EMIT) && (consumer_step == CONS_STEP_READ_NEXT_M) &&
    !clear_next_m_pending && !iter_check_pending;

  assign o_vnu_cnu_a =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_EMIT) && (consumer_step == CONS_STEP_CNU_A) &&
    !clear_next_m_pending && !iter_check_pending;

  assign o_vnu_write_next =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_EMIT) && (consumer_step == CONS_STEP_WRITE) &&
    !clear_next_m_pending && !iter_check_pending;

  assign o_iter_check = (ctrl_state == CTRL_ITER) && iter_check_pending;

  assign producer_is_prime =
    (ctrl_state == CTRL_ITER) && producer_active && !consumer_active &&
    (o_c2v_var_idx == '0);

  assign consumer_is_drain =
    (ctrl_state == CTRL_ITER) && consumer_active && !producer_active &&
    (o_v2c_var_idx == LAST_VAR);

  assign producer_write_last = o_c2v_write_t && i_c2v_column_slot_last;
  assign consumer_emit_write_last = o_vnu_write_next && i_v2c_column_slot_last;

  assign o_capture_consumer_col_now = producer_write_last && !consumer_active;
  assign o_capture_consumer_col_next = producer_write_last && consumer_active;
  assign o_promote_consumer_col_next =
    consumer_emit_write_last && !producer_active && (o_v2c_var_idx != LAST_VAR);

  assign o_c2v_pipe_valid = o_c2v_read || o_c2v_write_t;
  assign o_v2c_pipe_valid =
    o_vnu_read_t || o_vnu_accum_t || o_vnu_prep_write ||
    o_vnu_read_next_m || o_vnu_cnu_a || o_vnu_write_next;

  assign o_work_var = o_v2c_pipe_valid ? o_v2c_var_idx : o_c2v_var_idx;
  assign o_work_edge_slot = o_v2c_pipe_valid ? o_v2c_slot_idx : o_c2v_slot_idx;
  assign o_col_slot_idx = o_work_edge_slot;

  always_comb begin
    o_state = DEC_WAIT_START;
    o_phase = DEC_PH_WAIT;

    case (ctrl_state)
      CTRL_WAIT: begin
        o_state = DEC_WAIT_START;
        o_phase = DEC_PH_WAIT;
      end

      CTRL_SEED: begin
        o_state = DEC_INIT_DECODER;
        o_phase = DEC_PH_SEED_I;
      end

      CTRL_INIT: begin
        o_state = init_clear_pending ? DEC_INIT_DECODER : DEC_INIT_ROW_ACCUM;
        if (init_clear_pending) begin
          o_phase = DEC_PH_INIT_CLEAR;
        end else begin
          case (init_step)
            INIT_STEP_READ: o_phase = DEC_PH_INIT_M_READ;
            INIT_STEP_CNU_A: o_phase = DEC_PH_INIT_CNU_A;
            default: o_phase = DEC_PH_INIT_M_WRITE;
          endcase
        end
      end

      CTRL_ITER: begin
        if (clear_next_m_pending) begin
          o_state = DEC_ITER_C2V_PRIME;
          o_phase = DEC_PH_CLEAR_NEXT_M;
        end else if (iter_check_pending) begin
          o_state = DEC_ITER_CHECK;
          o_phase = DEC_PH_ITER_CHECK;
        end else if (consumer_active) begin
          o_state = consumer_is_drain ? DEC_ITER_V2C_DRAIN : DEC_ITER_OVERLAP;
          if (consumer_mode == CONS_MODE_ACCUM) begin
            if (consumer_step == CONS_STEP_READ) begin
              o_phase = DEC_PH_VNU_READ_T;
            end else begin
              o_phase = DEC_PH_VNU_ACCUM_T;
            end
          end else begin
            case (consumer_step)
              CONS_STEP_PREP: begin
                o_phase = DEC_PH_VNU_PREP_WRITE;
              end
              CONS_STEP_READ_NEXT_M: begin
                o_phase = DEC_PH_VNU_READ_NEXT_M;
              end
              CONS_STEP_CNU_A: begin
                o_phase = DEC_PH_VNU_CNU_A;
              end
              default: begin
                o_phase = DEC_PH_VNU_WRITE_NEXT;
              end
            endcase
          end
        end else if (producer_active) begin
          o_state = producer_is_prime ? DEC_ITER_C2V_PRIME : DEC_ITER_OVERLAP;
          o_phase = (producer_step == PROD_STEP_READ) ? DEC_PH_C2V_READ : DEC_PH_C2V_WRITE_T;
        end
      end

      default: begin
        o_state = DEC_DONE;
        o_phase = DEC_PH_DONE;
      end
    endcase
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      ctrl_state <= CTRL_WAIT;
      init_clear_pending <= 1'b0;
      init_step <= INIT_STEP_READ;
      clear_next_m_pending <= 1'b0;
      iter_check_pending <= 1'b0;
      producer_active <= 1'b0;
      producer_step <= PROD_STEP_READ;
      consumer_active <= 1'b0;
      consumer_mode <= CONS_MODE_ACCUM;
      consumer_step <= CONS_STEP_READ;
      o_c2v_var_idx <= '0;
      o_v2c_var_idx <= '0;
      o_c2v_slot_idx <= '0;
      o_v2c_slot_idx <= '0;
      o_active_m_pair <= 1'b0;
      o_seed_circ_idx <= '0;
      o_c2v_v2c_overlap_seen <= 1'b0;
      o_done <= 1'b0;
      o_success <= 1'b0;
      o_iter_count <= '0;
    end else begin
      case (ctrl_state)
        CTRL_WAIT: begin
          o_done <= 1'b0;
          o_success <= 1'b0;
          if (i_start) begin
            ctrl_state <= CTRL_SEED;
            init_clear_pending <= 1'b0;
            clear_next_m_pending <= 1'b0;
            iter_check_pending <= 1'b0;
            producer_active <= 1'b0;
            producer_step <= PROD_STEP_READ;
            consumer_active <= 1'b0;
            consumer_mode <= CONS_MODE_ACCUM;
            consumer_step <= CONS_STEP_READ;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_slot_idx <= '0;
            o_active_m_pair <= 1'b0;
            o_seed_circ_idx <= '0;
            o_c2v_v2c_overlap_seen <= 1'b0;
            o_iter_count <= '0;
          end
        end

        CTRL_SEED: begin
          if (o_seed_circ_idx == BANK_W'(N0 - 1)) begin
            ctrl_state <= CTRL_INIT;
            init_clear_pending <= 1'b1;
            init_step <= INIT_STEP_READ;
            clear_next_m_pending <= 1'b0;
            iter_check_pending <= 1'b0;
            producer_active <= 1'b0;
            consumer_active <= 1'b0;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_slot_idx <= '0;
          end else begin
            o_seed_circ_idx <= o_seed_circ_idx + BANK_W'(1);
          end
        end

        CTRL_INIT: begin
          if (init_clear_pending) begin
            init_clear_pending <= 1'b0;
            init_step <= INIT_STEP_READ;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_slot_idx <= '0;
          end else begin
            case (init_step)
              INIT_STEP_READ: begin
                init_step <= INIT_STEP_CNU_A;
              end

              INIT_STEP_CNU_A: begin
                init_step <= INIT_STEP_WRITE;
              end

              default: begin
                if (i_c2v_column_slot_last) begin
                  o_c2v_slot_idx <= '0;
                  if (o_c2v_var_idx == LAST_VAR) begin
                    ctrl_state <= CTRL_ITER;
                    clear_next_m_pending <= 1'b1;
                    producer_active <= 1'b0;
                    producer_step <= PROD_STEP_READ;
                    consumer_active <= 1'b0;
                    consumer_mode <= CONS_MODE_ACCUM;
                    consumer_step <= CONS_STEP_READ;
                    o_c2v_var_idx <= '0;
                    o_v2c_var_idx <= '0;
                    o_v2c_slot_idx <= '0;
                  end else begin
                    o_c2v_var_idx <= next_var(o_c2v_var_idx);
                    init_step <= INIT_STEP_READ;
                  end
                end else begin
                  o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
                  init_step <= INIT_STEP_READ;
                end
              end
            endcase
          end
        end

        CTRL_ITER: begin
          o_done <= 1'b0;
          if (clear_next_m_pending) begin
            clear_next_m_pending <= 1'b0;
            producer_active <= 1'b1;
            producer_step <= PROD_STEP_READ;
            consumer_active <= 1'b0;
            consumer_mode <= CONS_MODE_ACCUM;
            consumer_step <= CONS_STEP_READ;
            o_c2v_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_var_idx <= '0;
            o_v2c_slot_idx <= '0;
          end else if (iter_check_pending) begin
            iter_check_pending <= 1'b0;
            o_iter_count <= next_iter_count;
            if (i_finish_decode) begin
              ctrl_state <= CTRL_DONE;
              producer_active <= 1'b0;
              consumer_active <= 1'b0;
              o_done <= 1'b1;
              o_success <= i_decode_success;
            end else begin
              o_active_m_pair <= o_next_m_pair;
              clear_next_m_pending <= 1'b1;
              producer_active <= 1'b0;
              producer_step <= PROD_STEP_READ;
              consumer_active <= 1'b0;
              consumer_mode <= CONS_MODE_ACCUM;
              consumer_step <= CONS_STEP_READ;
              o_c2v_var_idx <= '0;
              o_v2c_var_idx <= '0;
              o_c2v_slot_idx <= '0;
              o_v2c_slot_idx <= '0;
            end
          end else if (!consumer_active) begin
            if (producer_active) begin
              if (producer_step == PROD_STEP_READ) begin
                producer_step <= PROD_STEP_WRITE;
              end else if (i_c2v_column_slot_last) begin
                consumer_active <= 1'b1;
                consumer_mode <= CONS_MODE_ACCUM;
                consumer_step <= CONS_STEP_READ;
                o_v2c_var_idx <= o_c2v_var_idx;
                o_v2c_slot_idx <= '0;
                o_c2v_slot_idx <= '0;
                if (o_c2v_var_idx == LAST_VAR) begin
                  producer_active <= 1'b0;
                  producer_step <= PROD_STEP_READ;
                end else begin
                  producer_active <= 1'b1;
                  producer_step <= PROD_STEP_READ;
                  o_c2v_var_idx <= next_var(o_c2v_var_idx);
                  o_c2v_v2c_overlap_seen <= 1'b1;
                end
              end else begin
                producer_step <= PROD_STEP_READ;
                o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
              end
            end
          end else if (consumer_mode == CONS_MODE_ACCUM) begin
            if (consumer_step == CONS_STEP_READ) begin
              consumer_step <= CONS_STEP_USE;
              if (producer_active) begin
                producer_step <= PROD_STEP_WRITE;
              end
            end else begin
              if (producer_active) begin
                producer_step <= PROD_STEP_READ;
                if (i_c2v_column_slot_last) begin
                  producer_active <= 1'b0;
                  o_c2v_slot_idx <= '0;
                end else begin
                  o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
                end
              end

              if (i_v2c_column_slot_last) begin
                o_v2c_slot_idx <= '0;
                consumer_mode <= CONS_MODE_EMIT;
                consumer_step <= CONS_STEP_PREP;
              end else begin
                o_v2c_slot_idx <= o_v2c_slot_idx + EDGE_W'(1);
                consumer_step <= CONS_STEP_READ;
              end
            end
          end else begin
            case (consumer_step)
              CONS_STEP_PREP: begin
                consumer_step <= CONS_STEP_READ_NEXT_M;
              end

              CONS_STEP_READ_NEXT_M: begin
                consumer_step <= CONS_STEP_CNU_A;
                if (producer_active) begin
                  producer_step <= PROD_STEP_WRITE;
                end
              end

              CONS_STEP_CNU_A: begin
                consumer_step <= CONS_STEP_WRITE;
                if (producer_active) begin
                  producer_step <= PROD_STEP_READ;
                  if (i_c2v_column_slot_last) begin
                    producer_active <= 1'b0;
                    o_c2v_slot_idx <= '0;
                  end else begin
                    o_c2v_slot_idx <= o_c2v_slot_idx + EDGE_W'(1);
                  end
                end
              end

              default: begin
                if (i_v2c_column_slot_last) begin
                  o_v2c_slot_idx <= '0;
                  consumer_mode <= CONS_MODE_ACCUM;
                  consumer_step <= CONS_STEP_READ;
                  if (o_v2c_var_idx == LAST_VAR) begin
                    consumer_active <= 1'b0;
                    iter_check_pending <= 1'b1;
                  end else if (producer_active) begin
                    consumer_active <= 1'b0;
                  end else begin
                    consumer_active <= 1'b1;
                    o_v2c_var_idx <= next_var(o_v2c_var_idx);
                    if (next_var(o_v2c_var_idx) == LAST_VAR) begin
                      producer_active <= 1'b0;
                      producer_step <= PROD_STEP_READ;
                    end else begin
                      producer_active <= 1'b1;
                      producer_step <= PROD_STEP_READ;
                      o_c2v_var_idx <= next_var(next_var(o_v2c_var_idx));
                      o_c2v_slot_idx <= '0;
                      o_c2v_v2c_overlap_seen <= 1'b1;
                    end
                  end
                end else begin
                  o_v2c_slot_idx <= o_v2c_slot_idx + EDGE_W'(1);
                  consumer_step <= CONS_STEP_READ_NEXT_M;
                end
              end
            endcase
          end
        end

        default: begin
          o_done <= 1'b1;
          if (i_start) begin
            ctrl_state <= CTRL_SEED;
            init_clear_pending <= 1'b0;
            clear_next_m_pending <= 1'b0;
            iter_check_pending <= 1'b0;
            producer_active <= 1'b0;
            producer_step <= PROD_STEP_READ;
            consumer_active <= 1'b0;
            consumer_mode <= CONS_MODE_ACCUM;
            consumer_step <= CONS_STEP_READ;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_slot_idx <= '0;
            o_v2c_slot_idx <= '0;
            o_active_m_pair <= 1'b0;
            o_seed_circ_idx <= '0;
            o_c2v_v2c_overlap_seen <= 1'b0;
            o_done <= 1'b0;
            o_success <= 1'b0;
            o_iter_count <= '0;
          end
        end
      endcase
    end
  end
endmodule
