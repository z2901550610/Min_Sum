# 验证矩阵

下表是任务级最小门禁的权威。可以增加验证，不能用较弱的证据替代要求的证据层。
测试命令和测试owner来自`config/test_catalog.toml`。表格由`config/validation_profiles.toml`生成；修改profile后运行`make update-validation-matrix`，漂移由`make check-validation-profiles`拒绝。
`make check-plan`只读分析当前Git差异并输出保守计划；dirty worktree使用
`VALIDATION_PATHS="<task-owned paths>"`限定范围。它不执行命令，也不产生PASS。
输出中的任务命令是本次改动的最小完成门禁；发布/共享范围升级命令只在对应边界
适用时执行。已知owner优先运行定向目标，无owner时回退到profile聚合门禁；同一层
目标合并为一次Make调用。owner是可选的加速映射；配置拒绝重叠owner，但不要求每个
RTL/TB/formal源都登记owner。研究脚本和数据无需强制路由，规划器提示后按任务选择检查。
广泛集成、工具链资格或下表明确要求时运行完整`make check`；核心构建/runner改动运行`make validate-workflow`。普通工作流脚本和Skill不触发完整资格。

其他变更完成对应矩阵行后，完整`make check`可报告为`NOT_APPLICABLE`。

<!-- BEGIN GENERATED VALIDATION PROFILES -->
| 改动范围 | 最小必跑 | 附加边界 |
| --- | --- | --- |
| 纯文档、实验索引或Vivado manifest | `git diff --check`；实验/物理记录由owner选择`make check-records` | 普通文档/Skill不扫描全仓记录；相关链接由本次编辑核对 |
| 工具锁、filelist、waiver、Make/Tcl入口 | `make check-filelists check-fast` | 工具锁按owning rule运行`make check`；Tcl改动至少dry-run对应Vivado目标 |
| 工作流辅助脚本、综合/QoR脚本或CI配置 | `make check-agent-workflow`；核心入口另运行`make validate-workflow` | 只有核心构建/runner或工具链资格需要`make validate-workflow`；普通辅助脚本运行相关测试 |
| 核心Make、验证runner、环境入口或依赖 | `make validate-workflow` | 仅工作流单测和工具smoke；生产recipe改变另测受影响目标，工具链基线验收另跑make check |
| 局部RTL/TB修复 | 最小定向test + `make check-fast` | 接口、参数或共享源受影响时升级至`ci-fast` |
| Decoder数据路径、调度、RAM或K-sign | 所属定向test + `make check-fast`；无owner运行`make ci-fast` | 叶级定向目标完成后，发布或共享decoder改动运行`make ci-fast`；固定周期、`residual=0`和`exact=1`分开记录 |
| 公开参数、`r/L/K/COLS_PER_TILE`或存储几何 | `make ci-smoke`并运行全部受影响profile | 发布运行`make ci-smoke`；重算周期；DFR/FLS报告trials、failures和置信界 |
| KEM密码语义、序列化、SM3/DRNG边界或完整顶层 | 所属最小reference test + `make check-fast`；无owner运行`make ci-kem-reference` | 定向目标完成后，发布或共享KEM语义改动运行`make ci-kem-reference`；逐byte/word golden、固定start/done边界和失败路径分开报告 |
| 形式属性或constant-time小控制 | 所属proof + cover；无owner运行`make formal-fast` | 已知harness运行所属proof/cover；发布或共享formal基础设施运行`make formal-fast`；说明assumption、参数和未覆盖状态 |
| 涉及FPGA映射、资源、布局或时序的RTL/XDC | 所需功能门禁；物理验收或基线更新另须同条件Vivado | 仅功能修复标明物理影响未验证，不宣称物理收益或更新基线；Vivado执行须新run manifest，只有routed可比结果可更新基线 |
<!-- END GENERATED VALIDATION PROFILES -->

`ci-nightly`是译码器多参数/多seed深度门禁；`ci-kem-reference`是官方KAT字节闭环门禁。
两者不互相替，也不代替Vivado物理实现。
