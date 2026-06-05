# Support-Major Tile Min-Sum 解码器设计

## 目标

support-major tile 架构按第一列 support 项扫描 QC-MDPC 校验矩阵边。设计目标：

- 主译码周期由公开参数固定决定。
- support 值只影响 lane valid mask 和 row/col 地址。
- C2V 和 V2C 以 tile 双缓冲重叠执行。
- 变量节点更新公式使用 raw C2V 求和后整体缩放。
- 每个公开参数集可独立选择 `L` 和 `C_TILE`。

## 派生常量

```text
N            = N0 * R
C_TILE       = min(R, BIKE_C_TILE)
Q_BASE       = ceil(C_TILE / L)
Q_TILE       = Q_BASE + 1
TILE_COUNT   = ceil(R / C_TILE)
TILES_TOTAL  = N0 * TILE_COUNT
ROW_SEG_SIZE = ceil(R / L)
```

`Q_TILE` 包含一个固定 guard 周期。`C_TILE` 要求为 `L` 的整数倍。

## Support 几何

第 `b` 个 block 的第 `k` 个 support 项：

```text
s       = support_mem[b][k]
edge_id = b * W + k
```

tile 内变量列：

```text
tile_base = tile_idx * C_TILE
offset    = q_idx * L + lane
col_local = tile_base + offset
col_idx   = b * R + col_local
row_raw   = col_local + s
row_idx   = row_raw - R if row_raw >= R else row_raw
```

lane 有效条件：

```text
phase_valid && q_idx < Q_BASE && offset < tile_cols
```

## Guard 规则

跨越 `R-1 -> 0` 的 L-wide 访问组被拆成两个 micro-cycle。row/col 生成器先计算：

```text
wrap_col    = R - s
has_wrap    = tile_base < wrap_col && wrap_col < tile_end
wrap_offset = wrap_col - tile_base
wrap_q      = wrap_offset / L
wrap_lane   = wrap_offset % L
split_en    = has_wrap && wrap_lane != 0
```

`split_en=0`：

```text
q_seq < Q_BASE : q_idx = q_seq
q_seq = Q_BASE : invalid guard
```

`split_en=1`：

```text
q_seq < wrap_q     : q_idx = q_seq
q_seq = wrap_q     : q_idx = wrap_q, lane <  wrap_lane
q_seq = wrap_q + 1 : q_idx = wrap_q, lane >= wrap_lane
q_seq > wrap_q + 1 : q_idx = q_seq - 1
```

所有支撑项固定执行 `Q_TILE` 个 `q_seq`。

## 迭代窗口

一个 tile 的固定窗口周期：

```text
T_TILE = W * Q_TILE
```

一个迭代的固定窗口周期：

```text
T_ITER = (TILES_TOTAL + 1) * T_TILE
```

完整译码：

```text
T_DECODE = I_MAX * T_ITER
```

## 状态组织

| 状态 | 访问方式 |
| --- | --- |
| compressed check state | `comp_pair[pair][row_idx]` |
| check-state epoch | `comp_epoch[pair][row_idx]` |
| V2C sign | `sign_mem[edge_id][row_idx]` |
| tile raw C2V sum | `tile_accum[buf][tile_offset]` |
| tile raw C2V edge | `tile_t[buf][lane][one_idx * Q_TILE + q_seq]` |
| decision bit | `decision_mem[col_idx]` |

`tile_accum` 和 `tile_t` 使用 `fill_buf/active_buf` 双缓冲。compressed check state 使用 `comp_read_pair_sel/comp_write_pair_sel` 双 pair。

## C2V

每个有效 lane：

```text
comp = first_iter ? FIRST_ITER_C2V_COMP : comp_or_init(comp_read_pair_sel, row_idx)
c2v  = cnu_b(comp, sign_mem[edge_id][row_idx], syndrome_mem[row_idx], edge_id)
raw  = signmag_to_tc(c2v)
tile_accum[fill_buf][tile_offset] += raw
tile_t[fill_buf][lane][t_addr]     = raw
```

`one_idx==0` 时 accumulator 从 0 开始。

## V2C

每个有效 lane：

```text
raw_sum   = tile_accum[active_buf][tile_offset]
raw_edge  = tile_t[active_buf][lane][t_addr]
posterior = C_VAL + scale(raw_sum)
v2c       = C_VAL + scale(raw_sum - raw_edge)
```

`v2c` 饱和编码后进入 CNU_A 规则，更新下一轮 compressed check state。最后一轮 `one_idx==0` 用 posterior sign 写入 `decision_mem[col_idx]`。
