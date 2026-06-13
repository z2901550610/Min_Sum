# 解码器架构

## 模块划分

| 模块 | 职责 |
| --- | --- |
| `decoder_top` | 顶层接口、C2V/V2C 数据通路、最终错误估计读口 |
| `ram_i` | 保存 H 第一列行索引，执行固定深度范围检查、重复检测和加载完成计数 |
| `edge_addr_gen` | 根据 tile 坐标和 H base row 生成 L 路 row/col/edge 访问 |
| `tile_scheduler` | 生成固定 tile 窗口调度 |
| `ram_m` | 双 pair compressed check-state banked RAM |
| `ram_s` | edge sign banked RAM |
| `ram_t_accum` | 双缓冲 raw C2V 累加 RAM |
| `ram_t` | 双缓冲 raw C2V 边缓存 RAM |
| `ram_c1` | 最终错误估计 bit RAM |
| `vnu_update` | 变量节点 posterior/extrinsic 更新 |
| `cnu_a` / `cnu_b` | 压缩 check-state 更新和 C2V 重建硬件块 |
| `msg_signmag_to_tc` / `msg_tc_to_signmag_sat` | sign-magnitude 与 two's-complement 消息转换参考小模块 |

`decoder_top` 实例化 CNU_A、CNU_B 和 C2V message codec。RAM、CNU 和 VNU 数据通路由独立硬件块承载。

## 论文 RAM 对应关系

| RTL 名称 | 论文名称 | 内容 |
| --- | --- | --- |
| `ram_i` | RAM I | H 第一列非零行索引 |
| `ram_m` | RAM M0/M1/M2/M3 | `min1_mag, min2_mag, min_edge_id, sign_xor` 压缩 check state |
| `ram_s` | RAM S | V2C sign bit |
| `ram_t` | RAM T | VNU 计算 V2C 时使用的单边 raw C2V |
| `ram_t_accum` | VNU 累加存储 | tile 内 raw C2V 总和 |
| `ram_c1` | RAM C1 | 最终错误估计 bit |
| `syndrome_mem` | syndrome 存储 | 输入 syndrome bit |

## 状态数组

顶层使用公开参数定宽的状态数组：

| 数组 | 维度 | 内容 |
| --- | --- | --- |
| `syndrome_mem` | `[R]` | 输入 syndrome |
| `ram_c1` | `[N]` | 最终错误估计 bit |
| `ram_m` | `2 * L` banks | 双 pair 压缩 check state |
| `ram_s` | `L` banks | 36-bit packed row-local edge V2C sign |
| `ram_t_accum` | `2 * L` banks | tile-local raw C2V 累加和 |
| `ram_t` | `2 * L` banks | tile-local raw C2V 边值 |

`comp_pair` 保存：

```text
min1_mag, min2_mag, min_edge_id, sign_xor
```

每个迭代的写 pair 由固定清空窗口写入 `COMP_C2V_INIT`，随后 V2C 数据通路按 row bank 写入下一轮 compressed check state。

## C2V 数据通路

每个有效 lane 执行：

1. 读取 edge address generator 生成的 `row_idx`、`edge_id` 和 `tile_offset`。
2. 读取当前迭代的 compressed check state。
3. 读取上一轮对应 edge sign；第一次迭代使用 sign 0 和 `FIRST_ITER_C2V_COMP`。
4. 用 CNU_B 规则重建 sign-magnitude C2V。
5. 将 C2V 转为 two's-complement raw 值。
6. 写入 `ram_t`。
7. 累加到 `ram_t_accum`。

`one_idx==0` 时 tile accumulator 从 0 开始，后续 H 第一列项持续累加同一 tile offset 的 raw C2V。

## V2C 数据通路

每个有效 lane 执行：

1. 读取 `ram_t_accum` 作为 raw C2V 总和。
2. 读取 `ram_t` 作为当前边 raw C2V。
3. 计算 posterior 和 extrinsic V2C。
4. 将 V2C 饱和为 sign-magnitude 消息。
5. 用 CNU_A 规则更新下一轮 compressed check state。
6. 写入 `ram_m` 和 `ram_s`。
7. 最后一轮 `one_idx==0` 时写入 `ram_c1[col_idx]`。

变量节点缩放采用公开参数给定的移位项 alpha：

```text
scale(x) = round(x * alpha)
```

每个正 `ALPHA_SHIFT_*` 项贡献一个 `2^-shift` 项，`shift=0` 项贡献 0。

## Pair 切换

每轮开始时：

```text
comp_read_pair_sel  = current pair
comp_write_pair_sel = next pair
```

迭代末尾交换两个 pair。每个迭代开始时，写 pair 的所有 row-bank 地址按固定顺序初始化为 `COMP_C2V_INIT`。

## 存储综合约束

大状态存储使用 banked RAM 模块承载。功能有效性由固定写入窗口、H 加载门控和 pair 调度保证。
