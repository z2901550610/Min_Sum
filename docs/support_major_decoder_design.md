# Support-Major Tile Min-Sum 解码器设计

## 目标

本设计描述一个面向 BIKE/QC-MDPC syndrome 输入 min-sum 解码器的 support-major tile 架构。架构目标如下：

- 对任意合法第一列支撑集提供完整边覆盖。
- 对每个公开参数集使用固定译码周期。
- 使用规则的向量化 row 访问降低 RAM-M 和 syndrome RAM 的 bank 冲突压力。
- 使用 tile-local RAM-T 保存 c2v，支持 C2V/V2C tile 交叠。
- 保持 CNU/VNU 的 min-sum 数学功能，改变边遍历顺序和存储索引方式。

该架构适用于 `H = [H0 | H1 | ... | H(N0-1)]` 形式的 QC-MDPC 校验矩阵。每个 `Hb` 是 `R x R` circulant block，每个 block 的第一列有 `W` 个非零位置。

## 符号

| 符号 | 含义 |
| --- | --- |
| `R` | 每个 circulant block 的尺寸，也是 check node 行数 |
| `N0` | circulant block 个数 |
| `W` | 每个 circulant block 每列非零边数 |
| `N` | 码长，`N = N0 * R` |
| `L` | 每周期处理的边数，也是向量化 row 宽度 |
| `C_TILE` | 每个 tile 包含的本地变量列数 |
| `Q_TILE` | 每个支撑项处理一个 tile 的固定周期数 |
| `TILE_COUNT` | 每个 circulant block 的 tile 数，`ceil(R / C_TILE)` |
| `EDGE_ID_W` | 行内边身份位宽，覆盖 `0 .. N0*W-1` |
| `MSG_W` | c2v/v2c sign-magnitude 消息宽度 |
| `ACC_W` | tile 内变量节点累加器宽度 |
| `M_WORD_W` | RAM-M 每个 row 的压缩状态 word 宽度 |

推荐参数约束：

```text
L 为 2 的幂
C_TILE <= R
C_TILE 为 L 的整数倍
Q_TILE = ceil(C_TILE / L) + 1
```

`Q_TILE` 中额外的 1 个周期用于处理 `row = (col + s) mod R` 在 tile 内跨越 `R-1 -> 0` 的情况。最后一个 tile 的有效列数可小于 `C_TILE`，控制器仍执行完整 `Q_TILE` 个周期，越界 lane 使用 invalid mask。

派生常量建议统一放入参数包：

```text
Q_BASE       = ceil(C_TILE / L)
TILE_COUNT   = ceil(R / C_TILE)
TILES_TOTAL  = N0 * TILE_COUNT
TILE_ID_W    = ceil(log2(TILES_TOTAL))
TILE_IDX_W   = ceil(log2(TILE_COUNT))
TILE_OFF_W   = ceil(log2(C_TILE))
Q_SEQ_W      = ceil(log2(Q_TILE))
ROW_IDX_W    = ceil(log2(R))
COL_W        = ceil(log2(N0 * R))
ROW_BANK_AW  = ceil(log2(ceil(R / L)))
```

RTL 中所有计数器按这些公开常量定宽，尾 tile、guard 和 invalid lane 只改变 valid mask。

## 校验矩阵几何

每个 circulant block 只存第一列支撑集：

```text
S_b = {s_b,0, s_b,1, ..., s_b,W-1}
```

第 `b` 个 block 中，本地变量列 `j` 与支撑项 `s_b,k` 对应的 check row 为：

```text
row = (j + s_b,k) mod R
```

support-major 扫描固定一个支撑项 `s_b,k`，然后扫描一个 tile 中的连续变量列：

```text
j = tile_base + offset
row = (j + s_b,k) mod R
edge_id = b * W + k
```

几何上，固定的 `s_b,k` 对应一条循环对角线。扫描该支撑项等价于沿这条循环对角线访问所有边。

