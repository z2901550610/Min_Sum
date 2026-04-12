# BIKE-L1 Min-Sum Golden Validation

## Scope

`golden/bike_l1_min_sum_golden.c` is a standalone BIKE-sized min-sum golden model.

It is intentionally separate from the McEliece/paper80 golden. This keeps two different validation stories apart:

- `golden/mdpc_min_sum_golden.c` remains the toy/RTL plus paper80 McEliece-oriented min-sum reference.
- `golden/bike_l1_min_sum_golden.c` is a BIKE-parameterized min-sum reference for the user-requested Level1-style dimensions.

This program does **not** implement the official BIKE bit-flipping decoder family. It applies the same scaled min-sum equations already used by the repo’s MDPC golden, but on a BIKE-L1-sized double-circulant matrix.

## Parameter Baseline

This implementation locks the structural baseline to the user-requested set:

- `n0 = 2`
- `r = 12323`
- per-half first-column weight `wh = 71`
- total row weight `w = 142`
- code length `n = 24646`
- error weight `t = 134`
- lane count `L = 2`

The matrix is generated as `H = [H0 | H1]` from deterministic seeded first-column supports.

## Decoder Defaults

BIKE does not provide official min-sum defaults for `C`, `alpha`, and `Imax`. This golden therefore ships with **repo-defined min-sum defaults**, selected by deterministic calibration over a fixed candidate grid.

Current shipped defaults:

- `C = 7`
- `alpha = 2^-4 + 2^-6`
- `Imax = 6`
- message magnitude width = 4 bits with saturation at `15`
- scaling uses rounding

These are implementation defaults for this BIKE-sized min-sum model only. They must not be described as official BIKE decoder constants.

## Trust Strategy

Every BIKE-L1 run cross-checks two independent software models on the same seeded instance:

- a schedule-aware model that preserves the lane/column ordering style with `L = 2`
- a row-centric oracle that executes the same min-sum equations directly from graph adjacency

The run is accepted only if both models agree on:

- success or failure
- iteration count
- final hard-decision vector
- per-iteration syndrome zero/nonzero history

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
- `--bike-l1-once --seed 1` reported `models_agree=yes`, `success=1`, `iterations=2`, `final_syndrome_weight=0`, with defaults `C=7`, `alpha=2^-4 + 2^-6`, `Imax=6`
- `--bike-l1-batch --base-seed 1 --trials 8` reported `successes=8`, `failures=0`, first successful seed `1`, first successful iterations `2`
- `--bike-l1-calibrate --base-seed 1 --trials 4` ranked the fixed grid and selected `C=7`, `alpha=2^-4 + 2^-6`, `Imax=6` as the best tuple

These checks establish that the BIKE-L1 min-sum golden is deterministic, cross-validated internally, and does not change the existing RTL regression path.
