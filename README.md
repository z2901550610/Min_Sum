# Min_Sum RTL

本仓库实现公开参数决定固定调度的BIKE/MDPC Min-Sum译码器与TRIKE KEM RTL。
本地功能验证、形式证明与Vivado物理实现是独立证据层。

## 快速入口

```sh
source scripts/eda-env.sh
make check-fast
make test-trike-poly-mul-core  # 换成当前模块的定向测试
```

- `ci-fast`：轻量静态检查（filelist + Slang）、单元和集成测试；局部修改使用 `check-fast` 加定向 test。
- `ci-smoke`：加入固定seed的BIKE和TRIKE K=3/K=4随机点。
- `ci-nightly`：加入扩展形式参数与多参数、多seed回归。
- `ci-kem-reference`：使用机器本地的官方TRIKE KAT/Reference C执行KeyGen、Encaps和Decaps
  byte-for-byte发布门禁；该入口明确不属于日常快速回归。
- `validate-workflow`：工作流单测与正/负工具 smoke；不运行生产 RTL 全套检查或 QoR。
- `workflow-smoke`：独立计数器的lint、cocotb、formal与Yosys互操作证明。
- `synth` / `qor`：本地Yosys结构估计与受验证状态约束的JSON/Markdown报告，
  不属于Vivado物理证据。
- `check`：工具基线、记录、完整静态、短形式矩阵、仿真、展开与本地综合；独立 PoC 属于 `validate-workflow`。

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
- `.agents/skills/`：仓库级Codex RTL工作阶段指令。
- `workflow-smoke/`：不进入生产filelist的独立工具链PoC。

完整文档入口见[docs/README.md](docs/README.md)，本地流程见
[docs/workflow.md](docs/workflow.md)，项目约束见[AGENTS.md](AGENTS.md)。

## 本机配置

将`config/local.mk.example`复制为不进入Git的`config/local.mk`，在其中设置官方TRIKE
Reference C/KAT等机器相关路径。`external/trike-reference`只是本地配置的默认查找路径，
该外部Reference C目录不随仓库分发，可在`config/local.mk`中覆盖。
