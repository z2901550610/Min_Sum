# EXP-0099：KEM稠密乘法16-bit digit并行化

- 日期：2026-08-20
- 状态：`retained`
- 基线：EXP-0098
- 配置：`WORD_W=64`，`DIGIT_W=16`，KeyGen与四档运行时Decaps

## 目标与假设

KeyGen的两次固定链求逆和Decaps的syndrome稠密乘法共享digit-serial carryless数据通路。把每拍处理宽度
从8 bit增至16 bit，可把每个word pair的digit轮数从8减至4，同时保持操作数扫描、RAM访问和控制深度
只由公开参数决定。Encaps使用稀疏乘法调度，周期不受该参数影响。

## 硬件改动边界

生产KeyGen、独立求逆、固定profile Decaps和四档运行时Decaps统一使用16-bit digit。每拍组合部分积由
16个受控移位项异或形成，product/result RAM几何、外部流宽和算法调度不变。4/8-bit小参数单元测试继续
覆盖可参数化路径；有效/拒绝、候选选择和多项式数据不改变循环次数或RAM访问数。

## 验证与结果

官方TRIKE-2稠密乘法为1,014,796拍，稀疏乘法保持69,366拍；求逆为23,021,520拍，全部逐word golden
通过。KeyGen算术/core/窄I/O为49,162,174/53,995,036/54,002,607拍，两个候选路径逐byte PK/SK通过。

| Profile | EXP-0098周期 | 16-bit周期 | 降低 |
| --- | ---: | ---: | ---: |
| TRIKE160 | 3,415,291 | 2,794,347 | 18.18% |
| TRIKE256 | 14,941,165 | 11,331,165 | 24.16% |
| TRIKE384 | 55,654,606 | 39,750,462 | 28.58% |
| TRIKE512 | 142,148,438 | 97,579,462 | 31.35% |

四档有效/c2拒绝路径逐byteSS和固定周期通过，TRIKE160另覆盖u/v拒绝路径；`make ci-fast`通过。
[求逆](../../reports/vivado/manifests/RUN-20260820-01-trike-poly-inv.toml)为2,138 LUT、4 RAMB36，内部setup
`+0.447 ns`；[KeyGen](../../reports/vivado/manifests/RUN-20260820-02-trike-keygen.toml)为46,441 LUT、
54,731 FF、22,042 Slice、22 BRAM Tile和5 DSP，整体/内部setup为`+0.025/+0.040 ns`；内部最差为
采样状态高扇出控制且97.3%为布线，不是部分积路径。两次run均未嵌入revision/参数，标记为不可比参考。
## 结论

`retained`。16-bit digit保留为生产KEM稠密路径配置；求逆与完整KeyGen均未出现部分积关键路径。
下一物理门禁为同源revision/XDC下的固定profile Decaps route，随后复测运行时统一Decaps。
