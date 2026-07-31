#define _POSIX_C_SOURCE 200809L

#include "trike_kem.h"

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static void make_seed(uint8_t seed[TRIKE_SEED_BYTES], uint64_t value,
                      uint8_t tag) {
  memset(seed, 0, TRIKE_SEED_BYTES);
  for (unsigned int i = 0U; i < 8U; ++i) {
    seed[i] = (uint8_t)(value >> (8U * i));
  }
  seed[TRIKE_SEED_BYTES - 1U] = tag;
}

static double elapsed_seconds(const struct timespec *start,
                              const struct timespec *end) {
  return (double)(end->tv_sec - start->tv_sec) +
         (double)(end->tv_nsec - start->tv_nsec) / 1.0e9;
}

int main(int argc, char **argv) {
  const char *profile_name = argc > 1 ? argv[1] : "trike128";
  uint64_t seed_value = 1U;
  const trike_kem_params_t *params;
  trike_public_key_t public_key = {0};
  trike_secret_key_t secret_key = {0};
  trike_ciphertext_t ciphertext = {0};
  uint8_t key_seed[TRIKE_SEED_BYTES];
  uint8_t encaps_seed[TRIKE_SEED_BYTES];
  uint8_t encaps_secret[TRIKE_SHARED_SECRET_BYTES];
  uint8_t decaps_secret[TRIKE_SHARED_SECRET_BYTES];
  uint8_t rejected_secret[TRIKE_SHARED_SECRET_BYTES];
  struct timespec start;
  struct timespec after_keypair;
  struct timespec after_encaps;
  struct timespec after_decaps;
  uint32_t residual_weight = UINT32_MAX;
  int valid = 0;
  int tampered_valid = 1;
  int status = EXIT_FAILURE;

  if (argc > 2) {
    char *end = NULL;
    seed_value = strtoull(argv[2], &end, 0);
    if ((end == argv[2]) || (*end != '\0')) {
      fprintf(stderr, "invalid seed: %s\n", argv[2]);
      return EXIT_FAILURE;
    }
  }
  params = trike_kem_params_by_name(profile_name);
  if (params == NULL) {
    fprintf(stderr, "unknown profile: %s\n", profile_name);
    return EXIT_FAILURE;
  }
  make_seed(key_seed, seed_value, 0x4bU);
  make_seed(encaps_seed, seed_value, 0x45U);

  clock_gettime(CLOCK_MONOTONIC, &start);
  if (trike_kem_keypair(params, key_seed, &public_key, &secret_key) != 0) {
    fprintf(stderr, "keypair failed\n");
    goto cleanup;
  }
  clock_gettime(CLOCK_MONOTONIC, &after_keypair);
  if (trike_kem_encaps(&public_key, encaps_seed, &ciphertext,
                       encaps_secret) != 0) {
    fprintf(stderr, "encaps failed\n");
    goto cleanup;
  }
  clock_gettime(CLOCK_MONOTONIC, &after_encaps);
  if (trike_kem_decaps(&secret_key, &ciphertext, decaps_secret, &valid,
                       &residual_weight) != 0) {
    fprintf(stderr, "decaps failed\n");
    goto cleanup;
  }
  clock_gettime(CLOCK_MONOTONIC, &after_decaps);
  if ((valid != 1) ||
      (memcmp(encaps_secret, decaps_secret, sizeof(encaps_secret)) != 0)) {
    fprintf(stderr,
            "valid ciphertext mismatch: valid=%d residual=%" PRIu32 "\n",
            valid, residual_weight);
    goto cleanup;
  }

  ciphertext.c2[0] ^= 1U;
  if (trike_kem_decaps(&secret_key, &ciphertext, rejected_secret,
                       &tampered_valid, NULL) != 0) {
    fprintf(stderr, "tampered decaps failed\n");
    goto cleanup;
  }
  ciphertext.c2[0] ^= 1U;
  if ((tampered_valid != 0) ||
      (memcmp(encaps_secret, rejected_secret, sizeof(encaps_secret)) == 0)) {
    fprintf(stderr, "implicit rejection check failed\n");
    goto cleanup;
  }

  printf("TRIKE KEM software self-test passed\n");
  printf("profile=%s r=%" PRIu32 " w=%" PRIu32 " t=%" PRIu32
         " seed=%" PRIu64 "\n",
         params->name, params->r, params->w, params->t, seed_value);
  printf("decoder=ms_quant iterations=%" PRIu32
         " residual=%" PRIu32 " ciphertext_valid=%d\n",
         params->decoder.iterations, residual_weight, valid);
  printf("keypair_seconds=%.6f encaps_seconds=%.6f decaps_seconds=%.6f\n",
         elapsed_seconds(&start, &after_keypair),
         elapsed_seconds(&after_keypair, &after_encaps),
         elapsed_seconds(&after_encaps, &after_decaps));
  printf("tampered_ciphertext_valid=%d implicit_rejection=pass\n",
         tampered_valid);
  status = EXIT_SUCCESS;

cleanup:
  trike_ciphertext_free(&ciphertext);
  trike_secret_key_free(&secret_key);
  trike_public_key_free(&public_key);
  return status;
}
