# 归档文件（不再使用）

本目录存放从活跃文档和流程中移除的历史文件。目录内所有内容均不再被当前设计文档、验证流程或构建脚本引用，仅作为历史参考保留。请勿在新文档或脚本中引用本目录内容。

| 内容 | 原位置 | 归档原因 |
| --- | --- | --- |
| `parameter_results.md` | `docs/verification/` | 仅含 BIKE 三档 seed-1 早期结果，已被 `design/implementation_status.md` 和实验索引覆盖 |
| `figures/` | `docs/figures/` | 无文档引用的早期导出图和图源；现役图仅保留 `docs/figures/decoder_datapath.*` |
| `recovered/` | `docs/recovered/` | 早期恢复出的架构图源与导出，无任何引用 |
| `decoder_architecture.md` | `docs/design/` | 内容已并入 `design/decoder_hardware_design_guide.md`（§4、§13、§19） |
| `decoder_schedule.md` | `docs/design/` | 内容已并入 `design/decoder_hardware_design_guide.md`（§14） |
| `tile_decoder_design.md` | `docs/design/` | 内容已并入 `design/decoder_hardware_design_guide.md`（§5、§8） |
| `k_sign_decoder_design.md` | `docs/design/` | 现役内容已并入 `design/decoder_hardware_design_guide.md`（§2.4、§11、§12）；文内 K=3 资源估算和 DFR 表为历史快照 |
| `TRIKE_HARDWARE_OPTIMIZATION_ANALYSIS.md` | `docs/design/` | EXP-0115 前的优化调研快照；活跃结论已由 `design/trike_kem_optimization_roadmap.md` 和实验索引接管 |

归档文档内部的相对链接按原目录结构编写，移动后可能失效。
