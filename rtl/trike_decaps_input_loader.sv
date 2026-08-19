`timescale 1ns / 1ps

// Runtime-public profile loader for the narrow Decaps byte stream. A profile
// is sampled only with i_start, so every accepted-byte count and RAM write
// window remains fixed for the complete transaction.
module trike_decaps_input_loader #(
    parameter int WORD_W = 64,
    parameter int M_BYTES = 32,
    parameter int MAX_R_BITS = bike_pkg::P_R_VALS[3],
    parameter int MAX_SECRET_WEIGHT = bike_pkg::P_W_VALS[3],
    parameter int INPUT_ADDR_W = $clog2(
        (3 * MAX_SECRET_WEIGHT * 4) + (5 * ((MAX_R_BITS + 7) / 8)) + (3 * M_BYTES)
    ),
    parameter int SUPPORT_ADDR_W = $clog2(3 * MAX_SECRET_WEIGHT),
    parameter int ROW_ADDR_W = $clog2(MAX_R_BITS),
    parameter int WORD_ADDR_W = $clog2((MAX_R_BITS + WORD_W - 1) / WORD_W),
    parameter int R_ADDR_W = $clog2((MAX_R_BITS + 7) / 8),
    parameter int CT_ADDR_W = $clog2((2 * ((MAX_R_BITS + 7) / 8)) + M_BYTES),
    parameter int SIGMA_ADDR_W = $clog2(M_BYTES)
) (
    input  logic                              i_clk,
    input  logic                              i_rst_n,
    input  logic                              i_start,
    input  logic [bike_pkg::PROFILE_ID_W-1:0] i_param_level,
    input  logic                              i_valid,
    input  logic [                       7:0] i_data,
    output logic                              o_ready,
    output logic                              o_support_we,
    output logic [        SUPPORT_ADDR_W-1:0] o_support_waddr,
    output logic [            ROW_ADDR_W-1:0] o_support_wdata,
    output logic                              o_t0_we,
    output logic [           WORD_ADDR_W-1:0] o_t0_waddr,
    output logic [                WORD_W-1:0] o_t0_wdata,
    output logic                              o_r2_we,
    output logic [              R_ADDR_W-1:0] o_r2_waddr,
    output logic [                       7:0] o_r2_wdata,
    output logic                              o_u_we,
    output logic [           WORD_ADDR_W-1:0] o_u_waddr,
    output logic [                WORD_W-1:0] o_u_wdata,
    output logic                              o_v_we,
    output logic [           WORD_ADDR_W-1:0] o_v_waddr,
    output logic [                WORD_W-1:0] o_v_wdata,
    output logic                              o_ct_we,
    output logic [             CT_ADDR_W-1:0] o_ct_waddr,
    output logic [                       7:0] o_ct_wdata,
    output logic                              o_sigma2_we,
    output logic [          SIGMA_ADDR_W-1:0] o_sigma2_waddr,
    output logic [                       7:0] o_sigma2_wdata,
    output logic [bike_pkg::PROFILE_ID_W-1:0] o_param_level,
    output logic [                      31:0] o_r_bits,
    output logic [                      31:0] o_secret_weight,
    output logic [                      31:0] o_error_weight,
    output logic [                      31:0] o_r_bytes,
    output logic [                      31:0] o_padded_r_bytes,
    output logic [                      31:0] o_words,
    output logic [                      31:0] o_support_count,
    output logic [                      31:0] o_secret_key_bytes,
    output logic [                      31:0] o_ciphertext_bytes,
    output logic [                      31:0] o_input_bytes,
    output logic [                      31:0] o_error_bytes,
    output logic                              o_busy,
    output logic                              o_done
);
  import bike_pkg::*;

  localparam int WORD_BYTES = WORD_W / 8;

  typedef enum logic {
    ST_IDLE,
    ST_LOAD
  } state_t;

  state_t                    state_q;
  logic   [INPUT_ADDR_W-1:0] input_count_q;
  logic   [            31:0] support_bytes_q;
  logic   [            31:0] r_bytes_q;
  logic   [            31:0] secret_key_bytes_q;
  logic   [            31:0] input_bytes_q;
  logic   [            31:0] profile_r_bits_c;
  logic   [            31:0] profile_secret_weight_c;
  logic   [            31:0] profile_error_weight_c;
  logic   [            31:0] profile_r_bytes_c;
  logic   [            31:0] profile_padded_r_bytes_c;
  logic   [            31:0] profile_words_c;
  logic   [            31:0] profile_support_count_c;
  logic   [            31:0] profile_support_bytes_c;
  logic   [            31:0] profile_secret_key_bytes_c;
  logic   [            31:0] profile_ciphertext_bytes_c;
  logic   [            31:0] profile_input_bytes_c;
  logic   [            31:0] profile_error_bytes_c;
  logic   [            31:0] input_index_c;
  integer                    t0_byte_c;
  integer                    r2_byte_c;
  integer                    sigma2_byte_c;
  integer                    ct_byte_c;
  integer                    u_byte_c;
  integer                    v_byte_c;
  logic   [            31:0] t0_offset_c;
  logic   [            31:0] r2_offset_c;
  logic   [            31:0] sigma2_offset_c;
  logic   [            31:0] v_offset_c;
  logic   [            31:0] support_word_c;
  logic   [      WORD_W-1:0] t0_word_c;
  logic   [      WORD_W-1:0] u_word_c;
  logic   [      WORD_W-1:0] v_word_c;
  logic   [            31:0] support_accum_q;
  logic   [      WORD_W-1:0] t0_accum_q;
  logic   [      WORD_W-1:0] u_accum_q;
  logic   [      WORD_W-1:0] v_accum_q;
  logic                      accept_c;

  trike_decaps_profile_config u_profile_config (
      .i_param_level     (i_param_level),
      .o_r_bits          (profile_r_bits_c),
      .o_secret_weight   (profile_secret_weight_c),
      .o_error_weight    (profile_error_weight_c),
      .o_r_bytes         (profile_r_bytes_c),
      .o_padded_r_bytes  (profile_padded_r_bytes_c),
      .o_words           (profile_words_c),
      .o_support_count   (profile_support_count_c),
      .o_support_bytes   (profile_support_bytes_c),
      .o_secret_key_bytes(profile_secret_key_bytes_c),
      .o_ciphertext_bytes(profile_ciphertext_bytes_c),
      .o_input_bytes     (profile_input_bytes_c),
      .o_error_bytes     (profile_error_bytes_c)
  );

  assign o_ready  = state_q == ST_LOAD;
  assign o_busy   = state_q != ST_IDLE;
  assign accept_c = o_ready && i_valid;

  always_comb begin
    input_index_c = 32'(input_count_q);
    t0_offset_c = support_bytes_q + r_bytes_q;
    r2_offset_c = support_bytes_q + (2 * r_bytes_q);
    sigma2_offset_c = support_bytes_q + (3 * r_bytes_q) + M_BYTES;
    v_offset_c = secret_key_bytes_q + r_bytes_q;
    t0_byte_c = int'(input_index_c) - int'(t0_offset_c);
    r2_byte_c = int'(input_index_c) - int'(r2_offset_c);
    sigma2_byte_c = int'(input_index_c) - int'(sigma2_offset_c);
    ct_byte_c = int'(input_index_c) - int'(secret_key_bytes_q);
    u_byte_c = ct_byte_c;
    v_byte_c = int'(input_index_c) - int'(v_offset_c);

    support_word_c = support_accum_q;
    t0_word_c = t0_accum_q;
    u_word_c = u_accum_q;
    v_word_c = v_accum_q;
    o_support_we = 1'b0;
    o_support_waddr = '0;
    o_support_wdata = '0;
    o_t0_we = 1'b0;
    o_t0_waddr = '0;
    o_t0_wdata = '0;
    o_r2_we = 1'b0;
    o_r2_waddr = '0;
    o_r2_wdata = i_data;
    o_u_we = 1'b0;
    o_u_waddr = '0;
    o_u_wdata = '0;
    o_v_we = 1'b0;
    o_v_waddr = '0;
    o_v_wdata = '0;
    o_ct_we = 1'b0;
    o_ct_waddr = '0;
    o_ct_wdata = i_data;
    o_sigma2_we = 1'b0;
    o_sigma2_waddr = '0;
    o_sigma2_wdata = i_data;

    if (accept_c && (input_index_c < support_bytes_q)) begin
      support_word_c[8*(input_index_c%4)+:8] = i_data;
      if ((input_index_c % 4) == 3) begin
        o_support_we = 1'b1;
        o_support_waddr = SUPPORT_ADDR_W'(input_index_c / 4);
        o_support_wdata = support_word_c[ROW_ADDR_W-1:0];
      end
    end

    if (accept_c && (t0_byte_c >= 0) && (t0_byte_c < int'(r_bytes_q))) begin
      t0_word_c[8*(t0_byte_c%WORD_BYTES)+:8] = i_data;
      if (((t0_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) ||
          (t0_byte_c == int'(r_bytes_q) - 1)) begin
        o_t0_we = 1'b1;
        o_t0_waddr = WORD_ADDR_W'(t0_byte_c / WORD_BYTES);
        o_t0_wdata = t0_word_c;
      end
    end

    if (accept_c && (r2_byte_c >= 0) && (r2_byte_c < int'(r_bytes_q))) begin
      o_r2_we = 1'b1;
      o_r2_waddr = R_ADDR_W'(r2_byte_c);
    end

    if (accept_c && (ct_byte_c >= 0) && (input_index_c < input_bytes_q)) begin
      o_ct_we = 1'b1;
      o_ct_waddr = CT_ADDR_W'(ct_byte_c);
    end

    if (accept_c && (u_byte_c >= 0) && (u_byte_c < int'(r_bytes_q))) begin
      u_word_c[8*(u_byte_c%WORD_BYTES)+:8] = i_data;
      if (((u_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (u_byte_c == int'(r_bytes_q) - 1)) begin
        o_u_we = 1'b1;
        o_u_waddr = WORD_ADDR_W'(u_byte_c / WORD_BYTES);
        o_u_wdata = u_word_c;
      end
    end

    if (accept_c && (v_byte_c >= 0) && (v_byte_c < int'(r_bytes_q))) begin
      v_word_c[8*(v_byte_c%WORD_BYTES)+:8] = i_data;
      if (((v_byte_c % WORD_BYTES) == (WORD_BYTES - 1)) || (v_byte_c == int'(r_bytes_q) - 1)) begin
        o_v_we = 1'b1;
        o_v_waddr = WORD_ADDR_W'(v_byte_c / WORD_BYTES);
        o_v_wdata = v_word_c;
      end
    end

    if (accept_c && (sigma2_byte_c >= 0) && (sigma2_byte_c < M_BYTES)) begin
      o_sigma2_we = 1'b1;
      o_sigma2_waddr = SIGMA_ADDR_W'(sigma2_byte_c);
    end
  end

  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      state_q <= ST_IDLE;
      input_count_q <= '0;
      support_bytes_q <= '0;
      r_bytes_q <= '0;
      secret_key_bytes_q <= '0;
      input_bytes_q <= '0;
      support_accum_q <= '0;
      t0_accum_q <= '0;
      u_accum_q <= '0;
      v_accum_q <= '0;
      o_param_level <= PROFILE_TRIKE_160;
      o_r_bits <= '0;
      o_secret_weight <= '0;
      o_error_weight <= '0;
      o_r_bytes <= '0;
      o_padded_r_bytes <= '0;
      o_words <= '0;
      o_support_count <= '0;
      o_secret_key_bytes <= '0;
      o_ciphertext_bytes <= '0;
      o_input_bytes <= '0;
      o_error_bytes <= '0;
      o_done <= 1'b0;
    end else begin
      o_done <= 1'b0;
      unique case (state_q)
        ST_IDLE: begin
          if (i_start) begin
            input_count_q <= '0;
            support_bytes_q <= profile_support_bytes_c;
            r_bytes_q <= profile_r_bytes_c;
            secret_key_bytes_q <= profile_secret_key_bytes_c;
            input_bytes_q <= profile_input_bytes_c;
            support_accum_q <= '0;
            t0_accum_q <= '0;
            u_accum_q <= '0;
            v_accum_q <= '0;
            o_param_level <= i_param_level;
            o_r_bits <= profile_r_bits_c;
            o_secret_weight <= profile_secret_weight_c;
            o_error_weight <= profile_error_weight_c;
            o_r_bytes <= profile_r_bytes_c;
            o_padded_r_bytes <= profile_padded_r_bytes_c;
            o_words <= profile_words_c;
            o_support_count <= profile_support_count_c;
            o_secret_key_bytes <= profile_secret_key_bytes_c;
            o_ciphertext_bytes <= profile_ciphertext_bytes_c;
            o_input_bytes <= profile_input_bytes_c;
            o_error_bytes <= profile_error_bytes_c;
            state_q <= ST_LOAD;
          end
        end
        ST_LOAD: begin
          if (accept_c) begin
            if ((input_index_c < support_bytes_q) && ((input_index_c % 4) != 3))
              support_accum_q <= support_word_c;
            else if ((input_index_c < support_bytes_q) && ((input_index_c % 4) == 3))
              support_accum_q <= '0;

            if ((t0_byte_c >= 0) && (t0_byte_c < int'(r_bytes_q))) begin
              if (o_t0_we) t0_accum_q <= '0;
              else t0_accum_q <= t0_word_c;
            end
            if ((u_byte_c >= 0) && (u_byte_c < int'(r_bytes_q))) begin
              if (o_u_we) u_accum_q <= '0;
              else u_accum_q <= u_word_c;
            end
            if ((v_byte_c >= 0) && (v_byte_c < int'(r_bytes_q))) begin
              if (o_v_we) v_accum_q <= '0;
              else v_accum_q <= v_word_c;
            end

            if (input_index_c == (input_bytes_q - 1)) begin
              o_done  <= 1'b1;
              state_q <= ST_IDLE;
            end else begin
              input_count_q <= input_count_q + 1'b1;
            end
          end
        end
        default: state_q <= ST_IDLE;
      endcase
    end
  end

`ifndef SYNTHESIS
  initial begin
    if ((WORD_W % 8) != 0) $fatal(1, "trike_decaps_input_loader requires byte words");
    if (M_BYTES != 32) $fatal(1, "trike_decaps_input_loader requires 32-byte messages");
  end
`endif

endmodule
