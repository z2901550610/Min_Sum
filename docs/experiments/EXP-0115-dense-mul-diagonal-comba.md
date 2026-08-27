# EXP-0115：稠密乘法diagonal/Comba调度

- 日期：2026-08-26
- 状态：`pending`
- 比较键：`WORD_W=64`、`DIGIT_W=16`、独立`2W` product RAM与`W` result RAM

## 目标与边界

消除每个word pair对product RAM的low/high反复读改写。保留16x64 carry-less base、流式接口、
external-dense接口、完整product存储和独立固定归约；不引入Karatsuba、direct cyclic fold或原位覆盖。

## 实现与固定调度

两个64-bit diagonal寄存器累加当前product word的low/high贡献。A/B双RAM读在前一pair最后一个digit或
对角写回拍预取，稳态word-pair initiation interval为4拍。每个product word按地址顺序只写一次。

令`W=ceil(r/64)`、`D=64/DIGIT_W`，连续握手busy周期为：

- internal dense：`10W + D*W^2 + 1`；
- external dense：`6W + D*W^2 + 1`。

TRIKE-2测得240,585/239,609拍；相对EXP-0099的1,014,796/1,013,820拍分别减少76.29%/76.37%。
product RAM固定执行`2W`次顺序写和`3W`次归约读，不再执行乘法期RMW。

## 验证与结论

- 13-bit非word对齐toy覆盖两组稠密数据、稀疏路径、backpressure及精确A/B/product访问计数；
- TRIKE-2 dense/sparse逐wordgolden为240,585/69,366拍；
- external-dense求逆逐wordgolden：TRIKE-2为5,988,878拍，`r=12589`为3,476,131拍；
- KeyGen算术/core/窄I/O逐word或逐bytegolden为12,774,257/17,607,119/17,614,690拍；
- `make test-unit`与`make check-rtl`通过；完整四档Decaps按局部优先策略不作为迭代门禁。

功能与固定调度候选成立。Vivado资源、product RAM映射、100 MHz内部setup/hold和`cycles/Fmax`待测，
物理门通过前保持`pending`，不更新Vivado基线注册表。
