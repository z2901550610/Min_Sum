#define _POSIX_C_SOURCE 200809L

#if defined(__APPLE__)
#define _DARWIN_C_SOURCE
#endif

#include <errno.h>
#include <getopt.h>
#include <inttypes.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#if defined(__APPLE__)
#include <sys/types.h>
#include <sys/sysctl.h>
#endif

typedef struct {
  const char *name;
  uint32_t n0;
  uint32_t r;
  uint32_t w;
  uint32_t t;
  uint32_t iterations;
  uint32_t msg_bits;
  uint32_t c_val;
  uint32_t alpha_shift_0;
  uint32_t alpha_shift_1;
} decoder_config_t;

typedef struct {
  uint64_t state;
} rng_t;

typedef struct {
  uint64_t v2c_zero;
  uint64_t v2c_saturated;
  uint64_t c2v_zero;
  uint64_t c2v_saturated;
  uint64_t min_equal;
  uint64_t checks;
  uint64_t edges;
  uint64_t *v2c_hist;
  uint64_t *c2v_hist;
} iteration_stats_t;

typedef struct {
  uint32_t *h_base;
  uint8_t *target_error;
  uint8_t *syndrome;
  int16_t *v2c;
  int16_t *c2v;
  int32_t *variable_sum;
  uint16_t *min1;
  uint16_t *min2;
  uint16_t *min_diag_idx_global;
  uint8_t *sign_xor;
  uint8_t *decision;
  uint8_t *residual;
} decoder_buffers_t;

typedef struct {
  uint64_t seed;
  uint32_t decision_weight;
  uint32_t residual_weight;
  bool exact;
  double seconds;
} trial_result_t;

typedef struct {
  const decoder_config_t *config;
  uint64_t base_seed;
  uint32_t trials;
  uint32_t worker_idx;
  uint32_t worker_count;
  bool print_stats;
  trial_result_t *results;
} worker_args_t;

typedef struct {
  decoder_config_t config;
  uint64_t seed;
  uint32_t *h_base;
  uint32_t *error_positions;
  uint32_t syndrome_weight;
  uint32_t *syndrome_positions;
} fixture_case_t;

static const decoder_config_t k_profiles[] = {
    {"toy", 2, 8, 3, 1, 4, 5, 2, 1, 3},
    {"trike128", 3, 8117, 27, 201, 7, 5, 5, 3, 4},
    {"trike160", 3, 12739, 35, 263, 7, 5, 5, 3, 4},
    {"trike256", 3, 29501, 55, 429, 7, 5, 5, 3, 4},
    {"trike384", 3, 61283, 83, 659, 7, 5, 5, 3, 6},
    {"trike512", 3, 108587, 111, 877, 7, 5, 7, 4, 0},
    {"bike128", 2, 12323, 71, 134, 7, 5, 5, 3, 4},
    {"bike192", 2, 24659, 103, 199, 7, 5, 5, 3, 4},
    {"bike256", 2, 40973, 137, 264, 7, 5, 5, 3, 4},
};

static void *checked_calloc(size_t count, size_t size, const char *name);

static void usage(FILE *stream, const char *program) {
  fprintf(stream,
          "Usage: %s [options]\n"
          "\n"
          "Run a fixed-iteration QC-MDPC syndrome min-sum model.\n"
          "\n"
          "Options:\n"
          "  --profile NAME          toy, trike128, trike160, trike256, trike384,"
          " trike512, bike128, bike192, or bike256\n"
          "  --seed N                first trial seed (default: 1)\n"
          "  --trials N              number of generated cases (default: 1)\n"
          "  --threads N             parallel trial workers; 0 uses online CPUs\n"
          "  --r N                   circulant size\n"
          "  --w N                   column weight per circulant block\n"
          "  --errors N              generated error weight\n"
          "  --iterations N          fixed decoding iteration count\n"
          "  --msg-bits N            sign plus magnitude bits\n"
          "  --c-val N               positive channel constant C\n"
          "  --alpha-shift-0 N       first alpha shift\n"
          "  --alpha-shift-1 N       second alpha shift\n"
          "  --fixture-in PATH       read one shared RTL/C fixture\n"
          "  --decision-out PATH     write decoded nonzero column positions\n"
          "  --stats                  print per-iteration message statistics\n"
          "  --csv PATH               write one summary row per trial\n"
          "  --help                   show this help\n"
          "\n"
          "Alpha is 2^(-alpha-shift-0) + 2^(-alpha-shift-1).\n",
          program);
}

static bool parse_u32(const char *text, uint32_t *value) {
  char *end = NULL;
  unsigned long parsed;

  errno = 0;
  parsed = strtoul(text, &end, 0);
  if ((errno != 0) || (end == text) || (*end != '\0') || (parsed > UINT32_MAX)) {
    return false;
  }
  *value = (uint32_t)parsed;
  return true;
}

static const decoder_config_t *find_profile(const char *name) {
  size_t profile_count = sizeof(k_profiles) / sizeof(k_profiles[0]);
  for (size_t idx = 0; idx < profile_count; ++idx) {
    if (strcmp(name, k_profiles[idx].name) == 0) {
      return &k_profiles[idx];
    }
  }
  return NULL;
}

static bool expect_token(FILE *file, const char *expected) {
  char token[64];
  if ((fscanf(file, "%63s", token) != 1) || (strcmp(token, expected) != 0)) {
    fprintf(stderr, "fixture parse error: expected %s\n", expected);
    return false;
  }
  return true;
}

