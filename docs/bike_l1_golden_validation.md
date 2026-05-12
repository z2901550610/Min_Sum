# BIKE-L1 Min-Sum Golden Validation

## Scope

`golden/bike_l1_min_sum_golden.c` is a standalone BIKE-sized min-sum golden model.

It is the BIKE-L1-sized software reference for the RTL syndrome-decoding flow:

- generate a target error vector `e`
- compute the input syndrome `s = H*e`
- decode from `s` with an all-zero initial error estimate
- verify the residual syndrome `s ^ H*e_hat`

This program does **not** implement the official BIKE bit-flipping decoder family. It applies the repository's scaled min-sum equations on a BIKE-L1-sized double-circulant matrix.

## Parameter Baseline

This implementation locks the structural baseline to the user-requested set:

- `n0 = 2`
- `r = 12323`
- per-half first-column weight `wh = 71`
- total row weight `w = 142`
- code length `n = 24646`
- error weight `t = 134`
- row-group count `L = 2`

The matrix is generated as `H = [H0 | H1]` from deterministic seeded first-column supports.

## Decoder Defaults

BIKE does not provide official min-sum defaults for `C`, `alpha`, and `Imax`. This golden therefore ships with **repo-defined min-sum defaults**, selected by deterministic calibration over a fixed candidate grid.

Current shipped defaults:

- `C = 7`
- `alpha = 2^-4`
- `Imax = 6`
- message magnitude width = 4 bits with saturation at `15`
- scaling uses rounding

These are implementation defaults for this BIKE-sized min-sum model only. They must not be described as official BIKE decoder constants.

## Trust Strategy

Every BIKE-L1 run cross-checks two independent software models on the same seeded instance:

- a schedule-aware model that preserves the row-group/column ordering style with `L = 2`
- a row-centric oracle that executes the same min-sum equations directly from graph adjacency

The run is accepted only if both models agree on:

- success or failure
- iteration count
- final hard-decision vector
- final residual syndrome weight
- per-iteration residual syndrome zero/nonzero history

## CLI And Build Targets

CLI:

- `--bike-l1-once --seed <u64>`
- `--bike-l1-batch --base-seed <u64> --trials <n>`
- `--bike-l1-calibrate --base-seed <u64> --trials <n>`
- `--self-test`

Optional overrides for once/batch:

- `--c-val <int>`
- `--alpha-shift0 <int> --alpha-shift1 <int>`
- `--i-max <int>`

Make targets:

```sh
make bike-golden-self-test
make bike-golden-once BIKE_SEED=1
make bike-golden-batch BIKE_BASE_SEED=1 BIKE_TRIALS=8
make bike-golden-calibrate BIKE_CAL_BASE_SEED=1 BIKE_CAL_TRIALS=4
```

## Current Verification Snapshot

The implementation was checked with the following reproducible results:

- `--self-test` passed
- `--bike-l1-once --seed 1` reported `models_agree=yes`, `success=1`, `iterations=3`, `final_residual_weight=0`, with defaults `C=7`, `alpha=2^-4`, `Imax=6`
- `--bike-l1-batch --base-seed 1 --trials 8` reported `successes=8`, `failures=0`, first successful seed `1`, first successful iterations `3`
- `--bike-l1-calibrate --base-seed 1 --trials 4` ranked the fixed grid and selected `C=7`, `alpha=2^-4`, `Imax=6` as the best tuple

These checks establish that the BIKE-L1 min-sum golden is deterministic and cross-validated internally. Regular RTL regression defines `BIKE_TOY_PARAMS` for the compact demo dimensions, and Vivado-oriented builds use the BIKE-L1 dimensions from `rtl/decoder_top.sv`.
