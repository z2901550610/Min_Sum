# 本地 RTL 环境基线

审计日期：2026-08-28；主机：macOS 27.0（26A5421a），Apple Silicon arm64，
默认 shell 为 zsh。

## 安装布局

- OSS CAD Suite 版本目录：`~/tools/oss-cad-suite-20260827`
- 稳定选择链接：`~/tools/oss-cad-suite`
- 项目 Python 环境：`.venv`，由`pyproject.toml`和`uv.lock`创建
- 仓库环境入口：`./eda <command>`；交互终端仍可`source scripts/eda-env.sh`
- Verible：已有主机安装，由环境入口保留在 PATH
- 波形查看器不属于必需门禁；FST由workflow smoke生成后可用任意兼容查看器检查
- Python/cocotb：项目`.venv`中的 Python 3.12.10 与 cocotb 2.0.1

## 版本来源

工具版本以[工具锁](../config/rtl_toolchain.lock)为唯一基线，Python依赖以
[uv.lock](../uv.lock)为准。`./eda make tool-versions`查看实际版本并告警差异；
`./eda make check-tool-versions`要求版本匹配。缺失或执行失败的工具均报错。

## 已验证能力

- `make check-local-tools`：包含Slang frontend加载、当前SBY任务使用的Z3和cocotb。
- `make check-tool-versions`：锁文件全部匹配。
- OSS CAD Suite 的 Verilator/Slang/Yosys/SBY/Z3 可运行生产静态与 formal gate。
- 项目`.venv`中的cocotb可驱动Suite Verilator；可选FST生成由调用者通过
  `LZ4_PREFIX`显式选择lz4头文件和库。

## 工具升级

先核对实际可执行文件与安装来源，再比较官方版本；不因名称或stable标签把已验证的较新开发版降级。
只升级任务选定的工具，手动安装保留可恢复版本。安装后更新`config/rtl_toolchain.lock`；
只有Python依赖有意改变时才修改`pyproject.toml`并更新`uv.lock`。
调试用受影响的lint、proof和最小仿真；接受新工具链基线前完成`make check`。
格式或诊断变化做有范围的修正，不恢复全局忽略错误。
Vivado不随本地开源工具刷新；用新Vivado作物理比较前重跑同条件实现。
命令入口与证据边界以[工作流](workflow.md)为准。

## 已知限制

- OSS CAD Suite 2026-08-27 自带 cocotb/Python 在本机加载`libpython3.11.dylib`
  时无法解析相对`libintl.8.dylib`。环境入口使用`uv.lock`创建的项目 Python
  3.12/cocotb 2.0.1环境；EDA可执行程序仍来自 Suite。
- Suite Verilator 的 FST 构建需要 Homebrew lz4 的显式 include/link 参数。
  `workflow-smoke/Makefile`仅在`WAVES=1`时加入这些参数。
- `make synth`和`make qor`提供 Yosys 结构估计，不验证 Vivado XPM/RAMB映射、
  布局、布线、时序或硬件功能。`make qor`当前固定报告组合模块`kem_ct_compare_select`，
  是报告链路验证，不是译码器QoR基线。
- PoC formal 的时钟是 SymbiYosys global clock；harness wire 无普通RTL驱动是建模边界。
- 当前本地链路不运行 Vivado；物理实现继续在 Windows/Vivado 流程执行并以 run manifest 回传。
- 本仓库不引入 ASIC synthesis、place-and-route 或 signoff backend。
