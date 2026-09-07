# 本地 SystemVerilog 工作流

## 环境入口

checkout后或`pyproject.toml`/`uv.lock`变化时执行一次：

```sh
uv sync --frozen
```

每个新终端只需在仓库根目录选择已安装环境：

```sh
source scripts/eda-env.sh
```

环境脚本选择`~/tools/oss-cad-suite`中的版本化 EDA 工具，并把项目`.venv`中的
Python 3.12、cocotb 2.0.1、PyYAML和pytest放在路径前端。`uv.lock`锁定Python
依赖与哈希，`config/rtl_toolchain.lock`记录共同验证的工具版本；
`scripts/eda-env.sh`只选择这些已安装程序，不隐式安装依赖。`ci-fast`、`make check`
和`make validate-workflow`会执行工具存在性和版本门禁，无需在同一流程前手工重复。

GitHub CI位于`.github/workflows/ci.yml`。它在Linux runner上固定Python 3.12.10、
OSS CAD Suite 2026-08-27和带校验和的Verible版本，执行`uv sync --frozen`后只调用canonical `make check`；
YAML不复制单项测试、proof或综合recipe。Vivado物理实现仍在独立Windows流程中完成。

## 规范入口

| 入口 | 内容 | 证据边界 |
| --- | --- | --- |
| `make format FILES="..."` | 仅原地格式化本任务指定的 RTL/TB/Formal 文件 | 文本格式 |
| `make format-check` | 非修改式检查全部维护中的 SystemVerilog 文件 | 文本格式门禁 |
| `make lint` | filelist、格式、Verible、Verilator、Slang | 静态/展开 |
| `make compile` | 译码器顶层与常时比较选择模块展开 | 可编译性 |
| `make test` | 单元与集成仿真 | 行为 |
| `make regress` | 仅运行固定 seed 的 BIKE/TRIKE 随机 smoke；不隐含静态、单元或formal门禁 | 有限样本行为 |
| `make formal` | 短 proof/cover 矩阵 | harness 范围内属性 |
| `make synth` | Slang 前端的 generic 与 xc7-oriented Yosys 综合 | 结构和资源估计 |
| `make qor` | 验证`kem_ct_compare_select`并写入`build/results/qor/` | 只读工作树的本地估计，不是物理结果 |
| `make qor-record` | 重新验证并更新`reports/qor/latest.*` | 显式接受/记录本地估计，会修改tracked文件 |
| `make check-plan` | 根据当前Git差异输出任务完成命令，并单列发布/共享范围升级命令 | 只读规划，不执行门禁 |
| `make check-plan VALIDATION_PATHS="..."` | 仅为本任务拥有的路径规划并限定`git diff --check`范围 | dirty worktree下的最小只读规划 |
| `make check-validation-profiles` | 核对TOML配置与生成矩阵 | 只读漂移门禁；也由`check-records`执行 |
| `make update-validation-matrix` | 从TOML更新矩阵标记区块 | 显式文档生成操作 |
| `make check` | `ci-fast`、compile、local synth | 完整本地RTL门禁，不重复验证工作流自身 |
| `make validate-workflow` | 工作流单元测试、正/负向烟测、`check`和同轮QoR报告 | 核心工作流/工具链完成门禁 |

`make format-changed`显式格式化当前 Git 变更中的 SystemVerilog 文件，
`make format-all`显式格式化全部维护文件。Agent 默认使用`FILES`列出本任务拥有的
文件，避免改写其他未提交工作。`make lint`和`make format-check`不修改受版本控制
的源文件。`config/validation_profiles.toml`只保存profile、路径路由、Make target名称、
覆盖关系、发布升级目标和矩阵表格，不保存shell命令。行为owner是局部验证的可选加速
映射；配置检查拒绝重叠owner、失效target和profile错配，但未登记owner的源会安全回退。
`docs/verification/validation_matrix.md`是生成后供人审阅的任务级最小门禁权威。`check-plan`把 owning target 列为任务完成命令，
把不会被本次改动直接触发的聚合门禁单列为发布/共享范围升级命令。无已知owner时
才使用对应profile的保守聚合门禁，并把同一层的所有target合并成一次Make调用，交由
Make依赖图统一去重。完整`make check`用于共享生产RTL、核心工作流/
工具链、发布/CI资格或矩阵明确要求的变更。`filelists/*.f`继续控制生产实现源顺序。

根Make入口通过`scripts/sby_quiet.py`运行SymbiYosys。终端只显示每个task的状态、
耗时、输入摘要和日志路径。独立运行的完整输出保存在`build/logs/sby/`，最新task结果
写入`build/results/check-summary.json`；`make validate-workflow`则把formal、编译、仿真
日志和task摘要放入本次run目录。task摘要不是完整门禁的总体PASS，只有task、参数、
工具版本和`source_digest`均匹配时，才能确认两项记录输入一致；当前流程不自动复用
旧结果。独立workflow smoke也使用该包装；故障注入把预期FAIL写入隔离摘要。调试时可设置`SBY_QUIET=0`。

