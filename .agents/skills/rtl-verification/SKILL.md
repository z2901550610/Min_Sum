---
name: rtl-verification
description: Add or run deterministic SystemVerilog and cocotb verification for BIKE or TRIKE RTL, including fixed-cycle and random regressions.
---

# RTL verification

Use `docs/verification/validation_matrix.md` to choose scope. Prefer existing
Make targets and deterministic seeds. Check data results, protocol behavior,
memory transaction counts, and exact start/done cycle boundaries independently.
For randomized failures, print parameter set, seed, trial, expected and actual
values, and preserve the runtime log. Exercise K=3/K=4 and all affected public
profiles when required. State trials, failures, stopping rule, and confidence
bound for DFR/FLS results. Simulation does not establish FPGA mapping or timing.
