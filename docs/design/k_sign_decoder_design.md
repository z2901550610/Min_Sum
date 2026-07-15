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

工作记录保存 `base_sign` 和 K 个无序 `(dev_pos, magnitude)` 槽。变量列的最后一个 `diag_idx_local` 完成后，硬件将 `base_sign` 和 K 个位置原地提交到全局 K-sign RAM。幅值状态只覆盖活动 tile。

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

K=3 时，每个 lane 使用两个比较选择节点组成最差项树，并使用一个候选门限比较器。工作记录只更新一个槽。

推荐 tie-break：

```text
mag 更大者优先
mag 相同则 diag_idx_local 更小者优先
```

同一变量列的候选按递增 `diag_idx_local` 到达。候选与最差项幅值相同时不执行替换；归约树在同幅值槽中选择位置较大的槽作为最差项。该规则完全确定，便于 C/RTL 对齐。

## Sign_xor 更新

K-sign 的关键约束是 `sign_xor_approx` 必须和 C2V 读取的近似 V2C 符号一致。check 符号状态拆成 base parity 和 deviation parity：

```text
sign_xor_base[row] = XOR of base_sign over connected variables
dev_xor[row]       = XOR of hit(dev_pos == diag_idx_local) over connected variables
sign_xor_approx[row] = sign_xor_base[row] XOR dev_xor[row]
```

主 V2C 扫描中，CNU A 把 `base_sign` 累积到 `ram_m.sign_xor_base`，并在 tile 工作 RAM 中确定每个变量节点的 K 个偏离位置。独立 correction 扫描读取完成 tile 的记录；每个命中位置对 `ram_sign_delta.dev_xor` 中对应 check row 执行一次翻转：

```text
if hit(dev_pos == diag_idx_local):
    dev_xor[row(dev_edge)] ^= 1
```

下一轮 C2V 同步读取 `ram_m` 和 `ram_sign_delta`，在进入 CNU B 前组合：

```text
c2v_sign = (sign_xor_base XOR dev_xor) XOR v2c_sign_approx XOR syndrome
```

`ram_m` 和 `ram_sign_delta` 都使用两个 iteration pair。C2V 读取上一轮 pair，V2C/correction 写当前轮 pair，因此重叠期间的读写访问落在不同物理 pair。

## Correction 重叠调度

`ram_k_tile` 使用两个工作 buffer。tile `t` 的 V2C 在 buffer `t[0]` 中维护候选；tile 完成后，correction 从该 buffer 读取记录，同时 tile `t+1` 的 V2C 使用另一个 buffer。扫描顺序固定为：

```text
for h_block_idx in 0..N0-1:
  for tile_idx in 0..TILE_COUNT-1:
    for diag_idx_local in 0..W-1:
      for lane_group_idx in 0..Q_TILE-1:
        parallel for lane in 0..L-1:
          if column valid and diag matches one retained dev_pos:
            dev_xor[row] ^= 1
```

同一个 `diag_idx_local/lane_group_idx` 的 L 个有效列经 `edge_addr_gen` 映射到不同 row bank，因此每个 delta bank 每拍最多接收一个 flip。`ram_sign_delta` 对连续命中同一地址提供固定 RMW 旁路。

tile 0 的 V2C 尾拍启动 correction。主路径共有 `TILES_TOTAL+1` 个 tile 窗口，correction 共有 `TILES_TOTAL` 个 tile 扫描窗口；启动错开两个 tile 窗口，因此主路径结束后固定保留一个 tile 扫描尾部：

```text
T_TILE   = W * Q_TILE
T_ITER   = ROW_SEG_SIZE + (TILES_TOTAL + 1) * T_TILE + 8 + T_TILE
T_DECODE = I_MAX * T_ITER + 6
```

统一 TRIKE、`K=3`、`L=16`、`Q_TILE=76` 的 correction 固定尾部为：

| 等级 | W | `T_TILE` |
| --- | ---: | ---: |
| TRIKE128 | 27 | 2052 |
| TRIKE160 | 35 | 2660 |
| TRIKE256 | 55 | 4180 |
| TRIKE384 | 83 | 6308 |
| TRIKE512 | 111 | 8436 |

## 常数时间要求

K-sign 实现遵守以下固定时间规则：

- 每个公开参数等级使用固定 `K`、`POS_W`、`COLS_PER_TILE`、`L`。
- selector 始终执行 K 级比较，不因候选填满提前结束。
- 每个 tile 始终执行完整 `W * Q_TILE` 主扫描。
- correction 窗口长度只由公开参数决定，invalid 槽只 mask 写使能。
- 不使用由 syndrome、错误模式、H base row、dev 数量、候选幅值决定的循环次数。
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
| 3 | 22 | 7,166,742 | 0.85 |

