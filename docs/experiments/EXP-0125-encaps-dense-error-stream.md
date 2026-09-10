# EXP-0125：Encaps复用稠密乘法与现有error RAM

日期：2026-09-09。基线为EXP-0124六拍稀疏路径。状态：本地功能保留，Vivado NOT_RUN。

## 实现与生命周期

`trike_encaps_uv_core`读取已有padded e0/e1/e2的8-bit同步error RAM，替代全局support输入接口。
先读取e0，把u/v RAM初始化为e0；随后顺序执行e1*r1、e2*r2、e1*t1、e2*t2四次稠密乘法，
逐word异或到u或v。四次使用原有通用乘法器；其他模块的小重量稀疏模式保留。

UV阶段独占error RAM读口，完成后交回L(e)阶段。每个byte执行READ/CAPTURE，
每个word组装后执行EMIT，末word屏蔽padding，背压时保持word。
error RAM依次读取e0/e1/e2/e1/e2，合计`5W*(WORD_W/8)`次；地址/访问数不随秘密分块重量改变。
u/v每份先写W个e0，再完成两次W-word RMW；最终固定输出2W words。

移除UV内部support RAM和e0 RAM。TRIKE-2逻辑存储减少`263*16+244*64=19824`bits，
新增一个64-bit打包寄存器；不把逻辑容量差额换算为未经测量的BRAM块收益。
相邻乘法之间加入一拍DRAIN，让共享稠密wrapper完成last输出后的退休，再发起下一次start。
全局error/support store与KeyGen/syndrome的小重量稀疏路径未删除。

## 固定周期

令B=WORD_W/8，D为通用稠密核连续握手周期，则UV边界为：
`T_UV = 4D + (10B+9)W + 3`。
包括五次字节读取/打包、四次计算、结果RMW背压、最终输出及相邻事务控制。
外部输入/输出等待另计，数据不改变计算阶段的固定调度。

| 边界 | EXP-0124 | 当前实测 |
| --- | ---: | ---: |
| r13、WORD_W=8 UV，内部/外部结果store | 344 | 305 |
| 官方TRIKE-2 UV组件 | 1548862（周期推导） | 228651 |
| 官方TRIKE-2 Encaps core | 1865071 | 544860 |
| 官方TRIKE-2寄存I/O wrapper | 1871045（周期推导） | 550834 |

100 MHz假设下Encaps core为5.44860 ms；这不是本轮已完成布线的频率证据。

## 验证

- `./eda make test-trike-encaps-uv-core test-trike-encaps-uv-core-external-store`：两组不同秘密分块重量、
  独立GF(2)循环乘法golden、dirty padding、相同error地址轨迹/计数、输出背压通过。
- `./eda make test-trike-encaps-components-reference test-trike-encaps-core-reference-base test-trike-encaps-core-reference-shared-resources test-trike-encaps-synth-reference`：
  官方中间量、3928-byte CT及32-byte SS通过；共享乘法/error RAM组合及wrapper周期通过。
- format、`check-fast`、`check-rtl`及`git diff --check`通过。

日志：`build/encaps-dense/reference.log`含初次迁移失败与已通过的局部结果；
最终组件、基础完整核与共享/wrapper结果分别在`components.log`、`core.log`、`final.log`。
其他大参数完整Encaps、完整Decaps、生产形式证明和Vivado为NOT_RUN；
本轮没有为记录更多结果而扩大到全参数KEM回归。
