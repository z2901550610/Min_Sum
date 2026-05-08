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
  output logic [DEC_STATE_W-1:0] o_state,                      // Coarse decoder state for debug/observation.
  output logic [DEC_PHASE_W-1:0] o_phase,                      // Current debug micro-stage.
  output logic [COL_W-1:0] o_work_col_idx,                     // Debug-selected active column.
  output logic [ONE_IDX_W-1:0] o_work_entry_pos,               // Debug-selected entry list position.
  output logic [COL_W-1:0] o_c2v_col_idx,                      // Column currently being reconstructed into c2v.
  output logic [COL_W-1:0] o_v2c_col_idx,                      // Column currently being updated into v2c.
  output logic [ONE_IDX_W-1:0] o_c2v_entry_pos,                // Active entry list position inside the c2v column.
  output logic [ONE_IDX_W-1:0] o_v2c_entry_pos,                // Active entry list position inside the v2c column.
  output logic [ONE_IDX_W-1:0] o_active_entry_pos,             // Debug-selected entry list position.
  output logic o_m_read_pair,                                  // RAM-M pair selected for compressed-c2v reads.
  output logic o_m_write_pair,                                 // RAM-M pair selected for compressed-c2v writes.
  output logic o_init_m_read,                                  // Reads RAM-M for initial CNU_A.
  output logic o_init_cnu_a,                                   // Enables CNU_A for initial accumulation.
  output logic o_init_m_write,                                 // Writes initial CNU_A result.
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
  localparam logic [2:0] CTRL_INIT = 3'd2;
  localparam logic [2:0] CTRL_ITER = 3'd3;
  localparam logic [2:0] CTRL_DONE = 3'd4;

  localparam logic [1:0] INIT_STEP_READ = 2'd0;
  localparam logic [1:0] INIT_STEP_CNU_A = 2'd1;
  localparam logic [1:0] INIT_STEP_WRITE = 2'd2;

  localparam logic [1:0] COL_K_STAGE_FIRST = 2'd0;
  localparam logic [1:0] COL_K_STAGE_ISSUE = 2'd1;

  localparam logic [1:0] SCHED_FILL_K = 2'd0;
  localparam logic [1:0] SCHED_K_KP1 = 2'd1;
  localparam logic [1:0] SCHED_KP1_READY = 2'd2;
  localparam logic [1:0] SCHED_DRAIN_K = 2'd3;

  logic [2:0] ctrl_state;
  logic [1:0] init_step;
  logic iter_check_pending;

  logic col_kp1_c2v_valid_d1;
  logic col_kp1_last_d1;
  logic col_kp1_col_last_d1;

  logic [1:0] sched_state;
  logic [1:0] col_k_stage;
  logic col_k_v2c_valid_d1;
  logic col_k_last_d1;
  logic col_k_col_last_d1;

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

  assign o_init_m_read = (ctrl_state == CTRL_INIT) && (init_step == INIT_STEP_READ);
  assign o_init_cnu_a = (ctrl_state == CTRL_INIT) && (init_step == INIT_STEP_CNU_A);
  assign o_init_m_write = (ctrl_state == CTRL_INIT) && (init_step == INIT_STEP_WRITE);

  assign schedule_has_col_kp1 =
    (sched_state == SCHED_FILL_K) || (sched_state == SCHED_K_KP1);
  assign schedule_has_col_k =
    (sched_state == SCHED_K_KP1) ||
    (sched_state == SCHED_KP1_READY) ||
    (sched_state == SCHED_DRAIN_K);

  assign col_kp1_c2v_issue_fire =
    (ctrl_state == CTRL_ITER) && schedule_has_col_kp1 && !iter_check_pending;

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

      CTRL_INIT: begin
        o_state = DEC_INIT_DECODER;
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

  task automatic clear_pipelines;
    begin
      col_kp1_c2v_valid_d1 <= 1'b0;
      col_kp1_last_d1 <= 1'b0;
      col_kp1_col_last_d1 <= 1'b0;
      col_k_v2c_valid_d1 <= 1'b0;
      col_k_last_d1 <= 1'b0;
      col_k_col_last_d1 <= 1'b0;
    end
  endtask

  task automatic reset_iteration_context;
    begin
      sched_state <= SCHED_FILL_K;
      col_k_stage <= COL_K_STAGE_FIRST;
      o_c2v_col_idx <= '0;
      o_v2c_col_idx <= '0;
      o_c2v_entry_pos <= '0;
      o_v2c_entry_pos <= '0;
    end
  endtask

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      ctrl_state <= CTRL_WAIT;
      init_step <= INIT_STEP_READ;
      iter_check_pending <= 1'b0;
      sched_state <= SCHED_FILL_K;
      col_k_stage <= COL_K_STAGE_FIRST;
      clear_pipelines();
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
      case (ctrl_state)
        CTRL_WAIT: begin
          o_done <= 1'b0;
          o_success <= 1'b0;
          if (i_start) begin
            ctrl_state <= CTRL_INIT;
            init_step <= INIT_STEP_READ;
            iter_check_pending <= 1'b0;
            sched_state <= SCHED_FILL_K;
            col_k_stage <= COL_K_STAGE_FIRST;
            clear_pipelines();
            o_c2v_col_idx <= '0;
            o_v2c_col_idx <= '0;
            o_c2v_entry_pos <= '0;
            o_v2c_entry_pos <= '0;
            o_m_read_pair <= 1'b0;
            o_c2v_v2c_overlap_seen <= 1'b0;
            o_iter_count <= '0;
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

            INIT_STEP_WRITE: begin
              if (i_c2v_entry_pos_last) begin
                o_c2v_entry_pos <= '0;
                if (o_c2v_col_idx == LAST_COL) begin
                  ctrl_state <= CTRL_ITER;
                  reset_iteration_context();
                  clear_pipelines();
                end else begin
                  o_c2v_col_idx <= next_col(o_c2v_col_idx);
                  init_step <= INIT_STEP_READ;
                end
              end else begin
                o_c2v_entry_pos <= o_c2v_entry_pos + ONE_IDX_W'(1);
                init_step <= INIT_STEP_READ;
              end
            end

            default: begin
              init_step <= INIT_STEP_READ;
            end
          endcase
        end

        CTRL_ITER: begin
          o_done <= 1'b0;
          if (iter_check_pending) begin
            iter_check_pending <= 1'b0;
            o_iter_count <= next_iter_count;
            clear_pipelines();
            if (i_finish_decode) begin
              ctrl_state <= CTRL_DONE;
              sched_state <= SCHED_FILL_K;
              o_done <= 1'b1;
              o_success <= i_decode_success;
            end else begin
              o_m_read_pair <= o_m_write_pair;
              reset_iteration_context();
            end
          end else begin
            col_kp1_c2v_valid_d1 <= col_kp1_c2v_issue_fire;
            col_kp1_last_d1 <= col_kp1_c2v_issue_fire && i_c2v_entry_pos_last;
            col_kp1_col_last_d1 <= col_kp1_c2v_issue_fire && (o_c2v_col_idx == LAST_COL);
            col_k_v2c_valid_d1 <= col_k_v2c_issue_fire;
            col_k_last_d1 <= col_k_v2c_issue_fire && i_v2c_entry_pos_last;
            col_k_col_last_d1 <= col_k_v2c_issue_fire && (o_v2c_col_idx == LAST_COL);

            if (col_kp1_c2v_issue_fire) begin
              if (i_c2v_entry_pos_last) begin
                o_c2v_entry_pos <= '0;
              end else begin
                o_c2v_entry_pos <= o_c2v_entry_pos + ONE_IDX_W'(1);
              end
            end

            if (col_kp1_done_fire) begin
              if (sched_state == SCHED_K_KP1) begin
                sched_state <= SCHED_KP1_READY;
                o_c2v_entry_pos <= '0;
              end else begin
                col_k_stage <= COL_K_STAGE_FIRST;
                o_v2c_col_idx <= o_c2v_col_idx;
                o_v2c_entry_pos <= '0;
                o_c2v_entry_pos <= '0;
                if (col_kp1_col_last_d1) begin
                  sched_state <= SCHED_DRAIN_K;
                end else begin
                  sched_state <= SCHED_K_KP1;
                  o_c2v_col_idx <= next_col(o_c2v_col_idx);
                  o_c2v_v2c_overlap_seen <= 1'b1;
                end
              end
            end

            if (schedule_has_col_k) begin
              if (col_k_v2c_issue_fire) begin
                if (i_v2c_entry_pos_last) begin
                  o_v2c_entry_pos <= '0;
                  col_k_stage <= COL_K_STAGE_FIRST;
                  if (o_v2c_col_idx == LAST_COL) begin
                    sched_state <= SCHED_FILL_K;
                  end else if (sched_state == SCHED_KP1_READY) begin
                    o_v2c_col_idx <= next_col(o_v2c_col_idx);
                    if (next_col(o_v2c_col_idx) == LAST_COL) begin
                      sched_state <= SCHED_DRAIN_K;
                    end else begin
                      sched_state <= SCHED_K_KP1;
                      o_c2v_col_idx <= next_col(next_col(o_v2c_col_idx));
                      o_c2v_entry_pos <= '0;
                      o_c2v_v2c_overlap_seen <= 1'b1;
                    end
                  end else if (sched_state == SCHED_K_KP1) begin
                    if (col_kp1_done_fire) begin
                      o_v2c_col_idx <= next_col(o_v2c_col_idx);
                      if (next_col(o_v2c_col_idx) == LAST_COL) begin
                        sched_state <= SCHED_DRAIN_K;
                      end else begin
                        sched_state <= SCHED_K_KP1;
                        o_c2v_col_idx <= next_col(next_col(o_v2c_col_idx));
                        o_c2v_entry_pos <= '0;
                        o_c2v_v2c_overlap_seen <= 1'b1;
                      end
                    end else begin
                      sched_state <= SCHED_FILL_K;
                    end
                  end
                end else begin
                  o_v2c_entry_pos <= o_v2c_entry_pos + ONE_IDX_W'(1);
                  col_k_stage <= COL_K_STAGE_ISSUE;
                end
              end
            end

            if (col_k_last_write_fire && col_k_col_last_d1) begin
              iter_check_pending <= 1'b1;
            end
          end
        end

        default: begin
          o_done <= 1'b1;
          if (i_start) begin
            ctrl_state <= CTRL_INIT;
            init_step <= INIT_STEP_READ;
            iter_check_pending <= 1'b0;
            sched_state <= SCHED_FILL_K;
            col_k_stage <= COL_K_STAGE_FIRST;
            clear_pipelines();
            o_c2v_col_idx <= '0;
            o_v2c_col_idx <= '0;
            o_c2v_entry_pos <= '0;
            o_v2c_entry_pos <= '0;
            o_m_read_pair <= 1'b0;
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
