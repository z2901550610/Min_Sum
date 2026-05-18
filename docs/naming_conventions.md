# RTL 命名规范

本文档定义本项目 RTL 中常用对象、索引、地址和数据接口的命名规则。目标是让
`group_idx`、`row_idx_group`、`h_block_idx`、`entry_pos`、`one_idx`、`row_idx_global` 等词在所有模块里
保持同一个含义，避免新读代码的人把"分组编号""组内位置""边编号"和"行号"
混在一起。

本项目实现的是 BIKE/MDPC 风格的 min-sum decoder。校验矩阵 H 由若干 circulant
block 组成；每个变量列有 `W` 条边；为了并行处理，校验行被划分成 `L` 个
group。很多模块只处理其中一个 group，因此端口名必须清楚区分：
这个信号是在选择 group，还是在当前 group 内选择一个位置。

## 核心术语

| 名称 | 范围/形状 | 含义 |
| --- | --- | --- |
| `group_idx` | `0..L-1` | 校验行的并行分组编号。只有跨 group 的数组或真正选择 group 的信号才使用这个词。 |
| `h_block_idx` | `0..N0-1` | H 的 circulant block 编号，即 H0/H1/... 的 block 选择。 |
| `col_idx` | `0..N-1` | 全局变量节点编号。 |
| `check_row` | `0..R-1` | 全局校验行编号。 |
| `row_idx_group` | `0..floor((R-1)/L)` | 当前 group 内的紧凑局部行号。当前 RTL 中等于 `floor(row_idx_global / L)`。 |
| `row_idx_global` | `0..R-1` | 绝对校验行号。需要从 `group_idx` 和 `row_idx_group` 重建。 |
| `one_idx` | `0..W-1` | 一个变量列内某个"1"的位置编号（即该列第几条边），用于访问 RAM-S/T/U 的边维度。 |
| `list` | `[0:W-1]` | 一组 packed entries，通常表示当前 group-local metadata 列表。 |
| `entry_pos` | `0..W-1` | `list` 内的游标位置，是相对索引，不是行号。用于遍历列表中各 entry 的步进游标。 |
| `entry` | packed value | 单个 metadata 项。当前 RAM-I entry 格式是 `{one_idx, row_idx_group}`。 |
| `count` | `0..W` | 一个 list 中有效 entry 的数量。只有 `entry_pos < count` 的项有效。 |

### `count` 与写指针的区分

`count` 专指 list 的有效条目数（cardinality）。**不要把递增的写指针命名为 `count`**，
应使用 `ptr`（pointer）后缀。例如：

- `ram_i_count` — 有效条目数（正确）
- `ram_i_read_ptr` — RAM-I entry 读取游标（正确）
- `ram_i_read_count` — 易与 list cardinality 混淆（不推荐）

### `_global` / `_idx_group` 后缀使用规则

只有 `row_idx` 需要在全局行号和组内行号之间显式区分，使用 `row_idx_global`
和 `row_idx_group` 后缀。`one_idx`、`col_idx` 等其他索引天然是全局坐标系，
不需要 `_global` 后缀。

## 层级关系

下面的图展示了常见的 H-block metadata 存储方式。不同模块可以有不同的数组名，
但层级含义应保持一致。

```text
per-group metadata storage

list_entries
  [h_block_idx]              // 0..N0-1，选择 H block
    [entry_pos]              // 0..W-1，选择当前 list 内的位置
      entry = {one_idx, row_idx_group}
               |               |
               |               +-- 当前 group 内的局部行号
               +------------------ 变量列内的边编号，0..W-1

list_count
  [h_block_idx]              // 当前 list 中有效 entry 数，范围 0..W
```

一个 list 示例：

```text
当前逻辑属于 group 0，h_block_idx = 0

entry_pos   list_entries[0][entry_pos]           是否有效
---------   ------------------------------      --------
0           {one_idx=0, row_idx_group=1}  entry_pos < count，有效
1           {one_idx=2, row_idx_group=3}  entry_pos < count，有效
2           {one_idx=0, row_idx_group=0}  entry_pos >= count，无效

list_count[0] = 2
```

当前 RTL 使用奇偶分组。`row_idx_group` 转成绝对行号时，由上层按奇偶规则重建：

```text
group 0: row_idx_global = 2 * row_idx_group
group 1: row_idx_global = 2 * row_idx_group + 1
```

通式（L 分组）：`row_idx_global = L * row_idx_group + group_idx`

