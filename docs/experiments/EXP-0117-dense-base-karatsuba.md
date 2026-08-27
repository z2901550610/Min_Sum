# EXP-0117：64-bit carry-less base Karatsuba

- 日期：2026-08-27
- 状态：`pending`
- 比较键：TRIKE-2，64x64 base，外层diagonal/Comba与RAM调度不变

## 目标与边界

确认当前核的算法边界，并在不改变word-pair数量、周期或存储访问的条件下比较64x64 schoolbook与
Karatsuba recursion depth 1/2/3。本实验只优化base组合逻辑，不是整多项式Karatsuba。

## 实现与功能门

`trike_clmul_karatsuba`在depth 0使用经典carry-less乘法；每层按
`z0=a0b0,z2=a1b1,z1=(a0+a1)(b0+b1)`递归，并用XOR重组。乘法核参数
`DENSE_KARATSUBA_DEPTH`只在`DIGIT_W=WORD_W=64`时启用。

- 260组定向/随机64x64向量：depth 0/1/2/3全部匹配独立schoolbook结果；
- TRIKE-2整多项式与求逆golden：depth 1/2/3全部通过；
- 三档dense/sparse/inversion周期均保持61,977/69,366/2,059,502拍。

## 本地结构诊断与结论

Yosys 0.68 `synth_xilinx -family xc7`的独立base Estimated LC为2,195/1,766/2,690/3,312；
完整乘法核depth 0/1/2为3,575/3,460/3,768，均为4个RAMB36。depth 1相对schoolbook base下降
19.54%，完整核下降3.22%；depth 2/3被额外重组XOR抵消。

保留depth 1作为64-bit物理候选，depth 2/3停止扩展。该候选不降周期，Vivado LUT、组合路径和Fmax待测。
下一实验进入整多项式Karatsuba-Comba depth 1/2，以减少`W^2` word-pair数量；Toom-3在相同leaf规模下
乘法数接近depth-2 Karatsuba，但评价、精确除法/插值和scratch带宽更复杂，后置于Karatsuba物理门。
