#include "trike_ms_quant.h"

#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  int16_t *v2c;
  int16_t *c2v;
  int32_t *variable_sum;
  uint16_t *min1;
  uint16_t *min2;
  uint16_t *min_diag;
  uint8_t *sign_xor;
  uint8_t *residual;
} trike_ms_quant_workspace_t;

static void *checked_calloc(size_t count, size_t size) {
  if ((size != 0U) && (count > SIZE_MAX / size)) {
    return NULL;
  }
  return calloc(count, size);
}

static void free_workspace(trike_ms_quant_workspace_t *workspace) {
  if (workspace == NULL) {
    return;
  }
  free(workspace->v2c);
  free(workspace->c2v);
  free(workspace->variable_sum);
  free(workspace->min1);
  free(workspace->min2);
  free(workspace->min_diag);
  free(workspace->sign_xor);
  free(workspace->residual);
  memset(workspace, 0, sizeof(*workspace));
}

static int allocate_workspace(const trike_ms_quant_config_t *config,
                              trike_ms_quant_workspace_t *workspace) {
  const size_t n = (size_t)config->block_count * config->r;
  const size_t edge_count = n * config->w;

  memset(workspace, 0, sizeof(*workspace));
  workspace->v2c = checked_calloc(edge_count, sizeof(*workspace->v2c));
  workspace->c2v = checked_calloc(edge_count, sizeof(*workspace->c2v));
  workspace->variable_sum =
      checked_calloc(n, sizeof(*workspace->variable_sum));
  workspace->min1 = checked_calloc(config->r, sizeof(*workspace->min1));
  workspace->min2 = checked_calloc(config->r, sizeof(*workspace->min2));
  workspace->min_diag =
      checked_calloc(config->r, sizeof(*workspace->min_diag));
  workspace->sign_xor =
      checked_calloc(config->r, sizeof(*workspace->sign_xor));
  workspace->residual =
      checked_calloc(config->r, sizeof(*workspace->residual));

  if ((workspace->v2c == NULL) || (workspace->c2v == NULL) ||
      (workspace->variable_sum == NULL) || (workspace->min1 == NULL) ||
      (workspace->min2 == NULL) || (workspace->min_diag == NULL) ||
      (workspace->sign_xor == NULL) || (workspace->residual == NULL)) {
    free_workspace(workspace);
    return -1;
  }
  return 0;
}

static uint32_t edge_row(const trike_ms_quant_config_t *config,
                         const uint32_t *h_support, uint32_t block,
                         uint32_t column, uint32_t diag_idx) {
  uint32_t row =
      column + h_support[(size_t)block * config->w + diag_idx];
  if (row >= config->r) {
    row -= config->r;
  }
  return row;
}

static int32_t round_alpha(int32_t value, uint32_t shift_0,
                           uint32_t shift_1) {
  const uint32_t frac_bits = 6U;
  int64_t numerator = 0;
  int64_t product;
  int64_t magnitude;
  int64_t quotient;
  int64_t remainder;

  if ((shift_0 > 0U) && (shift_0 <= frac_bits)) {
    numerator += INT64_C(1) << (frac_bits - shift_0);
  }
  if ((shift_1 > 0U) && (shift_1 <= frac_bits)) {
    numerator += INT64_C(1) << (frac_bits - shift_1);
  }

  product = (int64_t)value * numerator;
  magnitude = (product < 0) ? -product : product;
  quotient = magnitude >> frac_bits;
  remainder = magnitude & ((INT64_C(1) << frac_bits) - 1);
  if ((remainder << 1) >= (INT64_C(1) << frac_bits)) {
    ++quotient;
  }
  return (int32_t)((product < 0) ? -quotient : quotient);
}

static int16_t saturate_message(int32_t value, uint32_t magnitude_max) {
  int32_t magnitude = (value < 0) ? -value : value;

  if (magnitude > (int32_t)magnitude_max) {
    magnitude = (int32_t)magnitude_max;
  }
  if (magnitude == 0) {
    return 0;
  }
  return (int16_t)((value < 0) ? -magnitude : magnitude);
}

static uint32_t magnitude_i16(int16_t value) {
  return (uint32_t)((value < 0) ? -value : value);
}

static uint32_t calculate_residual(
    const trike_ms_quant_config_t *config, const uint32_t *h_support,
    const uint8_t *syndrome, const uint8_t *error,
    trike_ms_quant_workspace_t *workspace) {
  const uint32_t n = config->block_count * config->r;
  uint32_t weight = 0U;

  memcpy(workspace->residual, syndrome,
         (size_t)config->r * sizeof(*workspace->residual));
  for (uint32_t variable = 0U; variable < n; ++variable) {
    const uint32_t block = variable / config->r;
    const uint32_t column = variable % config->r;

    if (error[variable] == 0U) {
      continue;
    }
    for (uint32_t diag_idx = 0U; diag_idx < config->w; ++diag_idx) {
      const uint32_t row =
          edge_row(config, h_support, block, column, diag_idx);
      workspace->residual[row] ^= 1U;
    }
  }
  for (uint32_t row = 0U; row < config->r; ++row) {
    weight += workspace->residual[row] != 0U;
  }
  return weight;
}

