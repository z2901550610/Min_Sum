# QC-MDPC Min-Sum 译码器说明

## 总览

当前 RTL 按“存储体 + 计算单元 + 顶层调度”的方式组织。

- `ram_i` 保存每个循环子矩阵当前列的非零索引，并负责列移位
- `h_shift` 把索引 RAM 的内容展开成当前要处理的边信息
- `cnu_a` 更新 check row 的压缩状态
- `cnu_b` 从压缩状态重建单条 `c2v`
- `vnu` 计算 `app`、硬判决和下一轮 `u`
- `decoder_top` 负责各类 RAM 的读写控制和阶段切换

消息格式约定：

- `CNU` 一侧和 `RAM U` 使用 sign-magnitude
- `VNU` 一侧和 `RAM T` 使用 signed 2's complement
- sign-magnitude 到 2's complement 的转换只放在 `CNU_B -> RAM T` 边界
- 2's complement 到 sign-magnitude 的转换只放在 `VNU -> RAM U` 边界

## 固定参数

- `n0 = 2`
- `r = 8`
- `w = 3`
- `n = 16`
- `L = 2`
- `Imax = 4`
- `C = 9`
- `alpha = 3/32 = 2^-4 + 2^-5`
- `H0` 首列非零位置 `{0, 1, 3}`
- `H1` 首列非零位置 `{0, 2, 5}`

## 存储体组织

### `RAM I`

文件：`rtl/ram_i.sv`

作用：

- 按 bank 保存当前列的非零边索引
- 每个 entry 保存 `{row_local, edge_slot}`
- 在一列处理完成后对当前 bank 做一次 `+1 mod r` 移位

这里按论文第一种连续行段方案分 lane，分段大小是 `ROW_SEG_SIZE = ceil(R / L)`。在 demo 的 `R=8, L=2` 下：

- lane 0 对应 rows `[0..3]`
- lane 1 对应 rows `[4..7]`

`lane_count` 给出每条 lane 当前有多少条有效边，`lane_entries` 给出对应 entry。

### `RAM C0 / C1`

文件：`rtl/ram_c.sv`

作用：

- `C0` 保存输入硬判决，用来生成先验消息 `prior_j`
- `C1` 保存当前轮更新后的硬判决

### `RAM M`

文件：`rtl/ram_m.sv`

作用：

- 保存每个 check row 的压缩状态
- 内部是两组 ping-pong bank，每组按 `L=2` 个 row segment 分成 lane-local RAM
- CNU B 从当前迭代 read bank 读压缩状态，CNU A 向下一迭代 write bank 累积新状态
- 每次 `CHECK` 后若继续迭代，read/write bank 交换，并只清空新的 write bank

每行状态包含：

- `min1`
- `min2`
- `min_id`
- `sign_xor`

### `RAM S`

文件：`rtl/ram_s.sv`

作用：

- 保存每条边对应的 `u_i,j` 符号位

地址形式是：

- `var_idx`
- `edge_slot`

### `RAM T`

文件：`rtl/ram_t.sv`

作用：

- 保存 `c2v` 消息
- 作为论文 Fig. 7 中的中间 `c2v` 缓存
- 以 signed 2's complement 形式保存
- CNU B 生成 `c2v` 时写入
- VNU emit 上一列时每拍从中取最多 `L=2` 条消息做 `app - alpha*c2v`

### `RAM U`

文件：`rtl/ram_u.sv`

作用：

- 保存下一轮送回 CNU A 的 `u_i,j`
- 以 sign-magnitude 形式保存
- `LOAD` 阶段用先验消息初始化
- 流水阶段 VNU emit 每拍最多写回两条 `v2c`，同时这些 `v2c` 直连 CNU A

## 模块说明

### `h_shift`

输入：

- `var_idx`
- `lane_entries`
- `lane_count`

输出：

- `lane_edges`

它把 `RAM I` 中的 `{row_local, edge_slot}` 扩展成当前计算用的边描述：

- `row_global`
- `row_local`
- `var_idx`
- `edge_slot`
- `valid`

### `cnu_a`

输入：

- `clk/rst_n/clear_en`
- `in_valid`
- 单条 `u_i,j`
- 当前 `var_idx`
- 当前 row 的压缩状态

输出：

- 单拍后输出更新后的 row state
- 单拍后输出当前边的 sign bit
- `out_valid`

功能：

- 每周期处理一条 `u_i,j`
- 更新 `min1/min2/min_id`
- 累积 `sign_xor`

这里的 `u_i,j` 采用 sign-magnitude 表示，这样可以直接拆出：

- sign 给 `sign_xor`
- magnitude 给 `min1/min2`

这里直接对应论文 Fig. 6(a) 里的 `CNU A`：

- 行状态本体保存在 `RAM M`
- `cnu_a` 负责对当前输入边做一次时序更新
- 不再引入论文中没有的 `valid_count`