## 顶层循环

一个译码迭代由所有 block tile 的 C2V/V2C 处理组成。tile 的逻辑坐标为：

```text
tile_id = b * TILE_COUNT + tile_idx
tile_base = tile_idx * C_TILE
tile_cols = min(C_TILE, R - tile_base)
```

一个 tile 的处理周期数为：

```text
T_TILE = W * Q_TILE
```

其中每个支撑项固定执行 `Q_TILE` 个周期。完整迭代的 tile 数为：

```text
TILES_TOTAL = N0 * TILE_COUNT
```

使用双缓冲交叠时，迭代主周期为：

```text
T_ITER = (TILES_TOTAL + 1) * T_TILE
```

其中第一个 `T_TILE` 是首个 tile 的 C2V 填充窗口，最后一个 `T_TILE` 是末尾 tile 的 V2C 排空窗口。中间每个窗口同时执行一个 tile 的 C2V 和前一个 tile 的 V2C。

## Tile 内扫描

对固定的 `(b, tile_idx, k)`，控制器保持支撑项：

```text
s = support_mem[b][k]
edge_id = b * W + k
```

普通向量周期以 `q` 为索引：

```text
offset = q * L + lane
col_local = tile_base + offset
col_global = b * R + col_local
row_raw = col_local + s
row = row_raw - R, if row_raw >= R
row = row_raw,     if row_raw <  R
```

lane 有效条件：

```text
offset < tile_cols
```

### 跨界 guard

当一个 `L`-wide 访问组跨越 `R-1 -> 0` 时，组内 row 形如：

```text
R-a, ..., R-1, 0, ..., b
```

这类访问组在 `bank(row) = row mod L` 的向量 bank 组织下可能出现 bank 重复。row/col 生成器将该访问组拆为两个 micro-cycle：

```text
pre-wrap cycle:  只使能 row < R 的尾部 lane
post-wrap cycle: 只使能 row >= 0 的头部 lane
```

每个 `(b, tile_idx, k)` 固定提供一个 guard cycle。若 tile 内不存在跨界访问组，guard cycle 全部 lane invalid。若跨界发生在某个普通向量周期，控制器在该位置插入 guard cycle，并保证该支撑项的总周期数仍为 `Q_TILE`。

固定周期条件为：

```text
普通向量周期数 = ceil(C_TILE / L)
guard 周期数   = 1
总周期数       = Q_TILE
```

私钥支撑项 `s` 只影响 guard 出现的位置和 lane valid mask，总周期数由公开参数决定。

### Guard 位置计算

row/col 生成器可按以下规则实现固定 `q_seq` 到实际向量组的映射：

```text
Q_BASE       = ceil(C_TILE / L)
tile_end     = tile_base + tile_cols
wrap_col     = R - s
has_wrap     = (tile_base < wrap_col) && (wrap_col < tile_end)
wrap_offset  = wrap_col - tile_base
wrap_q       = floor(wrap_offset / L)
wrap_lane    = wrap_offset mod L
split_en     = has_wrap && (wrap_lane != 0)
```

`row_raw`、`tile_end`、`wrap_col` 和 `wrap_offset` 使用 `ROW_IDX_W+1` 位计算，使 `s=0` 时的 `wrap_col=R` 能被完整表示。

`split_en=0` 时：

```text
q_seq = 0 .. Q_BASE-1 : q_idx = q_seq，普通向量周期
q_seq = Q_BASE        : 全 lane invalid
```

`split_en=1` 时：

```text
q_seq < wrap_q        : q_idx = q_seq，普通向量周期
q_seq = wrap_q        : q_idx = wrap_q，只使能 lane < wrap_lane
q_seq = wrap_q + 1    : q_idx = wrap_q，只使能 lane >= wrap_lane
q_seq > wrap_q + 1    : q_idx = q_seq - 1，普通向量周期
```

所有分支都叠加尾 tile 条件：

