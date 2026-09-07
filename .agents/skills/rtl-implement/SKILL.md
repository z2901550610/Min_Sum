---
name: rtl-implement
description: Implement SystemVerilog RTL changes authorized by the current task while preserving fixed schedule, filelists, tests, and documentation.
---

# RTL implementation

Follow `AGENTS.md`, `docs/vivado_systemverilog_guidelines.md`, and
`docs/design/naming_conventions.md`. Inspect the affected RTL, testbench, design
status, and validation matrix. Preserve constant-time scheduling and public-only
cycle budgets. Keep packages, wrappers, fixtures, formal assumptions, Vivado
defines, and canonical `filelists/*.f` synchronized. Apply the authorization and
clarification rules in `AGENTS.md`. After editing, run
`make format FILES="<files edited by this task>"` and the gates selected by
`make check-plan` and applicable escalation rules. Use `rtl-verification`,
`rtl-formal`, `rtl-synthesis`, or `rtl-qor-opt` for required evidence stages
without duplicating their procedures or unchanged passing gates. Follow the
completion rules in `AGENTS.md` for running gates and unavailable prerequisites;
never represent incomplete required validation as overall completion. Preserve
unrelated working-tree changes.
