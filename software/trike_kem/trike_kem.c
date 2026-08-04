#include "trike_kem.h"

#include <limits.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "fips202.h"

enum {
  TRIKE_DOMAIN_KEY_MATERIAL = 0x10,
  TRIKE_DOMAIN_SECRET_H0 = 0x20,
  TRIKE_DOMAIN_SECRET_H1 = 0x21,
  TRIKE_DOMAIN_SECRET_H2 = 0x22,
  TRIKE_DOMAIN_H1 = 0x31,
  TRIKE_DOMAIN_H2 = 0x32,
  TRIKE_DOMAIN_H3 = 0x33,
  TRIKE_DOMAIN_H4 = 0x34,
  TRIKE_DOMAIN_L = 0x35,
  TRIKE_DOMAIN_K = 0x36,
  TRIKE_DOMAIN_MESSAGE = 0x40
};

static const trike_kem_params_t k_trike_params[] = {
    {"trike128", 128U, 8243U, 27U, 201U,
     {3U, 8243U, 27U, 7U, 5U, 4U, 3U, 4U}},
    {"trike160", 160U, 12589U, 35U, 263U,
     {3U, 12589U, 35U, 7U, 5U, 4U, 3U, 4U}},
    {"trike256", 256U, 30389U, 55U, 429U,
     {3U, 30389U, 55U, 7U, 5U, 5U, 3U, 4U}},
    {"trike384", 384U, 63773U, 83U, 659U,
     {3U, 63773U, 83U, 7U, 5U, 5U, 3U, 6U}},
    {"trike512", 512U, 106781U, 111U, 877U,
     {3U, 106781U, 111U, 7U, 5U, 7U, 4U, 0U}},
};

typedef struct {
  uint32_t r;
  size_t words;
  uint64_t *value;
} ring_poly_t;

size_t trike_kem_poly_words(const trike_kem_params_t *params) {
  return params == NULL ? 0U : ((size_t)params->r + 63U) / 64U;
}

size_t trike_kem_poly_bytes(const trike_kem_params_t *params) {
  return params == NULL ? 0U : ((size_t)params->r + 7U) / 8U;
}

const trike_kem_params_t *trike_kem_params_by_name(const char *name) {
  if (name == NULL) {
    return NULL;
  }
  for (size_t i = 0U; i < sizeof(k_trike_params) / sizeof(k_trike_params[0]);
       ++i) {
    if (strcmp(name, k_trike_params[i].name) == 0) {
      return &k_trike_params[i];
    }
  }
  return NULL;
}

static int ring_poly_alloc(ring_poly_t *poly, uint32_t r) {
  if ((poly == NULL) || (r == 0U)) {
    return -1;
  }
  memset(poly, 0, sizeof(*poly));
  poly->r = r;
  poly->words = ((size_t)r + 63U) / 64U;
  poly->value = calloc(poly->words, sizeof(*poly->value));
  return poly->value == NULL ? -1 : 0;
}

static void secure_clean(void *memory, size_t bytes) {
  volatile uint8_t *cursor = (volatile uint8_t *)memory;
  while (bytes-- != 0U) {
    *cursor++ = 0U;
  }
}

static void ring_poly_free(ring_poly_t *poly) {
  if (poly == NULL) {
    return;
  }
  if (poly->value != NULL) {
    secure_clean(poly->value, poly->words * sizeof(*poly->value));
    free(poly->value);
  }
  memset(poly, 0, sizeof(*poly));
}

static void ring_poly_mask(ring_poly_t *poly) {
  const unsigned int used = poly->r & 63U;
  if (used != 0U) {
    poly->value[poly->words - 1U] &= (UINT64_C(1) << used) - 1U;
  }
}

static void ring_poly_zero(ring_poly_t *poly) {
  memset(poly->value, 0, poly->words * sizeof(*poly->value));
}

static void ring_poly_copy(ring_poly_t *destination,
                           const ring_poly_t *source) {
  memcpy(destination->value, source->value,
         source->words * sizeof(*source->value));
}

static void ring_poly_xor(ring_poly_t *destination,
                          const ring_poly_t *source) {
  for (size_t i = 0U; i < destination->words; ++i) {
    destination->value[i] ^= source->value[i];
  }
}

static unsigned int ring_poly_get_bit(const ring_poly_t *poly, uint32_t bit) {
  return (unsigned int)((poly->value[bit >> 6U] >> (bit & 63U)) & 1U);
}

static void ring_poly_toggle_bit(ring_poly_t *poly, uint32_t bit) {
  poly->value[bit >> 6U] ^= UINT64_C(1) << (bit & 63U);
}

static unsigned int ring_poly_parity(const ring_poly_t *poly) {
  unsigned int parity = 0U;
  for (size_t i = 0U; i < poly->words; ++i) {
    parity ^= (unsigned int)__builtin_parityll(poly->value[i]);
  }
  return parity & 1U;
}

