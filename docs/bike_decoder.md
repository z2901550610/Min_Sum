# BIKE Syndrome-Input Min-Sum Decoder

## Overview

The RTL is now a BIKE-style syndrome decoder. The parity-check matrix is a
double-circulant matrix:

- `H = [H0 | H1]`
- `H0` and `H1` are represented by their first-column supports in
  `bike_pkg.H_BASE[h_sel][bank][edge]`
- `bank = 0` selects `H0`, and `bank = 1` selects `H1`

The top-level decoder no longer accepts a received hard-decision vector. It
accepts an initial syndrome and estimates an error vector:

- input: `i_syndrome[R-1:0]`
- output: `o_e[N-1:0]`
- success condition: `i_syndrome ^ H*o_e == 0`

## Parameters

`rtl/bike_pkg.sv` is the only RTL parameter package.

- Default build: a small BIKE-shaped demo (`R=8`, `W=3`) for fast RTL tests.
- `BIKE_L1_PARAMS` build: BIKE-L1-shaped parameters (`R=12323`, `W=71`,
  `N=24646`) with deterministic first-column supports.

Here `W` is the weight per circulant block, so BIKE-L1 total row weight is
`N0 * W = 142`.

## Decoder Semantics

The decoder starts from the all-zero error estimate.

- `C1 RAM` is initialized to zero.
- `RAM U` is initialized to `{sign=0, mag=C_VAL}` for every edge.
- The VNU prior is always `+C_VAL`.
- `CNU_A` accumulates only the incoming `u` signs in each row state.
- `CNU_B` computes each outgoing sign as:

```text
row_sign_xor ^ edge_u_sign ^ syndrome[row]
```

At the end of each iteration, the residual syndrome is recomputed from the
current error estimate. The decoder stops successfully when the residual is
zero, or fails after `I_MAX` iterations.

## Verification

Regular RTL regression uses the small BIKE demo parameters:

```sh
make test
```

The BIKE-L1 golden model uses the same syndrome-input min-sum equations on a
BIKE-L1-sized double-circulant matrix:

```sh
make bike-golden-self-test
make bike-golden-once BIKE_SEED=1
make bike-golden-batch BIKE_BASE_SEED=1 BIKE_TRIALS=8
```

This is a repository-defined min-sum decoder for BIKE-shaped inputs. It is not
the official BIKE bit-flipping decoder family.
