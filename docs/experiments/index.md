# 实验决策索引

下一个实验ID：`EXP-0124`。

本页按“可比较假设/实验系列”汇总结论，不再逐个列出每次小修改。已有
`EXP-0082`至`EXP-0123`的单项文档和 Vivado RUN manifest 保留原 ID，作为需要时
下钻的历史证据。TRIKE KEM 的依赖和下一门禁见
[优化路线图](../design/trike_kem_optimization_roadmap.md)。

| 实验系列 | 时间 | 核心问题与范围 | 已形成的证据 | 当前结论 | 下钻入口 |
| --- | --- | --- | --- | --- | --- |
| LEGACY-0001–0081 | 2026-07-10至08-09 | Decoder、K-sign、RAM和早期TRIKE KEM探索 | 历史功能、周期及部分物理记录 | `superseded`，仅作设计来源 | [冻结归档](../design/optimization_exploration_history.md) |
| EXP-0082–0086 | 2026-08-10至08-13 | 统一Decaps配置收敛，并建立Decaps、KeyGen、Encaps物理参考 | 四档功能门禁；三个窄I/O/统一顶层 routed run | EXP-0084/0085/0086为保留参考；0082被后续四档配置替代 | [基线注册表](../design/vivado_baseline_registry.md) / [EXP-0084](EXP-0084-four-profile-decaps-route.md) |
| EXP-0087–0098 | 2026-08-13至08-19 | 四档运行时Decaps从输入、存储、syndrome、support到postprocess和端到端闭环 | 分层golden、固定周期、四档byte对拍；双行residual扫描 | RTL架构`retained`；运行时顶层物理实现仍待测 | [实现状态](../design/implementation_status.md) / [EXP-0097](EXP-0097-four-profile-runtime-decaps-golden.md) |
| EXP-0099 | 2026-08-20 | 16-bit digit稠密乘法替换串行基础实现 | KeyGen及四档Decaps golden/固定周期；poly-inv与KeyGen routed | `retained`，作为后续算术优化起点 | [详情](EXP-0099-kem-dense-mul-digit16.md) |
| EXP-0100–0110 | 2026-08-24 | 单发射统一KEM服务和RAM生命周期复用 | 单SM3、共享乘法/H123/sampler/store，KeyGen持久RAM与support视图分层验证 | 架构`retained`；统一顶层物理收敛交给后续系列 | [统一KEM设计](../design/trike_kem_common_cores.md) / [EXP-0100](EXP-0100-unified-kem-asic-sm3.md) |
| EXP-0111–0114 | 2026-08-25至08-26 | 统一KEM首轮route的除法链、采样索引RAM和SM3扇出诊断 | H4无除法映射、1个RAMB36索引存储、SM3局部扇出；多次routed诊断 | 0111 `rejected`；0112/0113 `retained`；0114物理结论`pending` | [EXP-0111](EXP-0111-unified-kem-asic-route.md) / [EXP-0114](EXP-0114-sm3-result-local-fanout.md) |
| EXP-0115–0120 | 2026-08-26至08-28 | 稠密乘法Comba/base宽度、Karatsuba层级和短求逆链 | 定向/官方golden、固定周期、Yosys矩阵；K1/K2和短链routed诊断 | 候选系列`pending`，已形成周期/资源Pareto但未进入完整KeyGen基线 | [优化路线图](../design/trike_kem_optimization_roadmap.md) / [EXP-0120](EXP-0120-trike2-short-inversion-chain.md) |
| EXP-0121 | 2026-08-28 | compare-select三元mux候选 | 定向仿真与W1/8/256 proof/cover；Yosys无收益 | `rejected`，保留显式mask | 本页结论 |
| EXP-0122 | 2026-08-28 | Bernstein-Yang divstep架构锚点 | r13穷举、r15581 golden、s1 formal、s8更新验证 | `pending`，下一门是全长BRAM扫描核 | [详情](EXP-0122-trike-bernstein-yang-divstep-anchor.md) |
| EXP-0123 | 2026-09-07 | 一层Karatsuba子积直接循环折叠，删除完整product RAM | 边界/固定轨迹、10个全尺寸算术样本、KEM reference及160/256 runtime、Yosys估计 | `pending`，求逆/统一服务已迁移；物理待验收 | [详情](EXP-0123-trike-k1-cyclic-fold.md) |

## 新实验的记录门槛

- 普通RTL修改、bug修复、格式调整和等价重构只由Git与测试记录。
- 一个明确、可比较的架构/QoR假设或连续实验系列只分配一个EXP ID；同一假设下的
  中间实现、参数扫点和多次验证不重复建EXP。
- 只有比较问题、硬件边界或决策目标实质改变时才建立新EXP。
- 每次Vivado执行仍分配独立RUN ID和manifest；RUN数量不决定EXP数量。
- 需要保存失败原因、RAM生命周期、周期边界或关键定量结果时才创建单项EXP文档。
