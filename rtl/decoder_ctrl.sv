`timescale 1ns/1ps
// Decoder control for column-overlap min-sum scheduling.
module decoder_ctrl
  import bike_pkg::*;
(
  input  logic i_clk,
  input  logic i_rst_n,
  input  logic i_start,                                        // Starts a new decode pass.
  input  logic i_finish_decode,                                // Requests transition to DONE after the check phase.
  input  logic i_decode_success,                               // Indicates whether the residual syndrome is zero.
  input  logic i_c2v_entry_pos_last,                           // c2v side: current entry list position is the last in this column.
  input  logic i_v2c_entry_pos_last,                           // v2c side: current entry list position is the last in this column.
  input  logic i_ram_i_shift_ready,                             // RAM-I shifted metadata writer can accept the next c2v read.
  output logic [DEC_STATE_W-1:0] o_state,                      // Coarse decoder state for debug/observation.
  output logic [DEC_PHASE_W-1:0] o_phase,                      // Current debug micro-stage.
  output logic [COL_W-1:0] o_work_col_idx,                     // Debug-selected active column.
  output logic [ENTRY_POS_W-1:0] o_work_entry_pos,             // Debug-selected entry list position.
  output logic [COL_W-1:0] o_c2v_col_idx,                      // Column currently being reconstructed into c2v.
  output logic [COL_W-1:0] o_v2c_col_idx,                      // Column currently being updated into v2c.
  output logic [ENTRY_POS_W-1:0] o_c2v_entry_pos,              // Active entry list position inside the c2v column.
  output logic [ENTRY_POS_W-1:0] o_v2c_entry_pos,              // Active entry list position inside the v2c column.
  output logic [ENTRY_POS_W-1:0] o_active_entry_pos,           // Debug-selected entry list position.
  output logic o_m_read_pair,                                  // RAM-M pair selected for compressed-c2v reads.
  output logic o_m_write_pair,                                 // RAM-M pair selected for compressed-c2v writes.
  output logic o_c2v_read,                                     // Reads RAM-M/RAM-S for CNU_B.
  output logic o_c2v_write_t,                                  // Writes CNU_B/codec result to RAM-T.
  output logic o_vnu_accum_t,                                  // Accumulates one col k+1 c2v value in VNU.
  output logic o_vnu_prep_write,                               // Captures VNU decision.
  output logic o_vnu_cnu_a,                                    // Enables CNU_A with VNU-generated v2c.
  output logic o_vnu_write_next,                               // Writes RAM-M/RAM-S for next iteration.
  output logic o_iter_check,                                   // Iteration completion/check cycle.
  output logic o_col_k_meta_advance,                           // Col k metadata slot advances to the filled col k+1 slot.
  output logic o_c2v_pipe_valid,                               // Debug c2v activity flag.
  output logic o_v2c_pipe_valid,                               // Debug v2c activity flag.
  output logic o_c2v_v2c_overlap_seen,                         // Debug flag for exposed overlap.
  output logic o_done,                                         // Decode completion flag.
  output logic o_success,                                      // Decode success flag.
  output logic [$clog2(I_MAX + 1)-1:0] o_iter_count            // Completed iteration count.
);

  localparam int ITER_W = $clog2(I_MAX + 1);
  localparam logic [COL_W-1:0] LAST_COL = COL_W'(N - 1);

  localparam logic [2:0] CTRL_WAIT = 3'd0;
  localparam logic [2:0] CTRL_ITER = 3'd3;
  localparam logic [2:0] CTRL_DONE = 3'd4;

  localparam logic [1:0] COL_K_STAGE_FIRST = 2'd0;
  localparam logic [1:0] COL_K_STAGE_ISSUE = 2'd1;

  localparam logic [1:0] SCHED_FILL_K = 2'd0;
  localparam logic [1:0] SCHED_K_KP1 = 2'd1;
  localparam logic [1:0] SCHED_KP1_READY = 2'd2;
  localparam logic [1:0] SCHED_DRAIN_K = 2'd3;

  logic [2:0] ctrl_state;
  logic [2:0] ctrl_state_next;
  logic iter_check_pending;
  logic iter_check_pending_next;

  logic col_kp1_c2v_valid_d1;
  logic col_kp1_last_d1;
  logic col_kp1_col_last_d1;
  logic col_kp1_c2v_valid_d1_next;
  logic col_kp1_last_d1_next;
  logic col_kp1_col_last_d1_next;

  logic [1:0] sched_state;
  logic [1:0] col_k_stage;
  logic col_k_v2c_valid_d1;
  logic col_k_last_d1;
  logic col_k_col_last_d1;
  logic [1:0] sched_state_next;
  logic [1:0] col_k_stage_next;
  logic col_k_v2c_valid_d1_next;
  logic col_k_last_d1_next;
  logic col_k_col_last_d1_next;

  logic [COL_W-1:0] c2v_col_idx_next;
  logic [COL_W-1:0] v2c_col_idx_next;
  logic [ENTRY_POS_W-1:0] c2v_entry_pos_next;
  logic [ENTRY_POS_W-1:0] v2c_entry_pos_next;
  logic m_read_pair_next;
  logic c2v_v2c_overlap_seen_next;
  logic done_next;
  logic success_next;
  logic [ITER_W-1:0] iter_count_next;

  logic col_kp1_c2v_issue_fire;
  logic col_k_v2c_issue_fire;
  logic col_k_last_issue_fire;
  logic col_kp1_done_fire;
  logic col_k_last_write_fire;
  logic schedule_has_col_kp1;
  logic schedule_has_col_k;
  logic col_k_is_drain;
  logic col_kp1_is_prime;
  logic [ITER_W-1:0] next_iter_count;

  function automatic logic [COL_W-1:0] next_col(
    input logic [COL_W-1:0] col_idx
  );
    begin
      next_col = col_idx + COL_W'(1);
    end
  endfunction

  assign next_iter_count = o_iter_count + 1'b1;
  assign o_m_write_pair = ~o_m_read_pair;

  assign schedule_has_col_kp1 =
    (sched_state == SCHED_FILL_K) || (sched_state == SCHED_K_KP1);
  assign schedule_has_col_k =
    (sched_state == SCHED_K_KP1) ||
    (sched_state == SCHED_KP1_READY) ||
    (sched_state == SCHED_DRAIN_K);

  assign col_kp1_c2v_issue_fire =
    (ctrl_state == CTRL_ITER) && schedule_has_col_kp1 &&
    !iter_check_pending && i_ram_i_shift_ready;

  assign col_k_v2c_issue_fire =
    (ctrl_state == CTRL_ITER) && schedule_has_col_k && !iter_check_pending &&
    ((col_k_stage == COL_K_STAGE_FIRST) ||
     (col_k_stage == COL_K_STAGE_ISSUE));
  assign col_k_last_issue_fire = col_k_v2c_issue_fire && i_v2c_entry_pos_last;

  assign o_c2v_read = col_kp1_c2v_issue_fire;
  assign o_c2v_write_t = (ctrl_state == CTRL_ITER) && col_kp1_c2v_valid_d1 && !iter_check_pending;

  assign o_vnu_accum_t = o_c2v_write_t;
  assign o_vnu_prep_write =
    (ctrl_state == CTRL_ITER) && schedule_has_col_k && !iter_check_pending &&
    (col_k_stage == COL_K_STAGE_FIRST);
  assign o_vnu_cnu_a = col_k_v2c_issue_fire;
  assign o_vnu_write_next = (ctrl_state == CTRL_ITER) && col_k_v2c_valid_d1 && !iter_check_pending;
  assign o_iter_check = (ctrl_state == CTRL_ITER) && iter_check_pending;

  assign col_kp1_done_fire = o_c2v_write_t && col_kp1_last_d1;
  assign col_k_last_write_fire = o_vnu_write_next && col_k_last_d1;

  assign o_col_k_meta_advance =
    (col_kp1_done_fire && (sched_state == SCHED_FILL_K)) ||
    (col_k_last_issue_fire &&
     ((sched_state == SCHED_KP1_READY) ||
      ((sched_state == SCHED_K_KP1) && col_kp1_done_fire)));

  assign o_c2v_pipe_valid = o_c2v_read || o_c2v_write_t;
  assign o_v2c_pipe_valid =
    o_vnu_prep_write || o_vnu_cnu_a || o_vnu_write_next;

  assign o_work_col_idx = o_v2c_pipe_valid ? o_v2c_col_idx : o_c2v_col_idx;
  assign o_work_entry_pos = o_v2c_pipe_valid ? o_v2c_entry_pos : o_c2v_entry_pos;
  assign o_active_entry_pos = o_work_entry_pos;

  assign col_k_is_drain =
    (ctrl_state == CTRL_ITER) && (sched_state == SCHED_DRAIN_K);

  assign col_kp1_is_prime =
    (ctrl_state == CTRL_ITER) &&
    ((sched_state == SCHED_FILL_K) || col_kp1_c2v_valid_d1) &&
    !schedule_has_col_k && (o_c2v_col_idx == '0);

  always_comb begin
    o_state = DEC_WAIT_START;
    o_phase = DEC_PH_WAIT;

    case (ctrl_state)
      CTRL_WAIT: begin
        o_state = DEC_WAIT_START;
        o_phase = DEC_PH_WAIT;
      end

      CTRL_ITER: begin
        if (iter_check_pending) begin
          o_state = DEC_ITER_CHECK;
          o_phase = DEC_PH_ITER_CHECK;
        end else if (schedule_has_col_k) begin
          o_state = col_k_is_drain ? DEC_ITER_V2C_DRAIN : DEC_ITER_OVERLAP;
          case (col_k_stage)
            COL_K_STAGE_FIRST: begin
              o_phase = col_k_is_drain ? DEC_PH_DRAIN_PREP : DEC_PH_OVERLAP_PREP;
            end
            COL_K_STAGE_ISSUE: begin
              o_phase = col_k_is_drain ? DEC_PH_DRAIN_EMIT_CNU_A : DEC_PH_OVERLAP_EMIT_CNU_A;
            end
            default: o_phase = col_k_is_drain ? DEC_PH_DRAIN_EMIT_CNU_A : DEC_PH_OVERLAP_EMIT_CNU_A;
          endcase
        end else if (schedule_has_col_kp1 || col_kp1_c2v_valid_d1) begin
          o_state = col_kp1_is_prime ? DEC_ITER_C2V_PRIME : DEC_ITER_OVERLAP;
          o_phase = o_c2v_read ? DEC_PH_PRIME_READ : DEC_PH_PRIME_WRITE;
          if (!col_kp1_is_prime) begin
            o_phase = o_c2v_read ? DEC_PH_PROD_FINISH_READ : DEC_PH_PROD_FINISH_WRITE;
          end
        end
      end

      default: begin
        o_state = DEC_DONE;
        o_phase = DEC_PH_DONE;
      end
    endcase
  end

  always_comb begin
    ctrl_state_next = ctrl_state;
    iter_check_pending_next = iter_check_pending;
    sched_state_next = sched_state;
    col_k_stage_next = col_k_stage;
    col_kp1_c2v_valid_d1_next = col_kp1_c2v_valid_d1;
    col_kp1_last_d1_next = col_kp1_last_d1;
    col_kp1_col_last_d1_next = col_kp1_col_last_d1;
    col_k_v2c_valid_d1_next = col_k_v2c_valid_d1;
    col_k_last_d1_next = col_k_last_d1;
    col_k_col_last_d1_next = col_k_col_last_d1;
    c2v_col_idx_next = o_c2v_col_idx;
    v2c_col_idx_next = o_v2c_col_idx;
    c2v_entry_pos_next = o_c2v_entry_pos;
    v2c_entry_pos_next = o_v2c_entry_pos;
    m_read_pair_next = o_m_read_pair;
    c2v_v2c_overlap_seen_next = o_c2v_v2c_overlap_seen;
    done_next = o_done;
    success_next = o_success;
    iter_count_next = o_iter_count;

    case (ctrl_state)
      CTRL_WAIT: begin
        done_next = 1'b0;
        success_next = 1'b0;
        if (i_start) begin
          ctrl_state_next = CTRL_ITER;
          iter_check_pending_next = 1'b0;
          sched_state_next = SCHED_FILL_K;
          col_k_stage_next = COL_K_STAGE_FIRST;
          col_kp1_c2v_valid_d1_next = 1'b0;
          col_kp1_last_d1_next = 1'b0;
          col_kp1_col_last_d1_next = 1'b0;
          col_k_v2c_valid_d1_next = 1'b0;
          col_k_last_d1_next = 1'b0;
          col_k_col_last_d1_next = 1'b0;
          c2v_col_idx_next = '0;
          v2c_col_idx_next = '0;
          c2v_entry_pos_next = '0;
          v2c_entry_pos_next = '0;
          m_read_pair_next = 1'b0;
          c2v_v2c_overlap_seen_next = 1'b0;
          iter_count_next = '0;
        end
      end

      CTRL_ITER: begin
        done_next = 1'b0;
        if (iter_check_pending) begin
          iter_check_pending_next = 1'b0;
          iter_count_next = next_iter_count;
          col_kp1_c2v_valid_d1_next = 1'b0;
          col_kp1_last_d1_next = 1'b0;
          col_kp1_col_last_d1_next = 1'b0;
          col_k_v2c_valid_d1_next = 1'b0;
          col_k_last_d1_next = 1'b0;
          col_k_col_last_d1_next = 1'b0;
          if (i_finish_decode) begin
            ctrl_state_next = CTRL_DONE;
            sched_state_next = SCHED_FILL_K;
            done_next = 1'b1;
            success_next = i_decode_success;
          end else begin
            m_read_pair_next = o_m_write_pair;
            sched_state_next = SCHED_FILL_K;
            col_k_stage_next = COL_K_STAGE_FIRST;
            c2v_col_idx_next = '0;
            v2c_col_idx_next = '0;
            c2v_entry_pos_next = '0;
            v2c_entry_pos_next = '0;
          end
        end else begin
          col_kp1_c2v_valid_d1_next = col_kp1_c2v_issue_fire;
          col_kp1_last_d1_next = col_kp1_c2v_issue_fire && i_c2v_entry_pos_last;
          col_kp1_col_last_d1_next = col_kp1_c2v_issue_fire && (o_c2v_col_idx == LAST_COL);
          col_k_v2c_valid_d1_next = col_k_v2c_issue_fire;
          col_k_last_d1_next = col_k_v2c_issue_fire && i_v2c_entry_pos_last;
          col_k_col_last_d1_next = col_k_v2c_issue_fire && (o_v2c_col_idx == LAST_COL);

          if (col_kp1_c2v_issue_fire) begin
            if (i_c2v_entry_pos_last) begin
              c2v_entry_pos_next = '0;
            end else begin
              c2v_entry_pos_next = o_c2v_entry_pos + ENTRY_POS_W'(1);
            end
          end

          if (col_kp1_done_fire) begin
            if (sched_state == SCHED_K_KP1) begin
              sched_state_next = SCHED_KP1_READY;
              c2v_entry_pos_next = '0;
            end else begin
              col_k_stage_next = COL_K_STAGE_FIRST;
              v2c_col_idx_next = o_c2v_col_idx;
              v2c_entry_pos_next = '0;
              c2v_entry_pos_next = '0;
              if (col_kp1_col_last_d1) begin
                sched_state_next = SCHED_DRAIN_K;
              end else begin
                sched_state_next = SCHED_K_KP1;
                c2v_col_idx_next = next_col(o_c2v_col_idx);
                c2v_v2c_overlap_seen_next = 1'b1;
              end
            end
          end

          if (schedule_has_col_k && col_k_v2c_issue_fire) begin
            if (i_v2c_entry_pos_last) begin
              v2c_entry_pos_next = '0;
              col_k_stage_next = COL_K_STAGE_FIRST;
              if (o_v2c_col_idx == LAST_COL) begin
                sched_state_next = SCHED_FILL_K;
              end else if (sched_state == SCHED_KP1_READY) begin
                v2c_col_idx_next = next_col(o_v2c_col_idx);
                if (next_col(o_v2c_col_idx) == LAST_COL) begin
                  sched_state_next = SCHED_DRAIN_K;
                end else begin
                  sched_state_next = SCHED_K_KP1;
                  c2v_col_idx_next = next_col(next_col(o_v2c_col_idx));
                  c2v_entry_pos_next = '0;
                  c2v_v2c_overlap_seen_next = 1'b1;
                end
              end else if (sched_state == SCHED_K_KP1) begin
                if (col_kp1_done_fire) begin
                  v2c_col_idx_next = next_col(o_v2c_col_idx);
                  if (next_col(o_v2c_col_idx) == LAST_COL) begin
                    sched_state_next = SCHED_DRAIN_K;
                  end else begin
                    sched_state_next = SCHED_K_KP1;
                    c2v_col_idx_next = next_col(next_col(o_v2c_col_idx));
                    c2v_entry_pos_next = '0;
                    c2v_v2c_overlap_seen_next = 1'b1;
                  end
                end else begin
                  sched_state_next = SCHED_FILL_K;
                end
              end
            end else begin
              v2c_entry_pos_next = o_v2c_entry_pos + ENTRY_POS_W'(1);
              col_k_stage_next = COL_K_STAGE_ISSUE;
            end
          end

          if (col_k_last_write_fire && col_k_col_last_d1) begin
            iter_check_pending_next = 1'b1;
          end
        end
      end

      CTRL_DONE: begin
        done_next = 1'b1;
        if (i_start) begin
          ctrl_state_next = CTRL_ITER;
          iter_check_pending_next = 1'b0;
          sched_state_next = SCHED_FILL_K;
          col_k_stage_next = COL_K_STAGE_FIRST;
          col_kp1_c2v_valid_d1_next = 1'b0;
          col_kp1_last_d1_next = 1'b0;
          col_kp1_col_last_d1_next = 1'b0;
          col_k_v2c_valid_d1_next = 1'b0;
          col_k_last_d1_next = 1'b0;
          col_k_col_last_d1_next = 1'b0;
          c2v_col_idx_next = '0;
          v2c_col_idx_next = '0;
          c2v_entry_pos_next = '0;
          v2c_entry_pos_next = '0;
          m_read_pair_next = 1'b0;
          c2v_v2c_overlap_seen_next = 1'b0;
          done_next = 1'b0;
          success_next = 1'b0;
          iter_count_next = '0;
        end
      end

      default: begin
        ctrl_state_next = CTRL_DONE;
        done_next = 1'b1;
      end
    endcase
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      ctrl_state <= CTRL_WAIT;
      iter_check_pending <= 1'b0;
      sched_state <= SCHED_FILL_K;
      col_k_stage <= COL_K_STAGE_FIRST;
      col_kp1_c2v_valid_d1 <= 1'b0;
      col_kp1_last_d1 <= 1'b0;
      col_kp1_col_last_d1 <= 1'b0;
      col_k_v2c_valid_d1 <= 1'b0;
      col_k_last_d1 <= 1'b0;
      col_k_col_last_d1 <= 1'b0;
      o_c2v_col_idx <= '0;
      o_v2c_col_idx <= '0;
      o_c2v_entry_pos <= '0;
      o_v2c_entry_pos <= '0;
      o_m_read_pair <= 1'b0;
      o_c2v_v2c_overlap_seen <= 1'b0;
      o_done <= 1'b0;
      o_success <= 1'b0;
      o_iter_count <= '0;
    end else begin
      ctrl_state <= ctrl_state_next;
      iter_check_pending <= iter_check_pending_next;
      sched_state <= sched_state_next;
      col_k_stage <= col_k_stage_next;
      col_kp1_c2v_valid_d1 <= col_kp1_c2v_valid_d1_next;
      col_kp1_last_d1 <= col_kp1_last_d1_next;
      col_kp1_col_last_d1 <= col_kp1_col_last_d1_next;
      col_k_v2c_valid_d1 <= col_k_v2c_valid_d1_next;
      col_k_last_d1 <= col_k_last_d1_next;
      col_k_col_last_d1 <= col_k_col_last_d1_next;
      o_c2v_col_idx <= c2v_col_idx_next;
      o_v2c_col_idx <= v2c_col_idx_next;
      o_c2v_entry_pos <= c2v_entry_pos_next;
      o_v2c_entry_pos <= v2c_entry_pos_next;
      o_m_read_pair <= m_read_pair_next;
      o_c2v_v2c_overlap_seen <= c2v_v2c_overlap_seen_next;
      o_done <= done_next;
      o_success <= success_next;
      o_iter_count <= iter_count_next;
    end
  end
endmodule
