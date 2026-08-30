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

## Compatibility and Defensive Programming

- This repository optimizes for one simple canonical current design and long-term maintainability, not implicit backward compatibility of project-internal code.
- Backward compatibility is opt-in. Preserve it only for an explicitly documented external RTL or software interface, golden/reference/KAT semantics, persisted artifact or manifest schema, canonical user/automation entrypoint, or when the user explicitly requires it.
- Project-owned RTL module interfaces, package APIs, parameters, wrappers, test helpers, formal harnesses, scripts, internal Make targets, filelists, and documentation may change directly. Update every repository caller and producer/consumer in the same change.
- Prefer one canonical interface and one implementation. Do not add aliases, compatibility wrappers, deprecated parameter names, dual implementations, or `*_old`, `*_new`, `*_v2`, `*_legacy`, or `*_compat` variants merely to avoid migrating repository callers.
- A replacement normally removes the superseded repository-owned implementation, tests, configuration, documentation, and entrypoints within the task scope. Resolve the exact callers first, preserve unrelated or user-owned working-tree changes, and do not remove designated experiment records, Vivado manifests, or other provenance as compatibility cleanup.
- Do not add speculative fallbacks, defaults, configuration knobs, abstraction layers, or extension points for hypothetical future consumers. New defensive behavior requires a concrete current requirement or demonstrated failure mode.
- Fail clearly when required tools, configuration, inputs, parameters, or invariants are missing. Do not silently select another implementation, simulator, synthesis path, parameter profile, or evidence layer; use `FAIL`, `NOT_RUN`, or `NOT_APPLICABLE` as appropriate.
- Tests protect the current intended contract, not obsolete internal behavior. When an intentional internal change invalidates an old test, update or remove that test instead of retaining obsolete production code solely to keep it passing. Golden/reference/KAT semantics remain protected unless an explicitly justified change updates the contract and evidence together.
- Active documentation describes only the canonical current design. Historical context belongs in Git, experiment records, Vivado manifests, or designated archives; do not present obsolete behavior as current compatibility guidance.
- If a compatibility layer is temporarily necessary, record the concrete consumer, why it cannot be migrated in the current change, and the removal condition. Do not add a compatibility layer without both a real consumer and an exit condition.
- Before completing a refactor, search the affected scope for obsolete wrappers, aliases, dead branches, duplicate Make targets, stale filelists, superseded tests or active documentation, and transitional configuration introduced or exposed by the change; remove them when no protected boundary requires them.

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

Run `uv sync --frozen` after checkout or a Python lock change. Expected on `PATH` after sourcing the environment: `verilator`, `verible-verilog-format`, `verible-verilog-lint`, `slang`, `yosys`, `sby`, and `z3`; project Python, cocotb, PyYAML, and pytest come from `.venv`. `config/rtl_toolchain.lock` and `uv.lock` pin the validated layers; audit with `make check-local-tools` / `make check-tool-versions`, display with `make tool-versions`.

Source `scripts/eda-env.sh` in each new terminal before running the canonical local workflow. Repository-scoped RTL workflow skills live under `.agents/skills/`.

## Mandatory Skill Routing

Before editing files or running validation for an RTL task, select and read the smallest applicable set of repository skills. Announce the selected skills and use them together when a request crosses stages.

| Task boundary | Required skill |
|---|---|
| Behavior, interface, parameters, cycle contract, or acceptance criteria | `rtl-spec` |
| Datapath, FSM, RAM lifecycle, scheduling, parallelism, or fixed-cycle budgeting | `rtl-architecture` |
| SystemVerilog implementation or refactoring | `rtl-implement` |
| Formatting, lint, type, or elaboration failure diagnosis | `rtl-lint-debug` |
| Testbench, reference comparison, fixed-cycle measurement, or random regression | `rtl-verification` |
| Control, counter, address, handshake, selection, or constant-time proof | `rtl-formal` |
| Synthesizability, hierarchy, inference, or structural resource inspection | `rtl-synthesis` |
| Resource, timing, latency, throughput, or architecture optimization | `rtl-qor-opt` |

For combined design work, use the stage order `rtl-spec` -> `rtl-architecture` -> `rtl-implement` -> `rtl-verification`/`rtl-formal` -> `rtl-synthesis`/`rtl-qor-opt`, omitting only stages that do not apply. A later-stage skill does not replace earlier acceptance criteria or evidence. Explanation, review, or diagnosis requests stop before implementation unless the user also requests a change.

## Canonical Commands

- The stable human/Agent interface is `make format FILES="<task-owned .sv files>"`, `make format-check`, `make lint`, `make compile`, `make test`, `make regress`, `make formal`, `make synth`, `make qor`, and `make check`. `make format-changed` and `make format-all` are explicit broader formatting operations. `make check` is the complete local gate and includes static checks, compile, fast simulation/formal, the independent workflow smoke test, and local synthesis.
- Workflow qualification: `make workflow-smoke`; deliberate negative checks: `make -C workflow-smoke check-failures`.
- Fine-grained targets such as `make check-rtl`, `make test-<name>`, `make formal-<name>`, and `make ci-*` are scoped implementation targets. Use them to reproduce a failure, run the smallest relevant validation, or select an explicit CI profile; do not substitute them for the stable entrypoints in the normal workflow.
- Deterministic random profiles remain available through `make test-bike-random BIKE_RANDOM_PARAM_SET=<set> BIKE_RANDOM_BASE_SEED=<n> BIKE_RANDOM_TRIALS=<n>` and the corresponding unified BIKE/TRIKE targets. The opt-in byte-for-byte KAT gate is `make ci-kem-reference` and requires `config/local.mk`.
- Vivado physical work uses direct Windows Tcl Console or `vivado -mode batch -source scripts/vivado_trike_kem_cores.tcl` as the primary interface. Set `VIVADO_REPORT_ROOT`, run ID, top, part, XDC, defines, and directives explicitly; `make vivado-impl-trike-*` remains an optional wrapper where GNU Make is available.
- Diagnostics: `make check-filelists`, `make check-records`, `make check-trike-sm3-sharing`.

