# EXP-0105：统一KEM H123向量存储

## 目标与假设

KeyGen与Encaps使用相同的官方TRIKE-2 H1/H2/H3几何，且在公开operation下单发射运行。两阶段的
`t1/t2/r1`生命周期均为H123产生后保留至活动事务完成，可使用同一组三银行同步RAM。

## 硬件边界

- `trike_h123_vector_store`将共享H123 byte流按little-endian打包到三组244x64-bit RAM。
- 三组RAM提供独立同步读口，支持KeyGen同周期读取`t1/r1`及Encaps公开FSM读序列。
- KeyGen与Encaps核通过参数选择本地或外部H123存储；统一顶层固定使用外部存储。
- operation mux只选择活动stage的读使能与地址，H123写流在共享服务握手处旁路写入。
- Decaps运行时四档H123几何及其他多项式scratch RAM不属于本实验。

## 验证与量化结果

- 单元测试覆盖三银行并行读取、连续事务覆盖和末word零填充。
- 完整Verilator层次恰好1个`trike_h123_vector_store`，包含3个逻辑word RAM。
- KeyGen全外置组合PK/SK byte golden通过，固定53,995,036拍。
- Encaps全外置组合CT/SS byte golden通过，固定2,378,447拍。
- 静态RTL、独立算术reference及结构门禁通过。

## 结论

方案保留。KeyGen/Encaps的六组stage本地H123逻辑RAM收敛到三组共享逻辑RAM；实际RAMB36/RAMB18、
读口复制行为、LUT/FF、WNS与`cycles/Fmax`等待统一ASIC Vivado placed/routed报告。
