# RTL 实现状态与 Vivado 基线

本文档汇总统一 TRIKE K-sign 译码器的 RTL 结构、固定周期、存储组织、Vivado
资源占用、时序结果和验证状态。算法说明见
[k_sign_decoder_design.md](k_sign_decoder_design.md)，周期定义见
[decoder_schedule.md](decoder_schedule.md)。

## 基线配置

仓库统一TRIKE K-sign默认构建配置为 `L=32`、`K=4`、`COLS_PER_TILE=1152`。该配置已完成功能验证、
Fully Placed资源报告和Routed时序报告。

| 项目 | 配置 |
| --- | --- |
| 参数族 | `TRIKE_UNIFIED_PARAMS` |
| 最大公开参数等级 | TRIKE-512 |
| `N0 / R / W` | `3 / 108587 / 111` |
| 迭代数 `I_MAX` | 7 |
| message width | 5 bit，幅值 `D=4` bit |
| lane 并行度 `L` | 32 |
| `COLS_PER_TILE` | 1152 |
| `Q_BASE / Q_TILE` | `36 / 39` |
| `TILE_COUNT / TILES_TOTAL` | `95 / 285` |
| K-sign `K / POS_W` | `4 / 7` |
| FPGA | `xc7k355tffg901-2L` |
| Vivado | 2023.2 |
| 目标时钟 | 100 MHz，周期 10 ns |
| 时钟不确定度 | 0.100 ns |
| 报告阶段 | 2026-07-22 Fully Placed资源 / Routed时序 |

统一硬件使用最大参数确定存储和计数器几何。`i_param_level` 是公开输入，各参数等级使用公开固定的
`R`、`W`、tile 数和周期预算。

## 数据通路与控制

主译码器使用固定窗口调度：

- `edge_addr_gen` 使用两级地址流水，每拍接收一组 tile/diag/lane 坐标。
- `barrel_rotate` 完成 lane 到 bank 的请求路由和读数据返回。
- `ram_m` 使用两个 iteration pair，C2V 读取一个 pair，V2C 更新另一个 pair。
- `ram_sign_delta` 使用两个 iteration pair，C2V 读取 deviation parity，重叠 correction 更新另一个 pair。
- `ram_accum` 和 `ram_t` 使用独立的 fill/active 双 buffer，使相邻 tile 的 C2V 与 V2C 重叠；两个buffer
  选择恒为互补。
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
| `ram_accum` | 两组单读口 banked distributed RAM | 每个物理buffer在C2V/V2C之间共享一个读地址；C2V读改写 |
| `ram_t` | 每个buffer、每个tile-offset bank一份深度 `W × Q_BASE` 的BRAM | 请求按tile offset旋转；C2V写fill buffer，V2C读active buffer |
| `ram_k_tile` | `L` 个34-bit工作bank和 `L` 个21-bit snapshot bank | 工作RAM维护候选；snapshot供correction读取位置 |
| `ram_k_global` | `L` 个原地更新全局 bank | C2V 同步读，V2C提交同步写；完成后同步输出最终判决 |

TRIKE K-sign 配置不实例化完整符号存储 `ram_s`。C2V 符号由全局 K-sign 记录重建。

### 全局 K-sign RAM

每变量逻辑记录为：

```text
base_sign : 1 bit
dev_pos   : K × POS_W = 3 × 7 bit
record    : 22 bit
```

`ram_k_global` 使用以下物理映射：

- `base_sign` 使用独立 1-bit 全深度字段。
- slot 0、slot 1 和 slot 2 分别使用 7-bit 字段。
- 三个 `dev_pos` 字段按 RAMB36 的 `4K × 9` 原生几何划分深度段。
- 写 valid、bank 地址和记录数据先寄存，再驱动各段写端口。
- 读 segment 编号与同步读延迟对齐，随后完成字段组合和 lane 返回路由。
- `o_done` 有效后，外部列地址从 lane 0 请求通道进入同一读路径，`base_sign` 位连接到 `o_e_rdata`。

最大参数下：

```text
KSIGN_BANK_DEPTH       = ceil(325761 / 16) = 20361
DIAG_SEG_COUNT         = ceil(20361 / 4096) = 5
dev_pos RAMB36/bank    = 3 fields × 5 segments = 15
base_sign RAMB36/bank  = 1
global K RAMB36        = 16 banks × (15 + 1) = 256
```

