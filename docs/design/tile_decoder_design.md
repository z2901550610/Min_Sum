# Tile Min-Sum 解码器设计

## 目标

tile 架构按 H 第一列行索引扫描 QC-MDPC 校验矩阵边。设计目标：

- 主译码周期由公开参数固定决定。
- H `base_row_idx` 只影响 lane valid mask 和 row/col 地址。
- C2V 和 V2C 以 tile 双缓冲重叠执行。
- 变量节点更新公式使用 raw C2V 求和后整体缩放。
- 每个公开参数集可独立选择 `L` 和 `COLS_PER_TILE`。

## 派生常量

```text
N            = N0 * R
COLS_PER_TILE       = min(R, BIKE_COLS_PER_TILE)
Q_BASE       = ceil(COLS_PER_TILE / L)
Q_TILE       = Q_BASE + 3
TILE_COUNT   = ceil(R / COLS_PER_TILE)
TILES_TOTAL  = N0 * TILE_COUNT
ROW_SEG_SIZE = ceil(R / L)
```

`Q_TILE` 包含三个固定 guard 周期。`COLS_PER_TILE` 要求为 `L` 的整数倍。

## H Base Row Index 几何

第 `b` 个 block 的第 `k` 个 H 第一列项：

```text
entry_id = b * W + k
base_row_idx = ram_i[entry_id]
diag_idx_global = b * W + k
```

tile 内变量列：

```text
tile_base = tile_idx * COLS_PER_TILE
offset    = lane_group_idx_eff * L + lane
col_local = tile_base + offset
col_idx   = b * R + col_local
row_raw       = col_local + base_row_idx
check_row_idx = row_raw - R if row_raw >= R else row_raw
```

lane 有效条件：

```text
phase_valid && lane_group_idx_eff < Q_BASE && offset < cols_per_tile
```

## Guard 规则

跨越 `R-1 -> 0` 的 L-wide 访问组被拆成两个 micro-cycle。row/col 生成器先计算：

```text
wrap_col    = R - base_row_idx
has_wrap    = tile_base < wrap_col && wrap_col < tile_end
wrap_offset = wrap_col - tile_base
wrap_lane_group_idx = wrap_offset / L
wrap_lane   = wrap_offset % L
split_en    = has_wrap && wrap_lane != 0
```

`split_en=0`：

```text
lane_group_idx < Q_BASE : lane_group_idx_eff = lane_group_idx
lane_group_idx >= Q_BASE : invalid guard
```

`split_en=1`：

```text
lane_group_idx < wrap_lane_group_idx     : lane_group_idx_eff = lane_group_idx
lane_group_idx = wrap_lane_group_idx     : lane_group_idx_eff = wrap_lane_group_idx, lane <  wrap_lane
lane_group_idx = wrap_lane_group_idx + 1 : lane_group_idx_eff = wrap_lane_group_idx, lane >= wrap_lane
lane_group_idx > wrap_lane_group_idx + 1 : lane_group_idx_eff = lane_group_idx - 1
```

所有支撑项固定执行 `Q_TILE` 个 `lane_group_idx`。guard 周期为跨模拆分、C2V 输入寄存和写回对齐提供固定预算。

## 状态组织

| 状态 | 访问方式 |
| --- | --- |
| compressed check state | `comp_pair[pair][check_row_idx]` |
| V2C sign | `sign_mem[diag_idx_global][check_row_idx]` |
| tile raw C2V sum | `ram_accum[buf][tile_offset]` |
| tile raw C2V edge | `ram_t[buf][lane][diag_idx_local * Q_TILE + lane_group_idx]` |
| decision bit | `ram_decision[col_idx]` |

`ram_accum` 和 `ram_t` 使用 `fill_buf/active_buf` 双缓冲。compressed check state 使用 `comp_read_pair_sel/comp_write_pair_sel` 双 pair。每轮写 pair 按固定地址序列初始化为 `COMP_C2V_INIT`。

## C2V

每个有效 lane：

```text
comp = first_iter ? FIRST_ITER_C2V_COMP : comp_or_init(comp_read_pair_sel, check_row_idx)
c2v  = cnu_b(comp, sign_mem[diag_idx_global][check_row_idx], syndrome_mem[check_row_idx], diag_idx_global)
raw  = signmag_to_tc(c2v)
ram_accum[fill_buf][tile_offset] += raw
ram_t[fill_buf][lane][t_addr]       = raw
```

`diag_idx_local==0` 时 accumulator 从 0 开始。

## V2C

每个有效 lane：

```text
raw_sum   = ram_accum[active_buf][tile_offset]
raw_edge  = ram_t[active_buf][lane][t_addr]
posterior = C_VAL + scale(raw_sum)
v2c       = C_VAL + scale(raw_sum - raw_edge)
```

`v2c` 饱和编码后进入 CNU_A 规则，更新下一轮 compressed check state。最后一轮 `diag_idx_local==0` 用 posterior sign 写入 `ram_decision[col_idx]`。
