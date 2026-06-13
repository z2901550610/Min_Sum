# BIKE Syndrome 输入 Min-Sum 解码器

## 概述

本项目实现一个 BIKE/MDPC 风格的 syndrome 输入 min-sum 解码器。校验矩阵由 `N0` 个 circulant block 横向拼接：

```text
H = [H0 | H1 | ... | H(N0-1)]
```

每个 block 只通过第一列支撑集描述。第 `b` 个 block 的第 `k` 个支撑项为 `h_matrix_mem[b][k]`，本地变量列 `j` 对应的校验行为：

```text
row = (j + h_matrix_mem[b][k]) mod R
edge_id = b * W + k
```

顶层接口包含 syndrome 写入、H 第一列写入、启动、错误估计读出和完成状态。译码主循环固定执行 `I_MAX` 轮，不使用收敛提前停止。

## 文档导航

- [decoder_architecture.md](decoder_architecture.md)：模块划分、状态数组和数据通路
- [decoder_schedule.md](decoder_schedule.md)：tile 固定窗口调度
- [tile_decoder_design.md](tile_decoder_design.md)：tile 几何、guard 规则和存储组织
- [decoder_verification.md](decoder_verification.md)：回归入口、随机用例和残差检查
- [naming_conventions.md](naming_conventions.md)：当前 RTL 命名规则

## 参数

`rtl/bike_pkg.sv` 包含公开参数、派生 tile 几何、消息格式和压缩 check-state field layout。

常用构建参数：

| 宏 | 参数 |
| --- | --- |
| `BIKE_TOY_PARAMS` | `N0=2`, `R=8`, `W=3`, `T=1`, `I_MAX=4` |
| `BIKE_128_PARAMS` | `N0=3`, `R=8117`, `W=27`, `T=201`, `I_MAX=7` |
| `BIKE_160_PARAMS` | `N0=3`, `R=12739`, `W=35`, `T=263`, `I_MAX=7` |
| `BIKE_256_PARAMS` | `N0=3`, `R=29501`, `W=55`, `T=429`, `I_MAX=7` |
| `BIKE_384_PARAMS` | `N0=3`, `R=59069`, `W=83`, `T=659`, `I_MAX=7` |
| `BIKE_512_PARAMS` | `N0=3`, `R=108587`, `W=111`, `T=877`, `I_MAX=7` |

覆盖宏：

- `BIKE_PARALLEL_L`：每周期 lane 数，默认 `8`
- `BIKE_C_TILE`：每个 tile 的本地变量列数，默认 `288`
- `BIKE_MSG_BITS`：sign-magnitude 消息总位宽，默认 `5`

128/160/256 参数使用 `C_VAL=5`、`alpha=0.1875`。384 参数使用 `C_VAL=5`、`alpha=0.140625`。512 参数使用 `C_VAL=7`、`alpha=0.0625`。

## 顶层输入输出

H 加载接口：

| 端口 | 含义 |
| --- | --- |
| `i_h_we` | 写入一个 H 第一列项 |
| `i_h_block_idx` | circulant block 编号 |
| `i_h_one_idx` | block 第一列中第几个非零项 |
| `i_h_base_row` | 第一列非零项行号 |
| `o_h_loaded` | 全部 H 第一列项已加载且未检测到错误 |
| `o_h_error` | H 第一列项越界或重复 |

译码接口：

| 端口 | 含义 |
| --- | --- |
| `i_syndrome_we/i_syndrome_addr/i_syndrome_wdata` | syndrome 写入 |
| `i_start` | 启动固定轮数译码 |
| `o_done` | 译码完成 |
| `o_iter_count` | 完成时等于 `I_MAX` |
| `i_e_read_col_idx/o_e_rdata` | 最终错误估计串行读口 |

`i_start` 在 `o_h_loaded && !o_h_error` 时生效。

## 解码语义

CNU_B 根据压缩 check state、边 sign 和 syndrome 生成 C2V：

```text
c2v_sign = sign_xor ^ v2c_sign ^ syndrome[row]
c2v_mag  = min2_mag if edge_id == min_edge_id else min1_mag
```

变量节点更新公式使用 raw C2V 求和并整体缩放：

```text
posterior = C_VAL + scale(sum(c2v_raw))
v2c_edge  = C_VAL + scale(sum(c2v_raw) - c2v_edge_raw)
```

V2C 写回更新下一轮压缩 check state：

```text
min1_mag, min2_mag, min_edge_id, sign_xor
```

最后一轮的 posterior sign 写入错误估计存储。验证环境导出 `e_hat` 后计算：

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