## Change Workflow

1. Inspect `git status --short` and preserve unrelated or user-owned changes.
2. Classify the task with the skill-routing table, read every applicable `SKILL.md`, and state the validation boundary before editing.
3. Read the affected RTL, testbench, design status, `docs/vivado_systemverilog_guidelines.md`, and the relevant row of `docs/verification/validation_matrix.md`. Reproduce the current behavior with the smallest relevant target when a runnable baseline exists.
4. Keep package parameters, RTL, fixtures, wrappers, formal assumptions, Vivado defines, and canonical `filelists/*.f` synchronized.
5. After SystemVerilog edits, run `make format FILES="<files edited by this task>"` and the read-only `make lint`, then the smallest relevant deterministic simulation. Do not run repository-wide in-place formatting unless the user requests it. Escalate to `make test` for shared functional scope and `make regress` for shared modules, randomized behavior, or affected public parameter profiles.
6. Run `make formal` when a small control, handshake, counter, address, selection, or constant-time invariant applies; a scoped `make formal-<name>` target may be used first for fast iteration. Pair safety proofs with reachable `cover` witnesses and do not attempt full-decoder equivalence without a bounded reviewed abstraction.
7. Run `make synth` for synthesizability, hierarchy, inference, or structural changes, and `make qor` only for its documented local-estimate scope. For RAM, K-sign, scheduler, decoder-top, or shared package changes, validate both K=3 and K=4 where applicable and every affected public parameter profile.
8. Run `make check` before declaring an RTL workflow change complete. If a required gate is unavailable or disproportionate to the requested scope, report it as `NOT_RUN` with the exact reason and list the narrower gates that passed; never silently replace a required evidence layer.
9. Git plus tests record ordinary RTL changes, bug fixes, and equivalent refactors. Create one experiment entry for one explicit, comparable architecture/QoR hypothesis or experiment series, including failed and withdrawn conclusions; do not create an EXP row per edit or commit. Every new Vivado run gets one `RUN-*.toml` manifest and raw reports under the configured external run root. Only retained, comparable placed/routed results update the baseline registry.

## Toolchain Updates

Full procedure lives in `docs/project_workflow.md`. Non-negotiable points: audit actual executables before upgrading, upgrade only the selected RTL tools, update `config/rtl_toolchain.lock` afterwards, and pass `make check` before accepting the lock. Vivado versions are project baselines and are never part of the local tool refresh.

## Validation and Reporting Rules

- Use the stable Makefile entrypoints for normal work so defines, file ordering, and logging stay reproducible. Invoke a lower-level tool directly only to debug the workflow itself, and rerun the owning Make target afterwards.
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
- `docs/experiments/index.md` - compact decision index grouped by comparable hypothesis or experiment series; per-ID detail files preserve older evidence.
- `docs/verification/validation_matrix.md` - minimum validation tier for each change class.
- `docs/project_workflow.md` - source-of-truth boundaries, experiment flow, and toolchain update procedure.
- `rtl/bike_pkg.sv` - shared parameter sets, widths, and memory geometry.

## Documentation Rules

- Follow `docs/vivado_systemverilog_guidelines.md` and `docs/design/naming_conventions.md` when generating, modifying, reviewing, or documenting RTL, testbenches, XDC, formal harnesses, and synthesis scripts.
- Except in dedicated exploration records, design documents and code comments describe only the current state, never comparisons with older versions (avoid phrasings such as "no longer", "now changed to", "now", "instead of", "rather than"). Design documents describe the production architecture, not a change log.
- Assign a new EXP ID only for a new comparable hypothesis or experiment series; intermediate edits, parameter sweep points, and repeated validation stay under that ID. Keep `docs/experiments/index.md` grouped by series and preserve older per-ID detail files and manifests as traceable evidence. Do not extend the frozen stages 1-81 history document. Ordinary code changes are recorded by Git and tests and do not create experiment entries. Keep any new detail record within 40 lines by default: goal and hypothesis, hardware change boundary, validation layers, quantified results, and conclusion only - no RTL diffs, full logs, or raw Vivado reports.
- For retained solutions, update the related production design documents; when a new complete and comparable placed/routed baseline forms, update the Vivado baseline registry and `docs/design/implementation_status.md`.
- If the user provides a Vivado report, assign it a run ID and commit a TOML manifest. Mark it `incomparable` and do not compute deltas when device, constraints, parameters, tool version, or report stage differ.
- Place experimental plots and data summaries under `docs/figures/` or `reports/`, not in the repository root.
- Keep commit messages in the conventional-commit style (for example `feat(trike):`, `fix(vivado):`, `perf(build):`), consistent with the existing history.
- `AGENTS.md` and `CLAUDE.md` must remain word-for-word identical; update both files whenever shared rules change.