static void ring_poly_from_support(ring_poly_t *poly, const uint32_t *support,
                                   uint32_t weight) {
  ring_poly_zero(poly);
  for (uint32_t i = 0U; i < weight; ++i) {
    ring_poly_toggle_bit(poly, support[i]);
  }
}

static void ring_poly_from_bytes(ring_poly_t *poly, const uint8_t *bytes,
                                 size_t byte_count) {
  ring_poly_zero(poly);
  for (size_t i = 0U; i < byte_count; ++i) {
    poly->value[i >> 3U] |= (uint64_t)bytes[i] << (8U * (i & 7U));
  }
  ring_poly_mask(poly);
}

static void ring_poly_to_bytes(const ring_poly_t *poly, uint8_t *bytes,
                               size_t byte_count) {
  for (size_t i = 0U; i < byte_count; ++i) {
    bytes[i] =
        (uint8_t)(poly->value[i >> 3U] >> (8U * (i & 7U)));
  }
  if ((poly->r & 7U) != 0U) {
    bytes[byte_count - 1U] &=
        (uint8_t)((1U << (poly->r & 7U)) - 1U);
  }
}

static void carryless_multiply64(uint64_t a, uint64_t b, uint64_t *low,
                                 uint64_t *high) {
  __uint128_t product = 0U;
  for (unsigned int bit = 0U; bit < 64U; ++bit) {
    const uint64_t mask = UINT64_C(0) - ((b >> bit) & 1U);
    product ^= ((__uint128_t)(a & mask)) << bit;
  }
  *low = (uint64_t)product;
  *high = (uint64_t)(product >> 64U);
}

static int ring_poly_mul(ring_poly_t *out, const ring_poly_t *a,
                         const ring_poly_t *b) {
  const uint64_t product_bits = (uint64_t)a->r * 2U;
  const size_t product_words = (size_t)((product_bits + 63U) / 64U);
  uint64_t *product = calloc(product_words, sizeof(*product));

  if (product == NULL) {
    return -1;
  }
  for (size_t i = 0U; i < a->words; ++i) {
    for (size_t j = 0U; j < b->words; ++j) {
      uint64_t low;
      uint64_t high;
      carryless_multiply64(a->value[i], b->value[j], &low, &high);
      product[i + j] ^= low;
      if ((i + j + 1U) < product_words) {
        product[i + j + 1U] ^= high;
      }
    }
  }

  for (uint64_t bit = (uint64_t)a->r * 2U - 2U; bit >= a->r; --bit) {
    const size_t high_word = (size_t)(bit >> 6U);
    const uint64_t high_mask = UINT64_C(1) << (bit & 63U);
    const uint64_t present = (product[high_word] & high_mask) != 0U;
    const uint64_t low_bit = bit - a->r;

    product[high_word] ^= high_mask & (UINT64_C(0) - present);
    product[low_bit >> 6U] ^=
        (UINT64_C(1) << (low_bit & 63U)) & (UINT64_C(0) - present);
  }
  memcpy(out->value, product, out->words * sizeof(*out->value));
  ring_poly_mask(out);
  secure_clean(product, product_words * sizeof(*product));
  free(product);
  return 0;
}

static int polynomial_degree(const uint64_t *value, size_t words) {
  for (size_t i = words; i-- > 0U;) {
    if (value[i] != 0U) {
      return (int)(i * 64U + 63U -
                   (unsigned int)__builtin_clzll(value[i]));
    }
  }
  return -1;
}

static int polynomial_is_one(const uint64_t *value, size_t words) {
  if (value[0] != 1U) {
    return 0;
  }
  for (size_t i = 1U; i < words; ++i) {
    if (value[i] != 0U) {
      return 0;
    }
  }
  return 1;
}

static void polynomial_xor_shift(uint64_t *destination,
                                 const uint64_t *source, size_t words,
                                 unsigned int shift) {
  const unsigned int word_shift = shift >> 6U;
  const unsigned int bit_shift = shift & 63U;

  for (size_t source_word = words; source_word-- > 0U;) {
    const size_t target_word = source_word + word_shift;
    if (target_word >= words) {
      continue;
    }
    destination[target_word] ^= source[source_word] << bit_shift;
    if ((bit_shift != 0U) && (target_word + 1U < words)) {
      destination[target_word + 1U] ^=
          source[source_word] >> (64U - bit_shift);
    }
  }
}

static void ring_poly_xor_rotate(ring_poly_t *destination,
                                 const ring_poly_t *source,
                                 uint32_t shift) {
  shift %= source->r;
  for (size_t word = 0U; word < source->words; ++word) {
    uint64_t bits = source->value[word];
    while (bits != 0U) {
      const unsigned int local = (unsigned int)__builtin_ctzll(bits);
      const uint32_t source_bit = (uint32_t)(word * 64U + local);
      if (source_bit < source->r) {
        uint32_t target = source_bit + shift;
        if (target >= source->r) {
          target -= source->r;
        }
        ring_poly_toggle_bit(destination, target);
      }
      bits &= bits - 1U;
    }
  }
}

