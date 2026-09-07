---
name: rtl-lint-debug
description: Diagnose SystemVerilog formatting, Verible, Slang, or Verilator lint and elaboration failures in this repository.
---

# RTL lint debugging

After `source scripts/eda-env.sh`, start with the known failing target and its
saved diagnostic; use `make lint` when the failing layer is unknown. Use the
smallest owning Make target for iteration and read the quiet wrapper log under
`build/logs/verilator/`; use
`VERILATOR_QUIET=0` only when the saved diagnostic is insufficient. Fix the RTL
or the narrowest justified waiver in `config/verilator_waivers.vlt`; never hide
behavioral or width bugs with broad suppression. Rerun the smallest failing
target, then complete the gates selected by `make check-plan` and applicable
escalation rules. Apply `AGENTS.md` gate reuse and blocked-validation rules.
Lint success is not simulation, synthesis, or timing evidence.