static bool read_fixture(const char *path, fixture_case_t *fixture) {
  FILE *file = fopen(path, "r");
  char header[64];
  uint32_t error_count;

  memset(fixture, 0, sizeof(*fixture));
  if (file == NULL) {
    fprintf(stderr, "cannot open fixture %s: %s\n", path, strerror(errno));
    return false;
  }
  fixture->config.name = "fixture";
  if ((fscanf(file, "%63s", header) != 1) || (strcmp(header, "MIN_SUM_FIXTURE_V1") != 0) ||
      !expect_token(file, "seed") || (fscanf(file, "%" SCNu64, &fixture->seed) != 1) ||
      !expect_token(file, "n0") || (fscanf(file, "%" SCNu32, &fixture->config.n0) != 1) ||
      !expect_token(file, "r") || (fscanf(file, "%" SCNu32, &fixture->config.r) != 1) ||
      !expect_token(file, "w") || (fscanf(file, "%" SCNu32, &fixture->config.w) != 1) ||
      !expect_token(file, "error_count") || (fscanf(file, "%" SCNu32, &error_count) != 1) ||
      !expect_token(file, "iterations") ||
      (fscanf(file, "%" SCNu32, &fixture->config.iterations) != 1) ||
      !expect_token(file, "msg_bits") ||
      (fscanf(file, "%" SCNu32, &fixture->config.msg_bits) != 1) ||
      !expect_token(file, "c_val") ||
      (fscanf(file, "%" SCNu32, &fixture->config.c_val) != 1) ||
      !expect_token(file, "alpha_shift_0") ||
      (fscanf(file, "%" SCNu32, &fixture->config.alpha_shift_0) != 1) ||
      !expect_token(file, "alpha_shift_1") ||
      (fscanf(file, "%" SCNu32, &fixture->config.alpha_shift_1) != 1)) {
    fprintf(stderr, "fixture parse error in %s\n", path);
    fclose(file);
    return false;
  }
  fixture->config.t = error_count;
  fixture->h_base = checked_calloc((size_t)fixture->config.n0 * fixture->config.w,
                                   sizeof(*fixture->h_base), "fixture H support");
  for (uint32_t block = 0; block < fixture->config.n0; ++block) {
    uint32_t block_idx;
    if (!expect_token(file, "h") || (fscanf(file, "%" SCNu32, &block_idx) != 1) ||
        (block_idx != block)) {
      fprintf(stderr, "fixture parse error in H block %u\n", block);
      fclose(file);
      return false;
    }
    for (uint32_t diag_idx_local = 0; diag_idx_local < fixture->config.w; ++diag_idx_local) {
      if (fscanf(file, "%" SCNu32,
                 &fixture->h_base[(size_t)block * fixture->config.w + diag_idx_local]) != 1) {
        fprintf(stderr, "fixture parse error in H block %u\n", block);
        fclose(file);
        return false;
      }
    }
  }
  if (!expect_token(file, "error_positions")) {
    fclose(file);
    return false;
  }
  fixture->error_positions =
      checked_calloc(error_count, sizeof(*fixture->error_positions), "fixture errors");
  for (uint32_t idx = 0; idx < error_count; ++idx) {
    if (fscanf(file, "%" SCNu32, &fixture->error_positions[idx]) != 1) {
      fprintf(stderr, "fixture parse error in error positions\n");
      fclose(file);
      return false;
    }
  }
  if (!expect_token(file, "syndrome_weight") ||
      (fscanf(file, "%" SCNu32, &fixture->syndrome_weight) != 1) ||
      !expect_token(file, "syndrome_positions")) {
    fclose(file);
    return false;
  }
  fixture->syndrome_positions = checked_calloc(
      fixture->syndrome_weight, sizeof(*fixture->syndrome_positions), "fixture syndrome");
  for (uint32_t idx = 0; idx < fixture->syndrome_weight; ++idx) {
    if (fscanf(file, "%" SCNu32, &fixture->syndrome_positions[idx]) != 1) {
      fprintf(stderr, "fixture parse error in syndrome positions\n");
      fclose(file);
      return false;
    }
  }
  fclose(file);
  return true;
}

static void free_fixture(fixture_case_t *fixture) {
  free(fixture->h_base);
  free(fixture->error_positions);
  free(fixture->syndrome_positions);
  memset(fixture, 0, sizeof(*fixture));
}

static uint64_t splitmix64_next(rng_t *rng) {
  uint64_t z;

  rng->state += UINT64_C(0x9e3779b97f4a7c15);
  z = rng->state;
  z = (z ^ (z >> 30)) * UINT64_C(0xbf58476d1ce4e5b9);
  z = (z ^ (z >> 27)) * UINT64_C(0x94d049bb133111eb);
  return z ^ (z >> 31);
}

static uint32_t random_bounded(rng_t *rng, uint32_t bound) {
  uint64_t threshold;
  uint64_t value;

  if (bound == 0) {
    return 0;
  }
  threshold = (UINT64_MAX - (uint64_t)bound + 1U) % (uint64_t)bound;
  do {
    value = splitmix64_next(rng);
  } while (value < threshold);
  return (uint32_t)(value % bound);
}

static int compare_u32(const void *lhs, const void *rhs) {
  uint32_t left = *(const uint32_t *)lhs;
  uint32_t right = *(const uint32_t *)rhs;
  return (left > right) - (left < right);
}