static int ring_poly_inv(ring_poly_t *out, const ring_poly_t *input) {
  const size_t ext_words = ((size_t)input->r + 64U) / 64U;
  uint64_t *u = calloc(ext_words, sizeof(*u));
  uint64_t *v = calloc(ext_words, sizeof(*v));
  ring_poly_t g1 = {0};
  ring_poly_t g2 = {0};
  unsigned int iterations = 0U;
  int status = -1;

  if ((u == NULL) || (v == NULL) || (ring_poly_alloc(&g1, input->r) != 0) ||
      (ring_poly_alloc(&g2, input->r) != 0)) {
    free(u);
    free(v);
    ring_poly_free(&g1);
    ring_poly_free(&g2);
    return -1;
  }
  memcpy(u, input->value, input->words * sizeof(*u));
  v[0] = 1U;
  v[input->r >> 6U] |= UINT64_C(1) << (input->r & 63U);
  g1.value[0] = 1U;

  while (!polynomial_is_one(u, ext_words)) {
    int degree_u = polynomial_degree(u, ext_words);
    int degree_v = polynomial_degree(v, ext_words);
    int shift;

    if ((degree_u < 0) || (++iterations > 4U * input->r)) {
      goto cleanup;
    }
    if (degree_u < degree_v) {
      uint64_t *temporary_poly = u;
      ring_poly_t temporary_ring = g1;
      u = v;
      v = temporary_poly;
      g1 = g2;
      g2 = temporary_ring;
      degree_u = polynomial_degree(u, ext_words);
      degree_v = polynomial_degree(v, ext_words);
    }
    shift = degree_u - degree_v;
    polynomial_xor_shift(u, v, ext_words, (unsigned int)shift);
    ring_poly_xor_rotate(&g1, &g2, (uint32_t)shift);
  }

  ring_poly_copy(out, &g1);
  status = 0;

cleanup:
  secure_clean(u, ext_words * sizeof(*u));
  secure_clean(v, ext_words * sizeof(*v));
  free(u);
  free(v);
  ring_poly_free(&g1);
  ring_poly_free(&g2);
  return status;
}

static int shake_expand(uint8_t domain, const uint8_t *input,
                        size_t input_bytes, uint8_t *output,
                        size_t output_bytes) {
  uint8_t *domain_input = malloc(input_bytes + 1U);
  if (domain_input == NULL) {
    return -1;
  }
  domain_input[0] = domain;
  if (input_bytes != 0U) {
    memcpy(domain_input + 1U, input, input_bytes);
  }
  shake256(output, output_bytes, domain_input, input_bytes + 1U);
  secure_clean(domain_input, input_bytes + 1U);
  free(domain_input);
  return 0;
}

static uint32_t ct_equal_u32(uint32_t a, uint32_t b) {
  uint32_t difference = a ^ b;
  return 1U ^ ((difference | (0U - difference)) >> 31U);
}

static int sample_fixed_weight(uint32_t *indices, uint32_t weight,
                               uint32_t limit, uint8_t domain,
                               const uint8_t *seed, size_t seed_bytes) {
  uint8_t *random_words;

  if ((indices == NULL) || (weight > limit)) {
    return -1;
  }
  random_words = malloc((size_t)weight * 4U);
  if (random_words == NULL) {
    return -1;
  }
  if (shake_expand(domain, seed, seed_bytes, random_words,
                   (size_t)weight * 4U) != 0) {
    free(random_words);
    return -1;
  }

  for (uint32_t i = weight; i-- > 0U;) {
    const uint32_t random =
        (uint32_t)random_words[4U * i] |
        ((uint32_t)random_words[4U * i + 1U] << 8U) |
        ((uint32_t)random_words[4U * i + 2U] << 16U) |
        ((uint32_t)random_words[4U * i + 3U] << 24U);
    const uint32_t candidate =
        i + (uint32_t)(((uint64_t)random * (limit - i)) >> 32U);
    uint32_t duplicate = 0U;

    for (uint32_t j = i + 1U; j < weight; ++j) {
      duplicate |= ct_equal_u32(candidate, indices[j]);
    }
    {
      const uint32_t mask = 0U - duplicate;
      indices[i] = (mask & i) | (~mask & candidate);
    }
  }
  secure_clean(random_words, (size_t)weight * 4U);
  free(random_words);
  return 0;
}

