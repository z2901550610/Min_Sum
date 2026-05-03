# RTL 命名规范

本文档定义本项目 RTL 中常用对象、索引、地址和数据接口的命名规则。目标是让
`row_group`、`hblk_idx`、`entry_idx`、`one_idx`、`row_local` 等词在所有模块里
保持同一个含义，避免新读代码的人把“分组编号”“组内位置”“边编号”和“行号”
混在一起。

本项目实现的是 BIKE/MDPC 风格的 min-sum decoder。校验矩阵 H 由若干 circulant
block 组成；每个变量列有 `W` 条边；为了并行处理，校验行被划分成 `L` 个
`row_group`。很多模块只处理其中一个 row group，因此端口名必须清楚区分：
这个信号是在选择 row group，还是在当前 row group 内选择一个位置。

## 核心术语

| 名称 | 范围/形状 | 含义 |
| --- | --- | --- |
| `row_group` | `0..L-1` | 校验行的并行分组编号。只有跨 group 的数组或真正选择 group 的信号才使用这个词。 |
| `hblk_idx` | `0..N0-1` | H 的 circulant block 编号，也就是 H0/H1/... 的 block 选择。 |
| `var_idx` | `0..N-1` | 全局变量节点编号。 |
| `check_row` | `0..R-1` | 全局校验行编号。 |
| `row_local` | `0..floor((R-1)/2)` | 当前 row group 内的紧凑局部行号。当前 RTL 中等于 `floor(row_global / 2)`。 |
| `row_global` | `0..R-1` | 绝对校验行号。需要从 `row_group` 和 `row_local` 重建。 |
| `one_idx` | `0..W-1` | 一个变量列内某个"1"的位置编号（即该列第几条边），用于访问 RAM-S/T/U 的边维度。 |
| `list` | `[0:W-1]` | 一组 packed entries，通常表示当前 group-local metadata 列表。 |
| `entry_idx` | `0..W-1` | `list` 内的位置编号，是相对索引，不是行号。 |
| `entry` | packed value | 单个 metadata 项。当前 RAM-I entry 格式是 `{one_idx, row_local}`。 |
| `count` | `0..W` | 一个 list 中有效 entry 的数量。只有 `entry_idx < count` 的项有效。 |

## 层级关系

下面的图展示了常见的 H-block metadata 存储方式。不同模块可以有不同的数组名，
但层级含义应保持一致。

```text
per-row-group metadata storage

list_entries
  [hblk_idx]                 // 0..N0-1，选择 H block
    [entry_idx]              // 0..W-1，选择当前 list 内的位置
      entry = {one_idx, row_local}
               |          |
               |          +-- 当前 row_group 内的局部行号
               +------------- 变量列内的边编号，0..W-1

list_count
  [hblk_idx]                 // 当前 list 中有效 entry 数，范围 0..W
```

一个 list 示例：

```text
当前逻辑属于 row_group 0，hblk_idx = 0

entry_idx   list_entries[0][entry_idx]          是否有效
---------   ------------------------------      --------
0           {one_idx=0, row_local=1}          entry_idx < count，有效
1           {one_idx=2, row_local=3}          entry_idx < count，有效
2           {one_idx=0, row_local=0}          entry_idx >= count，无效

list_count[0] = 2
```

当前 RTL 使用奇偶分组。`row_local` 转成绝对行号时，由上层按奇偶规则重建：

```text
row_group 0: row_global = 2 * row_local
row_group 1: row_global = 2 * row_local + 1
```

如果模块内部已经固定属于一个 row group，例如顶层实例化了两个相同 RAM 分别服务
`row_group 0` 和 `row_group 1`，那么模块端口不应再用 `row_group` 暗示它在选择
group。端口可以直接叫 `entry_idx`、`list_entries`、`count`，由实例名或上层数组
表达它属于哪个 group。

## 索引命名

| 后缀 | 用法 | 示例 |
| --- | --- | --- |
| `_idx` | 离散编号或数组索引。优先用于逻辑对象编号。 | `one_idx`, `hblk_idx`, `var_idx`, `entry_idx` |
| `_addr` | 真实 RAM 地址端口。只有信号直接接到存储器地址时使用。 | `check_row_addr` |
| `_local` | 在当前分组/局部坐标系内有效。 | `row_local` |
| `_global` | 全局坐标系内有效。 | `row_global` |

推荐写法：

