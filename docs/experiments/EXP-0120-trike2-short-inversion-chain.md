# EXP-0120：TRIKE-2低寄存器短求逆链

- 日期：2026-08-27
- 状态：`pending`
- 参数域：官方TRIKE-2，`r=15581`、`WORD_W=64`

## 目标与结构

用公开固定短加法链降低KeyGen两次求逆的Frobenius置换和稠密乘法次数，保持constant-time调度。
链为`1,2,4,8,9,18,36,72,144,288,576,577,1154,2308,4616,5193,10386,15579`。
每步计算`A_(i+j)=A_i*Frobenius_i(A_j)`，其中`A_k=a^(2^k-1)`；末尾再执行一次平方。

控制器继续使用`f/g/t`三份整环scratch：`A1`、`A577`、`A5193`依次占用`t`检查点。
乘法A源bank和结果bank由两个公开控制位分别选择；没有增加整环RAM、数据相关分支或提前退出。

## 验证与结果

| `DIGIT_W` | 固定周期 | 同位宽EXP-0116周期 | 变化 |
| ---: | ---: | ---: | ---: |
| 16 | 4,635,018 | 5,988,878 | -22.61% |
| 32 | 2,610,794 | 3,369,294 | -22.51% |
| 64，base Karatsuba depth 1 | 1,598,682 | 2,059,502 | -22.38% |

- 官方TRIKE-2 inverse逐word匹配独立Python Euclid golden，三档固定周期均通过。
- `r=13` toy保持272拍；`r=12589`旧公开链保持3,476,131拍并通过golden。
- KeyGen算术逐word匹配官方`t0/r2`，固定10,066,537拍；`make test-kem-unit`与`make check-rtl`通过。
- 未运行完整KeyGen/KEM回归；对应testbench固定周期期望已按两次公开求逆同步，留待后续门禁验证。

## 结论

局部功能与固定周期门通过。置换/乘法次数固定为18/17。
[RUN-20260828-01](../../reports/vivado/manifests/RUN-20260828-01-trike-poly-inv-short-chain.toml)为Fully Routed
诊断：2,354 LUT、903 FF、799 Slice、4 RAMB36，内部setup WNS `+1.092 ns`；整体`-2.624 ns`来自
BRAM到顶层输出的I/O路径。run缺源码/generic/XDC provenance及methodology/DRC，完整KeyGen门禁也待测，
因此保持`pending`且不计算严格物理增减。
