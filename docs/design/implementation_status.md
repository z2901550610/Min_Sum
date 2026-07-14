# RTL 实现状态与 Vivado 基线

本文档汇总统一 TRIKE K-sign 译码器的 RTL 结构、固定周期、存储组织、Vivado
资源占用、时序结果和验证状态。算法说明见
[k_sign_decoder_design.md](k_sign_decoder_design.md)，周期定义见
[decoder_schedule.md](decoder_schedule.md)。

## 基线配置

| 项目 | 配置 |
| --- | --- |
| 参数族 | `TRIKE_UNIFIED_PARAMS` |
| 最大公开参数等级 | TRIKE-512 |
| `N0 / R / W` | `3 / 108587 / 111` |
| 迭代数 `I_MAX` | 7 |
| message width | 5 bit，幅值 `D=4` bit |
| lane 并行度 `L` | 16 |
| `COLS_PER_TILE` | 1168 |
| `Q_BASE / Q_TILE` | `73 / 76` |
| `TILE_COUNT / TILES_TOTAL` | `93 / 279` |
| K-sign `K / POS_W` | `3 / 7` |
| FPGA | `xc7k355tffg901-2L` |
| Vivado | 2023.2 |
| 目标时钟 | 100 MHz，周期 10 ns |
| 时钟不确定度 | 0.100 ns |
| 报告阶段 | Fully Placed / Routed |

统一硬件使用最大参数确定存储和计数器几何。`i_param_level` 是公开输入，各参数等级使用公开固定的
`R`、`W`、tile 数和周期预算。

## 数据通路与控制

主译码器使用固定窗口调度：

- `edge_addr_gen` 使用两级地址流水，每拍接收一组 tile/diag/lane 坐标。
- `barrel_rotate` 完成 lane 到 bank 的请求路由和读数据返回。
- `ram_m` 使用两个 iteration pair，C2V 读取一个 pair，V2C 更新另一个 pair。
- `ram_accum` 和 `ram_t` 使用独立的 fill/active 双 buffer，使相邻 tile 的 C2V 与 V2C 重叠。
- `ram_m` 的翻转、V2C 写回和同地址读写使用固定旁路规则。
- `tile_scheduler` 根据公开参数选择 K-sign 扫描 correction 或直接 correction。
- invalid lane、invalid K 槽、syndrome、H 第一列内容和译码结果只控制 valid/写使能，不改变调度深度。
- 主循环固定执行 `I_MAX` 轮，不使用提前终止。

## RAM 组织

| 模块 | 物理组织 | 端口与时序 |
| --- | --- | --- |
| `ram_bram` | XPM 简单双口 block RAM；tile 工作存储可选择 distributed RAM | 同步写、同步读，read-first 语义 |
| `ram_i` | 两份 H 第一列 `base_row_idx` BRAM | C2V/V2C 双读视图；加载后执行固定周期合法性校验 |
| `ram_m` | `2 × L` 个压缩 check-state bank | pair 隔离；每 bank 同步读写；flip 具有固定旁路 |
| `ram_syndrome` | `L` 个 syndrome bit BRAM bank | 外部写入，C2V 同步读 |
| `ram_accum` | 两组 banked distributed RAM | C2V 读改写，V2C 读取 active buffer |
| `ram_t` | 每个 buffer、每个 lane 一份 BRAM | C2V 写 fill buffer，V2C 读 active buffer |
| `ram_k_tile` | `L` 个 distributed RAM 工作 bank | 保存活动 tile 的 K=3 无序 `(dev_pos, magnitude)` 槽 |
| `ram_k_global` | `L` 个原地更新全局 bank | C2V/correction 同步读，V2C 提交经寄存器后同步写 |
| `ram_decision` | `L` 个最终判决 bit BRAM bank | final iteration 写，外部同步读 |

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

最大参数下：

```text
KSIGN_BANK_DEPTH       = ceil(325761 / 16) = 20361
DIAG_SEG_COUNT         = ceil(20361 / 4096) = 5
dev_pos RAMB36/bank    = 3 fields × 5 segments = 15
base_sign RAMB36/bank  = 1
global K RAMB36        = 16 banks × (15 + 1) = 256
```

全局 K-sign RAM 占基线 RAMB36 总数的 `256 / 464`。tile 工作记录宽度为
`1 + 3 × (7 + 4) = 34 bit`，深度为 `Q_BASE=73`。

### K=3 更新器

`k_sign_update` 保存三个无序候选槽。每拍执行：

1. 根据 `v2c_sign XOR base_sign` 生成候选 valid。
2. 平衡归约树按 valid、magnitude、`diag_idx_local` 和 slot index 选出最差槽。
3. 候选幅值严格大于最差有效槽时替换；存在无效槽时优先填充无效槽。
4. 等幅值保持先进入且 `diag_idx_local` 较小的候选。

