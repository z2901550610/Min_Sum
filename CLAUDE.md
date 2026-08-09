# Project Agent Instructions

## Project Scope

- SystemVerilog RTL for fixed-schedule BIKE/MDPC Min-Sum decoding and TRIKE KEM hardware.
- RTL is in `rtl/`; testbenches are in `tb/`; formal harnesses are in `formal/`; helper scripts are in `scripts/`.
- Canonical implementation source lists are in `filelists/`; generated simulation fixtures are in `tb/generated/`; generated logs and build products belong under `build/`.

## Hard Design Invariants

- Constant-time decoding and KEM post-processing are hard requirements.
- For one public parameter level, latency and memory access counts must be independent of the private key, support set, syndrome, error pattern, mismatch position, decoder success, and convergence behavior.
- Parameter levels may have different public fixed cycle budgets, memory geometries, parallelism settings, and timing targets.
- Do not introduce early termination, secret-dependent scheduling depth, secret-dependent bank counts, or data-dependent memory access counts.
- Evaluate architecture changes using fixed cycles together with achievable clock frequency and timing margin, then memory footprint and routing cost.

## Tool Roles and Evidence Boundaries

- **Verible** owns formatting and style lint. It does not elaborate the design or verify behavior.
- **Slang** is the independent SystemVerilog parser, type checker, linter, and elaborator. `make lint-slang` checks the decoder, Encaps, KeyGen, and Decaps implementation entrypoints with their real parameter defines.
- **Verilator** is the canonical local simulator for unit, integration, random, fixed-cycle, and byte-for-byte reference tests. Maintained implementation entrypoints also pass fatal-warning `--lint-only -Wall` checks; intentional exceptions are scoped by warning class and source file in `config/verilator_waivers.vlt`.
- **Yosys** is used for structural checks and as the formal frontend. Its inferred hierarchy and memories are not evidence of Vivado XPM mapping or FPGA timing.
- **SymbiYosys** with **Z3** or Yosys **ABC-PDR** proves scoped properties in `formal/`. A passing proof applies only to the selected harness, assumptions, parameters, and assertions.
- **Icarus Verilog** is optional for small portability smoke tests. It is not a signoff simulator for this repository's full SystemVerilog and XPM-oriented RTL.
- **Vivado** is the authority for Xilinx synthesis, XPM/RAMB mapping, placement, routing, utilization, and timing. Physical claims require comparable Vivado reports.
- Expected local commands on `PATH`: `verilator`, `verible-verilog-format`, `verible-verilog-lint`, `slang`, `yosys`, `sby`, and `z3`. Run `make check-local-tools` to audit them.
- `config/rtl_toolchain.lock` records the exact locally validated tool versions. Run `make tool-versions` to display them and `make check-tool-versions` to enforce the lock.

## Canonical Commands

- `make check-local-tools` - verify the required local RTL tools are available.
- `make tool-versions` - print installed and validated RTL tool versions.
- `make check-filelists` - verify canonical implementation filelists, source existence, uniqueness, and implementation tops.
- `make check-records` - verify the compact experiment/Vivado record structure and all committed run manifests.
- `make format-rtl` - format maintained RTL, testbench, and formal SystemVerilog files.
- `make check-rtl` - run filelist, formatting, Verible, fatal-warning Verilator, and `-Werror` Slang checks.
- `make formal` or `make formal-fast` - prove the maintained short formal matrix and generate cover witnesses.
- `make formal-nightly` - add the extended formal parameter cases.
- `make test-unit` - run unit testbenches.
- `make test-integration` - run the full decoder testbench.
- `make test-bike-random BIKE_RANDOM_TRIALS=1` - run one generated BIKE decoder case.
- `make test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_K=3 BIKE_RANDOM_TRIALS=1` - run the unified K=3 TRIKE profiles.
- `make test-trike-unified-ksign-random TRIKE_UNIFIED_KSIGN_K=4 BIKE_RANDOM_TRIALS=1` - run the unified K=4 TRIKE profiles.
- `make ci-fast` or `make verify-rtl` - run locked-tool audit, static checks, short formal matrix, unit tests, and integration test.
- `make ci-smoke` - add deterministic seed-1 traditional BIKE, unified BIKE, and unified TRIKE K=3/K=4 random cases.
- `make ci-nightly` - add extended formal and multi-seed full-profile unified BIKE/TRIKE regressions.
- `make ci-kem-reference` - run the opt-in official TRIKE KAT/Reference C byte-for-byte KeyGen, Encaps, and Decaps release gate; requires `config/local.mk`.
- `make check-trike-sm3-sharing` - verify the intended structural SM3 sharing hierarchy with Yosys.
- `make vivado-impl-trike-{poly-inv,pseudohash,encaps,keygen,decaps}` - run the matching Vivado implementation entrypoint.

