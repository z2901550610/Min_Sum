# EXP-0103：统一KEM固定重量采样服务

## 目标与假设

KeyGen秘密support、Encaps H4和Decaps重加密H4由公开operation串行，三者的Generate(4 byte)与
固定重量索引生成可使用一个最大几何运行时服务，不合并持久结果RAM。

## 硬件边界

- 服务命令携带公开`length/weight`和DRNG V/C/reseed state，返回固定数量index与最终state。
- 最大物理几何为`length=3*106781`、`weight=877`；KeyGen使用`15581/35`，Encaps使用`46743/263`。
- 各stage保留seed Instantiate控制、KeyGen弱密钥检测/support RAM和H4 dense error RAM。
- sampler的SM3请求接入全局压缩服务，客户端只由锁存operation选择。

## 验证与量化结果

- 完整层次恰好1个`trike_drng_weight_sampler`和1个`trike_fixed_weight_sampler`。
- KeyGen全外置组合PK/SK golden通过，固定53,995,036拍。
- Encaps全外置组合CT/SS golden通过，固定2,378,447拍。
- Decaps postprocess外置sampler/SM3有效与拒绝golden通过，固定257,417拍。

## 结论

方案保留。三条固定重量采样计算链收敛为单服务，结果RAM生命周期不变；实际LUT/FF/BRAM、WNS与
`cycles/Fmax`等待统一ASIC Vivado placed/routed报告。