```text
offset = q_idx * L + lane
valid  = lane_mask && (offset < tile_cols)
```

RAM-T 地址使用 `q_seq`，因此拆分周期在 RAM-T 中占用两个不同 entry。V2C 阶段使用同一映射规则重放 `q_seq` 序列。

## Row Bank 组织

RAM-M、syndrome RAM 和 RAM-S 的 row 维度按 `L` 个 vector bank 组织：

```text
bank(row) = row mod L
addr(row) = floor(row / L)
```

一个非跨界向量周期访问 `L` 个连续 row：

```text
row_start, row_start+1, ..., row_start+L-1
```

这些 row 在 `row mod L` 下覆盖 `L` 个不同 bank，因此每个 bank 每周期最多一个读请求或写请求。跨界访问由 guard 拆分后，每个 micro-cycle 仍满足该性质。

该性质与支撑集分布无关，因为一个周期只处理一个支撑项生成的连续 row 片段。

## 存储结构

### Support RAM

Support RAM 保存第一列支撑集：

```text
support_mem[b][k] = s_b,k
```

尺寸：

```text
N0 * W * ROW_IDX_W bits
```

BIKE-128：

```text
3 * 27 * 13 = 1053 bits
```

加载契约：

```text
0 <= support_mem[b][k] < R
同一 block 内 W 个 support row 互不相同
每个 block 固定写入 W 个 support row
```

加载器可提供重复项检测。检测逻辑采用固定比较结构或固定扫描深度，错误标志进入状态寄存器；译码主循环只在加载完成且参数合法时启动。

### RAM-M

RAM-M 保存每个 check row 的压缩 min-sum 状态：

```text
min1
min2
min_id
sign_xor
epoch
```

两个 RAM-M pair 以 ping-pong 方式保存上一迭代状态和下一迭代累积状态。每个 pair 使用 `L` 个 vector bank：

```text
depth_per_bank = ceil(R / L)
word_width = M_WORD_W
```

总容量：

```text
2 * L * ceil(R / L) * M_WORD_W bits
```

BIKE-128、`L=8`、`M_WORD_W=17`：

```text
2 * 8 * 1015 * 17 = 276080 bits
```

RAM-M 下一迭代 pair 在 V2C 阶段执行 read-modify-write。CNU_A 流水写回延迟内可能出现同 row 再访问，设计中配置固定深度 write-forward buffer。forward buffer 以 `(bank, addr)` 命中，返回最近的待写压缩状态。该结构深度等于 CNU_A 写回延迟，尺寸与私钥无关。

### Syndrome RAM

Syndrome RAM 保存输入 syndrome：

```text
syndrome[row]
```

bank 组织与 RAM-M 一致：

```text
L * ceil(R / L) bits
```

C2V 阶段按 row 向量读取 syndrome bit。

### RAM-S

RAM-S 保存每条边的 v2c sign。索引建议为：

```text
sign_mem[edge_id][row]
```

其中：

```text
edge_id = b * W + k
```

尺寸：

```text
N0 * W * R bits
```

BIKE-128：

```text
3 * 27 * 8117 = 657477 bits
```

RAM-S 使用单逻辑副本，支持每周期 `L` 路读和 `L` 路写。C2V 阶段读取 CNU_B 输入 sign，V2C 阶段写回 VNU 输出 sign。对同一 `edge_id`，不同 tile 对应不相交的 row 集合；一个 tile 的输入 sign 在该 tile C2V 完成后可由 V2C 覆盖写。

RAM-S 每个 `edge_id` 使用 `L` 个 row bank，每个 bank 为 1R1W。C2V/V2C 交叠时，同一个 sign bank 每周期可执行一次读和一次写。

RAM-S 单副本的时序不变量：

```text
Phase A(tile t) 先读取 tile t 的 sign
Phase B(tile t) 后写回 tile t 的 sign
Phase A(tile t+1) 与 Phase B(tile t) 访问的 row 集合不相交
```