tile工作记录宽度为 `1 + 3 × (7 + 4) = 34 bit`，correction snapshot宽度为 `3 × 7 = 21 bit`，
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
ROW_SEG_SIZE = ceil(108587 / 32) = 3394
T_MAIN       = (285 + 1) × 111 × 39 = 1238094
T_TILE       = 111 × 39 = 4329
T_ITER       = 3394 + 1238094 + 8 + 4329 = 1245825
T_DECODE     = 7 × 1245825 + 6 = 8720781
```

8,720,781 拍由公开参数完全确定。H 第一列、syndrome、错误模式、候选位置、候选幅值和 residual
不改变该周期数。

| 参数等级 | 固定周期 | 100 MHz 延时 |
| --- | ---: | ---: |
| TRIKE128 | 193,486 | 1.93486 ms |
| TRIKE160 | 365,945 | 3.65945 ms |
| TRIKE256 | 1,207,716 | 12.07716 ms |
| TRIKE384 | 3,729,550 | 37.29550 ms |
| TRIKE512 | 8,720,781 | 87.20781 ms |

## Vivado 资源占用

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

### K=4可选配置

K=4的全局记录宽度为29 bit，tile工作记录为45 bit，correction snapshot为28 bit。全局K RAM使用
336个RAMB36，其中16个保存base sign，320个保存四个位置字段。最终判决由这16个base-sign RAMB36
直接提供，不额外分配判决存储。2026-07-17 Fully Placed aggregate utilization如下：

| 资源 | 使用量 | 器件可用量 | 利用率 |
| --- | ---: | ---: | ---: |
| Slice LUT | 28,243 | 222,600 | 12.69% |
| LUT as Logic | 23,924 | 222,600 | 10.75% |
| LUT as Memory | 4,319 | 81,400 | 5.31% |
| Distributed RAM LUT | 4,160 | — | — |
| SRL LUT | 159 | — | — |
| Slice Register | 11,489 | 445,200 | 2.58% |
| Slice | 9,911 | 55,650 | 17.81% |
| Block RAM Tile | 553.5 | 715 | 77.41% |
| RAMB36E1 | 496 | 715 | 69.37% |
| RAMB18E1 | 115 | 1,430 | 8.04% |
| DSP | 0 | 1,440 | 0.00% |
| CARRY4 | 1,819 | — | — |

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

该配置的最大等级 `Q_BASE/Q_TILE=36/39`、`TILE_COUNT=95`、`TILES_TOTAL=285`。TRIKE-512固定周期为
8,720,781，100 MHz固定译码时间为87.20781 ms。五档功能回归通过。2026-07-22 Fully Placed aggregate
utilization如下：

| 资源 | 使用量 | 器件可用量 | 利用率 |
| --- | ---: | ---: | ---: |
| Slice LUT | 48,027 | 222,600 | 21.58% |
| LUT as Logic | 43,580 | 222,600 | 19.58% |
| LUT as Memory | 4,447 | 81,400 | 5.46% |
| Distributed RAM LUT | 4,160 | — | — |
| SRL LUT | 287 | — | — |
| Slice Register | 20,946 | 445,200 | 4.70% |
| Slice | 16,053 | 55,650 | 28.85% |
| Block RAM Tile | 561.5 | 715 | 78.53% |
| RAMB36E1 | 512 | 715 | 71.61% |
| RAMB18E1 | 99 | 1,430 | 6.92% |
| DSP | 0 | 1,440 | 0.00% |
| CARRY4 | 2,998 | — | — |

该配置剩余153.5个Block RAM Tile。全局K记录使用两个18-bit配对字段，每个bank各实例化10个RAMB36，
32个bank合计320个RAMB36；相对配对前配置，全设计减少64个RAMB36和32个RAMB18，精确减少80个
Block RAM Tile。报告为aggregate utilization；物理归属由显式XPM实例几何和aggregate总量的精确变化
交叉确认，尚无同次hierarchical utilization报告。

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

最近完整K=4基线的2026-07-17 Routed timing满足内部100 MHz约束。整体及 `decoder_clk` 组setup
WNS/TNS均为 `+0.547 ns / 0.000 ns`。hold WHS/THS为 `+0.027 ns / 0.000 ns`，WPWS/TPWS为
`+4.232 ns / 0.000 ns`。

最差主时钟路径从K-sign selector的bank 0局部位置索引寄存器到 `ram_k_tile` bank 10的snapshot
distributed RAM写入口，数据路径9.013 ns，其中logic 1.245 ns、route 7.768 ns，共12级逻辑。最差异步
路径从同步复位寄存器到 `ram_k_global` bank 6的segment选择寄存器CLR端，数据路径8.858 ns，其中route
占96.207%。全局base-sign RAM到 `o_e_rdata` 的未约束外部输出路径数据延迟为12.743 ns；接口签核要求
与K=3相同。

K=4、L=32可选配置的2026-07-20 Routed timing满足内部100 MHz约束。整体及 `decoder_clk` 组setup
WNS/TNS均为 `+0.226 ns / 0.000 ns`，hold WHS/THS为 `+0.033 ns / 0.000 ns`，WPWS/TPWS为
`+4.232 ns / 0.000 ns`。最差主时钟路径从 `v2c_tile_offset_c_reg[13][7]` 到 `ram_k_tile` bank 9工作
distributed RAM的读数据寄存器，数据路径9.533 ns，其中route为9.267 ns、占97.210%。最差异步复位
释放路径WNS为+3.243 ns。

该配置内部未约束endpoint为0；69个普通输入和7个输出没有I/O delay，另有1个输入由false path覆盖。
`o_e_rdata` 的未约束外部输出路径数据延迟为14.597 ns，板级接口签核要求与其他配置相同。

K=4、`L=32`、`COLS_PER_TILE=1152` 默认配置的2026-07-22 Routed timing满足内部100 MHz约束。整体及
`decoder_clk` 组setup WNS/TNS均为 `+0.590 ns / 0.000 ns`，hold WHS/THS为
`+0.027 ns / 0.000 ns`，WPWS/TPWS为 `+4.232 ns / 0.000 ns`；异步复位释放路径WNS为
`+3.239 ns`。最差主时钟路径从 `v2c_tile_offset_c_reg[27][10]` 的布局复制寄存器到K-sign selector
bank 29工作distributed RAM的读数据寄存器，数据路径9.303 ns，其中route为9.037 ns、占97.141%。
correction snapshot到 `ram_sign_delta` 的路径未进入前十条setup路径。

该配置内部未约束endpoint为0；TIMING-18报告76项，69个普通输入和7个输出没有I/O delay，另有1个输入
由false path覆盖。`o_e_rdata` 的未约束外部输出路径数据延迟为14.515 ns，因此内部100 MHz通过不等于
板级I/O时序已经签核。

## 验证状态

当前 RTL 通过：

```sh
make test
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1 TRIKE_UNIFIED_KSIGN_K=4
```

维护范围内的RTL和testbench通过Verible格式检查与lint。toy集成测试同时检查syndrome未完成时不接受
启动、译码运行期间的重复 `i_start` 不重启固定调度，以及同一H下第二帧启动时 `o_done` 清除并保持154拍
固定周期。

K=3和K=4统一TRIKE五档、seed 1完整随机译码均为residual 0、exact 1，固定周期分别为333,990、
657,341、2,353,770、7,135,995和16,641,183。

K=4、`L=32`、`COLS_PER_TILE=1184` 的统一TRIKE五档seed 1随机译码均为residual 0、exact 1，固定周期
分别为175,720、345,855、1,192,316、3,685,394和8,664,060。

仓库默认的K=4、`L=32`、`COLS_PER_TILE=1152` 统一TRIKE五档seed 1随机译码均为residual 0、exact 1，
固定周期分别为193,486、365,945、1,207,716、3,729,550和8,720,781。

顶层 toy 集成结果：

```text
residual = 0
exact    = 1
cycles   = 154
```

TRIKE-512、seed 1、`L=16`、`COLS_PER_TILE=1168` 的完整随机译码结果：

```text
iter            = 7
cycles          = 16641183
target_weight   = 877
output_weight   = 877
residual_weight = 0
exact           = 1
```

统一 TRIKE、seed 1 的五档完整随机译码均为 residual 0、exact 1，周期依次为
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
```

批处理入口按启动时间创建 `build/vivado/<timestamp>/..._k3` 或 `..._k4` 目录；可以用
`VIVADO_RUN_TAG=<label>`指定可读实验标签。不同K值和不同运行不会覆盖已有报告。

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