int trike_ms_quant_decode(const trike_ms_quant_config_t *config,
                          const uint32_t *h_support,
                          const uint8_t *syndrome,
                          uint8_t *error_out,
                          uint32_t *residual_weight_out) {
  trike_ms_quant_workspace_t workspace;
  size_t edge_count;
  uint32_t n;
  uint32_t magnitude_max;
  uint32_t residual_weight;

  if ((config == NULL) || (h_support == NULL) || (syndrome == NULL) ||
      (error_out == NULL) || (config->block_count != 3U) ||
      (config->r == 0U) || (config->w == 0U) ||
      (config->iterations == 0U) || (config->msg_bits < 2U) ||
      (config->msg_bits > 15U) ||
      ((uint64_t)config->block_count * config->w > UINT16_MAX)) {
    return -1;
  }

  n = config->block_count * config->r;
  edge_count = (size_t)n * config->w;
  magnitude_max = (UINT32_C(1) << (config->msg_bits - 1U)) - 1U;
  if (allocate_workspace(config, &workspace) != 0) {
    return -1;
  }

  memset(error_out, 0, (size_t)n * sizeof(*error_out));
  for (size_t edge = 0U; edge < edge_count; ++edge) {
    workspace.v2c[edge] = (int16_t)config->channel_value;
  }

  for (uint32_t iteration = 0U; iteration < config->iterations;
       ++iteration) {
    for (uint32_t row = 0U; row < config->r; ++row) {
      workspace.min1[row] = (uint16_t)magnitude_max;
      workspace.min2[row] = (uint16_t)magnitude_max;
      workspace.min_diag[row] = 0U;
      workspace.sign_xor[row] = 0U;
    }

    for (uint32_t variable = 0U; variable < n; ++variable) {
      const uint32_t block = variable / config->r;
      const uint32_t column = variable % config->r;
      const size_t edge_base = (size_t)variable * config->w;

      for (uint32_t diag_idx = 0U; diag_idx < config->w; ++diag_idx) {
        const int16_t message = workspace.v2c[edge_base + diag_idx];
        const uint32_t magnitude = magnitude_i16(message);
        const uint32_t row =
            edge_row(config, h_support, block, column, diag_idx);
        const uint16_t diag_global =
            (uint16_t)(block * config->w + diag_idx);

        if (message < 0) {
          workspace.sign_xor[row] ^= 1U;
        }
        if (magnitude <= workspace.min1[row]) {
          workspace.min2[row] = workspace.min1[row];
          workspace.min1[row] = (uint16_t)magnitude;
          workspace.min_diag[row] = diag_global;
        } else if (magnitude < workspace.min2[row]) {
          workspace.min2[row] = (uint16_t)magnitude;
        }
      }
    }

    memset(workspace.variable_sum, 0,
           (size_t)n * sizeof(*workspace.variable_sum));
    for (uint32_t variable = 0U; variable < n; ++variable) {
      const uint32_t block = variable / config->r;
      const uint32_t column = variable % config->r;
      const size_t edge_base = (size_t)variable * config->w;

      for (uint32_t diag_idx = 0U; diag_idx < config->w; ++diag_idx) {
        const int16_t input = workspace.v2c[edge_base + diag_idx];
        const uint32_t row =
            edge_row(config, h_support, block, column, diag_idx);
        const uint16_t diag_global =
            (uint16_t)(block * config->w + diag_idx);
        const uint32_t magnitude =
            (diag_global == workspace.min_diag[row])
                ? workspace.min2[row]
                : workspace.min1[row];
        const uint8_t sign = workspace.sign_xor[row] ^
                             (uint8_t)(input < 0) ^
                             (uint8_t)(syndrome[row] != 0U);
        const int16_t output =
            (int16_t)((sign != 0U && magnitude != 0U)
                          ? -(int32_t)magnitude
                          : (int32_t)magnitude);

        workspace.c2v[edge_base + diag_idx] = output;
        workspace.variable_sum[variable] += output;
      }
    }

    for (uint32_t variable = 0U; variable < n; ++variable) {
      const size_t edge_base = (size_t)variable * config->w;
      const int32_t posterior =
          (int32_t)config->channel_value +
          round_alpha(workspace.variable_sum[variable],
                      config->alpha_shift_0, config->alpha_shift_1);

      error_out[variable] = (uint8_t)(posterior < 0);
      for (uint32_t diag_idx = 0U; diag_idx < config->w; ++diag_idx) {
        const int32_t extrinsic =
            workspace.variable_sum[variable] -
            workspace.c2v[edge_base + diag_idx];
        const int32_t updated =
            (int32_t)config->channel_value +
            round_alpha(extrinsic, config->alpha_shift_0,
                        config->alpha_shift_1);

        workspace.v2c[edge_base + diag_idx] =
            saturate_message(updated, magnitude_max);
      }
    }
  }

  residual_weight = calculate_residual(config, h_support, syndrome,
                                       error_out, &workspace);
  if (residual_weight_out != NULL) {
    *residual_weight_out = residual_weight;
  }
  free_workspace(&workspace);
  return residual_weight == 0U ? 0 : 1;
}
