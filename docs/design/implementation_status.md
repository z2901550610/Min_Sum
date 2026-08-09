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
`trike_sampler_candidate`、`trike_fixed_weight_sampler`、`trike_drng_weight_sampler`、
`trike_h4_error_sampler`、`trike_error_support_store`、`trike_h4_error_vector`、`trike_h123_vectors`、
`trike_poly_mul_core`、`trike_encaps_uv_core`、`trike_poly_inv_core`、`trike_decaps_syndrome_core`、
`trike_decoder_load_adapter`、`trike_ct_verify_stream`和`kem_ct_compare_select`公共RTL核。
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

Vivado 2023.2、`xc7k355tffg901-2L`的首轮窄I/O implementation完成route：9,711 LUT、8,767 FF、
4,029 Slice、0 Block RAM Tile、0 DSP和83 Bonded IOB。10 ns时钟下整体setup WNS为-2.008 ns、
TNS为-118.367 ns、70个失败端点，hold WHS为0.051 ns、THS为0。70个失败端点与wrapper的70个输出
bit数量相同，报告top path均从摘要或word选择寄存器到`o_result_data[*]`，包含MUXF7、OBUF和2 ns
output delay；该结果证明内部核完成布局布线，但不构成100 MHz整体时序通过。内部寄存器到寄存器WNS
为0.883 ns，对应相同布局布线条件下约109.7 MHz的近似内部Fmax；1,128个核心busy周期对应100 MHz时
11.28 us，按近似Fmax为10.29 us。内部最差路径从共享SM3的`o_done`到HMAC outer chaining-state CE，
8.431 ns数据延迟中8.072 ns为路由，主要问题是31和256级扇出控制网，不是SM3轮函数组合逻辑。外部流
接口时序与该片内核时序分开报告。

hierarchical utilization显示一个物理`sm3_compress`占5,293 LUT和3,002逻辑FF；HMAC控制与两个hash
context占2,061 LUT和2,627逻辑FF，H1、H2分别占1,445/1,044和766/1,043。物理flat report的
Slice Register为8,767，hierarchical report的顶层逻辑FF为8,795，资源对比使用前者，层次归因使用
后者。全部buffer和schedule均映射为FF/LUT，未使用BRAM。

奇偶映射连续流周期为`2*R_BYTES+1`；固定重量采样器对碰撞和无碰撞输入均执行
`WEIGHT*(WEIGHT+3)`个busy周期。valid/ready外部停顿会延长接口总周期，KEM顶层需要提供公开的
连续RAM调度或固定等待预算。

`trike_drng_weight_sampler`为每个候选单独执行一次Generate(4 byte)，按little-endian `uint32_t`组装
随机数，并把更新后的DRNG状态传给下一次调用。`trike_h4_error_sampler`执行
Instantiate(`m || r2`)和固定`t`次Generate，Instantiate与全部Generate顺序复用一个
`trike_sm3_service`。toy fixture对拍完整错误support和最终`V/C/reseed_counter`；含3拍输出停顿的
Generate/采样组合为1,448拍，连续H4组合为2,313拍。真实参数资源、时序和总周期待目标Vivado与KAT测量。

`trike_weak_key_test`保存三组秘密support，并用一份8-bit、深度`r`的距离直方图RAM依次执行三项自相关
和三项互相关检查。每项都固定清零直方图、扫描公开数量的index pair，再扫描固定地址范围并累加
`sum C(count[d],2)`；该分数与Reference C的`cnt[]`更新等价。TRIKE-2官方support的六项分数为
`28/19/16/50/48/51`，固定244,638拍。

`trike_keygen_secret_sampler`从32-byte seed实例化一个DRNG，固定生成16组候选；每组顺序采样
`h0/h1/h2`并运行完整弱密钥检查。首个合格候选通过写mask在固定105拍复制扫描中保存，其合格位置不改变
后续候选执行。官方Count=0选择候选0；补充向量的候选0分数超限、候选1合格，两者均输出正确的105个
support索引和最终DRNG状态，连续握手busy周期同为4,778,975拍。16组均不合格时模块仍按相同调度结束，
输出`success=0`及全零support。10,000个确定性软件样本中首候选弱22次、最长连续弱候选为1；该有限
样本只支持工程预算选择，不是失败概率证明。该组合尚无Vivado资源或时序结果。

