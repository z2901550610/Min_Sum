# Environment Audit Report

审计日期：2026-08-28

| 项目 | 结果 |
| --- | --- |
| 主机 | macOS 27.0，build 26A5421a，arm64，zsh |
| OSS CAD Suite | 2026-08-27 darwin-arm64，`~/tools/oss-cad-suite-20260827` |
| 稳定入口 | `~/tools/oss-cad-suite`，由`source scripts/eda-env.sh`选择 |
| Verilator | 5.051 devel，v5.050-277-g99c6f9ced，PASS |
| Slang | 11.0.448+e222e7dc0，PASS |
| Yosys + Slang | 0.68+132；`read_slang`可加载，PASS |
| SymbiYosys / solver | SBY 0.68；Z3 4.15.5，PASS |
| 备用 solver | Boolector 3.2.4；Bitwuzla 0.9.1，版本检查PASS |
| Verible | v0.0-4133-g873f559f，PASS |
| cocotb | 主机Python 3.12.10 + cocotb 2.0.1，Verilator PoC PASS |
| Surfer | 0.7.0，执行检查PASS |
| FST | `WAVES=1`生成`build/workflow-smoke/waves/dump.fst`，PASS |

执行证据：`make check-local-tools`与`make check-tool-versions`均通过。Suite自带
Python/cocotb的动态库问题、FST所需lz4参数和各证据边界记录在
`docs/known-limitations.md`。`config/rtl_toolchain.lock`是版本锁源，
`docs/environment.md`是维护入口。
