# BIKE Syndrome 输入 Min-Sum 解码器

## 概述

本项目实现一个 BIKE/MDPC 风格的 syndrome 输入 min-sum 解码器。校验矩阵由 `N0` 个 circulant block 横向拼接：

```text
H = [H0 | H1 | ... | H(N0-1)]
```

每个 block 只通过第一列支撑集描述。第 `b` 个 block 的第 `k` 个支撑项使用线性 entry `b * W + k` 访问，本地变量列 `j` 对应的校验行为：

```text
base_row_idx = ram_i[b * W + k]
row = (j + base_row_idx) mod R
diag_idx_global = b * W + k
```

顶层接口包含 syndrome 写入、H 第一列写入、启动、错误估计读出和完成状态。译码主循环固定执行 `I_MAX` 轮，不使用收敛提前停止。

## 文档导航

- [decoder_hardware_design_guide.md](decoder_hardware_design_guide.md)：面向硬件设计初学者、按完整译码数据流组织的架构与实现说明
- [decoder_architecture.md](decoder_architecture.md)：模块划分、数据通路、存储职责和控制边界
- [tile_decoder_design.md](tile_decoder_design.md)：tile 几何、guard 规则、状态组织和 C2V/V2C 公式
- [decoder_schedule.md](decoder_schedule.md)：固定窗口调度、状态、计数器和周期预算
- [decoder_verification.md](../verification/decoder_verification.md)：回归入口、随机用例和残差检查
- [naming_conventions.md](naming_conventions.md)：RTL 命名规则

## 参数

`rtl/bike_pkg.sv` 包含公开参数、派生 tile 几何、消息格式和压缩 check-state field layout。

常用构建参数：

| 宏 | 参数 |
| --- | --- |
| 未指定等级宏 | 最大几何为 `N0=2`, `R=40973`, `W=137`, `T=264`, `I_MAX=7` |
| `BIKE_TOY_PARAMS` | `N0=2`, `R=8`, `W=3`, `T=1`, `I_MAX=4` |
| `BIKE_128_PARAMS` | `N0=2`, `R=12323`, `W=71`, `T=134`, `I_MAX=7` |
| `BIKE_192_PARAMS` | `N0=2`, `R=24659`, `W=103`, `T=199`, `I_MAX=7` |
| `BIKE_256_PARAMS` | `N0=2`, `R=40973`, `W=137`, `T=264`, `I_MAX=7` |
| `TRIKE_128_PARAMS` | `N0=3`, `R=8243`, `W=27`, `T=201`, `I_MAX=7` |
| `TRIKE_160_PARAMS` | `N0=3`, `R=12899`, `W=35`, `T=263`, `I_MAX=7` |
| `TRIKE_256_PARAMS` | `N0=3`, `R=29917`, `W=55`, `T=429`, `I_MAX=7` |
| `TRIKE_384_PARAMS` | `N0=3`, `R=63997`, `W=83`, `T=659`, `I_MAX=7` |
| `TRIKE_512_PARAMS` | `N0=3`, `R=106781`, `W=111`, `T=877`, `I_MAX=7` |
| `BIKE_UNIFIED_PARAMS` | 最大几何为 `N0=2`, `R=40973`, `W=137`, `T=264`, `I_MAX=7` |
| `TRIKE_UNIFIED_PARAMS` | 最大几何为 `N0=3`, `R=106781`, `W=111`, `T=877`, `I_MAX=7` |

覆盖宏：

- `BIKE_PARALLEL_L`：每周期 lane 数，默认 `32`
- `BIKE_COLS_PER_TILE`：每个 tile 的本地变量列数；`BIKE_UNIFIED_PARAMS` 默认 `576`，`TRIKE_UNIFIED_PARAMS` 默认 `1152`
- `BIKE_MSG_BITS`：sign-magnitude 消息总位宽，默认 `5`
- `BIKE_K_SIGN_K`：K-sign偏差位置数量，默认 `4`

Vivado GUI 工程可直接添加 RTL 源文件并使用默认 Verilog define 设置。该配置生成统一参数硬件。

顶层包含公开 profile 选择端口 `i_param_level`。`BIKE_UNIFIED_PARAMS` 配置使用该端口选择 BIKE-128/192/256 profile，`TRIKE_UNIFIED_PARAMS` 配置使用该端口选择 TRIKE-128/160/256/384/512 profile。配置表为选中 profile 输出 `R`、`W`、tile 数、row bank 深度、`C_VAL` 和 `alpha` 参数。存储和 datapath 按所选 family 的最大几何定宽，调度器按选中 profile 的公开边界执行固定窗口。

BIKE 官方参数表中的 `w` 为整行权重；RTL 中 `W` 表示每个 circulant block 的第一列非零数。BIKE 三档 profile 的整行权重为 `N0*W = 142/206/274`，TRIKE 五档 profile 的整行权重为 `N0*W = 81/105/165/249/333`。

TRIKE-128 使用 `C_VAL=4`、`alpha=0.1875`。BIKE profile 和 TRIKE-160/256 使用
`C_VAL=5`、`alpha=0.1875`。TRIKE-384 使用 `C_VAL=5`、`alpha=0.140625`。
TRIKE-512 使用 `C_VAL=7`、`alpha=0.0625`。

## 顶层输入输出

H 加载接口：

| 端口 | 含义 |
| --- | --- |
| `i_h_we` | 写入一个 H 第一列项 |
| `i_h_block_idx` | circulant block 编号 |
| `i_h_diag_idx_local` | block 内对角线编号，对应第一列支撑项编号 |
| `i_h_base_row_idx` | 第一列非零项行号 |
| `o_h_loaded` | 全部 H 第一列项已加载且未检测到错误 |
| `o_h_error` | H 第一列项越界或重复 |

译码接口：

| 端口 | 含义 |
| --- | --- |
| `i_syndrome_we/i_syndrome_addr/i_syndrome_wdata` | syndrome 写入 |
| `i_start` | 启动固定轮数译码 |
| `o_done` | 译码完成 |
| `o_iter_count` | 完成时等于 `I_MAX` |
| `i_e_read_col_idx/o_e_rdata` | 最终错误估计同步串行读口，地址到数据延迟一拍 |

`i_start` 在 `o_h_loaded && !o_h_error` 时生效。

## 解码语义

CNU_B 根据压缩 check state、边 sign 和 syndrome 生成 C2V：

```text
c2v_sign = sign_xor ^ v2c_sign ^ syndrome[row]
c2v_mag  = min2_mag if diag_idx_global == min_diag_idx_global else min1_mag
```

变量节点更新公式使用 raw C2V 求和并整体缩放：

```text
posterior = C_VAL + scale(sum(c2v_raw))
v2c_edge  = C_VAL + scale(sum(c2v_raw) - c2v_edge_raw)
```

V2C 写回更新下一轮压缩 check state：

```text
min1_mag, min2_mag, min_diag_idx_global, sign_xor
```

最后一轮的 posterior sign 写入错误估计存储。验证环境导出 `e_hat` 后计算 residual：

```text
residual = syndrome ^ H * e_hat
```

随机测试要求 residual 为 0，并检查 `e_hat` 与生成目标错误向量一致。

## 常用命令

```sh
make test
make test-bike-random BIKE_RANDOM_TRIALS=1
make check-format-rtl && make lint-rtl
make vivado-synth
```