`trike_encaps_uv_core`保存H4输出的`t`个全局错误位置，使用一个`trike_poly_mul_core`依次计算
`e1*r1`、`e2*r2`、`e1*t1`和`e2*t2`，在三个word RAM中构造`e0`并累加`u/v`。每次乘法固定回放全部
`t`个位置，不属于目标错误块的位置转换为`index>=r`的零贡献dummy；四次乘法数、support读取数和
word RAM访问数不依赖`e0/e1/e2`各自重量。13-bit toy中两种`2/1/2`和`0/3/2`重量分布均为384拍，
结果匹配独立环乘模型；3拍结果backpressure使接口总周期增加3拍。

`trike_h123_vectors`从`sigma`执行一次Instantiate，并从同一DRNG状态连续执行三次
Generate(`R_BYTES`)，输出依次经过偶、偶、奇`trike_parity_map_stream`。Instantiate和三次Generate
顺序复用一个压缩服务，并提供外部压缩端口供KEM顶层进一步共享。Generate完成脉冲先寄存为12组本地
副本，分别驱动三份440-bit状态的四个110-bit分组；复制数量和捕获节拍由公开结构固定。13-bit、4-byte
seed的独立SM3 toy fixture逐byte匹配`t1/t2/r1`和最终DRNG状态；含3拍结果停顿固定2,284拍。

`scripts/gen_trike_encaps_fixture.py`从官方TRIKE-2 Count=0恢复Encaps消息`m`。KAT全局DRNG在KeyGen中
依次生成`seed/sigma2/sigma`，秘密多项式采样使用局部DRNG，因此第四次32-byte Generate是`m`。
生成器独立重算H1/H2/H3、H4 support、`u/v`、padded `L(e)`、`c2`和`K(m||ct)`，最终逐byte匹配官方
3,928-byte CT和32-byte SS。

真实TRIKE-2 RTL对拍得到：H1/H2/H3为44,640拍，H4为207,017拍，单乘法核`u/v`为1,805,550拍，
`L(e)`为34,916拍，`K(m||ct)`为23,616拍。`trike_error_support_store`固定6,478拍构造263-entry support
RAM和5,952-byte padded error RAM；与H4并行清零和顺序写入的`trike_h4_error_vector`固定207,018拍。
这些结果是RTL连续流周期，不是目标器件的Fmax或物理时间；当前Encaps延时瓶颈是四次串行稀疏乘法。

`trike_encaps_core`采用8-bit输入、密文输出和共享密钥输出接口，输入顺序为官方公钥序列化
`r2 || sigma`后接随机消息`m`，输出顺序为`u || v || c2`和共享密钥。顶层缓存公钥与消息，依次执行
H1/H2/H3、H4 error-vector、四次共享稀疏乘法、`L(e)`、`c2`写回和`K(m||ct)`，六个多项式word RAM
承载`r2/t1/t2/r1/u/v`。H123 byte流按little-endian每8 byte写入64-bit word；H4 support、padded error、
L/K双pass和密文输出均由公开计数器预取同步RAM。四个哈希/DRNG阶段经顶层mux复用一个
`trike_sm3_service`。官方TRIKE-2 Count=0端到端测试逐byte匹配3,928-byte CT和32-byte SS；连续输入、
连续接收时固定2,121,759个busy周期。输入`valid`空拍或输出`ready`停顿只延长外部事务，内部阶段选择、
哈希调用数、support回放数和RAM地址序列不依赖消息、公钥或错误位置。

`trike_encaps_synth_top`在核与package边界之间使用8-bit单项输入缓冲，以及密文和共享密钥的片内暂存加
IOB输出两级寄存边界；输出数据、valid、last、busy和done均从IOB寄存器驱动。该wrapper按公开
2,012-byte输入长度控制输入缓冲，并在最后一个共享密钥byte被外部接收时产生done。连续输入与连续接收的
官方TRIKE-2端到端周期为2,127,733拍，3,928-byte密文与32-byte共享密钥逐byte匹配KAT。接口缓冲增加
5,974个固定周期，不改变核内算法调度。

