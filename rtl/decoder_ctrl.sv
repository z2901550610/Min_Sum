// Decoder control for Fig.8-style column-overlap scheduling using a small
// set of macro states plus c2v/v2c column contexts.
module decoder_ctrl
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_start,                                        // Starts a new decode pass.
  input  logic i_finish_decode,                                // Requests transition to DONE after the check phase.
  input  logic i_decode_success,                               // Indicates whether the residual syndrome is zero.
  input  logic i_c2v_entry_pos_last,                         // c2v side: current entry list position is the last in this column.
  input  logic i_v2c_entry_pos_last,                         // v2c side: current entry list position is the last in this column.
  output logic [DEC_STATE_W-1:0] o_state,                      // Coarse decoder state for debug/observation.
  output logic [DEC_PHASE_W-1:0] o_phase,                      // Current debug micro-stage.
  output logic [VAR_W-1:0] o_work_var,                         // Debug-selected active column.
  output logic [ONE_IDX_W-1:0] o_work_entry_pos,               // Debug-selected entry list position.
  output logic [VAR_W-1:0] o_c2v_var_idx,                      // Column currently being reconstructed into c2v.
  output logic [VAR_W-1:0] o_v2c_var_idx,                      // Column currently being updated into v2c.
  output logic [ONE_IDX_W-1:0] o_c2v_entry_pos,                // Active entry list position inside the c2v column.
  output logic [ONE_IDX_W-1:0] o_v2c_entry_pos,                // Active entry list position inside the v2c column.
  output logic [ONE_IDX_W-1:0] o_active_entry_pos,             // Debug-selected entry list position.
  output logic o_m_read_pair,                                  // RAM-M pair selected for compressed-c2v reads.
  output logic o_m_write_pair,                                 // RAM-M pair selected for compressed-c2v writes.
  output logic o_seed_active,                                  // Loads static first-column RAM-I metadata.
  output logic [H_BLOCK_W-1:0] o_seed_h_block_idx,              // Which H block's first-column RAM-I list is seeded.
  output logic o_init_m_read,                                  // Reads RAM-M/RAM-U for initial CNU_A.
  output logic o_init_cnu_a,                                   // Enables CNU_A for initial accumulation.
  output logic o_init_m_write,                                 // Writes initial CNU_A result.
  output logic o_c2v_read,                                     // Reads RAM-M/RAM-S for CNU_B.
  output logic o_c2v_write_t,                                  // Writes CNU_B/codec result to RAM-T.
  output logic o_vnu_read_t,                                   // Reads RAM-T for VNU accumulation.
  output logic o_vnu_accum_t,                                  // Accumulates one RAM-T value in VNU.
  output logic o_vnu_prep_write,                               // Captures VNU decision.
  output logic o_vnu_read_next_m,                              // Reads next RAM-M pair before CNU_A.
  output logic o_vnu_cnu_a,                                    // Enables CNU_A with VNU-generated v2c.
  output logic o_vnu_write_next,                               // Writes RAM-U/RAM-M/RAM-S for next iteration.
  output logic o_iter_check,                                   // Iteration completion/check cycle.
  output logic o_capture_v2c_column_now,                      // Current c2v column becomes the active v2c column.
  output logic o_capture_v2c_column_next,                     // Current c2v column becomes the buffered next v2c column.
  output logic o_promote_v2c_column_next,                     // Buffered next v2c column becomes active.
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

  // Macro control states. Fine-grain activity is carried by the c2v and v2c
  // column contexts below rather than by a long flat micro-phase FSM.
  localparam logic [2:0] CTRL_WAIT = 3'd0;
  localparam logic [2:0] CTRL_SEED = 3'd1;
  localparam logic [2:0] CTRL_INIT = 3'd2;
  localparam logic [2:0] CTRL_ITER = 3'd3;
  localparam logic [2:0] CTRL_DONE = 3'd4;

  // INIT walks one column entry position through read -> CNU_A -> write.
  localparam logic [1:0] INIT_STEP_READ = 2'd0;
  localparam logic [1:0] INIT_STEP_CNU_A = 2'd1;
  localparam logic [1:0] INIT_STEP_WRITE = 2'd2;

  // During ITER, the c2v side reconstructs column j+1 while the v2c side
  // accumulates and updates column j.
  localparam logic PROD_STEP_READ = 1'b0;
  localparam logic PROD_STEP_WRITE = 1'b1;

  localparam logic CONS_MODE_ACCUM = 1'b0;
  localparam logic CONS_MODE_V2C = 1'b1;

  localparam logic [2:0] CONS_STEP_READ = 3'd0;
  localparam logic [2:0] CONS_STEP_USE = 3'd1;
  localparam logic [2:0] CONS_STEP_PREP = 3'd2;
  localparam logic [2:0] CONS_STEP_READ_NEXT_M = 3'd3;
  localparam logic [2:0] CONS_STEP_CNU_A = 3'd4;
  localparam logic [2:0] CONS_STEP_WRITE = 3'd5;

  logic [2:0] ctrl_state;
  logic [1:0] init_step;
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
  logic consumer_v2c_write_last;

  function automatic logic [VAR_W-1:0] next_var(
    input logic [VAR_W-1:0] var_idx
  );
    begin
      next_var = var_idx + VAR_W'(1);
    end
  endfunction

  // The control outputs are intentionally kept as one-cycle pulses that the
  // datapath can consume directly. `o_phase` is debug-only and mirrors the
  // current context in a compact encoding.
  assign next_iter_count = o_iter_count + 1'b1;
  assign o_m_write_pair = ~o_m_read_pair;
  assign o_seed_active = (ctrl_state == CTRL_SEED);

  assign o_init_m_read = (ctrl_state == CTRL_INIT) && (init_step == INIT_STEP_READ);
  assign o_init_cnu_a = (ctrl_state == CTRL_INIT) && (init_step == INIT_STEP_CNU_A);
  assign o_init_m_write = (ctrl_state == CTRL_INIT) && (init_step == INIT_STEP_WRITE);

  assign o_c2v_read = (ctrl_state == CTRL_ITER) && producer_active && (producer_step == PROD_STEP_READ) && !iter_check_pending;
  assign o_c2v_write_t = (ctrl_state == CTRL_ITER) && producer_active && (producer_step == PROD_STEP_WRITE) && !iter_check_pending;

  assign o_vnu_read_t =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_ACCUM) && (consumer_step == CONS_STEP_READ) &&
    !iter_check_pending;

  assign o_vnu_accum_t =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_ACCUM) && (consumer_step == CONS_STEP_USE) &&
    !iter_check_pending;

  assign o_vnu_prep_write =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_V2C) && (consumer_step == CONS_STEP_PREP) &&
    !iter_check_pending;

  assign o_vnu_read_next_m =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_V2C) && (consumer_step == CONS_STEP_READ_NEXT_M) &&
    !iter_check_pending;

  assign o_vnu_cnu_a =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_V2C) && (consumer_step == CONS_STEP_CNU_A) &&
    !iter_check_pending;

  assign o_vnu_write_next =
    (ctrl_state == CTRL_ITER) && consumer_active &&
    (consumer_mode == CONS_MODE_V2C) && (consumer_step == CONS_STEP_WRITE) &&
    !iter_check_pending;

  assign o_iter_check = (ctrl_state == CTRL_ITER) && iter_check_pending;

  assign producer_is_prime =
    (ctrl_state == CTRL_ITER) && producer_active && !consumer_active &&
    (o_c2v_var_idx == '0);

  assign consumer_is_drain =
    (ctrl_state == CTRL_ITER) && consumer_active && !producer_active &&
    (o_v2c_var_idx == LAST_VAR);

  assign producer_write_last = o_c2v_write_t && i_c2v_entry_pos_last;
  assign consumer_v2c_write_last = o_vnu_write_next && i_v2c_entry_pos_last;

  assign o_capture_v2c_column_now = producer_write_last && !consumer_active;
  assign o_capture_v2c_column_next = producer_write_last && consumer_active;
  assign o_promote_v2c_column_next =
    consumer_v2c_write_last && !producer_active && (o_v2c_var_idx != LAST_VAR);

  assign o_c2v_pipe_valid = o_c2v_read || o_c2v_write_t;
  assign o_v2c_pipe_valid =
    o_vnu_read_t || o_vnu_accum_t || o_vnu_prep_write ||
    o_vnu_read_next_m || o_vnu_cnu_a || o_vnu_write_next;

  assign o_work_var = o_v2c_pipe_valid ? o_v2c_var_idx : o_c2v_var_idx;
  assign o_work_entry_pos = o_v2c_pipe_valid ? o_v2c_entry_pos : o_c2v_entry_pos;
  assign o_active_entry_pos = o_work_entry_pos;

  // Export a legacy-style phase view for debug/waveform readability. The
  // actual scheduling decisions are made by the contexts in the sequential
  // block below.
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
        o_state = DEC_INIT_ROW_ACCUM;
        case (init_step)
          INIT_STEP_READ: o_phase = DEC_PH_INIT_M_READ;
          INIT_STEP_CNU_A: o_phase = DEC_PH_INIT_CNU_A;
          default: o_phase = DEC_PH_INIT_M_WRITE;
        endcase
      end

      CTRL_ITER: begin
        if (iter_check_pending) begin
          o_state = DEC_ITER_CHECK;
          o_phase = DEC_PH_ITER_CHECK;
        end else if (consumer_active) begin
          o_state = consumer_is_drain ? DEC_ITER_V2C_DRAIN : DEC_ITER_OVERLAP;
          if (consumer_mode == CONS_MODE_ACCUM) begin
            if (consumer_step == CONS_STEP_READ) begin
              o_phase = consumer_is_drain ? DEC_PH_DRAIN_ACCUM_READ : DEC_PH_OVERLAP_ACCUM_READ;
            end else begin
              o_phase = consumer_is_drain ? DEC_PH_DRAIN_ACCUM_USE : DEC_PH_OVERLAP_ACCUM_USE;
            end
          end else begin
            case (consumer_step)
              CONS_STEP_PREP: begin
                o_phase = consumer_is_drain ? DEC_PH_DRAIN_PREP : DEC_PH_OVERLAP_PREP;
              end
              CONS_STEP_READ_NEXT_M: begin
                o_phase = consumer_is_drain ? DEC_PH_DRAIN_EMIT_READ : DEC_PH_OVERLAP_EMIT_READ;
              end
              CONS_STEP_CNU_A: begin
                o_phase = consumer_is_drain ? DEC_PH_DRAIN_EMIT_CNU_A : DEC_PH_OVERLAP_EMIT_CNU_A;
              end
              default: begin
                o_phase = consumer_is_drain ? DEC_PH_DRAIN_EMIT_WRITE : DEC_PH_OVERLAP_EMIT_WRITE;
              end
            endcase
          end
        end else if (producer_active) begin
          o_state = producer_is_prime ? DEC_ITER_C2V_PRIME : DEC_ITER_OVERLAP;
          if (producer_is_prime) begin
            o_phase = (producer_step == PROD_STEP_READ) ? DEC_PH_PRIME_READ : DEC_PH_PRIME_WRITE;
          end else begin
            o_phase = (producer_step == PROD_STEP_READ) ? DEC_PH_PROD_FINISH_READ : DEC_PH_PROD_FINISH_WRITE;
          end
        end
      end

      default: begin
        o_state = DEC_DONE;
        o_phase = DEC_PH_DONE;
      end
    endcase
  end

  // State update rules:
  // 1. INIT builds the first compressed-c2v pair one row_group position at a time.
  // 2. ITER prime phase fills v2c column 0.
  // 3. Once v2c is active, c2v stays one column ahead when possible.
  // 4. When c2v drains, v2c finishes the remaining column and then
  //    ITER_CHECK decides whether to swap RAM-M pairs or stop.
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      ctrl_state <= CTRL_WAIT;
      init_step <= INIT_STEP_READ;
      iter_check_pending <= 1'b0;
      producer_active <= 1'b0;
      producer_step <= PROD_STEP_READ;
      consumer_active <= 1'b0;
      consumer_mode <= CONS_MODE_ACCUM;
      consumer_step <= CONS_STEP_READ;
      o_c2v_var_idx <= '0;
      o_v2c_var_idx <= '0;
      o_c2v_entry_pos <= '0;
      o_v2c_entry_pos <= '0;
      o_m_read_pair <= 1'b0;
      o_seed_h_block_idx <= '0;
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
            iter_check_pending <= 1'b0;
            producer_active <= 1'b0;
            producer_step <= PROD_STEP_READ;
            consumer_active <= 1'b0;
            consumer_mode <= CONS_MODE_ACCUM;
            consumer_step <= CONS_STEP_READ;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_entry_pos <= '0;
            o_v2c_entry_pos <= '0;
            o_m_read_pair <= 1'b0;
            o_seed_h_block_idx <= '0;
            o_c2v_v2c_overlap_seen <= 1'b0;
            o_iter_count <= '0;
          end
        end

        CTRL_SEED: begin
          if (o_seed_h_block_idx == H_BLOCK_W'(N0 - 1)) begin
            ctrl_state <= CTRL_INIT;
            init_step <= INIT_STEP_READ;
            iter_check_pending <= 1'b0;
            producer_active <= 1'b0;
            consumer_active <= 1'b0;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_entry_pos <= '0;
            o_v2c_entry_pos <= '0;
          end else begin
            o_seed_h_block_idx <= o_seed_h_block_idx + H_BLOCK_W'(1);
          end
        end

        CTRL_INIT: begin
          case (init_step)
            INIT_STEP_READ: begin
              init_step <= INIT_STEP_CNU_A;
            end

            INIT_STEP_CNU_A: begin
              init_step <= INIT_STEP_WRITE;
            end

            default: begin
              if (i_c2v_entry_pos_last) begin
                o_c2v_entry_pos <= '0;
                if (o_c2v_var_idx == LAST_VAR) begin
                  ctrl_state <= CTRL_ITER;
                  producer_active <= 1'b1;
                  producer_step <= PROD_STEP_READ;
                  consumer_active <= 1'b0;
                  consumer_mode <= CONS_MODE_ACCUM;
                  consumer_step <= CONS_STEP_READ;
                  o_c2v_var_idx <= '0;
                  o_v2c_var_idx <= '0;
                  o_v2c_entry_pos <= '0;
                end else begin
                  o_c2v_var_idx <= next_var(o_c2v_var_idx);
                  init_step <= INIT_STEP_READ;
                end
              end else begin
                o_c2v_entry_pos <= o_c2v_entry_pos + ONE_IDX_W'(1);
                init_step <= INIT_STEP_READ;
              end
            end
          endcase
        end

        CTRL_ITER: begin
          o_done <= 1'b0;
          if (iter_check_pending) begin
            iter_check_pending <= 1'b0;
            o_iter_count <= next_iter_count;
            if (i_finish_decode) begin
              ctrl_state <= CTRL_DONE;
              producer_active <= 1'b0;
              consumer_active <= 1'b0;
              o_done <= 1'b1;
              o_success <= i_decode_success;
            end else begin
              o_m_read_pair <= o_m_write_pair;
              producer_active <= 1'b1;
              producer_step <= PROD_STEP_READ;
              consumer_active <= 1'b0;
              consumer_mode <= CONS_MODE_ACCUM;
              consumer_step <= CONS_STEP_READ;
              o_c2v_var_idx <= '0;
              o_v2c_var_idx <= '0;
              o_c2v_entry_pos <= '0;
              o_v2c_entry_pos <= '0;
            end
          end else if (!consumer_active) begin
            if (producer_active) begin
              if (producer_step == PROD_STEP_READ) begin
                producer_step <= PROD_STEP_WRITE;
              end else if (i_c2v_entry_pos_last) begin
                consumer_active <= 1'b1;
                consumer_mode <= CONS_MODE_ACCUM;
                consumer_step <= CONS_STEP_READ;
                o_v2c_var_idx <= o_c2v_var_idx;
                o_v2c_entry_pos <= '0;
                o_c2v_entry_pos <= '0;
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
                o_c2v_entry_pos <= o_c2v_entry_pos + ONE_IDX_W'(1);
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
                if (i_c2v_entry_pos_last) begin
                  producer_active <= 1'b0;
                  o_c2v_entry_pos <= '0;
                end else begin
                  o_c2v_entry_pos <= o_c2v_entry_pos + ONE_IDX_W'(1);
                end
              end

              if (i_v2c_entry_pos_last) begin
                o_v2c_entry_pos <= '0;
                consumer_mode <= CONS_MODE_V2C;
                consumer_step <= CONS_STEP_PREP;
              end else begin
                o_v2c_entry_pos <= o_v2c_entry_pos + ONE_IDX_W'(1);
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
                  if (i_c2v_entry_pos_last) begin
                    producer_active <= 1'b0;
                    o_c2v_entry_pos <= '0;
                  end else begin
                    o_c2v_entry_pos <= o_c2v_entry_pos + ONE_IDX_W'(1);
                  end
                end
              end

              default: begin
                if (i_v2c_entry_pos_last) begin
                  o_v2c_entry_pos <= '0;
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
                      o_c2v_entry_pos <= '0;
                      o_c2v_v2c_overlap_seen <= 1'b1;
                    end
                  end
                end else begin
                  o_v2c_entry_pos <= o_v2c_entry_pos + ONE_IDX_W'(1);
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
            iter_check_pending <= 1'b0;
            producer_active <= 1'b0;
            producer_step <= PROD_STEP_READ;
            consumer_active <= 1'b0;
            consumer_mode <= CONS_MODE_ACCUM;
            consumer_step <= CONS_STEP_READ;
            o_c2v_var_idx <= '0;
            o_v2c_var_idx <= '0;
            o_c2v_entry_pos <= '0;
            o_v2c_entry_pos <= '0;
            o_m_read_pair <= 1'b0;
            o_seed_h_block_idx <= '0;
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
