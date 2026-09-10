# 文档入口

按本次问题选择一份主文档；不默认遍历历史。当前设计、验证状态、未来候选和旧证据分别维护，
不在各处重复同步。文档写入门槛见[记录规则](project_workflow.md)。

## 日常入口

| 要解决的问题 | 主文档 |
| --- | --- |
| 怎样运行工具、选检查、何时停止 | [工作流](workflow.md) |
| 当前实现与验证到了哪里 | [实现状态](design/implementation_status.md) |
| 某方向是否已经踩过坑 | [错题与历史摘要](experiments/index.md) |
| 下一步有哪些值得保留的候选 | [KEM路线图](design/trike_kem_optimization_roadmap.md) |
| 哪个物理结果可作为基线 | [Vivado注册表](design/vivado_baseline_registry.md)与[manifest规范](../reports/vivado/manifests/README.md) |

## 按需设计与方法参考

以下文档保存技术内容，不充当任务日记；仅在对应接口、实现或方法改变时更新所属部分。

| 主题 | 内容归属 |
| --- | --- |
| Decoder硬件 | [硬件设计说明](design/decoder_hardware_design_guide.md)：数据通路、K-sign、RAM与固定调度；[BIKE速查](design/bike_decoder.md)：BIKE参数和接口 |
| TRIKE KEM实现 | [公共核](design/trike_kem_common_cores.md)：共享服务、接口和生命周期；[直接折叠](design/trike_karatsuba_fold.md)：乘法推导、周期和复现 |
| KEM算法教学 | [BIKE/TRIKE机制](design/bike_trike_kem_hardware_mechanism.md)：数学语义与核分层，不作为当前实例或验证状态清单 |
| 编码约束 | [命名](design/naming_conventions.md)、[复位/时钟](reset-and-clock.md)、[Vivado RTL规范](vivado_systemverilog_guidelines.md) |
| 环境 | [工具基线](environment.md)、[已知限制](known-limitations.md)；执行命令以工作流为准 |
| 验证方法 | [Decoder验证](verification/decoder_verification.md)、[量化模型](verification/quantization_model.md)、[FLS外推](verification/k4_minsum_trike_bf_fls_extrapolation.md)；保留trials、置信界与适用范围 |
| 图与文献 | [图源及数据](figures/README.md)、[Cai与Zhang论文](references/cai-zhang-2023-low-complexity-parallel-min-sum-mdpc-decoder.pdf) |

## 历史文档的归属

所有历史材料先经[错题与主题摘要](experiments/index.md)查找，命中具体问题再下钻。

| 历史集合 | 已提炼到哪里 | 原文用途 |
| --- | --- | --- |
| 冻结阶段1–81 | 实验索引的错题与主题摘要；现役Decoder/KEM设计 | [冻结原文](design/optimization_exploration_history.md)仅核查原配置、数值和取舍，不追加阶段 |
| EXP-0082至0126（含索引内0121） | 实验索引按配置基线、Decaps、共享服务、算术分组 | [实验目录说明](experiments/README.md)；原ID和RUN引用保留，历史“当前”不代表今日状态 |
| 已归档架构、调度、K-sign、tile文档 | Decoder硬件设计说明 | [归档索引](archive/README.md)，不再平行维护 |
| 已归档参数结果、硬件优化调研 | 验证方法、实现状态、候选路线图 | 原始参数/调研快照，不视为当前结论 |
| 旧图和恢复素材 | 图文件索引中的现役素材 | 归档保留，不要求重新导出 |

新增内容先更新已有归属，不因新任务新建同类文档。旧证据不为压缩篇幅改写数字或覆盖原结论。
