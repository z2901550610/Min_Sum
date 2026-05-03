# BIKE Syndrome输入 Min-Sum 解码器

## 概述

本 RTL 实现了一个 BIKE 风格的syndrome解码器。校验矩阵为双循环矩阵：

- `H = [H0 | H1]`
- `H0` 和 `H1` 由各自的首列向量表示，存储在 `bike_pkg.H_BASE[h_sel][bank][edge]` 中
- `bank = 0` 对应 `H0`，`bank = 1` 对应 `H1`

解码器接受初始syndrome，根据静态首列向量填充各 circulant bank，并估计错误向量：

- 输入：`i_syndrome[R-1:0]`
- 输出：`o_e[N-1:0]`
- 成功条件：`i_syndrome ^ H*o_e == 0`

## 参数

`rtl/bike_pkg.sv` 是解码器核心的参数包。

- 默认构建：小型 BIKE 演示参数（`R=8`, `W=3`），用于快速 RTL 测试
- `BIKE_L1_PARAMS` 构建：BIKE-L1 规模参数（`R=12323`, `W=71`, `N=24646`），使用确定性的首列向量

其中 `W` 是每个 circulant block 的列权重，BIKE-L1 的总行重为 `N0 * W = 142`。

## 解码语义

解码器从全零错误估计开始。

- `ram_c` 存储运行中的错误估计（硬判决位）
- `RAM U` 的每条边初始化为 `{sign=0, mag=C_VAL}`
- `VNU` 先验值始终为 `+C_VAL`
- `CNU_A` 仅累积每个压缩 c2v 状态中传入的 `u` 符号
- `CNU_B` 计算每条输出边的符号：

```text
row_sign_xor ^ edge_u_sign ^ syndrome[row]
```

每次迭代结束时，从 RAM C1 的内容重新计算残差syndrome，RAM C1 是导出错误估计 `o_e` 的唯一数据源。残差为零时解码成功，达到 `I_MAX` 次迭代后仍未清零则解码失败。

## 初始化

解码器需要知道 H 矩阵每个 circulant block 的首列中哪些位置为 1。由于 H 是双循环矩阵拼接，列 j 的拓扑等于首列循环移位 j 位，因此只需存储首列元数据，运行时由 `h_shift` 在线计算任意列的元数据。

### 离线生成 hex 文件

初始化数据由 `scripts/gen_qc_first_columns.py` 离线生成。该脚本解析 `rtl/bike_pkg.sv` 中的 `H_BASE` 数组，对每个 circulant block 的首列支撑集按 row_group 分 lane，打包为 `{one_idx, row_local}` 格式的 entry，输出 8 个 hex 文件到 `rtl/generated/`：

```
ram_i0_entries_test.hex    ram_i0_counts_test.hex     # I0，默认测试参数
ram_i1_entries_test.hex    ram_i1_counts_test.hex     # I1，默认测试参数
ram_i0_entries_l1.hex      ram_i0_counts_l1.hex       # I0，BIKE_L1 参数
ram_i1_entries_l1.hex      ram_i1_counts_l1.hex       # I1，BIKE_L1 参数
```

- **entries 文件**：每行一个十六进制值，按 row-major 顺序排列（先 hblk=0 的 W 个 entry，再 hblk=1 的 W 个 entry，以此类推）。无效 entry 填 0。
- **counts 文件**：每行一个十六进制值，对应每个 H block 中该 lane 的有效 entry 数量。

Makefile 中将首个 hex 文件列为 `test-unit` 和 `test-integration` 的依赖，确保 `bike_pkg.sv` 或生成脚本有改动时自动重新生成。

### 仿真启动加载

`ram_i.sv` 在 `initial` 块中通过 `$readmemh` 加载 hex 文件：

```systemverilog
initial begin
    $readmemh({INIT_HEX_STEM, "_entries", INIT_TAG, ".hex"}, list_entries_mem);
    $readmemh({INIT_HEX_STEM, "_counts", INIT_TAG, ".hex"}, list_count_mem);
end
```

