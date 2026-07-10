# BIKE Min-Sum 译码器架构

本文档描述 RTL 的模块划分、数据通路、存储职责和控制边界。算法语义和顶层接口见 [bike_decoder.md](bike_decoder.md)，tile 几何见 [tile_decoder_design.md](tile_decoder_design.md)，固定窗口周期见 [decoder_schedule.md](decoder_schedule.md)。

## 设计目标

- 主译码路径固定执行公开参数决定的轮数和窗口数。
- H 第一列支撑集、syndrome、错误模式和译码收敛状态不改变主循环访问次数。
- C2V 和 V2C 使用 tile 级双缓冲重叠执行。
- check-state 使用迭代级 read/write pair 隔离读写。
- 地址生成、RAM 访问、CNU、VNU 和写回逻辑保持流水化，便于综合和时序收敛。

## 顶层模块

`decoder_top` 连接以下主要模块：

| 模块 | 职责 |
| --- | --- |
| `profile_config` | 根据公开 `i_param_level` 输出 `R/W/tile_count/row_seg_size/C_VAL/alpha` 等配置 |
| `tile_scheduler` | 产生固定窗口调度、tile/diag/lane 坐标、clear 周期、buffer 选择和完成状态 |
| `ram_i` | 存储 H 第一列每个支撑项的 `base_row_idx` |
| `edge_addr_gen` | 根据 tile 坐标和 `base_row_idx` 生成每 lane 的 row/col/diag/tile 地址 |
| `ram_m` | 存储压缩 check-state 的 magnitude 字段 |
| `ram_s` | 存储 V2C sign 状态 |
| `ram_syndrome` | 存储 syndrome bit |
| `cnu_b` | 从压缩 check-state 重建 C2V message |
| `ram_accum` | 存储 tile 内变量节点 raw C2V 总和 |
| `ram_t` | 缓存 tile 内每条边的 raw C2V |
| `vnu` | 根据 `c2v_sum` 和 `c2v_edge` 生成 posterior 与 V2C message |
| `cnu_a` | 用 V2C message 更新下一轮压缩 check-state |
| `ram_decision` | 存储最终错误估计 bit |

图文件位于 [figures/](../figures/)。

## 坐标流

调度器输出当前窗口坐标：

```text
h_block_idx
tile_idx
diag_idx_local
lane_group_idx
```

`ram_i` 根据 `h_block_idx` 和 `diag_idx_local` 读出 `base_row_idx`。`edge_addr_gen` 把这些坐标转换为：

```text
check_row_idx
col_idx
diag_idx_global
tile_offset
row_bank / row_addr
```

其中 `diag_idx_global = h_block_idx * W + diag_idx_local`，用于访问全局边相关状态；`diag_idx_local` 用于 tile 内边缓存地址和调度推进。

## C2V 数据通路

C2V 阶段从校验节点向变量节点发消息：

1. `edge_addr_gen` 产生当前 lane 的 `check_row_idx`、`diag_idx_global` 和 `tile_offset`。
2. `ram_m`、`ram_s`、`ram_syndrome` 读出压缩 check-state、边符号和 syndrome bit。
3. `cnu_b` 根据 `min1/min2/min_diag_idx_global/sign_xor` 重建 C2V message。
4. C2V message 转成二进制补码 `c2v_tc`。
5. `ram_accum` 对同一 `tile_offset` 执行读、累加、写回。
6. `ram_t` 保存单条边的 `c2v_tc`，供 V2C 执行排除自身计算。

首次迭代的 C2V 输入使用固定初始 check-state。无效 lane 的计算结果由 valid 屏蔽，不参与 RAM 写回。

## V2C 数据通路

V2C 阶段综合变量节点收到的校验建议，并更新下一轮 check-state：

1. `ram_accum` 读出当前变量列的 `c2v_sum`。
2. `ram_t` 读出当前边的 `c2v_edge`。
3. `vnu` 计算 posterior 和当前边的 V2C message。
4. V2C message 转成符号-幅度格式。
5. `cnu_a` 更新压缩 check-state 的 magnitude 字段。
6. `ram_m` 写入 updated compressed C2V state。
7. `ram_s` 写入 V2C sign。
8. final iteration 且 `diag_idx_local==0` 时，posterior sign 写入 `ram_decision`。

同一 check row 在流水中存在读写相关时，`decoder_top` 使用旁路路径向 `cnu_a` 提供最新压缩状态。

## 存储边界

| 存储 | 粒度 | 切换边界 | 读写关系 |
| --- | --- | --- | --- |
| `ram_i` | `N0 * W` 个 `base_row_idx` | H 加载后保持稳定 | 调度读 |
| `ram_m` | check row 压缩 magnitude state | 每轮迭代交换 pair | C2V 读 pair，V2C 写 pair |
| `ram_s` | `diag_idx_global` 和 check row 对应的 V2C sign | 与边状态一致 | C2V 读，V2C 写 |
| `ram_syndrome` | check row syndrome bit BRAM | 启动前写入 | C2V 同步读 |
| `ram_accum` | tile 内变量列 raw C2V sum | 每个 tile window 交换 buffer | C2V 写 buffer，V2C 读 buffer |
| `ram_t` | tile 内单条 raw C2V edge | 每个 tile window 交换 buffer | C2V 写 buffer，V2C 读 buffer |
| `ram_k_global` | 每变量 K-sign 压缩记录 | tile 读取完成后原地提交 | C2V/correction 读，V2C 写 |
| `ram_decision` | 变量列错误估计 bit BRAM | final iteration 写入 | 外部同步读 |

`ram_m` 的 pair 选择由 `decoder_top` 保存，并由 `tile_scheduler` 的每个 `iter_last_cycle` 触发交换。`ram_accum` 和 `ram_t` 的 buffer 选择由窗口编号奇偶性生成。K-sign 的 V2C 写回落后同一 tile 的 C2V 读取一个窗口，全局记录在旧值消费完成后原地更新。

## 控制边界

`tile_scheduler` 负责主循环调度：

- 当前 iteration、window、tile、diag、lane group。
- `c2v_valid`、`v2c_valid`、clear 周期和 done 状态。
- tile 级 buffer 选择。
- K-sign correction 阶段的固定调度。

`decoder_top` 负责局部流水控制：

- C2V/V2C valid 对齐。
- `ram_m` pair 选择和交换。
- final iteration decision 写使能。
- `ram_accum` 首条 diag 的累加基值选择。
- RAM 读写旁路和写使能屏蔽。

`edge_addr_gen` 和 RAM 模块负责局部地址、bank、chunk 和 lane valid 派生。主循环周期数只由公开参数和固定调度决定。

## 流水和固定时间

C2V 和 V2C 在 tile window 上错开一个窗口：

```text
window 0      : C2V(tile 0)
window 1      : C2V(tile 1) + V2C(tile 0)
...
last window   : V2C(last tile)
```

每个 tile 固定扫描 `W * Q_TILE` 个周期。guard、wrap split、无效 lane 和最后一个不满 tile 只改变 lane valid，不改变窗口长度。完整周期公式由 [decoder_schedule.md](decoder_schedule.md) 维护。

## 相关文档

- [tile_decoder_design.md](tile_decoder_design.md)：tile 内地址、guard、状态组织和 C2V/V2C 公式。
- [decoder_schedule.md](decoder_schedule.md)：调度状态、计数器和固定周期预算。
- [naming_conventions.md](naming_conventions.md)：RTL 命名规则。
- [decoder_verification.md](../verification/decoder_verification.md)：回归入口和检查项。
