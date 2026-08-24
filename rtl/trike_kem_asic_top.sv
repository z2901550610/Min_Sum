`timescale 1ns / 1ps

// Single-issue TRIKE KEM integration boundary. i_operation is public and is
// latched for the full transaction: 0=KeyGen, 1=Encaps, 2=Decaps. All three
// modes share one SM3 compression service and one runtime-geometry streaming
// polynomial multiplier; inactive modes receive no start or input traffic.
// KeyGen/Encaps use the official TRIKE-2 geometry while Decaps retains the
// validated runtime K-sign profile table.
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

  logic                 keygen_start;
  logic                 encaps_start;
  logic                 decaps_start;
  logic [          1:0] active_operation;
  logic                 control_error;

  logic                 keygen_input_ready;
  logic                 keygen_pk_valid;
  logic [          7:0] keygen_pk_data;
  logic                 keygen_pk_last;
  logic                 keygen_sk_valid;
  logic [          7:0] keygen_sk_data;
  logic                 keygen_sk_last;
  logic                 keygen_busy;
  logic                 keygen_done;
  logic                 keygen_compress_start;
  logic [        511:0] keygen_compress_block;
  logic [        255:0] keygen_compress_state;
  logic                 keygen_mul_start;
  logic [         31:0] keygen_mul_r_bits;
  logic [         31:0] keygen_mul_words;
  logic [         31:0] keygen_mul_sparse_weight;
  logic                 keygen_mul_sparse_a;
  logic                 keygen_mul_a_valid;
  logic [         63:0] keygen_mul_a_data;
  logic                 keygen_mul_sparse_index_valid;
  logic [ROW_IDX_W-1:0] keygen_mul_sparse_index;
  logic                 keygen_mul_b_valid;
  logic [         63:0] keygen_mul_b_data;
  logic                 keygen_mul_result_ready;

  logic                 encaps_input_ready;
  logic                 encaps_ciphertext_valid;
  logic [          7:0] encaps_ciphertext_data;
  logic                 encaps_ciphertext_last;
  logic                 encaps_shared_secret_valid;
  logic [          7:0] encaps_shared_secret_data;
  logic                 encaps_shared_secret_last;
  logic                 encaps_busy;
  logic                 encaps_done;
  logic                 encaps_compress_start;
  logic [        511:0] encaps_compress_block;
  logic [        255:0] encaps_compress_state;
  logic                 encaps_mul_start;
  logic [         31:0] encaps_mul_r_bits;
  logic [         31:0] encaps_mul_words;
  logic [         31:0] encaps_mul_sparse_weight;
  logic                 encaps_mul_sparse_a;
  logic                 encaps_mul_a_valid;
  logic [         63:0] encaps_mul_a_data;
  logic                 encaps_mul_sparse_index_valid;
  logic [ROW_IDX_W-1:0] encaps_mul_sparse_index;
  logic                 encaps_mul_b_valid;
  logic [         63:0] encaps_mul_b_data;
  logic                 encaps_mul_result_ready;

  logic                 decaps_input_ready;
  logic                 decaps_shared_secret_valid;
  logic [          7:0] decaps_shared_secret_data;
  logic                 decaps_shared_secret_last;
  logic                 decaps_error;
  logic                 decaps_busy;
  logic                 decaps_done;
  logic                 decaps_compress_start;
  logic [        511:0] decaps_compress_block;
  logic [        255:0] decaps_compress_state;
  logic [ROW_IDX_W-1:0] decaps_residual_weight;
  logic [          4:0] decaps_shared_secret_index;
  logic                 decaps_mul_start;
  logic [         31:0] decaps_mul_r_bits;
  logic [         31:0] decaps_mul_words;
  logic [         31:0] decaps_mul_sparse_weight;
  logic                 decaps_mul_sparse_a;
  logic                 decaps_mul_a_valid;
  logic [         63:0] decaps_mul_a_data;
  logic                 decaps_mul_sparse_index_valid;
  logic [ROW_IDX_W-1:0] decaps_mul_sparse_index;
  logic                 decaps_mul_b_valid;
  logic [         63:0] decaps_mul_b_data;
  logic                 decaps_mul_result_ready;

  logic                 shared_compress_start;
  logic [        511:0] shared_compress_block;
  logic [        255:0] shared_compress_input_state;
  logic                 shared_compress_busy;
  logic                 shared_compress_done;
  logic [        255:0] shared_compress_output_state;

  logic                 shared_mul_start;
  logic [         31:0] shared_mul_r_bits;
  logic [         31:0] shared_mul_words;
  logic [         31:0] shared_mul_sparse_weight;
  logic                 shared_mul_sparse_a;
  logic                 shared_mul_a_valid;
  logic [         63:0] shared_mul_a_data;
  logic                 shared_mul_a_ready;
  logic                 shared_mul_sparse_index_valid;
  logic [ROW_IDX_W-1:0] shared_mul_sparse_index;
  logic                 shared_mul_sparse_index_ready;
  logic                 shared_mul_b_valid;
  logic [         63:0] shared_mul_b_data;
  logic                 shared_mul_b_ready;
  logic                 shared_mul_result_valid;
  logic [         63:0] shared_mul_result_data;
  logic                 shared_mul_result_last;
  logic                 shared_mul_result_ready;
  logic                 shared_mul_done;

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
      .M_BYTES              (32),
      .R_BITS               (15581),
      .SECRET_WEIGHT        (35),
      .CANDIDATE_COUNT      (16),
      .WORD_W               (64),
      .DIGIT_W              (16),
      .USE_EXTERNAL_COMPRESS(1'b1),
      .USE_EXTERNAL_MUL     (1'b1),
      .MUL_INDEX_W          (ROW_IDX_W)
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
      .i_mul_done(shared_mul_done && (active_operation == OP_KEYGEN))
  );

  trike_encaps_core #(
      .M_BYTES              (32),
      .R_BITS               (15581),
      .ERROR_WEIGHT         (263),
      .WORD_W               (64),
      .USE_EXTERNAL_COMPRESS(1'b1),
      .USE_EXTERNAL_MUL     (1'b1),
      .MUL_INDEX_W          (ROW_IDX_W)
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
      .o_mul_result_ready(encaps_mul_result_ready)
  );

  trike_decaps_unified_core #(
      .USE_EXTERNAL_COMPRESS(1'b1),
      .USE_EXTERNAL_MUL     (1'b1)
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
      .o_mul_result_ready(decaps_mul_result_ready)
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
      end
      default: ;
    endcase
  end

  assign o_error = control_error || ((active_operation == OP_DECAPS) && decaps_error);

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
