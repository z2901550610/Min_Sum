# K-sign 压缩符号译码器设计

## 目标

K-sign 方案用于压缩 V2C 符号状态。设计目标：

- 译码周期由公开参数和固定调度决定。
- C2V 使用近似 V2C 符号重建 min-sum 符号项。
- 每个变量节点保存少量偏离位置，避免保存全部 `W` 条边的 V2C 符号。
- CNU 幅度路径保持 min1/min2/min_diag_idx_global 更新规则。
- K 值、位置位宽、tile 大小、并行度均为公开配置。

本文档描述 `high_mag_dev` 规则：每个变量节点选择幅值最大的 K 条符号偏离边。

## 算法语义

对变量节点 `j`，VNU 产生后验符号和每条 V2C 消息：

```text
base_sign[j] = sign(posterior[j])
v2c_sign[j,k] = sign(v2c_msg[j,k])
v2c_mag[j,k]  = abs(v2c_msg[j,k])
```

其中 `k` 是该变量节点的边序号，范围为 `0..W-1`。定义偏离标志：

```text
dev[j,k] = v2c_sign[j,k] XOR base_sign[j]
```

K-sign 记录保存：

```text
base_sign[j]
dev_pos[j,0..K-1]
```

`dev_pos` 只记录 `dev=1` 的边位置，并按 `v2c_mag` 选择幅值最大的 K 个。候选数少于 K 时，剩余槽为 invalid。候选工作槽保持无序；Top-K 集合由固定的最差项选择规则确定。

C2V 阶段重建边 `k` 的近似 V2C 符号：

```text
hit = OR_s(valid[j,s] && dev_pos[j,s] == k)
v2c_sign_approx[j,k] = base_sign[j] XOR hit
```

CNU B 使用近似符号计算 C2V 符号：

```text
c2v_sign = sign_xor_approx[row] XOR v2c_sign_approx[j,k] XOR syndrome[row]
```

`sign_xor_approx[row]` 是该校验节点所有近似 V2C 符号的异或。

## 伪代码

下面给出论文描述风格的 K-sign min-sum 译码伪代码。`TopK_K` 表示从符号偏离边中选择幅值最大的 K 个边位置。

```text
Algorithm: K-sign Scaled Min-Sum Decoding Algorithm

1:  Input: syndrome s, initial value C, maximum iteration Imax, retained number K
2:  Initialization: S_j = {base_j = 0, P_j = empty}, for all variable nodes j
3:  Initialization: M_i = {min1_i = C, min2_i = C, idx_i = 0, sxor_i = 0}, for all check nodes i
4:  for iter = 1 to Imax do
5:      Check node processing:
6:      for each edge (i, j) do
7:          hit_j,i = 1 if edge index of (i, j) is in P_j, otherwise 0
8:          sign(u_i,j) = base_j XOR hit_j,i
9:          |v_i,j| = min2_i if idx_i = diag_idx_global(i,j), otherwise min1_i
10:         sign(v_i,j) = sxor_i XOR sign(u_i,j) XOR s_i
11:     end for
12:
13:     Variable node processing:
14:     for each variable node j do
15:         L_j = C + alpha * sum_{i in N(j)} v_i,j
16:         base'_j = sign(L_j)
17:         for each i in N(j) do
18:             u'_i,j = C + alpha * sum_{i' in N(j), i' != i} v_i',j
19:         end for
20:         P'_j = TopK_K { edge index of (i,j) : sign(u'_i,j) XOR base'_j = 1 },
21:                ordered by |u'_i,j|
22:     end for
23:
24:     Check-state update:
25:     for each check node i do
26:         sxor'_i = XOR_{j in M(i)} approx_sign(u'_i,j, base'_j, P'_j)
27:         min1'_i = min_{j in M(i)} |u'_i,j|
28:         idx'_i  = arg min_{j in M(i)} |u'_i,j|
29:         min2'_i = min_{j in M(i), diag_idx_global(i,j) != idx'_i} |u'_i,j|
30:     end for
31:
32:     S_j = {base'_j, P'_j}, for all j
33:     M_i = {min1'_i, min2'_i, idx'_i, sxor'_i}, for all i
34:     x_j = sign(L_j), for all j
35: end for
```

