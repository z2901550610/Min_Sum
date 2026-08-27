# EXP-0119：整多项式Karatsuba depth 2

- 日期：2026-08-27
- 状态：`pending`
- 比较键：64-bit word，base Karatsuba depth 1，word-array depth 2

## 目标与结构

A/B固定补齐并拆为四个quarter bank，依次计算9个quarter-size Comba子积。公开phase地址表对每个
subproduct word执行`4/4/2/4/4/2/2/2/1`组product-RAM XOR；输入值不改变相位、读写或周期。

公开`W=ceil(r/64)`、`Q=ceil(W/4)`时，word-pair由depth-1的`3*ceil(W/2)^2`降为`9Q^2`；
完整busy周期为`9Q^2+152Q+6W-9`。

## 局部功能与周期

- `r=257,W=5,Q=2`三组逐bit独立卷积通过，覆盖每操作数补3 words及末word掩码；固定361拍；
- 官方TRIKE-2逐word golden通过：44,216拍；较depth 1再降13.29%，较D64 Comba降28.66%；
- TRIKE-9几何`W=1669,Q=418`通过参数elaboration；公式为1,646,057拍，较D64降41.26%。

## 结构诊断与结论

[RUN-20260827-02](../../reports/vivado/manifests/RUN-20260827-02-trike-poly-mul-k2.toml)确认Fully Routed
为3,712 LUT、661 FF、1,156 Slice和10 RAMB36；同步内部WNS为`+1.483 ns`。相对depth 1，内部诊断
Fmax下降6.45%，但`cycles/Fmax`延时仍下降7.32%；LUT/Slice/BRAM则增加35.47%/40.12%/66.67%。

depth 1/2构成TRIKE-2面积与延时Pareto点：depth 1为平衡候选，depth 2为最低延时候选。TRIKE-9静态
block几何下两者均为19个RAMB36等价容量，depth 2保留为大参数首选。报告provenance不完整，求逆、
完整KEM和depth 3均不在本实验结论内。
