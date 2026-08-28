# SystemVerilog Codex Workflow Execution Summary

执行日期：2026-08-28；起点revision：`c877513b5aa82544ff3994a3285cfae4b8d78941`。

## 落地结果

| 阶段 | 主要命令/产物 | 结果 |
| --- | --- | --- |
| 仓库审计 | `repository-inventory.md`、`workflow-conflicts.md`、`workflow-migration-plan.md` | PASS |
| 工具环境 | `source scripts/eda-env.sh`；`make check-local-tools check-tool-versions` | PASS |
| 独立PoC | `make -C workflow-smoke check` | lint/sim/formal/synth PASS |
| 波形 | `make -C workflow-smoke test WAVES=1` | FST生成；Surfer可执行 |
| 负向检查 | `make -C workflow-smoke check-failures` | lint/sim/formal均拒绝注入缺陷 |
| bug-fix dry run | 注入错误步长，观察sim/formal失败，恢复原RTL后重跑PoC | PASS |
| 真实模块迁移 | `kem_ct_compare_select`定向test、W1/8/256 proof/cover、Yosys synth | PASS |
| QoR重复性 | 连续两次`make qor`并比较结构字段 | 完全一致 |
| QoR候选 | ternary mux对比显式mask；候选验证PASS | generic 849增至850，xc7不变，REJECTED |
| 完整本地门禁 | `make check` | PASS |
| 记录/格式 | `make check-filelists check-records`；`git diff --check`；AGENTS/CLAUDE cmp | PASS |
| Vivado | 本机未运行 | NOT_RUN |
| ASIC backend | 不属于FPGA/Vivado目标链路 | NOT_APPLICABLE |

## 可复现指标

`kem_ct_compare_select`的保留基线为：generic 849 cells；xc7-oriented 1692
mapped cells、411 LUT、0 FF、0 RAMB、0 DSP。该模块是组合逻辑，latency和
throughput字段为`null`。这些数值是Yosys估计，不是Vivado映射、布局、布线或时序结果。

## 切换结果

统一`format/lint/compile/test/regress/formal/synth/qor/check`入口已成为文档推荐路径；
原细粒度目标保留为同一Make依赖图中的诊断/风险门禁。无独有能力的`sim`别名已移除。
生产source-of-truth仍是`filelists/*.f`、`rtl/`、现有TB/formal/reference oracle和设计
状态文档。仓库级Skills位于`.agents/skills/`并通过官方validator。

完整环境、命令说明和限制分别见`docs/environment.md`、`docs/workflow.md`与
`docs/known-limitations.md`。
