# Project Record and Baseline Workflow

## Information Boundaries

| Question | Primary Record |
| --- | --- |
| What exactly changed in the RTL | Git commit/diff |
| Why an architecture, RAM, cycle, resource, or timing experiment was done | `docs/experiments/index.md` series summary plus any necessary `EXP-xxxx-*.md` |
| Exact conditions and numbers of one Vivado run | `reports/vivado/manifests/*.toml` |
| Which physical result is currently the baseline | `docs/design/vivado_baseline_registry.md` |
| Current production architecture and verification state | `docs/design/implementation_status.md` |
| How far TRIKE KEM optimization has progressed and what the next gate is | `docs/design/trike_kem_optimization_roadmap.md` |
| Raw Vivado `.rpt`/`.dcp` files | `${VIVADO_REPORT_ROOT}/<run-id>/` |

Git records ordinary changes. Do not create experiment entries for formatting, spelling fixes, local bugfixes, or equivalent refactors. Add an experiment record only when it forms a verifiable hypothesis, avoids duplicate exploration, or changes a physical/cycle judgment.

The record hierarchy is `Git + tests` for ordinary changes, one `EXP` entry per explicit comparable hypothesis or experiment series, one `RUN` manifest per Vivado execution, and a baseline-registry update only for a retained comparable placed/routed result. Multiple implementation iterations under one hypothesis do not create one EXP entry each.

## Experiment Flow

1. Assign the next `EXP-xxxx` only for a new comparable hypothesis or experiment series, then state its hypothesis and comparison target in one sentence. Intermediate edits and parameter sweep points stay under that ID.
2. Commit a reproducible starting point; change only one main structural variable per experiment.
3. Record functional, fixed-cycle, K=3/K=4, and public parameter coverage; write `pending` explicitly for layers that were not run.
   For polynomial arithmetic and SM3 exploration iterations, prefer running the affected units, independent reference, fixed-cycle/access-count, and static checks; run the full KEM only when a candidate is ready to be retained, an interface boundary changed, or at a release/milestone.
4. Assign each Vivado run a unique `RUN-YYYYMMDD-NN-<top>`, keep raw reports under `${VIVADO_REPORT_ROOT}/<run-id>/`, and commit only the TOML manifest into the repository. Configure the root through the Windows Tcl environment or local ignored configuration; historical manifests retain the actual path used by their run. The KEM implementation scripts also generate `run_provenance.txt` recording run ID, Git revision, dirty state, filelist, defines, XDC, device, and implementation directives.
5. Mark runs with identical device, Vivado version, XDC, parameters, `L/K`, storage geometry, clock, and report stage as `comparable`; otherwise list them separately.
6. Conclusions use only `retained`, `rejected`, `pending`, `incomparable`, or `superseded`.
7. Only `retained`, complete placed/routed runs may update the baseline registry; update `implementation_status.md` when they form the current architecture.

## Generated Products

- Rebuildable simulation data, Verilator products, waveforms, logs, and Vivado run directories do not enter Git.
- For fixtures that must rely on external KATs, the Make targets and `config/local.mk.example` together record the rebuild entrypoints.
- Reports, presentations, and temporary exports use explicit delivery directories separate from `build/`, and do not rely on unstated `output`/`outputs` naming differences.

## Toolchain Update Workflow

1. Audit actual executables and installation sources before upgrading; do not infer freshness from a tool name alone.
2. Compare stable package-manager metadata and official upstream tags. Keep a newer validated development snapshot when replacing it with a stable tag would be a downgrade.
3. Upgrade only the selected RTL tools, not the whole host package set. Keep recoverable versioned installs for manually managed binaries.
4. Update `config/rtl_toolchain.lock` after selected EDA versions are installed. Update `pyproject.toml` and regenerate `uv.lock` only when project Python dependencies intentionally change.
5. Run `make lint`, `make formal`, and the smallest relevant simulations while iterating on the lock update. Run `make check` as the complete local gate before accepting it; use lower-level targets only to isolate a failure.
6. A tool upgrade that changes formatting or diagnostics requires an audited mechanical update or a narrowly documented exception; do not restore global non-fatal warning flags.
7. Vivado versions are project baselines and are not upgraded as part of the open-source local tool refresh. Re-run comparable Vivado implementation before using a new Vivado version for resource or timing claims.

## Local Workflow Entry

Source `scripts/eda-env.sh` before running local RTL gates. The canonical
aggregate commands and their evidence boundaries are defined in
`docs/workflow.md`; exact tool versions remain in
`config/rtl_toolchain.lock`. Repository-specific Codex skills live under
`.agents/skills/` and refine stages without replacing this record policy or
`AGENTS.md`. `config/test_catalog.toml` defines test commands, groups and test owners once for Make and the planner. `config/validation_profiles.toml` defines profile targets, policy routing, non-test owners, coverage, release escalation and the generated validation-matrix table. It stores Make target names rather than
shell commands. Owners are optional accelerators for precise local validation;
overlapping owners are rejected, while unowned sources conservatively fall back
to their profile aggregate. One planned Make dependency graph deduplicates shared prerequisites. Use
`make check-plan VALIDATION_PATHS="<task-owned paths>"` in a dirty tree, or
`make check-plan` when the complete diff belongs to the task, when selecting checks is unclear or scope changes; after a profile edit, run `make update-validation-matrix`, while
`make check-validation-profiles` rejects drift. Standalone SymbiYosys logs remain
under `build/logs/sby/`, with the latest per-task result in
`build/results/check-summary.json`; workflow validation places these artifacts
under its run directory. A per-task summary is not an aggregate gate verdict. Core
workflow changes use `make validate-workflow` for unit/tool smoke only; toolchain baseline acceptance separately uses `make check`. Product release scope uses
the applicable `make check`, random/reference, and Vivado gates;
supporting tests and functional generators use their owning targets first; Skills and ordinary documentation use diff/link review only; experiment and physical records use `check-records`. Unrouted research scripts/data need no registration and are listed for task-appropriate review. Its run-scoped events, aggregate
summary and full terminal log remain under
`build/results/runs/<run-id>/` without updating tracked QoR records.