static int derive_dense_poly(ring_poly_t *poly, uint8_t domain,
                             const uint8_t sigma[TRIKE_SEED_BYTES],
                             unsigned int wanted_parity) {
  const size_t bytes = ((size_t)poly->r + 7U) / 8U;
  uint8_t *encoded = malloc(bytes);
  if (encoded == NULL) {
    return -1;
  }
  if (shake_expand(domain, sigma, TRIKE_SEED_BYTES, encoded, bytes) != 0) {
    free(encoded);
    return -1;
  }
  ring_poly_from_bytes(poly, encoded, bytes);
  if (ring_poly_parity(poly) != (wanted_parity & 1U)) {
    ring_poly_toggle_bit(poly, 0U);
  }
  secure_clean(encoded, bytes);
  free(encoded);
  return 0;
}

static int derive_public_ring_values(
    const trike_kem_params_t *params,
    const uint8_t sigma[TRIKE_SEED_BYTES], ring_poly_t *t1, ring_poly_t *t2,
    ring_poly_t *r1) {
  if ((ring_poly_alloc(t1, params->r) != 0) ||
      (ring_poly_alloc(t2, params->r) != 0) ||
      (ring_poly_alloc(r1, params->r) != 0)) {
    return -1;
  }
  if ((derive_dense_poly(t1, TRIKE_DOMAIN_H1, sigma, 0U) != 0) ||
      (derive_dense_poly(t2, TRIKE_DOMAIN_H2, sigma, 0U) != 0) ||
      (derive_dense_poly(r1, TRIKE_DOMAIN_H3, sigma, 1U) != 0)) {
    return -1;
  }
  return 0;
}

static int hash_h4(const trike_kem_params_t *params,
                   const uint8_t message[TRIKE_MESSAGE_BYTES],
                   const uint64_t *r2_words, uint8_t *error) {
  const size_t poly_bytes = trike_kem_poly_bytes(params);
  const size_t input_bytes = TRIKE_MESSAGE_BYTES + poly_bytes;
  const uint32_t n = 3U * params->r;
  uint8_t *input = malloc(input_bytes);
  uint32_t *indices = malloc((size_t)params->t * sizeof(*indices));
  ring_poly_t r2 = {params->r, trike_kem_poly_words(params),
                    (uint64_t *)r2_words};
  int status = -1;

  if ((input == NULL) || (indices == NULL)) {
    goto cleanup;
  }
  memcpy(input, message, TRIKE_MESSAGE_BYTES);
  ring_poly_to_bytes(&r2, input + TRIKE_MESSAGE_BYTES, poly_bytes);
  if (sample_fixed_weight(indices, params->t, n, TRIKE_DOMAIN_H4, input,
                          input_bytes) != 0) {
    goto cleanup;
  }
  memset(error, 0, (size_t)n);
  for (uint32_t i = 0U; i < params->t; ++i) {
    error[indices[i]] = 1U;
  }
  status = 0;

cleanup:
  if (input != NULL) {
    secure_clean(input, input_bytes);
  }
  free(input);
  if (indices != NULL) {
    secure_clean(indices, (size_t)params->t * sizeof(*indices));
  }
  free(indices);
  return status;
}

static int hash_l(const trike_kem_params_t *params, const uint8_t *error,
                  uint8_t output[TRIKE_MESSAGE_BYTES]) {
  const size_t poly_bytes = trike_kem_poly_bytes(params);
  const size_t input_bytes = 3U * poly_bytes;
  uint8_t *input = calloc(input_bytes, 1U);
  if (input == NULL) {
    return -1;
  }
  for (uint32_t block = 0U; block < 3U; ++block) {
    for (uint32_t bit = 0U; bit < params->r; ++bit) {
      input[(size_t)block * poly_bytes + (bit >> 3U)] |=
          (uint8_t)(error[(size_t)block * params->r + bit] << (bit & 7U));
    }
  }
  if (shake_expand(TRIKE_DOMAIN_L, input, input_bytes, output,
                   TRIKE_MESSAGE_BYTES) != 0) {
    secure_clean(input, input_bytes);
    free(input);
    return -1;
  }
  secure_clean(input, input_bytes);
  free(input);
  return 0;
}

static int hash_k(const trike_kem_params_t *params,
                  const uint8_t message[TRIKE_MESSAGE_BYTES],
                  const trike_ciphertext_t *ciphertext,
                  uint8_t output[TRIKE_SHARED_SECRET_BYTES]) {
  const size_t poly_bytes = trike_kem_poly_bytes(params);
  const size_t input_bytes = 2U * TRIKE_MESSAGE_BYTES + 2U * poly_bytes;
  uint8_t *input = malloc(input_bytes);
  ring_poly_t u = {params->r, trike_kem_poly_words(params), ciphertext->u};
  ring_poly_t v = {params->r, trike_kem_poly_words(params), ciphertext->v};
  int status;

  if (input == NULL) {
    return -1;
  }
  memcpy(input, message, TRIKE_MESSAGE_BYTES);
  ring_poly_to_bytes(&u, input + TRIKE_MESSAGE_BYTES, poly_bytes);
  ring_poly_to_bytes(&v, input + TRIKE_MESSAGE_BYTES + poly_bytes,
                     poly_bytes);
  memcpy(input + TRIKE_MESSAGE_BYTES + 2U * poly_bytes, ciphertext->c2,
         TRIKE_MESSAGE_BYTES);
  status = shake_expand(TRIKE_DOMAIN_K, input, input_bytes, output,
                        TRIKE_SHARED_SECRET_BYTES);
  secure_clean(input, input_bytes);
  free(input);
  return status;
}

