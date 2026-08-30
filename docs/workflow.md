# 本地 SystemVerilog 工作流

## 环境入口

每个新终端先在仓库根目录执行：

```sh
uv sync --frozen
source scripts/eda-env.sh
make check-local-tools
make check-tool-versions
```

环境脚本选择`~/tools/oss-cad-suite`中的版本化 EDA 工具，并把项目`.venv`中的
Python 3.12、cocotb 2.0.1、PyYAML和pytest放在路径前端。`uv.lock`锁定Python
依赖与哈希，`config/rtl_toolchain.lock`记录共同验证的工具版本；
`scripts/eda-env.sh`只选择这些已安装程序，不隐式安装依赖。

## 规范入口

| 入口 | 内容 | 证据边界 |
| --- | --- | --- |
| `make format FILES="..."` | 仅原地格式化本任务指定的 RTL/TB/Formal 文件 | 文本格式 |
| `make format-check` | 非修改式检查全部维护中的 SystemVerilog 文件 | 文本格式门禁 |
| `make lint` | filelist、格式、Verible、Verilator、Slang | 静态/展开 |
| `make compile` | 译码器顶层与常时比较选择模块展开 | 可编译性 |
| `make test` | 单元与集成仿真 | 行为 |
| `make regress` | 固定 seed 的 BIKE/TRIKE 随机 smoke | 有限样本行为 |
| `make formal` | 短 proof/cover 矩阵 | harness 范围内属性 |
| `make synth` | Slang 前端的 generic 与 xc7-oriented Yosys 综合 | 结构和资源估计 |
| `make qor` | `kem_ct_compare_select`的验证状态与 Yosys 指标快照 | 本地估计，不是物理结果 |
| `make check` | `ci-fast`、compile、独立 PoC、local synth | 完整本地门禁 |

`make format-changed`显式格式化当前 Git 变更中的 SystemVerilog 文件，
`make format-all`显式格式化全部维护文件。Agent 默认使用`FILES`列出本任务拥有的
文件，避免改写其他未提交工作。`make lint`和`make format-check`不修改受版本控制
的源文件。细粒度目标只用于复现单个失败、定向验证或选择明确的 CI profile；
`filelists/*.f`继续控制生产实现源顺序。

## 两层导入路径

`workflow-smoke/`是独立四位计数器 PoC。它验证 Verible、Slang、Verilator、
cocotb、SymbiYosys/Z3、Yosys+Slang、FST 和 Surfer 的工具互操作，不进入生产
filelist。运行：

```sh
make workflow-smoke
make -C workflow-smoke check-failures
make -C workflow-smoke test WAVES=1
```

生产切入点为`rtl/kem_ct_compare_select.sv`。`make qor`先执行静态检查、定向
仿真和三个宽度的 proof/cover，再生成`reports/qor/latest.{json,md}`。状态只使用
`PASS`、`FAIL`、`NOT_RUN`和`NOT_APPLICABLE`；没有执行的层不得标成通过。

## 变更路径

1. 读取`AGENTS.md`、相关设计状态、RTL/TB、规范和验证矩阵。
2. 先跑最小可重现目标，保存 seed、参数和日志。
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
