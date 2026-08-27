# Project Agent Instructions

## Project Scope

- SystemVerilog RTL for fixed-schedule BIKE/MDPC Min-Sum decoding and TRIKE KEM hardware.
- `rtl/` RTL, `tb/` testbenches, `formal/` formal harnesses, `scripts/` helper scripts, `software/` reference C, `constraints/` XDC.
- `filelists/` are the canonical ordered implementation source lists. `tb/generated/`, `build/`, `obj_dir/`, and Vivado run directories are rebuildable ignored products; use their Make/generator entrypoints and never treat their presence as clean-clone evidence.

## Hard Design Invariants

- Constant-time decoding and KEM post-processing are hard requirements.
- For one public parameter level, latency and memory access counts must be independent of the private key, support set, syndrome, error pattern, mismatch position, decoder success, and convergence behavior.
- Parameter levels may have different public fixed cycle budgets, memory geometries, parallelism settings, and timing targets.
- Do not introduce early termination, secret-dependent scheduling depth, secret-dependent bank counts, or data-dependent memory access counts.
- Evaluate architecture changes using fixed cycles together with achievable clock frequency and timing margin, then memory footprint and routing cost.

## Tool Roles and Evidence Boundaries

Each tool produces exactly one evidence layer. RTL simulation, formal proof, structural synthesis, and Vivado implementation are separate results; never use one layer as evidence for another. Physical claims require comparable Vivado reports.

| Tool | Role | Not evidence for |
|---|---|---|
| Verible | Formatting and style lint | Elaboration, behavior |
| Slang | Type check, lint, elaboration (`make lint-slang`) | Behavior |
| Verilator | Canonical local simulator (unit, integration, random, fixed-cycle, byte-for-byte) and fatal-warning `--lint-only -Wall`; exceptions scoped in `config/verilator_waivers.vlt` | FPGA mapping, timing |
| Yosys | Structural checks, formal frontend | Vivado XPM mapping, FPGA timing |
| SymbiYosys (+Z3 / ABC-PDR) | Scoped proofs in `formal/` | Anything beyond the chosen harness, assumptions, parameters |
| Icarus Verilog | Optional portability smoke tests | Signoff simulation |
| Vivado | Authority for synthesis, XPM/RAMB mapping, place, route, utilization, timing | — |

Expected on `PATH`: `verilator`, `verible-verilog-format`, `verible-verilog-lint`, `slang`, `yosys`, `sby`, `z3`. `config/rtl_toolchain.lock` pins validated versions; audit with `make check-local-tools` / `make check-tool-versions`, display with `make tool-versions`.

## Canonical Commands

- Daily: `make format-rtl`, `make check-rtl` (filelist + format + Verible + Verilator lint + Slang `-Werror`), `make test-unit`, `make test-integration`.
- Random regression: `make test-bike-random BIKE_RANDOM_PARAM_SET=<set> BIKE_RANDOM_BASE_SEED=<n> BIKE_RANDOM_TRIALS=<n>`; same variable pattern for `test-bike-unified-random` and `test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_K={3,4}`.
- Formal: `make formal` / `make formal-fast` (short matrix + cover witnesses), `make formal-nightly` (extended cases).
- Gates: `make ci-fast` (= `verify-rtl`: tool audit + static checks + short formal + unit + integration), `make ci-smoke` (seed-1 random profiles), `make ci-nightly` (extended formal + multi-seed). `make ci-kem-reference` is the opt-in byte-for-byte KAT gate requiring `config/local.mk`.
- Vivado: `make vivado-impl-trike-{poly-inv,pseudohash,encaps,keygen,decaps}`.
- Diagnostics: `make check-filelists`, `make check-records`, `make check-trike-sm3-sharing`.

## Change Workflow

1. Inspect `git status --short` and preserve unrelated or user-owned changes.
2. Read the affected RTL, its testbench, the relevant design status, and `docs/vivado_systemverilog_guidelines.md` before editing.
3. Keep package parameters, RTL, fixtures, wrappers, formal assumptions, and Vivado defines synchronized; update the matching `filelists/*.f` when an implementation source is added, removed, or reordered.
4. Run `make format-rtl` and `make check-rtl` after SystemVerilog edits.
5. Pick the minimum sufficient validation tier per `docs/verification/validation_matrix.md`: smallest relevant unit/reference test first, then integration or random profile tests in proportion to the affected scope.
6. Add or update a formal property when a small control, handshake, counter, address, selection, or constant-time invariant can be stated exhaustively; pair safety proofs with reachable `cover` witnesses. Do not attempt full-decoder formal equivalence without a bounded and reviewed abstraction.
7. For RAM, K-sign, scheduler, decoder-top, or shared package changes, validate both K=3 and K=4 paths where applicable and exercise every affected public parameter profile.
8. Run Vivado when the change can affect inference, hierarchy, utilization, routing, or timing; record the report stage and comparison conditions.
9. Before finishing architecture, parallelism, storage, resource, or timing work, append one row to `docs/experiments/index.md` (a concise `EXP-xxxx-*.md` only when the decision cannot fit in a row; include failed and withdrawn experiments). For every new Vivado run, store raw reports under the external run ID and commit one matching `reports/vivado/manifests/RUN-*.toml`; update the baseline registry only for retained comparable placed/routed results.

