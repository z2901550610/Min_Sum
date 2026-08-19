# EXP-0085：当前KeyGen同条件物理复测

- 状态：`physical-pass`
- 基线/对照：阶段72历史检查点
- 配置键：`trike_keygen_synth_top | TRIKE-2窄I/O | 当前共享乘法调度`
- 运行清单：[RUN-20260811-02-trike-keygen](../../reports/vivado/manifests/RUN-20260811-02-trike-keygen.toml)

## 目标与边界

在当前filelist、统一KEM XDC和共享多项式乘法调度下重新测量完整KeyGen的资源、RAM映射与100 MHz时序。
本实验不修改KeyGen数据通路、公开FSM或RAM生命周期；外部接口仍为8-bit随机输入、PK和SK流。

`trike_keygen_core`固定98,766,108拍，wrapper固定98,773,679拍。候选合格位置只影响数据和`success`，
不改变16组候选、H123、算术及输出扫描深度。本实验不包含板级pin分配与真实I/O delay签核。

## 验证

| 层 | 配置 | 结果 |
| --- | --- | --- |
| 静态/结构 | `make check-rtl check-trike-sm3-sharing` | `PASS`，完整层次一个`sm3_compress` |
| RTL/byte golden | 候选0合格、候选1才合格及窄I/O wrapper | `PASS`，PK 1,980 byte，SK 6,328 byte |
| 固定周期 | core两路径 / wrapper | `PASS`，98,766,108 / 98,773,679 |
| Vivado入口 | KeyGen top、器件、统一XDC和run目录dry-run | `PASS` |
| Vivado | `RUN-20260811-02-trike-keygen` | `PASS`，Fully Routed，100 MHz setup/hold通过 |

资源为46,464 LUT、54,718 FF、22,392 Slice、22 Block RAM Tile（21 RAMB36、2 RAMB18）和5 DSP。
support顺序输出RAM映射为1个RAMB18；算术核占15 RAMB36和1 RAMB18。整体setup WNS/TNS为
`+0.025 ns/0`，hold WHS/THS为`+0.001 ns/0`，无未约束路径。整体最差setup位于`o_pk_valid`虚拟I/O
边界；同步数据路径WNS为`+0.600 ns`，最差路径从弱密钥距离RAM经过7级CARRY4和DSP到弱标志寄存器。
methodology保留49项DPIR-1和4项SYNTH-10；均归属采样乘法器的异步复位/DSP打包与宽乘法提示。
相对阶段72历史检查点，LUT减少395（0.84%）、FF增加147（0.27%）、Slice增加667（3.07%），
BRAM/DSP及整体setup WNS不变；同步数据WNS改善0.186 ns，资源差异按实现波动处理。

## 结论

`retained`。当前共享乘法调度在100 MHz下形成KeyGen物理基线。报告头未嵌入Git revision，按用户提供的
Windows工程关联到本实验；该限制写入run manifest。wrapper没有package pin约束，不构成板级I/O签核。