## Change Workflow

1. Inspect `git status --short` and preserve unrelated or user-owned changes.
2. Read the affected RTL, its testbench, the relevant design status, and `docs/vivado_systemverilog_guidelines.md` before editing.
3. Keep package parameters, RTL, fixtures, wrappers, formal assumptions, and Vivado defines synchronized.
4. Update the matching `filelists/*.f` entry when an implementation source is added, removed, or reordered; Make, random simulation, Slang, Verilator lint, and Vivado consume these lists.
5. Run `make format-rtl` and `make check-rtl` after SystemVerilog edits.
6. Run the smallest relevant unit/reference test first, then integration or random profile tests in proportion to the affected scope.
7. Add or update a formal property when a small control, handshake, counter, address, selection, or constant-time invariant can be stated exhaustively. Pair safety proofs with reachable `cover` witnesses where practical. Do not attempt full-decoder formal equivalence without a bounded and reviewed abstraction.
8. For RAM, K-sign, scheduler, decoder-top, or shared package changes, validate both K=3 and K=4 paths where applicable and exercise every affected public parameter profile.
9. Run Vivado when the change can affect inference, hierarchy, utilization, routing, or timing. Record the report stage and comparison conditions.
10. Before finishing architecture, parallelism, storage, resource, or timing work, append one row to `docs/experiments/index.md`. Create a concise `EXP-xxxx-*.md` only when the decision cannot be explained in the row; include failed and withdrawn experiments.
11. For every new Vivado run, store raw reports under the external run ID and commit one matching `reports/vivado/manifests/RUN-*.toml`. Update the baseline registry only for retained comparable placed/routed results.

## Toolchain Update Workflow

1. Audit actual executables and installation sources before upgrading; do not infer freshness from a tool name alone.
2. Compare stable package-manager metadata and official upstream tags. Keep a newer validated development snapshot when replacing it with a stable tag would be a downgrade.
3. Upgrade only the selected RTL tools, not the whole host package set. Keep recoverable versioned installs for manually managed binaries.
4. Update `config/rtl_toolchain.lock` after the selected versions are installed.
5. Run `make check-tool-versions`, `make check-rtl`, `make formal-fast`, and the smallest relevant simulations before accepting the lock update. Run `make ci-fast` for the complete local gate.
6. A tool upgrade that changes formatting or diagnostics requires an audited mechanical update or a narrowly documented exception; do not restore global non-fatal warning flags.
7. Vivado versions are project baselines and are not upgraded as part of the open-source local tool refresh. Re-run comparable Vivado implementation before using a new Vivado version for resource or timing claims.

## Validation and Reporting Rules

