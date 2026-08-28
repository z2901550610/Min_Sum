---
name: rtl-spec
description: Define or refine fixed-schedule BIKE or TRIKE RTL behavior, interfaces, parameters, and acceptance criteria before architecture or implementation.
---

# RTL specification

Read `AGENTS.md`, the affected design status, and existing interfaces first.
Produce an implementation-ready contract covering ports, public parameters,
cycle boundaries, reset behavior, memory transactions, and observable failure
behavior. State which values may affect public fixed latency and explicitly
exclude private-data-dependent termination, scheduling depth, bank count, and
access count. Separate functional acceptance, fixed-cycle acceptance, formal
properties, and physical goals. Do not edit RTL unless the user also requests
implementation.
