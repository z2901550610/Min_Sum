# 本地 SystemVerilog 工作流

## 环境入口

每个新终端先在仓库根目录执行：

```sh
source scripts/eda-env.sh
make check-local-tools
make check-tool-versions
```

环境脚本选择`~/tools/oss-cad-suite`中的版本化 EDA 工具，并把主机 Python
3.12/cocotb 2.0.1 放在仿真路径前端。`config/rtl_toolchain.lock`是实际验证版本的
唯一锁文件；`scripts/eda-env.sh`只负责可复现地选择这些程序。

## 规范入口

| 入口 | 内容 | 证据边界 |
| --- | --- | --- |
| `make format` | 生产 RTL/TB/Formal 格式化 | 文本格式 |
| `make lint` | filelist、格式、Verible、Verilator、Slang | 静态/展开 |
| `make compile` | 译码器顶层与常时比较选择模块展开 | 可编译性 |
| `make test` | 单元与集成仿真 | 行为 |
| `make regress` | 固定 seed 的 BIKE/TRIKE 随机 smoke | 有限样本行为 |
| `make formal` | 短 proof/cover 矩阵 | harness 范围内属性 |
| `make synth` | Slang 前端的 generic 与 xc7-oriented Yosys 综合 | 结构和资源估计 |
| `make qor` | `kem_ct_compare_select`的验证状态与 Yosys 指标快照 | 本地估计，不是物理结果 |
| `make check` | `ci-fast`、compile、独立 PoC、local synth | 完整本地门禁 |

原有细粒度目标仍是调试和分层回归的规范入口。`filelists/*.f`继续控制生产
实现源顺序；统一别名没有复制或替换该来源。

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
4. 运行格式与静态检查，再按验证矩阵升级到仿真、随机、形式和 Vivado。
5. 架构/QoR工作先保存可复现基线，一次只改变一个结构变量。
6. 分层报告结果；Yosys不能替代 Vivado，内部时钟收敛不能替代板级 I/O signoff。

仓库 Skills 位于`.agents/skills/`，覆盖规格、架构、实现、lint 调试、验证、
形式、综合和 QoR。Codex 根据任务读取相应`SKILL.md`。

## 远端物理扩展

Vivado仍使用现有`make vivado-impl-trike-*`入口。原始报告放在外部 run ID
目录，仓库提交对应 TOML manifest。只有器件、版本、XDC、时钟、参数、`L/K`、
存储几何和报告阶段相同的 placed/routed 结果才可计算物理差值。本地流程不包含
ASIC backend。
