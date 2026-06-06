# 解码器架构

## 模块划分

| 模块 | 职责 |
| --- | --- |
| `decoder_top` | 顶层接口、C2V/V2C 数据通路、最终错误估计读口 |
| `h_matrix_mem` | 保存 H 第一列行索引，执行固定深度范围检查、重复检测和加载完成计数 |
| `edge_addr_gen` | 根据 tile 坐标和 H base row 生成 L 路 row/col/edge 访问 |
| `tile_scheduler` | 生成固定 tile 窗口调度 |
| `check_state_ram` | 双 pair compressed check-state banked RAM |
| `msg_sign_ram` | edge sign banked RAM |
| `tile_accum_ram` | 双缓冲 raw C2V 累加 RAM |
| `c2v_cache_ram` | 双缓冲 raw C2V 边缓存 RAM |
| `vnu_update` | 变量节点 posterior/extrinsic 更新 |
| `cnu_a` / `cnu_b` | 压缩 check-state 更新和 C2V 重建的独立参考小模块 |
| `msg_signmag_to_tc` / `msg_tc_to_signmag_sat` | sign-magnitude 与 two's-complement 消息转换参考小模块 |

`decoder_top` 内联使用 CNU 和 message codec 的等价组合逻辑，RAM 和 VNU 数据通路由独立硬件块承载。独立 CNU/msg 模块由单元测试覆盖。

## 状态数组

顶层使用公开参数定宽的状态数组：

| 数组 | 维度 | 内容 |
| --- | --- | --- |
| `syndrome_mem` | `[R]` | 输入 syndrome |
| `decision_mem` | `[N]` | 最终错误估计 bit |
| `check_state_ram` | `2 * L` banks | 双 pair 压缩 check state 和 row epoch |
| `pair_epoch` | `[2]` | 当前 pair 世代 bit |
| `msg_sign_ram` | `L` banks | 每条 row-local edge 的上一轮 V2C sign |
| `tile_accum_ram` | `2 * L` banks | tile-local raw C2V 累加和 |
| `c2v_cache_ram` | `2 * L` banks | tile-local raw C2V 边值 |

`comp_pair` 保存：

```text
min1_mag, min2_mag, min_edge_id, sign_xor
```

epoch 位用于判断某行是否在当前 pair 中已被写入。epoch 不匹配时，读出值按 `COMP_C2V_INIT` 处理。

## C2V 数据通路

每个有效 lane 执行：

1. 读取 edge address generator 生成的 `row_idx`、`edge_id` 和 `tile_offset`。
2. 读取当前迭代的 compressed check state。
3. 读取上一轮对应 edge sign；第一次迭代使用 sign 0 和 `FIRST_ITER_C2V_COMP`。
4. 用 CNU_B 规则重建 sign-magnitude C2V。
5. 将 C2V 转为 two's-complement raw 值。
6. 写入 `c2v_cache_ram`。
7. 累加到 `tile_accum_ram`。

`one_idx==0` 时 tile accumulator 从 0 开始，后续 H 第一列项持续累加同一 tile offset 的 raw C2V。

## V2C 数据通路

每个有效 lane 执行：

1. 读取 `tile_accum_ram` 作为 raw C2V 总和。
2. 读取 `c2v_cache_ram` 作为当前边 raw C2V。
3. 计算 posterior 和 extrinsic V2C。
4. 将 V2C 饱和为 sign-magnitude 消息。
5. 用 CNU_A 规则更新下一轮 compressed check state。
6. 写入 `check_state_ram` 和 `msg_sign_ram`。
7. 最后一轮 `one_idx==0` 时写入 `decision_mem[col_idx]`。

变量节点缩放采用 6-bit 小数 alpha：

```text
scale(x) = round(x * alpha)
```

alpha 由 `ALPHA_SHIFT_0` 和 `ALPHA_SHIFT_1` 表示为两个移位项之和。

## Pair 切换

每轮开始时：

```text
comp_read_pair_sel  = current pair
comp_write_pair_sel = next pair
```

迭代末尾交换两个 pair，并翻转释放 pair 的 epoch。写 pair 中未触达的 row 在后续读取时由 epoch 机制返回初始 compressed state。

## 存储综合约束

大状态存储使用 banked RAM 模块承载。功能有效性由固定写入窗口、H 加载门控和 epoch 位保证。
