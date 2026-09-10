# Vivado基线注册表

本表只回答“某个实现边界当前可以引用哪组物理证据”。精确条件与原始报告位置保存在
Vivado manifest；没有对应manifest的条目是历史参考，不是当前源码签核。

当前折叠乘法、求逆、稠密Encaps与KEM集成均未完成同条件物理验收。下表digit配置仅指旧检查点。
同条件比较要求：器件、Vivado版本、XDC、参数、defines、存储几何与报告阶段一致。

| 实现边界 | 配置 | 物理状态 | 证据 | 关键数字 |
| --- | --- | --- | --- | --- |
| Decoder K=3 | `L=16`，历史`r`，`COLS_PER_TILE=1168`，`xc7k355tffg901-2L`，Vivado 2023.2，100 MHz | 历史routed参考 | 探索阶段13/24 | 26,637 LUT；11,083 FF；9,133 Slice；473.5 BRAM Tile（416×RAMB36+115×RAMB18）；整体WNS +0.451 ns；主时钟WNS +0.862 ns |
| Decoder K=4，L=16 | `C=1168`，新`r`，K=4，同器件/工具/时钟 | 历史routed参考 | 探索阶段44 | 26,034 LUT；11,365 FF；9,286 Slice；537.5 BRAM Tile（480+115）；整体WNS +0.611 ns；主时钟WNS +0.667 ns；TRIKE512固定周期 16,463,236 |
| Decoder K=4，L=32 | `C=1152`，新`r`，K=4，同器件/工具/时钟 | 历史routed参考 | 探索阶段45 | 45,309 LUT；20,802 FF；15,406 Slice；561.5 BRAM Tile（512+99）；整体/主时钟WNS +0.439 ns；TRIKE512固定周期 8,538,564（85.38564 ms @100 MHz） |
| Poly-inv | TRIKE-2窄I/O，`DIGIT_W=16` | 待测 | 无 | 8-bit旧XDC结果不作为当前配置证据 |
| Pseudohash | 32-byte窄I/O | 片内100 MHz通过，外部I/O未通过 | 探索阶段62 | 窄I/O wrapper routed：9,711 LUT，8,767 FF，0 BRAM Tile，83 Bonded IOB；整体setup WNS -2.008 ns（含2 ns output delay）；register-to-register WNS +0.883 ns |
| Encaps | TRIKE-2窄I/O，2026-08-13共享乘法检查点 | 历史routed参考 | [RUN-20260813-01](../../reports/vivado/manifests/RUN-20260813-01-trike-encaps.toml) | 47,349 LUT，16.5 BRAM Tile，WNS +0.025 ns |
| KeyGen | TRIKE-2窄I/O，`DIGIT_W=16` | 待测 | 无 | [8-bit routed参考](../../reports/vivado/manifests/RUN-20260811-02-trike-keygen.toml)不作为当前配置证据 |
| 固定profile Decaps最大物理包络 | `trike_decaps_synth_top`，统一最大几何，L=32，K=4，C=256，`DIGIT_W=16` | 待测 | 无 | [8-bit routed参考](../../reports/vivado/manifests/RUN-20260811-01-trike-decaps.toml)不作为当前配置证据 |
| 运行时统一Decaps | `trike_decaps_runtime_synth_top`，四档，L=32，K=4，C=256，`DIGIT_W=16` | 待测 | 无 | 资源、布局布线与时序均待测 |
| 单发射统一KEM ASIC | `trike_kem_asic_top`，L=32，K=4，C=256 | routed诊断，100 MHz未收敛 | [RUN-20260825-04](../../reports/vivado/manifests/RUN-20260825-04-trike-kem-asic-gui.toml) | 655 BRAM Tile；internal WNS -3.914 ns；采样索引映射1个RAMB36；源码revision与defines未记录 |
| 统一Decaps五档参考 | 五档统一最大几何，L=32，K=4，C=256 | superseded routed参考 | [RUN-20260810-01](../../reports/vivado/manifests/RUN-20260810-01-trike-decaps.toml) | 63,228 LUT，635 BRAM Tile，WNS +0.033 ns |

统一KEM后续SM3扇出诊断见[RUN-20260826-01](../../reports/vivado/manifests/RUN-20260826-01-trike-kem-asic-sm3-fanout.toml)，
因provenance不完整且时序未收敛，不构成当前基线。其他历史细节按[Git入口](../experiments.md)查阅。
新运行使用独立manifest；本表仅维护证据定位与关键结论。