其中 `INIT_HEX_STEM` 是模块参数，在 `decoder_top` 实例化时指定：

```systemverilog
ram_i #(.INIT_HEX_STEM("rtl/generated/ram_i0")) u_ram_i0 (...);
ram_i #(.INIT_HEX_STEM("rtl/generated/ram_i1")) u_ram_i1 (...);
```

`INIT_TAG` 通过 `` `ifdef BIKE_L1_PARAMS `` 选择 `"_l1"` 或 `"_test"`，确保编译时匹配正确的参数集。

`$readmemh` 在仿真时间零点执行，直接将 hex 文件内容加载到 `list_entries_mem` 和 `list_count_mem`。复位期间记忆体阵列**不清零**（仅复位输出寄存器 `o_entry_rdata`），因此复位释放后 RAM-I 已包含完整的首列元数据，解码器进入 INIT 状态即可直接使用。

## 模块划分

- `decoder_ctrl` 负责解码控制、c2v/v2c 列上下文、RAM-M 乒乓 bank、列缓冲切换事件以及 done/success 状态管理。实现采用少量宏状态配合计数器/valid 风格的活动标志，将调度逻辑分布在列上下文中。
- `decoder_top` 是解码器核心数据通路和结构互连。它实例化各编号 RAM 块、`decoder_ctrl`、`h_shift`、CNU/VNU 单元和消息编解码适配器；顶层逻辑仅限于 RAM 端口选择、RAM-I 行组 entry 处理、数据锁存和残差syndrome重算。
- `vnu` 以 2's-complement 格式消费 c2v 并生成未饱和的 2's-complement v2c。符号-幅值转换在 VNU 输入/输出边界的外部 `msg_codec` 适配器中完成；RAM-T 和 VNU 缩放数据通路保持在 2's-complement 域内。
- `ram_i`、`ram_m`、`ram_s`、`ram_t`、`ram_u`、`ram_c` 均为论文风格的同步读单端口 RAM 原语。每个 RTL 文件对应一个编号 RAM 块。
- `decoder_top` 按论文命名显式实例化各 RAM 块：`I0/I1`、`M0/M1/M2/M3`、`S0/S1`、`T0/T1`、`U0/U1`、`C0/C1`。
- `decoder_ctrl` 遵循论文的 Fig.8 式单端口调度：每次迭代先将列 0 的数据填入 RAM-T，然后进入列重叠流水线——c2v 侧重建列 `j+1` 的同时 v2c 侧累积并更新列 `j`，最后排空 v2c 的最后一列，进入 `ITER_CHECK`。复用的 RAM-M 行通过逐行 epoch 追踪器实现 `COMP_C2V_INIT` 语义。`phase` 信号仅用于调试；数据通路时序由显式的控制脉冲和列缓冲切换事件驱动。
- RAM-I 在仿真启动时通过 `$readmemh` 从 hex 文件加载首列元数据。解码期间，活跃列的行/局部行/边索引元数据来自 RAM-I 的行组列表。`h_shift` 为每个 RAM-I 块设置一个 entry 输入，为每个 lane 设置一个移位后的 entry 输出，数据通路通过 RAM-I 的单 entry 写端口将每个移位后的 entry 写入下一个 c2v 列。v2c 元数据独立缓冲，使 c2v 侧的 RAM-I 可以领先一列。`decoder_top` 通过 RAM-I 的功能列视图输出访问 RAM-I。项目级 RTL 命名约定定义在 [`docs/naming_conventions.md`](/Users/z2901550610/Documents/Min_Sum/docs/naming_conventions.md) 中。行组方案基于奇偶：`row_group 0` 存储偶数行，`row_group 1` 存储奇数行，`row_local` 为紧凑的奇偶局部索引 `floor(row_global / 2)`。CNU/VNU 行地址调度由 RAM-I 元数据驱动。
- `decoder_edge_meta` 和 `qc_column_preprocess` 保留在 [`rtl/reference/`](/Users/z2901550610/Documents/Min_Sum/rtl/reference) 下作为参考辅助文件。核心解码器使用 RAM-I + `h_shift` 提供活跃边元数据。
- 静态首列元数据由 [`scripts/gen_qc_first_columns.py`](/Users/z2901550610/Documents/Min_Sum/scripts/gen_qc_first_columns.py) 离线生成，输出 hex 文件到 `rtl/generated/`。RAM-I 通过 `$readmemh` 在仿真启动时直接加载。
- c2v 侧在列开始时缓冲活跃的 RAM-I 列，使得下一列的单 entry 移位写入不会干扰当前列的元数据视图。
- 待实现：两级缩放、灵活的消息存储选择、论文中的宽字 `RAM S` 打包/移位寄存器方案、组大小重平衡。当前 RTL 使用单级 VNU 缩放。

## 状态机详解

`decoder_ctrl` 使用 4 个宏状态加嵌套子状态的层次化 FSM，实现 Fig.8 式列重叠调度。RAM-I 的首列元数据通过 `$readmemh` 在仿真启动时从 hex 文件加载，无需状态机参与。

### 状态转移总览

```mermaid
stateDiagram-v2
    [*] --> WAIT

    WAIT --> INIT : i_start=1

    state INIT {
        [*] --> READ
        READ --> CNU_A
        CNU_A --> WRITE
        WRITE --> READ : 递增 entry 或进入下一列
    }

    INIT --> ITER : 所有列初始化完成

    state ITER {
        [*] --> PROD_ONLY
        PROD_ONLY --> OVERLAP : 列 0 填充完毕
        OVERLAP --> DRAIN : producer 到达最后一列
        DRAIN --> ITER_CHECK : 最后一列排空

        state OVERLAP {
            [*] --> ACCUM
            ACCUM --> V2C : 当前列累加完毕
            V2C --> ACCUM : 下一列
        }

        ITER_CHECK --> PROD_ONLY : i_finish_decode=0\n(继续迭代，交换 RAM-M pair)
    }

    ITER --> DONE : i_finish_decode=1

    DONE --> INIT : i_start=1
