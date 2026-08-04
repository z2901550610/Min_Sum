# RTL 实现状态与 Vivado 基线

本文档汇总统一 TRIKE K-sign 译码器的 RTL 结构、固定周期、存储组织、Vivado
资源占用、时序结果和验证状态。算法说明见
[k_sign_decoder_design.md](k_sign_decoder_design.md)，周期定义见
[decoder_schedule.md](decoder_schedule.md)。

## 基线配置

仓库统一TRIKE K-sign默认构建配置为 `L=32`、`K=4`、`COLS_PER_TILE=1152`。当前TRIKE128采用
`R=8243`、`C_VAL=4`。RTL功能和固定周期验证见本文验证状态；Vivado资源和时序数据来自
2026-07-28的前一组TRIKE128参数，当前参数的物理实现待重跑。

| 项目 | 配置 |
| --- | --- |
| 参数族 | `TRIKE_UNIFIED_PARAMS` |
| 最大公开参数等级 | TRIKE-512 |
| `N0 / R / W` | `3 / 106781 / 111` |
| 迭代数 `I_MAX` | 7 |
| message width | 5 bit，幅值 `D=4` bit |
| lane 并行度 `L` | 32 |
| `COLS_PER_TILE` | 1152 |
| `Q_BASE / Q_TILE` | `36 / 39` |
| `TILE_COUNT / TILES_TOTAL` | `93 / 279` |
| K-sign `K / POS_W` | `4 / 7` |
| FPGA | `xc7k355tffg901-2L` |
| Vivado | 2023.2 |
| 目标时钟 | 100 MHz，周期 10 ns |
| 时钟不确定度 | 0.100 ns |
| 物理实现状态 | 当前参数待测；2026-07-28前一参数版本报告作为历史参考 |

统一硬件使用最大参数确定存储和计数器几何。`i_param_level` 是公开输入，各参数等级使用公开固定的
`R`、`W`、tile 数和周期预算。

## 数据通路与控制

主译码器使用固定窗口调度：

- `edge_addr_gen` 使用两级地址流水，每拍接收一组 tile/diag/lane 坐标。
- `barrel_rotate` 完成 lane 到 bank 的请求路由和读数据返回。
- `k_sign_selector`利用同一lane group内`floor(tile_offset/L)`相同的不变量，只旋转valid、列号、消息和
  base sign等bank相关负载；主工作RAM和correction snapshot读地址各计算一份并广播到所有bank。
- `ram_m` 使用两个 iteration pair，C2V 读取一个 pair，V2C 更新另一个 pair。
- `ram_sign_delta` 使用两个 iteration pair，C2V 读取 deviation parity，重叠 correction 更新另一个 pair。
- `ram_accum` 和 `ram_t` 使用独立的 fill/active 双 buffer，使相邻 tile 的 C2V 与 V2C 重叠；两个buffer
  选择恒为互补。
- `ram_t`利用同一lane group内`diag_idx_local*Q_BASE+floor(tile_offset/L)`相同的不变量，读侧只旋转
  valid，写侧只旋转valid和消息；读写地址各计算一份并广播到所有bank。
- `ram_k_tile` 使用一份候选工作RAM和一份位置snapshot，使完成tile的correction与后续tile的V2C重叠。
- correction在snapshot所属column bank完成K路位置命中和invalid过滤，只将1-bit有效命中结果逆路由回
  原请求lane并驱动 `ram_sign_delta` 翻转读改写。
- 最后一轮提交到 `ram_k_global` 的 `base_sign` 是最终错误判决；`o_done` 后外部串行读口复用空闲的
  全局K记录读口。
