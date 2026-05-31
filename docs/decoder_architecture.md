# 解码器架构

## 模块划分

- `decoder_ctrl` 负责解码控制、c2v/v2c 列上下文、RAM-M 乒乓 bank、列缓冲切换事件以及 done 状态管理。ITER 内部调度由固定 `SCHED_*` 状态表驱动，列 k 内部使用 `COL_K_STAGE_*` 表示 v2c 发射流水阶段。
- `decoder_top` 是解码器核心数据通路和结构互连。它实例化各编号 RAM 块、`decoder_ctrl`、CNU/VNU 单元和消息编解码适配器；顶层逻辑覆盖 RAM 端口选择、RAM-I lane entry 处理、数据锁存和错误估计导出。
- `vnu` 以 2's-complement 格式消费 c2v 并生成未饱和的 2's-complement v2c。符号-幅值转换在 VNU 输入/输出边界的外部 `msg_codec` 适配器中完成；RAM-T 和 VNU 缩放数据通路保持在 2's-complement 域内。
- `ram_i`、`ram_m`、`ram_s`、`ram_t`、`ram_c` 均为论文风格的 RAM 原语。每个 RTL 文件对应一个编号 RAM 块。

## RAM 组织

- `decoder_top` 按 lane 显式实例化 RAM-I 和 RAM-T，并实例化 `2*L` 个 RAM-M bank 组成读写 pair。RAM-S 是按变量列寻址的 sign-vector RAM。
- RAM-M 每个 numbered block 保存全局校验行地址空间中的压缩 c2v 状态和 1 bit epoch，深度为 `R`。压缩状态中的 `min_id` 使用行内 `edge_id = h_block_idx * W + one_idx`。顶层向 RAM-M、syndrome RAM 和验证侧传递 `row_idx_global`。
- RAM-I 和 RAM-T 的 lane 内 entry 深度统一为 `RAM_LANE_DEPTH`，表示首列元数据在各 lane 中的最大有效 entry 数。默认 BIKE-L1 形状参数下 `RAM_LANE_DEPTH=9`，`BIKE_TOY_PARAMS` 参数下 `RAM_LANE_DEPTH=3`。
- RAM-S 每个变量列保存一个 `W` bit v2c sign 向量。c2v 侧按列读取向量并用 `one_idx` 选择 edge sign；v2c 侧在一列的 CNU_A 写回过程中累积 sign 向量，并在列尾写回 RAM-S。
- RAM-T 每个 lane 以按 entry slot 寻址的缓冲保存列 k+1 生成的 c2v 和 valid sideband。列 k+1 每个 entry slot 都写入，空 lane 写入 invalid slot；v2c 发射阶段按同一个 entry slot 读取，valid sideband 控制 VNU 的外信息相减。`ITER_CHECK` 清空 RAM-T slot 状态。
- RAM-C 保存 syndrome 输入译码器的错误估计 bit，是一份适配 syndrome 输入语义的 `N` bit 存储，并提供串行读口用于导出最终估计。
- syndrome RAM 按 `M_ROW_BANKS` 个 row bank 保存 `R` bit syndrome。c2v 调度使用同一 row-bank 映射选择同拍有效 lane，保证 syndrome 读端口和 RAM-M 读端口的 bank 冲突约束一致。

## RAM-I 元数据

解码器需要知道 H 矩阵每个 circulant block 的首列中哪些位置为 1。由于 H 是双循环矩阵拼接，列 j 的拓扑等于首列循环移位 j 位，因此 RAM-I 保存首列元数据，运行时由 `decoder_top` 对首列行号加列内偏移并做环绕修正。

RAM-I entry 保存 `row_idx_global`。解码期间，c2v 侧按 `h_block_idx` 和 entry 位置读取首列 entry，并在 `decoder_top` 中由 RAM-I bank 编号和 entry 位置重建 `one_idx`。顶层对 `base_row_idx_global + col_idx_local` 执行一次环绕修正，得到活跃列的行地址，并生成该边的行内 `edge_id`。v2c 元数据独立缓冲，使 c2v 侧可以领先一列。

### `$readmemh` 初始镜像路径

静态首列元数据由 `scripts/gen_qc_first_columns.py` 离线生成，输出 hex 文件到 `rtl/generated/`。该脚本读取 `rtl/bike_pkg.sv` 的尺寸参数，并使用 `scripts/qc_matrix_data.py` 中的首列支撑集。每个首列支撑集按 `one_idx` 派生的 lane 分入 RAM-I bank，entry 保存 `row_idx_global`。

