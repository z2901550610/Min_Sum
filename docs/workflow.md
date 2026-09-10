# 本地研究工作流

默认流程：相关代码 → 修改 → 最小自检 → 按实际影响补检查 → 停止。
不以生产资格验证作为日常完成条件。共享原则以[AGENTS](../AGENTS.md)为准。

## 入口与选测

本地工具用`./eda <command>`，例如`./eda make test-ram-accum`。环境脚本选择现有OSS CAD Suite及项目
`.venv`；环境缺失或依赖变化时执行`uv sync --frozen`，无需每次checkout或每条命令同步。
日常只需要实际用到的工具；`tool-versions`告警版本差异，`check-tool-versions`用于显式基线核查。

| 变化 | 最小检查 |
| --- | --- |
| 局部RTL/TB | 格式化任务文件，运行所属自检；编译已提供局部语法/展开反馈 |
| 接口、共享行为 | 补实际受影响调用方的reference/集成；不自动扩大到完整KEM |
| filelist/package/top | filelist检查及相关展开；需要跨顶层检查时用`check-fast` |
| 控制/调度属性 | 已有相关proof/cover与周期/访问检查；不要求新建形式工程 |
| 参数表 | 测改变的档；通用几何公式变化才补最小/最大代表档与便宜边界 |
| Make recipe、catalog、辅助脚本 | 相关工作流单测及改动命令；catalog仍是测试命令/分组/owner唯一来源 |
| 执行器、环境或工具互操作 | `validate-workflow`：单测、正/负工具smoke |
| 文档/Skill | 差异和相关链接；EXP/RUN/物理基线关系改变才用`check-records` |

选测不明时用`./eda make check-plan VALIDATION_PATHS="..."`；planner只给一套建议，不另列发布或迭代门禁。
逐文件选择后合并为一次Make调用；不按验证类别删掉其他文件的定向测试。
缺少owner不等于已验证，应按行为选择测试。`check-validation-profiles`只验证选测配置与引用；
文字规则只维护在本页，不生成或检查另一份文档矩阵。

## 显式聚合入口

- `check-fast`：filelist和多顶层Slang展开；`ci-fast`再加单元/集成，供代码CI或需要广泛集成时使用。
- `lint`/`check-rtl`：完整格式、Verible、Verilator及Slang；诊断需要时使用。`lint`已包含`format-check`。
- `test`已包含`test-unit`和`test-integration`；选择其中所需范围，不顺序重复执行。
- `ci-kem-reference`：KEM参考集合及reference数据检查，不要求无关工具、锁定版本或全仓lint。
- `regress`/`ci-smoke`/`ci-nightly`：显式随机或扩展覆盖；不作为参数变化的统一默认入口。
- `check`：新工具链或明确的广泛资格检查；`validate-workflow`不证明生产RTL。
- `synth`：Yosys generic/Xilinx结构估计；`qor`专用于compare-select自检、proof和估计，未跑的lint标NOT_RUN。
  `qor-record`显式保存tracked结果；只保存已有结果可用`qor-report`并如实传入证据状态。

CI的代码push/PR使用`ci-fast`，纯Markdown、docs、Skill变化跳过；手动工作流使用`check`。
完整尺寸入口仍支持`VALIDATION_PROFILE_SET=representative|all`，默认代表参数；个别suite可显式覆盖。
例如`./eda make test-trike-fold-profiles FOLD_ARGS="--suite multiply --list"`可只查看几何，不运行仿真。
Fold乘法/求逆几何不等同于完整KEM/KAT覆盖；参考参数域必须注明。

## 输出与证据

定向仿真使用独立`build/verilator/<target>/<variant>/`；quiet wrapper保留完整日志、退出码与失败摘录。
fixture内容未变不重写，测试按请求执行。不要为了省输出吞掉失败，也不要重复轮询整个日志。
`validate-workflow`结果在`build/results/runs/<run-id>/`，普通任务无需另建汇总报告。
PASS/FAIL/NOT_RUN/NOT_APPLICABLE与CANCELLED分别表达实际边界，不要求为无关层填满清单。
DFR结论保留trials、failures、停止规则及置信界；toy proof只证明其harness范围。

物理结果用Windows Tcl Console或`vivado -mode batch -source scripts/vivado_trike_kem_cores.tcl`。
RUN/原始报告及同条件比较规则见[记录政策](project_workflow.md)和[manifest规范](../reports/vivado/manifests/README.md)。
日常功能探索无需Vivado；未测资源/时序不作物理收益声明。