- `ram_sign_delta` 的翻转读改写和连续同地址访问使用固定旁路规则。
- `k_sign_overlap_scheduler` 使用公开固定 tile/diag/lane 扫描深度。
- 参数等级在首个有效H或syndrome写请求时锁定，H校验、syndrome容量和主调度共用同一公开配置。
- syndrome按地址 `0..R-1` 顺序完整写入后置为就绪；启动同时要求H校验通过、syndrome就绪且控制器空闲。
- 译码运行期间的重复启动和配置写请求不进入调度器或配置RAM；主循环状态和pair选择保持连续。
- invalid lane、invalid K 槽、syndrome、H 第一列内容和译码结果只控制 valid/写使能，不改变调度深度。
- 主循环固定执行 `I_MAX` 轮，不使用提前终止。

## RAM 组织

| 模块 | 物理组织 | 端口与时序 |
| --- | --- | --- |
| `ram_bram` | XPM 简单双口 block RAM；tile 工作存储可选择 distributed RAM | 同步写、同步读，read-first 语义 |
| `ram_i` | 三份 H 第一列 `base_row_idx` BRAM | C2V/V2C/correction 三读视图；加载后执行固定周期合法性校验 |
| `ram_m` | `2 × L` 个18-bit压缩 check-state bank | 完整记录同步读写和固定旁路；pair 隔离 |
| `ram_sign_delta` | `2 × L` 个 1-bit row-parity bank | pair 隔离；同步读、清空和 flip RMW |
| `ram_syndrome` | `L` 个 syndrome bit BRAM bank | 顺序完整装载后允许启动；C2V同步读，读valid控制位复位 |
| `ram_accum` | 两组单读口 banked distributed RAM | 地址、valid和写数据按tile offset旋转；每个物理buffer在C2V/V2C之间共享一个读地址；C2V读改写 |
| `ram_t` | 每个buffer、每个tile-offset bank一份深度 `W × Q_BASE` 的BRAM | 公共地址广播；valid/消息按tile offset旋转；C2V写fill buffer，V2C读active buffer |
| `ram_k_tile` | `L` 个参数化工作bank和snapshot bank；K=4宽度为45/28 bit | 工作RAM维护候选；snapshot供correction读取位置 |
| `ram_k_global` | `L` 个原地更新全局 bank | C2V 同步读，V2C提交同步写；完成后同步输出最终判决 |

TRIKE K-sign 配置不实例化完整符号存储 `ram_s`。C2V 符号由全局 K-sign 记录重建。

### 全局 K-sign RAM

每变量逻辑记录为：

```text
base_sign       : 1 bit
dev_pos         : K × POS_W
K=3 record      : 1 + 3 × 7 = 22 bit
K=4 record      : 1 + 4 × 7 = 29 bit
```

`ram_k_global` 使用以下物理映射：

- `L=16`、`K=4`、`DIAG_IDX_W=7`时使用四个9-bit字段：field 0保存
  `{base_sign, dev_pos[0]}`，field 1至3分别保存其余三个`dev_pos`；字段按RAMB36的`4K × 9`
  原生几何划分深度段。
- `L=32`、`K=4`、`DIAG_IDX_W=7`时使用两个18-bit字段：field 0保存
  `{base_sign, dev_pos[1], dev_pos[0]}`，field 1保存`{dev_pos[3], dev_pos[2]}`；字段按RAMB36的
  `2K × 18`原生几何划分深度段。
- 其他参数配置使用独立1-bit `base_sign`字段和每槽独立7-bit位置字段；位置字段按RAMB36的
  `4K × 9`原生几何划分深度段。
- 写 valid、bank 地址和记录数据先寄存，再驱动各段写端口。
- 读 segment 编号与同步读延迟对齐，随后完成字段组合和 lane 返回路由。
- `o_done` 有效后，外部列地址从 lane 0 请求通道进入同一读路径，`base_sign` 位连接到 `o_e_rdata`。

最大参数、`L=16`、`K=4`下：

```text
KSIGN_BANK_DEPTH       = ceil(320343 / 16) = 20022
PACK_SEG_COUNT         = ceil(20022 / 4096) = 5
packed RAMB36/bank     = 4 fields × 5 segments = 20
global K RAMB36        = 16 banks × 20 = 320
```

