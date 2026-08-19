`timescale 1ns / 1ps

// Public TRIKE Min-Sum Decaps transaction geometry. The selected profile
// determines fixed byte counts and memory scan bounds; no private input is
// consumed by this combinational descriptor.
module trike_decaps_profile_config
  import bike_pkg::*;
(
    input  logic [PROFILE_ID_W-1:0] i_param_level,
    output logic [            31:0] o_r_bits,
    output logic [            31:0] o_secret_weight,
    output logic [            31:0] o_error_weight,
    output logic [            31:0] o_r_bytes,
    output logic [            31:0] o_padded_r_bytes,
    output logic [            31:0] o_words,
    output logic [            31:0] o_support_count,
    output logic [            31:0] o_support_bytes,
    output logic [            31:0] o_secret_key_bytes,
    output logic [            31:0] o_ciphertext_bytes,
    output logic [            31:0] o_input_bytes,
    output logic [            31:0] o_error_bytes
);

  localparam int M_BYTES = 32;
  localparam int WORD_W  = 64;

  logic   [PROFILE_ID_W-1:0] profile_idx_c;
  integer                    r_bits_c;
  integer                    secret_weight_c;
  integer                    error_weight_c;
  integer                    r_bytes_c;
  integer                    padded_r_bytes_c;
  integer                    words_c;
  integer                    support_count_c;
  integer                    support_bytes_c;
  integer                    secret_key_bytes_c;
  integer                    ciphertext_bytes_c;

  always_comb begin
    unique case (i_param_level)
      PROFILE_TRIKE_160: profile_idx_c = PROFILE_TRIKE_160;
      PROFILE_TRIKE_256: profile_idx_c = PROFILE_TRIKE_256;
      PROFILE_TRIKE_384: profile_idx_c = PROFILE_TRIKE_384;
      default:           profile_idx_c = PROFILE_TRIKE_512;
    endcase

    r_bits_c = P_R_VALS[profile_idx_c];
    secret_weight_c = P_W_VALS[profile_idx_c];
    error_weight_c = P_T_VALS[profile_idx_c];
    r_bytes_c = (r_bits_c + 7) / 8;
    padded_r_bytes_c = ((r_bits_c + 511) / 512) * 64;
    words_c = (r_bits_c + WORD_W - 1) / WORD_W;
    support_count_c = N0 * secret_weight_c;
    support_bytes_c = support_count_c * 4;
    secret_key_bytes_c = support_bytes_c + (N0 * r_bytes_c) + (2 * M_BYTES);
    ciphertext_bytes_c = (2 * r_bytes_c) + M_BYTES;

    o_r_bits = 32'(r_bits_c);
    o_secret_weight = 32'(secret_weight_c);
    o_error_weight = 32'(error_weight_c);
    o_r_bytes = 32'(r_bytes_c);
    o_padded_r_bytes = 32'(padded_r_bytes_c);
    o_words = 32'(words_c);
    o_support_count = 32'(support_count_c);
    o_support_bytes = 32'(support_bytes_c);
    o_secret_key_bytes = 32'(secret_key_bytes_c);
    o_ciphertext_bytes = 32'(ciphertext_bytes_c);
    o_input_bytes = 32'(secret_key_bytes_c + ciphertext_bytes_c);
    o_error_bytes = 32'(N0 * padded_r_bytes_c);
  end

`ifndef SYNTHESIS
  initial begin
    if (N0 != 3) $fatal(1, "trike_decaps_profile_config requires three TRIKE blocks");
    if (PROFILE_COUNT != 4) $fatal(1, "trike_decaps_profile_config requires four profiles");
  end
`endif

endmodule
