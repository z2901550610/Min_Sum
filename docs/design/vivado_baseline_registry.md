# Vivado基线注册表

本表只回答“某个实现边界当前可以引用哪组物理证据”。精确资源和时序数字保存在
Vivado manifest；没有对应manifest的条目是待迁移的历史参考，不是当前源码签核。

| 实现边界 | 配置 | 物理状态 | 当前指针 | 备注 |
| --- | --- | --- | --- | --- |
| Decoder K=3 | L=16，历史`r` | 历史routed参考 | [探索24](optimization_exploration_history.md#24-复用全局k记录的-base_sign-作为最终判决) | 当前`r`待同条件重跑 |
| Decoder K=4，L=16 | C=1168，历史`r` | 历史routed参考 | [探索44](optimization_exploration_history.md#44-新r参数下l16-ram_t公共地址物理检查点与下一步排序) | 不与当前参数计算增减 |
| Decoder K=4，L=32 | C=1152，历史`r` | 历史routed参考 | [探索45](optimization_exploration_history.md#45-新r参数下l32-ram_t公共地址物理基线) | 不与当前参数计算增减 |
| Poly-inv | TRIKE-2窄I/O，`DIGIT_W=16` | 待测 | 无 | 8-bit旧XDC结果不作为当前配置证据 |
| Pseudohash | 32-byte窄I/O | 片内100 MHz通过，外部I/O未通过 | [阶段62](optimization_exploration_history.md#阶段62trike-kem公共核vivado首轮实现与pseudohash窄io封装2026-08-04) | 不是板级I/O签核 |
| Encaps | TRIKE-2窄I/O，当前共享乘法调度 | 当前routed基线 | [RUN-20260813-01](../../reports/vivado/manifests/RUN-20260813-01-trike-encaps.toml) | 47,349 LUT，16.5 BRAM Tile，WNS +0.025 ns |
| KeyGen | TRIKE-2窄I/O，`DIGIT_W=16` | 待测 | 无 | [8-bit routed参考](../../reports/vivado/manifests/RUN-20260811-02-trike-keygen.toml)不作为当前配置证据 |
| 固定profile Decaps最大物理包络 | `trike_decaps_synth_top`，统一最大几何，L=32，K=4，C=256，`DIGIT_W=16` | 待测 | 无 | [8-bit routed参考](../../reports/vivado/manifests/RUN-20260811-01-trike-decaps.toml)不作为当前配置证据 |
| 运行时统一Decaps | `trike_decaps_runtime_synth_top`，四档，L=32，K=4，C=256，`DIGIT_W=16` | 待测 | 无 | 资源、布局布线与时序均待测 |
| 单发射统一KEM ASIC | `trike_kem_asic_top`，L=32，K=4，C=256 | routed诊断，100 MHz未收敛 | [RUN-20260825-04](../../reports/vivado/manifests/RUN-20260825-04-trike-kem-asic-gui.toml) | 655 BRAM Tile；internal WNS -3.914 ns；采样索引映射1个RAMB36；源码revision与defines未记录 |
| 统一Decaps五档参考 | 五档统一最大几何，L=32，K=4，C=256 | superseded routed参考 | [RUN-20260810-01](../../reports/vivado/manifests/RUN-20260810-01-trike-decaps.toml) | 63,228 LUT，635 BRAM Tile，WNS +0.033 ns |

下一次任一顶层的Vivado运行都使用新manifest；不要继续把整组数字复制到本表。
