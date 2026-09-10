---
name: rtl-verification
description: Add or run deterministic SystemVerilog and cocotb verification for BIKE or TRIKE RTL, including fixed-cycle and random regressions.
---

# RTL verification

Choose the testbench form from the verification boundary. Prefer a direct,
self-checking SystemVerilog testbench for cycle-accurate protocols, handshakes,
RAM transactions, fixed latency, and small RTL units. Use Python for golden
models, large fixtures, deterministic random generation, and cryptographic
byte/word reference data. Use cocotb as a Python driver only when dynamic data
or orchestration is materially clearer than an SV driver; cocotb drives the RTL
simulator and does not generate SystemVerilog. A hybrid SV harness plus generated
Python fixture is often the best fit. Do not introduce cocotb for a test whose
essential checks are simpler and more explicit in self-checking SV.

Consult docs/workflow.md only when scope is unclear. Start with the
smallest existing deterministic `make test-<name>` target, use `make test` for
the aggregate fast suite, and use `make regress` for the fixed-seed random gate.
Check data results, protocol behavior, memory transaction counts, and exact
start/done cycle boundaries independently. For randomized failures, print
parameter set, seed, trial, expected and actual values, and preserve the runtime
log. Follow AGENTS.md representative-profile scope: retain cheap boundary cases,
add middle profiles only for their changed branch/table or an explicit request.
Exercise affected K=3/K=4 behavior when required. State
trials, failures, stopping rule, and confidence bound for DFR/FLS results.
Simulation does not establish FPGA mapping or timing.