```

### 宏状态

#### 1. CTRL_WAIT — 上电空闲

`i_rst_n` 复位后的初始状态。解码器在此等待首次 `i_start` 信号。当 `i_start` 置位时，复位所有内部计数器、子状态、列索引和 entry 位置指针，跳转到 **CTRL_INIT**。后续解码完成后再收到 `i_start` 时，状态机从 **CTRL_DONE** 直接跳回 **CTRL_INIT**，不会再次经过 WAIT。WAIT 仅存在于复位路径，为硬件上电提供一个确定的起点。

#### 2. CTRL_INIT — 初始压缩 c2v 对构建

RAM-I 的首列元数据在仿真启动时通过 `$readmemh` 从 hex 文件自动加载（由 `gen_qc_first_columns.py` 根据 `H_BASE` 预生成），无需运行时播种。

INIT 为所有变量列构建初始压缩 c2v 对（第一次迭代的输入），内部有以下微步骤，按列遍历，每列内按 entry 位置步进：

| 微步骤 | 信号 | 功能 |
|---|---|---|
| `INIT_STEP_READ` | `o_init_m_read` | 从 RAM-M / RAM-U 读取当前 entry 的 c2v 数据 |
| `INIT_STEP_CNU_A` | `o_init_cnu_a` | 使能 CNU_A 进行初始累加运算 |
| `INIT_STEP_WRITE` | `o_init_m_write` | 将 CNU_A 结果写回 RAM-M / RAM-U |

播种完成后，每个 entry 依次经过 READ → CNU_A → WRITE 三步。entry 步进规则：

- 非最后 entry（`i_c2v_entry_pos_last = 0`）：递增 `o_c2v_entry_pos`，回到 `INIT_STEP_READ`。
- 最后 entry 但非最后列：`o_c2v_entry_pos` 归零，`o_c2v_var_idx` 递增，回到 `INIT_STEP_READ`。
- 最后 entry 且最后列（`o_c2v_var_idx == LAST_VAR`）：所有列初始化完成，进入 **CTRL_ITER**，激活 producer，列索引归零。

#### 3. CTRL_ITER — 迭代解码（核心）

`CTRL_ITER` 实现 **Fig.8 列重叠调度**：一条流水线（producer，c2v 侧）重建列 j+1 的 LLR，另一条流水线（consumer，v2c 侧）对列 j 进行 VNU 累积和 v2c 更新。两条流水线重叠运行，c2v 始终领先 v2c 一列。

##### 3a. PRODUCER ONLY（Prime 阶段）— 填充 v2c 列 0

- 只有 producer 活跃，consumer 不活跃。
- 循环 `PROD_STEP_READ → PROD_STEP_WRITE`，遍历 c2v 列 0 的所有 entry。
  - `PROD_STEP_READ`：`o_c2v_read = 1`，从 RAM-M / RAM-S 读取压缩 c2v 数据。
  - `PROD_STEP_WRITE`：`o_c2v_write_t = 1`，将 CNU_B/编解码结果写入 RAM-T。
- 每个 entry 完成后：非最后 entry 则递增 `o_c2v_entry_pos` 回到 `PROD_STEP_READ`。最后 entry 则激活 consumer（`consumer_active = 1`），consumer 模式设为 `CONS_MODE_ACCUM`，`o_v2c_var_idx` 设为与 `o_c2v_var_idx` 相同。若 `o_c2v_var_idx == LAST_VAR`，停用 producer（drain 开始）；否则 producer 继续激活，`o_c2v_var_idx` 递增（overlap 开始），`o_c2v_v2c_overlap_seen` 置位。

##### 3b. PRODUCER + CONSUMER（Overlap 阶段）— 流水线并行

Producer 和 consumer 同时活跃。Consumer 在两个模式间切换：

**ACCUM 模式**（`CONS_MODE_ACCUM`，VNU 累积）：

| 微步骤 | 信号 | 功能 |
|---|---|---|
| `CONS_STEP_READ` | `o_vnu_read_t` | 从 RAM-T 读取一个 c2v 值，供 VNU 累加 |
| `CONS_STEP_USE` | `o_vnu_accum_t` | 在 VNU 中累加该 RAM-T 值 |

在 `CONS_STEP_READ` 时，若 producer 活跃，producer 步进到 `PROD_STEP_WRITE`。在 `CONS_STEP_USE` 时，若 producer 活跃，producer 步进到 `PROD_STEP_READ`。当前 v2c 列所有 entry 累加完毕后（`i_v2c_entry_pos_last = 1`），切换到 `CONS_MODE_V2C`，进入 **V2C 模式**。

**V2C 模式**（`CONS_MODE_V2C`，发射 v2c 更新）：

| 微步骤 | 信号 | 功能 |
|---|---|---|
| `CONS_STEP_PREP` | `o_vnu_prep_write` | 捕获 VNU 硬判决，准备 v2c 写入 |
| `CONS_STEP_READ_NEXT_M` | `o_vnu_read_next_m` | 读取下一个 RAM-M 对，为 CNU_A 做准备 |
| `CONS_STEP_CNU_A` | `o_vnu_cnu_a` | 用 VNU 生成的 v2c 值使能 CNU_A |
| `CONS_STEP_WRITE` | `o_vnu_write_next` | 将结果写入 RAM-U / RAM-M / RAM-S，为下一次迭代准备 |

在 `CONS_STEP_READ_NEXT_M` 时，若 producer 活跃，producer 写入一个 c2v 结果。在 `CONS_STEP_CNU_A` 时，若 producer 活跃，producer 读取下一个 c2v entry，最后 entry 则停用 producer。

`CONS_STEP_WRITE` 结束时的分流逻辑：

- v2c 最后 entry 且 `o_v2c_var_idx == LAST_VAR`：停用 consumer，设置 `iter_check_pending = 1`，进入迭代检查。
- v2c 最后 entry 且 producer 活跃：停用 consumer，回到仅 producer 模式。
- v2c 最后 entry 且 producer 不活跃：递增 `o_v2c_var_idx`，若后续还有列则激活 producer 并设 `o_c2v_var_idx` 领先两列。
- 否则：递增 `o_v2c_entry_pos`，回到 `CONS_STEP_READ_NEXT_M`。

##### 3c. CONSUMER ONLY（Drain 阶段）— 排空最后一列

Producer 已完成所有列（到达 `LAST_VAR` 后停用），只剩 consumer 处理最后一列的 v2c 更新。经历 ACCUM → V2C 完整流程后，设置 `iter_check_pending = 1`。

##### 3d. ITER_CHECK — 迭代检查

`iter_check_pending` 置位后的下一个时钟周期执行。迭代计数器 `o_iter_count` 递增。

- `i_finish_decode = 1`（残差为零或达到最大迭代次数）：跳转到 **CTRL_DONE**，输出 `o_done = 1`，锁存 `o_success = i_decode_success`。
- `i_finish_decode = 0`：交换 RAM-M pair（`o_m_read_pair` 翻转），复位所有子状态和列指针，重新激活 producer，开始下一轮迭代。

#### 4. CTRL_DONE — 解码完成

输出 `o_done = 1`，锁存 `o_success` 和 `o_iter_count`。等待新一轮 `i_start`，收到后回到 **CTRL_INIT** 开始新的解码。

### ITER 内部流水线时空示意

```
时间 →
       列0              列1              列2        ...    最后一列
