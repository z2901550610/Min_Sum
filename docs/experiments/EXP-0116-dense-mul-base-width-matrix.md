# EXP-0116：稠密乘法base-width矩阵

- 日期：2026-08-27
- 状态：`pending`
- 比较键：TRIKE-2，`WORD_W=64`，diagonal/Comba，`DIGIT_W=16/32/64`

## 目标与边界

在EXP-0115相同控制、RAM和固定归约边界下比较三档carry-less base。只改变`DIGIT_W`；不改变
product/result存储、稀疏路径或KEM调度，不运行完整KEM。Vivado映射、Fmax和route均为`待测`。

## 局部功能与周期

`make test-trike-poly-kernel-matrix`对三档分别运行TRIKE-2乘法和求逆逐word golden，全部通过：

| base | pair II | internal dense | external dense | inversion | 相对16-bit求逆 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16x64 | 4 | 240,585 | 239,609 | 5,988,878 | 1.000x |
| 32x64 | 2 | 121,513 | 120,537 | 3,369,294 | 1.777x |
| 64x64 | 1 | 61,977 | 61,001 | 2,059,502 | 2.908x |

稀疏路径三档均为69,366拍。周期只由公开参数决定；100 MHz等效求逆延时为59.889、33.693和
20.595 ms，但只有实现后达到100 MHz时该换算才成立。

## 本地结构估计与结论

Yosys 0.68 `synth_xilinx -family xc7`诊断在三档均推断4个RAMB36，Estimated LC分别为2,379、
3,147和4,252；相对16-bit增加32.28%和78.73%。该结果使用generic RAM分支，不能代替Vivado XPM映射、
LUT/BRAM或时序报告。

32-bit是首选物理候选：求逆周期降低43.74%，本地LC增幅较64-bit温和。64-bit作为激进候选保留；
双lane需要复制A/B读带宽且会同时改变RAM结构，留到三档同条件Vivado结果之后独立立项。
