# RTL 命名规范

## 坐标术语

| 名称 | 范围 | 含义 |
| --- | --- | --- |
| `h_block_idx` | `0..N0-1` | circulant block 编号 |
| `diag_idx` | `0..W-1` | 一个 block 内的对角线编号，对应第一列支撑项编号 |
| `base_row` | `0..R-1` | H 第一列行索引 |
| `edge_id` | `0..N0*W-1` | row-local edge 编号，`h_block_idx * W + diag_idx` |
| `tile_idx` | `0..TILE_COUNT-1` | block 内 tile 编号 |
| `tile_linear` | `0..TILES_TOTAL-1` | 全局 tile 编号 |
| `q_seq` | `0..Q_TILE-1` | tile 内固定向量周期编号 |
| `lane_idx` | `0..L-1` | 并行 lane 编号 |
| `row_idx` | `0..R-1` | 校验行号 |
| `col_idx` | `0..N-1` | 全局变量列号 |
| `tile_offset` | `0..COLS_PER_TILE-1` | tile 内本地列 offset |

## 后缀

| 后缀 | 用法 |
| --- | --- |
| `_idx` | 离散编号或数组索引 |
| `_seq` | 固定顺序扫描计数 |
| `_addr` | 存储器地址或 bank-local 地址 |
| `_offset` | tile 或数组局部偏移 |
| `_valid` | 当前 lane/window 数据有效 |
| `_loaded` | 外部加载完成 |
| `_error` | 加载或参数检查错误 |
| `_sel` | pair、buffer 或 mux 选择 |
| `_buf` | tile 双缓冲编号 |
| `_pair` | compressed check-state 双 pair 编号 |

## 主要数组命名

| 名称 | 含义 |
| --- | --- |
| `ram_i` | H 第一列行索引存储 |
| `ram_m` | compressed check-state 双 pair RAM |
| `ram_s` | edge sign RAM |
| `ram_t_accum` | raw C2V tile 累加 RAM |
| `ram_t` | raw C2V tile 边缓存 RAM |
| `ram_c1` | 最终错误估计 bit |
| `syndrome_mem` | 输入 syndrome bit |

## Pair 和 Buffer

compressed check-state 使用双 pair：

| 名称 | 含义 |
| --- | --- |
| `comp_read_pair_sel` | C2V 读取的 pair |
| `comp_write_pair_sel` | V2C 写入的 pair |
| `comp_clear_valid` | check-state 写 pair 初始化有效 |
| `comp_clear_addr` | check-state 写 pair 初始化地址 |

tile-local 状态使用双 buffer：

| 名称 | 含义 |
| --- | --- |
| `fill_buf` | C2V 写入 tile buffer |
| `active_buf` | V2C 读取 tile buffer |

## 端口前缀

| 前缀 | 用法 |
| --- | --- |
| `i_` | 模块输入 |
| `o_` | 模块输出 |
| `u_` | 子模块实例 |

## 推荐写法

```systemverilog
logic [ROW_IDX_W-1:0] c2v_row_idx[0:L-1];
logic [TILE_OFF_W-1:0] v2c_tile_offset[0:L-1];
logic signed [ACC_W-1:0] c2v_raw_next[0:L-1];
```

unpacked 维度紧贴信号名。多 lane 信号使用 `[0:L-1]`。

## Debug 信号

仅 testbench 或 lint 消噪使用的信号使用 `unused_*` 或 `observed_*` 前缀，并放在局部 lint waiver 内。
