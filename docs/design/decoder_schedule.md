# 解码调度

## 固定窗口

调度器按固定 tile 顺序执行。一个 tile 的逻辑坐标为：

```text
tile_linear = h_block_idx * TILE_COUNT + tile_idx
tile_base   = tile_idx * COLS_PER_TILE
```

`edge_addr_gen` 使用两级流水：第一级寄存 tile、wrap 和参数上下文，第二级计算每个
bank 的 lane 偏移与行地址。流水每拍接收一组地址请求，内部延迟不改变固定窗口长度。

每个迭代先执行 `ROW_SEG_SIZE` 个 check-state 写 pair 清空周期。每个 tile 固定执行：

```text
W * Q_TILE
```

个主窗口周期。一个迭代包含 `TILES_TOTAL + 1` 个主窗口：

```text
T_MAIN = (TILES_TOTAL + 1) * W * Q_TILE
```

第一个窗口执行 tile 0 的 C2V 填充，最后一个窗口执行最后一个 tile 的 V2C 排空，中间窗口同时执行当前 tile 的 C2V 和前一个 tile 的 V2C。

K-sign correction 对每个公开参数等级固定选择以下较短窗口：

```text
T_CORR_SCAN   = W * Q_TILE
T_CORR_DIRECT = K * L * Q_BASE
T_CORR        = min(T_CORR_SCAN, T_CORR_DIRECT)
```

扫描模式使用 `diag_idx_local` 和 `lane_group_idx` 检查 L 列。直接模式使用 `lane_group_idx`、`ksign_slot_idx` 和 `ksign_lane_idx`，每拍串行处理一个保留位置。两种模式都执行公开固定数量的周期。

K-sign 每个迭代的调度周期数和顶层可见译码周期数为：

```text
T_ITER   = ROW_SEG_SIZE + T_MAIN + 8 + TILES_TOTAL * T_CORR
T_DECODE = I_MAX * T_ITER + 6
```

## 可见状态

| 状态 | 含义 |
| --- | --- |
| `DEC_WAIT_START` | 等待合法启动 |
| `DEC_ITER_CLEAR` | check-state 写 pair 初始化 |
| `DEC_ITER_C2V_PRIME` | 首 tile C2V 填充 |
| `DEC_ITER_OVERLAP` | C2V(tile n) 与 V2C(tile n-1) 重叠 |
| `DEC_ITER_V2C_DRAIN` | 尾 tile V2C 排空 |
| `DEC_ITER_KSIGN_CORR` | K-sign 固定 correction 窗口 |
| `DEC_DONE` | 固定轮数完成 |

`o_iter_count` 在完成时等于 `I_MAX`。

## 计数器

`tile_scheduler` 维护：

| 计数器 | 范围 |
| --- | --- |
| `clear_addr` | `0 .. ROW_SEG_SIZE-1` |
| `window_idx` | `0 .. TILES_TOTAL` |
| `diag_idx_local` | `0 .. W-1` |
| `lane_group_idx` | `0 .. Q_TILE-1` |
| `ksign_slot_idx` | `0 .. K-1`，直接 correction 模式 |
| `ksign_lane_idx` | `0 .. L-1`，直接 correction 模式 |
| `iter_count` | `0 .. I_MAX` |

`clear_addr` 在迭代开始递增；清空完成后进入 tile 窗口。`lane_group_idx` 最内层递增；`lane_group_idx` 到达 `Q_TILE-1` 后推进 `diag_idx_local`；`diag_idx_local` 到达 `W-1` 后推进 `window_idx`；最后一个窗口结束后推进迭代。

## 调度输出

每个周期根据 `window_idx` 生成两个 tile 坐标：

```text
c2v_tile = window_idx
v2c_tile = window_idx - 1
```

有效条件：

```text
c2v_valid = running && !clear_valid && c2v_tile < TILES_TOTAL
v2c_valid = running && !clear_valid && window_idx > 0
```

tile 坐标展开：

```text
h_block_idx = tile_linear / TILE_COUNT
tile_idx    = tile_linear % TILE_COUNT
```

双缓冲选择：

```text
fill_buf   = window_idx[0]
active_buf = ~window_idx[0]
```

## 启动与完成

`decoder_top` 对启动做 H load gate：

```text
decode_start = i_start && o_h_loaded && !o_h_error
```

调度器收到 `decode_start` 后从迭代 0、窗口 0、H 第一列项 0、`lane_group_idx=0` 开始。主窗口排空后执行 K-sign correction；最后一个 correction 坐标和固定流水排空完成后拉高 `o_done`。

## 常量时间属性

H 第一列项数、tile 数、guard 周期数、迭代轮数和 correction 模式都由公开参数决定。H base row、K-sign 位置、候选有效位、syndrome 和错误模式只影响写使能及地址，不影响窗口数量。
