# Min_Sum RTL

本仓库实现公开参数决定固定调度的BIKE/MDPC Min-Sum译码器与TRIKE KEM RTL。
本地功能验证、形式证明与Vivado物理实现是独立证据层。

## 快速入口

```sh
./eda make test-trike-poly-mul-core  # 换成当前模块的定向自检
```

局部修改默认只格式化任务文件并运行相关自检，按改变的接口/行为补调用方检查后停止。
`ci-fast`、完整KEM reference和`check`是显式聚合入口，不是日常收尾清单。
命令与证据边界见[工作流](docs/workflow.md)；未知测试时可用`check-plan`辅助选择。

Vivado以 Windows Tcl Console 或直接 `vivado -mode batch -source scripts/vivado_trike_kem_cores.tcl` 为主入口。
资源与时序结论只使用同器件、Vivado版本、XDC、参数和报告阶段的可比结果。

## 目录

- `rtl/`、`tb/`、`formal/`、`filelists/`：RTL、testbench、proof 与源文件顺序
- `scripts/`：fixture 生成、验证入口与 Vivado Tcl
- `software/`、`constraints/`：软件参考与 XDC
- `config/`：测试 catalog、验证 profile、工具锁
- `docs/`：设计、工作流、错题本、验证方法
- `reports/vivado/manifests/`：Vivado 运行摘要；原始报告在外部报告根目录
- `workflow-smoke/`：不进入生产 filelist 的独立工具链 PoC

## 文档入口

| 问题 | 文档 |
| --- | --- |
| 怎样跑工具、选检查、何时停、记什么 | [工作流](docs/workflow.md) |
| 当前实现与验证范围 | [实现状态](docs/design/implementation_status.md) |
| Decoder / KEM 架构事实 | [Decoder](docs/design/decoder_hardware_design_guide.md)、[公共核](docs/design/trike_kem_common_cores.md)、[折叠](docs/design/trike_karatsuba_fold.md) |
| 候选与下一步 | [路线图](docs/design/trike_kem_optimization_roadmap.md) |
| 错题与历史 | [错题本](docs/experiments.md) |
| 物理基线 | [Vivado注册表](docs/design/vivado_baseline_registry.md) |
| 编码规范 | [coding](docs/design/coding.md) |
| 工具基线 | [环境](docs/environment.md) |

## 本机配置

将`config/local.mk.example`复制为不进入Git的`config/local.mk`，设置官方TRIKE
Reference C/KAT等机器相关路径。`external/trike-reference`只是本地默认查找路径。
