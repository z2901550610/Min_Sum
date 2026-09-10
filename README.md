# Min_Sum RTL

本仓库实现公开参数决定固定调度的BIKE/MDPC Min-Sum译码器与TRIKE KEM RTL。
本地功能验证、形式证明与Vivado物理实现是独立证据层。

## 快速入口

```sh
./eda make test-trike-poly-mul-core  # 换成当前模块的定向自检
```

局部修改默认只格式化任务文件并运行相关自检，按改变的接口/行为补调用方检查后停止。
`ci-fast`、完整KEM reference和`check`是显式聚合入口，不是日常收尾清单。
命令、选测和证据边界只维护在[工作流](docs/workflow.md)；未知测试时可用`check-plan`辅助选择。

Vivado以 Windows Tcl Console 或直接 `vivado -mode batch -source scripts/vivado_trike_kem_cores.tcl` 为主入口，Make包装可选。
资源与时序结论只使用同器件、Vivado版本、XDC、参数和报告阶段的可比结果。

## 目录

- `rtl/`：可综合SystemVerilog RTL。
- `tb/`：定向、reference和集成testbench。
- `formal/`：SymbiYosys proof/cover harness。
- `filelists/`：实现顶层的规范源文件顺序。
- `scripts/`：生成、验证和Vivado入口。
- `software/`：TRIKE软件参考与RTL对拍辅助实现。
- `constraints/`：Vivado XDC约束。
- `docs/`：成品设计、验证、实验和项目工作流。
- `reports/vivado/manifests/`：版本化的Vivado运行摘要；原始报告保存在外部报告根目录。
- `.agents/skills/`：按需查阅的RTL专题指导。
- `workflow-smoke/`：不进入生产filelist的独立工具链PoC。

完整文档入口见[docs/README.md](docs/README.md)，本地流程见
[docs/workflow.md](docs/workflow.md)，项目约束见[AGENTS.md](AGENTS.md)。

## 本机配置

将`config/local.mk.example`复制为不进入Git的`config/local.mk`，在其中设置官方TRIKE
Reference C/KAT等机器相关路径。`external/trike-reference`只是本地配置的默认查找路径，
该外部Reference C目录不随仓库分发，可在`config/local.mk`中覆盖。
