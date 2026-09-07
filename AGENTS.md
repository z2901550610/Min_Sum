# Project Agent Instructions

## Scope and Hard Invariants

- This repository contains fixed-schedule BIKE/MDPC Min-Sum decoder and TRIKE KEM SystemVerilog. Production RTL is under `rtl/`; canonical ordered sources are `filelists/*.f`; tests, proofs, reference software, and constraints are under `tb/`, `formal/`, `software/`, and `constraints/`.
- This is a graduate research repository, not a production qualification program. Keep validation proportional to the changed research claim while preserving constant-time behavior, reproducibility, and explicit evidence boundaries.
- Constant-time decoding and KEM post-processing are mandatory. Within one public parameter level, latency and memory-access counts must not depend on a private key, support set, syndrome, error pattern, mismatch position, decoder success, or convergence behavior.
- Public parameter levels may use different fixed schedules, geometries, parallelism, and timing targets. Evaluate changes by fixed cycles and achievable clock/timing margin first, then memory and routing cost. Never add early exit, secret-dependent depth, bank count, or access count.
- Generated directories such as `tb/generated/`, `build/`, `obj_dir/`, and Vivado run directories are not clean-clone evidence; use their checked-in generators and entrypoints.

## Change Authority and Canonical Design

- Prefer the simplest single long-term design over patch-on-patch fixes. Internal modules, package APIs, parameters, wrappers, harnesses, scripts, Make targets, filelists, and active documentation may change when every repository caller and producer/consumer is migrated in the same change.
- Preserve compatibility only for a documented external RTL/software interface, golden/reference/KAT semantics, persisted artifact or manifest schema, canonical user/automation entrypoint, or an explicit user requirement. A temporary compatibility layer needs a real consumer, a current migration blocker, and a removal condition.
- Do not add speculative aliases, fallbacks, defaults, configuration knobs, extension layers, or `*_old`, `*_new`, `*_v2`, `*_legacy`, or `*_compat` variants. Remove superseded project-owned code, tests, configuration, and documentation within scope, while preserving experiment records and provenance.
- Fail clearly when a required tool, input, configuration, parameter, or evidence layer is missing. Use `FAIL`, `NOT_RUN`, or `NOT_APPLICABLE`; never silently switch simulator, synthesis path, parameter profile, or evidence type.
- Preserve unrelated or user-owned working-tree changes. Review, explanation, diagnosis, and planning requests do not authorize implementation. Existing change authorization remains valid throughout the task and covers necessary specification, architecture choices, implementation, caller migration, and non-destructive validation within scope; do not request approval again at each skill or stage. Preserve explicit user approval checkpoints and tool permission requirements.
- Resolve uncertainties from current code, tests, documentation, and prior user decisions first. Make routine, reversible choices within the authorized scope and existing contracts, stating material assumptions. Ask for clarification when the answer would materially change scope, external interfaces, cryptographic semantics, fixed-cycle contracts, or acceptance goals. Continue independent authorized work while waiting; elapsed time is not approval.

## Evidence Boundaries

Simulation, formal proof, structural synthesis, and Vivado implementation are separate evidence layers.

| Tool | Role | Does not establish |
|---|---|---|
| Verible | Formatting and style | Elaboration or behavior |
| Slang | Type, lint, elaboration | Behavior |
| Verilator | Canonical local simulation and fatal-warning lint | FPGA mapping or timing |
| Yosys | Structural checks and local estimates | Vivado XPM/RAMB mapping or FPGA timing |
| SymbiYosys with Z3 | Properties inside the selected harness and assumptions | Behavior outside that boundary |
| Vivado | FPGA synthesis, placement, routing, utilization, and timing | Board I/O signoff without I/O constraints |

- Same-condition Vivado is a required acceptance gate for tasks that include FPGA mapping, resource or timing acceptance, or physical baseline updates. Tasks limited to functional fixes use their required functional gates and report unverified physical effects without claiming physical benefits or updating physical baselines.
- Physical comparisons require the same part/speed grade, Vivado version, XDC, clock, public parameters, `L`, `K`, memory geometry, defines, directives, and report stage. Record LUT, FF, Slice, Block RAM Tile, RAMB36, RAMB18, DSP, setup WNS/TNS, and hold WHS when available; missing results are `pending`, not estimates.
- Fixed-cycle reports include the public profile, `L`, `K`, storage geometry, and exact start/done boundary. DFR/FLS reports include trials, failures, stopping rule, and confidence bound; zero failures remain finite-sample evidence.

## Mandatory RTL Skill Routing

Before editing files or running validation for an RTL task, read and announce the smallest applicable repository skills.

