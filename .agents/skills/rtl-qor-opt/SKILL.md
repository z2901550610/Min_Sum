---
name: rtl-qor-opt
description: Measure and optimize RTL quality of results with reproducible baselines, bounded changes, and separate local-estimate versus Vivado evidence.
---

# RTL QoR optimization

Establish a reproducible baseline before editing. Record revision, dirty state,
top, sources/filelist, defines, parameters, tool version, target, constraints,
and report stage. Make one structural change at a time, preserve fixed-cycle and
functional/formal gates, and compare like-for-like metrics. `make qor` is a local
Yosys estimate for `kem_ct_compare_select`; it is not physical evidence. Require
comparable Vivado placed/routed reports before claiming FPGA resource or timing
improvement. Record attempted, failed, and withdrawn architecture experiments
as required by `AGENTS.md`.