K=4的tile工作记录宽度为 `1 + 4 × (7 + 4) = 45 bit`，correction snapshot宽度为
`4 × 7 = 28 bit`，
两者深度均为 `Q_BASE=73`。最后一个对角线同时提交全局K-sign记录和snapshot；snapshot同步读写采用
read-first语义。

### K=3 更新器

`k_sign_update` 保存K个无序候选槽。每拍执行：

1. 根据 `v2c_sign XOR base_sign` 生成候选 valid。
2. 平衡归约树按 valid、magnitude、`diag_idx_local` 和 slot index 选出最差槽。
3. 候选幅值严格大于最差有效槽时替换；存在无效槽时优先填充无效槽。
4. 等幅值保持先进入且 `diag_idx_local` 较小的候选。

该组合结构直接连接 `ram_k_tile` 的 distributed RAM 写数据端口。

## 固定周期

TRIKE-512 参数：

```text
ROW_SEG_SIZE = ceil(106781 / 32) = 3337
T_MAIN       = (279 + 1) × 111 × 39 = 1212120
T_TILE       = 111 × 39 = 4329
T_ITER       = 3337 + 1212120 + 8 + 4329 = 1219794
T_DECODE     = 7 × 1219794 + 6 = 8538564
```

8,538,564 拍由公开参数完全确定。H 第一列、syndrome、错误模式、候选位置、候选幅值和 residual
不改变该周期数。

| 参数等级 | 固定周期 | 100 MHz 延时 |
| --- | ---: | ---: |
| TRIKE128 | 193,514 | 1.93514 ms |
| TRIKE160 | 337,245 | 3.37245 ms |
| TRIKE256 | 1,252,957 | 12.52957 ms |
| TRIKE384 | 3,866,043 | 38.66043 ms |
| TRIKE512 | 8,538,564 | 85.38564 ms |

## Vivado 资源占用

本节列出的2026-07-17至2026-07-26 Vivado结果使用
`R={8117,12739,29501,61283,108587}`。2026-07-28的L=16和L=32结果使用
`R={8291,12899,29917,63997,106781}`。当前参数为
`R={8243,12589,30389,63773,106781}`，因此既有报告均作为历史物理参考，不能表述为当前源码的
资源和时序签核。

最近完整K=3基线的2026-07-17 Fully Placed aggregate utilization如下：

| 资源 | 使用量 | 器件可用量 | 利用率 |
| --- | ---: | ---: | ---: |
| Slice LUT | 26,117 | 222,600 | 11.73% |
| LUT as Logic | 22,566 | 222,600 | 10.14% |
| LUT as Memory | 3,551 | 81,400 | 4.36% |
| Distributed RAM LUT | 3,392 | — | — |
| SRL LUT | 159 | — | — |
| Slice Register | 11,078 | 445,200 | 2.49% |
| Slice | 9,331 | 55,650 | 16.77% |
| Block RAM Tile | 473.5 | 715 | 66.22% |
| RAMB36E1 | 416 | 715 | 58.18% |
| RAMB18E1 | 115 | 1,430 | 8.04% |
| DSP | 0 | 1,440 | 0.00% |
| CARRY4 | 1,803 | — | — |

K=3 aggregate结果确认当前配置使用416个RAMB36和473.5个Block RAM Tile。hierarchical utilization
仍需确认各存储模块和协议控制的资源归属。完整实现数据和逐阶段比较保存在
[optimization_exploration_history.md](optimization_exploration_history.md)。

### K=4、L=16的2026-07-28参数配置

K=4的全局记录宽度为29 bit，tile工作记录为45 bit，correction snapshot为28 bit。全局K RAM使用
320个RAMB36组成四个9-bit字段，base sign与`dev_pos[0]`保存在field 0，最终判决由同一字段直接提供，
不额外分配判决存储。K-sign selector和`ram_t`使用公共bank地址。该参数下TRIKE-512固定周期为
16,463,236，100 MHz固定译码时间为164.63236 ms。2026-07-28 Fully Placed aggregate utilization如下：