用户提供的Vivado 2023.2、`xc7k355tffg901-2L`、10 ns、0.100 ns不确定度的Fully Routed Encaps
检查点使用48,575 LUT、60,982 FF、24,554 Slice、15 RAMB36、3 RAMB18、4 DSP和37 IOB，即
16.5 Block RAM Tile。整体setup WNS/TNS为-3.937 ns/-214.375 ns，共435个失败端点；hold WHS为
+0.034 ns。整体最差路径位于片内RAM至byte选择和OBUF的输出边界。限定寄存器到寄存器的内部WNS为
-1.534 ns：最差内部路径为H123 Generate完成脉冲到父级440-bit状态捕获，扇出1,322、数据路径
11.158 ns，其中10.856 ns为路由；下一组路径为稀疏乘法`b_word_idx_q`到result RAM写数据，约34级逻辑。
层次资源中H123为17,032 LUT/27,472 FF，H4错误采样约8,072 LUT/11,137 FF，L/K分别为
5,662/5,776和4,841/5,772，UV为3,289 LUT/632 FF及7 RAMB36/2 RAMB18。

寄存分段RTL的同条件Vivado复测完成。Fully Routed结果为47,859 LUT、61,222 FF、23,354 Slice、
15 RAMB36、3 RAMB18、4 DSP和37 IOB，即16.5 Block RAM Tile。整体setup WNS/TNS为
+0.025 ns/0，hold WHS/THS为+0.050 ns/0，100 MHz约束通过；内部register-to-register WNS为
+0.378 ns。整体最差setup路径为IOB寄存的`o_done`经OBUF到输出端口，内部最差路径为共享SM3状态到
L摘要寄存器，数据路径9.761 ns中9.538 ns为route、逻辑级数为0。H123 Generate完成脉冲和稀疏乘法
BRAM写数据路径均未进入内部前20条路径，高扇出表中其余1320级DRNG控制网的最差slack不低于
+1.638 ns。

与本节首轮检查点相比，LUT减少716、FF增加240、Slice减少1,200，BRAM、DSP和IOB不变；整体WNS从
-3.937 ns提高到+0.025 ns，内部WNS从-1.534 ns提高到+0.378 ns。固定wrapper周期为2,127,733拍，
100 MHz下为21.27733 ms。按`1/(10 ns-0.378 ns)`作一阶内部频率外推约103.93 MHz，该值不是新的
超频签核。

本次Vivado工程仍读取工程目录中导入的旧XDC副本，其第16/18行把I/O min和max都设为2 ns，因此
methodology仍有35项XDCH-2。仓库XDC已明确使用max 2 ns、min 0 ns；更新工程约束副本并重跑时序与
methodology后才能形成板级I/O约束签核。49项DPIR-1来自采样器DSP输入的异步复位寄存器，4项
SYNTH-10对应预期的32x32 multiply-high分解，均未构成当前100 MHz最差路径。

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

`trike_keygen_arith_core`用七份word RAM保存`t1/t2/r1`、共享分子、共享逆元、`t0/r2`，并保存三组
秘密support。外层一个`trike_poly_mul_core`固定完成一次稀疏乘法和三次稠密乘法；一个
`trike_poly_inv_core`固定完成`inverse(t1+r1)`与`inverse(t0+h0)`。`h1/h2/h0`的稀疏word mask在RAM
边界直接XOR，不设置单独的稠密多项式加法器。13-bit toy的两组不同输入均为925拍并匹配独立模型；
TRIKE-2官方Count=0逐word匹配`t0/r2`，连续握手固定93,924,706拍。当前模块包含外层乘法器和求逆核
内部乘法器两个物理数据通路；资源、映射、WNS和Fmax待Vivado测量。

`trike_keygen_core`从外部随机源接收`key_seed || sigma2 || sigma`共96 byte，顺序连接
`trike_keygen_secret_sampler`、`trike_h123_vectors`和`trike_keygen_arith_core`。秘密采样与H123的压缩
请求经公开状态mux复用一个`trike_sm3_service`；support在采样输出时同时写入顶层稀疏视图、算术核和
32-bit×`3*SECRET_WEIGHT`的SK顺序输出RAM。SK序列化按公开地址依次fetch每个support word并输出四个
little-endian byte。H123 byte流每8 byte组装为一个算术operand word。算术输出写入`t0/r2`结果RAM，
再按官方结构输出1,980-byte PK和6,328-byte SK。