static bool contains_u32(const uint32_t *values, uint32_t count, uint32_t value) {
  for (uint32_t idx = 0; idx < count; ++idx) {
    if (values[idx] == value) {
      return true;
    }
  }
  return false;
}

static void sample_sorted_unique(rng_t *rng, uint32_t limit, uint32_t count, uint32_t *values) {
  uint32_t used = 0;

  while (used < count) {
    uint32_t candidate = random_bounded(rng, limit);
    if (!contains_u32(values, used, candidate)) {
      values[used++] = candidate;
    }
  }
  qsort(values, count, sizeof(values[0]), compare_u32);
}

static void *checked_calloc(size_t count, size_t size, const char *name) {
  void *memory;

  if (count == 0) {
    count = 1;
  }
  if ((size != 0) && (count > SIZE_MAX / size)) {
    fprintf(stderr, "allocation size overflow for %s\n", name);
    exit(EXIT_FAILURE);
  }
  memory = calloc(count, size);
  if (memory == NULL) {
    fprintf(stderr, "allocation failed for %s (%zu bytes)\n", name, count * size);
    exit(EXIT_FAILURE);
  }
  return memory;
}

static bool allocate_buffers(const decoder_config_t *config, decoder_buffers_t *buffers) {
  uint64_t n64 = (uint64_t)config->n0 * config->r;
  uint64_t edge_count64 = n64 * config->w;
  uint64_t h_count64 = (uint64_t)config->n0 * config->w;

  if ((n64 > SIZE_MAX) || (edge_count64 > SIZE_MAX) || (h_count64 > SIZE_MAX)) {
    fprintf(stderr, "configured geometry exceeds host address space\n");
    return false;
  }

  memset(buffers, 0, sizeof(*buffers));
  buffers->h_base = checked_calloc((size_t)h_count64, sizeof(*buffers->h_base), "H support");
  buffers->target_error =
      checked_calloc((size_t)n64, sizeof(*buffers->target_error), "target error");
  buffers->syndrome = checked_calloc(config->r, sizeof(*buffers->syndrome), "syndrome");
  buffers->v2c = checked_calloc((size_t)edge_count64, sizeof(*buffers->v2c), "V2C messages");
  buffers->c2v = checked_calloc((size_t)edge_count64, sizeof(*buffers->c2v), "C2V messages");
  buffers->variable_sum =
      checked_calloc((size_t)n64, sizeof(*buffers->variable_sum), "variable sums");
  buffers->min1 = checked_calloc(config->r, sizeof(*buffers->min1), "check min1");
  buffers->min2 = checked_calloc(config->r, sizeof(*buffers->min2), "check min2");
  buffers->min_diag_idx_global = checked_calloc(config->r, sizeof(*buffers->min_diag_idx_global), "check min id");
  buffers->sign_xor = checked_calloc(config->r, sizeof(*buffers->sign_xor), "check sign");
  buffers->decision = checked_calloc((size_t)n64, sizeof(*buffers->decision), "decision");
  buffers->residual = checked_calloc(config->r, sizeof(*buffers->residual), "residual");
  return true;
}

static uint64_t buffer_bytes(const decoder_config_t *config) {
  uint64_t n = (uint64_t)config->n0 * config->r;
  uint64_t edge_count = n * config->w;
  uint64_t h_count = (uint64_t)config->n0 * config->w;

  return h_count * sizeof(uint32_t) + n * sizeof(uint8_t) +
         config->r * sizeof(uint8_t) + edge_count * sizeof(int16_t) * 2U +
         n * sizeof(int32_t) + config->r * sizeof(uint16_t) * 3U +
         config->r * sizeof(uint8_t) + n * sizeof(uint8_t) +
         config->r * sizeof(uint8_t);
}

static void free_buffers(decoder_buffers_t *buffers) {
  free(buffers->h_base);
  free(buffers->target_error);
  free(buffers->syndrome);
  free(buffers->v2c);
  free(buffers->c2v);
  free(buffers->variable_sum);
  free(buffers->min1);
  free(buffers->min2);
  free(buffers->min_diag_idx_global);
  free(buffers->sign_xor);
  free(buffers->decision);
  free(buffers->residual);
  memset(buffers, 0, sizeof(*buffers));
}

static uint32_t edge_row(const decoder_config_t *config, const decoder_buffers_t *buffers,
                         uint32_t block, uint32_t column, uint32_t diag_idx_local) {
  uint32_t base = buffers->h_base[(size_t)block * config->w + diag_idx_local];
  uint32_t sum = base + column;
  return (sum >= config->r) ? (sum - config->r) : sum;
}

static size_t edge_offset(const decoder_config_t *config, uint32_t variable, uint32_t diag_idx_local) {
  return (size_t)variable * config->w + diag_idx_local;
}