其中：

```text
approx_sign(u'_i,j, base'_j, P'_j)
    = base'_j XOR 1{edge index of (i,j) is in P'_j}
```

`base_j` 是变量节点的基准符号，`P_j` 是保存的 K 个偏离边位置。C2V 阶段用 `base_j` 和 `P_j` 重建上一轮 V2C 符号；VNU 阶段重新计算 `base'_j` 和 `P'_j`。

## 存储格式

统一 TRIKE 硬件按最大列重配置：

```text
W_MAX = 111
POS_W = ceil(log2(W_MAX)) = 7
```

每个变量节点的长期 K-sign 记录：

| 字段 | 位宽 | 数量 | 说明 |
| --- | ---: | ---: | --- |
| base_sign | 1 | 1 | 变量节点后验符号 |
| dev_pos | 7 | K | 偏离 base_sign 的边位置 |

若使用无效位置哨兵，长期存储宽度为：

```text
KSIGN_W = 1 + K * POS_W
```

若实现选择独立 valid bit，宽度为：

```text
KSIGN_W_VALID = 1 + K * (POS_W + 1)
```

硬件采用哨兵编码，长期记录宽度为 `1 + K*7`。

V2C 扫描期间使用 tile 局部工作记录：

```text
KSIGN_WORK_W = 1 + K * (POS_W + D)
```

工作记录保存 `base_sign` 和 K 个无序 `(dev_pos, magnitude)` 槽。变量列的最后一个 `diag_idx_local` 完成后，硬件将 `base_sign` 和 K 个位置提交到下一轮全局 K-sign RAM。幅值状态只覆盖活动 tile。

## 流水线位置

K-sign selector 放在 VNU 后。该位置同时具备：

- `posterior` 符号，用于生成 `base_sign`。
- `v2c_msg` 符号，用于判断 `dev`。
- `v2c_msg` 幅值，用于 high-mag top-K 选择。
- `tile_offset` 和 `diag_idx_local`，用于记录变量列和边位置。

数据路径：

```text
C2V read -> CNU B -> tile accumulation -> VNU -> K-sign selector -> CNU A / sign update
```

CNU A 幅度路径使用真实 `v2c_mag` 更新 min1/min2/min_diag_idx_global。符号路径使用 K-sign 定义的近似符号规则。

## Tile 内候选选择器

译码器按 tile 对角线扫描，tile 内多个变量列交织到达。selector 为 tile 内每个列 offset 保留 K 个无序候选槽：

```text
base_sign[tile_offset]
pos[tile_offset][0..K-1]
mag[tile_offset][0..K-1]
```

位置哨兵 `K_SIGN_DIAG_INVALID` 同时表达槽位有效性。

每个有效 VNU 输出执行固定比较网络：

1. 计算 `dev = v2c_sign XOR base_sign`。
2. `dev=0` 时候选输入被 mask。
3. 平衡归约树从 K 个槽中选择最差项：invalid 优先被替换；有效槽中幅值较小者更差；幅值相同时位置较大者更差。
4. `dev=1` 且候选优于最差项时，只覆盖最差槽。
5. 比较树和单槽写选择的逻辑数量固定，不因候选数量提前结束。

K=4 或 K=6 时，每个 lane 使用 `K-1` 个比较选择节点组成最差项树，并使用一个候选门限比较器。树深约为 `ceil(log2(K))`，工作记录只更新一个槽。

推荐 tie-break：

```text
mag 更大者优先
mag 相同则 diag_idx_local 更小者优先
```

同一变量列的候选按递增 `diag_idx_local` 到达。候选与最差项幅值相同时不执行替换；归约树在同幅值槽中选择位置较大的槽作为最差项。该规则完全确定，便于 C/RTL 对齐。

## Sign_xor 更新

K-sign 的关键约束是 `sign_xor_approx` 必须和 C2V 读取的近似 V2C 符号一致。硬件实现有两个固定时间选项。

### 选项 A：双遍 V2C 更新

第一遍 V2C 只计算 VNU 输出并完成 K-sign 选择。第二遍 V2C 使用已确定的 K-sign 记录更新 CNU A：