官方Count=0候选0合格；补充输入使候选0弱、候选1合格。两组完整输出均逐byte匹配软件golden，连续
96-byte输入及连续PK/SK接收时busy周期均为98,757,568拍。`success`只控制状态输出，不控制H123、算术、
RAM扫描或序列化状态。Yosys层次检查确认完整KeyGen顶层只有一个`sm3_compress`。完整KeyGen的物理资源、
时序和Fmax边界由下述wrapper实现结果覆盖。

`trike_keygen_synth_top`为TRIKE-2固定参数提供窄物理边界：96-byte随机输入、1,980-byte PK和
6,328-byte SK均使用8-bit valid/ready流，`busy/done/success`为单bit寄存输出。随机输入以及PK/SK各有
一项片内缓冲，输出端再经过IOB寄存器，不把密钥RAM或多项式word导出为顶层端口。官方向量逐byte通过，
连续外部握手固定98,765,139拍；Yosys层次检查确认wrapper仍只有一个`sm3_compress`。当前RTL的Vivado
2023.2、`xc7k355tffg901-2L`、10 ns时钟、0.100 ns uncertainty和Fully Routed报告得到46,859 LUT、
54,571 FF、21,725 Slice、21 RAMB36、2 RAMB18、22 Block RAM Tile、5 DSP和38 IOB。support顺序
输出RAM映射为1个RAMB18。整体setup WNS/TNS为+0.025 ns/0，hold WHS/THS为+0.050 ns/0；整体最差
setup路径是IOB寄存的`o_pk_valid`经OBUF到输出端口，内部register-to-register WNS为+0.414 ns。内部
最差路径为秘密采样FSM到440-bit状态寄存器的1级逻辑高扇出路径；外层稀疏乘法贡献生成路径紧随其后，
两者均满足100 MHz。methodology保留49项DPIR-1异步复位DSP输入告警和4项SYNTH-10宽乘法提示，无
TIMING-16告警或未约束路径。wrapper不分配package pin，因此该结果属于核心实现签核，不是板级I/O签核。

Decaps syndrome阶段固定装载`h0` support与`t0/u/v`，顺序复用一个`trike_poly_mul_core`计算
`h0*u+t0*(u+v)`。官方TRIKE-2 Count=0的244个64-bit syndrome word全部匹配独立Python模型，连续
握手固定2,030,223拍。decoder装载桥固定写入`3w`项H support，把little-endian syndrome word展开为
恰好`r`次bit写并只发一次start。流式验证核固定消费全部比较word，把累计difference和decoder residual
状态共同送入`kem_ct_compare_select`；首/中/末word不匹配均不改变连续输入周期。

官方TRIKE-2 KAT参数为`r=15581,w=35,t=263`，当前K-sign译码参数表的对应档为
`r=12589,w=35,t=263`。两个参数集的syndrome、密文长度和译码证据不可混用。形成官方端到端Decaps
KAT前，需要为`r=15581`建立明确的译码profile并分别完成RTL功能、固定周期和DFR验证；形成当前优化参数
完整KEM则需要生成`r=12589`的KeyGen/Encaps/Decaps一致向量。

`r=12589`固定求逆链由公开`r-2`二进制分解生成，包含13个主乘法阶段、6个累积乘法和最终平方，即
19次稠密环乘与20次Frobenius置换。197-word确定性输入的RTL输出逐word匹配独立扩展Euclid逆元，固定
24,863,614拍；既有`r=15581`官方输入继续匹配并保持43,978,192拍。

`TRIKE_MINSUM_KAT_V1` seed 1使用官方SM3语义产生`r=12589`的完整PK/SK/CT和Min-Sum Decaps记录。
Min-Sum固定7轮后residual为0，263项判决与H4原始错误完全一致，正常SS相等。`u/v`定向翻转分别完整
译码并以residual 6,304/6,309拒绝；`c2`定向翻转由H4重生成比较拒绝。三者均选择`sigma2`计算拒绝
SS。项目SK保留采样器原始support顺序，decoder使用块内升序视图以匹配DFR与`low_index` tie边界。