static void generate_case(const decoder_config_t *config, uint64_t seed,
                          decoder_buffers_t *buffers) {
  rng_t rng = {.state = seed};
  uint32_t n = config->n0 * config->r;
  uint32_t *error_positions =
      checked_calloc(config->t, sizeof(*error_positions), "error positions");

  memset(buffers->target_error, 0, (size_t)n * sizeof(*buffers->target_error));
  memset(buffers->syndrome, 0, (size_t)config->r * sizeof(*buffers->syndrome));

  for (uint32_t block = 0; block < config->n0; ++block) {
    sample_sorted_unique(&rng, config->r, config->w,
                         &buffers->h_base[(size_t)block * config->w]);
  }
  sample_sorted_unique(&rng, n, config->t, error_positions);
  for (uint32_t idx = 0; idx < config->t; ++idx) {
    buffers->target_error[error_positions[idx]] = 1;
  }

  for (uint32_t variable = 0; variable < n; ++variable) {
    uint32_t block;
    uint32_t column;

    if (buffers->target_error[variable] == 0) {
      continue;
    }
    block = variable / config->r;
    column = variable % config->r;
    for (uint32_t diag_idx_local = 0; diag_idx_local < config->w; ++diag_idx_local) {
      uint32_t row = edge_row(config, buffers, block, column, diag_idx_local);
      buffers->syndrome[row] ^= 1U;
    }
  }
  free(error_positions);
}

static bool load_fixture_case(const fixture_case_t *fixture, decoder_buffers_t *buffers) {
  uint32_t n = fixture->config.n0 * fixture->config.r;

  memcpy(buffers->h_base, fixture->h_base,
         (size_t)fixture->config.n0 * fixture->config.w * sizeof(*buffers->h_base));
  memset(buffers->target_error, 0, (size_t)n * sizeof(*buffers->target_error));
  memset(buffers->syndrome, 0, (size_t)fixture->config.r * sizeof(*buffers->syndrome));
  for (uint32_t idx = 0; idx < fixture->config.t; ++idx) {
    uint32_t position = fixture->error_positions[idx];
    if (position >= n) {
      fprintf(stderr, "fixture error position %u is out of range\n", position);
      return false;
    }
    buffers->target_error[position] = 1;
  }
  for (uint32_t idx = 0; idx < fixture->syndrome_weight; ++idx) {
    uint32_t position = fixture->syndrome_positions[idx];
    if (position >= fixture->config.r) {
      fprintf(stderr, "fixture syndrome position %u is out of range\n", position);
      return false;
    }
    buffers->syndrome[position] = 1;
  }
  for (uint32_t block = 0; block < fixture->config.n0; ++block) {
    uint32_t previous = 0;
    for (uint32_t diag_idx_local = 0; diag_idx_local < fixture->config.w; ++diag_idx_local) {
      uint32_t row = buffers->h_base[(size_t)block * fixture->config.w + diag_idx_local];
      if ((row >= fixture->config.r) || ((diag_idx_local != 0) && (row <= previous))) {
        fprintf(stderr, "fixture H block %u must contain sorted unique rows in range\n", block);
        return false;
      }
      previous = row;
    }
  }
  return true;
}

static bool write_decision(const char *path, const decoder_config_t *config,
                           const decoder_buffers_t *buffers) {
  FILE *file = fopen(path, "w");
  uint32_t n = config->n0 * config->r;

  if (file == NULL) {
    fprintf(stderr, "cannot open decision output %s: %s\n", path, strerror(errno));
    return false;
  }
  fprintf(file, "MIN_SUM_DECISION_V1\n");
  for (uint32_t variable = 0; variable < n; ++variable) {
    if (buffers->decision[variable] != 0) {
      fprintf(file, "%u\n", variable);
    }
  }
  if (fclose(file) != 0) {
    fprintf(stderr, "cannot close decision output %s: %s\n", path, strerror(errno));
    return false;
  }
  return true;
}

