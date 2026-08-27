# Project Record and Baseline Workflow

## Information Boundaries

| Question | Primary Record |
| --- | --- |
| What exactly changed in the RTL | Git commit/diff |
| Why an architecture, RAM, cycle, resource, or timing experiment was done | `docs/experiments/index.md` plus any necessary `EXP-xxxx-*.md` |
| Exact conditions and numbers of one Vivado run | `reports/vivado/manifests/*.toml` |
| Which physical result is currently the baseline | `docs/design/vivado_baseline_registry.md` |
| Current production architecture and verification state | `docs/design/implementation_status.md` |
| How far TRIKE KEM optimization has progressed and what the next gate is | `docs/design/trike_kem_optimization_roadmap.md` |
| Raw Vivado `.rpt`/`.dcp` files | `D:/trike_reports/<run-id>/` |

Git records ordinary changes. Do not create experiment entries for formatting, spelling fixes, local bugfixes, or equivalent refactors. Add an experiment record only when it forms a verifiable hypothesis, avoids duplicate exploration, or changes a physical/cycle judgment.

## Experiment Flow

1. Assign the next `EXP-xxxx` in the index and state the hypothesis and comparison target in one sentence.
2. Commit a reproducible starting point; change only one main structural variable per experiment.
3. Record functional, fixed-cycle, K=3/K=4, and public parameter coverage; write `pending` explicitly for layers that were not run.
   For polynomial arithmetic and SM3 exploration iterations, prefer running the affected units, independent reference, fixed-cycle/access-count, and static checks; run the full KEM only when a candidate is ready to be retained, an interface boundary changed, or at a release/milestone.
4. Assign each Vivado run a unique `RUN-YYYYMMDD-NN-<top>`, keep raw reports in an external directory of the same name, and commit only the TOML manifest into the repository. The KEM implementation scripts also generate `run_provenance.txt` recording run ID, Git revision, dirty state, filelist, defines, XDC, device, and implementation directives.
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
4. Update `config/rtl_toolchain.lock` after the selected versions are installed.
5. Run `make check-tool-versions`, `make check-rtl`, `make formal-fast`, and the smallest relevant simulations before accepting the lock update. Run `make ci-fast` for the complete local gate.
6. A tool upgrade that changes formatting or diagnostics requires an audited mechanical update or a narrowly documented exception; do not restore global non-fatal warning flags.
7. Vivado versions are project baselines and are not upgraded as part of the open-source local tool refresh. Re-run comparable Vivado implementation before using a new Vivado version for resource or timing claims.