```text
v2c_sign_approx = base_sign XOR hit(dev_pos == diag_idx_local)
CNU A sign_xor  = sign_xor XOR v2c_sign_approx
```

特点：

- 语义直接，CNU A 只看到最终近似符号。
- bank 冲突处理沿用主 V2C 扫描路径。
- 周期增加接近一个 V2C tile pass。
- 适合作为参考 RTL 和算法对齐版本。

### 选项 B：Base-sign 主更新 + 固定校正

主 V2C 扫描中，CNU A 符号路径先按 `base_sign` 更新：

```text
sign_xor_base[row] = XOR of base_sign over connected variables
```

selector 同时找出每个变量节点的 K 个 dev 位置。tile 扫描完成后，对每个有效 dev 位置翻转对应校验节点的 `sign_xor`：

```text
sign_xor_approx[row(dev_edge)] = sign_xor_base[row(dev_edge)] XOR 1
```

固定校正窗口遍历：

```text
for slot in 0..K-1:
  for q in 0..Q_BASE-1:
    for lane in 0..L-1:
      column = q * L + lane
      if valid[column][slot]:
        flip sign_xor at row(base_row_idx[dev_pos] + column)
```

无效槽执行 mask，不改变状态。窗口长度由公开参数决定。

该选项的工程重点是 correction write 的 bank 冲突。可选实现：

- 将 `sign_xor` 从 min 状态中拆出，使用独立的 XOR 更新存储。
- correction 写入使用固定 subslot 调度，每个 subslot 对每个 bank 至多一次写。
- 对同一 row 的多次 flip 先做 XOR 合并。
- subslot 数为公开常量，不能由冲突数量动态决定。

理想 correction 带宽为 L 条/拍时，tile 内额外周期约为：

```text
T_CORR = K * Q_BASE
T_TILE = W * Q_TILE
overhead = T_CORR / T_TILE
```

例：`L=32, COLS_PER_TILE=1056, Q_BASE=33, Q_TILE=36, W=111`

```text
K=4: 132 / 3996 = 3.3%
K=6: 198 / 3996 = 5.0%
```

若 correction 写入采用最保守逐列串行调度，周期成本接近 `K*COLS_PER_TILE`，适合作为功能验证，不适合作为性能实现。

## 常数时间要求

K-sign 实现遵守以下固定时间规则：

- 每个公开参数等级使用固定 `K`、`POS_W`、`COLS_PER_TILE`、`L`。
- selector 始终执行 K 级比较，不因候选填满提前结束。
- 每个 tile 始终执行完整 `W * Q_TILE` 主扫描。
- correction 阶段始终执行固定窗口，invalid 槽只 mask 写使能。
- 不使用由 syndrome、错误模式、H base row、dev 数量、候选幅值决定的循环次数。
- bank 冲突处理使用公开固定 subslot 数。
- 不使用译码成功提前停止。

公开参数等级可选择不同固定周期预算。统一硬件可按最大 `W_MAX`、`POS_W` 和固定 K 实现。

## 资源估算

统一 TRIKE 最大参数：

```text
N0 = 3
R_MAX = 108587
N = N0 * R_MAX = 325761
W_MAX = 111
POS_W = 7
```

长期 K-sign bit 数：

| K | 每变量 bit | 总 bit | 约 MiB |
| ---: | ---: | ---: | ---: |
| 4 | 29 | 9,447,069 | 1.13 |
| 6 | 43 | 14,007,723 | 1.67 |

BRAM36 粗估按 banked variable storage：

| 并行度 | K=4 | K=6 |
| ---: | ---: | ---: |
| L=16 | 约 320 BRAM36 | 约 400 BRAM36 |
| L=32 | 约 320 BRAM36 | 约 416 BRAM36 |

完整符号存储参考约为 1.0k BRAM36。K-sign 长期存储的主收益来自把每变量 `W_MAX=111` 个符号位压缩为 `1+K*7` bit。

Tile 内 selector 工作状态按 `COLS_PER_TILE=1168`、`D=4` 估算：

| K | 每变量工作记录 | 合计 |
| ---: | ---: | ---: |
| 4 | 45 bit | 52,560 bit |
| 6 | 67 bit | 78,256 bit |