| 资源 | 使用量 | 器件可用量 | 利用率 |
| --- | ---: | ---: | ---: |
| Slice LUT | 26,034 | 222,600 | 11.70% |
| LUT as Logic | 21,714 | 222,600 | 9.75% |
| LUT as Memory | 4,320 | 81,400 | 5.31% |
| Distributed RAM LUT | 4,160 | — | — |
| SRL LUT | 160 | — | — |
| Slice Register | 11,365 | 445,200 | 2.55% |
| Slice | 9,286 | 55,650 | 16.69% |
| Block RAM Tile | 537.5 | 715 | 75.17% |
| RAMB36E1 | 480 | 715 | 67.13% |
| RAMB18E1 | 115 | 1,430 | 8.04% |
| DSP | 0 | 1,440 | 0.00% |
| CARRY4 | 1,731 | — | — |

### K=4、L=32可选配置

该配置使用 `COLS_PER_TILE=1184`，最大等级的 `Q_BASE/Q_TILE=37/40`、`TILE_COUNT=92`、
`TILES_TOTAL=276`。TRIKE-512固定周期为8,664,060，100 MHz固定译码时间为86.64060 ms。
2026-07-20 Fully Placed aggregate utilization如下：

| 资源 | 使用量 | 器件可用量 | 利用率 |
| --- | ---: | ---: | ---: |
| Slice LUT | 50,805 | 222,600 | 22.82% |
| LUT as Logic | 46,357 | 222,600 | 20.83% |
| LUT as Memory | 4,448 | 81,400 | 5.46% |
| Distributed RAM LUT | 4,160 | — | — |
| SRL LUT | 288 | — | — |
| Slice Register | 20,947 | 445,200 | 4.71% |
| Slice | 17,311 | 55,650 | 31.11% |
| Block RAM Tile | 673.5 | 715 | 94.20% |
| RAMB36E1 | 576 | 715 | 80.56% |
| RAMB18E1 | 195 | 1,430 | 13.64% |
| DSP | 0 | 1,440 | 0.00% |
| CARRY4 | 3,078 | — | — |

该配置剩余41.5个Block RAM Tile。后续存储扩展、额外缓冲和系统集成必须重新检查BRAM容量与布局可行性。

### K=4、L=32、1152列默认配置

该配置的最大等级`Q_BASE/Q_TILE=36/39`、`TILE_COUNT=93`、`TILES_TOTAL=279`。TRIKE-512固定周期为
8,538,564，100 MHz固定译码时间为85.38564 ms。该版本五档功能回归通过。K-sign selector使用公共bank
地址，`ram_t`读写地址各计算一份并广播到所有bank。2026-07-28 Fully Placed aggregate utilization如下：

| 资源 | 使用量 | 器件可用量 | 利用率 |
| --- | ---: | ---: | ---: |
| Slice LUT | 45,309 | 222,600 | 20.35% |
| LUT as Logic | 40,861 | 222,600 | 18.36% |
| LUT as Memory | 4,448 | 81,400 | 5.46% |
| Distributed RAM LUT | 4,160 | — | — |
| SRL LUT | 288 | — | — |
| Slice Register | 20,802 | 445,200 | 4.67% |
| Slice | 15,406 | 55,650 | 27.68% |
| Block RAM Tile | 561.5 | 715 | 78.53% |
| RAMB36E1 | 512 | 715 | 71.61% |
| RAMB18E1 | 99 | 1,430 | 6.92% |
| DSP | 0 | 1,440 | 0.00% |
| CARRY4 | 2,812 | — | — |

该配置剩余153.5个Block RAM Tile。全局K记录使用两个18-bit配对字段，每个bank各实例化10个RAMB36，
32个bank合计320个RAMB36。报告为aggregate utilization；物理归属由显式XPM实例几何确认，尚无同次
hierarchical utilization报告。

## Vivado 时序状态

