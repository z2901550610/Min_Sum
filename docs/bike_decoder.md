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
- `CNU_A` accumulates only the incoming `u` signs in each compressed c2v state.
- `CNU_B` computes each outgoing sign as:

```text
row_sign_xor ^ edge_u_sign ^ syndrome[row]
```

At the end of each iteration, the residual syndrome is recomputed from the
contents of `RAM C1`, which is the single source of truth for the exported
error estimate `o_e`. The decoder stops successfully when the residual is
zero, or fails after `I_MAX` iterations.

## Module Split

- `decoder_ctrl` owns the decode controller, c2v/v2c column contexts,
  RAM-M ping-pong banks, RAM-I seed control, column-buffer handoff events, and
  done/success bookkeeping. The implementation uses a small set of macro
  states plus counters/valid-style activity flags rather than encoding the
  whole schedule as a long phase-only FSM.
- `decoder_top` is the decoder core datapath and structural interconnect. It
  instantiates the numbered RAM blocks, `decoder_ctrl`, `h_shift`, CNU/VNU
  units, and message-codec adapters; top-level logic is limited to RAM port
  selection, RAM-I row-group entry handling, data latching, and residual-syndrome
  recomputation.
- `vnu` now consumes c2v in 2's-complement and generates unsaturated 2's-complement
  v2c. Sign-magnitude conversion happens at the VNU input/output boundaries in
  the external `msg_codec` adapters; RAM-T and the VNU scaling datapath stay in
  2's-complement.
- `ram_i`, `ram_m`, `ram_s`, `ram_t`, `ram_u`, and `ram_c` are paper-style
  single-port RAM primitives with synchronous read data.  One RTL file
  represents one numbered RAM block rather than a multi-bank wrapper with
  several read/write ports.
- `decoder_top` instantiates the RAM blocks explicitly by paper-style names:
  `I0/I1`, `M0/M1/M2/M3`, `S0/S1`, `T0/T1`, `U0/U1`, and `C0/C1`.  The top
  does not use `generate`/`genvar` for RAM instantiation.
- `decoder_ctrl` follows the paper's Fig.8-style single-port schedule: each
  iteration clears the next RAM-M pair, primes column 0 into RAM-T, then runs
  a column-overlap pipeline where the c2v side computes column `j+1` while the
  v2c side accumulates and updates column `j`, and finally drains the last v2c
  column before `ITER_CHECK`. The exported
  `phase` signal is now debug-only; datapath sequencing uses explicit control
  pulses and column-buffer handoff events.
- RAM-I is seeded with first-column row-group lists. During decode, the active
  column's row/local-row/edge-index metadata comes from the RAM-I row-group
  lists; after the c2v side finishes a column, `h_shift` advances those packed
  lists by `+1 mod R` and writes them back for the next c2v column. v2c
  metadata is buffered separately so the c2v side can keep RAM-I one column
  ahead. `decoder_top` now consumes RAM-I through formal functional column-view
  outputs instead of using RAM debug arrays in the functional path. Project-wide
  RTL naming for indexes, rows, entries, lists, and counts is defined in
  [`docs/naming_conventions.md`](/Users/z2901550610/Documents/Min_Sum/docs/naming_conventions.md).
  `H_BASE` is not used for normal CNU/VNU row-address scheduling.
- `decoder_edge_meta` and `qc_column_preprocess` are kept under
  [`rtl/reference/`](/Users/z2901550610/Documents/Min_Sum/rtl/reference) as
  reference helpers. They are no longer part of the decoder core because RAM-I
  plus `h_shift` now supplies the active edge metadata.
- The static first-column metadata is generated offline by
  [`scripts/gen_qc_first_columns.py`](/Users/z2901550610/Documents/Min_Sum/scripts/gen_qc_first_columns.py)
  into
  [`rtl/generated/qc_first_columns.svh`](/Users/z2901550610/Documents/Min_Sum/rtl/generated/qc_first_columns.svh).
  `decoder_top` consumes only the generated tables; it no longer derives row-group
  grouping from `H_BASE` internally.
- The current RTL keeps the practical whole-column RAM-I writeback/cache
  scheme; it does not implement strict edge-by-edge RAM-I timing from the
  paper.
- Two-stage scaling, flexible message storage selection, the paper's wide-word
  `RAM S` packing/shift-register scheme, and group-size re-balancing are not
  implemented yet. The RTL keeps the existing single-stage VNU scaling.

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
