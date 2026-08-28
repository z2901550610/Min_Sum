---
name: rtl-implement
description: Implement approved SystemVerilog RTL changes in this repository while preserving fixed schedule, filelists, tests, and documentation.
---

# RTL implementation

Follow `AGENTS.md`, `docs/vivado_systemverilog_guidelines.md`, and
`docs/design/naming_conventions.md`. Inspect the affected RTL, testbench, design
status, and validation matrix. Preserve constant-time scheduling and public-only
cycle budgets. Keep packages, wrappers, fixtures, formal assumptions, Vivado
defines, and canonical `filelists/*.f` synchronized. Use `make format-rtl` and
`make check-rtl`, then the minimum sufficient unit, integration, random, formal,
and Vivado layers. Report each evidence layer separately and preserve unrelated
working-tree changes.
