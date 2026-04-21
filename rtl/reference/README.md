# Reference RTL Helpers

This directory holds SystemVerilog helpers that are useful for understanding
or comparing QC metadata handling, but are not part of the decoder core.

- `decoder_edge_meta.sv` derives the row, lane, and local-row metadata for one
  active `(variable column, edge slot)` pair directly from `H_BASE`.
- `qc_column_preprocess.sv` expands a variable column into lane-packed
  nonzero-entry lists.

The synthesized/core decoder path now gets active edge metadata from RAM-I and
advances it with `h_shift`. Keep these modules out of `Makefile` `RTL_CORE`
and out of generated random-test RTL source lists unless a dedicated reference
test needs them.
