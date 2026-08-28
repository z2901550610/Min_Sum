---
name: rtl-lint-debug
description: Diagnose SystemVerilog formatting, Verible, Slang, or Verilator lint and elaboration failures in this repository.
---

# RTL lint debugging

Reproduce through the canonical Make target after `source scripts/eda-env.sh`.
Read the quiet wrapper log under `build/logs/verilator/`; use
`VERILATOR_QUIET=0` only when the saved diagnostic is insufficient. Fix the RTL
or the narrowest justified waiver in `config/verilator_waivers.vlt`; never hide
behavioral or width bugs with broad suppression. Rerun the smallest failing gate
and then `make check-rtl`. Lint success is not simulation, synthesis, or timing
evidence.
