# EXP-0082：统一Decaps寄存分段物理复测

- 状态：`superseded`
- 基线/对照：历史阶段81首轮route
- 配置键：`trike_decaps_synth_top | 五档统一最大几何 | L=32 | K=4 | C=256`

## 目标与假设

复测阶段81保留的稀疏乘法地址寄存边界和residual support同步RAM，确认两组失败路径是否消失，并取得
统一硬件最大参数几何的资源与100 MHz时序结果。

## 统一硬件边界

报告按统一硬件的最大`R/W/N`确定RAM深度、字段宽度和计数器宽度。因此层次中的320个
`ram_k_global` RAMB36、8个CT RAMB36以及7-bit K-sign位置字段属于最大TRIKE几何，不是
TRIKE160误配。`decoder_top`具有公开运行时profile选择；该Decaps wrapper中的pipeline将选择绑到
`PROFILE_DEFAULT`，所以本次route衡量统一数据通路的最大物理包络，不证明四档完整KEM事务可从
wrapper运行时切换。

该运行包含`TRIKE-1/2/5/7/9`五档控制表。EXP-0083删除非提交的TRIKE-1档后，四档统一RTL仍由
TRIKE-9确定最大物理几何；本报告作为修改前物理参考，当前四档源码需要重新route后才能形成同提交范围
一致的基线。

## 物理结果

| 指标 | 阶段81首轮 | 本次route | 变化 |
| --- | ---: | ---: | ---: |
| LUT | 65,746 | 63,228 | -2,518（-3.830%） |
| FF | 66,149 | 60,542 | -5,607（-8.476%） |
| Slice | 28,128 | 25,653 | -2,475（-8.799%） |
| Block RAM Tile | 634.5 | 635 | +0.5 |
| RAMB36 / RAMB18 | 575 / 119 | 575 / 120 | 0 / +1 |
| DSP | 4 | 4 | 0 |
| setup WNS / TNS | -0.304 ns / -13.669 ns | +0.033 ns / 0 | +0.337 ns / 清零 |
| hold WHS / THS | +0.049 ns / 0 | +0.050 ns / 0 | +0.001 ns / 0 |

新增RAMB18位于`trike_decoder_residual_check.u_support_mem`。原有稀疏环乘进位/移位路径和residual动态
support读取路径均未进入新的前20条路径，说明两个固定寄存边界实现了预期的路径切分。

整体WNS `+0.033 ns`来自IOB寄存器到`o_shared_secret_data[0]`的OBUF路径，包含2 ns虚拟output delay。
前20条报告中的`+0.591 ns`是复位release recovery路径，不是寄存器数据setup。最差内部数据setup为
error-vector级联RAM到reencryption选择寄存器，slack `+0.612 ns`，数据延迟9.294 ns，其中route
6.723 ns（72.338%），共4级逻辑。

资源按主要层次分布为：decoder 24,557 LUT、11,262 FF、480 RAMB36和115 RAMB18；postprocess
30,035 LUT、45,001 FF、16 RAMB36和4 DSP；support sorter 4,641 LUT、1,926 FF；syndrome
2,665 LUT、894 FF、35 RAMB36和3 RAMB18。总BRAM利用率为88.81%，只剩80 Tile。

methodology报告有49项DPIR-1和4项SYNTH-10 Warning，没有Critical Warning。时序检查显示内部未约束
endpoint为0，流接口具有max 2 ns/min 0 ns虚拟I/O delay，reset输入由false path覆盖。wrapper没有
板级package pin方案，因此该结果不是板级I/O签核。

## 验证

| 层 | 配置 | 结果 |
| --- | --- | --- |
| Decoder功能 | 五档统一K=4、L=32 | `PASS`，固定周期、residual和exact逐档通过 |
| KEM功能 | 软件五档；RTL TRIKE-2/项目TRIKE160边界 | `PASS`，范围与物理最大几何分别记录 |
| Vivado | `RUN-20260810-01-trike-decaps` | `PASS`，Fully Routed 100 MHz |

## 结论

`superseded`。寄存分段在统一最大几何下消除了阶段81的setup失败路径，并降低LUT/FF/Slice，方案保留。
该运行证明统一数据通路最大几何的100 MHz物理可行性；EXP-0083删除非提交TRIKE-1档后，
以四档统一RTL重新运行Vivado并建立提交范围一致的当前基线。
