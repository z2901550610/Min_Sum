# EXP-0118：整多项式Karatsuba depth 1

- 日期：2026-08-27
- 状态：`pending`
- 比较键：官方TRIKE-2，64-bit word，base Karatsuba depth 1

## 目标与结构

在EXP-0117的64x64 base上加入一层word-array Karatsuba，减少外层Comba word-pair。A/B各拆为固定
low/high bank；同拍读取`A0/A1/B0/B1`，依次计算`Z0=A0B0`、`Z2=A1B1`和
`Z1=(A0+A1)(B0+B1)`。每个子积按固定地址混入完整product RAM，再执行固定循环归约。

公开`WORDS=W`、`H=ceil(W/2)`时，主乘积次数由`W^2`变为`3H^2`；奇数W固定补一个全零高半word。
输入数据不改变phase、bank访问数、RMW次数或输出拍数。

## 局部功能与周期

- `r=129,W=3,H=2`三组逐bit独立卷积通过，覆盖奇数bank和末word掩码；均为107拍；
- 官方TRIKE-2逐word golden通过：`W=244,H=122`，固定50,993拍；
- D64 diagonal/Comba为61,977拍，减少10,984拍（17.72%）。

## 结构诊断与结论

[RUN-20260827-01](../../reports/vivado/manifests/RUN-20260827-01-trike-poly-mul-k1.toml)确认Fully Routed
为2,740 LUT、628 FF、825 Slice和6 RAMB36。总体WNS `-2.557 ns`来自result RAM到64-bit输出边界；
同步内部WNS为`+2.032 ns`，关键路径是FSM状态到operand RAM地址，93.57%为布线。

保留为TRIKE-2面积/时序平衡候选。报告缺少源码、XDC和directive provenance，因此不升级为正式物理基线；
求逆和完整KEM尚未接入。
