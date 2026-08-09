# Min_Sum RTL

本仓库实现公开参数决定固定调度的BIKE/MDPC Min-Sum译码器与TRIKE KEM RTL。
本地功能验证、形式证明与Vivado物理实现是独立证据层。

## 快速入口

```sh
make check-local-tools
make ci-fast
make ci-smoke
make ci-nightly
make ci-kem-reference
```

- `ci-fast`：工具锁、记录结构、格式/lint、短形式矩阵、单元和集成测试。
- `ci-smoke`：加入固定seed的BIKE和TRIKE K=3/K=4随机点。
- `ci-nightly`：加入扩展形式参数与多参数、多seed回归。
- `ci-kem-reference`：使用机器本地的官方TRIKE KAT/Reference C执行KeyGen、Encaps和Decaps
  byte-for-byte发布门禁；该入口明确不属于日常快速回归。

Vivado实现入口为`make vivado-impl-trike-{poly-inv,pseudohash,encaps,keygen,decaps}`。
资源与时序结论只使用同器件、Vivado版本、XDC、参数和报告阶段的可比结果。

## 目录

- `rtl/`：可综合SystemVerilog RTL。
- `tb/`：定向、reference和集成testbench。
- `formal/`：SymbiYosys proof/cover harness。
- `filelists/`：实现顶层的规范源文件顺序。
- `scripts/`：生成、验证和Vivado入口。
- `docs/`：成品设计、验证、实验和项目工作流。
- `reports/vivado/manifests/`：版本化的Vivado运行摘要；原始报告保存在外部报告根目录。

完整文档入口见[docs/README.md](docs/README.md)，项目约束见[AGENTS.md](AGENTS.md)。

## 本机配置

将`config/local.mk.example`复制为不进入Git的`config/local.mk`，在其中设置官方TRIKE
Reference C/KAT等机器相关路径。仓库默认使用`external/trike-reference`。
