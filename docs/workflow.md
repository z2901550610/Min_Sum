# 本地研究工作流

默认流程：相关代码 → 修改 → 最小自检 → 按实际影响补检查 → 停止。
不以生产资格验证作为日常完成条件。共享原则以[AGENTS](../AGENTS.md)为准。

## 入口与选测

本地工具用`./eda <command>`，例如`./eda make test-ram-accum`。环境脚本选择现有OSS CAD Suite及项目
`.venv`；环境缺失或依赖变化时执行`uv sync --frozen`。`tool-versions`告警版本差异，
`check-tool-versions`用于显式基线核查。工具基线与限制见[环境](environment.md)。

| 变化 | 最小检查 |
| --- | --- |
| 局部RTL/TB | 格式化任务文件，运行所属自检 |
| 接口、共享行为 | 补实际受影响调用方的reference/集成 |
| filelist/package/top | filelist检查及相关展开；需要跨顶层时用`check-fast` |
| 控制/调度属性 | 已有相关proof/cover；不要求新建形式工程 |
| 参数表 | 测改变的档；通用几何变化才补最小/最大代表档 |
| Make recipe、catalog、辅助脚本 | 相关工作流单测及改动命令 |
| 执行器、环境或工具互操作 | `validate-workflow` |
| 文档 | 差异和相关链接；RUN/物理基线关系改变才用`check-records` |

选测不明时用`./eda make check-plan VALIDATION_PATHS="..."`。缺少owner不等于已验证。
`check-validation-profiles`只验证选测配置；文字规则只维护在本页。

## 显式聚合入口

- `check-fast`：filelist和多顶层Slang展开；`ci-fast`再加单元/集成。
- `check-rtl`：完整格式、Verible、Verilator及Slang。
- `test` = `test-unit` + `test-integration`；选择所需范围，不顺序重复。
- `ci-kem-reference`：KEM参考集合及reference数据检查。
- `regress`/`ci-smoke`/`ci-nightly`：显式随机或扩展覆盖。
- `check`：新工具链或明确的广泛资格检查；`validate-workflow`不证明生产RTL。
- `synth`：Yosys generic/Xilinx结构估计；`qor`专用于compare-select自检、proof和估计。
  `qor-record`保存tracked结果；`qor-report`如实传入证据状态。

CI的代码push/PR使用`ci-fast`，纯Markdown/docs变化跳过；手动工作流使用`check`。
`VALIDATION_PROFILE_SET=representative|all`控制完整尺寸入口，默认代表参数。
Fold乘法/求逆几何不等同于完整KEM/KAT覆盖。

## 输出与证据

定向仿真使用独立`build/verilator/<target>/<variant>/`；quiet wrapper保留完整日志、退出码与失败摘录。
结果事件统一写入`build/results/runs/<run-id>/events.jsonl`；`validate-workflow`自动生成摘要，
单独formal执行也分配独立run。需要时用`./eda python3 scripts/validation_events.py summarize --events <events.jsonl> --run-id <run-id>`重建摘要。
PASS/FAIL/NOT_RUN/NOT_APPLICABLE与CANCELLED分别表达实际边界。
DFR结论保留trials、failures、停止规则及置信界；toy proof只证明其harness范围。

物理结果用Windows Tcl Console或`vivado -mode batch -source scripts/vivado_trike_kem_cores.tcl`。
RUN规则见[manifest规范](../reports/vivado/manifests/README.md)。
日常功能探索无需Vivado；未测资源/时序不作物理收益声明。
Yosys `synth`/`qor`只是结构估计，不是Vivado映射、布局、布线或时序结论。

## 记录门槛

| 内容 | 唯一维护位置 | 何时更新 |
| --- | --- | --- |
| 普通修改、调试、测试输出 | Git、自动日志 | 不另写总结文件 |
| 当前接口、RAM生命周期、固定周期 | 所属[设计文档](design/) | 采用的设计事实改变时 |
| 当前验证范围与限制 | [实现状态](design/implementation_status.md) | 有新结果或旧结果失效时 |
| 有证据放弃的方向 | [错题本](experiments.md) | 一条机制只记一次 |
| 有价值但未完成的候选 | [路线图](design/trike_kem_optimization_roadmap.md) | 确需跨任务保留时 |
| 正式物理结果 | RUN manifest、原始报告、[基线注册表](design/vivado_baseline_registry.md) | 按物理证据规则 |

阅读、推导、参数试点默认留在对话与工具输出，不创建计划/日报/阶段总结；不再分配EXP。
普通编译错误不进入错题本。只有证据表明某方向在当前约束下不值得继续时，记录
“方向/条件、失败原因、关键证据、重新考虑的条件”。
未测、CANCELLED与NOT_RUN不是失败；局部Yosys估计不是Vivado结论。
成功方案只更新所属设计说明及必要验证边界。
可重建fixtures、日志、波形、综合输出留在已有build/report目录。