## Toolchain Updates

Full procedure lives in `docs/project_workflow.md`. Non-negotiable points: audit actual executables before upgrading, upgrade only the selected RTL tools, update `config/rtl_toolchain.lock` afterwards, and pass `make ci-fast` before accepting the lock. Vivado versions are project baselines and are never part of the local tool refresh.

## Validation and Reporting Rules

- Prefer Makefile targets over handwritten tool commands so defines, file ordering, and logging stay reproducible.
- Machine-specific reference/KAT paths belong in ignored `config/local.mk`; keep portable defaults and examples in tracked files.
- The default `VERILATOR` wrapper is `./scripts/verilator_quiet.py`. Compile logs are in `build/logs/verilator/`; runtime logs in `build/logs/run/`. Use `VERILATOR_QUIET=0 make ...` only to diagnose a failure. Formal outputs are in `build/formal/`; a counterexample is a failing trace to debug, not a hardware result.
- Report fixed-cycle measurements with the public parameter set, `L`, `K`, storage geometry, and the exact start/done boundary. Distinguish accepted-word counts from wall-clock time extended by input backpressure.
- Report DFR/FLS experiments with trials, failures, stopping rule, and confidence bound. Zero observed failures is finite-sample evidence.
- Resource and timing comparisons must use the same FPGA part and speed grade, Vivado version, XDC, clock constraint, parameter set, `L`, `K`, memory geometry, and report stage. Record LUT, FF, Slice, Block RAM Tile, RAMB36, RAMB18, DSP, setup WNS/TNS, and hold WHS when available; mark missing results as `pending`, never estimate.
- Internal clock closure does not establish board I/O timing signoff when input/output delays are absent.

## Key Files

- `config/rtl_toolchain.lock` - exact validated open-source RTL tool versions.
- `docs/vivado_systemverilog_guidelines.md` - Vivado/SystemVerilog, XDC, CDC, reset, inference, and verification rules.
- `docs/design/naming_conventions.md` - RTL naming rules.
- `docs/design/implementation_status.md` - implemented architecture and current fixed-cycle, resource, timing, and verification baseline.
- `docs/design/vivado_baseline_registry.md` - pointer for each accepted or pending physical implementation boundary.
- `docs/design/optimization_exploration_history.md` - frozen stages 1-81 archive; do not append new work.
- `docs/experiments/index.md` - compact append-only experiment ledger from `EXP-0082` onward.
- `docs/verification/validation_matrix.md` - minimum validation tier for each change class.
- `docs/project_workflow.md` - source-of-truth boundaries, experiment flow, and toolchain update procedure.
- `rtl/bike_pkg.sv` - shared parameter sets, widths, and memory geometry.

## Documentation Rules

- Follow `docs/vivado_systemverilog_guidelines.md` and `docs/design/naming_conventions.md` when generating, modifying, reviewing, or documenting RTL, testbenches, XDC, formal harnesses, and synthesis scripts.
- Except in dedicated exploration records, design documents and code comments describe only the current state, never comparisons with older versions (avoid phrasings such as "no longer", "now changed to", "now", "instead of", "rather than"). Design documents describe the production architecture, not a change log.
- Append new explorations to `docs/experiments/index.md` in actual implementation order; do not extend the frozen stages 1-81 history document. Ordinary code changes are recorded by Git and tests and do not create experiment entries. Keep each experiment within 40 lines by default: goal and hypothesis, hardware change boundary, validation layers, quantified results, and conclusion only - no RTL diffs, full logs, or raw Vivado reports.
- For retained solutions, update the related production design documents; when a new complete and comparable placed/routed baseline forms, update the Vivado baseline registry and `docs/design/implementation_status.md`.
- If the user provides a Vivado report, assign it a run ID and commit a TOML manifest. Mark it `incomparable` and do not compute deltas when device, constraints, parameters, tool version, or report stage differ.
- Place experimental plots and data summaries under `docs/figures/` or `reports/`, not in the repository root.
- Keep commit messages in the conventional-commit style (for example `feat(trike):`, `fix(vivado):`, `perf(build):`), consistent with the existing history.
- `AGENTS.md` and `CLAUDE.md` must remain word-for-word identical; update both files whenever shared rules change.
