# 已知限制

- OSS CAD Suite 2026-08-27 自带 cocotb/Python 在本机加载`libpython3.11.dylib`
  时无法解析相对`libintl.8.dylib`。环境入口使用主机 Python 3.12 和 cocotb
  2.0.1；EDA可执行程序仍来自 Suite。该组合已由独立 PoC 验证。
- Suite Verilator 的 FST 构建需要 Homebrew lz4 的显式 include/link 参数。
  `workflow-smoke/Makefile`仅在`WAVES=1`时加入这些参数。
- `make synth`和`make qor`提供 Yosys generic/xc7-oriented 结构估计，不验证
  Vivado XPM/RAMB映射、布局、布线、时序或硬件功能。
- `make qor`当前固定报告无状态、组合的`kem_ct_compare_select`，因此 FF、RAMB、
  DSP为零，latency/throughput为`null`。它验证报告链路，不是译码器QoR基线。
- PoC formal 的时钟是 SymbiYosys global clock；Yosys会报告该 harness wire
  无普通RTL驱动。这是 harness 建模边界，不是生产 RTL warning。
- 当前本地链路不运行 Vivado；物理实现继续在已有 Windows/Vivado 流程执行并
  以 run manifest 回传。板级 I/O 时序需要完整输入/输出约束。
- 本计划没有引入 ASIC synthesis、place-and-route 或 signoff backend。
- 仓库根目录已有的 K-sign 图表/CSV 属于历史研究证据，来源迁移需独立核对；
  本次工作未重写或移动这些用户资产。
