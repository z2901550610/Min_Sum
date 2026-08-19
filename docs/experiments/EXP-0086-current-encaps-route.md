# EXP-0086：当前Encaps同条件物理复测

- 状态：`physical-pass`
- 基线/对照：阶段67历史检查点
- 配置键：`trike_encaps_synth_top | TRIKE-2窄I/O | 当前共享乘法调度`
- 运行清单：[RUN-20260813-01-trike-encaps](../../reports/vivado/manifests/RUN-20260813-01-trike-encaps.toml)

## 目标与证据边界

在统一KEM XDC下测量当前Encaps的资源、RAM映射与100 MHz时序。RTL功能门禁逐byte匹配3,928-byte CT和
32-byte SS；core/wrapper固定2,378,447/2,384,421拍。报告命令误用KeyGen输出目录，manifest为本组
Encaps报告分配独立run ID；报告头未记录Git revision，且无package pin约束。

## 物理结果

资源为47,349 LUT、61,308 FF、24,349 Slice、16.5 Block RAM Tile（15 RAMB36、3 RAMB18）和4 DSP。
H4错误存储占2 RAMB36/1 RAMB18，UV与乘法存储占7 RAMB36/2 RAMB18，其余六个多项式RAM占6 RAMB36。
整体setup WNS/TNS为`+0.025 ns/0`，hold WHS/THS为`+0.014 ns/0`，无未约束路径。

同步数据路径WNS为`+0.441 ns`；最差路径从共享SM3状态寄存器到L的H1摘要寄存器，9.409 ns数据路径中
9.186 ns（97.63%）为布线且无组合逻辑级。methodology只有49项DPIR-1和4项SYNTH-10，均归属采样器
异步复位DSP输入及预期的宽乘法分解。

相对阶段67，LUT减少510、FF增加86、Slice增加995，BRAM/DSP及整体WNS不变，判定为物理波动。wrapper
周期增加256,688（12.06%）；按两次内部WNS粗略估算的`cycles/Fmax`延时增加约11.33%，不构成性能收益。

## 结论

`retained`。当前共享乘法调度在100 MHz下形成Encaps物理基线；板级I/O与精确source revision仍是证据限制。