最近完整K=3基线的2026-07-17 Routed timing满足内部100 MHz约束。整体setup WNS/TNS为
`+0.656 ns / 0.000 ns`，其中最差路径属于 `**async_default**` 异步复位释放组；`decoder_clk` 组的
setup WNS/TNS为 `+0.812 ns / 0.000 ns`。hold WHS/THS为 `+0.039 ns / 0.000 ns`，WPWS/TPWS为
`+4.232 ns / 0.000 ns`。

最差主时钟路径从 `ram_k_global` bank 6的deviation位置RAMB36读口到
`c2v_ksign_sign_q_reg[6]`，数据路径8.667 ns，其中logic 2.144 ns、route 6.523 ns，共8级逻辑。最差
异步路径从同步复位寄存器到 `v2c_comp_c_reg[15]` 的CLR端，数据路径9.237 ns，其中route占96.308%。

内部endpoint全部受约束；69个普通输入和7个输出没有I/O delay，另有1个输入由false path覆盖。
`ram_k_global` base-sign RAM到 `o_e_rdata` 的未约束外部输出路径数据延迟为11.823 ns。该路径不影响固定
译码周期和内部100 MHz结论，但外部错误向量若要求同一100 MHz时钟下一拍在器件引脚采样，需要补充真实
output delay约束并重新签核，或为输出增加寄存器并明确接口读延迟。

2026-07-28参数下K=4、`L=16`、`COLS_PER_TILE=1168`的四字段`4K × 9`、selector公共地址和`ram_t`
公共地址配置在2026-07-28 Routed timing中满足内部100 MHz约束。整体setup WNS/TNS为
`+0.611 ns / 0.000 ns`，`decoder_clk`组为`+0.667 ns / 0.000 ns`，hold WHS/THS为
`+0.034 ns / 0.000 ns`，WPWS/TPWS为
`+4.232 ns / 0.000 ns`。

最差主时钟路径从`ram_t` buffer 1、bank 3的RAMB36读口到VNU lane 11的
`v2c_scaled_q_reg[11][17]`，数据路径8.722 ns，其中logic 2.905 ns、route 5.817 ns，共11级逻辑。
前十条主时钟setup路径包括七条`ram_t`到VNU寄存器路径，以及三条`ram_m.c2v_pair_sel_q`到
`c2v_comp_s`寄存器的路径；最差`ram_m`路径数据延迟9.310 ns，其中route 9.008 ns、占96.756%。
最差异步路径从复位同步器到全局K RAM的`pack_read_segment_idx_q_reg[2][2]` CLR端，
WNS为`+0.611 ns`，数据路径8.914 ns，其中route占95.883%。

内部未约束endpoint为0；TIMING-18报告76项，69个普通输入和7个输出没有I/O delay，另有1个输入由
false path覆盖。field 0 RAMB36到`o_e_rdata`的未约束外部输出路径数据延迟为13.213 ns，不能据此判定
板级同步输出时序通过。

该报告作为2026-07-28参数及`ram_t`公共地址配置的L=16历史物理基线。

K=3配置保留用于兼容、回归验证和已有实现结果复现；后续架构、资源和时序优化以K=4配置为主要评估对象。

K=4、L=32可选配置的2026-07-20 Routed timing满足内部100 MHz约束。整体及 `decoder_clk` 组setup
WNS/TNS均为 `+0.226 ns / 0.000 ns`，hold WHS/THS为 `+0.033 ns / 0.000 ns`，WPWS/TPWS为
`+4.232 ns / 0.000 ns`。最差主时钟路径从 `v2c_tile_offset_c_reg[13][7]` 到 `ram_k_tile` bank 9工作
distributed RAM的读数据寄存器，数据路径9.533 ns，其中route为9.267 ns、占97.210%。最差异步复位
释放路径WNS为+3.243 ns。

该配置内部未约束endpoint为0；69个普通输入和7个输出没有I/O delay，另有1个输入由false path覆盖。
`o_e_rdata` 的未约束外部输出路径数据延迟为14.597 ns，板级接口签核要求与其他配置相同。