该状态由按变量列 bank 化的 tile 工作 RAM 保存，并在 tile 间复用。全局双缓冲 K-sign RAM 保存 `1+K*POS_W` bit 的长期记录。

## 仿真观察

仿真参数：

```text
decoder = hw_quant_ms
msg_bits = 5
frac_bits = 0
max_iter = 7
sign_mode = high_mag_dev
```

TRIKE128：

| r | full sign DFR | K=6 DFR | K=4 DFR |
| ---: | ---: | ---: | ---: |
| 7200 | 5.128e-4 | 2.245e-3 | 6.905e-3 |
| 7250 | 6.200e-5 | 2.801e-4 | 9.524e-4 |
| 7300 | 6.500e-6 | 3.500e-5 | 1.253e-4 |
| 7350 | 1.500e-6 | 5.000e-6 | 1.000e-5 |

TRIKE256：

| r | full sign DFR | K=6 DFR | K=4 DFR |
| ---: | ---: | ---: | ---: |
| 25200 | 5.000e-5 | 1.700e-4 | 1.374e-4 |
| 25300 | 1.200e-5 | 4.000e-5 | 6.000e-5 |
| 25400 | 2.000e-6 | upper only | 1.000e-5 |

TRIKE512：

| r | full sign DFR | K=6 DFR | K=4 DFR |
| ---: | ---: | ---: | ---: |
| 94000 | 1.304e-3 | 1.190e-2 | 1.714e-2 |
| 94500 | 4.945e-5 | 1.242e-3 | 2.041e-3 |
| 95000 | 3.333e-6 | 4.000e-5 | 4.000e-5 |

观察结论：

- K=6 在三个等级上曲线形状稳定。
- K=4 在 TRIKE256 和 TRIKE512 的低 DFR 区接近 K=6。
- K=4 以更小长期存储换取更大的 DFR margin 需求。
- K=6 提供较稳的性能余量。

## RTL 集成

K-sign 数据通路由以下模块组成：

1. `ram_k_global`：每个变量列的全局双缓冲记录，字段为 `base_sign` 和 K 个 `dev_pos`。
2. `ram_k_tile`：活动 tile 的幅值工作 RAM，字段为 `base_sign` 和 K 个无序 `(dev_pos, magnitude)` 槽。
3. `k_sign_update`：无序候选槽的最差项归约树和单槽更新组合逻辑。
4. `k_sign_selector`：变量列 bank 路由、工作 RAM 读改写控制和压缩记录提交。
5. `k_sign_reconstruct`：根据全局压缩记录和 `diag_idx_local` 重建近似符号及命中标志。

最后一个对角线将压缩记录写入全局目标 pair。C2V 和 correction 读取全局记录，通过 `base_sign XOR hit(dev_pos == diag_idx_local)` 重建符号。主 V2C 使用 base-sign 更新，固定 correction 扫描对命中位置翻转对应 check row 的 `sign_xor`。

## 主要风险

| 风险 | 说明 | 处理方式 |
| --- | --- | --- |
| correction bank 冲突 | K 个 dev 位置按变量选择，映射到 row bank 后可能冲突 | 使用固定 subslot 调度或独立 sign_xor 更新存储 |
| selector 布线 | `COLS_PER_TILE*K` 候选状态分布在 tile 内 | 将 selector 状态按 lane/bank 分区，靠近 VNU 输出放置 |
| K=4 余量 | 小 K 对 DFR margin 更敏感 | 使用多 seed 和更低 DFR 区确认 |
| sign_xor 语义 | C2V 与 CNU A 必须使用同一近似符号定义 | C model、RTL 和测试向量共享 tie-break 规则 |

## 推荐配置

仿真和资源估算支持以下主配置：

```text
K = 4 或 K = 6
POS_W = 7
base_sign 保存在 K-sign 记录中
selector 规则 = high_mag_dev
tie-break = mag 大优先，diag_idx_local 小优先
```

硬件第一版可选择 K=4 作为资源优先配置，K=6 作为性能余量配置。最终 K 值由多 seed DFR、BRAM 预算、correction 写入时序共同决定。
