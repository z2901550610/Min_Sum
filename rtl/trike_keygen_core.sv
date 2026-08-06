`timescale 1ns / 1ps

// Fixed-schedule TRIKE KeyGen core.
//
// Random input order is key_seed || sigma2 || sigma. The core runs the fixed
// secret-candidate sampler, H1/H2/H3 generation, polynomial arithmetic, and
// official PK/SK serialization. Secret sampling and H123 share one SM3 lane.
module trike_keygen_core #(
    parameter int M_BYTES = 32,
    parameter int R_BITS = 15581,
    parameter int SECRET_WEIGHT = 35,
    parameter int CANDIDATE_COUNT = 16,
    parameter int WORD_W = 64,
    parameter int DIGIT_W = 8,
    parameter int WORD_ADDR_W = ((((R_BITS + WORD_W - 1) / WORD_W) > 1) ? $clog2(
        (R_BITS + WORD_W - 1) / WORD_W
    ) : 1)
) (
    input  logic       i_clk,
    input  logic       i_rst_n,
    input  logic       i_start,
    input  logic       i_random_valid,
    input  logic [7:0] i_random_data,
    output logic       o_random_ready,
    output logic       o_pk_valid,
    output logic [7:0] o_pk_data,
    output logic       o_pk_last,
    input  logic       i_pk_ready,
    output logic       o_sk_valid,
    output logic [7:0] o_sk_data,
    output logic       o_sk_last,
    input  logic       i_sk_ready,
    output logic       o_busy,
    output logic       o_done,
    output logic       o_success
);

  localparam int R_BYTES = (R_BITS + 7) / 8;
  localparam int WORDS = (R_BITS + WORD_W - 1) / WORD_W;
  localparam int INDEX_W = (R_BITS > 1) ? $clog2(R_BITS) : 1;
  localparam int POSITION_W = (SECRET_WEIGHT > 1) ? $clog2(SECRET_WEIGHT) : 1;
  localparam int SUPPORT_COUNT = 3 * SECRET_WEIGHT;
  localparam int SUPPORT_ADDR_W = (SUPPORT_COUNT > 1) ? $clog2(SUPPORT_COUNT) : 1;

  typedef enum logic [4:0] {
    ST_IDLE,
    ST_LOAD_RANDOM,
    ST_START_SECRET,
    ST_WAIT_SECRET,
    ST_START_H123,
    ST_WAIT_H123,
    ST_START_ARITH,
    ST_WAIT_ARITH,
    ST_PK_R2_FETCH,
    ST_PK_R2_DATA,
    ST_PK_SIGMA,
    ST_SK_SUPPORT_FETCH,
    ST_SK_SUPPORT_DATA,
    ST_SK_H0,
    ST_SK_T0_FETCH,
    ST_SK_T0_DATA,
    ST_SK_R2_FETCH,
    ST_SK_R2_DATA,
    ST_SK_SIGMA,
    ST_SK_SIGMA2
  } state_t;

  state_t state_q;
  logic [7:0] key_seed_q[0:M_BYTES-1];
  logic [7:0] sigma_q[0:M_BYTES-1];
  logic [7:0] sigma2_q[0:M_BYTES-1];
  logic [INDEX_W-1:0] support_q[0:2][0:SECRET_WEIGHT-1];
  integer random_byte_q;
  integer seed_replay_byte_q;
  logic [WORD_W-1:0] h123_word_accum_q;
  integer poly_byte_q;
  integer sigma_byte_q;
  logic [SUPPORT_ADDR_W-1:0] support_output_addr_q;
  logic [1:0] support_output_byte_q;

  logic secret_start;
  logic secret_seed_ready;
  logic secret_support_valid;
  logic [1:0] secret_support_block;
  logic [POSITION_W-1:0] secret_support_position;
  logic [INDEX_W-1:0] secret_support_index;
  logic secret_support_ready;
  logic secret_done;
  logic secret_success;
  logic secret_compress_start;
  logic [511:0] secret_compress_block;
  logic [255:0] secret_compress_state;

  logic h123_start;
  logic h123_seed_ready;
  logic h123_vector_valid;
  logic [1:0] h123_vector_select;
  logic [((R_BYTES > 1) ? $clog2(R_BYTES) : 1)-1:0] h123_vector_byte;
  logic [7:0] h123_vector_data;
  logic h123_vector_ready;
  logic h123_done;
  logic h123_compress_start;
  logic [511:0] h123_compress_block;
  logic [255:0] h123_compress_state;

  logic arith_support_ready;
  logic arith_vector_valid;
  logic [1:0] arith_vector_select;
  logic [WORD_ADDR_W-1:0] arith_vector_word;
  logic [WORD_W-1:0] arith_vector_data;
  logic arith_vector_ready;
  logic arith_start;
  logic arith_result_valid;
  logic arith_result_select;
  logic [WORD_ADDR_W-1:0] arith_result_word;
  logic [WORD_W-1:0] arith_result_data;
  logic arith_done;

  logic select_h123_compress;
  logic shared_compress_start;
  logic [511:0] shared_compress_block;
  logic [255:0] shared_compress_state;
  logic shared_compress_busy;
  logic shared_compress_done;
  logic [255:0] shared_compress_result;

  logic t0_we;
  logic t0_re;
  logic [WORD_ADDR_W-1:0] t0_addr;
  logic [WORD_W-1:0] t0_rdata;
  logic r2_we;
  logic r2_re;
  logic [WORD_ADDR_W-1:0] r2_addr;
  logic [WORD_W-1:0] r2_rdata;
  logic support_output_we;
  logic support_output_re;
  logic [SUPPORT_ADDR_W-1:0] support_output_waddr;
  logic [31:0] support_output_rdata;

  logic h123_word_end_c;
  logic [WORD_W-1:0] h123_word_data_c;

  function automatic logic [7:0] support_dense_byte(input integer byte_index);
    logic   [7:0] value;
    integer       coefficient;
    begin
      value = '0;
      for (int position = 0; position < SECRET_WEIGHT; position++) begin
        coefficient = int'(support_q[0][position]);
        if ((coefficient / 8) == byte_index) value[coefficient%8] = 1'b1;
      end
      support_dense_byte = value;
    end
  endfunction

  assign o_random_ready = state_q == ST_LOAD_RANDOM;
  assign o_busy = state_q != ST_IDLE;

  assign secret_start = state_q == ST_START_SECRET;
  assign secret_support_ready = (state_q == ST_WAIT_SECRET) && arith_support_ready;
  assign h123_start = state_q == ST_START_H123;
  assign arith_start = state_q == ST_START_ARITH;

  always_comb begin
    h123_word_data_c = h123_word_accum_q;
    h123_word_data_c[8*(int'(h123_vector_byte)%8)+:8] = h123_vector_data;
    h123_word_end_c = (int'(h123_vector_byte) == (R_BYTES - 1)) ||
                      ((int'(h123_vector_byte) % 8) == 7);
  end

  assign arith_vector_valid = (state_q == ST_WAIT_H123) && h123_vector_valid && h123_word_end_c;
  assign arith_vector_select = h123_vector_select;
  assign arith_vector_word = WORD_ADDR_W'(int'(h123_vector_byte) / 8);
  assign arith_vector_data = h123_word_data_c;
  assign h123_vector_ready = (state_q == ST_WAIT_H123) && (!h123_word_end_c || arith_vector_ready);

  assign select_h123_compress = (state_q == ST_START_H123) || (state_q == ST_WAIT_H123);
  assign shared_compress_start = select_h123_compress ? h123_compress_start : secret_compress_start;
  assign shared_compress_block = select_h123_compress ? h123_compress_block : secret_compress_block;
  assign shared_compress_state = select_h123_compress ? h123_compress_state : secret_compress_state;

  /* verilator lint_off PINCONNECTEMPTY */
  trike_keygen_secret_sampler #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (R_BITS),
      .SECRET_WEIGHT        (SECRET_WEIGHT),
      .CANDIDATE_COUNT      (CANDIDATE_COUNT),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_secret_sampler (
      .i_clk               (i_clk),
      .i_rst_n             (i_rst_n),
      .i_start             (secret_start),
      .i_seed_valid        (state_q == ST_WAIT_SECRET),
      .i_seed_data         (key_seed_q[seed_replay_byte_q]),
      .o_seed_ready        (secret_seed_ready),
      .o_seed_pass         (),
      .o_support_valid     (secret_support_valid),
      .o_support_block     (secret_support_block),
      .o_support_position  (secret_support_position),
      .o_support_index     (secret_support_index),
      .i_support_ready     (secret_support_ready),
      .o_busy              (),
      .o_done              (secret_done),
      .o_success           (secret_success),
      .o_selected_candidate(),
      .o_selected_scores   (),
      .o_v                 (),
      .o_c                 (),
      .o_reseed_counter    (),
      .o_compress_start    (secret_compress_start),
      .o_compress_block    (secret_compress_block),
      .o_compress_state    (secret_compress_state),
      .i_compress_busy     (shared_compress_busy),
      .i_compress_done     (shared_compress_done),
      .i_compress_state    (shared_compress_result)
  );

  trike_h123_vectors #(
      .M_BYTES              (M_BYTES),
      .R_BITS               (R_BITS),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_h123 (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (h123_start),
      .i_seed_valid    (state_q == ST_WAIT_H123),
      .i_seed_data     (sigma_q[seed_replay_byte_q]),
      .o_seed_ready    (h123_seed_ready),
      .o_seed_pass     (),
      .o_vector_valid  (h123_vector_valid),
      .o_vector_select (h123_vector_select),
      .o_vector_byte   (h123_vector_byte),
      .o_vector_data   (h123_vector_data),
      .i_vector_ready  (h123_vector_ready),
      .o_busy          (),
      .o_done          (h123_done),
      .o_v             (),
      .o_c             (),
      .o_reseed_counter(),
      .o_compress_start(h123_compress_start),
      .o_compress_block(h123_compress_block),
      .o_compress_state(h123_compress_state),
      .i_compress_busy (shared_compress_busy),
      .i_compress_done (shared_compress_done),
      .i_compress_state(shared_compress_result)
  );

  trike_keygen_arith_core #(
      .R_BITS       (R_BITS),
      .SECRET_WEIGHT(SECRET_WEIGHT),
      .WORD_W       (WORD_W),
      .DIGIT_W      (DIGIT_W)
  ) u_arith (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_support_valid   (secret_support_valid && secret_support_ready),
      .i_support_block   (secret_support_block),
      .i_support_position(secret_support_position),
      .i_support_index   (secret_support_index),
      .o_support_ready   (arith_support_ready),
      .i_vector_valid    (arith_vector_valid),
      .i_vector_select   (arith_vector_select),
      .i_vector_word     (arith_vector_word),
      .i_vector_data     (arith_vector_data),
      .o_vector_ready    (arith_vector_ready),
      .i_start           (arith_start),
      .o_result_valid    (arith_result_valid),
      .o_result_select   (arith_result_select),
      .o_result_word     (arith_result_word),
      .o_result_data     (arith_result_data),
      .o_result_last     (),
      .i_result_ready    (1'b1),
      .o_busy            (),
      .o_done            (arith_done)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  trike_sm3_service u_sm3_service (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .i_start(shared_compress_start),
      .i_block(shared_compress_block),
      .i_state(shared_compress_state),
      .o_busy (shared_compress_busy),
      .o_done (shared_compress_done),
      .o_state(shared_compress_result)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_t0_output_mem (
      .i_clk  (i_clk),
      .i_we   (t0_we),
      .i_waddr(t0_addr),
      .i_wdata(arith_result_data),
      .i_re   (t0_re),
      .i_raddr(t0_addr),
      .o_rdata(t0_rdata)
  );

  ram_bram #(
      .DATA_W(WORD_W),
      .DEPTH (WORDS)
  ) u_r2_output_mem (
      .i_clk  (i_clk),
      .i_we   (r2_we),
      .i_waddr(r2_addr),
      .i_wdata(arith_result_data),
      .i_re   (r2_re),
      .i_raddr(r2_addr),
      .o_rdata(r2_rdata)
  );

  assign support_output_we = secret_support_valid && secret_support_ready;
  assign support_output_re = state_q == ST_SK_SUPPORT_FETCH;
  assign support_output_waddr = SUPPORT_ADDR_W'(secret_support_position) +
      ((secret_support_block == 2'd1) ? SUPPORT_ADDR_W'(SECRET_WEIGHT) :
       (secret_support_block == 2'd2) ? SUPPORT_ADDR_W'(2 * SECRET_WEIGHT) : '0);

  ram_bram #(
      .DATA_W(32),
      .DEPTH (SUPPORT_COUNT)
  ) u_support_output_mem (
      .i_clk  (i_clk),
      .i_we   (support_output_we),
      .i_waddr(support_output_waddr),
      .i_wdata(32'(secret_support_index)),
      .i_re   (support_output_re),
      .i_raddr(support_output_addr_q),
      .o_rdata(support_output_rdata)
  );

  always_comb begin
    t0_we = arith_result_valid && !arith_result_select;
    t0_re = state_q == ST_SK_T0_FETCH;
    t0_addr = t0_we ? arith_result_word : WORD_ADDR_W'(poly_byte_q / (WORD_W / 8));
    r2_we = arith_result_valid && arith_result_select;
    r2_re = (state_q == ST_PK_R2_FETCH) || (state_q == ST_SK_R2_FETCH);
    r2_addr = r2_we ? arith_result_word : WORD_ADDR_W'(poly_byte_q / (WORD_W / 8));

    o_pk_valid = 1'b0;
    o_pk_data = '0;
    o_pk_last = 1'b0;
    if (state_q == ST_PK_R2_DATA) begin
      o_pk_valid = 1'b1;
      o_pk_data  = r2_rdata[8*(poly_byte_q%(WORD_W/8))+:8];
    end else if (state_q == ST_PK_SIGMA) begin
      o_pk_valid = 1'b1;
      o_pk_data  = sigma_q[sigma_byte_q];
      o_pk_last  = sigma_byte_q == (M_BYTES - 1);
    end

    o_sk_valid = 1'b0;
    o_sk_data  = '0;
    o_sk_last  = 1'b0;
    unique case (state_q)
      ST_SK_SUPPORT_DATA: begin
        o_sk_valid = 1'b1;
        o_sk_data  = support_output_rdata[8*support_output_byte_q+:8];
      end
      ST_SK_H0: begin
        o_sk_valid = 1'b1;
        o_sk_data  = support_dense_byte(poly_byte_q);
      end
      ST_SK_T0_DATA: begin
        o_sk_valid = 1'b1;
        o_sk_data  = t0_rdata[8*(poly_byte_q%(WORD_W/8))+:8];
      end
      ST_SK_R2_DATA: begin
        o_sk_valid = 1'b1;
        o_sk_data  = r2_rdata[8*(poly_byte_q%(WORD_W/8))+:8];
      end
      ST_SK_SIGMA: begin
        o_sk_valid = 1'b1;
        o_sk_data  = sigma_q[sigma_byte_q];
      end
      ST_SK_SIGMA2: begin
        o_sk_valid = 1'b1;
        o_sk_data  = sigma2_q[sigma_byte_q];
        o_sk_last  = sigma_byte_q == (M_BYTES - 1);
      end
      default: begin
      end
    endcase
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      random_byte_q <= 0;
      seed_replay_byte_q <= 0;
      h123_word_accum_q <= '0;
      poly_byte_q <= 0;
      sigma_byte_q <= 0;
      support_output_addr_q <= '0;
      support_output_byte_q <= '0;
      o_done <= 1'b0;
      o_success <= 1'b0;
      for (int byte_index = 0; byte_index < M_BYTES; byte_index++) begin
        key_seed_q[byte_index] <= '0;
        sigma_q[byte_index] <= '0;
        sigma2_q[byte_index] <= '0;
      end
      for (int block = 0; block < 3; block++) begin
        for (int position = 0; position < SECRET_WEIGHT; position++) begin
          support_q[block][position] <= '0;
        end
      end
    end else begin
      o_done <= 1'b0;

      if (secret_support_valid && secret_support_ready) begin
        support_q[secret_support_block][secret_support_position] <= secret_support_index;
      end

      if ((state_q == ST_WAIT_H123) && h123_vector_valid && h123_vector_ready) begin
        if (h123_word_end_c) begin
          h123_word_accum_q <= '0;
        end else begin
          h123_word_accum_q <= h123_word_data_c;
        end
      end

      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            random_byte_q <= 0;
            o_success <= 1'b0;
            state_q <= ST_LOAD_RANDOM;
          end
        end

        ST_LOAD_RANDOM: begin
          if (i_random_valid) begin
            if (random_byte_q < M_BYTES) begin
              key_seed_q[random_byte_q] <= i_random_data;
            end else if (random_byte_q < (2 * M_BYTES)) begin
              sigma2_q[random_byte_q-M_BYTES] <= i_random_data;
            end else begin
              sigma_q[random_byte_q-(2*M_BYTES)] <= i_random_data;
            end
            if (random_byte_q == (3 * M_BYTES - 1)) begin
              seed_replay_byte_q <= 0;
              state_q <= ST_START_SECRET;
            end else begin
              random_byte_q <= random_byte_q + 1;
            end
          end
        end

        ST_START_SECRET: begin
          seed_replay_byte_q <= 0;
          state_q <= ST_WAIT_SECRET;
        end

        ST_WAIT_SECRET: begin
          if (secret_seed_ready) begin
            if (seed_replay_byte_q == (M_BYTES - 1)) begin
              seed_replay_byte_q <= 0;
            end else begin
              seed_replay_byte_q <= seed_replay_byte_q + 1;
            end
          end
          if (secret_done) begin
            o_success <= secret_success;
            seed_replay_byte_q <= 0;
            state_q <= ST_START_H123;
          end
        end

        ST_START_H123: begin
          seed_replay_byte_q <= 0;
          h123_word_accum_q <= '0;
          state_q <= ST_WAIT_H123;
        end

        ST_WAIT_H123: begin
          if (h123_seed_ready) begin
            if (seed_replay_byte_q == (M_BYTES - 1)) begin
              seed_replay_byte_q <= 0;
            end else begin
              seed_replay_byte_q <= seed_replay_byte_q + 1;
            end
          end
          if (h123_done) state_q <= ST_START_ARITH;
        end

        ST_START_ARITH: begin
          state_q <= ST_WAIT_ARITH;
        end

        ST_WAIT_ARITH: begin
          if (arith_done) begin
            poly_byte_q <= 0;
            state_q <= ST_PK_R2_FETCH;
          end
        end

        ST_PK_R2_FETCH: begin
          state_q <= ST_PK_R2_DATA;
        end

        ST_PK_R2_DATA: begin
          if (i_pk_ready) begin
            if (poly_byte_q == (R_BYTES - 1)) begin
              sigma_byte_q <= 0;
              state_q <= ST_PK_SIGMA;
            end else begin
              poly_byte_q <= poly_byte_q + 1;
              if ((poly_byte_q % (WORD_W / 8)) == ((WORD_W / 8) - 1)) begin
                state_q <= ST_PK_R2_FETCH;
              end
            end
          end
        end

        ST_PK_SIGMA: begin
          if (i_pk_ready) begin
            if (sigma_byte_q == (M_BYTES - 1)) begin
              support_output_addr_q <= '0;
              support_output_byte_q <= '0;
              state_q <= ST_SK_SUPPORT_FETCH;
            end else begin
              sigma_byte_q <= sigma_byte_q + 1;
            end
          end
        end

        ST_SK_SUPPORT_FETCH: begin
          state_q <= ST_SK_SUPPORT_DATA;
        end

        ST_SK_SUPPORT_DATA: begin
          if (i_sk_ready) begin
            if (support_output_byte_q == 2'd3) begin
              support_output_byte_q <= '0;
              if (support_output_addr_q == SUPPORT_ADDR_W'(SUPPORT_COUNT - 1)) begin
                poly_byte_q <= 0;
                state_q <= ST_SK_H0;
              end else begin
                support_output_addr_q <= support_output_addr_q + 1'b1;
                state_q <= ST_SK_SUPPORT_FETCH;
              end
            end else begin
              support_output_byte_q <= support_output_byte_q + 1'b1;
            end
          end
        end

        ST_SK_H0: begin
          if (i_sk_ready) begin
            if (poly_byte_q == (R_BYTES - 1)) begin
              poly_byte_q <= 0;
              state_q <= ST_SK_T0_FETCH;
            end else begin
              poly_byte_q <= poly_byte_q + 1;
            end
          end
        end

        ST_SK_T0_FETCH: begin
          state_q <= ST_SK_T0_DATA;
        end

        ST_SK_T0_DATA: begin
          if (i_sk_ready) begin
            if (poly_byte_q == (R_BYTES - 1)) begin
              poly_byte_q <= 0;
              state_q <= ST_SK_R2_FETCH;
            end else begin
              poly_byte_q <= poly_byte_q + 1;
              if ((poly_byte_q % (WORD_W / 8)) == ((WORD_W / 8) - 1)) begin
                state_q <= ST_SK_T0_FETCH;
              end
            end
          end
        end

        ST_SK_R2_FETCH: begin
          state_q <= ST_SK_R2_DATA;
        end

        ST_SK_R2_DATA: begin
          if (i_sk_ready) begin
            if (poly_byte_q == (R_BYTES - 1)) begin
              sigma_byte_q <= 0;
              state_q <= ST_SK_SIGMA;
            end else begin
              poly_byte_q <= poly_byte_q + 1;
              if ((poly_byte_q % (WORD_W / 8)) == ((WORD_W / 8) - 1)) begin
                state_q <= ST_SK_R2_FETCH;
              end
            end
          end
        end

        ST_SK_SIGMA: begin
          if (i_sk_ready) begin
            if (sigma_byte_q == (M_BYTES - 1)) begin
              sigma_byte_q <= 0;
              state_q <= ST_SK_SIGMA2;
            end else begin
              sigma_byte_q <= sigma_byte_q + 1;
            end
          end
        end

        ST_SK_SIGMA2: begin
          if (i_sk_ready) begin
            if (sigma_byte_q == (M_BYTES - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              sigma_byte_q <= sigma_byte_q + 1;
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
    if (WORD_W % 8 != 0) $error("trike_keygen_core WORD_W must be byte aligned");
    if (M_BYTES < 1) $error("trike_keygen_core M_BYTES must be at least 1");
  end
`endif

endmodule