该组合结构直接连接 `ram_k_tile` 的 distributed RAM 写数据端口。

## 固定周期

TRIKE-512 基线参数：

```text
ROW_SEG_SIZE = ceil(108587 / 16) = 6787
T_MAIN       = (279 + 1) × 111 × 76 = 2362080
T_CORR_SCAN  = 111 × 76 = 8436
T_CORR_DIRECT= 3 × 16 × 73 = 3504
T_CORR       = 3504
T_ITER       = 6787 + 2362080 + 8 + 279 × 3504 = 3346491
T_DECODE     = 7 × 3346491 + 6 = 23425443
```

23,425,443 拍由公开参数完全确定。H 第一列、syndrome、错误模式、候选位置、候选幅值和 residual
不改变该周期数。

## Vivado 资源占用

下表为基线配置的 placed utilization：

| 资源 | 使用量 | 可用量 | 利用率 |
| --- | ---: | ---: | ---: |
| Slice LUT | 24,110 | 222,600 | 10.83% |
| LUT as Logic | 20,381 | 222,600 | 9.16% |
| LUT as Memory | 3,729 | 81,400 | 4.58% |
| Distributed RAM LUT | 3,520 | — | — |
| SRL LUT | 209 | — | — |
| Slice Register | 11,129 | 445,200 | 2.50% |
| Slice | 8,519 | 55,650 | 15.31% |
| Block RAM Tile | 505 | 715 | 70.63% |
| RAMB36E1 | 464 | 715 | 64.90% |
| RAMB18E1 | 82 | 1,430 | 5.73% |
| DSP48E1 | 1 | 1,440 | 0.07% |
| CARRY4 | 1,416 | — | — |
| Bonded IOB | 78 | 300 | 26.00% |
| BUFGCTRL | 1 | 32 | 3.13% |

资源压力由 BRAM Tile 主导。LUT 总量中 3,520 个用于 distributed RAM，主要承载 tile 工作状态；
寄存器和 DSP 利用率具有较大余量。

## Vivado 时序基线

| 指标 | 结果 |
| --- | ---: |
| 时钟周期 | 10.000 ns |
| 整体 WNS | +0.629 ns |
| `decoder_clk` 内部 WNS | +0.629 ns |
| TNS | 0.000 ns |
| WHS | +0.036 ns |
| THS | 0.000 ns |
| WPWS | +4.232 ns |

内部最差 setup 路径从 `tile_scheduler` 的 C2V tile index 寄存器到
`ram_k_global` slot 0、segment 3 的 RAMB36 enable 端口：

```text
Data Path Delay = 9.130 ns
logic           = 3.561 ns
route           = 5.569 ns
Logic Levels    = 8
```

该路径包含 correction 列地址乘加、bank/segment 选择和 BRAM 使能译码。路径延迟以布线为主，
实现评估同时关注 WNS、DSP 乘加和 route 比例。

XDC 定义 100 MHz 时钟、0.100 ns clock uncertainty 和异步复位 false path。core 级报告包含：

- 69 个普通输入端口没有 input delay。
- 1 个异步复位输入使用 false path。
- 7 个输出端口没有 output delay。
- methodology 报告包含 `DPIR-1=18` 和 `TIMING-18=76`。

板级或上层系统集成需要根据真实接口补充 I/O delay。RTL 内部时序判断使用
`decoder_clk` intra-clock 结果。

## 验证状态

基线 RTL 通过：

```sh
make test-unit
make test-integration
make check-format-rtl && make lint-rtl
```

顶层 toy 集成结果：

```text
residual = 0
exact    = 1
cycles   = 154
```

TRIKE-512、seed 1、`L=16`、`COLS_PER_TILE=1168` 的完整随机译码结果：

```text
iter            = 7
cycles          = 23425443
target_weight   = 877
output_weight   = 877
residual_weight = 0
exact           = 1
```

统一 TRIKE 多参数回归入口：

```sh
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1
```

Vivado 综合入口：

```sh
make vivado-synth-trike-unified-ksign
```

完整实现报告至少检查 utilization、timing summary、methodology、CDC 和 messages。

## 实现判据

同一器件、参数、约束和 Vivado 版本下，RTL 调整使用以下判据：

1. 固定译码周期和 correction 周期保持由公开参数决定。
2. 单元、集成和 TRIKE-512 随机译码结果保持一致。
3. 100 MHz 下 setup、hold 和 pulse width 无违例。
4. BRAM Tile 是存储优化的主要指标；RAMB36 与 RAMB18 需要按 Tile 等价关系共同评估。
5. LUT 优化同时检查 placed LUT、Slice 和关键路径，避免只依据 RTL 运算符数量判断收益。
6. 关键路径以 routed timing 为准，综合级逻辑层数仅作为定位信息。
