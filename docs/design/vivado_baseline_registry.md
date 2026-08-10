# Vivado基线注册表

本表只回答“某个实现边界当前可以引用哪组物理证据”。精确资源和时序数字保存在
Vivado manifest；没有对应manifest的条目是待迁移的历史参考，不是当前源码签核。

| 实现边界 | 配置 | 物理状态 | 当前指针 | 备注 |
| --- | --- | --- | --- | --- |
| Decoder K=3 | L=16，历史`r` | 历史routed参考 | [探索24](optimization_exploration_history.md#24-复用全局k记录的-base_sign-作为最终判决) | 当前`r`待同条件重跑 |
| Decoder K=4，L=16 | C=1168，历史`r` | 历史routed参考 | [探索44](optimization_exploration_history.md#44-新r参数下l16-ram_t公共地址物理检查点与下一步排序) | 不与当前参数计算增减 |
| Decoder K=4，L=32 | C=1152，历史`r` | 历史routed参考 | [探索45](optimization_exploration_history.md#45-新r参数下l32-ram_t公共地址物理基线) | 不与当前参数计算增减 |
| Poly-inv | TRIKE-2窄I/O | 历史routed参考 | [阶段62](optimization_exploration_history.md#阶段62trike-kem公共核vivado首轮实现与pseudohash窄io封装2026-08-04) | 旧XDC边界，待manifest迁移 |
| Pseudohash | 32-byte窄I/O | 片内100 MHz通过，外部I/O未通过 | [阶段62](optimization_exploration_history.md#阶段62trike-kem公共核vivado首轮实现与pseudohash窄io封装2026-08-04) | 不是板级I/O签核 |
| Encaps | TRIKE-2窄I/O | 历史routed保留 | [阶段67](optimization_exploration_history.md#阶段67完整encaps首轮物理基线与关键路径寄存分段2026-08-05) | 片内100 MHz通过，工程XDC副本状态待统一 |
| KeyGen | TRIKE-2窄I/O | 修改后待复测 | [阶段72](optimization_exploration_history.md#阶段72keygen-sk-support顺序输出ram切断动态索引路径2026-08-06) | 首轮routed未达100 MHz |
| Decaps | TRIKE160，L=32，K=4，C=256 | 待正确宏复测 | [EXP-0082](../experiments/EXP-0082-decaps-route-config-audit.md) | 2026-08-10 GUI报告实际为统一最大几何，不作为基线 |
| Decaps误配置运行 | 顶层名为TRIKE160，实际统一最大几何 | rejected | [RUN-20260810-01](../../reports/vivado/manifests/RUN-20260810-01-trike-decaps.toml) | Routed 100 MHz通过，但profile与功能向量不一致 |

下一次任一顶层的Vivado运行都使用新manifest；不要继续把整组数字复制到本表。
