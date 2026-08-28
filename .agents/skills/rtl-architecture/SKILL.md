---
name: rtl-architecture
description: Design BIKE or TRIKE RTL microarchitecture, RAM lifecycle, scheduling, and fixed-cycle budgets before coding.
---

# RTL architecture

Start from the approved behavioral contract and current production design docs.
Describe the module-tied datapath, control/address/data roles, RAM bank geometry
and lifecycle, handshake boundaries, and a symbolic fixed-cycle equation.
Evaluate public parameter profiles separately. Compare options by fixed cycles,
achievable clock/timing margin, memory footprint, and routing cost. Treat Yosys
counts as estimates and require comparable Vivado placed/routed reports for
physical conclusions. Record an architecture experiment when required by
`AGENTS.md`; do not implement unless requested.