static uint32_t secure_compare(const uint8_t *a, const uint8_t *b,
                               size_t bytes) {
  uint32_t difference = 0U;
  for (size_t i = 0U; i < bytes; ++i) {
    difference |= (uint32_t)(a[i] ^ b[i]);
  }
  return 1U ^ ((difference | (0U - difference)) >> 31U);
}

static int allocate_public_key(const trike_kem_params_t *params,
                               trike_public_key_t *public_key) {
  memset(public_key, 0, sizeof(*public_key));
  public_key->params = params;
  public_key->r2 = calloc(trike_kem_poly_words(params), sizeof(*public_key->r2));
  return public_key->r2 == NULL ? -1 : 0;
}

static int allocate_secret_key(const trike_kem_params_t *params,
                               trike_secret_key_t *secret_key) {
  const size_t words = trike_kem_poly_words(params);
  memset(secret_key, 0, sizeof(*secret_key));
  secret_key->params = params;
  secret_key->h_support =
      calloc((size_t)3U * params->w, sizeof(*secret_key->h_support));
  secret_key->t0 = calloc(words, sizeof(*secret_key->t0));
  secret_key->r2 = calloc(words, sizeof(*secret_key->r2));
  if ((secret_key->h_support == NULL) || (secret_key->t0 == NULL) ||
      (secret_key->r2 == NULL)) {
    trike_secret_key_free(secret_key);
    return -1;
  }
  return 0;
}

static int allocate_ciphertext(const trike_kem_params_t *params,
                               trike_ciphertext_t *ciphertext) {
  const size_t words = trike_kem_poly_words(params);
  memset(ciphertext, 0, sizeof(*ciphertext));
  ciphertext->params = params;
  ciphertext->u = calloc(words, sizeof(*ciphertext->u));
  ciphertext->v = calloc(words, sizeof(*ciphertext->v));
  if ((ciphertext->u == NULL) || (ciphertext->v == NULL)) {
    trike_ciphertext_free(ciphertext);
    return -1;
  }
  return 0;
}