- Prefer Makefile targets over handwritten tool commands so defines, file ordering, and logging stay reproducible.
- `filelists/*.f` are the source-order authority for maintained implementation entrypoints. Do not duplicate implementation source lists in Python or Vivado Tcl.
- Machine-specific reference/KAT paths belong in ignored `config/local.mk`; keep portable defaults and examples in tracked files.
- The default `VERILATOR` wrapper is `./scripts/verilator_quiet.py`. Compile logs are in `build/logs/verilator/`; runtime logs are in `build/logs/run/`. Use `VERILATOR_QUIET=0 make ...` only to diagnose a failure.
- Formal outputs are in `build/formal/`. A counterexample is a failing trace to debug, not a hardware timing result.
- `tb/generated/`, `build/`, `obj_dir/`, logs, waveforms, and Vivado run directories are rebuildable ignored products. Use their Make/generator entrypoints; never treat their presence as clean-clone evidence.
- Report fixed-cycle measurements with the public parameter set, `L`, `K`, storage geometry, and the exact start/done boundary. Distinguish accepted-word counts from wall-clock time extended by input backpressure.
- Report DFR/FLS experiments with trials, failures, stopping rule, and confidence bound. Zero observed failures is finite-sample evidence.
- Resource and timing comparisons must use the same FPGA part and speed grade, Vivado version, XDC, clock constraint, parameter set, `L`, `K`, memory geometry, and report stage.
- Record LUT, FF, Slice, Block RAM Tile, RAMB36, RAMB18, DSP, setup WNS/TNS, and hold WHS when available. Mark missing synthesis or route results as `待测`; do not estimate them.
- RTL simulation, formal proof, structural synthesis, and Vivado implementation are separate results. State each completed layer explicitly and do not use one as evidence for another.
- Internal clock closure does not establish board I/O timing signoff when input/output delays are absent.

## Key Files

- `Makefile` - canonical build, check, formal, simulation, and Vivado entrypoints.
- `config/rtl_toolchain.lock` - exact validated open-source RTL tool versions.
- `filelists/*.f` - canonical ordered source manifests for decoder and TRIKE KEM implementation tops.
- `docs/vivado_systemverilog_guidelines.md` - Vivado/SystemVerilog, XDC, CDC, reset, inference, and verification rules.
- `docs/design/implementation_status.md` - implemented architecture and current fixed-cycle, resource, timing, and verification baseline.
- `docs/design/vivado_baseline_registry.md` - current pointer for each accepted or pending physical implementation boundary.
- `docs/experiments/index.md` - compact append-only experiment ledger from `EXP-0082` onward.
- `docs/design/optimization_exploration_history.md` - frozen stages 1-81 archive; do not append new work.
- `reports/vivado/manifests/` - versioned metadata and results for new Vivado runs; raw reports remain outside Git.
- `docs/project_workflow.md` - source-of-truth boundaries for Git, experiments, reports, baselines, and generated products.
- `docs/verification/validation_matrix.md` - minimum validation tier for each change class.
- `rtl/bike_pkg.sv` - shared parameter sets, widths, and memory geometry.
- `rtl/decoder_top.sv` - decoder top-level RTL.
- `formal/` - maintained formal configurations and harnesses.
- `scripts/run_bike_random.py` - generated random decoder simulations.

## Documentation Rules

- Follow `docs/vivado_systemverilog_guidelines.md` when generating, modifying, reviewing, or documenting RTL, testbenches, XDC, formal harnesses, and synthesis scripts.
- 除专用探索记录外，设计文档和代码注释只描述当前状态，不写与旧版本的对比（避免“不再”、“目前已改为”、“no longer”、“now”、“instead of”、“rather than”等表述）。设计文档应描述成品架构，而非修改记录。
- 新探索按实际实施顺序追加到`docs/experiments/index.md`，不再扩展冻结的阶段1-81历史文档。普通代码修改由Git和测试记录，不创建实验项。
- 单项实验默认控制在40行以内，只记录目标与假设、硬件改动边界、验证层、量化结果和结论，不复制RTL diff、完整日志或原始Vivado报告。
- 对保留的方案同步更新相关成品设计文档；形成新的完整且可比较placed/routed基线时更新Vivado基线注册表和`docs/design/implementation_status.md`。
- 如果用户提供Vivado报告，为其分配run ID并提交TOML manifest。器件、约束、参数、工具版本或报告阶段变化时标记`incomparable`，不计算增减量。
- `AGENTS.md` 与 `CLAUDE.md` 必须保持逐字一致；修改共享规则时同步更新两份文件。
