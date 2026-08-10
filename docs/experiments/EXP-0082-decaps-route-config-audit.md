# EXP-0082：Decaps寄存分段复测与GUI宏配置审计

- 状态：`rejected`
- 基线/对照：历史阶段81首轮route
- 配置键：`trike_decaps_synth_top | 报告实际TRIKE512几何 | L=32 | K=4 | C=256`

## 目标与假设

复测阶段81保留的稀疏乘法地址寄存边界和residual support同步RAM，确认两组失败路径是否消失，并取得
完整Decaps的当前资源与100 MHz时序结果。

## 配置审计

报告标题给出的顶层为`trike_decaps_synth_top`，器件为`xc7k355tffg901-2L`，Vivado为2023.2，阶段为
Fully Routed。层次结果证明该工程没有按目标`TRIKE_160_PARAMS`展开：

- `ram_k_global`出现`g_pack_fields`层次并使用320个RAMB36。该分支要求`DIAG_IDX_W=7`，对应本工程
  `W=111`的最大TRIKE几何；TRIKE160的`W=35`应为`DIAG_IDX_W=6`。
- wrapper的`u_ct_mem/u_r2_mem/u_t0_mem`分别使用8/4/4个RAMB36，符合`R=106781`的容量级别；
  `R=12589`不需要该深度。
- 当前批处理入口为该顶层显式设置`TRIKE_160_PARAMS`。报告来自GUI工程，报告文件本身没有记录
  `verilog_define`或Git revision，因此不能把顶层名称当作profile证据。

本次运行实际反映的是统一最大TRIKE存储几何，不能与TRIKE160 Min-Sum功能向量和4,743,972拍wrapper
周期合并成一条端到端证据链。

## 物理结果

同历史阶段81的错误宏配置相比，寄存分段仍给出有用的物理诊断：

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

新增RAMB18位于`trike_decoder_residual_check.u_support_mem`，与阶段81的同步support RAM实现方式一致。
原有稀疏环乘进位/移位路径和residual动态support读取路径均未进入新的前20条路径。

整体WNS `+0.033 ns`来自IOB寄存器到`o_shared_secret_data[0]`的OBUF路径，包含2 ns虚拟output delay。
前20条报告中的`+0.591 ns`是复位release recovery路径，不是寄存器数据setup。最差真正的内部数据setup
为error-vector级联RAM到reencryption选择寄存器，slack `+0.612 ns`，数据延迟9.294 ns，其中route
6.723 ns（72.338%），共4级逻辑。

资源按主要层次分布为：decoder 24,557 LUT、11,262 FF、480 RAMB36和115 RAMB18；postprocess
30,035 LUT、45,001 FF、16 RAMB36和4 DSP；support sorter 4,641 LUT、1,926 FF；syndrome
2,665 LUT、894 FF、35 RAMB36和3 RAMB18。总BRAM利用率为88.81%，只剩80 Tile。

methodology报告有49项DPIR-1和4项SYNTH-10 Warning。DPIR-1来自采样器DSP输入侧异步复位寄存器，
SYNTH-10来自预期的宽乘法分解；没有Critical Warning。时序检查显示内部未约束endpoint为0，普通流接口
具有max 2 ns/min 0 ns虚拟I/O delay，reset输入由false path覆盖。wrapper没有板级package pin方案，
因此该结果仍不是板级I/O签核。

## 验证

| 层 | 配置 | 结果 |
| --- | --- | --- |
| RTL/byte golden | TRIKE160项目向量 | `PASS`，但不是本次Vivado展开配置 |
| 固定周期 | pipeline/wrapper 4,734,246 / 4,743,972 | `PASS`，但不是本次Vivado展开配置 |
| Vivado | `RUN-20260810-01-trike-decaps` | `PASS` route，profile审计`FAIL` |

## 结论

`rejected`。两组寄存分段在统一最大几何下消除了阶段81的setup失败路径，并降低LUT/FF/Slice；本次运行
不能成为TRIKE160 Decaps基线。GUI工程必须把sources_1的`verilog_define`设为
`TRIKE_160_PARAMS BIKE_PARALLEL_L=32 BIKE_K_SIGN_K=4 BIKE_MSG_BITS=5 BIKE_COLS_PER_TILE=256`，重置
synthesis/implementation后重新生成报告。正确展开的层次中`ram_k_global`不应出现当前的320个RAMB36，
wrapper的CT/R2/T0 RAM深度也应明显下降。