int trike_kem_keypair(const trike_kem_params_t *params,
                      const uint8_t seed[TRIKE_SEED_BYTES],
                      trike_public_key_t *public_key,
                      trike_secret_key_t *secret_key) {
  uint8_t key_material[2U * TRIKE_SEED_BYTES];
  ring_poly_t h0 = {0};
  ring_poly_t h1 = {0};
  ring_poly_t h2 = {0};
  ring_poly_t t0 = {0};
  ring_poly_t t1 = {0};
  ring_poly_t t2 = {0};
  ring_poly_t r1 = {0};
  ring_poly_t r2 = {0};
  ring_poly_t numerator = {0};
  ring_poly_t denominator = {0};
  ring_poly_t inverse = {0};
  ring_poly_t temporary = {0};
  int status = -1;

  if ((params == NULL) || (seed == NULL) || (public_key == NULL) ||
      (secret_key == NULL)) {
    return -1;
  }
  if ((allocate_public_key(params, public_key) != 0) ||
      (allocate_secret_key(params, secret_key) != 0)) {
    goto cleanup;
  }
  if (shake_expand(TRIKE_DOMAIN_KEY_MATERIAL, seed, TRIKE_SEED_BYTES,
                   key_material, sizeof(key_material)) != 0) {
    goto cleanup;
  }
  memcpy(public_key->sigma, key_material, TRIKE_SEED_BYTES);
  memcpy(secret_key->sigma, key_material, TRIKE_SEED_BYTES);
  memcpy(secret_key->rejection_secret, key_material + TRIKE_SEED_BYTES,
         TRIKE_MESSAGE_BYTES);

  for (uint32_t block = 0U; block < 3U; ++block) {
    if (sample_fixed_weight(secret_key->h_support + (size_t)block * params->w,
                            params->w, params->r,
                            (uint8_t)(TRIKE_DOMAIN_SECRET_H0 + block), seed,
                            TRIKE_SEED_BYTES) != 0) {
      goto cleanup;
    }
  }
  if ((ring_poly_alloc(&h0, params->r) != 0) ||
      (ring_poly_alloc(&h1, params->r) != 0) ||
      (ring_poly_alloc(&h2, params->r) != 0) ||
      (ring_poly_alloc(&t0, params->r) != 0) ||
      (ring_poly_alloc(&r2, params->r) != 0) ||
      (ring_poly_alloc(&numerator, params->r) != 0) ||
      (ring_poly_alloc(&denominator, params->r) != 0) ||
      (ring_poly_alloc(&inverse, params->r) != 0) ||
      (ring_poly_alloc(&temporary, params->r) != 0) ||
      (derive_public_ring_values(params, public_key->sigma, &t1, &t2, &r1) !=
       0)) {
    goto cleanup;
  }
  ring_poly_from_support(&h0, secret_key->h_support, params->w);
  ring_poly_from_support(&h1, secret_key->h_support + params->w, params->w);
  ring_poly_from_support(&h2, secret_key->h_support + 2U * params->w,
                         params->w);

  /* t0 = (r1*h0 + h1) / (r1 + t1). */
  if (ring_poly_mul(&numerator, &r1, &h0) != 0) {
    goto cleanup;
  }
  ring_poly_xor(&numerator, &h1);
  ring_poly_copy(&denominator, &r1);
  ring_poly_xor(&denominator, &t1);
  if ((ring_poly_inv(&inverse, &denominator) != 0) ||
      (ring_poly_mul(&t0, &numerator, &inverse) != 0)) {
    goto cleanup;
  }
  if ((ring_poly_mul(&temporary, &denominator, &t0) != 0) ||
      (memcmp(temporary.value, numerator.value,
              temporary.words * sizeof(*temporary.value)) != 0)) {
    goto cleanup;
  }

  /* r2 = (h2 + t0*t2) / (t0 + h0). */
  if (ring_poly_mul(&numerator, &t0, &t2) != 0) {
    goto cleanup;
  }
  ring_poly_xor(&numerator, &h2);
  ring_poly_copy(&denominator, &t0);
  ring_poly_xor(&denominator, &h0);
  if ((ring_poly_inv(&inverse, &denominator) != 0) ||
      (ring_poly_mul(&r2, &numerator, &inverse) != 0)) {
    goto cleanup;
  }

  /* Check both divisions before exporting the expanded key. */
  if ((ring_poly_mul(&temporary, &denominator, &r2) != 0) ||
      (memcmp(temporary.value, numerator.value,
              temporary.words * sizeof(*temporary.value)) != 0)) {
    goto cleanup;
  }

  memcpy(public_key->r2, r2.value, r2.words * sizeof(*r2.value));
  memcpy(secret_key->t0, t0.value, t0.words * sizeof(*t0.value));
  memcpy(secret_key->r2, r2.value, r2.words * sizeof(*r2.value));
  status = 0;

cleanup:
  secure_clean(key_material, sizeof(key_material));
  ring_poly_free(&h0);
  ring_poly_free(&h1);
  ring_poly_free(&h2);
  ring_poly_free(&t0);
  ring_poly_free(&t1);
  ring_poly_free(&t2);
  ring_poly_free(&r1);
  ring_poly_free(&r2);
  ring_poly_free(&numerator);
  ring_poly_free(&denominator);
  ring_poly_free(&inverse);
  ring_poly_free(&temporary);
  if (status != 0) {
    trike_public_key_free(public_key);
    trike_secret_key_free(secret_key);
  }
  return status;
}