PROD  [R][W][R][W]...  [R][W][R][W]...  [R][W]...        (停用)
CONS                   [ACCUM][V2C]     [ACCUM][V2C] ... [ACCUM][V2C]
                       └─ overlap ─┘
        ◀── prime ──▶ ◀─────────── 流水线并行 ───────────▶◀─ drain ─▶
```

- `[R][W]` = PROD_STEP_READ / PROD_STEP_WRITE
- `[ACCUM]` = CONS_MODE_ACCUM（CONS_STEP_READ → CONS_STEP_USE 循环）
- `[V2C]` = CONS_MODE_V2C（PREP → READ_NEXT_M → CNU_A → WRITE 循环）

### 资源与性能特征

- **状态寄存器**：3 位宏状态 + 2 位 INIT 子状态 + 1 位 producer_active + 1 位 producer_step + 1 位 consumer_active + 1 位 consumer_mode + 3 位 consumer_step + 1 位 iter_check_pending，控制状态共约 13 位。
- **关键路径**：控制逻辑为纯组合译码，不产生时序收敛瓶颈。时序关键路径位于 CNU/VNU 数据通路。
- **流水线效率**：稳定重叠阶段中，每个时钟周期同时进行一个 c2v 操作和一个 v2c 操作，实现接近 2 entry/周期的吞吐。

## 验证

常规 RTL 回归使用小型 BIKE 演示参数：

```sh
make test
```

BIKE-L1 黄金模型在 BIKE-L1 规模的双循环矩阵上使用相同的syndrome输入 min-sum 公式：

```sh
make bike-golden-self-test
make bike-golden-once BIKE_SEED=1
make bike-golden-batch BIKE_BASE_SEED=1 BIKE_TRIALS=8
```

本仓库实现的是面向 BIKE 输入的 min-sum 解码器，并非官方的 BIKE bit-flipping 解码器系列。