其中 `tile t` 和 `tile t+1` 表示同一 block 内不同本地列区间，或不同 block 的不同 `edge_id` line。该不变量保证 tile 交叠时不会覆盖尚未读取的 sign。

### Tile Accumulator

Tile accumulator 保存当前 tile 中每个变量列的后验累加值：

```text
A_tile[col_offset]
```

宽度：

```text
ACC_W = MSG_W + ceil(log2(W + 1))
```

BIKE-128 中 `MSG_W=5`，`ACC_W=10`。

双缓冲容量：

```text
2 * C_TILE * ACC_W bits
```

`k=0` 时 accumulator read 端返回先验 `gamma[col]`，从而免除独立清零扫描。每个 C2V 周期读出旧累加值，加上缩放后的 c2v，再写回同一 tile 地址。

### Tile RAM-T

Tile RAM-T 保存当前 tile 每条边的 c2v，用于 V2C 阶段执行外信息相减：

```text
v2c = A_tile[col] - scaled(c2v_edge)
```

推荐索引：

```text
ram_t_buf[buffer][lane][entry]
entry = k * Q_TILE + q_seq
```

其中 `q_seq` 是包含 guard 周期的支撑项内部周期编号。Phase B 使用同一 row/col 生成器重新生成 valid mask，因此 RAM-T 可只存 c2v 数据。调试型或时序型实现可附加 valid sideband。

双缓冲容量：

```text
2 * L * W * Q_TILE * MSG_W bits
```

BIKE-128、`L=8`、`C_TILE=256`、`Q_TILE=33`：

```text
2 * 8 * 27 * 33 * 5 = 71280 bits
```

若存 valid sideband，额外增加：

```text
2 * L * W * Q_TILE bits = 14256 bits
```

### Decision RAM

Decision RAM 保存最终错误估计：

```text
e_hat[col_global]
```

尺寸：

```text
N0 * R bits
```

BIKE-128：

```text
24351 bits
```

最终迭代中，tile 的 posterior 在 accumulator 中形成。决策写入可复用 V2C 阶段 `k=0` 的列扫描窗口：每个变量列在 `k=0` 时出现一次，比较 `A_tile[col]` 的符号并写入 Decision RAM。

基线控制在每个迭代都执行完整 C2V 和 V2C 窗口。最终迭代的 Decision RAM 写入嵌入 V2C 窗口，本文周期公式均按该基线计算。若采用固定公开的最终写回专用流程，需要为该流程单独给出周期公式和等价性证明。

## 数据通路

### C2V Phase

C2V phase 为 tile 生成 c2v 并累加变量节点后验量：

```text
for k in 0..W-1:
  s = support_mem[b][k]
  for q_seq in 0..Q_TILE-1:
    generate L lanes of (valid, row, col, edge_id)
    read M_old[row]
    read sign_mem[edge_id][row]
    read syndrome[row]
    c2v = CNU_B(M_old[row], sign, syndrome[row], edge_id)
    A_tile[col] += scale(c2v)
    RAM-T[entry] = c2v
```

每周期需求：

```text
L 路 RAM-M old read
L 路 RAM-S 输入 sign read
L 路 syndrome read
L 个 CNU_B
L 个 scale/add accumulator datapath
L 路 tile accumulator read/write
L 路 RAM-T write
```

### V2C Phase

V2C phase 消费 tile-local RAM-T，并累积下一迭代 RAM-M：

```text
for k in 0..W-1:
  s = support_mem[b][k]
  for q_seq in 0..Q_TILE-1:
    generate L lanes of (valid, row, col, edge_id)
    c2v = RAM-T[entry]
    posterior = A_tile[col]
    v2c = posterior - scale(c2v)
    read M_new[row]
    M_new[row] = CNU_A(M_new[row], v2c, edge_id)
    sign_mem[edge_id][row] = sign(v2c)
```

每周期需求：