2026-07-28参数下K=4、`L=32`、`COLS_PER_TILE=1152`公共地址配置的Routed timing满足内部100 MHz
约束。整体及`decoder_clk`组setup WNS/TNS均为`+0.439 ns / 0.000 ns`，hold WHS/THS为
`+0.028 ns / 0.000 ns`，WPWS/TPWS为`+4.232 ns / 0.000 ns`；异步复位释放路径WNS为
`+2.499 ns`。

最差主时钟路径从`ram_t` buffer 0、bank 22的RAMB36读口到VNU lane 13的
`v2c_scaled_q_reg[13][17]`，数据路径8.992 ns，其中logic 3.226 ns、route 5.766 ns、route占
64.122%，共13级逻辑。前十条setup路径全部为`ram_t`到VNU路径，WNS范围为+0.439至+0.546 ns；
K-sign工作RAM、snapshot和`ram_m`路径均未进入前十条。

该配置内部未约束endpoint为0；TIMING-18报告76项，69个普通输入和7个输出没有I/O delay，另有1个输入
由false path覆盖。`o_e_rdata`的未约束外部输出路径数据延迟为14.105 ns，因此内部100 MHz通过不等于
板级I/O时序已经签核。

该报告作为2026-07-28参数及`ram_t`公共地址配置的L=32历史物理基线。

## KEM公共核

TRIKE KEM数据通路包含`sm3_compress`、`trike_sm3_service`、`sm3_hash_stream`、
`hmac_sm3_64byte_key_stream`、`sm3_df_stream`、`trike_sm3_drng_instantiate_stream`、
`trike_sm3_drng_generate_stream`、`trike_pseudohash512_stream`、`trike_parity_map_stream`、
`trike_sampler_candidate`、`trike_fixed_weight_sampler`、`trike_poly_mul_core`、
`trike_poly_inv_core`和`kem_ct_compare_select`公共RTL核。
SM3压缩核固定用52周期扩展消息、64周期执行压缩；上层完成SM3-DRNG状态生成与更新、
pseudohash512级联、H1/H2/H3奇偶映射、H4固定扫描和固定结构选择。接口、状态布局和验证边界见
[trike_kem_common_cores.md](trike_kem_common_cores.md)。

`keccak_f1600`和`shake256_stream`作为BIKE兼容公共核保留。随包TRIKE的H1/H2/H3、H4、K和L使用
SM3、SM3-DRNG和pseudohash路径。

HMAC、DRNG Instantiate、DRNG Generate和pseudohash各自保留多个hash context控制器，并在各自
复合顶层内共享一个`trike_sm3_service`。压缩服务选择只依赖公开FSM阶段；各复合顶层经Yosys层次检查
均恰好包含一个`sm3_compress`。DF、Instantiate、Generate和pseudohash512的固定busy周期分别为
314、916、708和1,128拍。

`trike_pseudohash_synth_top`通过64-bit result valid/ready流输出512-bit摘要，固定发送8个word。顶层不把
512-bit摘要直接映射到package I/O；无输出停顿时，wrapper在pseudohash完成后固定增加8次结果握手。
hierarchical utilization报告用于分离wrapper串行器与`u_pseudohash`本体资源。

奇偶映射连续流周期为`2*R_BYTES+1`；固定重量采样器对碰撞和无碰撞输入均执行
`WEIGHT*(WEIGHT+3)`个busy周期。valid/ready外部停顿会延长接口总周期，KEM顶层需要提供公开的
连续RAM调度或固定等待预算。Reference C KeyGen的弱密钥重采样循环是完整KEM固定周期设计中的独立
未决项。