```text
hblk_idx      // H block 选择，0..N0-1
entry_idx     // list 内位置，0..W-1
one_idx     // 变量列内 "1" 的位置编号，0..W-1
row_local     // 当前 row_group 内局部行号
row_global    // 绝对行号
```

避免写法：

```text
row_group_pos       // 不清楚是 row_group 编号，还是 group 内位置
column_idx          // 不清楚是全局变量列，还是 H block 内的移位状态
addr                // 没有说明地址空间
pos                 // 没有说明相对哪个对象的位置
```

## 数据集合命名

| 名称模式 | 含义 |
| --- | --- |
| `entry_*` | 单个 packed entry 的数据或接口。 |
| `list_*` | 一整组 `[0:W-1]` entries。 |
| `count_*` | 一个 list 的有效 entry 数。 |
| `*_load_*` | 一次性装载/覆盖一组相关状态。 |
| `*_valid` | 当前数据或 lane 有效。 |
| `*_last` | 当前游标已经到达本轮/本列最后一个有效位置。 |
| `debug_*` | 仅用于 testbench/观测，不参与功能路径。 |

当一个操作同时写入完整 `list` 和对应 `count` 时，使用同一个前缀：

```text
list_load_en
list_load_hblk_idx
list_load_entries
list_load_count
```

这样可以看出这是一组事务：选中一个 H block，并覆盖它的完整 list 与有效长度。

## Row Group 规则

`row_group` 只在下面几种情况使用：

1. 信号真的保存 row group 编号，例如 `row_group_idx`。
2. 数组维度跨越多个 row group，例如 `c2v_row_group_valid[0:L-1]`。
3. 注释或文档需要解释某个实例属于哪个 row group。

如果一个模块实例天然只属于一个 row group，不要在端口里重复 `row_group`。例如：

```text
好的方向：
  u_ram_i0.o_count(...)
  u_ram_i1.o_count(...)

不推荐：
  u_ram_i0.o_row_group_count(...)
  u_ram_i1.o_row_group_count(...)
```

前者表达的是“这个实例的 selected list count”；实例名或上层数组已经表达了它属于
哪个 row group。

## 行号规则

`row_local` 和 `row_global` 必须显式区分。

```text
row_local:
  当前 row_group 内的紧凑局部行号
  可作为每个 row_group 私有 RAM 的行地址

row_global:
  绝对校验行号
  用于跨 group 比较、生成 syndrome、或和 golden/reference 模型对齐
```

不要把局部行号命名成 `row_idx` 或 `row`，除非所在上下文已经非常明确，且不会跨
group 使用。跨边界传递时优先写全：

```text
c2v_row_group_row_local[row_group_idx]
c2v_row_group_row_global[row_group_idx]
```

## 端口前缀

本项目沿用 SystemVerilog RTL 常见端口前缀：

| 前缀 | 含义 |
| --- | --- |
| `i_` | 模块输入 |
| `o_` | 模块输出 |
| `io_` | 双向端口，尽量少用 |

端口名应优先表达“对象 + 动作/属性”，而不是只写方向或 RAM 操作。例如：

```text
i_entry_wdata
o_entry_rdata
i_list_load_entries
i_list_load_count
```

## 常见模块示例

| 模块/区域 | 推荐命名 | 说明 |
| --- | --- | --- |
| RAM-I metadata | `entry_idx`, `entry_wdata`, `list_entries`, `count` | 一个实例属于一个 row group；端口名不重复 group。 |
| RAM-S/T/U edge 维 | `one_idx` | 访问变量列内第几条边。 |
| RAM-M 行地址 | `check_row_addr` 或 `row_local` | 如果 RAM-M 是 per-group 存储，地址应是局部行。 |
| C2V/V2C 跨 group 数组 | `*_row_group_valid[0:L-1]` | 数组维度确实是 row group。 |
| H block 选择 | `hblk_idx` | 避免混用 `bank`、`block`、`column`。 |

## 简短检查表

提交或新增模块前，可以快速检查：

- 这个信号是否真的在选择 row group？如果不是，不要叫 `row_group_*`。
- 这个索引是 H block、变量节点、边槽位、list 位置，还是行号？名字里要体现出来。
- 行号是局部的还是全局的？使用 `row_local` 或 `row_global`。
- `[0:W-1]` 的数组是完整 list，单个元素是 entry，list 的有效长度是 count。
- 批量覆盖一组 entries 和 count 时，用 `list_load_*` 这类统一前缀。
- `debug_*` 信号不应参与功能路径。
