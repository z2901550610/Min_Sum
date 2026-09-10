# 错题与历史证据索引

下一个实验ID：`EXP-0127`。

默认只查本页相关主题；旧记录中的“当前”均指记录当时，不能作为今日RTL或物理验收。
现役设计见[实现状态](../design/implementation_status.md)，候选见[路线图](../design/trike_kem_optimization_roadmap.md)。
记录门槛只维护在[项目记录规则](../project_workflow.md)。

## 错题本

下表是已有记录的归纳，未重新运行实验。历史物理数字保留原配置范围，不能跨器件或检查点外推。

| 方向与条件 | 放弃原因和证据 | 何时值得重试 |
| --- | --- | --- |
| K=3 base_sign与slot 0打包 | 省16 BRAM Tile但整体WNS降0.093 ns，当时性能优先，撤回；[旧史§11](../design/optimization_exploration_history.md) | 存储优先级或时序余量改变 |
| ram_t双缓冲地址交织 | BRAM Tile不变，LUT增342；[旧史§12](../design/optimization_exploration_history.md) | 实际原生RAM几何能减少Tile |
| K-sign valid并入统一比较键 | LUT增164、WNS降0.339 ns；[旧史§13](../design/optimization_exploration_history.md) | 比较树或映射方式改变 |
| correction线性计数/K RAM预译码 | 当时实现时序退化，撤回；[旧史§15–16](../design/optimization_exploration_history.md) | 能切断实际关键路径并同条件复测 |
| delta pair合并到单块TDP | 同拍2读1写需三个独立地址，双端口无法维持吞吐；[旧史§18](../design/optimization_exploration_history.md) | 调度/端口预算改变，或允许固定额外周期 |
| ram_m拆成9+9 bit | K=3实测BRAM反增，未再跑K=4；[旧史§27](../design/optimization_exploration_history.md) | 原生宽深几何或端口绑定改变 |
| ram_accum公共地址广播 | L16/L32均时序退化，资源收益不稳定；[旧史§46](../design/optimization_exploration_history.md) | 布局/扇出机制改变；不能套用ram_t收益 |
| 共享H4变量除法/取模寻址 | 首轮统一KEM出现189级逻辑路径，不能形成100 MHz基线；[EXP-0111](EXP-0111-unified-kem-asic-route.md) | 改为无深除法映射并重新route；原报告provenance不完整 |
| 64-bit base递归depth 2/3 | Yosys独立base LC为2690/3312，高于depth 1的1766；[EXP-0117](EXP-0117-dense-base-karatsuba.md) | base宽度/器件/重组结构改变；仅本地估计 |
| EXP-0121 compare-select三元mux | 定向及proof/cover通过，Yosys无收益，保留显式mask | 综合映射或结构改变后再测，不能据此声称物理等价 |
| 直接折叠的双读RAM绑定 | 求逆RAMB36本地估计4→7，原地XOR/恢复回到4；[EXP-0123](EXP-0123-trike-k1-cyclic-fold.md) | 端口结构或原生RAM成本改变 |

## 历史主题摘要

成功结果保留为设计来源，不逐步扩写；下面覆盖冻结阶段1–81与已有EXP系列。