```text
L 路 RAM-T read
L 路 tile accumulator read
L 个 subtract/saturate datapath
L 个 CNU_A
L 路 RAM-M new read/write
L 路 RAM-S new-sign write
```

### Tile 交叠

双缓冲提供两个 tile context：

```text
fill buffer   : C2V 写 A_tile 和 RAM-T
active buffer : V2C 读 A_tile 和 RAM-T
```

稳态窗口：

```text
cycle window n:
  C2V processes tile n
  V2C processes tile n-1
```

每个窗口长度为 `T_TILE`。当窗口结束，buffer role 翻转。C2V 和 V2C 使用独立的 row/col generator context，并分别携带 `(b, tile_idx, k, q_seq)`。

## 固定周期与覆盖性

### 任意支撑集覆盖

对任意支撑项 `s`，tile 内 `row = (col + s) mod R` 至多跨越一次 `R-1 -> 0`。每个 `(b, tile_idx, k)` 固定分配一个 guard cycle，覆盖跨界拆分需求。

每个支撑项的周期固定为：

```text
Q_TILE = ceil(C_TILE / L) + 1
```

每个 tile 固定处理 `W` 个支撑项：

```text
T_TILE = W * Q_TILE
```

每个迭代固定处理 `N0 * ceil(R / C_TILE)` 个 tile。因此总周期只依赖公开参数：

```text
T_ITER = (N0 * ceil(R / C_TILE) + 1) * W * (ceil(C_TILE / L) + 1)
```

支撑集分布影响 row 偏移和 guard 位置，循环边界由固定 guard 覆盖。不同支撑项按 `k` 串行扫描，任意多个支撑项落到同一 row bank 的情况不会形成同周期 bank 竞争。

### Bank 冲突消除

非跨界周期内，row 序列为连续 `L` 个 row。采用：

```text
bank(row) = row mod L
```

连续 `L` 个 row 恰好落到 `L` 个不同 bank。跨界周期拆分为 pre-wrap 和 post-wrap 两个 micro-cycle，每个 micro-cycle 内 row 仍为非跨界连续片段，因此每个 bank 每周期最多一个 lane 请求。

### 固定 valid 行为

所有 lane 都随固定循环发射。lane valid 由以下公开或支撑相关条件组合：

```text
offset < tile_cols
pre/post wrap mask
guard active
```

invalid lane 执行 no-op，不写 RAM-T、accumulator、RAM-M、RAM-S 或 Decision RAM。控制器不根据 valid 数量缩短周期。

## BIKE-128 推荐配置

推荐交付点：

```text
R = 8117
N0 = 3
W = 27
I_MAX = 7
L = 8
C_TILE = 256
Q_TILE = 33
TILE_COUNT = ceil(8117 / 256) = 32
TILES_TOTAL = 96
T_TILE = 27 * 33 = 891 cycles
T_ITER = 97 * 891 = 86427 cycles
T_DECODE_MAIN = 7 * 86427 = 604989 cycles
```

核心存储估算：

| 存储 | 估算 |
| --- | ---: |
| Support RAM | 1053 bit |
| RAM-M 两个 pair | 276080 bit |
| Syndrome RAM | 8120 bit |
| RAM-S sign | 657720 bit，含 vector-bank padding |
| Tile RAM-T 双缓冲 | 71280 bit |
| Tile accumulator 双缓冲 | 5120 bit |
| Decision RAM | 24351 bit |

合计约：

```text
1.04 Mbit
```

该估算未包含 FIFO、pipeline registers、forward buffer、控制寄存器和 RAM 宏对齐开销。

### 参数点

| 配置 | 7 轮主周期 | Tile RAM-T | 特点 |
| --- | ---: | ---: | --- |
| `L=4, C_TILE=256` | 1191645 | 70200 bit | 数据通路较窄 |
| `L=8, C_TILE=128` | 620109 | 36720 bit | RAM-T 较小 |
| `L=8, C_TILE=256` | 604989 | 71280 bit | 推荐交付点 |
| `L=8, C_TILE=512` | 601965 | 140400 bit | RAM-T 增长明显 |
| `L=16, C_TILE=256` | 311661 | 73440 bit | 高性能点 |

