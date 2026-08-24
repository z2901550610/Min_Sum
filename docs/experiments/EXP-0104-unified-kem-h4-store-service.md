# EXP-0104：统一KEM H4结果存储服务

## 目标与假设

Encaps与Decaps在公开operation下串行运行，两阶段H4产生的support及三块padded dense error可使用一组
最大几何RAM。存储生命周期从H4 start延续至对应KEM事务done，不与另一operation重叠。

## 硬件边界

- `trike_h4_error_vector`支持本地store或外部store客户端，H4采样时序与读接口保持不变。
- 统一顶层实例化`r=106781,t=877`运行时几何store，命令携带公开`r/t/padded_r_bytes`。
- operation mux仲裁index写入、support读取和dense error读取；返回只送入活动stage。
- KeyGen support RAM、Decaps decoder error RAM及其他stage scratch RAM不属于本实验。

## 验证与量化结果

- 完整Verilator层次恰好1个`trike_error_support_store`，内部包含support RAM和dense error RAM。
- Encaps全外置组合CT/SS byte golden通过，固定2,378,447拍。
- Decaps postprocess外置SM3/sampler/store的有效与拒绝byte golden通过，固定257,417拍。
- H4固定及运行时几何、重加密reference、静态RTL门禁均通过。

## 结论

方案保留。H4持久结果存储按公开单发射生命周期复用；实际RAMB36/RAMB18、LUT/FF、WNS与
`cycles/Fmax`等待统一ASIC Vivado placed/routed报告。
