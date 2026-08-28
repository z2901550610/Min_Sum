# Implementation + Migration Plan

审计日期：2026-08-28  
目标：在不改变 BIKE/TRIKE RTL 算法语义的前提下，把现有成熟流程收敛为 Agent 可重复调用、
证据边界清晰的唯一工作流。

## Target Architecture

```text
spec/design docs
      -> filelists/*.f + rtl/*.sv
      -> make format/lint/compile
      -> make test/regress
      -> make formal
      -> make synth/qor (Yosys estimate)
      -> verified Git revision
      -> Windows/remote Vivado implementation + manifest
```

### Canonical source-of-truth

- 公开参数、位宽和 decoder memory geometry：`rtl/bike_pkg.sv`。
- 实现源文件顺序：`filelists/*.f`。
- 生产 RTL：`rtl/`；验证 oracle：`tb/`、`formal/`、`software/` 和 fixture 生成器。
- 日常行为契约：`AGENTS.md`，`CLAUDE.md` 为逐字镜像。
- 当前架构和证据边界：`docs/design/implementation_status.md`。
- 验证选择：`docs/verification/validation_matrix.md`。
- 物理结果：外部 raw Vivado run + `reports/vivado/manifests/RUN-*.toml`。

### Canonical commands

| 命令 | 语义 |
| --- | --- |
| `make format` | 确定性格式化，直接调用现有 formatter |
| `make lint` | filelist、格式、Verible、Verilator、Slang |
| `make compile` | 代表性 decoder/KEM 顶层 elaboration/compile，不跑长测试 |
| `make test` | 快速 unit + integration |
| `make regress` | 固定 seed 的参数化 smoke，支持现有变量覆盖 |
| `make formal` | scoped safety + reachable cover |
| `make synth` | 真实小模块 Yosys generic/Xilinx-oriented synthesis smoke |
| `make qor` | 生成 Markdown/JSON，不可得字段为 `null` |
| `make check` | 本地提交前 gate；包含`ci-fast`、compile、独立PoC和local synth |

细粒度 `test-*`、`formal-*`、`ci-*` 和 `vivado-*` 继续作为风险分层与诊断入口，不另建 shell
wrapper。旧 `sim` 同义 alias 在文档切换并完成引用搜索后删除。

## 资产决策

- KEEP：RTL、filelists、SV TB、reference software、formal harness、Vivado Tcl/XDC、manifest、
  tool lock、验证矩阵、当前设计文档和实验 ledger。
- MIGRATE：Make 短入口、环境/限制说明、root K-sign 结果（单独核对后迁入 `reports/`）。
- REWRITE：无；现有核心流程没有证据支持整体重写。
- ARCHIVE：现有 `docs/archive/` 与冻结阶段 1-81 历史维持原位。
- DELETE：无能力的 `sim` 同义 alias；删除前通过引用搜索和 `make test` 验收。
- ADD：`workflow-smoke/`、QoR 解析脚本、环境报告、已知限制、工作流文档和
  `.agents/skills/`。

## Compatibility Layer

迁移期短入口与现有项目名并存：`lint -> check-rtl`，`check`聚合`ci-fast`、compile、独立
PoC和local synth，细粒度目标仍供诊断使用。这不是 shell wrapper 链；Make 依赖图直接复用
同一实现。验收后文档只推荐短入口和风险 gate，不再推荐 `sim`。

## 实施顺序与退出条件

1. **审计**：提交本 inventory、conflict matrix 和 migration plan。退出条件是所有高保护
   oracle、实现源和旧入口均已分类。
2. **机器/工具链**：记录 macOS、架构、工具来源和版本；验证 cocotb、Yosys Slang plugin、
   sby+solver、Verible、Surfer。缺失能力只能写 `UNSUPPORTED`，不能写 PASS。
3. **独立 PoC**：counter 包含 parameter/enum/always_ff/always_comb；lint、cocotb simulation、
   prove+cover、generic 和 Xilinx-oriented synthesis 全部通过。故障注入以自动脚本或临时副本
   验证 lint/sim/formal 能失败，不修改生产 RTL。
4. **统一 Make 接口**：增加 canonical targets、构建目录和结构化日志；原细粒度 target 保持
   单一实现。
5. **真实模块迁移**：选择 `kem_ct_compare_select`。它已有 unit test 和 formal harness，规模
   适合 generic/Xilinx synthesis；记录 legacy 与新入口的等价结果。
6. **Skills/Agent 合约**：依据已通过的命令写 focused repo skills；更新 AGENTS/CLAUDE 导航，
   不复制完整数字 IC 教科书。
7. **Dry runs**：在临时 PoC 副本执行一轮可恢复 bug-fix 演练；对真实小模块执行 baseline 与
   等价 QoR 重跑，证明报告可复现，不制造虚假的资源改进。
8. **Full validation**：至少运行 `make check`、`make synth`、`make qor`、records/filelist check
   和 `git diff --check`。Vivado 为 `NOT_RUN`，除非取得同条件 Windows run。

## Cutover 与 rollback

Cutover 条件：新短入口返回与底层目标一致的非零失败状态；PoC 全链通过；真实模块的 test、
formal、synth 通过；文档和 AGENTS 指向唯一入口；`sim` 无引用。达到条件后删除 `sim` alias。

Rollback 使用普通 Git diff/commit 边界恢复本次 workflow 文件；不运行 `git reset --hard`、
`git clean`，不触碰用户本地 `config/local.mk`、generated fixture 或 external KAT。若新增工具
导致诊断漂移，保留原锁定工具路径，并把新增能力标为 optional/unsupported，直至单独通过
`make ci-fast`。

## 不在范围内

OpenROAD、PDK、ASIC STA/PnR、DFT、ATPG、DRC/LVS、GDS 和 nextpnr-xilinx sign-off 均不进入
核心流程。本地 Yosys 数字只用于 synthesizability 与相对结构趋势；Xilinx RAM/DSP 推断、
布局布线和 timing 只由可比 Vivado synthesis/implementation 报告确认。