`C_TILE=512` 对周期改善较小，但 RAM-T 和 accumulator 增长明显。`L=16` 可显著降低周期，代价是 CNU/VNU、RAM 端口、布线和 accumulator 数据通路翻倍。

### 多参数周期估算

以下估算取 `C_TILE=256`、`I_MAX=7`、`MSG_W=5`，只统计译码主循环：

| 参数 | `R` | `W` | `TILE_COUNT` | `L=8` 主周期 | `L=8` RAM-T | `L=16` 主周期 | `L=16` RAM-T |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 128 | 8117 | 27 | 32 | 604989 | 71280 bit | 311661 | 73440 bit |
| 160 | 12739 | 35 | 50 | 1220835 | 92400 bit | 628915 | 95200 bit |
| 256 | 29501 | 55 | 116 | 4434045 | 145200 bit | 2284205 | 149600 bit |
| 384 | 59069 | 83 | 231 | 13306062 | 219120 bit | 6854638 | 225760 bit |
| 512 | 156011 | 111 | 610 | 46948671 | 293040 bit | 24185679 | 301920 bit |

大参数点的周期主要由 `ceil(R/C_TILE) * W` 决定。`L=16` 使 `Q_TILE` 从 33 降到 17，资源代价集中在 CNU/VNU lane 数、row-bank 数、RAM 端口、旁路网络和布线。

## 模块划分建议

### `support_mem`

功能：

- 接收 H 加载接口写入的第一列支撑集。
- 按 `(b, k)` 提供 `s_b,k`。
- 输出 `edge_id = b * W + k`。

接口建议：

```systemverilog
input  logic                  i_we;
input  logic [H_BLOCK_W-1:0]  i_h_block_idx;
input  logic [ONE_IDX_W-1:0]  i_one_idx;
input  logic [ROW_IDX_W-1:0]  i_support_row;
input  logic [H_BLOCK_W-1:0]  i_read_h_block_idx;
input  logic [ONE_IDX_W-1:0]  i_read_one_idx;
output logic [ROW_IDX_W-1:0]  o_support_row;
```

### `support_major_ctrl`

功能：

- 产生 tile 级 C2V/V2C 交叠调度。
- 管理 `fill/active` buffer role。
- 管理 RAM-M pair epoch 和迭代计数。
- 生成 `done` 和最终 Decision RAM 写窗口。

主要计数器：

```text
iter_idx
tile_linear_idx
h_block_idx
tile_idx
one_idx
q_seq
buffer_sel
phase_valid
```

### `support_row_col_gen`

功能：

- 根据 `(b, tile_idx, one_idx, q_seq, support_row)` 生成 `L` 路 `(valid, row, col, edge_id)`。
- 检测 tile 内 row wrap。
- 产生 pre-wrap / post-wrap lane mask。
- 保证每个支撑项总共输出 `Q_TILE` 个周期。

输出：

```systemverilog
output logic                  o_valid[0:L-1];
output logic [ROW_IDX_W-1:0]  o_row_idx[0:L-1];
output logic [COL_W-1:0]      o_col_idx[0:L-1];
output logic [EDGE_ID_W-1:0]  o_edge_id[0:L-1];
output logic [LANE_IDX_W-1:0] o_row_bank[0:L-1];
output logic [ROW_BANK_AW-1:0] o_row_addr[0:L-1];
```

### `ram_m_vector_pair`

功能：

- 提供两个 RAM-M pair。
- 每个 pair 包含 `L` 个 1R1W vector bank。
- C2V 读 old pair。
- V2C 对 new pair 执行 read-modify-write。
- 提供 CNU_A 写回旁路。

### `ram_s_support_sign`

功能：

