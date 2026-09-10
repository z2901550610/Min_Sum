`timescale 1ns / 1ps

module tb_trike_encaps_core_reference #(
    parameter bit USE_SYNTH_TOP         = 1'b0,
    parameter bit USE_SHARED_SM3        = 1'b0,
    parameter bit USE_SHARED_MUL        = 1'b0,
    parameter bit USE_SHARED_H123       = 1'b0,
    parameter bit USE_SHARED_SAMPLER    = 1'b0,
    parameter bit USE_SHARED_H4_STORE   = 1'b0,
    parameter bit USE_SHARED_H123_STORE = 1'b0
);

  /* verilator lint_off UNUSEDPARAM */
  `include "generated/trike_encaps_reference_case.svh"
  /* verilator lint_on UNUSEDPARAM */

  localparam int REF_INPUT_BYTES = REF_R_BYTES + (2 * REF_M_BYTES);
  localparam int REF_CT_BYTES = (2 * REF_R_BYTES) + REF_M_BYTES;
  localparam int REF_BUSY_CYCLES = 527684;
  localparam int REF_SYNTH_BUSY_CYCLES = 533658;
  localparam int MAX_R_BITS = 106781;
  localparam int MUL_INDEX_W = $clog2(MAX_R_BITS);
  localparam int PADDED_R_BYTES = ((REF_R_BITS + 511) / 512) * 64;
  localparam int ERROR_ADDR_W = $clog2(3 * PADDED_R_BYTES);
  localparam int H123_WORD_ADDR_W = $clog2((REF_R_BITS + 63) / 64);

  logic                        clk;
  logic                        rst_n;
  logic                        start;
  logic                        input_valid;
  logic [                 7:0] input_data;
  logic                        input_ready;
  logic                        ciphertext_valid;
  logic [                 7:0] ciphertext_data;
  logic                        ciphertext_last;
  logic                        ciphertext_ready;
  logic                        shared_secret_valid;
  logic [                 7:0] shared_secret_data;
  logic                        shared_secret_last;
  logic                        shared_secret_ready;
  logic                        busy;
  logic                        done;
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
  logic [                 8:0] sampler_index_position;
  logic [                15:0] sampler_index;
  logic                        sampler_index_ready;
  logic                        sampler_busy;
  logic                        sampler_done;
  logic [               439:0] sampler_output_v;
  logic [               439:0] sampler_output_c;
  logic [               439:0] sampler_output_reseed_counter;
  logic                        sampler_compress_start;
  logic [               511:0] sampler_compress_block;
  logic [               255:0] sampler_compress_state;
  logic                        h4_store_start;
  logic [                31:0] h4_store_r_bits;
  logic [                31:0] h4_store_error_weight;
  logic [                31:0] h4_store_padded_r_bytes;
  logic                        h4_store_index_valid;
  logic [                 8:0] h4_store_index_position;
  logic [                15:0] h4_store_index;
  logic                        h4_store_index_ready;
  logic                        h4_store_support_re;
  logic [                 8:0] h4_store_support_raddr;
  logic [                15:0] h4_store_support_rdata;
  logic                        h4_store_error_re;
  logic [    ERROR_ADDR_W-1:0] h4_store_error_raddr;
  logic [                 7:0] h4_store_error_rdata;
  logic                        h4_store_busy;
  logic                        h4_store_done;
  /* verilator lint_on UNUSEDSIGNAL */

  int                          busy_cycles;
  int                          ciphertext_count;
  int                          shared_secret_count;

  generate
    if (USE_SYNTH_TOP) begin : g_synth_top
      trike_encaps_synth_top dut (
          .i_clk                (clk),
          .i_rst_n              (rst_n),
          .i_start              (start),
          .i_input_valid        (input_valid),
          .i_input_data         (input_data),
          .o_input_ready        (input_ready),
          .o_ciphertext_valid   (ciphertext_valid),
          .o_ciphertext_data    (ciphertext_data),
          .o_ciphertext_last    (ciphertext_last),
          .i_ciphertext_ready   (ciphertext_ready),
          .o_shared_secret_valid(shared_secret_valid),
          .o_shared_secret_data (shared_secret_data),
          .o_shared_secret_last (shared_secret_last),
          .i_shared_secret_ready(shared_secret_ready),
          .o_busy               (busy),
          .o_done               (done)
      );
    end else begin : g_core
      trike_encaps_core #(
          .M_BYTES                (REF_M_BYTES),
          .R_BITS                 (REF_R_BITS),
          .ERROR_WEIGHT           (REF_ERROR_WEIGHT),
          .WORD_W                 (64),
          .USE_EXTERNAL_COMPRESS  (USE_SHARED_SM3),
          .USE_EXTERNAL_MUL       (USE_SHARED_MUL),
          .USE_EXTERNAL_H123      (USE_SHARED_H123),
          .USE_EXTERNAL_SAMPLER   (USE_SHARED_SAMPLER),
          .USE_EXTERNAL_H4_STORE  (USE_SHARED_H4_STORE),
          .USE_EXTERNAL_H123_STORE(USE_SHARED_H123_STORE),
          .MUL_INDEX_W            (MUL_INDEX_W)
      ) dut (
          .i_clk                            (clk),
          .i_rst_n                          (rst_n),
          .i_start                          (start),
          .i_input_valid                    (input_valid),
          .i_input_data                     (input_data),
          .o_input_ready                    (input_ready),
          .o_ciphertext_valid               (ciphertext_valid),
          .o_ciphertext_data                (ciphertext_data),
          .o_ciphertext_last                (ciphertext_last),
          .i_ciphertext_ready               (ciphertext_ready),
          .o_shared_secret_valid            (shared_secret_valid),
          .o_shared_secret_data             (shared_secret_data),
          .o_shared_secret_last             (shared_secret_last),
          .i_shared_secret_ready            (shared_secret_ready),
          .o_busy                           (busy),
          .o_done                           (done),
          .o_compress_start                 (compress_start),
          .o_compress_block                 (compress_block),
          .o_compress_state                 (compress_input_state),
          .i_compress_busy                  (compress_busy),
          .i_compress_done                  (compress_done),
          .i_compress_state                 (compress_output_state),
          .o_mul_start                      (mul_start),
          .o_mul_runtime_r_bits             (mul_runtime_r_bits),
          .o_mul_runtime_words              (mul_runtime_words),
          .o_mul_runtime_sparse_weight      (mul_runtime_sparse_weight),
          .o_mul_sparse_a                   (mul_sparse_a),
          .o_mul_a_valid                    (mul_a_valid),
          .o_mul_a_data                     (mul_a_data),
          .i_mul_a_ready                    (mul_a_ready),
          .o_mul_sparse_index_valid         (mul_sparse_index_valid),
          .o_mul_sparse_index               (mul_sparse_index),
          .i_mul_sparse_index_ready         (mul_sparse_index_ready),
          .o_mul_b_valid                    (mul_b_valid),
          .o_mul_b_data                     (mul_b_data),
          .i_mul_b_ready                    (mul_b_ready),
          .i_mul_result_valid               (mul_result_valid),
          .i_mul_result_data                (mul_result_data),
          .i_mul_result_last                (mul_result_last),
          .o_mul_result_ready               (mul_result_ready),
          .o_h123_start                     (h123_start),
          .o_h123_seed_valid                (h123_seed_valid),
          .o_h123_seed_data                 (h123_seed_data),
          .i_h123_seed_ready                (h123_seed_ready),
          .i_h123_vector_valid              (h123_vector_valid),
          .i_h123_vector_select             (h123_vector_select),
          .i_h123_vector_byte               (h123_vector_byte),
          .i_h123_vector_data               (h123_vector_data),
          .o_h123_vector_ready              (h123_vector_ready),
          .i_h123_done                      (h123_done),
          .o_h123_t1_re                     (h123_t1_re),
          .o_h123_t1_raddr                  (h123_t1_raddr),
          .i_h123_t1_rdata                  (h123_t1_rdata),
          .o_h123_t2_re                     (h123_t2_re),
          .o_h123_t2_raddr                  (h123_t2_raddr),
          .i_h123_t2_rdata                  (h123_t2_rdata),
          .o_h123_r1_re                     (h123_r1_re),
          .o_h123_r1_raddr                  (h123_r1_raddr),
          .i_h123_r1_rdata                  (h123_r1_rdata),
          .o_sampler_start                  (sampler_start),
          .o_sampler_runtime_length         (sampler_length),
          .o_sampler_runtime_weight         (sampler_weight),
          .o_sampler_v                      (sampler_input_v),
          .o_sampler_c                      (sampler_input_c),
          .o_sampler_reseed_counter         (sampler_input_reseed_counter),
          .i_sampler_index_valid            (sampler_index_valid),
          .i_sampler_index_position         (sampler_index_position),
          .i_sampler_index                  (sampler_index),
          .o_sampler_index_ready            (sampler_index_ready),
          .i_sampler_done                   (sampler_done),
          .i_sampler_v                      (sampler_output_v),
          .i_sampler_c                      (sampler_output_c),
          .i_sampler_reseed_counter         (sampler_output_reseed_counter),
          .o_h4_store_start                 (h4_store_start),
          .o_h4_store_runtime_r_bits        (h4_store_r_bits),
          .o_h4_store_runtime_error_weight  (h4_store_error_weight),
          .o_h4_store_runtime_padded_r_bytes(h4_store_padded_r_bytes),
          .o_h4_store_index_valid           (h4_store_index_valid),
          .o_h4_store_index_position        (h4_store_index_position),
          .o_h4_store_index                 (h4_store_index),
          .i_h4_store_index_ready           (h4_store_index_ready),
          .o_h4_store_support_re            (h4_store_support_re),
          .o_h4_store_support_raddr         (h4_store_support_raddr),
          .i_h4_store_support_rdata         (h4_store_support_rdata),
          .o_h4_store_error_re              (h4_store_error_re),
          .o_h4_store_error_raddr           (h4_store_error_raddr),
          .i_h4_store_error_rdata           (h4_store_error_rdata),
          .i_h4_store_done                  (h4_store_done)
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
            .M_BYTES              (REF_M_BYTES),
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
            .i_t1_we        (1'b0),
            .i_t1_waddr     ('0),
            .i_t1_wdata     ('0),
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
            .LENGTH               (3 * REF_R_BITS),
            .WEIGHT               (REF_ERROR_WEIGHT),
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
            .R_BITS(MAX_R_BITS),
            .WORD_W(64),

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

            .o_busy(),
            .o_done()
        );
      end else begin : g_local_mul
        assign mul_a_ready = 1'b0;
        assign mul_sparse_index_ready = 1'b0;
        assign mul_b_ready = 1'b0;
        assign mul_result_valid = 1'b0;
        assign mul_result_data = '0;
        assign mul_result_last = 1'b0;
      end

      if (USE_SHARED_H4_STORE) begin : g_shared_h4_store
        trike_error_support_store #(
            .R_BITS          (REF_R_BITS),
            .ERROR_WEIGHT    (REF_ERROR_WEIGHT),
            .PADDED_R_BYTES  (PADDED_R_BYTES),
            .RUNTIME_GEOMETRY(1'b1)
        ) u_h4_store_service (
            .i_clk                   (clk),
            .i_rst_n                 (rst_n),
            .i_start                 (h4_store_start),
            .i_runtime_r_bits        (h4_store_r_bits),
            .i_runtime_error_weight  (h4_store_error_weight),
            .i_runtime_padded_r_bytes(h4_store_padded_r_bytes),
            .i_index_valid           (h4_store_index_valid),
            .i_index_position        (h4_store_index_position),
            .i_index                 (h4_store_index),
            .o_index_ready           (h4_store_index_ready),
            .i_support_re            (h4_store_support_re),
            .i_support_raddr         (h4_store_support_raddr),
            .o_support_rdata         (h4_store_support_rdata),
            .i_error_re              (h4_store_error_re),
            .i_error_raddr           (h4_store_error_raddr),
            .o_error_rdata           (h4_store_error_rdata),
            .o_busy                  (h4_store_busy),
            .o_done                  (h4_store_done)
        );
      end else begin : g_local_h4_store
        assign h4_store_index_ready = 1'b0;
        assign h4_store_support_rdata = '0;
        assign h4_store_error_rdata = '0;
        assign h4_store_done = 1'b0;
      end
    end
  endgenerate

  always #5 clk = ~clk;

  function automatic logic [7:0] encaps_input_byte(input int byte_idx);
    begin
      if (byte_idx < REF_R_BYTES) begin
        encaps_input_byte = REF_R2[byte_idx];
      end else if (byte_idx < (REF_R_BYTES + REF_M_BYTES)) begin
        encaps_input_byte = REF_SIGMA[byte_idx-REF_R_BYTES];
      end else begin
        encaps_input_byte = REF_MESSAGE[byte_idx-REF_R_BYTES-REF_M_BYTES];
      end
    end
  endfunction

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      busy_cycles <= 0;
      ciphertext_count <= 0;
      shared_secret_count <= 0;
    end else begin
      if (busy) busy_cycles <= busy_cycles + 1;

      if (ciphertext_valid && ciphertext_ready) begin
        if (ciphertext_data != REF_CIPHERTEXT[ciphertext_count]) begin
          $fatal(1, "ciphertext mismatch byte=%0d got=%02x expected=%02x", ciphertext_count,
                 ciphertext_data, REF_CIPHERTEXT[ciphertext_count]);
        end
        if (ciphertext_last != (ciphertext_count == (REF_CT_BYTES - 1))) begin
          $fatal(1, "ciphertext last mismatch byte=%0d", ciphertext_count);
        end
        ciphertext_count <= ciphertext_count + 1;
      end

      if (shared_secret_valid && shared_secret_ready) begin
        if (shared_secret_data != REF_SS[shared_secret_count]) begin
          $fatal(1, "shared-secret mismatch byte=%0d got=%02x expected=%02x", shared_secret_count,
                 shared_secret_data, REF_SS[shared_secret_count]);
        end
        if (shared_secret_last != (shared_secret_count == (REF_M_BYTES - 1))) begin
          $fatal(1, "shared-secret last mismatch byte=%0d", shared_secret_count);
        end
        shared_secret_count <= shared_secret_count + 1;
      end
    end
  end

  initial begin
    int input_count;

    clk = 1'b0;
    rst_n = 1'b0;
    start = 1'b0;
    input_valid = 1'b0;
    input_data = '0;
    ciphertext_ready = 1'b1;
    shared_secret_ready = 1'b1;

    repeat (3) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    if (USE_SYNTH_TOP) repeat (3) @(negedge clk);
    start = 1'b1;
    @(negedge clk);
    start = 1'b0;

    input_count = 0;
    input_valid = 1'b1;
    while (input_count < REF_INPUT_BYTES) begin
      input_data = encaps_input_byte(input_count);
      @(posedge clk);
      if (input_valid && input_ready) begin
        @(negedge clk);
        input_count++;
      end
    end
    input_valid = 1'b0;

    wait (done);
    if (ciphertext_count != REF_CT_BYTES) begin
      $fatal(1, "ciphertext transfer count mismatch got=%0d expected=%0d", ciphertext_count,
             REF_CT_BYTES);
    end
    if (shared_secret_count != REF_M_BYTES) begin
      $fatal(1, "shared-secret transfer count mismatch got=%0d expected=%0d", shared_secret_count,
             REF_M_BYTES);
    end
    if (busy_cycles != (USE_SYNTH_TOP ? REF_SYNTH_BUSY_CYCLES : REF_BUSY_CYCLES)) begin
      $fatal(1, "Encaps cycle mismatch got=%0d expected=%0d", busy_cycles,
             USE_SYNTH_TOP ? REF_SYNTH_BUSY_CYCLES : REF_BUSY_CYCLES);
    end

    $display("tb_trike_encaps_core_reference PASS cycles=%0d ct=%0d ss=%0d", busy_cycles,
             ciphertext_count, shared_secret_count);
    $finish;
  end

  initial begin
    repeat (3000000) @(posedge clk);
    $fatal(1, "tb_trike_encaps_core_reference timeout");
  end

endmodule
