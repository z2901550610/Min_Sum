# 解码调度

## 固定窗口

调度器按固定 tile 顺序执行。一个 tile 的逻辑坐标为：

```text
tile_linear = h_block_idx * TILE_COUNT + tile_idx
tile_base   = tile_idx * C_TILE
```

每个迭代先执行 `ROW_SEG_SIZE` 个 check-state 写 pair 清空周期。每个 tile 固定执行：

```text
W * Q_TILE
```

个主窗口周期。一个迭代包含 `TILES_TOTAL + 1` 个窗口：

```text
T_ITER = ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE
```

第一个窗口执行 tile 0 的 C2V 填充，最后一个窗口执行最后一个 tile 的 V2C 排空，中间窗口同时执行当前 tile 的 C2V 和前一个 tile 的 V2C。

完整译码周期数：

```text
T_DECODE = I_MAX * (ROW_SEG_SIZE + (TILES_TOTAL + 1) * W * Q_TILE)
```

## 可见状态

| 状态 | 含义 |
| --- | --- |
| `DEC_WAIT_START` | 等待合法启动 |
| `DEC_ITER_CLEAR` | check-state 写 pair 初始化 |
| `DEC_ITER_C2V_PRIME` | 首 tile C2V 填充 |
| `DEC_ITER_OVERLAP` | C2V(tile n) 与 V2C(tile n-1) 重叠 |
| `DEC_ITER_V2C_DRAIN` | 尾 tile V2C 排空 |
| `DEC_DONE` | 固定轮数完成 |

`o_iter_count` 在完成时等于 `I_MAX`。

## 计数器

`tile_scheduler` 维护：

| 计数器 | 范围 |
| --- | --- |
| `clear_addr` | `0 .. ROW_SEG_SIZE-1` |
| `window_idx` | `0 .. TILES_TOTAL` |
| `one_idx` | `0 .. W-1` |
| `q_seq` | `0 .. Q_TILE-1` |
| `iter_count` | `0 .. I_MAX` |

`clear_addr` 在迭代开始递增；清空完成后进入 tile 窗口。`q_seq` 最内层递增；`q_seq` 到达 `Q_TILE-1` 后推进 `one_idx`；`one_idx` 到达 `W-1` 后推进 `window_idx`；最后一个窗口结束后推进迭代。

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

调度器收到 `decode_start` 后从迭代 0、窗口 0、H 第一列项 0、`q_seq=0` 开始。达到第 `I_MAX` 轮最后一个窗口最后一个 `q_seq` 时拉高 `o_done`。

## 常量时间属性

H 第一列项数、tile 数、guard 周期数、迭代轮数都由公开参数决定。H base row 只影响 lane valid mask 和 wrap split 位置，不影响窗口数量。
