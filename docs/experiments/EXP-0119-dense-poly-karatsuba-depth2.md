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

TRIKE-2强制block的Yosys 0.68诊断为3,104 Estimated LC、10 RAMB36；depth 1同流程为2,309 LC、
6 RAMB36。未强制时quarter bank被映为176个RAM64M和2 RAMB36，说明最终映射必须由Vivado确认。

TRIKE-9静态block几何下depth 1/2均为19个RAMB36等价容量：operand 8、product 7、result 4。
保留depth 2作为大参数候选；TRIKE-2是否保留取决于同条件Vivado `cycles/Fmax`、Tile和AT。
depth 3在depth-2物理门前不实现，避免16个operand bank和更大的重组网络提前扩散。
