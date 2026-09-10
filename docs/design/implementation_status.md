# 验证状态与限制

架构事实分别维护在[Decoder设计](decoder_hardware_design_guide.md)、
[KEM公共核](trike_kem_common_cores.md)和[折叠乘法/求逆](trike_karatsuba_fold.md)。
本页只记录验证范围和未解决限制；历史结果不自动适用于后续源码。

## 验证范围

| 边界 | 已有证据 | 限制 |
| --- | --- | --- |
| Decoder | 历史L32/K4四档seed-1均residual=0、exact=1，固定周期与预算一致 | 不构成DFR结论；周期公式见Decoder设计 |
| 当前乘法/求逆 | 小几何固定轨迹、runtime、官方参考及最小/最大乘法几何通过 | 具体检查点及周期见折叠设计；无整个乘法器formal或Vivado验收 |
| KeyGen/Encaps | 共享服务、byte golden和固定周期证据见公共核；Encaps UV/基础/共享/wrapper参考通过 | 不外推为全参数KEM通过 |
| 运行时Decaps | EXP-0123八拍稀疏检查点下TRIKE160/256正常及c2拒绝参考通过 | 当时384 CANCELLED、512 NOT_RUN；当前六拍路径完整端到端未复测 |
| 物理实现 | [注册表](vivado_baseline_registry.md)定位历史RUN与原始报告 | 当前折叠及KEM集成同条件Vivado NOT_RUN；片内时序不等于板级I/O时序 |

旧验证全文按[Git历史入口](../experiments.md)查阅。命令与证据规则见[工作流](../workflow.md)。

## 当前限制

- 官方TRIKE-2的`r=15581`与项目Min-Sum profile的`r=12589`是两个验证域；官方端到端Decaps KAT需要
  单独建立`r=15581`译码profile及DFR证据。
- `trike_kem_asic_top`包含公开operation单发射、全局SM3、H1/H2/H3向量、固定重量采样、H4结果存储和
  普通多项式乘法共享；KeyGen算术、序列化及其他跨阶段scratch RAM生命周期分配是独立资源收敛边界。
- `trike_decaps_runtime_synth_top`通过2-bit公开profile连接最大几何输入存储、运行时syndrome、统一decoder、
  decoder后检查和postprocess。四档具备有效与`c2`隐式拒绝完整KEM golden；u/v非收敛RTL深测覆盖TRIKE160，
  其余三档由软件golden和分层运行时RTL测试覆盖。
- 运行时综合入口没有Vivado placed/routed结果；EXP-0084的资源与时序只适用于固定profile
  `trike_decaps_synth_top`最大物理包络。
- 当前Min-Sum端到端向量证明功能闭环、固定周期和隐式拒绝，不构成有限样本之外的DFR/FLS结论。
- KeyGen、Encaps和完整Decaps的板级接口还需要真实pin与I/O delay约束。