| Task boundary | Required skill |
|---|---|
| Behavior, interface, parameters, cycle contract, acceptance criteria | `rtl-spec` |
| Datapath, FSM, RAM lifecycle, scheduling, parallelism, cycle budget | `rtl-architecture` |
| SystemVerilog implementation or refactoring | `rtl-implement` |
| Formatting, lint, type, or elaboration diagnosis | `rtl-lint-debug` |
| Testbench, reference comparison, fixed-cycle or random regression | `rtl-verification` |
| Control, counter, address, handshake, selection, constant-time proof | `rtl-formal` |
| Synthesizability, hierarchy, inference, structural resources | `rtl-synthesis` |
| Resource, timing, latency, throughput, architecture optimization | `rtl-qor-opt` |

For combined work, use `rtl-spec` -> `rtl-architecture` -> `rtl-implement` -> `rtl-verification`/`rtl-formal` -> `rtl-synthesis`/`rtl-qor-opt`, omitting stages that do not apply. A later skill does not replace earlier acceptance criteria. Review or diagnosis stops before implementation unless the user requests a change.

## Canonical Workflow

- After checkout or a Python lock change, run `uv sync --frozen`. Source `scripts/eda-env.sh` in each local terminal. `config/rtl_toolchain.lock` and `uv.lock` define validated versions; missing or mismatched tools fail rather than fall back.
- `config/validation_profiles.toml` is the single source for path routing, non-overlapping owning targets, profile coverage, release escalation, and the generated table in `docs/verification/validation_matrix.md`. Run `make check-plan VALIDATION_PATHS="<task-owned paths>"` in a dirty tree, or `make check-plan` when the complete diff is in scope; it plans but never marks a gate passed. Use an owning target when one is registered; otherwise use the conservative aggregate fallback. Skills explain how to execute a gate; the plan and applicable escalation rules decide final gates. Do not rerun an already-passed gate in the current task solely because another skill requests it, provided relevant inputs and conditions are unchanged; rerun when they change or new evidence raises a concern.
- Stable entrypoints are documented in `docs/workflow.md`. Use `make format FILES="<task-owned .sv files>"` for scoped formatting; `make lint`, `make compile`, `make test`, `make regress`, `make formal`, `make synth`, `make qor`, and `make check` are canonical aggregates. `make check` is the complete local RTL gate. `make validate-workflow` separately qualifies the workflow itself with unit tests, positive/negative smoke, and a same-run QoR report.
- Direct test and proof targets remain available for reproduction and task completion. Run the complete `make check` for shared production RTL, core toolchain changes, release/CI qualification, or an explicit validation-matrix requirement. Use `make validate-workflow` when the workflow/toolchain implementation changes.
- Vivado physical work uses the direct Windows Tcl Console or `vivado -mode batch -source ...` with explicit report root, run ID, top, part, XDC, defines, and directives. Make wrappers are optional conveniences, not a separate evidence path.

## Completion Workflow

1. Inspect `git status --short`, affected sources, callers, tests, current design status, `docs/vivado_systemverilog_guidelines.md`, naming rules, and the validation matrix. Reproduce current behavior with the smallest owner when practical.
2. Keep packages, RTL, fixtures, wrappers, formal assumptions, Vivado defines, and filelists synchronized. Resolve all repository callers before replacing an internal interface.
3. After SystemVerilog edits, format only task-owned files, run read-only static checks, and execute the commands selected by `make check-plan`. Use the applicable skills for deterministic simulation, proof/cover, synthesis, QoR, public-profile, and K=3/K=4 escalation.
4. Run `make check-plan` again before completion. Execute its task commands; execute separately listed release/shared-scope commands only when that boundary applies. Follow running required gates to a terminal result. If an external prerequisite is unavailable, complete independent authorized work and report completed artifacts, outstanding acceptance gates, the blocker, and exact resumption steps. Mark unavailable required gates `NOT_RUN` with the reason and non-required gates `NOT_APPLICABLE`; neither a missing gate nor an interim delivery establishes overall completion. Resume already-authorized work when the prerequisite returns without requiring a new task request.
5. Before completing a refactor, search the affected scope for obsolete aliases, wrappers, dead branches, duplicate targets, stale filelists, superseded tests/docs, and transitional configuration. Tests protect the current intended contract, while golden/reference/KAT semantics remain protected boundaries.

## Documentation and Provenance

- Active design documents and code comments describe the production state, not a change log. Historical comparisons belong in Git, experiment records, Vivado manifests, or designated archives.
- Ordinary fixes and equivalent refactors are recorded by Git and tests. Create one EXP entry for one comparable architecture/QoR hypothesis or series, not per edit. Keep detail records concise and do not extend the frozen stages 1-81 history.
- Every Vivado execution gets one `RUN-*.toml` manifest and external raw reports. Only retained, complete, comparable placed/routed results may update `docs/design/vivado_baseline_registry.md` and `docs/design/implementation_status.md`.
- Machine-specific reference/KAT paths belong in ignored `config/local.mk`. Experimental plots and data belong under `docs/figures/` or `reports/`, not the repository root.
- Use conventional commit subjects such as `feat(trike):`, `fix(vivado):`, or `perf(build):`. `AGENTS.md` and `CLAUDE.md` must remain byte-identical.
