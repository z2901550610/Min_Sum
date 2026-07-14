# CLAUDE.md

## Project Snapshot

- SystemVerilog RTL for a BIKE/MDPC-style min-sum decoder.
- RTL lives in `rtl/`; testbenches live in `tb/`; helper scripts live in `scripts/`.
- Generated simulation fixtures are under `tb/generated/`.

## Design Goals

- Constant-time decoding is a hard requirement.
- For a given public parameter level, decode latency must be fixed and independent of the private key, first-column support set, syndrome, error pattern, and decoder convergence behavior.
- Each parameter level may use its own fixed cycle budget, memory geometry, parallelism settings, and timing target.
- Architecture changes should optimize fixed decode time by evaluating cycle count together with achievable clock frequency and timing margin, then memory footprint, while keeping the implementation hardware-friendly for synthesis and timing closure.
- Avoid early termination, key-dependent scheduling depth, key-dependent bank counts, and data-dependent memory access counts in the main decode path.

## Common Commands

- `make test-unit` - run unit testbenches.
- `make test-integration` - run the full decoder testbench.
- `make test-bike-random BIKE_RANDOM_TRIALS=1` - run one generated random BIKE decoder case.
- `make test` - run unit plus integration tests.
- `make format-rtl` - format maintained RTL/testbench SV files.
- `make check-format-rtl && make lint-rtl` - check RTL formatting and Verible lint.

## Verilator Output

- The default `VERILATOR` is `./scripts/verilator_quiet.py`.
- Full compile logs are saved in `build/logs/verilator/`.
- Runtime logs are saved in `build/logs/run/`.
- Use `VERILATOR_QUIET=0 make ...` only when raw Verilator output is needed.

## Key Files

- `Makefile` - canonical build/test entry points.
- `docs/vivado_systemverilog_guidelines.md` - Vivado/SystemVerilog RTL, XDC, CDC, reset, resource inference, and verification rules for this repository.
- `docs/design/implementation_status.md` - current implemented architecture, fixed-cycle, resource, timing, and verification baseline.
- `docs/design/optimization_exploration_history.md` - chronological record of architecture and resource optimization experiments.
- `docs/references/cai-zhang-2023-low-complexity-parallel-min-sum-mdpc-decoder.pdf` - reference paper for the decoder architecture.
- `rtl/bike_pkg.sv` - shared parameters/types.
- `rtl/decoder_top.sv` - top-level decoder RTL.
- `scripts/run_bike_random.py` - generated random decoder simulations.

## Working Notes

- Prefer Makefile targets over hand-written Verilator commands.
- Use `make format-rtl` for RTL/TB formatting. Declarations align direction/`logic`/packed width/name; unpacked dimensions stay tight to the name, e.g. `foo[0:L-1]`.
- Keep terminal output compact; inspect saved logs only when a failure needs detail.
- Do not delete generated files casually; generated SV headers are used by tests.
- Follow `docs/vivado_systemverilog_guidelines.md` when generating, modifying, reviewing, or documenting RTL, testbenches, Vivado XDC, and synthesis scripts.
- 除专用探索记录外，设计文档和代码注释只描述当前状态，不写与旧版本的对比（避免"不再"、"目前已改为"、"no longer"、"now"、"instead of"、"rather than"等表述）。设计文档应描述成品架构，而非修改记录。

## Exploration Records

- 每次完成架构、并行度、存储映射、资源或时序优化探索后，在结束该项工作前更新 `docs/design/optimization_exploration_history.md`。有收益、无变化、失败和撤回的方案都要记录，避免重复探索。
- 按实际实施顺序追加记录，不覆盖已有实验。每项至少写明：日期或顺序、目标与假设、关键实现方式、验证范围、定量结果、结论，以及保留/撤回/待定状态。
- 定量结果应尽量包含固定周期数、LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、setup WNS/TNS 和 hold WHS。缺少综合或布局布线结果时，明确标记为“待测”，不能推测收益。
- 资源和时序对比必须注明参数集、`L`、`K`、存储几何、FPGA 器件与速度等级、Vivado 版本、XDC 时钟约束和报告阶段。只有这些条件一致时才计算增减量。
- 如果结果来自用户提供的 Vivado 报告，记录报告配置和关键数字；如果器件、约束或工具版本变化，单列结果并说明不可与原基线直接比较。
- 对保留的方案，同时更新相关成品设计文档；形成新的完整 placed/routed 基线时更新 `docs/design/implementation_status.md`。探索记录保留历史比较，其他设计文档保持当前状态表述。
- RTL 功能验证与 Vivado 实现是两个独立结果：分别记录已运行的测试、固定周期/译码正确性，以及 synthesis/placement/routing 状态。不能用功能测试通过代替资源和时序结论。
- `AGENTS.md` 与 `CLAUDE.md` 中的项目规则应保持一致；修改共享规则时同步更新两份文件。
