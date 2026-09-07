# EXP-0123：一层 Karatsuba-Comba 直接循环折叠

- 日期：2026-09-07；状态：`pending`，独立候选功能通过，Vivado和KEM集成未完成。
- 基线revision：`3d2e0ba548de620c2fac317cc571105f6172b12a`；保留任务外dirty变更。
- 比较键：`WORD_W=64`，word-array Karatsuba depth 1，base depth 1，单路Comba。

## 假设与实现

利用GF(2)重组和循环归约的线性性，每个子积word直接混入独立结果RAM，删除完整product RAM。
输入半bank保留至计算结束；同址碎片使用顺序RMW，公开几何决定访问，padding项一致截断。
不保留旧存储模式参数或重复核；旧实现由Git与本实验基线标识复现，depth-2实验不在改动范围。
行为、推导和复现命令见[架构说明](../design/trike_karatsuba_fold.md)。

## 局部结果

| r | 折叠前周期 | 折叠后周期 | 64-bit逻辑word：前→后 |
| ---: | ---: | ---: | ---: |
| 12589 | 34542 | 34555 | 989→593 |
| 15581 | 50993 | 50999 | 1220→732 |
| 30389 | 182299 | 182312 | 2379→1427 |
| 63773 | 772942 | 772955 | 4989→2993 |
| 106781 | 2135086 | 2135099 | 8349→5009 |

前值除r15581修改前复测外为公式；后值均为RTL实测。r15581是官方TRIKE-2派生golden，
四个项目profile是seed=`20260907+r`的独立卷积。13种小几何×13事务检查精确访问、
逐拍数据无关轨迹、padding、连续事务和背压；定向test、check-rtl及候选Slang均`PASS`。

同条件本地Yosys generic-RAM xc7估计（r15581）：LUT primitive总数3200→3164、FF627→520、
RAMB36E1 6→5；Estimated LC 2429→2487，CARRY4 87→106。资源并非所有维度都下降，
不能把逻辑bit减少40%说成LUT/时序也改善。原始stat哈希、源码哈希见[记录](../../reports/qor/20260907-trike-karatsuba-fold.json)。

同条件r106781本地估计：LUT primitive 3457→3208、FF633→520、RAMB36E1 19→12，
Estimated LC 2645→2546、CARRY4 90→106。大几何的BRAM估计减少约36.8%；仍无Fmax证据。

## 决策与未完成项

选择一层串行Karatsuba-Comba＋循环折叠作为后续集成候选，排除FFT方向。
`NOT_RUN`：同条件Vivado（本机无Vivado）、外部RAM/运行时接口迁移、完整KeyGen/KEM门禁。
Tcl入口仅完成top/filelist/control-flow dry-run；没有真实执行Vivado，不建立虚构RUN结果。
在物理结果到达前，不宣称FPGA最优、不更新物理基线，也不把候选局部完成当作KEM集成完成。
