# 验证矩阵

下表给出每类改动的最小门禁。可以增加验证，不能用较弱的证据替代要求的证据层。

| 改动范围 | 最小必跑 | 附加边界 |
| --- | --- | --- |
| 纯文档、实验索引或Vivado manifest | `make check-records` | 再运行`git diff --check` |
| 工具锁、filelist、waiver、Make/Tcl入口 | `make check-tool-versions check-filelists check-records check-rtl` | Tcl改动至少dry-run对应Vivado目标 |
| 本地工作流、PoC、综合/QoR脚本或仓库Skill | `make workflow-smoke` + `make -C workflow-smoke check-failures` + `make compile synth qor` | Skill运行官方validator；Yosys结果只标为估计 |
| 局部RTL/TB修复 | 最小定向test + `make check-rtl` | 接口、参数或共享源受影响时升级至`ci-fast` |
| Decoder数据路径、调度、RAM或K-sign | `make ci-fast` + K=3/K=4受影响profile | 固定周期、`residual=0`和`exact=1`分开记录 |
| 公开参数、`r/L/K/COLS_PER_TILE`或存储几何 | `make ci-smoke`并运行全部受影响profile | 重算周期；DFR/FLS报告trials、failures和置信界 |
| KEM密码语义、序列化、SM3/DRNG边界或完整顶层 | 最小reference test，发布前`make ci-kem-reference` | 逐byte/word golden、固定start/done边界和失败路径分开报告 |
| 形式属性或constant-time小控制 | 相关proof + cover；完整入口为`make formal-fast` | 说明harness、assumption、参数和未覆盖状态 |
| 会影响RAM推断、层次、资源、布局或时序的RTL/XDC | 上述功能门禁 + 同条件Vivado | 新run manifest；只有routed可比结果可更新基线 |

`ci-nightly`是译码器多参数/多seed深度门禁；`ci-kem-reference`是官方KAT字节闭环门禁。
两者不互相替，也不代替Vivado物理实现。
