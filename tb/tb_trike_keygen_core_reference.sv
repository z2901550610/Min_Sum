`timescale 1ns / 1ps

module tb_trike_keygen_core_reference #(
    parameter bit ALT_CASE              = 1'b0,
    parameter bit USE_SYNTH_TOP         = 1'b0,
    parameter bit USE_SHARED_SM3        = 1'b0,
    parameter bit USE_SHARED_MUL        = 1'b0,
    parameter bit USE_SHARED_H123       = 1'b0,
    parameter bit USE_SHARED_SAMPLER    = 1'b0,
    parameter bit USE_SHARED_H123_STORE = 1'b0
);

  `include "generated/trike_keygen_reference_case.svh"

  localparam int EXPECTED_BUSY_CYCLES = 53995036;
  localparam int EXPECTED_SYNTH_BUSY_CYCLES = 54002607;
  localparam int MAX_R_BITS = 106781;
  localparam int MUL_INDEX_W = $clog2(MAX_R_BITS);
  localparam int H123_WORD_ADDR_W = $clog2((REF_R_BITS + 63) / 64);

  logic                        clk;
  logic                        rst_n;
  logic                        start;
  logic                        random_valid;
  logic [                 7:0] random_data;
  logic                        random_ready;
  logic                        pk_valid;
  logic [                 7:0] pk_data;
  logic                        pk_last;
  logic                        pk_ready;
  logic                        sk_valid;
  logic [                 7:0] sk_data;
  logic                        sk_last;
  logic                        sk_ready;
  logic                        busy;
  logic                        done;
  logic                        success;
  /* verilator lint_off UNUSEDSIGNAL */
  logic                        compress_start;
  logic [               511:0] compress_block;
  logic [               255:0] compress_input_state;
  logic                        compress_busy;
  logic                        compress_done;
  logic [               255:0] compress_output_state;
  logic                        selected_compress_start;
  logic [               511:0] selected_compress_block;
  logic [               255:0] selected_compress_state;
  logic                        mul_start;
  logic [                31:0] mul_runtime_r_bits;
  logic [                31:0] mul_runtime_words;
  logic [                31:0] mul_runtime_sparse_weight;
  logic                        mul_sparse_a;
  logic                        mul_a_valid;
  logic [                63:0] mul_a_data;
  logic                        mul_a_ready;
  logic                        mul_sparse_index_valid;
  logic [     MUL_INDEX_W-1:0] mul_sparse_index;
  logic                        mul_sparse_index_ready;
  logic                        mul_b_valid;
  logic [                63:0] mul_b_data;
  logic                        mul_b_ready;
  logic                        mul_result_valid;
  logic [                63:0] mul_result_data;
  logic                        mul_result_last;
  logic                        mul_result_ready;
  logic                        mul_done;
  logic                        h123_start;
  logic                        h123_seed_valid;
  logic [                 7:0] h123_seed_data;
  logic                        h123_seed_ready;
  logic                        h123_vector_valid;
  logic [                 1:0] h123_vector_select;
  logic [                10:0] h123_vector_byte;
  logic [                 7:0] h123_vector_data;
  logic                        h123_vector_ready;
  logic                        h123_done;
  logic                        h123_busy;
  logic                        h123_compress_start;
  logic [               511:0] h123_compress_block;
  logic [               255:0] h123_compress_state;
  logic                        h123_store_vector_ready;
  logic                        h123_t1_re;
  logic [H123_WORD_ADDR_W-1:0] h123_t1_raddr;
  logic [                63:0] h123_t1_rdata;
  logic                        h123_t1_we;
  logic [H123_WORD_ADDR_W-1:0] h123_t1_waddr;
  logic [                63:0] h123_t1_wdata;
  logic                        h123_t2_re;
  logic [H123_WORD_ADDR_W-1:0] h123_t2_raddr;
  logic [                63:0] h123_t2_rdata;
  logic                        h123_r1_re;
  logic [H123_WORD_ADDR_W-1:0] h123_r1_raddr;
  logic [                63:0] h123_r1_rdata;
  logic                        sampler_start;
  logic [                31:0] sampler_length;
  logic [                31:0] sampler_weight;
  logic [               439:0] sampler_input_v;
  logic [               439:0] sampler_input_c;
  logic [               439:0] sampler_input_reseed_counter;
  logic                        sampler_index_valid;
  logic [                 5:0] sampler_index_position;
  logic [                13:0] sampler_index;
  logic                        sampler_index_ready;
  logic                        sampler_busy;
  logic                        sampler_done;
  logic [               439:0] sampler_output_v;
  logic [               439:0] sampler_output_c;
  logic [               439:0] sampler_output_reseed_counter;
  logic                        sampler_compress_start;
  logic [               511:0] sampler_compress_block;
  logic [               255:0] sampler_compress_state;
  /* verilator lint_on UNUSEDSIGNAL */

  int                          random_count;
  int                          pk_count;
  int                          sk_count;
  int                          busy_cycles;

  always_comb begin
    if (random_count < 32) begin
      random_data = ALT_CASE ? REF_ALT_KEY_SEED[random_count] : REF_KEY_SEED[random_count];
    end else if (random_count < 64) begin
      random_data = REF_SIGMA2[random_count-32];
    end else begin
      random_data = REF_SIGMA[random_count-64];
    end
  end

  generate
    if (USE_SYNTH_TOP) begin : g_synth_top
      trike_keygen_synth_top dut (
          .i_clk         (clk),
          .i_rst_n       (rst_n),
          .i_start       (start),
          .i_random_valid(random_valid),
          .i_random_data (random_data),
          .o_random_ready(random_ready),
          .o_pk_valid    (pk_valid),
          .o_pk_data     (pk_data),
          .o_pk_last     (pk_last),
          .i_pk_ready    (pk_ready),
          .o_sk_valid    (sk_valid),
          .o_sk_data     (sk_data),
          .o_sk_last     (sk_last),
          .i_sk_ready    (sk_ready),
          .o_busy        (busy),
          .o_done        (done),
          .o_success     (success)
      );
    end else begin : g_core
      trike_keygen_core #(
          .M_BYTES                (32),
          .R_BITS                 (REF_R_BITS),
          .SECRET_WEIGHT          (REF_SECRET_WEIGHT),
          .CANDIDATE_COUNT        (REF_CANDIDATE_COUNT),
          .WORD_W                 (64),
          .DIGIT_W                (16),
          .USE_EXTERNAL_COMPRESS  (USE_SHARED_SM3),
          .USE_EXTERNAL_MUL       (USE_SHARED_MUL),
          .USE_EXTERNAL_H123      (USE_SHARED_H123),
          .USE_EXTERNAL_SAMPLER   (USE_SHARED_SAMPLER),
          .USE_EXTERNAL_H123_STORE(USE_SHARED_H123_STORE),
          .MUL_INDEX_W            (MUL_INDEX_W)
      ) dut (
          .i_clk                      (clk),
          .i_rst_n                    (rst_n),
          .i_start                    (start),
          .i_random_valid             (random_valid),
          .i_random_data              (random_data),
          .o_random_ready             (random_ready),
          .o_pk_valid                 (pk_valid),
          .o_pk_data                  (pk_data),
          .o_pk_last                  (pk_last),
          .i_pk_ready                 (pk_ready),
          .o_sk_valid                 (sk_valid),
          .o_sk_data                  (sk_data),
          .o_sk_last                  (sk_last),
          .i_sk_ready                 (sk_ready),
          .o_busy                     (busy),
          .o_done                     (done),
          .o_success                  (success),
          .o_compress_start           (compress_start),
          .o_compress_block           (compress_block),
          .o_compress_state           (compress_input_state),
          .i_compress_busy            (compress_busy),
          .i_compress_done            (compress_done),
          .i_compress_state           (compress_output_state),
          .o_mul_start                (mul_start),
          .o_mul_runtime_r_bits       (mul_runtime_r_bits),
          .o_mul_runtime_words        (mul_runtime_words),
          .o_mul_runtime_sparse_weight(mul_runtime_sparse_weight),
          .o_mul_sparse_a             (mul_sparse_a),
          .o_mul_a_valid              (mul_a_valid),
          .o_mul_a_data               (mul_a_data),
          .i_mul_a_ready              (mul_a_ready),
          .o_mul_sparse_index_valid   (mul_sparse_index_valid),
          .o_mul_sparse_index         (mul_sparse_index),
          .i_mul_sparse_index_ready   (mul_sparse_index_ready),
          .o_mul_b_valid              (mul_b_valid),
          .o_mul_b_data               (mul_b_data),
          .i_mul_b_ready              (mul_b_ready),
          .i_mul_result_valid         (mul_result_valid),
          .i_mul_result_data          (mul_result_data),
          .i_mul_result_last          (mul_result_last),
          .o_mul_result_ready         (mul_result_ready),
          .i_mul_done                 (mul_done),
          .o_h123_start               (h123_start),
          .o_h123_seed_valid          (h123_seed_valid),
          .o_h123_seed_data           (h123_seed_data),
          .i_h123_seed_ready          (h123_seed_ready),
          .i_h123_vector_valid        (h123_vector_valid),
          .i_h123_vector_select       (h123_vector_select),
          .i_h123_vector_byte         (h123_vector_byte),
          .i_h123_vector_data         (h123_vector_data),
          .o_h123_vector_ready        (h123_vector_ready),
          .i_h123_done                (h123_done),
          .o_h123_t1_re               (h123_t1_re),
          .o_h123_t1_raddr            (h123_t1_raddr),
          .i_h123_t1_rdata            (h123_t1_rdata),
          .o_h123_t1_we               (h123_t1_we),
          .o_h123_t1_waddr            (h123_t1_waddr),
          .o_h123_t1_wdata            (h123_t1_wdata),
          .o_h123_t2_re               (h123_t2_re),
          .o_h123_t2_raddr            (h123_t2_raddr),
          .i_h123_t2_rdata            (h123_t2_rdata),
          .o_h123_r1_re               (h123_r1_re),
          .o_h123_r1_raddr            (h123_r1_raddr),
          .i_h123_r1_rdata            (h123_r1_rdata),
          .o_sampler_start            (sampler_start),
          .o_sampler_runtime_length   (sampler_length),
          .o_sampler_runtime_weight   (sampler_weight),
          .o_sampler_v                (sampler_input_v),
          .o_sampler_c                (sampler_input_c),
          .o_sampler_reseed_counter   (sampler_input_reseed_counter),
          .i_sampler_index_valid      (sampler_index_valid),
          .i_sampler_index_position   (sampler_index_position),
          .i_sampler_index            (sampler_index),
          .o_sampler_index_ready      (sampler_index_ready),
          .i_sampler_done             (sampler_done),
          .i_sampler_v                (sampler_output_v),
          .i_sampler_c                (sampler_output_c),
          .i_sampler_reseed_counter   (sampler_output_reseed_counter)
      );

      always_comb begin
        selected_compress_start = compress_start;
        selected_compress_block = compress_block;
        selected_compress_state = compress_input_state;
        if (h123_busy || h123_start) begin
          selected_compress_start = h123_compress_start;
          selected_compress_block = h123_compress_block;
          selected_compress_state = h123_compress_state;
        end
        if (sampler_busy || sampler_start) begin
          selected_compress_start = sampler_compress_start;
          selected_compress_block = sampler_compress_block;
          selected_compress_state = sampler_compress_state;
        end
      end

      if (USE_SHARED_SM3) begin : g_shared_sm3
        trike_sm3_service u_sm3_service (
            .i_clk  (clk),
            .i_rst_n(rst_n),
            .i_start(selected_compress_start),
            .i_block(selected_compress_block),
            .i_state(selected_compress_state),
            .o_busy (compress_busy),
            .o_done (compress_done),
            .o_state(compress_output_state)
        );
      end else begin : g_local_sm3
        assign compress_busy = 1'b0;
        assign compress_done = 1'b0;
        assign compress_output_state = '0;
      end

      if (USE_SHARED_H123) begin : g_shared_h123
        trike_h123_vectors #(
            .M_BYTES              (32),
            .R_BITS               (REF_R_BITS),
            .USE_EXTERNAL_COMPRESS(1'b1)
        ) u_h123_service (
            .i_clk           (clk),
            .i_rst_n         (rst_n),
            .i_start         (h123_start),
            .i_seed_valid    (h123_seed_valid),
            .i_seed_data     (h123_seed_data),
            .o_seed_ready    (h123_seed_ready),
            .o_seed_pass     (),
            .o_vector_valid  (h123_vector_valid),
            .o_vector_select (h123_vector_select),
            .o_vector_byte   (h123_vector_byte),
            .o_vector_data   (h123_vector_data),
            .i_vector_ready  (h123_vector_ready && h123_store_vector_ready),
            .o_busy          (h123_busy),
            .o_done          (h123_done),
            .o_v             (),
            .o_c             (),
            .o_reseed_counter(),
            .o_compress_start(h123_compress_start),
            .o_compress_block(h123_compress_block),
            .o_compress_state(h123_compress_state),
            .i_compress_busy (compress_busy),
            .i_compress_done (compress_done),
            .i_compress_state(compress_output_state)
        );
      end else begin : g_local_h123
        assign h123_seed_ready = 1'b0;
        assign h123_vector_valid = 1'b0;
        assign h123_vector_select = '0;
        assign h123_vector_byte = '0;
        assign h123_vector_data = '0;
        assign h123_done = 1'b0;
        assign h123_busy = 1'b0;
        assign h123_compress_start = 1'b0;
        assign h123_compress_block = '0;
        assign h123_compress_state = '0;
      end

      if (USE_SHARED_H123_STORE) begin : g_shared_h123_store
        trike_h123_vector_store #(
            .R_BITS(REF_R_BITS),
            .WORD_W(64)
        ) u_h123_store_service (
            .i_clk          (clk),
            .i_rst_n        (rst_n),
            .i_vector_valid (h123_vector_valid && h123_vector_ready),
            .i_vector_select(h123_vector_select),
            .i_vector_byte  (h123_vector_byte),
            .i_vector_data  (h123_vector_data),
            .o_vector_ready (h123_store_vector_ready),
            .i_t1_re        (h123_t1_re),
            .i_t1_raddr     (h123_t1_raddr),
            .o_t1_rdata     (h123_t1_rdata),
            .i_t1_we        (h123_t1_we),
            .i_t1_waddr     (h123_t1_waddr),
            .i_t1_wdata     (h123_t1_wdata),
            .i_t2_re        (h123_t2_re),
            .i_t2_raddr     (h123_t2_raddr),
            .o_t2_rdata     (h123_t2_rdata),
            .i_r1_re        (h123_r1_re),
            .i_r1_raddr     (h123_r1_raddr),
            .o_r1_rdata     (h123_r1_rdata)
        );
      end else begin : g_local_h123_store
        assign h123_store_vector_ready = 1'b1;
        assign h123_t1_rdata = '0;
        assign h123_t2_rdata = '0;
        assign h123_r1_rdata = '0;
      end

      if (USE_SHARED_SAMPLER) begin : g_shared_sampler
        trike_drng_weight_sampler #(
            .LENGTH               (REF_R_BITS),
            .WEIGHT               (REF_SECRET_WEIGHT),
            .RUNTIME_GEOMETRY     (1'b1),
            .USE_EXTERNAL_COMPRESS(1'b1)
        ) u_sampler_service (
            .i_clk           (clk),
            .i_rst_n         (rst_n),
            .i_start         (sampler_start),
            .i_runtime_length(sampler_length),
            .i_runtime_weight(sampler_weight),
            .i_v             (sampler_input_v),
            .i_c             (sampler_input_c),
            .i_reseed_counter(sampler_input_reseed_counter),
            .o_index_valid   (sampler_index_valid),
            .o_index_position(sampler_index_position),
            .o_index         (sampler_index),
            .i_index_ready   (sampler_index_ready),
            .o_busy          (sampler_busy),
            .o_done          (sampler_done),
            .o_v             (sampler_output_v),
            .o_c             (sampler_output_c),
            .o_reseed_counter(sampler_output_reseed_counter),
            .o_compress_start(sampler_compress_start),
            .o_compress_block(sampler_compress_block),
            .o_compress_state(sampler_compress_state),
            .i_compress_busy (compress_busy),
            .i_compress_done (compress_done),
            .i_compress_state(compress_output_state)
        );
      end else begin : g_local_sampler
        assign sampler_index_valid = 1'b0;
        assign sampler_index_position = '0;
        assign sampler_index = '0;
        assign sampler_busy = 1'b0;
        assign sampler_done = 1'b0;
        assign sampler_output_v = '0;
        assign sampler_output_c = '0;
        assign sampler_output_reseed_counter = '0;
        assign sampler_compress_start = 1'b0;
        assign sampler_compress_block = '0;
        assign sampler_compress_state = '0;
      end

      if (USE_SHARED_MUL) begin : g_shared_mul
        trike_poly_mul_core #(
            .R_BITS          (MAX_R_BITS),
            .WORD_W          (64),
            .DIGIT_W         (16),
            .SPARSE_WEIGHT   (263),
            .RUNTIME_GEOMETRY(1'b1)
        ) u_mul_service (
            .i_clk                  (clk),
            .i_rst_n                (rst_n),
            .i_start                (mul_start),
            .i_runtime_r_bits       (mul_runtime_r_bits),
            .i_runtime_words        (mul_runtime_words),
            .i_runtime_sparse_weight(mul_runtime_sparse_weight),
            .i_sparse_a             (mul_sparse_a),
            .i_a_valid              (mul_a_valid),
            .i_a_data               (mul_a_data),
            .o_a_ready              (mul_a_ready),
            .i_sparse_index_valid   (mul_sparse_index_valid),
            .i_sparse_index         (mul_sparse_index),
            .o_sparse_index_ready   (mul_sparse_index_ready),
            .i_b_valid              (mul_b_valid),
            .i_b_data               (mul_b_data),
            .o_b_ready              (mul_b_ready),
            .o_result_valid         (mul_result_valid),
            .o_result_data          (mul_result_data),
            .o_result_last          (mul_result_last),
            .i_result_ready         (mul_result_ready),
            .o_ext_a_re             (),
            .o_ext_a_raddr          (),
            .i_ext_a_rdata          ('0),
            .o_ext_b_re             (),
            .o_ext_b_raddr          (),
            .i_ext_b_rdata          ('0),
            .o_ext_result_we        (),
            .o_ext_result_waddr     (),
            .o_ext_result_wdata     (),
            .o_busy                 (),
            .o_done                 (mul_done)
        );
      end else begin : g_local_mul
        assign mul_a_ready = 1'b0;
        assign mul_sparse_index_ready = 1'b0;
        assign mul_b_ready = 1'b0;
        assign mul_result_valid = 1'b0;
        assign mul_result_data = '0;
        assign mul_result_last = 1'b0;
        assign mul_done = 1'b0;
      end
    end
  endgenerate

  initial clk = 1'b0;
  always #5 clk = ~clk;

  always_ff @(posedge clk) begin
    if (!rst_n || start) begin
      busy_cycles <= 0;
    end else if (busy) begin
      busy_cycles <= busy_cycles + 1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pk_count <= 0;
      sk_count <= 0;
    end else begin
      if (pk_valid && pk_ready) begin
        if (pk_count >= REF_PK_BYTES) $fatal(1, "too many public-key bytes");
        if ((!ALT_CASE && (pk_data != REF_PUBLIC_KEY[pk_count])) ||
            (ALT_CASE && (pk_data != REF_ALT_PUBLIC_KEY[pk_count]))) begin
          $fatal(1, "PK byte %0d mismatch got=%02h expected=%02h", pk_count, pk_data,
                 ALT_CASE ? REF_ALT_PUBLIC_KEY[pk_count] : REF_PUBLIC_KEY[pk_count]);
        end
        if (pk_last != (pk_count == (REF_PK_BYTES - 1))) begin
          $fatal(1, "PK last mismatch byte=%0d", pk_count);
        end
        pk_count <= pk_count + 1;
      end
      if (sk_valid && sk_ready) begin
        if (sk_count >= REF_SK_BYTES) $fatal(1, "too many secret-key bytes");
        if ((!ALT_CASE && (sk_data != REF_SECRET_KEY[sk_count])) ||
            (ALT_CASE && (sk_data != REF_ALT_SECRET_KEY[sk_count]))) begin
          $fatal(1, "SK byte %0d mismatch got=%02h expected=%02h", sk_count, sk_data,
                 ALT_CASE ? REF_ALT_SECRET_KEY[sk_count] : REF_SECRET_KEY[sk_count]);
        end
        if (sk_last != (sk_count == (REF_SK_BYTES - 1))) begin
          $fatal(1, "SK last mismatch byte=%0d", sk_count);
        end
        sk_count <= sk_count + 1;
      end
    end
  end

  initial begin
    rst_n = 1'b0;
    start = 1'b0;
    random_valid = 1'b0;
    pk_ready = 1'b1;
    sk_ready = 1'b1;
    random_count = 0;

    repeat (4) @(negedge clk);
    rst_n = 1'b1;
    if (USE_SYNTH_TOP) repeat (3) @(negedge clk);
    @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;
    random_valid = 1'b1;

    while (random_count < 96) begin
      @(posedge clk);
      if (random_valid && random_ready) begin
        @(negedge clk);
        random_count++;
      end
    end
    random_valid = 1'b0;

    wait (done);
    #1;
    if (!success) $fatal(1, "official KeyGen returned failure");
    if (pk_count != REF_PK_BYTES) begin
      $fatal(1, "PK length mismatch got=%0d expected=%0d", pk_count, REF_PK_BYTES);
    end
    if (sk_count != REF_SK_BYTES) begin
      $fatal(1, "SK length mismatch got=%0d expected=%0d", sk_count, REF_SK_BYTES);
    end
    if (busy) $fatal(1, "KeyGen remained busy after done");
    if (busy_cycles != (USE_SYNTH_TOP ? EXPECTED_SYNTH_BUSY_CYCLES : EXPECTED_BUSY_CYCLES)) begin
      $fatal(1, "cycle mismatch got=%0d expected=%0d", busy_cycles,
             USE_SYNTH_TOP ? EXPECTED_SYNTH_BUSY_CYCLES : EXPECTED_BUSY_CYCLES);
    end
    $display("tb_trike_keygen_core_reference PASS alt=%0d synth=%0d pk=%0d sk=%0d cycles=%0d",
             ALT_CASE, USE_SYNTH_TOP, pk_count, sk_count, busy_cycles);
    $finish;
  end

  initial begin
    repeat (110000000) @(posedge clk);
    $fatal(1, "tb_trike_keygen_core_reference timeout");
  end

endmodule
