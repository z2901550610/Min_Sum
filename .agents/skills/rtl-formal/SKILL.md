---
name: rtl-formal
description: Add or debug scoped SymbiYosys proofs and cover witnesses for RTL control, counters, addresses, handshakes, selection, and constant-time properties.
---

# RTL formal

Define the exact harness boundary, assumptions, parameters, safety property, and
reachable cover witness. Use repository `formal/` conventions and canonical Make
targets. Keep assumptions no stronger than the real interface contract and pair
safety checks with cover reachability. Treat a counterexample as a trace to
debug, not hardware evidence. Do not claim properties beyond the selected
harness or attempt whole-decoder equivalence without a bounded reviewed
abstraction.