int trike_kem_encaps(const trike_public_key_t *public_key,
                     const uint8_t seed[TRIKE_SEED_BYTES],
                     trike_ciphertext_t *ciphertext,
                     uint8_t shared_secret[TRIKE_SHARED_SECRET_BYTES]) {
  const trike_kem_params_t *params;
  uint8_t message[TRIKE_MESSAGE_BYTES];
  uint8_t l_value[TRIKE_MESSAGE_BYTES];
  uint8_t *error = NULL;
  ring_poly_t e0 = {0};
  ring_poly_t e1 = {0};
  ring_poly_t e2 = {0};
  ring_poly_t t1 = {0};
  ring_poly_t t2 = {0};
  ring_poly_t r1 = {0};
  ring_poly_t r2;
  ring_poly_t u;
  ring_poly_t v;
  ring_poly_t temporary = {0};
  int status = -1;

  if ((public_key == NULL) || (public_key->params == NULL) ||
      (public_key->r2 == NULL) || (seed == NULL) || (ciphertext == NULL) ||
      (shared_secret == NULL)) {
    return -1;
  }
  params = public_key->params;
  if (allocate_ciphertext(params, ciphertext) != 0) {
    return -1;
  }
  error = calloc((size_t)3U * params->r, 1U);
  if ((error == NULL) ||
      (shake_expand(TRIKE_DOMAIN_MESSAGE, seed, TRIKE_SEED_BYTES, message,
                    sizeof(message)) != 0) ||
      (hash_h4(params, message, public_key->r2, error) != 0) ||
      (ring_poly_alloc(&e0, params->r) != 0) ||
      (ring_poly_alloc(&e1, params->r) != 0) ||
      (ring_poly_alloc(&e2, params->r) != 0) ||
      (ring_poly_alloc(&temporary, params->r) != 0) ||
      (derive_public_ring_values(params, public_key->sigma, &t1, &t2, &r1) !=
       0)) {
    goto cleanup;
  }
  for (uint32_t bit = 0U; bit < params->r; ++bit) {
    if (error[bit] != 0U) {
      ring_poly_toggle_bit(&e0, bit);
    }
    if (error[params->r + bit] != 0U) {
      ring_poly_toggle_bit(&e1, bit);
    }
    if (error[2U * params->r + bit] != 0U) {
      ring_poly_toggle_bit(&e2, bit);
    }
  }
  r2 = (ring_poly_t){params->r, trike_kem_poly_words(params),
                     public_key->r2};
  u = (ring_poly_t){params->r, trike_kem_poly_words(params), ciphertext->u};
  v = (ring_poly_t){params->r, trike_kem_poly_words(params), ciphertext->v};

  ring_poly_copy(&u, &e0);
  if (ring_poly_mul(&temporary, &e1, &r1) != 0) {
    goto cleanup;
  }
  ring_poly_xor(&u, &temporary);
  if (ring_poly_mul(&temporary, &e2, &r2) != 0) {
    goto cleanup;
  }
  ring_poly_xor(&u, &temporary);

  ring_poly_copy(&v, &e0);
  if (ring_poly_mul(&temporary, &e1, &t1) != 0) {
    goto cleanup;
  }
  ring_poly_xor(&v, &temporary);
  if (ring_poly_mul(&temporary, &e2, &t2) != 0) {
    goto cleanup;
  }
  ring_poly_xor(&v, &temporary);

  if (hash_l(params, error, l_value) != 0) {
    goto cleanup;
  }
  for (size_t i = 0U; i < TRIKE_MESSAGE_BYTES; ++i) {
    ciphertext->c2[i] = message[i] ^ l_value[i];
  }
  if (hash_k(params, message, ciphertext, shared_secret) != 0) {
    goto cleanup;
  }
  status = 0;

cleanup:
  secure_clean(message, sizeof(message));
  secure_clean(l_value, sizeof(l_value));
  if (error != NULL) {
    secure_clean(error, (size_t)3U * params->r);
  }
  free(error);
  ring_poly_free(&e0);
  ring_poly_free(&e1);
  ring_poly_free(&e2);
  ring_poly_free(&t1);
  ring_poly_free(&t2);
  ring_poly_free(&r1);
  ring_poly_free(&temporary);
  if (status != 0) {
    trike_ciphertext_free(ciphertext);
  }
  return status;
}