`trike_fixed_support_sorter`逐块缓存`WEIGHT`个坐标并执行固定bubble compare-swap调度，每块比较次数为
`WEIGHT*(WEIGHT-1)/2`。`r=12589,w=35`下三块连续握手的排序接口固定为1,996拍，只使用35×14 bit
逻辑存储；该逻辑bit数不是综合后的FF/BRAM结论。排序器已位于decoder装载桥输入侧，装载桥只把排序后
坐标写入H接口。toy `w=4`两组不同排列均固定43拍并逐项匹配升序结果。

`trike_decoder_error_vector`固定清零`3*PADDED_R_BYTES`后顺序请求全部`3r`个decoder判决bit，按块写成
padded dense error。`r=12589`下存储为4,800 byte，从start到完成固定42,569拍；toy `r=13`逐byte
匹配三个块的有效bit和零padding，固定53拍。逻辑容量和周期已经确定，BRAM映射与时序待Vivado验证。

Decaps后处理拆成三个固定调度模块。`trike_decaps_message_recover`两次重放4,800-byte `e'`计算`L(e')`
并输出`m'=c2 xor L(e')`，项目向量和全零error输入均固定28,431拍。`trike_decaps_reencrypt_verify`以
`m'||r2`驱动H4，固定比较全部4,800 byte，并按`decoder_ok && equal`选择`m'`或`sigma2`；匹配和首byte
扰动均固定209,659拍。`trike_decaps_kdf`两次重放`selected_message||ciphertext`，有效与拒绝路径均固定
19,323拍，32-byte SS逐byte匹配Python项目向量。三个模块均提供外部SM3压缩服务接口。

`trike_decaps_postprocess_core`把上述三段串成单一公开FSM，并通过external-compress接口顺序共享一个
`trike_sm3_service`。正常项目密文与`c2`首bit篡改密文均固定257,417拍；正常路径输出Encaps SS，篡改
路径完整执行L/H4/compare/K后选择`sigma2`并输出Python拒绝SS。Yosys层次检查确认该复合顶层恰好一个
`sm3_compress`实例。

`decoder_top.o_done`只表示固定轮数完成，不表示译码residual为零。`trike_decoder_residual_check`被动保存
与decoder相同的排序H和原始syndrome，随后按row/block/diag固定扫描`r*3w`条边，通过同步decision读口
重算`syndrome xor H*e'`。项目向量 residual为0；翻转一个syndrome bit后residual重量为1，两条路径均
固定2,668,869拍。该`o_residual_zero`作为postprocess的`decoder_ok`来源。

`trike_decaps_pipeline_core`连接syndrome、固定support排序/装载、`decoder_top`、padded decision存储、
residual重算和单SM3 postprocess。首个H块同时写入syndrome的H0 support RAM和完整H排序器，排序后的H
与原始syndrome bit同时扇出到decoder和residual checker。decoder的单一decision同步读口先分配给
error-vector writer，再分配给residual checker；两者完成后才开放error RAM给postprocess。编译时固定
profile的`PROFILE_DEFAULT`与对应参数宏一致，TRIKE160使用`r=12589,w=35,t=263`运行配置。

项目seed 1正常密文以及`u/v/c2`首bit篡改密文分别从独立复位后的start运行完整流水。四条路径都装载
105项support、各197个`t0/u/v` word、执行固定7轮Min-Sum、导出全部decision、重算全部residual并运行
完整L/H4/compare/K，均固定4,727,351拍。RTL residual重量依次为0/6,233/6,314/0；正常路径
`ciphertext_equal=1`并逐byte输出Encaps SS，三条篡改路径均`ciphertext_equal=0`并逐byte输出对应
`K(sigma2,tampered_ct)`。

`trike_decaps_synth_top`提供固定TRIKE160窄物理边界。外部按`SK || CT`连续装载5,206+3,180 byte，
只暴露8-bit input、8-bit SS和valid/ready/status。wrapper固定消费SK中的H0与sigma字段但不保存；原始
support写入105×14-bit RAM，t0/u/v各写入197×64-bit word RAM，r2和完整CT写入同步byte RAM，sigma2
写入256-bit寄存器。正常与u/v/c2篡改路径从wrapper start到最后一个SS byte接受均为4,737,077拍。
wrapper每次复位只接受一项事务，避免复用decoder只允许初次H/syndrome装载的状态。