`trike_poly_mul_core`提供稠密word流与固定数量稀疏index两种输入。稠密路径使用digit-serial
carryless乘法、双长度product存储和$x^r-1$固定折返；稀疏路径逐index扫描B，并把每个循环移位word
固定拆成三组result RAM读改写。A、B、product、result和稀疏index使用公共`ram_bram`同步端口；
综合分支请求Block RAM XPM。令
`WORDS=ceil(R_BITS/WORD_W)`、`DIGITS=WORD_W/DIGIT_W`，连续流稠密模式busy周期为
`11*WORDS+WORDS*WORDS*(1+4*DIGITS)`；令`S=SPARSE_WEIGHT`，稀疏模式busy周期为
`4*WORDS+2*S+7*S*WORDS`。功能TB覆盖13-bit非word对齐环、两种输入、不同数据固定周期和输出
backpressure；TRIKE-2真实参数回归的稠密/稀疏周期分别为1,967,372/60,826拍。实际Block RAM Tile、
组合移位路径Fmax、四档周期/Fmax和资源报告均为待测。

`trike_poly_inv_core`采用与最新四档Reference C相同的公开参数加法链。每个Frobenius映射固定扫描
`R_BITS`个输出系数，每个系数执行一次同步RAM读取和一次捕获；链中所有稠密环乘复用核内一个
`trike_poly_mul_core`。求逆连接采用外部稠密RAM模式：乘法器直接同步读取`f/t`和`g`，完成普通多项式
乘积后将归约结果直接写回`f/t`。该模式只保留乘法器内部双长度product RAM，不实例化A、B、result或
稀疏index RAM。

令`P`为公开参数表确定的Frobenius映射数、`M`为稠密乘法数，外部RAM稠密乘法周期
`C_EXT=7*WORDS+WORDS*WORDS*(1+4*DIGITS)`，连续输入输出求逆busy周期为
`3*WORDS+2*R_BITS*P+M*(C_EXT+1)`。TRIKE-2的`P=23`、`M=22`，官方KAT派生的15581-bit输入
逐word匹配独立多项式Euclid golden，固定43,978,192拍。三份外层scratch RAM和一份双长度product RAM
的逻辑容量为78,080 bit。首轮Vivado 2023.2、`xc7k355tffg901-2L`报告得到2,132 LUT、611 FF、
720 Slice、4 RAMB36、0 DSP，100 MHz内部时钟WNS为0.364 ns、WHS为0.080 ns；该工程同时加载了旧
`decoder.xdc`，且实现级I/O delay未生效，因此这些数字属于待干净约束复测的初步结果，不作为物理签核。

未实现范围包括H1/H2/H3/H4组合控制器和KEM序列化控制器。KEM公共核未接入
`decoder_top`，其Vivado资源与时序为待测，不计入本文译码器物理基线。

## 验证状态

当前 RTL 通过：

```sh
make format-rtl
make check-format-rtl
make lint-rtl
make check-trike-sm3-sharing
make test-kem-unit
make test-trike-reference-kat
make test-trike-poly-reference
make test-trike-poly-inv-reference
make test-unit
make test-integration
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1 \
  TRIKE_UNIFIED_KSIGN_K=4
```

维护范围内的RTL和testbench通过Verible格式检查与lint。toy集成测试同时检查syndrome未完成时不接受
启动、译码运行期间的重复 `i_start` 不重启固定调度，以及同一H下第二帧启动时 `o_done` 清除并保持154拍
固定周期。

仓库默认的K=4、`L=32`、`COLS_PER_TILE=1152`使用K=4外推参数，固定周期预算分别为
193,514、337,245、1,252,957、3,866,043和8,538,564。五档seed 1随机回归均为
residual 0、exact 1，实测周期与预算逐项一致。

K=4、`L=16`、`COLS_PER_TILE=1168`使用同一外推参数，固定周期预算分别为
377,138、657,271、2,441,942、7,402,016和16,463,236。五档seed 1随机回归均为
residual 0、exact 1，实测周期与预算逐项一致。

K-sign selector公共地址结构通过标准格式、lint、14项单元测试、toy集成，以及
`L=16/COLS_PER_TILE=1168`和`L=32/COLS_PER_TILE=1152`两组K=4统一TRIKE五档seed 1随机回归。另以
toy `L=4`单独运行`tb_k_sign_update`，覆盖`Q_BASE>1`的非零group地址和非零bank旋转场景。

