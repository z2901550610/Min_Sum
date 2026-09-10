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

## 锁定版本

| 工具 | 已验证版本 |
| --- | --- |
| Verilator | 5.051 devel, v5.050-277-g99c6f9ced |
| Verible | v0.0-4133-g873f559f |
| Slang | 11.0.448+e222e7dc0 |
| Yosys | 0.68+132；`yosys -m slang`可用 |
| SymbiYosys | 0.68 |
| Z3 | 4.15.5 |
| cocotb | 2.0.1 |
| PyYAML | 6.0.3 |
| pytest | 9.1.1 |
| Python | 3.12.10 |

主机辅助工具为 Homebrew 6.0.15、Apple Git 2.54.0、Apple clang 21.0.0 和
GNU Make 3.81。Python依赖及哈希由`uv.lock`锁定；日常 `make tool-versions` 记录差异并告警，缺失/失败的工具仍报错；显式 `make check-tool-versions` 和完整资格验证要求版本匹配。版本基线由
`config/rtl_toolchain.lock`和`scripts/check_tool_versions.py`执行，文档表格
不是程序化锁源。

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
