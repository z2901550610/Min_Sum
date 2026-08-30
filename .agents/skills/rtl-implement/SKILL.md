---
name: rtl-implement
description: Implement approved SystemVerilog RTL changes in this repository while preserving fixed schedule, filelists, tests, and documentation.
---

# RTL implementation

Follow `AGENTS.md`, `docs/vivado_systemverilog_guidelines.md`, and
`docs/design/naming_conventions.md`. Inspect the affected RTL, testbench, design
status, and validation matrix. Preserve constant-time scheduling and public-only
cycle budgets. Keep packages, wrappers, fixtures, formal assumptions, Vivado
defines, and canonical `filelists/*.f` synchronized. After editing, run
`make format FILES="<files edited by this task>"`, `make lint`, and the smallest
relevant deterministic smoke test. `AGENTS.md` and the validation matrix decide
whether `rtl-verification`, `rtl-formal`, `rtl-synthesis`, or `rtl-qor-opt` must
own later evidence stages; do not duplicate their procedures here or declare
completion before their required gates finish. Preserve unrelated working-tree
changes.
