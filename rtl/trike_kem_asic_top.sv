`timescale 1ns / 1ps

// Single-issue TRIKE KEM integration boundary. i_operation is public and is
// latched for the full transaction: 0=KeyGen, 1=Encaps, 2=Decaps. All three
// modes share one SM3 compression service, one H1/H2/H3 vector service, one
// runtime-geometry fixed-weight sampler, one H123 vector store, one H4
// support/error store, and one streaming polynomial multiplier; inactive modes
// receive no start or input traffic. KeyGen/Encaps use the official TRIKE-2
// geometry while Decaps retains the validated runtime K-sign profile table.
module trike_kem_asic_top
  import bike_pkg::*;
(
    input  logic                    i_clk,
    input  logic                    i_rst_n,
    input  logic                    i_start,
    input  logic [             1:0] i_operation,
    input  logic [PROFILE_ID_W-1:0] i_param_level,
    input  logic                    i_input_valid,
    input  logic [             7:0] i_input_data,
    output logic                    o_input_ready,
    output logic                    o_pk_valid,
    output logic [             7:0] o_pk_data,
    output logic                    o_pk_last,
    input  logic                    i_pk_ready,
    output logic                    o_sk_valid,
    output logic [             7:0] o_sk_data,
    output logic                    o_sk_last,
    input  logic                    i_sk_ready,
    output logic                    o_ciphertext_valid,
    output logic [             7:0] o_ciphertext_data,
    output logic                    o_ciphertext_last,
    input  logic                    i_ciphertext_ready,
    output logic                    o_shared_secret_valid,
    output logic [             7:0] o_shared_secret_data,
    output logic                    o_shared_secret_last,
    input  logic                    i_shared_secret_ready,
    output logic                    o_keygen_success,
    output logic                    o_residual_zero,
    output logic                    o_ciphertext_equal,
    output logic                    o_error,
    output logic                    o_busy,
    output logic                    o_done
);

  localparam logic [1:0] OP_KEYGEN = 2'd0;
  localparam logic [1:0] OP_ENCAPS = 2'd1;
  localparam logic [1:0] OP_DECAPS = 2'd2;
  localparam int H123_BYTE_W = $clog2((15581 + 7) / 8);
  localparam int H123_WORD_ADDR_W = $clog2((15581 + 63) / 64);
  localparam int KEYGEN_SAMPLER_POSITION_W = $clog2(35);
  localparam int KEYGEN_SAMPLER_INDEX_W = $clog2(15581);
  localparam int ENCAPS_SAMPLER_POSITION_W = $clog2(263);
  localparam int ENCAPS_SAMPLER_INDEX_W = $clog2(3 * 15581);
  localparam int SAMPLER_POSITION_W = $clog2(P_T_VALS[3]);
  localparam int SAMPLER_INDEX_W = $clog2(3 * P_R_VALS[3]);
  localparam int ENCAPS_H4_ERROR_ADDR_W = $clog2(3 * (((15581 + 511) / 512) * 64));
  localparam int H4_STORE_PADDED_R_BYTES = ((P_R_VALS[3] + 511) / 512) * 64;
  localparam int H4_STORE_ERROR_ADDR_W = $clog2(3 * H4_STORE_PADDED_R_BYTES);

  logic                                 keygen_start;
  logic                                 encaps_start;
  logic                                 decaps_start;
  logic [                          1:0] active_operation;
  logic                                 control_error;

  logic                                 keygen_input_ready;
  logic                                 keygen_pk_valid;
  logic [                          7:0] keygen_pk_data;
  logic                                 keygen_pk_last;
  logic                                 keygen_sk_valid;
  logic [                          7:0] keygen_sk_data;
  logic                                 keygen_sk_last;
  logic                                 keygen_busy;
  logic                                 keygen_done;
  logic                                 keygen_compress_start;
  logic [                        511:0] keygen_compress_block;
  logic [                        255:0] keygen_compress_state;
  logic                                 keygen_mul_start;
  logic [                         31:0] keygen_mul_r_bits;
  logic [                         31:0] keygen_mul_words;
  logic [                         31:0] keygen_mul_sparse_weight;
  logic                                 keygen_mul_sparse_a;
  logic                                 keygen_mul_a_valid;
  logic [                         63:0] keygen_mul_a_data;
  logic                                 keygen_mul_sparse_index_valid;
  logic [                ROW_IDX_W-1:0] keygen_mul_sparse_index;
  logic                                 keygen_mul_b_valid;
  logic [                         63:0] keygen_mul_b_data;
  logic                                 keygen_mul_result_ready;
  logic                                 keygen_h123_start;
  logic                                 keygen_h123_seed_valid;
  logic [                          7:0] keygen_h123_seed_data;
  logic                                 keygen_h123_vector_ready;
  logic                                 keygen_h123_t1_re;
  logic [         H123_WORD_ADDR_W-1:0] keygen_h123_t1_raddr;
  logic                                 keygen_h123_t2_re;
  logic [         H123_WORD_ADDR_W-1:0] keygen_h123_t2_raddr;
  logic                                 keygen_h123_r1_re;
  logic [         H123_WORD_ADDR_W-1:0] keygen_h123_r1_raddr;
  logic                                 keygen_sampler_start;
  logic [                         31:0] keygen_sampler_length;
  logic [                         31:0] keygen_sampler_weight;
  logic [                        439:0] keygen_sampler_v;
  logic [                        439:0] keygen_sampler_c;
  logic [                        439:0] keygen_sampler_reseed_counter;
  logic                                 keygen_sampler_index_ready;

  logic                                 encaps_input_ready;
  logic                                 encaps_ciphertext_valid;
  logic [                          7:0] encaps_ciphertext_data;
  logic                                 encaps_ciphertext_last;
  logic                                 encaps_shared_secret_valid;
  logic [                          7:0] encaps_shared_secret_data;
  logic                                 encaps_shared_secret_last;
  logic                                 encaps_busy;
  logic                                 encaps_done;
  logic                                 encaps_compress_start;
  logic [                        511:0] encaps_compress_block;
  logic [                        255:0] encaps_compress_state;
  logic                                 encaps_mul_start;
  logic [                         31:0] encaps_mul_r_bits;
  logic [                         31:0] encaps_mul_words;
  logic [                         31:0] encaps_mul_sparse_weight;
  logic                                 encaps_mul_sparse_a;
  logic                                 encaps_mul_a_valid;
  logic [                         63:0] encaps_mul_a_data;
  logic                                 encaps_mul_sparse_index_valid;
  logic [                ROW_IDX_W-1:0] encaps_mul_sparse_index;
  logic                                 encaps_mul_b_valid;
  logic [                         63:0] encaps_mul_b_data;
  logic                                 encaps_mul_result_ready;
  logic                                 encaps_h123_start;
  logic                                 encaps_h123_seed_valid;
  logic [                          7:0] encaps_h123_seed_data;
  logic                                 encaps_h123_vector_ready;
  logic                                 encaps_h123_t1_re;
  logic [         H123_WORD_ADDR_W-1:0] encaps_h123_t1_raddr;
  logic                                 encaps_h123_t2_re;
  logic [         H123_WORD_ADDR_W-1:0] encaps_h123_t2_raddr;
  logic                                 encaps_h123_r1_re;
  logic [         H123_WORD_ADDR_W-1:0] encaps_h123_r1_raddr;
  logic                                 encaps_sampler_start;
  logic [                         31:0] encaps_sampler_length;
  logic [                         31:0] encaps_sampler_weight;
  logic [                        439:0] encaps_sampler_v;
  logic [                        439:0] encaps_sampler_c;
  logic [                        439:0] encaps_sampler_reseed_counter;
  logic                                 encaps_sampler_index_ready;
  logic                                 encaps_h4_store_start;
  logic [                         31:0] encaps_h4_store_r_bits;
  logic [                         31:0] encaps_h4_store_error_weight;
  logic [                         31:0] encaps_h4_store_padded_r_bytes;
  logic                                 encaps_h4_store_index_valid;
  logic [ENCAPS_SAMPLER_POSITION_W-1:0] encaps_h4_store_index_position;
  logic [   ENCAPS_SAMPLER_INDEX_W-1:0] encaps_h4_store_index;
  logic                                 encaps_h4_store_support_re;
  logic [ENCAPS_SAMPLER_POSITION_W-1:0] encaps_h4_store_support_raddr;
  logic                                 encaps_h4_store_error_re;
  logic [   ENCAPS_H4_ERROR_ADDR_W-1:0] encaps_h4_store_error_raddr;

  logic                                 decaps_input_ready;
  logic                                 decaps_shared_secret_valid;
  logic [                          7:0] decaps_shared_secret_data;
  logic                                 decaps_shared_secret_last;
  logic                                 decaps_error;
  logic                                 decaps_busy;
  logic                                 decaps_done;
  logic                                 decaps_compress_start;
  logic [                        511:0] decaps_compress_block;
  logic [                        255:0] decaps_compress_state;
  logic [                ROW_IDX_W-1:0] decaps_residual_weight;
  logic [                          4:0] decaps_shared_secret_index;
  logic                                 decaps_mul_start;
  logic [                         31:0] decaps_mul_r_bits;
  logic [                         31:0] decaps_mul_words;
  logic [                         31:0] decaps_mul_sparse_weight;
  logic                                 decaps_mul_sparse_a;
  logic                                 decaps_mul_a_valid;
  logic [                         63:0] decaps_mul_a_data;
  logic                                 decaps_mul_sparse_index_valid;
  logic [                ROW_IDX_W-1:0] decaps_mul_sparse_index;
  logic                                 decaps_mul_b_valid;
  logic [                         63:0] decaps_mul_b_data;
  logic                                 decaps_mul_result_ready;
  logic                                 decaps_sampler_start;
  logic [                         31:0] decaps_sampler_length;
  logic [                         31:0] decaps_sampler_weight;
  logic [                        439:0] decaps_sampler_v;
  logic [                        439:0] decaps_sampler_c;
  logic [                        439:0] decaps_sampler_reseed_counter;
  logic                                 decaps_sampler_index_ready;
  logic                                 decaps_h4_store_start;
  logic [                         31:0] decaps_h4_store_r_bits;
  logic [                         31:0] decaps_h4_store_error_weight;
  logic [                         31:0] decaps_h4_store_padded_r_bytes;
  logic                                 decaps_h4_store_index_valid;
  logic [       SAMPLER_POSITION_W-1:0] decaps_h4_store_index_position;
  logic [          SAMPLER_INDEX_W-1:0] decaps_h4_store_index;
  logic                                 decaps_h4_store_support_re;
  logic [       SAMPLER_POSITION_W-1:0] decaps_h4_store_support_raddr;
  logic                                 decaps_h4_store_error_re;
  logic [    H4_STORE_ERROR_ADDR_W-1:0] decaps_h4_store_error_raddr;

  logic                                 shared_compress_start;
  logic [                        511:0] shared_compress_block;
  logic [                        255:0] shared_compress_input_state;
  logic                                 shared_compress_busy;
  logic                                 shared_compress_done;
  logic [                        255:0] shared_compress_output_state;

  logic                                 shared_mul_start;
  logic [                         31:0] shared_mul_r_bits;
  logic [                         31:0] shared_mul_words;
  logic [                         31:0] shared_mul_sparse_weight;
  logic                                 shared_mul_sparse_a;
  logic                                 shared_mul_a_valid;
  logic [                         63:0] shared_mul_a_data;
  logic                                 shared_mul_a_ready;
  logic                                 shared_mul_sparse_index_valid;
  logic [                ROW_IDX_W-1:0] shared_mul_sparse_index;
  logic                                 shared_mul_sparse_index_ready;
  logic                                 shared_mul_b_valid;
  logic [                         63:0] shared_mul_b_data;
  logic                                 shared_mul_b_ready;
  logic                                 shared_mul_result_valid;
  logic [                         63:0] shared_mul_result_data;
  logic                                 shared_mul_result_last;
  logic                                 shared_mul_result_ready;
  logic                                 shared_mul_done;

  logic                                 shared_h123_start;
  logic                                 shared_h123_seed_valid;
  logic [                          7:0] shared_h123_seed_data;
  logic                                 shared_h123_seed_ready;
  logic                                 shared_h123_vector_valid;
  logic [                          1:0] shared_h123_vector_select;
  logic [              H123_BYTE_W-1:0] shared_h123_vector_byte;
  logic [                          7:0] shared_h123_vector_data;
  logic                                 shared_h123_vector_ready;
  logic                                 shared_h123_store_vector_ready;
  logic                                 shared_h123_t1_re;
  logic [         H123_WORD_ADDR_W-1:0] shared_h123_t1_raddr;
  logic [                         63:0] shared_h123_t1_rdata;
  logic                                 shared_h123_t2_re;
  logic [         H123_WORD_ADDR_W-1:0] shared_h123_t2_raddr;
  logic [                         63:0] shared_h123_t2_rdata;
  logic                                 shared_h123_r1_re;
  logic [         H123_WORD_ADDR_W-1:0] shared_h123_r1_raddr;
  logic [                         63:0] shared_h123_r1_rdata;
  logic                                 shared_h123_busy;
  logic                                 shared_h123_done;
  logic                                 shared_h123_compress_start;
  logic [                        511:0] shared_h123_compress_block;
  logic [                        255:0] shared_h123_compress_state;

  logic                                 shared_sampler_start;
  logic [                         31:0] shared_sampler_length;
  logic [                         31:0] shared_sampler_weight;
  logic [                        439:0] shared_sampler_input_v;
  logic [                        439:0] shared_sampler_input_c;
  logic [                        439:0] shared_sampler_input_reseed_counter;
  logic                                 shared_sampler_index_valid;
  logic [       SAMPLER_POSITION_W-1:0] shared_sampler_index_position;
  logic [          SAMPLER_INDEX_W-1:0] shared_sampler_index;
  logic                                 shared_sampler_index_ready;
  logic                                 shared_sampler_busy;
  logic                                 shared_sampler_done;
  logic [                        439:0] shared_sampler_output_v;
  logic [                        439:0] shared_sampler_output_c;
  logic [                        439:0] shared_sampler_output_reseed_counter;
  logic                                 shared_sampler_compress_start;
  logic [                        511:0] shared_sampler_compress_block;
  logic [                        255:0] shared_sampler_compress_state;

  logic                                 shared_h4_store_start;
  logic [                         31:0] shared_h4_store_r_bits;
  logic [                         31:0] shared_h4_store_error_weight;
  logic [                         31:0] shared_h4_store_padded_r_bytes;
  logic                                 shared_h4_store_index_valid;
  logic [       SAMPLER_POSITION_W-1:0] shared_h4_store_index_position;
  logic [          SAMPLER_INDEX_W-1:0] shared_h4_store_index;
  logic                                 shared_h4_store_index_ready;
  logic                                 shared_h4_store_support_re;
  logic [       SAMPLER_POSITION_W-1:0] shared_h4_store_support_raddr;
  logic [          SAMPLER_INDEX_W-1:0] shared_h4_store_support_rdata;
  logic                                 shared_h4_store_error_re;
  logic [    H4_STORE_ERROR_ADDR_W-1:0] shared_h4_store_error_raddr;
  logic [                          7:0] shared_h4_store_error_rdata;
  logic                                 shared_h4_store_done;

  trike_kem_operation_control u_operation_control (
      .i_clk             (i_clk),
      .i_rst_n           (i_rst_n),
      .i_start           (i_start),
      .i_operation       (i_operation),
      .i_keygen_done     (keygen_done),
      .i_encaps_done     (encaps_done),
      .i_decaps_done     (decaps_done),
      .o_keygen_start    (keygen_start),
      .o_encaps_start    (encaps_start),
      .o_decaps_start    (decaps_start),
      .o_active_operation(active_operation),
      .o_busy            (o_busy),
      .o_done            (o_done),
      .o_error           (control_error)
  );

  trike_keygen_core #(
      .M_BYTES                (32),
      .R_BITS                 (15581),
      .SECRET_WEIGHT          (35),
      .CANDIDATE_COUNT        (16),
      .WORD_W                 (64),
      .DIGIT_W                (16),
      .USE_EXTERNAL_COMPRESS  (1'b1),
      .USE_EXTERNAL_MUL       (1'b1),
      .USE_EXTERNAL_H123      (1'b1),
      .USE_EXTERNAL_SAMPLER   (1'b1),
      .USE_EXTERNAL_H123_STORE(1'b1),
      .MUL_INDEX_W            (ROW_IDX_W)
  ) u_keygen (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_start(keygen_start),
      .i_random_valid(i_input_valid && (active_operation == OP_KEYGEN)),
      .i_random_data(i_input_data),
      .o_random_ready(keygen_input_ready),
      .o_pk_valid(keygen_pk_valid),
      .o_pk_data(keygen_pk_data),
      .o_pk_last(keygen_pk_last),
      .i_pk_ready(i_pk_ready && (active_operation == OP_KEYGEN)),
      .o_sk_valid(keygen_sk_valid),
      .o_sk_data(keygen_sk_data),
      .o_sk_last(keygen_sk_last),
      .i_sk_ready(i_sk_ready && (active_operation == OP_KEYGEN)),
      .o_busy(keygen_busy),
      .o_done(keygen_done),
      .o_success(o_keygen_success),
      .o_compress_start(keygen_compress_start),
      .o_compress_block(keygen_compress_block),
      .o_compress_state(keygen_compress_state),
      .i_compress_busy(shared_compress_busy),
      .i_compress_done(shared_compress_done),
      .i_compress_state(shared_compress_output_state),
      .o_mul_start(keygen_mul_start),
      .o_mul_runtime_r_bits(keygen_mul_r_bits),
      .o_mul_runtime_words(keygen_mul_words),
      .o_mul_runtime_sparse_weight(keygen_mul_sparse_weight),
      .o_mul_sparse_a(keygen_mul_sparse_a),
      .o_mul_a_valid(keygen_mul_a_valid),
      .o_mul_a_data(keygen_mul_a_data),
      .i_mul_a_ready(shared_mul_a_ready && (active_operation == OP_KEYGEN)),
      .o_mul_sparse_index_valid(keygen_mul_sparse_index_valid),
      .o_mul_sparse_index(keygen_mul_sparse_index),
      .i_mul_sparse_index_ready(shared_mul_sparse_index_ready && (active_operation == OP_KEYGEN)),
      .o_mul_b_valid(keygen_mul_b_valid),
      .o_mul_b_data(keygen_mul_b_data),
      .i_mul_b_ready(shared_mul_b_ready && (active_operation == OP_KEYGEN)),
      .i_mul_result_valid(shared_mul_result_valid && (active_operation == OP_KEYGEN)),
      .i_mul_result_data(shared_mul_result_data),
      .i_mul_result_last(shared_mul_result_last),
      .o_mul_result_ready(keygen_mul_result_ready),
      .i_mul_done(shared_mul_done && (active_operation == OP_KEYGEN)),
      .o_h123_start(keygen_h123_start),
      .o_h123_seed_valid(keygen_h123_seed_valid),
      .o_h123_seed_data(keygen_h123_seed_data),
      .i_h123_seed_ready(shared_h123_seed_ready && (active_operation == OP_KEYGEN)),
      .i_h123_vector_valid(shared_h123_vector_valid && (active_operation == OP_KEYGEN)),
      .i_h123_vector_select(shared_h123_vector_select),
      .i_h123_vector_byte(shared_h123_vector_byte),
      .i_h123_vector_data(shared_h123_vector_data),
      .o_h123_vector_ready(keygen_h123_vector_ready),
      .i_h123_done(shared_h123_done && (active_operation == OP_KEYGEN)),
      .o_h123_t1_re(keygen_h123_t1_re),
      .o_h123_t1_raddr(keygen_h123_t1_raddr),
      .i_h123_t1_rdata(shared_h123_t1_rdata),
      .o_h123_t2_re(keygen_h123_t2_re),
      .o_h123_t2_raddr(keygen_h123_t2_raddr),
      .i_h123_t2_rdata(shared_h123_t2_rdata),
      .o_h123_r1_re(keygen_h123_r1_re),
      .o_h123_r1_raddr(keygen_h123_r1_raddr),
      .i_h123_r1_rdata(shared_h123_r1_rdata),
      .o_sampler_start(keygen_sampler_start),
      .o_sampler_runtime_length(keygen_sampler_length),
      .o_sampler_runtime_weight(keygen_sampler_weight),
      .o_sampler_v(keygen_sampler_v),
      .o_sampler_c(keygen_sampler_c),
      .o_sampler_reseed_counter(keygen_sampler_reseed_counter),
      .i_sampler_index_valid(shared_sampler_index_valid && (active_operation == OP_KEYGEN)),
      .i_sampler_index_position(shared_sampler_index_position[KEYGEN_SAMPLER_POSITION_W-1:0]),
      .i_sampler_index(shared_sampler_index[KEYGEN_SAMPLER_INDEX_W-1:0]),
      .o_sampler_index_ready(keygen_sampler_index_ready),
      .i_sampler_done(shared_sampler_done && (active_operation == OP_KEYGEN)),
      .i_sampler_v(shared_sampler_output_v),
      .i_sampler_c(shared_sampler_output_c),
      .i_sampler_reseed_counter(shared_sampler_output_reseed_counter)
  );

  trike_encaps_core #(
      .M_BYTES                (32),
      .R_BITS                 (15581),
      .ERROR_WEIGHT           (263),
      .WORD_W                 (64),
      .USE_EXTERNAL_COMPRESS  (1'b1),
      .USE_EXTERNAL_MUL       (1'b1),
      .USE_EXTERNAL_H123      (1'b1),
      .USE_EXTERNAL_SAMPLER   (1'b1),
      .USE_EXTERNAL_H4_STORE  (1'b1),
      .USE_EXTERNAL_H123_STORE(1'b1),
      .MUL_INDEX_W            (ROW_IDX_W)
  ) u_encaps (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_start(encaps_start),
      .i_input_valid(i_input_valid && (active_operation == OP_ENCAPS)),
      .i_input_data(i_input_data),
      .o_input_ready(encaps_input_ready),
      .o_ciphertext_valid(encaps_ciphertext_valid),
      .o_ciphertext_data(encaps_ciphertext_data),
      .o_ciphertext_last(encaps_ciphertext_last),
      .i_ciphertext_ready(i_ciphertext_ready && (active_operation == OP_ENCAPS)),
      .o_shared_secret_valid(encaps_shared_secret_valid),
      .o_shared_secret_data(encaps_shared_secret_data),
      .o_shared_secret_last(encaps_shared_secret_last),
      .i_shared_secret_ready(i_shared_secret_ready && (active_operation == OP_ENCAPS)),
      .o_busy(encaps_busy),
      .o_done(encaps_done),
      .o_compress_start(encaps_compress_start),
      .o_compress_block(encaps_compress_block),
      .o_compress_state(encaps_compress_state),
      .i_compress_busy(shared_compress_busy),
      .i_compress_done(shared_compress_done),
      .i_compress_state(shared_compress_output_state),
      .o_mul_start(encaps_mul_start),
      .o_mul_runtime_r_bits(encaps_mul_r_bits),
      .o_mul_runtime_words(encaps_mul_words),
      .o_mul_runtime_sparse_weight(encaps_mul_sparse_weight),
      .o_mul_sparse_a(encaps_mul_sparse_a),
      .o_mul_a_valid(encaps_mul_a_valid),
      .o_mul_a_data(encaps_mul_a_data),
      .i_mul_a_ready(shared_mul_a_ready && (active_operation == OP_ENCAPS)),
      .o_mul_sparse_index_valid(encaps_mul_sparse_index_valid),
      .o_mul_sparse_index(encaps_mul_sparse_index),
      .i_mul_sparse_index_ready(shared_mul_sparse_index_ready && (active_operation == OP_ENCAPS)),
      .o_mul_b_valid(encaps_mul_b_valid),
      .o_mul_b_data(encaps_mul_b_data),
      .i_mul_b_ready(shared_mul_b_ready && (active_operation == OP_ENCAPS)),
      .i_mul_result_valid(shared_mul_result_valid && (active_operation == OP_ENCAPS)),
      .i_mul_result_data(shared_mul_result_data),
      .i_mul_result_last(shared_mul_result_last),
      .o_mul_result_ready(encaps_mul_result_ready),
      .o_h123_start(encaps_h123_start),
      .o_h123_seed_valid(encaps_h123_seed_valid),
      .o_h123_seed_data(encaps_h123_seed_data),
      .i_h123_seed_ready(shared_h123_seed_ready && (active_operation == OP_ENCAPS)),
      .i_h123_vector_valid(shared_h123_vector_valid && (active_operation == OP_ENCAPS)),
      .i_h123_vector_select(shared_h123_vector_select),
      .i_h123_vector_byte(shared_h123_vector_byte),
      .i_h123_vector_data(shared_h123_vector_data),
      .o_h123_vector_ready(encaps_h123_vector_ready),
      .i_h123_done(shared_h123_done && (active_operation == OP_ENCAPS)),
      .o_h123_t1_re(encaps_h123_t1_re),
      .o_h123_t1_raddr(encaps_h123_t1_raddr),
      .i_h123_t1_rdata(shared_h123_t1_rdata),
      .o_h123_t2_re(encaps_h123_t2_re),
      .o_h123_t2_raddr(encaps_h123_t2_raddr),
      .i_h123_t2_rdata(shared_h123_t2_rdata),
      .o_h123_r1_re(encaps_h123_r1_re),
      .o_h123_r1_raddr(encaps_h123_r1_raddr),
      .i_h123_r1_rdata(shared_h123_r1_rdata),
      .o_sampler_start(encaps_sampler_start),
      .o_sampler_runtime_length(encaps_sampler_length),
      .o_sampler_runtime_weight(encaps_sampler_weight),
      .o_sampler_v(encaps_sampler_v),
      .o_sampler_c(encaps_sampler_c),
      .o_sampler_reseed_counter(encaps_sampler_reseed_counter),
      .i_sampler_index_valid(shared_sampler_index_valid && (active_operation == OP_ENCAPS)),
      .i_sampler_index_position(shared_sampler_index_position[ENCAPS_SAMPLER_POSITION_W-1:0]),
      .i_sampler_index(shared_sampler_index[ENCAPS_SAMPLER_INDEX_W-1:0]),
      .o_sampler_index_ready(encaps_sampler_index_ready),
      .i_sampler_done(shared_sampler_done && (active_operation == OP_ENCAPS)),
      .i_sampler_v(shared_sampler_output_v),
      .i_sampler_c(shared_sampler_output_c),
      .i_sampler_reseed_counter(shared_sampler_output_reseed_counter),
      .o_h4_store_start(encaps_h4_store_start),
      .o_h4_store_runtime_r_bits(encaps_h4_store_r_bits),
      .o_h4_store_runtime_error_weight(encaps_h4_store_error_weight),
      .o_h4_store_runtime_padded_r_bytes(encaps_h4_store_padded_r_bytes),
      .o_h4_store_index_valid(encaps_h4_store_index_valid),
      .o_h4_store_index_position(encaps_h4_store_index_position),
      .o_h4_store_index(encaps_h4_store_index),
      .i_h4_store_index_ready(shared_h4_store_index_ready && (active_operation == OP_ENCAPS)),
      .o_h4_store_support_re(encaps_h4_store_support_re),
      .o_h4_store_support_raddr(encaps_h4_store_support_raddr),
      .i_h4_store_support_rdata(shared_h4_store_support_rdata[ENCAPS_SAMPLER_INDEX_W-1:0]),
      .o_h4_store_error_re(encaps_h4_store_error_re),
      .o_h4_store_error_raddr(encaps_h4_store_error_raddr),
      .i_h4_store_error_rdata(shared_h4_store_error_rdata),
      .i_h4_store_done(shared_h4_store_done && (active_operation == OP_ENCAPS))
  );

  trike_decaps_unified_core #(
      .USE_EXTERNAL_COMPRESS(1'b1),
      .USE_EXTERNAL_MUL     (1'b1),
      .USE_EXTERNAL_SAMPLER (1'b1),
      .USE_EXTERNAL_H4_STORE(1'b1)
  ) u_decaps (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_start(decaps_start),
      .i_param_level(i_param_level),
      .i_input_valid(i_input_valid && (active_operation == OP_DECAPS)),
      .i_input_data(i_input_data),
      .o_input_ready(decaps_input_ready),
      .o_residual_zero(o_residual_zero),
      .o_residual_weight(decaps_residual_weight),
      .o_ciphertext_equal(o_ciphertext_equal),
      .o_shared_secret_valid(decaps_shared_secret_valid),
      .o_shared_secret_index(decaps_shared_secret_index),
      .o_shared_secret_data(decaps_shared_secret_data),
      .o_shared_secret_last(decaps_shared_secret_last),
      .i_shared_secret_ready(i_shared_secret_ready && (active_operation == OP_DECAPS)),
      .o_error(decaps_error),
      .o_busy(decaps_busy),
      .o_done(decaps_done),
      .o_compress_start(decaps_compress_start),
      .o_compress_block(decaps_compress_block),
      .o_compress_state(decaps_compress_state),
      .i_compress_busy(shared_compress_busy),
      .i_compress_done(shared_compress_done),
      .i_compress_state(shared_compress_output_state),
      .o_mul_start(decaps_mul_start),
      .o_mul_runtime_r_bits(decaps_mul_r_bits),
      .o_mul_runtime_words(decaps_mul_words),
      .o_mul_runtime_sparse_weight(decaps_mul_sparse_weight),
      .o_mul_sparse_a(decaps_mul_sparse_a),
      .o_mul_a_valid(decaps_mul_a_valid),
      .o_mul_a_data(decaps_mul_a_data),
      .i_mul_a_ready(shared_mul_a_ready && (active_operation == OP_DECAPS)),
      .o_mul_sparse_index_valid(decaps_mul_sparse_index_valid),
      .o_mul_sparse_index(decaps_mul_sparse_index),
      .i_mul_sparse_index_ready(shared_mul_sparse_index_ready && (active_operation == OP_DECAPS)),
      .o_mul_b_valid(decaps_mul_b_valid),
      .o_mul_b_data(decaps_mul_b_data),
      .i_mul_b_ready(shared_mul_b_ready && (active_operation == OP_DECAPS)),
      .i_mul_result_valid(shared_mul_result_valid && (active_operation == OP_DECAPS)),
      .i_mul_result_data(shared_mul_result_data),
      .i_mul_result_last(shared_mul_result_last),
      .o_mul_result_ready(decaps_mul_result_ready),
      .o_sampler_start(decaps_sampler_start),
      .o_sampler_runtime_length(decaps_sampler_length),
      .o_sampler_runtime_weight(decaps_sampler_weight),
      .o_sampler_v(decaps_sampler_v),
      .o_sampler_c(decaps_sampler_c),
      .o_sampler_reseed_counter(decaps_sampler_reseed_counter),
      .i_sampler_index_valid(shared_sampler_index_valid && (active_operation == OP_DECAPS)),
      .i_sampler_index_position(shared_sampler_index_position),
      .i_sampler_index(shared_sampler_index),
      .o_sampler_index_ready(decaps_sampler_index_ready),
      .i_sampler_done(shared_sampler_done && (active_operation == OP_DECAPS)),
      .i_sampler_v(shared_sampler_output_v),
      .i_sampler_c(shared_sampler_output_c),
      .i_sampler_reseed_counter(shared_sampler_output_reseed_counter),
      .o_h4_store_start(decaps_h4_store_start),
      .o_h4_store_runtime_r_bits(decaps_h4_store_r_bits),
      .o_h4_store_runtime_error_weight(decaps_h4_store_error_weight),
      .o_h4_store_runtime_padded_r_bytes(decaps_h4_store_padded_r_bytes),
      .o_h4_store_index_valid(decaps_h4_store_index_valid),
      .o_h4_store_index_position(decaps_h4_store_index_position),
      .o_h4_store_index(decaps_h4_store_index),
      .i_h4_store_index_ready(shared_h4_store_index_ready && (active_operation == OP_DECAPS)),
      .o_h4_store_support_re(decaps_h4_store_support_re),
      .o_h4_store_support_raddr(decaps_h4_store_support_raddr),
      .i_h4_store_support_rdata(shared_h4_store_support_rdata),
      .o_h4_store_error_re(decaps_h4_store_error_re),
      .o_h4_store_error_raddr(decaps_h4_store_error_raddr),
      .i_h4_store_error_rdata(shared_h4_store_error_rdata),
      .i_h4_store_done(shared_h4_store_done && (active_operation == OP_DECAPS))
  );

  always_comb begin
    o_input_ready = 1'b0;
    o_pk_valid = 1'b0;
    o_pk_data = '0;
    o_pk_last = 1'b0;
    o_sk_valid = 1'b0;
    o_sk_data = '0;
    o_sk_last = 1'b0;
    o_ciphertext_valid = 1'b0;
    o_ciphertext_data = '0;
    o_ciphertext_last = 1'b0;
    o_shared_secret_valid = 1'b0;
    o_shared_secret_data = '0;
    o_shared_secret_last = 1'b0;
    shared_compress_start = 1'b0;
    shared_compress_block = '0;
    shared_compress_input_state = '0;
    shared_mul_start = 1'b0;
    shared_mul_r_bits = '0;
    shared_mul_words = '0;
    shared_mul_sparse_weight = '0;
    shared_mul_sparse_a = 1'b0;
    shared_mul_a_valid = 1'b0;
    shared_mul_a_data = '0;
    shared_mul_sparse_index_valid = 1'b0;
    shared_mul_sparse_index = '0;
    shared_mul_b_valid = 1'b0;
    shared_mul_b_data = '0;
    shared_mul_result_ready = 1'b0;
    shared_h123_start = 1'b0;
    shared_h123_seed_valid = 1'b0;
    shared_h123_seed_data = '0;
    shared_h123_vector_ready = 1'b0;
    shared_h123_t1_re = 1'b0;
    shared_h123_t1_raddr = '0;
    shared_h123_t2_re = 1'b0;
    shared_h123_t2_raddr = '0;
    shared_h123_r1_re = 1'b0;
    shared_h123_r1_raddr = '0;
    shared_sampler_start = 1'b0;
    shared_sampler_length = '0;
    shared_sampler_weight = '0;
    shared_sampler_input_v = '0;
    shared_sampler_input_c = '0;
    shared_sampler_input_reseed_counter = '0;
    shared_sampler_index_ready = 1'b0;
    shared_h4_store_start = 1'b0;
    shared_h4_store_r_bits = '0;
    shared_h4_store_error_weight = '0;
    shared_h4_store_padded_r_bytes = '0;
    shared_h4_store_index_valid = 1'b0;
    shared_h4_store_index_position = '0;
    shared_h4_store_index = '0;
    shared_h4_store_support_re = 1'b0;
    shared_h4_store_support_raddr = '0;
    shared_h4_store_error_re = 1'b0;
    shared_h4_store_error_raddr = '0;

    case (active_operation)
      OP_KEYGEN: begin
        o_input_ready = keygen_input_ready && o_busy;
        o_pk_valid = keygen_pk_valid;
        o_pk_data = keygen_pk_data;
        o_pk_last = keygen_pk_last;
        o_sk_valid = keygen_sk_valid;
        o_sk_data = keygen_sk_data;
        o_sk_last = keygen_sk_last;
        shared_compress_start = keygen_compress_start;
        shared_compress_block = keygen_compress_block;
        shared_compress_input_state = keygen_compress_state;
        shared_mul_start = keygen_mul_start;
        shared_mul_r_bits = keygen_mul_r_bits;
        shared_mul_words = keygen_mul_words;
        shared_mul_sparse_weight = keygen_mul_sparse_weight;
        shared_mul_sparse_a = keygen_mul_sparse_a;
        shared_mul_a_valid = keygen_mul_a_valid;
        shared_mul_a_data = keygen_mul_a_data;
        shared_mul_sparse_index_valid = keygen_mul_sparse_index_valid;
        shared_mul_sparse_index = keygen_mul_sparse_index;
        shared_mul_b_valid = keygen_mul_b_valid;
        shared_mul_b_data = keygen_mul_b_data;
        shared_mul_result_ready = keygen_mul_result_ready;
        shared_h123_start = keygen_h123_start;
        shared_h123_seed_valid = keygen_h123_seed_valid;
        shared_h123_seed_data = keygen_h123_seed_data;
        shared_h123_vector_ready = keygen_h123_vector_ready;
        shared_h123_t1_re = keygen_h123_t1_re;
        shared_h123_t1_raddr = keygen_h123_t1_raddr;
        shared_h123_t2_re = keygen_h123_t2_re;
        shared_h123_t2_raddr = keygen_h123_t2_raddr;
        shared_h123_r1_re = keygen_h123_r1_re;
        shared_h123_r1_raddr = keygen_h123_r1_raddr;
        shared_sampler_start = keygen_sampler_start;
        shared_sampler_length = keygen_sampler_length;
        shared_sampler_weight = keygen_sampler_weight;
        shared_sampler_input_v = keygen_sampler_v;
        shared_sampler_input_c = keygen_sampler_c;
        shared_sampler_input_reseed_counter = keygen_sampler_reseed_counter;
        shared_sampler_index_ready = keygen_sampler_index_ready;
      end
      OP_ENCAPS: begin
        o_input_ready = encaps_input_ready && o_busy;
        o_ciphertext_valid = encaps_ciphertext_valid;
        o_ciphertext_data = encaps_ciphertext_data;
        o_ciphertext_last = encaps_ciphertext_last;
        o_shared_secret_valid = encaps_shared_secret_valid;
        o_shared_secret_data = encaps_shared_secret_data;
        o_shared_secret_last = encaps_shared_secret_last;
        shared_compress_start = encaps_compress_start;
        shared_compress_block = encaps_compress_block;
        shared_compress_input_state = encaps_compress_state;
        shared_mul_start = encaps_mul_start;
        shared_mul_r_bits = encaps_mul_r_bits;
        shared_mul_words = encaps_mul_words;
        shared_mul_sparse_weight = encaps_mul_sparse_weight;
        shared_mul_sparse_a = encaps_mul_sparse_a;
        shared_mul_a_valid = encaps_mul_a_valid;
        shared_mul_a_data = encaps_mul_a_data;
        shared_mul_sparse_index_valid = encaps_mul_sparse_index_valid;
        shared_mul_sparse_index = encaps_mul_sparse_index;
        shared_mul_b_valid = encaps_mul_b_valid;
        shared_mul_b_data = encaps_mul_b_data;
        shared_mul_result_ready = encaps_mul_result_ready;
        shared_h123_start = encaps_h123_start;
        shared_h123_seed_valid = encaps_h123_seed_valid;
        shared_h123_seed_data = encaps_h123_seed_data;
        shared_h123_vector_ready = encaps_h123_vector_ready;
        shared_h123_t1_re = encaps_h123_t1_re;
        shared_h123_t1_raddr = encaps_h123_t1_raddr;
        shared_h123_t2_re = encaps_h123_t2_re;
        shared_h123_t2_raddr = encaps_h123_t2_raddr;
        shared_h123_r1_re = encaps_h123_r1_re;
        shared_h123_r1_raddr = encaps_h123_r1_raddr;
        shared_sampler_start = encaps_sampler_start;
        shared_sampler_length = encaps_sampler_length;
        shared_sampler_weight = encaps_sampler_weight;
        shared_sampler_input_v = encaps_sampler_v;
        shared_sampler_input_c = encaps_sampler_c;
        shared_sampler_input_reseed_counter = encaps_sampler_reseed_counter;
        shared_sampler_index_ready = encaps_sampler_index_ready;
        shared_h4_store_start = encaps_h4_store_start;
        shared_h4_store_r_bits = encaps_h4_store_r_bits;
        shared_h4_store_error_weight = encaps_h4_store_error_weight;
        shared_h4_store_padded_r_bytes = encaps_h4_store_padded_r_bytes;
        shared_h4_store_index_valid = encaps_h4_store_index_valid;
        shared_h4_store_index_position = SAMPLER_POSITION_W'(encaps_h4_store_index_position);
        shared_h4_store_index = SAMPLER_INDEX_W'(encaps_h4_store_index);
        shared_h4_store_support_re = encaps_h4_store_support_re;
        shared_h4_store_support_raddr = SAMPLER_POSITION_W'(encaps_h4_store_support_raddr);
        shared_h4_store_error_re = encaps_h4_store_error_re;
        shared_h4_store_error_raddr = H4_STORE_ERROR_ADDR_W'(encaps_h4_store_error_raddr);
      end
      OP_DECAPS: begin
        o_input_ready = decaps_input_ready && o_busy;
        o_shared_secret_valid = decaps_shared_secret_valid;
        o_shared_secret_data = decaps_shared_secret_data;
        o_shared_secret_last = decaps_shared_secret_last;
        shared_compress_start = decaps_compress_start;
        shared_compress_block = decaps_compress_block;
        shared_compress_input_state = decaps_compress_state;
        shared_mul_start = decaps_mul_start;
        shared_mul_r_bits = decaps_mul_r_bits;
        shared_mul_words = decaps_mul_words;
        shared_mul_sparse_weight = decaps_mul_sparse_weight;
        shared_mul_sparse_a = decaps_mul_sparse_a;
        shared_mul_a_valid = decaps_mul_a_valid;
        shared_mul_a_data = decaps_mul_a_data;
        shared_mul_sparse_index_valid = decaps_mul_sparse_index_valid;
        shared_mul_sparse_index = decaps_mul_sparse_index;
        shared_mul_b_valid = decaps_mul_b_valid;
        shared_mul_b_data = decaps_mul_b_data;
        shared_mul_result_ready = decaps_mul_result_ready;
        shared_sampler_start = decaps_sampler_start;
        shared_sampler_length = decaps_sampler_length;
        shared_sampler_weight = decaps_sampler_weight;
        shared_sampler_input_v = decaps_sampler_v;
        shared_sampler_input_c = decaps_sampler_c;
        shared_sampler_input_reseed_counter = decaps_sampler_reseed_counter;
        shared_sampler_index_ready = decaps_sampler_index_ready;
        shared_h4_store_start = decaps_h4_store_start;
        shared_h4_store_r_bits = decaps_h4_store_r_bits;
        shared_h4_store_error_weight = decaps_h4_store_error_weight;
        shared_h4_store_padded_r_bytes = decaps_h4_store_padded_r_bytes;
        shared_h4_store_index_valid = decaps_h4_store_index_valid;
        shared_h4_store_index_position = decaps_h4_store_index_position;
        shared_h4_store_index = decaps_h4_store_index;
        shared_h4_store_support_re = decaps_h4_store_support_re;
        shared_h4_store_support_raddr = decaps_h4_store_support_raddr;
        shared_h4_store_error_re = decaps_h4_store_error_re;
        shared_h4_store_error_raddr = decaps_h4_store_error_raddr;
      end
      default: ;
    endcase

    if (shared_h123_busy || shared_h123_start) begin
      shared_compress_start = shared_h123_compress_start;
      shared_compress_block = shared_h123_compress_block;
      shared_compress_input_state = shared_h123_compress_state;
    end
    if (shared_sampler_busy || shared_sampler_start) begin
      shared_compress_start = shared_sampler_compress_start;
      shared_compress_block = shared_sampler_compress_block;
      shared_compress_input_state = shared_sampler_compress_state;
    end
  end

  assign o_error = control_error || ((active_operation == OP_DECAPS) && decaps_error);

  /* verilator lint_off PINCONNECTEMPTY */
  trike_h123_vectors #(
      .M_BYTES              (32),
      .R_BITS               (15581),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_h123_service (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (shared_h123_start),
      .i_seed_valid    (shared_h123_seed_valid),
      .i_seed_data     (shared_h123_seed_data),
      .o_seed_ready    (shared_h123_seed_ready),
      .o_seed_pass     (),
      .o_vector_valid  (shared_h123_vector_valid),
      .o_vector_select (shared_h123_vector_select),
      .o_vector_byte   (shared_h123_vector_byte),
      .o_vector_data   (shared_h123_vector_data),
      .i_vector_ready  (shared_h123_vector_ready && shared_h123_store_vector_ready),
      .o_busy          (shared_h123_busy),
      .o_done          (shared_h123_done),
      .o_v             (),
      .o_c             (),
      .o_reseed_counter(),
      .o_compress_start(shared_h123_compress_start),
      .o_compress_block(shared_h123_compress_block),
      .o_compress_state(shared_h123_compress_state),
      .i_compress_busy (shared_compress_busy),
      .i_compress_done (shared_compress_done),
      .i_compress_state(shared_compress_output_state)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  trike_h123_vector_store #(
      .R_BITS(15581),
      .WORD_W(64)
  ) u_h123_store_service (
      .i_clk          (i_clk),
      .i_rst_n        (i_rst_n),
      .i_vector_valid (shared_h123_vector_valid && shared_h123_vector_ready),
      .i_vector_select(shared_h123_vector_select),
      .i_vector_byte  (shared_h123_vector_byte),
      .i_vector_data  (shared_h123_vector_data),
      .o_vector_ready (shared_h123_store_vector_ready),
      .i_t1_re        (shared_h123_t1_re),
      .i_t1_raddr     (shared_h123_t1_raddr),
      .o_t1_rdata     (shared_h123_t1_rdata),
      .i_t2_re        (shared_h123_t2_re),
      .i_t2_raddr     (shared_h123_t2_raddr),
      .o_t2_rdata     (shared_h123_t2_rdata),
      .i_r1_re        (shared_h123_r1_re),
      .i_r1_raddr     (shared_h123_r1_raddr),
      .o_r1_rdata     (shared_h123_r1_rdata)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  trike_drng_weight_sampler #(
      .LENGTH               (3 * P_R_VALS[3]),
      .WEIGHT               (P_T_VALS[3]),
      .RUNTIME_GEOMETRY     (1'b1),
      .USE_EXTERNAL_COMPRESS(1'b1)
  ) u_sampler_service (
      .i_clk           (i_clk),
      .i_rst_n         (i_rst_n),
      .i_start         (shared_sampler_start),
      .i_runtime_length(shared_sampler_length),
      .i_runtime_weight(shared_sampler_weight),
      .i_v             (shared_sampler_input_v),
      .i_c             (shared_sampler_input_c),
      .i_reseed_counter(shared_sampler_input_reseed_counter),
      .o_index_valid   (shared_sampler_index_valid),
      .o_index_position(shared_sampler_index_position),
      .o_index         (shared_sampler_index),
      .i_index_ready   (shared_sampler_index_ready),
      .o_busy          (shared_sampler_busy),
      .o_done          (shared_sampler_done),
      .o_v             (shared_sampler_output_v),
      .o_c             (shared_sampler_output_c),
      .o_reseed_counter(shared_sampler_output_reseed_counter),
      .o_compress_start(shared_sampler_compress_start),
      .o_compress_block(shared_sampler_compress_block),
      .o_compress_state(shared_sampler_compress_state),
      .i_compress_busy (shared_compress_busy),
      .i_compress_done (shared_compress_done),
      .i_compress_state(shared_compress_output_state)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  /* verilator lint_off PINCONNECTEMPTY */
  trike_error_support_store #(
      .R_BITS          (P_R_VALS[3]),
      .ERROR_WEIGHT    (P_T_VALS[3]),
      .PADDED_R_BYTES  (H4_STORE_PADDED_R_BYTES),
      .RUNTIME_GEOMETRY(1'b1)
  ) u_h4_store_service (
      .i_clk                   (i_clk),
      .i_rst_n                 (i_rst_n),
      .i_start                 (shared_h4_store_start),
      .i_runtime_r_bits        (shared_h4_store_r_bits),
      .i_runtime_error_weight  (shared_h4_store_error_weight),
      .i_runtime_padded_r_bytes(shared_h4_store_padded_r_bytes),
      .i_index_valid           (shared_h4_store_index_valid),
      .i_index_position        (shared_h4_store_index_position),
      .i_index                 (shared_h4_store_index),
      .o_index_ready           (shared_h4_store_index_ready),
      .i_support_re            (shared_h4_store_support_re),
      .i_support_raddr         (shared_h4_store_support_raddr),
      .o_support_rdata         (shared_h4_store_support_rdata),
      .i_error_re              (shared_h4_store_error_re),
      .i_error_raddr           (shared_h4_store_error_raddr),
      .o_error_rdata           (shared_h4_store_error_rdata),
      .o_busy                  (),
      .o_done                  (shared_h4_store_done)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  trike_sm3_service u_sm3_service (
      .i_clk  (i_clk),
      .i_rst_n(i_rst_n),
      .i_start(shared_compress_start),
      .i_block(shared_compress_block),
      .i_state(shared_compress_input_state),
      .o_busy (shared_compress_busy),
      .o_done (shared_compress_done),
      .o_state(shared_compress_output_state)
  );

  /* verilator lint_off PINCONNECTEMPTY */
  trike_poly_mul_core #(
      .R_BITS          (P_R_VALS[3]),
      .WORD_W          (64),
      .DIGIT_W         (16),
      .SPARSE_WEIGHT   (263),
      .RUNTIME_GEOMETRY(1'b1)
  ) u_poly_mul_service (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_start                (shared_mul_start),
      .i_runtime_r_bits       (shared_mul_r_bits),
      .i_runtime_words        (shared_mul_words),
      .i_runtime_sparse_weight(shared_mul_sparse_weight),
      .i_sparse_a             (shared_mul_sparse_a),
      .i_a_valid              (shared_mul_a_valid),
      .i_a_data               (shared_mul_a_data),
      .o_a_ready              (shared_mul_a_ready),
      .i_sparse_index_valid   (shared_mul_sparse_index_valid),
      .i_sparse_index         (shared_mul_sparse_index),
      .o_sparse_index_ready   (shared_mul_sparse_index_ready),
      .i_b_valid              (shared_mul_b_valid),
      .i_b_data               (shared_mul_b_data),
      .o_b_ready              (shared_mul_b_ready),
      .o_result_valid         (shared_mul_result_valid),
      .o_result_data          (shared_mul_result_data),
      .o_result_last          (shared_mul_result_last),
      .i_result_ready         (shared_mul_result_ready),
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
      .o_done                 (shared_mul_done)
  );
  /* verilator lint_on PINCONNECTEMPTY */

  /* verilator lint_off UNUSEDSIGNAL */
  logic unused_status;
  assign unused_status = ^{decaps_residual_weight, decaps_shared_secret_index, keygen_busy,
                           encaps_busy, decaps_busy};
  /* verilator lint_on UNUSEDSIGNAL */

endmodule