BRAM 数量由目标器件的 SDP primitive、bank 深度和 Vivado memory mapping 共同决定。统一 TRIKE、`L=16` 的全局记录总容量为 7,166,742 bit，综合时以目标器件报告为准。

完整符号存储参考约为 1.0k BRAM36。K-sign 长期存储的主收益来自把每变量 `W_MAX=111` 个符号位压缩为 `1+K*7` bit。

Tile 内 selector 工作状态按 `COLS_PER_TILE=1168`、`D=4` 估算：

| K | 每变量工作记录 | 单 buffer | 双 buffer |
| ---: | ---: | ---: | ---: |
| 3 | 34 bit | 39,712 bit | 79,424 bit |

该状态由按变量列 bank 化的双 buffer tile 工作 RAM 保存。一个 buffer 供 V2C 维护候选，另一个 buffer 供 correction 读取完成记录。全局 K-sign RAM 的逻辑记录宽度为 `1+K*POS_W` bit，物理上使用独立的 `base_sign` 字段，三个 `dev_pos` 槽分别使用窄 BRAM 字段。`dev_pos` 字段按 RAMB36 的 4K×9 原生几何划分深度段，并使用相同的逻辑 bank 地址和读写使能。C2V 完成一个 tile 的记录读取后，落后一窗口的 V2C 对同一 tile 原地提交记录。

`ram_sign_delta` 保存两个 iteration pair、每个 pair `R` bit 的 `dev_xor`，逻辑容量为 `2*R_MAX=217,174 bit`。它按 L 个 row bank 组织，物理 BRAM 数量以 Vivado 报告为准。

统一 TRIKE、`L=16`、K=3 的 RTL 实现和 Vivado 资源结果见
[implementation_status.md](implementation_status.md)。

## 仿真观察

下表是 K=4 和 K=6 的算法比较数据，用于判断减小 K 时的 DFR 趋势。K=3 的 RTL 随机 exact 测试覆盖功能一致性，不构成 DFR 结论；K=3 需要独立的多 seed DFR campaign。

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

1. `ram_k_global`：每个变量列的一份全局原地更新记录，`base_sign` 使用独立字段，三个 `dev_pos` 使用独立窄 BRAM 字段。
2. `ram_k_tile`：两个 tile 工作 buffer，字段为 `base_sign` 和 K 个无序 `(dev_pos, magnitude)` 槽。
3. `k_sign_update`：无序候选槽的最差项归约树和单槽更新组合逻辑。
4. `k_sign_selector`：变量列 bank 路由、双工作 RAM 读改写、correction 读取和压缩记录提交。
5. `k_sign_reconstruct`：根据全局压缩记录和 `diag_idx_local` 重建近似符号及命中标志。
6. `k_sign_overlap_scheduler`：按公开参数生成重叠 correction 的 tile、对角线和列组坐标。
7. `ram_sign_delta`：保存每个 check row 的 deviation parity，支持同步读取、清空和翻转 RMW。

最后一个对角线在该变量列的全部记录读取完成后，将压缩记录写回同一地址。C2V 通过 `base_sign XOR hit(dev_pos == diag_idx_local)` 重建变量边符号。主 V2C 把 base-sign 累积到 `ram_m`，重叠 correction 把命中位置的奇偶性累积到 `ram_sign_delta`；下一轮 C2V 将两部分异或后送入 CNU B。

## 主要风险

| 风险 | 说明 | 处理方式 |
| --- | --- | --- |
| correction bank 冲突 | 多列 dev 位置可能映射到同一个 row bank | 扫描使用与主 edge 路径相同的 lane-to-bank 排列 |
| selector 布线 | `COLS_PER_TILE*K` 候选状态分布在 tile 内 | 将 selector 状态按 lane/bank 分区，靠近 VNU 输出放置 |
| K=3 余量 | 小 K 对 DFR margin 更敏感 | 使用多 seed 和更低 DFR 区确认 |
| sign_xor 语义 | C2V 与 CNU A 必须使用同一近似符号定义 | C model、RTL 和测试向量共享 tie-break 规则 |
| 重叠路径时序 | 双 tile buffer、第三个 H 读口和 delta RMW 增加布局压力 | 使用 placed/routed 报告检查 LUT、BRAM 和 setup/hold |

## RTL 配置

RTL 使用以下配置：

```text
K = 3
POS_W = 7
base_sign 保存在 K-sign 记录中
selector 规则 = high_mag_dev
tie-break = mag 大优先，diag_idx_local 小优先
```

多 seed DFR、BRAM 预算和 correction 写入时序共同用于评估该固定配置。DFR campaign 完成前，K=3 属于资源优化候选参数。