`ram_i.sv` 在 `initial` 块中通过 `$readmemh` 加载 hex 文件。模块参数 `INIT_HEX_PREFIX`、`BANK_IDX` 和 `INIT_HEX_TAG` 组合出每个 bank 使用的文件名；`INIT_HEX_STEM` 非空时可直接指定文件前缀。复位期间记忆体阵列保持初始化内容，复位释放后 RAM-I 包含对应参数集的首列元数据。

```systemverilog
ram_i #(
    .INIT_HEX_PREFIX("rtl/generated/l8/ram_i"),
    .BANK_IDX(0),
    .INIT_HEX_TAG("_l1")
) u_ram_i (...);
```

### 运行时加载路径

`decoder_top` 通过 `ram_i_idx_loader` 提供硬件加载路径，接口接收每个 circulant block 的首列非零行号流。输入顺序定义 `one_idx`，加载器用计数器产生 `one_idx`，并把每个行号写入对应 RAM-I lane。参数 `L` 约束为 2 的幂。

加载方式是 L-wide 分发：每个周期接收同一 `entry_pos` 下最多 `L` 个行号，lane `l` 对应 `one_idx = entry_pos * L + l`。当 `one_idx < W` 时写入该 lane 的 RAM-I entry；当 `one_idx >= W` 时该 lane 不写 entry。每个 H block 的加载周期数固定为 `RAM_LANE_DEPTH`，两个 H block 的加载周期数固定为 `N0 * RAM_LANE_DEPTH`。默认 BIKE-L1 参数下，每个 block 9 个周期，两个 block 18 个周期。

该加载器的派生信号如下：

| 信号 | 生成方式 | 用途 |
| --- | --- | --- |
| `entry_pos` | 加载周期计数器 | RAM-I lane 内写地址 |
| `lane_idx` | 并行输入 lane 编号 | RAM-I bank 选择 |
| `one_idx` | `entry_pos * L + lane_idx` | RAM-S sign 向量选择和 RAM-T 边编号语义 |
| `valid` | `one_idx < W` | RAM-I entry 和 count 有效性 |
| `row_idx_global` | 输入行号 | 首列支撑集行地址 |

`one_idx` 由 `entry_pos` 左移和 `lane_idx` 拼接得到。顶层端口 `i_h_load_start` 启动加载，`o_h_load_request_h_block_idx/o_h_load_request_entry_pos` 给出本周期请求坐标，外部在 `i_h_load_valid` 有效时提供 `i_h_load_row_idx_global[0:L-1]`。加载器输出 `o_h_load_ready/o_h_load_busy/o_h_load_done` 作为握手和完成状态。加载器写入 RAM-I inactive slot，并在每个 H block 结束时更新 count。

固定 L-wide 加载接口也支持只存 `row_idx_global` 并在读取侧由 `{entry_pos, lane_idx}` 重建 `one_idx` 的变体，用于减少 RAM-I 位宽。

## 访存冲突处理

访存组织采用静态 bank 化和固定调度。

- RAM-I 每个 lane 一个 bank，c2v 每周期从所有 lane 读取相同 `entry_pos`，`entry_pos < count[lane]` 控制有效性。
- RAM-M 使用 `2*L` 个 bank。`ram_m_read_pair_sel` 指向 c2v 读取的 pair，`ram_m_write_pair_sel` 指向 v2c/CNU_A 写回的 pair。pair 内每个 lane 独占一个 RAM-M bank。
- RAM-M 的 stale row 通过 per-pair epoch 处理。写入时随行保存 epoch，读取时与 pair epoch 比较，失配时返回 `COMP_C2V_INIT` 或第一次迭代常量。
- 迭代收尾窗口由控制器独占调度状态，正常 c2v/v2c 请求在该窗口停发。
- RAM-S 使用一个 1R1W sign-vector RAM。c2v 侧按列读出 `W` bit sign 向量；v2c 侧按列尾写回 `W` bit sign 向量。
- RAM-T 每个 lane 一个 1R1W bank，c2v push 和 v2c pop 使用同一 `entry_pos` 坐标系，valid sideband 表示空 lane。
- 列 metadata 使用 active/fill 双 slot，c2v 写 fill slot，v2c 读 active slot，列切换事件交换 slot。

## 设计边界

RTL 使用单级 VNU 缩放。灵活的消息存储选择、两级缩放、组大小重平衡属于扩展功能。
