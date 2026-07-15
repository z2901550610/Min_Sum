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
| 报告阶段 | correction snapshot RTL 待运行 Fully Placed / Routed |

统一硬件使用最大参数确定存储和计数器几何。`i_param_level` 是公开输入，各参数等级使用公开固定的
`R`、`W`、tile 数和周期预算。

## 数据通路与控制

主译码器使用固定窗口调度：

- `edge_addr_gen` 使用两级地址流水，每拍接收一组 tile/diag/lane 坐标。
- `barrel_rotate` 完成 lane 到 bank 的请求路由和读数据返回。
- `ram_m` 使用两个 iteration pair，C2V 读取一个 pair，V2C 更新另一个 pair。
- `ram_sign_delta` 使用两个 iteration pair，C2V 读取 deviation parity，重叠 correction 更新另一个 pair。
- `ram_accum` 和 `ram_t` 使用独立的 fill/active 双 buffer，使相邻 tile 的 C2V 与 V2C 重叠。
- `ram_k_tile` 使用一份候选工作RAM和一份位置snapshot，使完成tile的correction与后续tile的V2C重叠。
- `ram_sign_delta` 的翻转读改写和连续同地址访问使用固定旁路规则。
- `k_sign_overlap_scheduler` 使用公开固定 tile/diag/lane 扫描深度。
- invalid lane、invalid K 槽、syndrome、H 第一列内容和译码结果只控制 valid/写使能，不改变调度深度。
- 主循环固定执行 `I_MAX` 轮，不使用提前终止。

## RAM 组织

| 模块 | 物理组织 | 端口与时序 |
| --- | --- | --- |
| `ram_bram` | XPM 简单双口 block RAM；tile 工作存储可选择 distributed RAM | 同步写、同步读，read-first 语义 |
| `ram_i` | 三份 H 第一列 `base_row_idx` BRAM | C2V/V2C/correction 三读视图；加载后执行固定周期合法性校验 |
| `ram_m` | `2 × L` 个压缩 check-state bank | pair 隔离；保存幅度状态和 base-sign parity |
| `ram_sign_delta` | `2 × L` 个 1-bit row-parity bank | pair 隔离；同步读、清空和 flip RMW |
| `ram_syndrome` | `L` 个 syndrome bit BRAM bank | 外部写入，C2V 同步读 |
| `ram_accum` | 两组 banked distributed RAM | C2V 读改写，V2C 读取 active buffer |
| `ram_t` | 每个 buffer、每个 lane 一份 BRAM | C2V 写 fill buffer，V2C 读 active buffer |
| `ram_k_tile` | `L` 个34-bit工作bank和 `L` 个21-bit snapshot bank | 工作RAM维护候选；snapshot供correction读取位置 |
| `ram_k_global` | `L` 个原地更新全局 bank | C2V 同步读，V2C 提交经寄存器后同步写 |
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

tile工作记录宽度为 `1 + 3 × (7 + 4) = 34 bit`，correction snapshot宽度为 `3 × 7 = 21 bit`，
两者深度均为 `Q_BASE=73`。最后一个对角线同时提交全局K-sign记录和snapshot；snapshot同步读写采用
read-first语义。

### K=3 更新器

`k_sign_update` 保存三个无序候选槽。每拍执行：

1. 根据 `v2c_sign XOR base_sign` 生成候选 valid。
2. 平衡归约树按 valid、magnitude、`diag_idx_local` 和 slot index 选出最差槽。
3. 候选幅值严格大于最差有效槽时替换；存在无效槽时优先填充无效槽。
4. 等幅值保持先进入且 `diag_idx_local` 较小的候选。

该组合结构直接连接 `ram_k_tile` 的 distributed RAM 写数据端口。

## 固定周期

TRIKE-512 参数：

```text
ROW_SEG_SIZE = ceil(108587 / 16) = 6787
T_MAIN       = (279 + 1) × 111 × 76 = 2362080
T_TILE       = 111 × 76 = 8436
T_ITER       = 6787 + 2362080 + 8 + 8436 = 2377311
T_DECODE     = 7 × 2377311 + 6 = 16641183
```

16,641,183 拍由公开参数完全确定。H 第一列、syndrome、错误模式、候选位置、候选幅值和 residual
不改变该周期数。

| 参数等级 | 固定周期 | 100 MHz 延时 |
| --- | ---: | ---: |
| TRIKE128 | 333,990 | 3.33990 ms |
| TRIKE160 | 657,341 | 6.57341 ms |
| TRIKE256 | 2,353,770 | 23.53770 ms |
| TRIKE384 | 7,135,995 | 71.35995 ms |
| TRIKE512 | 16,641,183 | 166.41183 ms |

## Vivado 资源占用

correction snapshot RTL的placed utilization待测。需要检查Slice LUT、LUT as Logic、LUT as Memory、
Distributed RAM LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP和CARRY4。工作状态的逻辑容量为
64,240 bit；资源映射和相对上一placed基线的增减量必须以新报告为准。

## Vivado 时序状态

correction snapshot RTL的routed timing待测。目标约束为10.000 ns，clock uncertainty为0.100 ns；需要检查
整体WNS/TNS、`decoder_clk`内部WNS、WHS/THS、WPWS和setup top paths。XDC定义100 MHz时钟和异步
复位false path；板级或上层系统集成需要根据真实接口补充I/O delay。

## 验证状态

当前 RTL 通过：

```sh
make test-unit
make test-integration
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1
```

维护范围内的修改文件通过 Verible 格式检查与 lint。工作区未跟踪的 `rtl/test.sv` 不属于本次修改范围，
因此没有执行会包含该文件的完整 `make check-format-rtl && make lint-rtl`。

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
```

Vivado 综合入口：

```sh
make vivado-synth-trike-unified-ksign
```

correction snapshot RTL的Fully Placed utilization、Routed timing summary、methodology、CDC和完整
messages报告待运行。

## 实现判据

同一器件、参数、约束和 Vivado 版本下，RTL 调整使用以下判据：

1. 固定译码周期和 correction 周期保持由公开参数决定。
2. 单元、集成和 TRIKE-512 随机译码结果保持一致。
3. 100 MHz 下 setup、hold 和 pulse width 无违例。
4. BRAM Tile 是存储优化的主要指标；RAMB36 与 RAMB18 需要按 Tile 等价关系共同评估。
5. LUT 优化同时检查 placed LUT、Slice 和关键路径，避免只依据 RTL 运算符数量判断收益。
6. 关键路径以 routed timing 为准，综合级逻辑层数仅作为定位信息。