`ram_t`公共地址结构通过标准格式、lint、14项单元测试和toy集成；toy `L=4`定向`tb_ram_t`覆盖非零
group、最大group、非零旋转和双buffer。当前参数下`L=16/COLS_PER_TILE=1168`与默认
`L=32/COLS_PER_TILE=1152`的K=4五档回归均通过。

以下为旧`r`参数集的历史功能检查点，不作为新参数的当前周期结果：K=3/K=4的
`L=16/COLS_PER_TILE=1168`周期为333,990、657,341、2,353,770、7,135,995、16,641,183；
K=4的`L=32/COLS_PER_TILE=1184`周期为175,720、345,855、1,192,316、3,685,394、8,664,060。

顶层 toy 集成结果：

```text
residual = 0
exact    = 1
cycles   = 154
```

旧参数TRIKE-512、seed 1、`L=16`、`COLS_PER_TILE=1168` 的完整随机译码历史结果：

```text
iter            = 7
cycles          = 16641183
target_weight   = 877
output_weight   = 877
residual_weight = 0
exact           = 1
```

该旧参数统一TRIKE、seed 1五档完整随机译码均为residual 0、exact 1，周期依次为
333,990、657,341、2,353,770、7,135,995、16,641,183。

统一 TRIKE 多参数回归入口：

```sh
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1 TRIKE_UNIFIED_KSIGN_K=4
```

Vivado 综合入口：

```sh
make vivado-synth-trike-unified-ksign
make vivado-synth-trike-unified-ksign TRIKE_UNIFIED_KSIGN_K=4
make vivado-impl-trike-kem-cores \
  VIVADO_PART=xc7k355tffg901-2L \
  VIVADO_RUN_TAG=trike_kem_core_shared_sm3
```

批处理入口按启动时间创建 `build/vivado/<timestamp>/..._k3` 或 `..._k4` 目录；可以用
`VIVADO_RUN_TAG=<label>`指定可读实验标签。不同K值和不同运行不会覆盖已有报告。

KEM公共核入口分别实现TRIKE-2求逆核和32-byte pseudohash核，输出目录为
`build/vivado/<label>/trike_poly_inv`与`build/vivado/<label>/trike_pseudohash`。两者使用100 MHz
`core_clk`、0.100 ns时钟不确定度和2 ns实现级I/O delay；wrapper不分配package pin，因此报告属于
公共核实现检查点，不是板级I/O签核。报告包含post-synth/post-route utilization、hierarchical
utilization、setup/hold top paths、timing summary、clock utilization、methodology、CDC、DRC、
messages和DCP。

Vivado工程只加载`constraints/trike_kem_core.xdc`，不同时加载译码器`decoder.xdc`。XDC使用
`get_ports -filter`直接选择数据输入和输出，避免工程模式XDC reader忽略一般Tcl的`if`和
`remove_from_collection`命令。

当前K=3和K=4 RTL的Fully Placed aggregate utilization及Routed timing summary已记录。当前 `ram_m`
使用完整18-bit记录；资源优化实验及定量结果保存在探索记录。hierarchical utilization、最新methodology、
CDC和完整messages报告待补充。

## 实现判据

同一器件、参数、约束和 Vivado 版本下，RTL 调整使用以下判据：

1. 固定译码周期和 correction 周期保持由公开参数决定。
2. 单元、集成和 TRIKE-512 随机译码结果保持一致。
3. 100 MHz 下 setup、hold 和 pulse width 无违例。
4. BRAM Tile 是存储优化的主要指标；RAMB36 与 RAMB18 需要按 Tile 等价关系共同评估。
5. LUT 优化同时检查 placed LUT、Slice 和关键路径，避免只依据 RTL 运算符数量判断收益。
6. 关键路径以 routed timing 为准，综合级逻辑层数仅作为定位信息。