| 实验系列 | 时间 | 核心问题与范围 | 已形成的证据 | 历史结论（仅适用于原检查点） | 下钻入口 |
| --- | --- | --- | --- | --- | --- |
| LEGACY-0001–0081 | 2026-07-10至08-09 | Decoder、K-sign、RAM和早期TRIKE KEM探索 | 历史功能、周期及部分物理记录 | `superseded`，仅作设计来源 | [冻结归档](../design/optimization_exploration_history.md) |
| EXP-0082–0086 | 2026-08-10至08-13 | 统一Decaps配置收敛，并建立Decaps、KeyGen、Encaps物理参考 | 四档功能门禁；三个窄I/O/统一顶层 routed run | EXP-0084/0085/0086为保留参考；0082被后续四档配置替代 | [基线注册表](../design/vivado_baseline_registry.md) / [EXP-0084](EXP-0084-four-profile-decaps-route.md) |
| EXP-0087–0098 | 2026-08-13至08-19 | 四档运行时Decaps从输入、存储、syndrome、support到postprocess和端到端闭环 | 分层golden、固定周期、四档byte对拍；双行residual扫描 | 该检查点架构`retained`；运行时顶层物理实现仍待测 | [实现状态](../design/implementation_status.md) / [EXP-0097](EXP-0097-four-profile-runtime-decaps-golden.md) |
| EXP-0099 | 2026-08-20 | 16-bit digit稠密乘法替换串行基础实现 | KeyGen及四档Decaps golden/固定周期；poly-inv与KeyGen routed | `retained`，作为后续算术优化起点 | [详情](EXP-0099-kem-dense-mul-digit16.md) |
| EXP-0100–0110 | 2026-08-24 | 单发射统一KEM服务和RAM生命周期复用 | 单SM3、共享乘法/H123/sampler/store，KeyGen持久RAM与support视图分层验证 | 架构`retained`；统一顶层物理收敛交给后续系列 | [统一KEM设计](../design/trike_kem_common_cores.md) / [EXP-0100](EXP-0100-unified-kem-asic-sm3.md) |
| EXP-0111–0114 | 2026-08-25至08-26 | 统一KEM首轮route的除法链、采样索引RAM和SM3扇出诊断 | H4无除法映射、1个RAMB36索引存储、SM3局部扇出；多次routed诊断 | 0111 `rejected`；0112/0113 `retained`；0114物理结论`pending` | [EXP-0111](EXP-0111-unified-kem-asic-route.md) / [EXP-0114](EXP-0114-sm3-result-local-fanout.md) |
| EXP-0115–0120 | 2026-08-26至08-28 | 稠密乘法Comba/base宽度、Karatsuba层级和短求逆链 | 定向/官方golden、固定周期、Yosys矩阵；K1/K2和短链routed诊断 | 候选系列`pending`，已形成周期/资源Pareto但未进入完整KeyGen基线 | [优化路线图](../design/trike_kem_optimization_roadmap.md) / [EXP-0120](EXP-0120-trike2-short-inversion-chain.md) |
| EXP-0121 | 2026-08-28 | compare-select三元mux候选 | 定向仿真与W1/8/256 proof/cover；Yosys无收益 | `rejected`，保留显式mask | 本页结论 |
| EXP-0122 | 2026-08-28 | Bernstein-Yang divstep架构锚点 | r13穷举、r15581 golden、s1 formal、s8更新验证 | `pending`，下一门是全长BRAM扫描核 | [详情](EXP-0122-trike-bernstein-yang-divstep-anchor.md) |
| EXP-0123 | 2026-09-07 | 一层Karatsuba子积直接循环折叠，删除完整product RAM | 边界/固定轨迹、10个全尺寸算术样本、KEM reference及160/256 runtime、Yosys估计 | `pending`，求逆/统一服务已迁移；物理待验收 | [详情](EXP-0123-trike-k1-cyclic-fold.md) |
| EXP-0124 | 2026-09-09 | 稀疏RMW重叠及同址转发 | 固定6拍/support-word，本地golden/代表几何 | 功能保留，物理未测 | [证据](EXP-0124-sparse-rmw-overlap.md) |
| EXP-0125 | 2026-09-09 | Encaps四次稠密乘法复用error RAM | UV、CT/SS及共享/wrapper参考 | 本地保留，物理未测 | [证据](EXP-0125-encaps-dense-error-stream.md) |
| EXP-0126 | 2026-09-09 | 二层直接折叠模型与预算 | 软件模型通过，RTL/Yosys/Vivado未测 | 候选未采用，不是失败 | [证据](EXP-0126-k2-direct-fold-model.md) |

旧文档按需查阅，不新增连续阶段；正式RUN需要新EXP时在本节加一行即可。
