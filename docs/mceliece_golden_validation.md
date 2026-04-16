# Golden Model Validation

## Scope

`golden/mdpc_min_sum_golden.c` now serves two purposes:

- `--emit-svh <path>` keeps the original toy-demo behavior used by the RTL testbenches.
- `--paper80-once` and `--paper80-batch` validate a paper-scale decoder instance with two independent software models.

The paper does not publish a concrete reproducible private key matrix `H = [H0 | H1]`. Because of that, the paper80 flow uses deterministic random QC-MDPC instances generated from a seed, plus a deterministic `t = 84` error vector on the all-zero codeword.

## What Matches The Paper

The golden model keeps the following paper-aligned choices:

- `C = 9`
- 4-bit message magnitude with saturation at `15`
- `alpha = 3/32 = 2^-4 + 2^-5`
- rounding after scaling
- check-node state `{min1, min2, min_id, sign_xor}`
- variable-node update `app = gamma + alpha * sum(v)`
- extrinsic update `u = app - alpha * v`
- default paper80 parameters `(n0, r, w, t, Imax) = (2, 4801, 45, 84, 30)`

These correspond to Algorithm 1 in the paper and the implementation notes around Fig. 6 and Fig. 7.

## Important Limits

The toy RTL demo intentionally remains smaller than the paper setup:

- toy parameters are still `R = 8`, `W = 3`, `Imax = 4`
- toy `H_BASE` is fixed, hand-written, and not paper-scale
- `--emit-svh` remains a toy-only compatibility path
- the current decoder stops at end-of-iteration, matching the RTL schedule

That end-of-iteration stop differs slightly from the paper pseudocode only for already-converged intermediate states; it does not affect the preserved RTL demo flow.

## Trust Strategy

Paper-scale validation uses two independent software decoders on the same seeded instance:

- a schedule-aware model that follows the existing RTL-facing column/lane ordering
- a row-centric oracle that executes Algorithm 1 directly from row adjacency data

For every paper80 run, both models must agree on:

- success or failure
- iteration count
- final hard decision vector
- per-iteration syndrome zero/nonzero history

If the two models disagree, the command exits with an error.

## Reproducible Commands

```sh
make golden-self-test
make golden-paper80-once PAPER80_SEED=1
make golden-paper80-batch PAPER80_BASE_SEED=1 PAPER80_TRIALS=8
```

`golden-self-test` checks:

- scalar rounding on positive and negative values
- 4-bit saturation
- toy single-bit error agreement between both models
- one toy two-bit error agreement case

## Current Verification Snapshot

The implementation was checked with the following reproducible results:

- `--emit-svh` regenerates the toy demo vectors byte-for-byte relative to the pre-refactor baseline
- `--self-test` passes
- `--paper80-once --seed 1` reports `models_agree=yes`, `success=1`, `iterations=4`, `final_syndrome_weight=0`
- `--paper80-batch --base-seed 1 --trials 8` reports `successes=8`, `failures=0`, with first successful seed `1` in `4` iterations

These results establish that the paper-scale flow is internally cross-checked, deterministic, and compatible with the existing toy RTL regression path.