如果模块内部已经固定属于一个 group，例如顶层实例化了两个相同 RAM 分别服务
group 0 和 group 1，那么模块端口不应再用 `group_idx` 暗示它在选择
group。端口可以直接叫 `entry_pos`、`list_entries`、`count`，由实例名或上层数组
表达它属于哪个 group。

## 索引命名

| 后缀 | 用法 | 示例 |
| --- | --- | --- |
| `_idx` | 离散编号或数组索引。优先用于逻辑对象编号。 | `col_idx`, `h_block_idx`, `group_idx` |
| `_pos` | 遍历 list 的游标位置，会递增步进。 | `c2v_entry_pos`, `v2c_entry_pos` |
| `_addr` | 真实 RAM 地址端口。只有信号直接接到存储器地址时使用。 | `check_row_addr` |
| `_global` | 全局行号，与 group-local 行号 `row_idx_group` 形成对比。仅在行号中使用。 | `row_idx_global` |
| `_idx_group` | 在当前 group 内的局部索引。 | `row_idx_group` |

推荐写法：

```text
group_idx         // 分组编号，0..L-1
h_block_idx       // H block 选择，0..N0-1
entry_pos         // list 内游标位置，0..W-1
one_idx    // 变量列内 "1" 的位置编号，0..W-1
row_idx_group     // 当前 group 内局部行号
row_idx_global    // 绝对行号
```

避免写法：

```text
row_group          // 不明确：是 group 编号还是 group 内位置？应使用 group_idx
row_group_pos      // 不清楚是 group 编号，还是 group 内位置
column_idx         // 不清楚是全局变量列，还是 H block 内的移位状态
addr               // 没有说明地址空间
pos                // 没有说明相对哪个对象的位置
count              // 用作写指针时，与 list cardinality 混淆
```

## 数据集合命名

| 名称模式 | 含义 |
| --- | --- |
| `entry_*` | 单个 packed entry 的数据或接口。 |
| `list_*` | 一整组 `[0:W-1]` entries。 |
| `count_*` | 一个 list 的有效 entry 数（cardinality）。 |
| `*_ptr` | 递增的写指针，区别于 cardinality 的 count。 |
| `*_valid` | 当前数据或 lane 有效。 |
| `*_last` | 当前游标已经到达本轮/本列最后一个有效位置。 |
| `debug_*` | 仅用于 testbench/观测，不参与功能路径。 |

## Group 编号规则

`group_idx` 只在下面几种情况使用：

1. 信号真的保存 group 编号，例如 `shifted_group_idx`。
2. 数组维度跨越多个 group，例如 `c2v_group_valid[0:L-1]`。
3. 注释或文档需要解释某个实例属于哪个 group。

如果一个模块实例天然只属于一个 group，不要在端口里重复 `group_idx`。例如：

```text
好的方向：
  u_ram_i0.o_count(...)
  u_ram_i1.o_count(...)

不推荐：
  u_ram_i0.o_group_count(...)
  u_ram_i1.o_group_count(...)
```

前者表达的是"这个实例的 selected list count"；实例名或上层数组已经表达了它属于
哪个 group。

## 行号规则

`row_idx_group` 和 `row_idx_global` 必须显式区分。

```text
row_idx_group:
  当前 group 内的紧凑局部行号
  可作为每个 group 私有 RAM 的行地址

row_idx_global:
  绝对校验行号
  用于跨 group 比较、生成 syndrome、或和参考数据对齐
```

不要把局部行号命名成 `row_idx` 或 `row`，除非所在上下文已经非常明确，且不会跨
group 使用。跨边界传递时优先写全：

```text
c2v_row_idx_group
c2v_row_idx_global
```

## RAM-M 乒乓与 epoch 命名

RAM-M 使用双 pair 乒乓结构，相关命名约定：

| 名称 | 含义 |
| --- | --- |
| `ram_m_read_pair_sel` | 当前迭代读取的 RAM-M pair 编号（0 或 1） |
| `ram_m_write_pair_sel` | 当前迭代写入的 RAM-M pair 编号（= ~ram_m_read_pair_sel） |
| `m_pair_epoch` | 每个 pair 的"世代"标记位，写入时翻转，用于区分新旧数据 |
| `m_row_valid` | 某行是否已被当前 pair 写入过有效数据 |
| `m_row_epoch` | 某行的 epoch 值，与 `m_pair_epoch` 比较判断数据是否属于当前迭代 |

