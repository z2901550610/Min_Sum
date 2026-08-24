`timescale 1ns / 1ps

// Narrow-I/O TRIKE-2 KeyGen wrapper for Vivado synthesis and implementation.
module trike_keygen_synth_top (
                       input  logic       i_clk,
                       input  logic       i_rst_n,
                       input  logic       i_start,
                       input  logic       i_random_valid,
                       input  logic [7:0] i_random_data,
    (* IOB = "TRUE" *) output logic       o_random_ready,
    (* IOB = "TRUE" *) output logic       o_pk_valid,
    (* IOB = "TRUE" *) output logic [7:0] o_pk_data,
    (* IOB = "TRUE" *) output logic       o_pk_last,
                       input  logic       i_pk_ready,
    (* IOB = "TRUE" *) output logic       o_sk_valid,
    (* IOB = "TRUE" *) output logic [7:0] o_sk_data,
    (* IOB = "TRUE" *) output logic       o_sk_last,
                       input  logic       i_sk_ready,
    (* IOB = "TRUE" *) output logic       o_busy,
    (* IOB = "TRUE" *) output logic       o_done,
    (* IOB = "TRUE" *) output logic       o_success
);

  localparam int RANDOM_BYTES = 96;
  localparam logic [6:0] RANDOM_LAST = 7'(RANDOM_BYTES - 1);

  logic       rst_n_sync;
  logic       core_start_q;
  logic       core_random_valid;
  logic [7:0] core_random_data;
  logic       core_random_ready;
  logic       core_pk_valid;
  logic [7:0] core_pk_data;
  logic       core_pk_last;
  logic       core_pk_ready;
  logic       core_sk_valid;
  logic [7:0] core_sk_data;
  logic       core_sk_last;
  logic       core_sk_ready;
  logic       core_busy;
  logic       core_done;
  logic       core_success;
  logic       random_buffer_valid_q;
  logic [7:0] random_buffer_data_q;
  logic       random_complete_q;
  logic [6:0] random_count_q;
  logic       pk_buffer_valid_q;
  logic [7:0] pk_buffer_data_q;
  logic       pk_buffer_last_q;
  logic       sk_buffer_valid_q;
  logic [7:0] sk_buffer_data_q;
  logic       sk_buffer_last_q;

  reset_sync u_reset_sync (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .o_rst_n(rst_n_sync)
  );

  assign core_random_valid = random_buffer_valid_q;
  assign core_random_data  = random_buffer_data_q;
  assign core_pk_ready     = !pk_buffer_valid_q;
  assign core_sk_ready     = !sk_buffer_valid_q;

  always_ff @(posedge i_clk) begin
    if (!rst_n_sync) begin
      core_start_q          <= 1'b0;
      random_buffer_valid_q <= 1'b0;
      random_buffer_data_q  <= '0;
      random_complete_q     <= 1'b0;
      random_count_q        <= '0;
      pk_buffer_valid_q     <= 1'b0;
      pk_buffer_data_q      <= '0;
      pk_buffer_last_q      <= 1'b0;
      sk_buffer_valid_q     <= 1'b0;
      sk_buffer_data_q      <= '0;
      sk_buffer_last_q      <= 1'b0;
      o_random_ready        <= 1'b0;
      o_pk_valid            <= 1'b0;
      o_pk_data             <= '0;
      o_pk_last             <= 1'b0;
      o_sk_valid            <= 1'b0;
      o_sk_data             <= '0;
      o_sk_last             <= 1'b0;
      o_busy                <= 1'b0;
      o_done                <= 1'b0;
      o_success             <= 1'b0;
    end else begin
      core_start_q <= 1'b0;
      o_done <= 1'b0;
      o_busy <= core_busy || core_start_q || random_buffer_valid_q || pk_buffer_valid_q ||
          sk_buffer_valid_q || o_pk_valid || o_sk_valid || i_start;

      if (i_start && !core_busy && !random_buffer_valid_q && !pk_buffer_valid_q &&
          !sk_buffer_valid_q && !o_pk_valid && !o_sk_valid) begin
        core_start_q      <= 1'b1;
        random_complete_q <= 1'b0;
        random_count_q    <= '0;
        o_success         <= 1'b0;
      end else if (core_busy || core_done) begin
        o_success <= core_success;
      end

      if (random_buffer_valid_q) begin
        o_random_ready <= 1'b0;
        if (core_random_ready) begin
          random_buffer_valid_q <= 1'b0;
          if (!random_complete_q) o_random_ready <= 1'b1;
        end
      end else begin
        o_random_ready <= core_random_ready && !random_complete_q;
        if (o_random_ready && i_random_valid) begin
          random_buffer_valid_q <= 1'b1;
          random_buffer_data_q  <= i_random_data;
          o_random_ready        <= 1'b0;
          if (random_count_q == RANDOM_LAST) begin
            random_complete_q <= 1'b1;
          end else begin
            random_count_q <= random_count_q + 1'b1;
          end
        end
      end

      if (!pk_buffer_valid_q && core_pk_valid) begin
        pk_buffer_valid_q <= 1'b1;
        pk_buffer_data_q  <= core_pk_data;
        pk_buffer_last_q  <= core_pk_last;
      end
      if (!o_pk_valid && pk_buffer_valid_q) begin
        o_pk_valid        <= 1'b1;
        o_pk_data         <= pk_buffer_data_q;
        o_pk_last         <= pk_buffer_last_q;
        pk_buffer_valid_q <= 1'b0;
      end else if (o_pk_valid && i_pk_ready) begin
        o_pk_valid <= 1'b0;
      end

      if (!sk_buffer_valid_q && core_sk_valid) begin
        sk_buffer_valid_q <= 1'b1;
        sk_buffer_data_q  <= core_sk_data;
        sk_buffer_last_q  <= core_sk_last;
      end
      if (!o_sk_valid && sk_buffer_valid_q) begin
        o_sk_valid        <= 1'b1;
        o_sk_data         <= sk_buffer_data_q;
        o_sk_last         <= sk_buffer_last_q;
        sk_buffer_valid_q <= 1'b0;
      end else if (o_sk_valid && i_sk_ready) begin
        o_sk_valid <= 1'b0;
        if (o_sk_last) begin
          o_done <= 1'b1;
          o_busy <= 1'b0;
        end
      end
    end
  end

  trike_keygen_core #(
      .M_BYTES        (32),
      .R_BITS         (15581),
      .SECRET_WEIGHT  (35),
      .CANDIDATE_COUNT(16),
      .WORD_W         (64),
      .DIGIT_W        (16)
  ) u_keygen (
      .i_clk                      (i_clk),
      .i_rst_n                    (rst_n_sync),
      .i_start                    (core_start_q),
      .i_random_valid             (core_random_valid),
      .i_random_data              (core_random_data),
      .o_random_ready             (core_random_ready),
      .o_pk_valid                 (core_pk_valid),
      .o_pk_data                  (core_pk_data),
      .o_pk_last                  (core_pk_last),
      .i_pk_ready                 (core_pk_ready),
      .o_sk_valid                 (core_sk_valid),
      .o_sk_data                  (core_sk_data),
      .o_sk_last                  (core_sk_last),
      .i_sk_ready                 (core_sk_ready),
      .o_busy                     (core_busy),
      .o_done                     (core_done),
      .o_success                  (core_success),
      .o_compress_start           (),
      .o_compress_block           (),
      .o_compress_state           (),
      .i_compress_busy            (1'b0),
      .i_compress_done            (1'b0),
      .i_compress_state           ('0),
      .o_mul_start                (),
      .o_mul_runtime_r_bits       (),
      .o_mul_runtime_words        (),
      .o_mul_runtime_sparse_weight(),
      .o_mul_sparse_a             (),
      .o_mul_a_valid              (),
      .o_mul_a_data               (),
      .i_mul_a_ready              (1'b0),
      .o_mul_sparse_index_valid   (),
      .o_mul_sparse_index         (),
      .i_mul_sparse_index_ready   (1'b0),
      .o_mul_b_valid              (),
      .o_mul_b_data               (),
      .i_mul_b_ready              (1'b0),
      .i_mul_result_valid         (1'b0),
      .i_mul_result_data          ('0),
      .i_mul_result_last          (1'b0),
      .o_mul_result_ready         (),
      .i_mul_done                 (1'b0),
      .o_h123_start               (),
      .o_h123_seed_valid          (),
      .o_h123_seed_data           (),
      .i_h123_seed_ready          (1'b0),
      .i_h123_vector_valid        (1'b0),
      .i_h123_vector_select       ('0),
      .i_h123_vector_byte         ('0),
      .i_h123_vector_data         ('0),
      .o_h123_vector_ready        (),
      .i_h123_done                (1'b0),
      .o_h123_t1_re               (),
      .o_h123_t1_raddr            (),
      .i_h123_t1_rdata            ('0),
      .o_h123_t1_we               (),
      .o_h123_t1_waddr            (),
      .o_h123_t1_wdata            (),
      .o_h123_t2_re               (),
      .o_h123_t2_raddr            (),
      .i_h123_t2_rdata            ('0),
      .o_h123_r1_re               (),
      .o_h123_r1_raddr            (),
      .i_h123_r1_rdata            ('0),
      .o_sampler_start            (),
      .o_sampler_runtime_length   (),
      .o_sampler_runtime_weight   (),
      .o_sampler_v                (),
      .o_sampler_c                (),
      .o_sampler_reseed_counter   (),
      .i_sampler_index_valid      (1'b0),
      .i_sampler_index_position   ('0),
      .i_sampler_index            ('0),
      .o_sampler_index_ready      (),
      .i_sampler_done             (1'b0),
      .i_sampler_v                ('0),
      .i_sampler_c                ('0),
      .i_sampler_reseed_counter   ('0)
  );

endmodule