int trike_kem_decaps(
    const trike_secret_key_t *secret_key,
    const trike_ciphertext_t *ciphertext,
    uint8_t shared_secret[TRIKE_SHARED_SECRET_BYTES], int *ciphertext_valid,
    uint32_t *decoder_residual_weight) {
  const trike_kem_params_t *params;
  const size_t words =
      secret_key == NULL ? 0U : trike_kem_poly_words(secret_key->params);
  uint8_t message_prime[TRIKE_MESSAGE_BYTES];
  uint8_t selected_message[TRIKE_MESSAGE_BYTES];
  uint8_t l_value[TRIKE_MESSAGE_BYTES];
  uint8_t *decoded_error = NULL;
  uint8_t *expected_error = NULL;
  uint8_t *syndrome = NULL;
  ring_poly_t h0 = {0};
  ring_poly_t syndrome_poly = {0};
  ring_poly_t temporary = {0};
  ring_poly_t u_plus_v = {0};
  ring_poly_t u;
  ring_poly_t v;
  ring_poly_t t0;
  uint32_t residual_weight = UINT32_MAX;
  uint32_t valid;
  int decode_status;
  int status = -1;

  if ((secret_key == NULL) || (secret_key->params == NULL) ||
      (secret_key->h_support == NULL) || (secret_key->t0 == NULL) ||
      (secret_key->r2 == NULL) || (ciphertext == NULL) ||
      (ciphertext->params != secret_key->params) || (ciphertext->u == NULL) ||
      (ciphertext->v == NULL) || (shared_secret == NULL)) {
    return -1;
  }
  params = secret_key->params;
  decoded_error = calloc((size_t)3U * params->r, 1U);
  expected_error = calloc((size_t)3U * params->r, 1U);
  syndrome = calloc(params->r, 1U);
  if ((decoded_error == NULL) || (expected_error == NULL) ||
      (syndrome == NULL) || (ring_poly_alloc(&h0, params->r) != 0) ||
      (ring_poly_alloc(&syndrome_poly, params->r) != 0) ||
      (ring_poly_alloc(&temporary, params->r) != 0) ||
      (ring_poly_alloc(&u_plus_v, params->r) != 0)) {
    goto cleanup;
  }
  ring_poly_from_support(&h0, secret_key->h_support, params->w);
  u = (ring_poly_t){params->r, words, ciphertext->u};
  v = (ring_poly_t){params->r, words, ciphertext->v};
  t0 = (ring_poly_t){params->r, words, secret_key->t0};

  /* s = h0*u + t0*(u+v). */
  ring_poly_copy(&u_plus_v, &u);
  ring_poly_xor(&u_plus_v, &v);
  if ((ring_poly_mul(&syndrome_poly, &h0, &u) != 0) ||
      (ring_poly_mul(&temporary, &t0, &u_plus_v) != 0)) {
    goto cleanup;
  }
  ring_poly_xor(&syndrome_poly, &temporary);
  for (uint32_t bit = 0U; bit < params->r; ++bit) {
    syndrome[bit] = (uint8_t)ring_poly_get_bit(&syndrome_poly, bit);
  }

  decode_status =
      trike_ms_quant_decode(&params->decoder, secret_key->h_support, syndrome,
                            decoded_error, &residual_weight);
  if (decode_status < 0) {
    goto cleanup;
  }
  if (hash_l(params, decoded_error, l_value) != 0) {
    goto cleanup;
  }
  for (size_t i = 0U; i < TRIKE_MESSAGE_BYTES; ++i) {
    message_prime[i] = ciphertext->c2[i] ^ l_value[i];
  }
  if (hash_h4(params, message_prime, secret_key->r2, expected_error) != 0) {
    goto cleanup;
  }
  valid = secure_compare(decoded_error, expected_error,
                         (size_t)3U * params->r);
  valid &= ct_equal_u32(residual_weight, 0U);
  {
    const uint8_t mask = (uint8_t)(0U - valid);
    for (size_t i = 0U; i < TRIKE_MESSAGE_BYTES; ++i) {
      selected_message[i] =
          (message_prime[i] & mask) |
          (secret_key->rejection_secret[i] & (uint8_t)~mask);
    }
  }
  if (hash_k(params, selected_message, ciphertext, shared_secret) != 0) {
    goto cleanup;
  }
  if (ciphertext_valid != NULL) {
    *ciphertext_valid = (int)valid;
  }
  if (decoder_residual_weight != NULL) {
    *decoder_residual_weight = residual_weight;
  }
  status = 0;

cleanup:
  secure_clean(message_prime, sizeof(message_prime));
  secure_clean(selected_message, sizeof(selected_message));
  secure_clean(l_value, sizeof(l_value));
  if (decoded_error != NULL) {
    secure_clean(decoded_error, (size_t)3U * params->r);
  }
  if (expected_error != NULL) {
    secure_clean(expected_error, (size_t)3U * params->r);
  }
  if (syndrome != NULL) {
    secure_clean(syndrome, params->r);
  }
  free(decoded_error);
  free(expected_error);
  free(syndrome);
  ring_poly_free(&h0);
  ring_poly_free(&syndrome_poly);
  ring_poly_free(&temporary);
  ring_poly_free(&u_plus_v);
  return status;
}

void trike_public_key_free(trike_public_key_t *public_key) {
  if (public_key == NULL) {
    return;
  }
  if (public_key->r2 != NULL && public_key->params != NULL) {
    secure_clean(public_key->r2,
                 trike_kem_poly_words(public_key->params) *
                     sizeof(*public_key->r2));
  }
  free(public_key->r2);
  memset(public_key, 0, sizeof(*public_key));
}

void trike_secret_key_free(trike_secret_key_t *secret_key) {
  if (secret_key == NULL) {
    return;
  }
  if (secret_key->params != NULL) {
    const size_t words = trike_kem_poly_words(secret_key->params);
    if (secret_key->h_support != NULL) {
      secure_clean(secret_key->h_support,
                   (size_t)3U * secret_key->params->w *
                       sizeof(*secret_key->h_support));
    }
    if (secret_key->t0 != NULL) {
      secure_clean(secret_key->t0, words * sizeof(*secret_key->t0));
    }
    if (secret_key->r2 != NULL) {
      secure_clean(secret_key->r2, words * sizeof(*secret_key->r2));
    }
  }
  free(secret_key->h_support);
  free(secret_key->t0);
  free(secret_key->r2);
  secure_clean(secret_key, sizeof(*secret_key));
}

void trike_ciphertext_free(trike_ciphertext_t *ciphertext) {
  if (ciphertext == NULL) {
    return;
  }
  if (ciphertext->params != NULL) {
    const size_t words = trike_kem_poly_words(ciphertext->params);
    if (ciphertext->u != NULL) {
      secure_clean(ciphertext->u, words * sizeof(*ciphertext->u));
    }
    if (ciphertext->v != NULL) {
      secure_clean(ciphertext->v, words * sizeof(*ciphertext->v));
    }
  }
  free(ciphertext->u);
  free(ciphertext->v);
  secure_clean(ciphertext, sizeof(*ciphertext));
}
