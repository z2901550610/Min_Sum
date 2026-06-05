# 解码器架构

## 模块划分

| 模块 | 职责 |
| --- | --- |
| `decoder_top` | 顶层接口、状态数组、C2V/V2C 数据通路、最终错误估计读口 |
| `support_mem` | 保存第一列 support，执行固定深度范围检查、重复检测和加载完成计数 |
| `support_row_col_gen` | 根据 tile 坐标和 support 项生成 L 路 row/col/edge 访问 |
| `support_major_ctrl` | 生成 support-major tile 固定窗口调度 |
| `cnu_a` / `cnu_b` | 压缩 check-state 更新和 C2V 重建的独立参考小模块 |
| `msg_signmag_to_tc` / `msg_tc_to_signmag_sat` | sign-magnitude 与 two's-complement 消息转换参考小模块 |

`decoder_top` 内联使用 CNU 和 message codec 的等价组合逻辑，以便 C2V/V2C 两段数据通路保持在同一模块内。独立 CNU/msg 模块由单元测试覆盖。

## 状态数组

顶层使用公开参数定宽的状态数组：

| 数组 | 维度 | 内容 |
| --- | --- | --- |
| `syndrome_mem` | `[R]` | 输入 syndrome |
| `decision_mem` | `[N]` | 最终错误估计 bit |
| `comp_pair` | `[2][R]` | 双 pair 压缩 check state |
| `comp_epoch` | `[2][R]` | 每个 pair 的 row epoch |
| `pair_epoch` | `[2]` | 当前 pair 世代 bit |
| `sign_mem` | `[N0*W][R]` | 每条 row-local edge 的上一轮 V2C sign |
| `tile_accum` | `[2][C_TILE]` | tile-local raw C2V 累加和 |
| `tile_t` | `[2][L][W*Q_TILE]` | tile-local raw C2V 边值 |

`comp_pair` 保存：

```text
min1_mag, min2_mag, min_edge_id, sign_xor
```

epoch 位用于判断某行是否在当前 pair 中已被写入。epoch 不匹配时，读出值按 `COMP_C2V_INIT` 处理。

## C2V 数据通路

每个有效 lane 执行：

1. 读取 support 生成的 `row_idx`、`edge_id` 和 `tile_offset`。
2. 读取当前迭代的 compressed check state。
3. 读取上一轮对应 edge sign；第一次迭代使用 sign 0 和 `FIRST_ITER_C2V_COMP`。
4. 用 CNU_B 规则重建 sign-magnitude C2V。
5. 将 C2V 转为 two's-complement raw 值。
6. 写入 `tile_t[fill_buf][lane][one_idx * Q_TILE + q_seq]`。
7. 累加到 `tile_accum[fill_buf][tile_offset]`。

`one_idx==0` 时 tile accumulator 从 0 开始，后续 support 项持续累加同一 tile offset 的 raw C2V。

## V2C 数据通路

每个有效 lane 执行：

1. 读取 `tile_accum[active_buf][tile_offset]` 作为 raw C2V 总和。
2. 读取 `tile_t[active_buf][lane][one_idx * Q_TILE + q_seq]` 作为当前边 raw C2V。
3. 计算 posterior 和 extrinsic V2C。
4. 将 V2C 饱和为 sign-magnitude 消息。
5. 用 CNU_A 规则更新下一轮 compressed check state。
6. 写入 `comp_pair[comp_write_pair_sel][row_idx]` 和 `sign_mem[edge_id][row_idx]`。
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

大数组不使用同步复位清零。功能有效性由控制器固定写入窗口、support 加载门控和 epoch 位保证。该写法便于综合器将大状态阵列映射为存储资源或规则寄存器阵列。