- 以 `(edge_id, row)` 索引保存 sign。
- 每个 edge line 使用 `L` 个 vector bank。
- 支持每周期 `L` 路 C2V 读和 `L` 路 V2C 写。

### `tile_accum_buffer`

功能：

- 双缓冲 tile accumulator。
- C2V fill buffer 执行 read-add-write。
- V2C active buffer 执行 read。
- `one_idx == 0` 时返回先验 `gamma[col]`。

### `tile_ram_t`

功能：

- 双缓冲 tile-local c2v cache。
- C2V fill buffer 写。
- V2C active buffer 读。
- 地址为 `(one_idx, q_seq, lane)`。
- valid mask 由 V2C 侧的 `support_row_col_gen` 重算；若实现存储 valid sideband，sideband 必须与重算结果一致。

### `support_c2v_pipe`

功能：

- 读取 RAM-M old state、old sign 和 syndrome。
- 调用 `CNU_B` 重建 c2v。
- 执行缩放并更新 tile accumulator。
- 写入 tile RAM-T。

### `support_v2c_pipe`

功能：

- 读取 tile RAM-T 和 tile accumulator。
- 计算外信息：

```text
v2c = posterior - scaled(c2v)
```

- 调用 `CNU_A` 更新 RAM-M new state。
- 写回 new sign。
- 在最终迭代的 `one_idx == 0` 窗口写 Decision RAM。

## 实现注意事项

- Support RAM 加载器固定接收每个 block 的 `W` 个 support row，并输出合法性标志。
- `support_row_col_gen` 使用固定 `Q_TILE` 输出节奏。guard 插入位置可由支撑项决定，总周期保持固定。
- `support_row_col_gen` 的 Phase A/Phase B 实例共享同一 `q_seq -> q_idx/mask` 规则。
- RAM-M new pair 需要固定深度 write-forward buffer，覆盖 CNU_A 写回流水延迟内的同 row 更新。
- RAM-M new pair 在每个迭代开始按公开控制信号初始化 epoch，未写入 row 返回初始化压缩状态。
- RAM-S 使用 1R1W bank 时，读输入 sign 和写输出 sign 可在同周期访问同一 bank 的不同地址。
- Tile accumulator 的 `one_idx == 0` 初始化语义需要覆盖所有 lane，包括 guard 和最后 tile invalid lane。
- RAM-T 的 Phase A/Phase B 地址生成器必须使用同一 `q_seq` 序列、同一 guard 规则和同一 lane valid 规则。
- Phase B 重放 row/col 序列时，`(valid,row,col,edge_id)` 必须逐周期匹配 Phase A 写 RAM-T 时使用的序列。
- 对 `R % L != 0`、`C_TILE` 尾 tile、`support_row=0`、`support_row=R-1` 添加 directed tests。
- 对 toy 参数构造覆盖 row wrap、tile wrap、guard dummy、同 row RAW forwarding 的测试。

## 验证计划

基础 directed tests：

- 单 block、单支撑项，检查 row/col 生成序列覆盖所有有效边。
- 支撑项 `s=0`，guard 周期全 invalid。
- 支撑项使跨界发生在 tile 第一个向量周期。
- 支撑项使跨界发生在 tile 最后一个向量周期。
- 最后 tile `tile_cols < C_TILE`，invalid lane 无写入。

结构覆盖 tests：

- RAM-M vector bank 每周期无重复 bank。
- RAM-S 读写同 edge line 不覆盖未读取旧 sign。
- RAM-T Phase A 写地址和 Phase B 读地址一一对应。
- CNU_A write-forward 命中路径与未命中路径。

译码等价 tests：

- toy QC-MDPC 参数下，与 column/order-independent reference model 比较每轮 `A[col]`、`M_new[row]` 和 sign。
- BIKE-128 随机小样本，固定 `I_MAX` 后比较输出 syndrome residual。
- 对同一 syndrome 和不同合法支撑集，测量 `done` 周期完全一致。
