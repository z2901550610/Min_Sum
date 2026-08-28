# 文档索引

本目录包含译码器设计说明、验证说明、图文件和 RTL/Vivado 实现规范。

## 设计文档

- [BIKE syndrome 输入 min-sum 译码器](design/bike_decoder.md)：参数宏、构建配置、顶层端口和译码语义速查。
- [译码器硬件设计说明](design/decoder_hardware_design_guide.md)：译码器数据通路、存储组织、K-sign、固定调度和周期预算的完整设计说明。
- [RTL实现状态](design/implementation_status.md)：当前配置、数据通路、RAM生命周期、固定周期、验证状态和证据边界。
- [Vivado基线注册表](design/vivado_baseline_registry.md)：指向各实现顶层的有效基线、历史参考和待测边界。
- [实验索引](experiments/index.md)：以一行一实验记录架构、RAM、周期、资源与时序探索。
- [历史探索归档](design/optimization_exploration_history.md)：阶段1至81的冻结历史记录。
- [RTL 命名规范](design/naming_conventions.md)：坐标、buffer、端口和 debug 信号命名规则。

## 项目管理

- [项目工作流](project_workflow.md)：Git、实验、Vivado报告、基线和生成物的记录边界。
- [本地SystemVerilog工作流](workflow.md)：环境入口、统一Make目标、PoC、真实RTL切入和证据边界。
- [本地RTL环境基线](environment.md)：安装布局、锁定工具版本和已验证能力。
- [已知限制](known-limitations.md)：cocotb/FST兼容层、Yosys估计和物理实现边界。
- [复位与时钟契约](reset-and-clock.md)：生产RTL的复位、时钟、CDC和报告边界速查。
- [Vivado manifest规范](../reports/vivado/manifests/README.md)：存放在`D:/trike_reports`的原始报告如何与仓库中的结构化结果对应。

## 验证和结果

- [译码器验证](verification/decoder_verification.md)：回归入口、随机用例、检查项、日志、格式化和 lint。
- [验证矩阵](verification/validation_matrix.md)：把文档、RTL、RAM/调度、参数和KEM改动映射到最小必要门禁。
- [量化模型](verification/quantization_model.md)：C 模型、量化参数、fixtures 和 sweep 流程。
- [K=4 Min-Sum 与 TRIKE BF 的 FLS 外推](verification/k4_minsum_trike_bf_fls_extrapolation.md)：外推方法、95% 置信区间、K=4 候选 `r` 和适用边界。

## 图文件

- [figures/](figures/)：图源文件和导出的 SVG/PNG/PDF 文件。

## RTL 和 Vivado 规范

- [Vivado SystemVerilog RTL 规范](vivado_systemverilog_guidelines.md)：RTL、testbench、Vivado、复位、RAM 推断、CDC 和审查规则。

## 参考资料

- [Cai and Zhang 2023 low-complexity parallel min-sum MDPC decoder](references/cai-zhang-2023-low-complexity-parallel-min-sum-mdpc-decoder.pdf)

## 归档

- [归档文件](archive/README.md)：不再使用的历史文档和图文件，仅供历史参考。