未实现范围包括KeyGen板级I/O签核、完整Decaps的Vivado资源/时序报告，以及有效Encaps密文触发Min-Sum
失败的稀有DFR样本。C模型在非收敛`u/v`篡改样本上的residual重量为
6,304/6,309，与RTL判决不bit-exact，但两侧均为非零并产生相同隐式拒绝SS；不能把该样本写成decoder
bit-exact对拍。功能固定周期和单SM3层次结果不能替代物理实现签核。

## 验证状态

当前 RTL 通过：

```sh
make format-rtl
make check-format-rtl
make lint-rtl
make check-trike-sm3-sharing
make test-kem-unit
make test-trike-reference-kat
make test-trike-encaps-components-reference
make test-trike-encaps-hash-reference
make test-trike-encaps-core-reference
make test-trike-encaps-synth-reference
make test-trike-error-store-reference
make test-trike-h4-vector-reference
make test-trike-weak-key-reference
make test-trike-keygen-secret-reference
make test-trike-keygen-arith-reference
make test-trike-keygen-core-reference
make test-trike-keygen-synth-reference
make test-trike-poly-reference
make test-trike-poly-inv-reference
make test-trike-poly-inv-minsum-reference
make test-trike-decaps-syndrome-reference
make gen-trike-minsum-kem-case
make test-trike-decaps-message-reference
make test-trike-decaps-verify-reference
make test-trike-decaps-kdf-reference
make test-trike-decaps-postprocess-reference
make test-trike-decoder-residual-reference
make test-trike-decaps-pipeline-reference
make test-trike-decaps-synth-reference
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
make vivado-impl-trike-encaps \
  VIVADO_PART=xc7k355tffg901-2L \
  VIVADO_RUN_TAG=trike_encaps_baseline
make vivado-impl-trike-keygen \
  VIVADO_PART=xc7k355tffg901-2L \
  VIVADO_RUN_TAG=trike_keygen_baseline
make vivado-impl-trike-decaps \
  VIVADO_PART=xc7k355tffg901-2L \
  VIVADO_RUN_TAG=trike160_minsum_decaps_baseline
```

批处理入口按启动时间创建 `build/vivado/<timestamp>/..._k3` 或 `..._k4` 目录；可以用
`VIVADO_RUN_TAG=<label>`指定可读实验标签。不同K值和不同运行不会覆盖已有报告。

KEM公共核入口分别实现TRIKE-2求逆核、32-byte pseudohash核、完整Encaps核和完整KeyGen核，输出目录为
`build/vivado/<label>/trike_poly_inv`、`build/vivado/<label>/trike_pseudohash`与
`build/vivado/<label>/trike_encaps`、`build/vivado/<label>/trike_keygen`。四者使用100 MHz
`core_clk`、0.100 ns时钟不确定度和2 ns实现级I/O delay；wrapper不分配package pin，因此报告属于
公共核实现检查点，不是板级I/O签核。报告包含post-synth/post-route utilization、hierarchical
utilization、setup/hold top paths、timing summary、clock utilization、methodology、CDC、DRC、
messages和DCP。

完整Encaps的Vivado GUI综合顶层为`trike_encaps_synth_top`，外部仅保留8-bit输入、8-bit密文输出、
8-bit共享密钥输出及valid/ready控制。工程源文件清单与编译顺序由
`scripts/vivado_trike_kem_cores.tcl`的该top分支维护，约束使用`constraints/trike_kem_core.xdc`。

完整KeyGen的Vivado GUI综合顶层为`trike_keygen_synth_top`，外部仅保留8-bit随机输入、8-bit PK输出、
8-bit SK输出及valid/ready/status控制。工程源文件清单与编译顺序由同一Tcl脚本的该top分支维护，约束
同样使用`constraints/trike_kem_core.xdc`。

完整Min-Sum Decaps的Vivado顶层为`trike_decaps_synth_top`，固定宏为`TRIKE_160_PARAMS`、`L=32`、
`K=4`、`MSG_BITS=5`和`COLS_PER_TILE=256`。外部只保留8-bit `SK || CT`输入、8-bit SS输出、residual-zero、
ciphertext-equal和握手/status。`scripts/vivado_trike_kem_cores.tcl`维护完整decoder/SM3/Decaps源文件顺序；
实现输出到`build/vivado/<label>/trike_decaps`。

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
