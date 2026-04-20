# BIKE Syndrome-Input Min-Sum Decoder

## Overview

The RTL is now a BIKE-style syndrome decoder. The parity-check matrix is a
double-circulant matrix:

- `H = [H0 | H1]`
- `H0` and `H1` are represented by their first-column supports in
  `bike_pkg.H_BASE[h_sel][bank][edge]`
- `bank = 0` selects `H0`, and `bank = 1` selects `H1`

The top-level decoder no longer accepts a received hard-decision vector. It
accepts an initial syndrome, seeds each circulant bank from a static first-
column description, and estimates an error vector:

- input: `i_syndrome[R-1:0]`
- output: `o_e[N-1:0]`
- success condition: `i_syndrome ^ H*o_e == 0`

## Parameters

`rtl/bike_pkg.sv` is the parameter package for the decoder core.

- Default build: a small BIKE-shaped demo (`R=8`, `W=3`) for fast RTL tests.
- `BIKE_L1_PARAMS` build: BIKE-L1-shaped parameters (`R=12323`, `W=71`,
  `N=24646`) with deterministic first-column supports.

Here `W` is the weight per circulant block, so BIKE-L1 total row weight is
`N0 * W = 142`.

## Decoder Semantics

The decoder starts from the all-zero error estimate.

- `ram_c` stores the running error estimate / hard decision bits.
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

## Module Split

- `decoder_ctrl` owns the decode-state machine, variable scheduling, RAM-M
  ping-pong banks, and edge-buffer selectors.
- `decoder_top` is the decoder core datapath. It seeds `ram_i` from static
  first-column metadata, then advances each bank with internal `h_shift`
  logic (`+1 mod R` plus cross-lane regrouping). The runtime datapath no
  longer depends on externally expanded per-column metadata, and `vnu`
  no longer performs message-format conversion internally.
- `vnu` now consumes c2v in 2's-complement and emits unsaturated 2's-complement
  v2c. Sign-magnitude conversion lives in the external `msg_codec` adapters.
- `ram_i` is a pure RAM for stored QC-column entries, and `h_shift` is a pure
  `+1 mod R` shifter for those entries.
- The static first-column metadata is generated offline by
  [`scripts/gen_qc_first_columns.py`](/Users/z2901550610/Documents/Min_Sum/scripts/gen_qc_first_columns.py)
  into
  [`rtl/generated/qc_first_columns.svh`](/Users/z2901550610/Documents/Min_Sum/rtl/generated/qc_first_columns.svh).
  `decoder_top` consumes only the generated tables; it no longer derives lane
  grouping from `H_BASE` internally.

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
