#ifndef TRIKE_MS_QUANT_H
#define TRIKE_MS_QUANT_H

#include <stdint.h>

typedef struct {
  uint32_t block_count;
  uint32_t r;
  uint32_t w;
  uint32_t iterations;
  uint32_t msg_bits;
  uint32_t channel_value;
  uint32_t alpha_shift_0;
  uint32_t alpha_shift_1;
} trike_ms_quant_config_t;

/*
 * Decode one three-block TRIKE syndrome with the fixed-iteration,
 * hardware-style quantized Min-Sum schedule used by myTRIKE ms_quant.
 *
 * h_support contains block_count consecutive support lists of w positions.
 * syndrome contains r binary coefficients. error_out contains block_count*r
 * binary coefficients on return.
 *
 * Returns 0 when the decoded word has zero residual syndrome, 1 when the
 * fixed iteration budget finishes with a nonzero residual, and -1 for invalid
 * arguments or allocation failure.
 */
int trike_ms_quant_decode(const trike_ms_quant_config_t *config,
                          const uint32_t *h_support,
                          const uint8_t *syndrome,
                          uint8_t *error_out,
                          uint32_t *residual_weight_out);

#endif