## 列交叠缓冲命名

c2v/v2c 列交叠调度中，列元数据在两侧之间传递，相关命名约定：

| 名称模式 | 含义 |
| --- | --- |
| `capture_*_active_cycle` | 在当前调度周期将 c2v 侧列元数据捕获为 v2c 活跃列 |
| `capture_*_next` | 将 c2v 侧当前列元数据缓冲为 v2c "下一列"（消费者尚在处理当前列） |
| `promote_*_next` | 将缓冲的"下一列"元数据提升为 v2c 活跃列 |
| `*_buffer_*` | 快照/缓冲数据，隔离生产者和消费者的读写冲突 |

## H-shift 命名

| 名称 | 含义 |
| --- | --- |
| `shift_ram_i` | 当前周期是否计算 RAM-I 派生行地址 |
| `shift_ram_i_last` | 当前移位是否是当前列最后一个 entry |
| `shifted_valid` | 移位后的 entry 是否有效（源 entry 是否有效） |
| `shifted_group_idx` | 移位后 entry 所属的 group 编号 |
| `shifted_entry` | 移位后的 entry 数据 |

## 端口前缀

本项目沿用 SystemVerilog RTL 常见端口前缀：

| 前缀 | 含义 |
| --- | --- |
| `i_` | 模块输入 |
| `o_` | 模块输出 |
| `io_` | 双向端口，尽量少用 |

端口名应优先表达"对象 + 动作/属性"，而不是只写方向或 RAM 操作。例如：

```text
i_entry_wdata
o_entry_rdata
```

## 声明排版

端口和主要信号声明按方向、`logic`、位宽和名字分列对齐。无位宽信号在位宽列留空，
unpacked 数组维度紧跟名字。

```systemverilog
input  logic                 i_clk,
input  logic [ROW_IDX_W-1:0] i_read_row_idx[0:L-1],
output logic                 o_rdata[0:L-1]
```

带属性的 RAM 声明在属性和 `logic` 之间保留一个空格：

```systemverilog
(* ram_style = "block" *) logic [MSG_W-1:0] mem[0:RAM_LANE_DEPTH-1];
```

`make format-rtl` 使用 Verible 做 SystemVerilog 格式化，并运行项目声明 cleanup，
保持 `input  logic`、属性声明空格和 unpacked 数组维度排版一致。

## 常见模块示例

| 模块/区域 | 推荐命名 | 说明 |
| --- | --- | --- |
| RAM-I metadata | `entry_pos`, `entry_wdata`, `list_entries`, `count` | 一个实例属于一个 group；端口名不重复 group。 |
| RAM-S/T/U edge 维 | `one_idx` | 访问变量列内第几条边；RAM-S 使用 read/write 地址后缀区分读写端，RAM-T 使用 push/pop 流式接口。 |
| RAM-M 行地址 | `check_row_addr` 或 `row_idx_group` | 如果 RAM-M 是 per-group 存储，地址应是组内局部行。 |
| C2V/V2C 跨 group 数组 | `*_group_valid[0:L-1]` | 数组维度确实是 group。 |
| H block 选择 | `h_block_idx` | 统一使用 `h_block`，不使用 `hblk`。 |
| 游标位置 | `entry_pos` | 遍历 list 的步进游标。 |
| 写指针 | `*_ptr` | 递增的写地址指针，区别于 count。 |
| 分组编号 | `group_idx` | group 的选择编号，0..L-1。 |

## 简短检查表

提交或新增模块前，可以快速检查：

- 这个信号是否真的是 group 编号？如果是，使用 `group_idx`。不要使用 `row_group` 表示分组编号。
- 这个索引是 H block、变量节点、边槽位、list 游标位置，还是行号？名字里要体现出来。
- 行号是局部的还是全局的？只有行号需要区分，使用 `row_idx_group` 或 `row_idx_global`。`one_idx` 和 `col_idx` 天然是全局坐标，无需后缀。
- `[0:W-1]` 的数组是完整 list，单个元素是 entry，list 的有效长度是 count。
- 递增的写指针用 `_ptr`，不要与 list 的 count 混淆。
- 跨 group 上下文中，边编号用 `one_idx`，无需 `_global` 后缀。只有行号需要 `_global`/`_idx_group` 区分。
- `debug_*` 信号不应参与功能路径。
- H block 选择统一用 `h_block_idx`，不要用 `hblk_idx` 或 `h_blk_idx`。
