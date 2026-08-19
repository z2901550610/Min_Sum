# EXP-0088：Decaps四档最大几何输入存储

- 日期：2026-08-13
- 状态：`retained`
- 配置：`TRIKE_UNIFIED_PARAMS`，四档项目Min-Sum参数，8-bit `SK || CT`

## 目标与边界

把EXP-0087的运行时输入loader连接到最大档物理存储生命周期，为syndrome和postprocess提供统一读口。
该实验验证字段存储与回读，不包含运行时syndrome、译码后处理或四档端到端Decaps。

## 实现

`trike_decaps_input_store`按TRIKE512最大几何实例化support、t0、r2、u、v和ciphertext RAM，并用寄存器
保存32-byte sigma2。每项事务只写公开profile的有效范围；H0和sigma按输入格式固定消费但不持久保存。
各RAM使用同步单读口，读地址宽度固定为最大几何，活动上界由锁存profile描述符给出。

| 生命周期 | 写入边界 | 后续读者 |
| --- | --- | --- |
| support | `3w`个17-bit index | H排序、syndrome、residual |
| t0/u/v | 各`ceil(r/64)`个word | syndrome |
| r2 | `ceil(r/8)`个byte | H4验证 |
| ciphertext | `2*ceil(r/8)+32`个byte | c2、比较、KDF |
| sigma2 | 32个byte | 隐式拒绝选择 |

## 验证与结论

`make test-trike-decaps-input-store`逐档装载并全量读回所有有效地址，检查little-endian word组装、末word
高位清零、profile锁存和字段偏移，四档通过。loader定向测试与`make ci-fast`通过。该存储层保留为
Decaps wrapper集成边界；Vivado RAMB映射、资源和时序为`待测`。