static int32_t round_alpha(int32_t value, uint32_t shift_0, uint32_t shift_1) {
  const uint32_t frac_bits = 6;
  int64_t numerator = 0;
  int64_t product;
  int64_t magnitude;
  int64_t quotient;
  int64_t remainder;

  if ((shift_0 > 0) && (shift_0 <= frac_bits)) {
    numerator += INT64_C(1) << (frac_bits - shift_0);
  }
  if ((shift_1 > 0) && (shift_1 <= frac_bits)) {
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

static uint32_t vector_weight(const uint8_t *vector, uint32_t length) {
  uint32_t weight = 0;
  for (uint32_t idx = 0; idx < length; ++idx) {
    weight += vector[idx] != 0;
  }
  return weight;
}

static void calculate_residual(const decoder_config_t *config, decoder_buffers_t *buffers) {
  uint32_t n = config->n0 * config->r;

  memcpy(buffers->residual, buffers->syndrome,
         (size_t)config->r * sizeof(*buffers->residual));
  for (uint32_t variable = 0; variable < n; ++variable) {
    uint32_t block;
    uint32_t column;

    if (buffers->decision[variable] == 0) {
      continue;
    }
    block = variable / config->r;
    column = variable % config->r;
    for (uint32_t diag_idx_local = 0; diag_idx_local < config->w; ++diag_idx_local) {
      uint32_t row = edge_row(config, buffers, block, column, diag_idx_local);
      buffers->residual[row] ^= 1U;
    }
  }
}

static bool decision_is_exact(const decoder_config_t *config,
                              const decoder_buffers_t *buffers) {
  uint32_t n = config->n0 * config->r;
  return memcmp(buffers->decision, buffers->target_error,
                (size_t)n * sizeof(*buffers->decision)) == 0;
}

static void clear_iteration_stats(iteration_stats_t *stats, uint32_t magnitude_max, bool enabled) {
  memset(stats, 0, sizeof(*stats));
  if (enabled) {
    stats->v2c_hist =
        checked_calloc((size_t)magnitude_max + 1, sizeof(uint64_t), "V2C histogram");
    stats->c2v_hist =
        checked_calloc((size_t)magnitude_max + 1, sizeof(uint64_t), "C2V histogram");
  }
}

static void free_iteration_stats(iteration_stats_t *stats) {
  free(stats->v2c_hist);
  free(stats->c2v_hist);
  memset(stats, 0, sizeof(*stats));
}

static void print_histogram(const char *name, const uint64_t *histogram, uint32_t magnitude_max) {
  printf("    %s:", name);
  for (uint32_t magnitude = 0; magnitude <= magnitude_max; ++magnitude) {
    if (histogram[magnitude] != 0) {
      printf(" %u:%" PRIu64, magnitude, histogram[magnitude]);
    }
  }
  putchar('\n');
}

static void run_decoder(const decoder_config_t *config, decoder_buffers_t *buffers,
                        bool print_stats, uint32_t *decision_weight, uint32_t *residual_weight,
                        bool *exact) {
  uint32_t n = config->n0 * config->r;
  uint32_t magnitude_max = (UINT32_C(1) << (config->msg_bits - 1)) - 1U;
  uint64_t edge_count = (uint64_t)n * config->w;

  for (uint64_t edge = 0; edge < edge_count; ++edge) {
    buffers->v2c[edge] = (int16_t)config->c_val;
  }

  for (uint32_t iteration = 0; iteration < config->iterations; ++iteration) {
    iteration_stats_t stats;

    clear_iteration_stats(&stats, magnitude_max, print_stats);
    for (uint32_t row = 0; row < config->r; ++row) {
      buffers->min1[row] = (uint16_t)magnitude_max;
      buffers->min2[row] = (uint16_t)magnitude_max;
      buffers->min_diag_idx_global[row] = 0;
      buffers->sign_xor[row] = 0;
    }

    for (uint32_t variable = 0; variable < n; ++variable) {
      uint32_t block = variable / config->r;
      uint32_t column = variable % config->r;

      for (uint32_t diag_idx_local = 0; diag_idx_local < config->w; ++diag_idx_local) {
        size_t offset = edge_offset(config, variable, diag_idx_local);
        int16_t message = buffers->v2c[offset];
        uint32_t magnitude = magnitude_i16(message);
        uint32_t row = edge_row(config, buffers, block, column, diag_idx_local);
        uint16_t diag_idx_global = (uint16_t)(block * config->w + diag_idx_local);

        if (print_stats) {
          ++stats.v2c_hist[magnitude];
          stats.v2c_zero += magnitude == 0;
          stats.v2c_saturated += magnitude == magnitude_max;
        }
        if (message < 0) {
          buffers->sign_xor[row] ^= 1U;
        }
        if (magnitude <= buffers->min1[row]) {
          buffers->min2[row] = buffers->min1[row];
          buffers->min1[row] = (uint16_t)magnitude;
          buffers->min_diag_idx_global[row] = diag_idx_global;
        } else if (magnitude < buffers->min2[row]) {
          buffers->min2[row] = (uint16_t)magnitude;
        }
      }
    }

    memset(buffers->variable_sum, 0, (size_t)n * sizeof(*buffers->variable_sum));
    if (print_stats) {
      for (uint32_t row = 0; row < config->r; ++row) {
        stats.min_equal += buffers->min1[row] == buffers->min2[row];
      }
    }

    for (uint32_t variable = 0; variable < n; ++variable) {
      uint32_t block = variable / config->r;
      uint32_t column = variable % config->r;

      for (uint32_t diag_idx_local = 0; diag_idx_local < config->w; ++diag_idx_local) {
        size_t offset = edge_offset(config, variable, diag_idx_local);
        int16_t input = buffers->v2c[offset];
        uint32_t row = edge_row(config, buffers, block, column, diag_idx_local);
        uint16_t diag_idx_global = (uint16_t)(block * config->w + diag_idx_local);
        uint32_t magnitude = (diag_idx_global == buffers->min_diag_idx_global[row]) ? buffers->min2[row]
                                                               : buffers->min1[row];
        uint8_t sign =
            buffers->sign_xor[row] ^ (input < 0) ^ (buffers->syndrome[row] != 0);
        int16_t output = (int16_t)((sign && (magnitude != 0)) ? -(int32_t)magnitude
                                                             : (int32_t)magnitude);

        buffers->c2v[offset] = output;
        buffers->variable_sum[variable] += output;
        if (print_stats) {
          ++stats.c2v_hist[magnitude];
          stats.c2v_zero += magnitude == 0;
          stats.c2v_saturated += magnitude == magnitude_max;
        }
      }
    }

    for (uint32_t variable = 0; variable < n; ++variable) {
      int32_t posterior =
          (int32_t)config->c_val +
          round_alpha(buffers->variable_sum[variable], config->alpha_shift_0,
                      config->alpha_shift_1);
      buffers->decision[variable] = posterior < 0;

      for (uint32_t diag_idx_local = 0; diag_idx_local < config->w; ++diag_idx_local) {
        size_t offset = edge_offset(config, variable, diag_idx_local);
        int32_t extrinsic = buffers->variable_sum[variable] - buffers->c2v[offset];
        int32_t updated =
            (int32_t)config->c_val +
            round_alpha(extrinsic, config->alpha_shift_0, config->alpha_shift_1);
        buffers->v2c[offset] = saturate_message(updated, magnitude_max);
      }
    }

    if (print_stats) {
      stats.checks = config->r;
      stats.edges = edge_count;
      calculate_residual(config, buffers);
      printf("  iteration %u: decision_weight=%u residual_weight=%u "
             "v2c_zero=%.6f v2c_sat=%.6f c2v_zero=%.6f c2v_sat=%.6f "
             "min1_eq_min2=%.6f\n",
             iteration + 1, vector_weight(buffers->decision, n),
             vector_weight(buffers->residual, config->r),
             (double)stats.v2c_zero / (double)stats.edges,
             (double)stats.v2c_saturated / (double)stats.edges,
             (double)stats.c2v_zero / (double)stats.edges,
             (double)stats.c2v_saturated / (double)stats.edges,
             (double)stats.min_equal / (double)stats.checks);
      print_histogram("v2c_mag", stats.v2c_hist, magnitude_max);
      print_histogram("c2v_mag", stats.c2v_hist, magnitude_max);
    }
    free_iteration_stats(&stats);
  }

  calculate_residual(config, buffers);
  *decision_weight = vector_weight(buffers->decision, n);
  *residual_weight = vector_weight(buffers->residual, config->r);
  *exact = decision_is_exact(config, buffers);
}

static double elapsed_seconds(const struct timespec *start, const struct timespec *end) {
  return (double)(end->tv_sec - start->tv_sec) +
         (double)(end->tv_nsec - start->tv_nsec) / 1.0e9;
}

static void run_trial(const decoder_config_t *config, uint64_t seed, bool print_stats,
                      decoder_buffers_t *buffers, trial_result_t *result) {
  struct timespec start;
  struct timespec end;

  generate_case(config, seed, buffers);
  clock_gettime(CLOCK_MONOTONIC, &start);
  run_decoder(config, buffers, print_stats, &result->decision_weight, &result->residual_weight,
              &result->exact);
  clock_gettime(CLOCK_MONOTONIC, &end);
  result->seed = seed;
  result->seconds = elapsed_seconds(&start, &end);
}

static void *worker_main(void *opaque) {
  worker_args_t *args = opaque;
  decoder_buffers_t buffers;

  if (!allocate_buffers(args->config, &buffers)) {
    return (void *)(uintptr_t)1;
  }
  for (uint32_t trial = args->worker_idx; trial < args->trials; trial += args->worker_count) {
    run_trial(args->config, args->base_seed + trial, args->print_stats, &buffers,
              &args->results[trial]);
  }
  free_buffers(&buffers);
  return NULL;
}

static uint32_t online_cpu_count(void) {
#if defined(__APPLE__)
  int count = 0;
  size_t count_size = sizeof(count);
  if ((sysctlbyname("hw.logicalcpu", &count, &count_size, NULL, 0) != 0) || (count < 1)) {
    return 1;
  }
  return (uint32_t)count;
#elif defined(_SC_NPROCESSORS_ONLN)
  long count = sysconf(_SC_NPROCESSORS_ONLN);
  if ((count < 1) || ((uint64_t)count > UINT32_MAX)) {
    return 1;
  }
  return (uint32_t)count;
#else
  return 1;
#endif
}

static bool validate_config(const decoder_config_t *config) {
  uint32_t magnitude_bits;
  uint32_t magnitude_max;
  uint64_t n;

  if ((config->n0 == 0) || (config->r == 0) || (config->w == 0) ||
      (config->iterations == 0)) {
    fprintf(stderr, "n0, r, w, and iterations must be positive\n");
    return false;
  }
  if (config->w > config->r) {
    fprintf(stderr, "w must not exceed r\n");
    return false;
  }
  n = (uint64_t)config->n0 * config->r;
  if (config->t > n) {
    fprintf(stderr, "error weight must not exceed n0*r\n");
    return false;
  }
  if ((config->msg_bits < 2) || (config->msg_bits > 16)) {
    fprintf(stderr, "msg-bits must be in the range 2..16\n");
    return false;
  }
  magnitude_bits = config->msg_bits - 1;
  magnitude_max = (UINT32_C(1) << magnitude_bits) - 1U;
  if (config->c_val > magnitude_max) {
    fprintf(stderr, "c-val must fit in the configured magnitude bits\n");
    return false;
  }
  if (((config->alpha_shift_0 == 0) || (config->alpha_shift_0 > 6)) &&
      ((config->alpha_shift_1 == 0) || (config->alpha_shift_1 > 6))) {
    fprintf(stderr, "at least one alpha shift must be in the range 1..6\n");
    return false;
  }
  if ((uint64_t)config->n0 * config->w > UINT16_MAX) {
    fprintf(stderr, "n0*w must fit in the model's 16-bit global diagonal index\n");
    return false;
  }
  return true;
}

int main(int argc, char **argv) {
  decoder_config_t config = k_profiles[1];
  uint64_t base_seed = 1;
  uint32_t trials = 1;
  uint32_t requested_threads = 1;
  bool print_stats = false;
  const char *csv_path = NULL;
  const char *fixture_path = NULL;
  const char *decision_path = NULL;
  FILE *csv = NULL;
  fixture_case_t fixture;
  trial_result_t *results = NULL;
  pthread_t *thread_ids = NULL;
  worker_args_t *worker_args = NULL;
  uint32_t success_count = 0;
  uint32_t exact_count = 0;
  double total_trial_seconds = 0.0;
  struct timespec wall_start;
  struct timespec wall_end;
  double wall_seconds;
  uint32_t worker_count;
  bool worker_failed = false;
  int option;
  int option_index = 0;
  enum {
    OPT_PROFILE = 1000,
    OPT_SEED,
    OPT_TRIALS,
    OPT_THREADS,
    OPT_R,
    OPT_W,
    OPT_ERRORS,
    OPT_ITERATIONS,
    OPT_MSG_BITS,
    OPT_C_VAL,
    OPT_ALPHA_SHIFT_0,
    OPT_ALPHA_SHIFT_1,
    OPT_FIXTURE_IN,
    OPT_DECISION_OUT,
    OPT_STATS,
    OPT_CSV,
  };
  static const struct option options[] = {
      {"profile", required_argument, NULL, OPT_PROFILE},
      {"seed", required_argument, NULL, OPT_SEED},
      {"trials", required_argument, NULL, OPT_TRIALS},
      {"threads", required_argument, NULL, OPT_THREADS},
      {"r", required_argument, NULL, OPT_R},
      {"w", required_argument, NULL, OPT_W},
      {"errors", required_argument, NULL, OPT_ERRORS},
      {"iterations", required_argument, NULL, OPT_ITERATIONS},
      {"msg-bits", required_argument, NULL, OPT_MSG_BITS},
      {"c-val", required_argument, NULL, OPT_C_VAL},
      {"alpha-shift-0", required_argument, NULL, OPT_ALPHA_SHIFT_0},
      {"alpha-shift-1", required_argument, NULL, OPT_ALPHA_SHIFT_1},
      {"fixture-in", required_argument, NULL, OPT_FIXTURE_IN},
      {"decision-out", required_argument, NULL, OPT_DECISION_OUT},
      {"stats", no_argument, NULL, OPT_STATS},
      {"csv", required_argument, NULL, OPT_CSV},
      {"help", no_argument, NULL, 'h'},
      {NULL, 0, NULL, 0},
  };

  while ((option = getopt_long(argc, argv, "h", options, &option_index)) != -1) {
    uint32_t parsed = 0;
    const decoder_config_t *profile;

    switch (option) {
      case OPT_PROFILE:
        profile = find_profile(optarg);
        if (profile == NULL) {
          fprintf(stderr, "unknown profile: %s\n", optarg);
          return EXIT_FAILURE;
        }
        config = *profile;
        break;
      case OPT_SEED: {
        char *end = NULL;
        errno = 0;
        base_seed = strtoull(optarg, &end, 0);
        if ((errno != 0) || (end == optarg) || (*end != '\0')) {
          fprintf(stderr, "invalid seed: %s\n", optarg);
          return EXIT_FAILURE;
        }
        break;
      }
      case OPT_TRIALS:
      case OPT_THREADS:
      case OPT_R:
      case OPT_W:
      case OPT_ERRORS:
      case OPT_ITERATIONS:
      case OPT_MSG_BITS:
      case OPT_C_VAL:
      case OPT_ALPHA_SHIFT_0:
      case OPT_ALPHA_SHIFT_1:
        if (!parse_u32(optarg, &parsed)) {
          fprintf(stderr, "invalid numeric option: %s\n", optarg);
          return EXIT_FAILURE;
        }
        if (option == OPT_TRIALS) {
          trials = parsed;
        } else if (option == OPT_THREADS) {
          requested_threads = parsed;
        } else if (option == OPT_R) {
          config.r = parsed;
        } else if (option == OPT_W) {
          config.w = parsed;
        } else if (option == OPT_ERRORS) {
          config.t = parsed;
        } else if (option == OPT_ITERATIONS) {
          config.iterations = parsed;
        } else if (option == OPT_MSG_BITS) {
          config.msg_bits = parsed;
        } else if (option == OPT_C_VAL) {
          config.c_val = parsed;
        } else if (option == OPT_ALPHA_SHIFT_0) {
          config.alpha_shift_0 = parsed;
        } else {
          config.alpha_shift_1 = parsed;
        }
        break;
      case OPT_STATS:
        print_stats = true;
        break;
      case OPT_FIXTURE_IN:
        fixture_path = optarg;
        break;
      case OPT_DECISION_OUT:
        decision_path = optarg;
        break;
      case OPT_CSV:
        csv_path = optarg;
        break;
      case 'h':
        usage(stdout, argv[0]);
        return EXIT_SUCCESS;
      default:
        usage(stderr, argv[0]);
        return EXIT_FAILURE;
    }
  }

  if (optind != argc) {
    fprintf(stderr, "unexpected positional argument: %s\n", argv[optind]);
    return EXIT_FAILURE;
  }
  memset(&fixture, 0, sizeof(fixture));
  if (fixture_path != NULL) {
    if (!read_fixture(fixture_path, &fixture)) {
      free_fixture(&fixture);
      return EXIT_FAILURE;
    }
    config = fixture.config;
    base_seed = fixture.seed;
    trials = 1;
    requested_threads = 1;
  }
  if ((trials == 0) || !validate_config(&config)) {
    free_fixture(&fixture);
    return EXIT_FAILURE;
  }
  worker_count = (requested_threads == 0) ? online_cpu_count() : requested_threads;
  if (worker_count > trials) {
    worker_count = trials;
  }
  if (print_stats && (worker_count != 1)) {
    fprintf(stderr, "--stats requires --threads 1 so iteration output remains ordered\n");
    free_fixture(&fixture);
    return EXIT_FAILURE;
  }
  if ((decision_path != NULL) && (trials != 1)) {
    fprintf(stderr, "--decision-out requires one trial or --fixture-in\n");
    free_fixture(&fixture);
    return EXIT_FAILURE;
  }
  if (csv_path != NULL) {
    csv = fopen(csv_path, "w");
    if (csv == NULL) {
      fprintf(stderr, "cannot open CSV output %s: %s\n", csv_path, strerror(errno));
      free_fixture(&fixture);
      return EXIT_FAILURE;
    }
    fprintf(csv,
            "trial,seed,profile,r,w,error_weight,iterations,msg_bits,c_val,"
            "alpha_shift_0,alpha_shift_1,decision_weight,residual_weight,exact,"
            "seconds\n");
  }

  printf("profile=%s n0=%u r=%u w=%u t=%u iterations=%u msg_bits=%u C=%u "
         "alpha=2^-%u+2^-%u trials=%u threads=%u worker_memory_mib=%.2f "
         "total_worker_memory_mib=%.2f\n",
         config.name, config.n0, config.r, config.w, config.t, config.iterations,
         config.msg_bits, config.c_val, config.alpha_shift_0, config.alpha_shift_1, trials,
         worker_count, (double)buffer_bytes(&config) / (1024.0 * 1024.0),
         (double)buffer_bytes(&config) * worker_count / (1024.0 * 1024.0));

  results = checked_calloc(trials, sizeof(*results), "trial results");
  worker_args = checked_calloc(worker_count, sizeof(*worker_args), "worker arguments");
  if (worker_count > 1) {
    thread_ids = checked_calloc(worker_count, sizeof(*thread_ids), "worker threads");
  }

  clock_gettime(CLOCK_MONOTONIC, &wall_start);
  for (uint32_t worker_idx = 0; worker_idx < worker_count; ++worker_idx) {
    worker_args[worker_idx] =
        (worker_args_t){.config = &config,
                        .base_seed = base_seed,
                        .trials = trials,
                        .worker_idx = worker_idx,
                        .worker_count = worker_count,
                        .print_stats = print_stats,
                        .results = results};
  }

  if (fixture_path != NULL) {
    decoder_buffers_t buffers;
    if (!allocate_buffers(&config, &buffers) || !load_fixture_case(&fixture, &buffers)) {
      worker_failed = true;
    } else {
      struct timespec start;
      struct timespec end;
      clock_gettime(CLOCK_MONOTONIC, &start);
      run_decoder(&config, &buffers, print_stats, &results[0].decision_weight,
                  &results[0].residual_weight, &results[0].exact);
      clock_gettime(CLOCK_MONOTONIC, &end);
      results[0].seed = fixture.seed;
      results[0].seconds = elapsed_seconds(&start, &end);
      if ((decision_path != NULL) && !write_decision(decision_path, &config, &buffers)) {
        worker_failed = true;
      }
      free_buffers(&buffers);
    }
  } else if (worker_count == 1) {
    worker_failed = worker_main(&worker_args[0]) != NULL;
  } else {
    uint32_t created = 0;
    for (; created < worker_count; ++created) {
      int rc = pthread_create(&thread_ids[created], NULL, worker_main, &worker_args[created]);
      if (rc != 0) {
        fprintf(stderr, "pthread_create failed for worker %u: %s\n", created, strerror(rc));
        worker_failed = true;
        break;
      }
    }
    for (uint32_t worker_idx = 0; worker_idx < created; ++worker_idx) {
      void *worker_result = NULL;
      int rc = pthread_join(thread_ids[worker_idx], &worker_result);
      if (rc != 0) {
        fprintf(stderr, "pthread_join failed for worker %u: %s\n", worker_idx, strerror(rc));
        worker_failed = true;
      } else if (worker_result != NULL) {
        worker_failed = true;
      }
    }
  }
  clock_gettime(CLOCK_MONOTONIC, &wall_end);

  if (worker_failed) {
    free(thread_ids);
    free(worker_args);
    free(results);
    if (csv != NULL) {
      fclose(csv);
    }
    free_fixture(&fixture);
    return EXIT_FAILURE;
  }

  for (uint32_t trial = 0; trial < trials; ++trial) {
    trial_result_t *result = &results[trial];

    total_trial_seconds += result->seconds;
    success_count += result->residual_weight == 0;
    exact_count += result->exact;

    printf("trial=%u seed=%" PRIu64 " decision_weight=%u residual_weight=%u "
           "exact=%s seconds=%.6f\n",
           trial, result->seed, result->decision_weight, result->residual_weight,
           result->exact ? "yes" : "no", result->seconds);
    if (csv != NULL) {
      fprintf(csv,
              "%u,%" PRIu64 ",%s,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%.9f\n",
              trial, result->seed, config.name, config.r, config.w, config.t, config.iterations,
              config.msg_bits, config.c_val, config.alpha_shift_0, config.alpha_shift_1,
              result->decision_weight, result->residual_weight, result->exact ? 1U : 0U,
              result->seconds);
    }
  }

  wall_seconds = elapsed_seconds(&wall_start, &wall_end);
  printf("summary syndrome_success=%u/%u exact=%u/%u wall_seconds=%.6f "
         "trial_seconds=%.6f throughput=%.3f_trials_per_second\n",
         success_count, trials, exact_count, trials, wall_seconds, total_trial_seconds,
         (wall_seconds > 0.0) ? ((double)trials / wall_seconds) : 0.0);
  if (csv != NULL) {
    fclose(csv);
  }
  free(thread_ids);
  free(worker_args);
  free(results);
  free_fixture(&fixture);
  return EXIT_SUCCESS;
}