`make validate-workflow`为每次执行生成`build/results/runs/<run-id>/`。`events.jsonl`
按实际执行次数保存formal、编译、仿真、静态检查、综合与阶段结果；`summary.json`
和`summary.txt`给出本run的聚合结论，`run.json`记录完整非忽略工作树内容摘要，
`run.log`保存被终端压缩的完整输出。摘要会列出
同一run内的重复signature，并列出最慢的五个已记录叶子任务而不重复外层阶段耗时，供审计
重复执行和定位性能瓶颈。聚合状态优先级为`FAIL > NOT_RUN > PASS > NOT_APPLICABLE`，
未执行证据不会被其他PASS掩盖。重复signature不单独构成失败。负向故障
注入使用隔离环境，预期FAIL不会污染主run事件。

直接Verilator测试使用`build/verilator/<make-target>/<variant>/`，同一聚合门禁中的
不同目标不共享编译目录；参数配置通过不同的直接目标隔离。测试聚合目标只声明
直接目标依赖，不内联编译或仿真recipe。并行Verilator日志以目标名和原子创建的唯一
文件名写入日志目录。`make validate-workflow`默认以`VALIDATION_JOBS=2`运行完整本地
gate；资源受限主机可显式设置`VALIDATION_JOBS=1`。并行只改变独立任务的执行顺序，
不改变单个test、proof或固定周期事务的语义与证据边界。

## 两层导入路径

`workflow-smoke/`是独立四位计数器 PoC。它验证 Verible、Slang、Verilator、
cocotb、SymbiYosys/Z3、Yosys+Slang和FST生成，不进入生产
filelist。运行：

```sh
make workflow-smoke
make -C workflow-smoke check-failures
make -C workflow-smoke test WAVES=1 LZ4_PREFIX=/installed/lz4/prefix
```

波形生成只验证FST文件，不把波形查看器纳入必需工具链。`LZ4_PREFIX`由调用者
显式提供，避免把本地Homebrew路径写入可移植流程。

生产切入点为`rtl/kem_ct_compare_select.sv`。`make qor`先执行静态检查、定向
仿真和三个宽度的proof/cover，再生成`build/results/qor/latest.{json,md}`。只有
显式`make qor-record`更新tracked的`reports/qor/latest.*`。状态只使用
`PASS`、`FAIL`、`NOT_RUN`和`NOT_APPLICABLE`；没有执行的层不得标成通过。

## 变更路径

1. 读取`AGENTS.md`、相关设计状态、RTL/TB、规范和验证矩阵。
2. 运行`make check-plan VALIDATION_PATHS="<task-owned paths>"`核对本任务风险分类；
   只有任务确实拥有当前全部Git差异时才省略`VALIDATION_PATHS`。先完成任务命令，
   只有发布/共享范围边界适用时才执行单列的升级命令，并保存seed、参数和日志。
3. 修改 RTL 时同步 package、wrapper、fixture、formal assumption、defines 和 filelist。
4. 使用`make format FILES="..."`只格式化本任务文件，再运行只读静态检查，并按
   验证矩阵升级到仿真、随机、形式和 Vivado。
5. 架构/QoR工作先保存可复现基线，一次只改变一个结构变量。
6. 分层报告结果；Yosys不能替代 Vivado，内部时钟收敛不能替代板级 I/O signoff。

## Agent Skill 路由

仓库 Skills 位于`.agents/skills/`。Codex 在修改文件或运行 RTL 验证前，根据任务
边界读取最小适用集合；跨阶段任务按以下顺序组合，不能用后续阶段替代前置契约：

| 阶段 | Skill |
| --- | --- |
| 行为、接口、周期与验收条件 | `rtl-spec` |
| 数据通路、FSM、RAM 生命周期与调度 | `rtl-architecture` |
| SystemVerilog 实现 | `rtl-implement` |
| 静态检查失败诊断 | `rtl-lint-debug` |
| 定向、集成、定周期与随机验证 | `rtl-verification` |
| 控制与常时属性证明 | `rtl-formal` |
| 可综合性、层次与推断检查 | `rtl-synthesis` |
| 资源、时序、延迟与吞吐优化 | `rtl-qor-opt` |

组合设计任务的标准顺序是
`spec -> architecture -> implement -> verification/formal -> synthesis/qor`，
只省略确实不适用的阶段。仅要求解释、审查或诊断时，不自动进入实现阶段。

## 远端物理扩展

Vivado以 Windows Tcl Console 或`vivado -mode batch -source
scripts/vivado_trike_kem_cores.tcl`为主入口；`make vivado-impl-trike-*`只是可选包装。
通过`VIVADO_REPORT_ROOT`选择外部报告根目录，每个 run 使用独立 run ID 子目录，
仓库只提交对应 TOML manifest。只有器件、版本、XDC、时钟、参数、`L/K`、存储
几何和报告阶段相同的 placed/routed 结果才可计算物理差值。本地流程不包含 ASIC
backend。
