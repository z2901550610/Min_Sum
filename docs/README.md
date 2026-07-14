# 文档索引

本目录包含译码器设计说明、验证说明、图文件和 RTL/Vivado 实现规范。

## 设计文档

- [BIKE syndrome 输入 min-sum 译码器](design/bike_decoder.md)：顶层概览、参数、接口和译码语义。
- [译码器架构](design/decoder_architecture.md)：模块划分、数据通路、存储组织和迭代流程。
- [Tile 译码器设计](design/tile_decoder_design.md)：tile 几何、guard 规则、存储组织、C2V 和 V2C。
- [译码调度](design/decoder_schedule.md)：固定窗口调度器计数器、可见状态和周期预算。
- [K-sign 译码器设计](design/k_sign_decoder_design.md)：压缩符号更新设计和集成说明。
- [RTL 实现状态与 Vivado 基线](design/implementation_status.md)：实现配置、存储组织、固定周期、资源占用、时序和验证结果。
- [译码器架构与资源优化探索记录](design/optimization_exploration_history.md)：按实施顺序记录已评估方案、实现结果和取舍结论。
- [RTL 命名规范](design/naming_conventions.md)：坐标、buffer、端口和 debug 信号命名规则。

## 验证和结果

- [译码器验证](verification/decoder_verification.md)：回归入口、随机用例、检查项、日志、格式化和 lint。
- [参数结果](verification/parameter_results.md)：参数运行摘要和结果模板。
- [量化模型](verification/quantization_model.md)：C 模型、量化参数、fixtures 和 sweep 流程。

## 图文件

- [figures/](figures/)：图源文件和导出的 SVG/PNG/PDF 文件。

## RTL 和 Vivado 规范

- [Vivado SystemVerilog RTL 规范](vivado_systemverilog_guidelines.md)：RTL、testbench、Vivado、复位、RAM 推断、CDC 和审查规则。

## 参考资料

- [Cai and Zhang 2023 low-complexity parallel min-sum MDPC decoder](references/cai-zhang-2023-low-complexity-parallel-min-sum-mdpc-decoder.pdf)
