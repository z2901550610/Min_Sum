#ifndef TRIKE_KEM_H
#define TRIKE_KEM_H

#include <stddef.h>
#include <stdint.h>

#include "trike_ms_quant.h"

#define TRIKE_SEED_BYTES 32U
#define TRIKE_SHARED_SECRET_BYTES 32U
#define TRIKE_MESSAGE_BYTES 32U

typedef struct {
  const char *name;
  uint32_t security_bits;
  uint32_t r;
  uint32_t w;
  uint32_t t;
  trike_ms_quant_config_t decoder;
} trike_kem_params_t;

typedef struct {
  const trike_kem_params_t *params;
  uint8_t sigma[TRIKE_SEED_BYTES];
  uint64_t *r2;
} trike_public_key_t;

typedef struct {
  const trike_kem_params_t *params;
  uint8_t sigma[TRIKE_SEED_BYTES];
  uint8_t rejection_secret[TRIKE_MESSAGE_BYTES];
  uint32_t *h_support;
  uint64_t *t0;
  uint64_t *r2;
} trike_secret_key_t;

typedef struct {
  const trike_kem_params_t *params;
  uint64_t *u;
  uint64_t *v;
  uint8_t c2[TRIKE_MESSAGE_BYTES];
} trike_ciphertext_t;

const trike_kem_params_t *trike_kem_params_by_name(const char *name);
size_t trike_kem_poly_words(const trike_kem_params_t *params);
size_t trike_kem_poly_bytes(const trike_kem_params_t *params);

/*
 * Deterministic entrypoints used by the software bring-up and regression
 * harness. The seed is expanded with SHAKE256. A production integration must
 * replace these seeds with output from its approved random source.
 */
int trike_kem_keypair(const trike_kem_params_t *params,
                      const uint8_t seed[TRIKE_SEED_BYTES],
                      trike_public_key_t *public_key,
                      trike_secret_key_t *secret_key);

int trike_kem_encaps(const trike_public_key_t *public_key,
                     const uint8_t seed[TRIKE_SEED_BYTES],
                     trike_ciphertext_t *ciphertext,
                     uint8_t shared_secret[TRIKE_SHARED_SECRET_BYTES]);

int trike_kem_decaps(
    const trike_secret_key_t *secret_key,
    const trike_ciphertext_t *ciphertext,
    uint8_t shared_secret[TRIKE_SHARED_SECRET_BYTES], int *ciphertext_valid,
    uint32_t *decoder_residual_weight);

void trike_public_key_free(trike_public_key_t *public_key);
void trike_secret_key_free(trike_secret_key_t *secret_key);
void trike_ciphertext_free(trike_ciphertext_t *ciphertext);

#endif