### `cnu_b`

输入：

- 当前 row 的压缩状态
- 当前边的 `u_sign`
- `var_idx`

输出：

- 单条 `c2v`

功能：

- 若当前变量等于 `min_id`，输出 `min2`
- 否则输出 `min1`
- 输出符号为 `sign_xor XOR u_sign`

`cnu_b` 输出的 `c2v` 仍然是 sign-magnitude；顶层在写入 `RAM T` 前再统一转换成 signed 2's complement。

### `vnu`

输入：

- `prior_msg_j`
- 每拍最多两条 `c2v`
- `RAM T` 逐拍读出的最多两条缓存 `c2v`

输出：

- 累加结束后输出并寄存 `app_j`
- 硬判决 `x_j`
- 逐拍输出下一轮 `u_i,j`

功能：

- 每周期累加两条 `c2v`
- `RAM T` 中的 `c2v` 以 signed 2's complement 缓存，进入累加路径前转换成 VNU 的输入格式
- `app = prior + alpha * sum(v)`
- `u = app - alpha * v`
- `alpha` 按论文约束成 6 位小数里两个非零 bit，用移位相加加 rounding 实现
- `VNU` 内部始终使用 signed 2's complement 做累加、缩放和减法
- `u` 输出前从 2's complement 转回 sign-magnitude

`u` 以 sign-magnitude 形式写回，并做幅值饱和。

### `decoder_top`

文件：`rtl/decoder_top.sv`

顶层负责：

- 驱动 `RAM I / C / M / S / T / U`
- 组织论文 Fig. 8 风格的列级流水
- 在 `CNU_B(iter k, col j+1)` 运行时，同时让 VNU emit `col j` 并把新 `v2c` 直连 `CNU_A(iter k+1, col j)`
- 维护 `active_var_idx`、`scan_slot`、`iter_count`

状态机包括：

- `LOAD`
- `INIT_CNU_A`
- `INIT_CNU_A_FLUSH`
- `PIPE_PREP`
- `PIPE`
- `PIPE_DRAIN`
- `PIPE_FLUSH`
- `CHECK`
- `DONE`

## 数据通路

### `LOAD`

- `x_in` 写入 `C0` 和 `C1`
- `U RAM` 按先验消息初始化
- `I RAM` 装载首列索引
- `M RAM` 清零到初始 row state
- `S RAM` 和 `T RAM` 清零

### `INIT_CNU_A`

- `I RAM` 给出当前列非零边
- `h_shift` 生成两条 lane 的边描述
- `U RAM` 读出当前边的 `u_i,j`
- `M RAM` 的初始 read bank 读出对应 row state
- `cnu_a` 在时钟边沿锁存这条边，并在下一拍给出更新后的 row state 和 sign
- row state 写回初始 read bank，形成第 0 次迭代 CNU B 要读取的压缩 c2v
- sign 写入 `S RAM`
- 一列处理完成后，`I RAM` 对当前 bank 做列移位

### `PIPE_PREP`

- 处理第 0 列，只运行 CNU B 和 VNU accumulation
- `M RAM` read bank 读出压缩 row state
- `S RAM` 读出当前边 sign
- `cnu_b` 生成 `c2v`，直接送入 VNU accumulation，同时写入 `T RAM`
- 顶层按 `edge_slot` 缓存当前列 edge descriptor，供下一列 emit/CNU A 使用

### `PIPE`

- 当前列执行 CNU B 并累加当前列 `c2v`
- 上一列执行 VNU emit：从 `T RAM` 读缓存 `c2v`，计算 `u = app - alpha*c2v`
- VNU emit 的 `u` 同周期送入 CNU A，CNU A 更新下一迭代 write bank 的 row state
- `u` 同时写回 `RAM U`，`x_j` 写回 `RAM C1`
- 当前列结束后 edge descriptor buffer 轮换，下一列继续流水

### `PIPE_DRAIN / PIPE_FLUSH`

- 所有 CNU B 列处理完后，`PIPE_DRAIN` 补最后一列的 VNU emit/CNU A
- `PIPE_FLUSH` 给 CNU A 的寄存输出留一拍写回 `RAM M`

### `CHECK`

- 对 `C1 RAM` 当前硬判决做 syndrome 计算
- syndrome 为零则结束
- 否则 `iter_count` 加一，RAM M read/write bank 交换，清空新的 write bank，返回 `PIPE_PREP`

## 验证

当前测试覆盖：

- `tb_cnu_a`
- `tb_cnu_b`
- `tb_vnu`
- `tb_decoder_top`

集成测试除了最终 `done/success/x_out/iter_count` 之外，还会检查首轮：

- `M RAM` 中的 row state
- `T RAM` 中的 2's complement `c2v`
- `U RAM` 中更新后的 `u`
