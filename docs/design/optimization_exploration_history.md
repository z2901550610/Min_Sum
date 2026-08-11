# 译码器架构与资源优化探索记录

> 归档状态：本文档冻结在2026-08-09的阶段81，不再追加新阶段。后续实验使用
> [实验索引](../experiments/index.md)、必要的单项记录和
> [Vivado运行清单](../../reports/vivado/manifests/README.md)。

本文档按实施顺序记录统一 TRIKE K-sign 译码器已经探索的架构与 RTL 方案、验证结果以及取舍结论。
它用于保留设计决策过程；成品架构见[implementation_status.md](implementation_status.md)，物理结果的
当前指针见[vivado_baseline_registry.md](vivado_baseline_registry.md)。

## 结果口径

早期实验跨越过不同 FPGA 器件，器件的 BRAM 原生容量、可用数量和映射结果不同。本文仅将以下条件完全
一致的 placed/routed 结果放入定量对比表：

| 项目 | 条件 |
| --- | --- |
| 参数 | `TRIKE_UNIFIED_PARAMS`，`L=16`，`COLS_PER_TILE=1168`，`K=3` |
| FPGA | `xc7k355tffg901-2L` |
| Vivado | 2023.2 |
| 时钟约束 | 100 MHz，10 ns，clock uncertainty 0.100 ns |
| 报告阶段 | Fully Placed / Routed |

BRAM 以 `Block RAM Tile` 为主要指标，因为一个 RAMB36 占一个 Tile，两个 RAMB18 合计占一个 Tile。
单独观察 RAMB36 或 RAMB18 数量可能误判收益。WNS 一列统一使用整体 WNS；阶段 5 的
`decoder_clk` 内部 WNS 为 `+0.653 ns`，阶段 8 为 `+0.145 ns`。当前RTL对应阶段13的全局K记录
最终判决复用；阶段13是K=3当前完整placed/routed基线，K=4结果记录在探索记录24中。K=4紧凑地址
历史结果单列在探索记录22中。

## 同条件实现结果总表

| 顺序 | 阶段 | LUT | FF | Slice | BRAM Tile | RAMB36 | RAMB18 | WNS | 结论 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 桶形路由和直接 correction 后、地址流水前基准 | 24,711 | 10,023 | 8,497 | 601 | 560 | 82 | -1.165 ns | 未满足 100 MHz |
| 2 | `edge_addr_gen` 固定两级流水 | 23,613 | 10,416 | 8,017 | 601 | 560 | 82 | +0.211 ns | 保留 |
| 3 | 全局 K 记录按逻辑字段初步拆分 | 23,895 | 10,364 | 8,279 | 601 | 560 | 82 | +0.424 ns | BRAM 无收益，继续细化 |
| 4 | 按 `4K × 9` 原生几何显式分段 | 24,110 | 11,129 | 8,519 | 505 | 464 | 82 | +0.629 ns | 历史参考基线 |
| 5 | `base_sign` 与 slot 0 打包 | 24,151 | 11,124 | 8,555 | 489 | 448 | 82 | +0.536 ns | 撤回，优先时序余量 |
| 6 | `ram_t` 地址交织双缓冲 | 24,493 | 11,004 | 8,590 | 489 | 464 | 50 | +0.532 ns | 撤回 |
| 7 | `k_sign_update` valid 状态折叠 | 24,315 | 11,012 | 8,571 | 489 | 448 | 82 | +0.197 ns | 撤回 |
| 8 | correction 线性计数与 K RAM 预译码直达读口 | 23,917 | 11,179 | 8,430 | 489 | 448 | 82 | +0.145 ns | 撤回，时序收益为负 |
| 9 | correction 跨 tile 重叠 | 29,099 | 11,653 | 9,327 | 521.5 | 464 | 115 | +0.309 ns | 历史重叠基线 |
| 10 | 21-bit correction snapshot | 27,070 | 11,491 | 9,193 | 521.5 | 464 | 115 | +0.072 ns | 保留，历史完整基线 |
| 11 | `ram_accum` 单读口buffer | 待测 | 待测 | 待测 | 待测 | 待测 | 待测 | 待测 | RTL待实现报告 |
| 12 | `ram_t` tile-offset bank紧凑地址 | 28,412 | 11,481 | 9,260 | 489.5 | 432 | 115 | +0.769 ns | 保留，历史完整基线 |
| 13 | 全局 `base_sign` 最终判决复用 | 26,637 | 11,083 | 9,133 | 473.5 | 416 | 115 | +0.451 ns | 保留，当前K=3完整基线；主时钟WNS +0.862 ns |
| 14 | `ram_m` 9+9 bit物理字段拆分 | 待测 | 待测 | 待测 | 待测 | 待测 | 待测 | 待测 | RTL保留，功能验证完成，实现待测 |

阶段 1 到阶段 2 的累计变化为 LUT 减少 1,098、Slice 减少 480，WNS 从 `-1.165 ns` 提升至
`+0.211 ns`。阶段 3 只改善时序，没有改变 BRAM 数量。阶段 4 将 BRAM Tile 减少到 505；阶段 5
进一步降至 489，但降低了时序余量。

## 1. K 候选维护结构选择

在拆分 K-sign 存储前，先评估了每拍输入一个候选时的三种 top-K 维护方式：

1. **全排序插入**：新候选与 K 个已保存值比较，生成插入位置并整体移位。它能在单拍后维持有序数组，
   但需要 K 路比较、插入位置译码和多级移位 mux。
2. **最小值门限加相邻交换**：新候选只与当前最小值比较，替换后每个槽每拍只与相邻槽交换一次。单级
   相邻交换不能保证新值在同一拍移动到最终位置；连续每拍接收候选时，排序可能尚未收敛。加入完整冒泡链
   会重新形成长组合路径，加入多个整理周期则增加状态和固定 flush 周期。
3. **无序 K 槽加最差槽归约**：K 个槽不维持全排序。每拍用平衡比较树从现有槽中找出最差项，新候选只
   与该项做一次替换判定；无效槽优先填充，等值使用位置和槽号确定稳定次序。

K=3 时，第三种结构只需要两级最差项归约、一次候选门限比较和单槽写选择，不需要 K 路插入移位网络，
也不需要等待排序收敛。该结构能够持续每拍接收候选，延迟固定，因此作为 `k_sign_update` 的实现。这个
选择发生在稳定的 Kintex-7 检查点建立前，没有单独的 placed/routed 增减数据。

## 2. K-sign 路径独立化

时间：2026-07-09 至 2026-07-10。

最初的工作重点是划清完整 sign 存储与 K-sign 存储的职责：

1. K-sign 构建关闭完整 sign RAM 的实例化，避免两套符号存储同时存在。
2. K-sign 存储拆成 `ram_k_tile` 和 `ram_k_global`。
3. 候选选择和记录更新分别放入 `k_sign_selector`、`k_sign_update`，RAM 模块只承担存储和端口时序。
4. `ram_k_tile` 保存活动 tile 的候选槽，`ram_k_global` 保存跨 tile、跨迭代使用的变量记录。

结果：模块职责和数据生命周期得到明确划分，完整 sign RAM 不进入 K-sign 配置。该阶段使用过与最终基线
不同的器件和存储几何，因此不将当时的绝对 BRAM 数量与后续 Kintex-7 结果直接比较。该结构保留至成品。

## 3. RAM 接口统一与同步读改造

时间：2026-07-10 至 2026-07-11。

这一阶段依次处理了主要状态存储：

- `ram_m` 的 bank 读口合并，翻转读写冲突使用固定旁路处理。
- 提取通用 `ram_bram` 封装，block RAM 通过 XPM 简单双口存储实现。
- `ram_i` 从寄存器阵列改为 BRAM，加载后增加固定周期的合法性检查。
- `ram_decision` 与 `ram_syndrome` 改成同步 BRAM 读。
- `ram_k_tile` 通过参数选择 distributed RAM，使浅深度、较宽工作记录避免占用完整 BRAM 块。

综合日志曾显示浅存储按 block RAM 实现，例如 `ram_k_tile` 的单 bank 只有约 73 深、45 bit 宽；这类几何
会浪费 BRAM 深度。distributed 选项用于 tile 局部工作状态，深存储继续使用 block RAM。

结果：大数组获得稳定的同步 RAM 推断，浅工作 RAM 使用 LUTRAM。同步读延迟被调度器显式吸收，加载、
主循环和校验拍数仍由公开参数固定。该方案保留。

## 4. 全局 K RAM 原地更新

时间：2026-07-10 至 2026-07-11。

全局 K-sign 状态曾使用双缓冲。分析记录的读写生命周期后，架构改为单份全局记录原地更新：C2V 读取
当前记录，V2C 完成候选更新，提交信号与写数据寄存后写回同一地址空间。correction 读取更新完成后的记录。

结果：消除一份全局 K 记录容量，同时通过寄存写回边界避免长组合路径直接进入 RAM 写端口。地址调度和
访问次数不依赖候选数据，固定时延属性保持。该方案保留。

## 5. 条件选择与侧信道审查

对数据通路中的 `if`、比较和写使能做过一次侧信道方向的审查。综合器通常把组合 `if` 实现为比较器和
mux；改写成按位算术选择不会自动减少翻转活动、逻辑级数或功耗泄漏，也不能单独构成侧信道安全证明。

架构层面的结论是：译码轮数、tile 深度、correction 深度和 RAM 访问拍数必须只由公开参数决定；syndrome、
H 第一列内容、K 候选和收敛状态可以影响数据值与写入内容，但不能改变控制流程长度。主路径没有提前终止、
私钥相关 bank 数或数据相关访问次数。

结果：没有对所有 `if` 进行机械算术化改写，避免引入未经综合验证的 LUT 和时序代价。该审查确认的是
固定时延架构属性，不等同于门级功耗平衡或掩码防护；后两项需要独立的泄漏模型、布局约束和测量验证。

## 6. 跨 lane 桶形路由

时间：2026-07-13 11:37。

跨 lane 请求和返回路径使用 `barrel_rotate` 表达循环移位关系，将分散的 lane/bank 选择归并为规则的
旋转网络。该结构进入后续所有 Kintex-7 检查点，但缺少同器件、同约束的独立前置报告，因此不单独计算
LUT 和 WNS 增减量。结果：规则路由结构保留。

## 7. 通用 BRAM 的精确逻辑深度实验

时间：2026-07-13 12:37 前后。

`ram_bram` 的 `MEMORY_SIZE` 使用 `DEPTH × DATA_W` 描述精确逻辑容量，并评估过用推断数组或不同 XPM
参数表达非 2 的幂深度，希望避免未使用地址占据 BRAM。

综合结果没有产生预期的 BRAM 降低。PG058 描述的 RAMB18/RAMB36 仍按器件支持的原生宽深模式组合；
逻辑深度可以是任意值，但物理 primitive 数量会向可用模式取整。此前观察到的一次 BRAM 数量变化伴随
目标器件变化，不能归因于精确深度写法。

结果：通用封装继续传入准确的逻辑 `MEMORY_SIZE`，便于表达容量并让 Vivado 选择合法映射，但不把该参数
视为物理 BRAM 节省手段。需要确定减少 primitive 时，应像全局 K RAM 一样按目标器件原生几何显式拆分或
打包。

## 8. K=3、直接 correction 与地址流水

时间：2026-07-13 13:37 至 14:56。

K 值设为 3，并加入直接 correction：固定扫描 K 个候选槽和 lane/tile 坐标，correction 周期由公开参数
确定。这两项构成表中阶段 1 的结构，当时地址与控制路径的 WNS 为 `-1.165 ns`。

随后 `edge_addr_gen` 使用固定两级流水输出 tile、diag 和 lane 地址，并同步调整固定译码周期。阶段 1 到
阶段 2 的定量变化对应这项地址流水改造。

同条件 Kintex-7 实现从表中阶段 1 变为阶段 2：

- LUT：24,711 → 23,613，减少 1,098。
- Slice：8,497 → 8,017，减少 480。
- WNS：`-1.165 ns` → `+0.211 ns`，100 MHz setup 收敛。
- BRAM Tile：601，保持不变。

结果说明该阶段的关键瓶颈集中在地址计算和控制扇出。固定流水增加 393 个 FF，但改善了 LUT、布局规模和
关键路径，并保持固定周期，因此保留。K=3 和直接 correction 也作为整体架构的一部分保留，但缺少
同器件、同约束的独立前后检查点，不为它们单独计算资源增减量。

## 9. 全局 K 记录的逻辑字段拆分

时间：2026-07-13 15:23。

全局 K 记录先按 `base_sign` 和各个 `dev_pos` 字段拆分，目标是让 Vivado 根据窄字段选择更合适的
BRAM 宽深模式。

阶段 2 到阶段 3 的结果：

- BRAM Tile、RAMB36 和 RAMB18 均没有变化。
- LUT 增加 282，Slice 增加 262。
- WNS 从 `+0.211 ns` 提升至 `+0.424 ns`。

结果：逻辑字段拆开不足以约束物理存储几何。Vivado 仍按完整深度和自身拼接策略构造 RAM，无法自动得到
目标的 BRAM 数量。该版本没有作为终点，随后改为显式原生深度分段。

## 10. 按 BRAM 原生几何显式分段

时间：2026-07-13 15:47。

Kintex-7 RAMB36 的窄数据模式适合 `4K × 9`。全局 K RAM 因此按以下方式映射：

- 每个 lane 的逻辑深度为 20,361，显式切为 5 个 4K 深度段。
- 三个 `dev_pos` 各为 7 bit，每个字段独占一组深度段。
- 读地址同时生成 segment 和段内地址；segment 编号与同步读延迟对齐。
- 写 valid、bank 地址和记录数据经过寄存器后驱动分段 RAM。

阶段 3 到阶段 4 的结果：

- BRAM Tile：601 → 505，减少 96。
- RAMB36：560 → 464，减少 96。
- WNS：`+0.424 ns` → `+0.629 ns`。
- LUT 增加 215，FF 增加 765，用于 segment 译码、数据组合和写回流水。

结果：显式匹配原生宽深模式才能稳定获得容量收益。该方案以少量 LUT/FF 换取 96 个 BRAM Tile，且时序
余量增加，因此保留。

## 11. `base_sign` 与 slot 0 共用字段

时间：2026-07-13 16:07。

`base_sign` 为 1 bit，slot 0 的 `dev_pos` 为 7 bit，两者合计 8 bit，可放入同一个 `4K × 9`
字段。slot 1、slot 2 各保留一个 7-bit 字段。

阶段 4 到阶段 5 的结果：

- BRAM Tile：505 → 489，减少 16。
- RAMB36：464 → 448，减少 16。
- LUT 增加 41，FF 减少 5，Slice 增加 36。
- 整体 WNS 为 `+0.536 ns`，`decoder_clk` 内部 WNS 为 `+0.653 ns`，hold WNS 为 `+0.036 ns`。

最大参数下，全局 K RAM 的物理数量为 `16 lane × 3 fields × 5 segments = 240 RAMB36`。
该方案曾形成 489 BRAM Tile 基线。固定周期相同的条件下，整体 WNS 比阶段 4 低 0.093 ns；按译码性能
优先、存储其次的取舍规则，该打包方案在 2026-07-14 回退。

## 12. `ram_t` 地址交织实验

时间：2026-07-13 16:22。

`ram_t` 的 fill/active 双缓冲曾尝试由两份物理存储改成一份地址空间交织的存储，希望让 Vivado 合并
两个 buffer 的容量。

阶段 5 到阶段 6 的结果：

- RAMB36：448 → 464，增加 16。
- RAMB18：82 → 50，减少 32。
- BRAM Tile：489，保持不变。
- LUT：24,151 → 24,493，增加 342。
- WNS 基本不变：`+0.536 ns` → `+0.532 ns`。

结果：32 个 RAMB18 与 16 个 RAMB36 在 Tile 口径下等价，交织没有节省物理 BRAM Tile，反而增加地址
选择与控制逻辑。该实验撤回，`ram_t` 保持独立 fill/active 存储。

## 13. `k_sign_update` valid 状态折叠实验

时间：2026-07-13 16:39 至 19:57。

候选更新器曾尝试把无效槽处理并入统一比较键，减少显式 valid 分支和比较表达式。功能仿真能够通过，
但 Vivado 对组合比较树和 mux 的映射发生变化。

与阶段 5 基线相比，阶段 7 的结果为：

- LUT：24,151 → 24,315，增加 164。
- Slice：8,555 → 8,571，增加 16。
- WNS：`+0.536 ns` → `+0.197 ns`，减少 0.339 ns。
- BRAM Tile：489，保持不变。

结果：RTL 表达更紧凑不代表综合结果更小。valid、幅值、位置和槽号的组合比较形成了更差的逻辑映射与
布线路径。该实验撤回，更新器使用显式无效槽优先规则和平衡归约比较。

## 14. 阶段 5 基线验证

保留方案组合后的资源和时序对应总表阶段 5：

```text
Slice LUT      24,151
Slice Register 11,124
Slice           8,555
Block RAM Tile    489
RAMB36E1           448
RAMB18E1            82
DSP48E1              1
overall WNS     +0.536 ns
intra-clock WNS +0.653 ns
hold WNS        +0.036 ns
```

TRIKE-512、seed 1 的完整随机译码固定执行 23,425,443 拍，输出 weight 为 877，residual 为 0，
exact 为 1。toy 集成测试固定执行 154 拍并得到 residual 0、exact 1。

## 15. correction 线性计数与 K RAM 预译码直达读口

时间：2026-07-14。placed utilization 报告时间为 11:42:23，routed timing summary 报告时间为
11:44:52。

目标与假设：阶段 5 的内部最差 setup 路径从 `tile_scheduler` 的 tile index 寄存器进入
`k_sign_correction` 列地址计算，并经过 K RAM bank/segment 译码到分段 RAMB36 enable。该路径的数据路径
延迟为 9.249 ns，其中 logic 3.618 ns、route 5.631 ns。实验假设是用线性列计数器消除
`tile_idx * COLS_PER_TILE`，并在 K RAM 前寄存 physical bank、4K 段内地址和 segment one-hot，切断请求侧
的乘加、旋转和分段译码组合路径。

关键实现：

- `k_sign_correction` 按公开的 lane、slot、lane group 和 tile 调度维护线性列计数器；tile 边界使用公开
  `COLS_PER_TILE` padding 回绕。
- correction 请求寄存器保存 valid、bank index/one-hot、段内地址、segment index/one-hot。
- `ram_k_global` 使用 correction 专用直达读口驱动物理 bank 和 segment，C2V/scan 标准读口维持原有接口。
- 请求端增加的寄存边界通过 correction 返回流水重排吸收，固定调度公式和顶层可见周期不增加。
- `ifndef SYNTHESIS` 断言逐拍核对线性列计数器与乘加参考公式。

验证范围：

- Verible 格式、lint 和 `git diff --check` 通过。
- 全部 unit test 与 toy integration 通过；toy 固定 154 拍，residual 0、exact 1。
- TRIKE-128/160/256/384/512、seed 1 完整随机译码全部 residual 0、exact 1；固定周期依次为
  621,270、1,253,181、4,237,694、10,991,791、23,425,443。

Vivado 报告条件：`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`，最大等级
TRIKE-512，`xc7k355tffg901-2L`，Vivado 2023.2，100 MHz/10 ns，clock uncertainty 0.100 ns；资源为
Fully Placed，时序为 Routed。报告由用户提供。

与阶段 5 同条件基线相比：

- Slice LUT：24,151 → 23,917，减少 234。
- Slice Register：11,124 → 11,179，增加 55。
- Slice：8,555 → 8,430，减少 125。
- Block RAM Tile：489，RAMB36：448，RAMB18：82，均不变。
- DSP48E1：1 → 0，乘加 DSP 被消除。
- setup WNS：整体 `+0.536 ns` → `+0.145 ns`；`decoder_clk` 内部 `+0.653 ns` →
  `+0.145 ns`；TNS 保持 0。
- hold WHS：`+0.036 ns` → `+0.042 ns`；THS 保持 0。WPWS 为 `+4.232 ns`。

原 correction 请求到 K RAM enable 路径没有进入新的 setup 前十。新的最差 setup 路径从全局 K RAM 的
RAMB36 同步读出，经过记录槽选择、H base-row 请求和 `ram_i` 扁平读地址生成，到 `ram_i` 的 RAMB18 地址；
数据路径延迟 8.798 ns，logic 2.756 ns，route 6.042 ns，13 级逻辑。第十条路径是
`v2c_tile_offset_c` 到 `ram_k_tile`，扇出 529，数据路径延迟 9.145 ns，其中 route 8.879 ns。

结论：目标请求侧路径被切断，DSP、LUT 和 Slice 有小幅资源收益，100 MHz setup/hold 均收敛；整体与内部
WNS 下降，固定周期下的可达频率余量变差，因此本实验不能视为时序性能提升。该方案在 2026-07-14 撤回。

## 16. 回退到阶段 4 时序性能基线

时间：2026-07-14。

目标与依据：阶段 4、阶段 5 和阶段 8 的固定译码周期相同，整体 WNS 分别为 `+0.629 ns`、`+0.536 ns`
和 `+0.145 ns`。根据固定周期与可达频率优先、存储其次的项目取舍规则，阶段 4 是已有同条件报告中时序
余量最大的版本。

关键实现状态：

- `ram_k_global` 的三个 `dev_pos` 字段分别按 `4K × 9` 原生几何显式分为 5 段。
- `base_sign` 使用独立 1-bit 全深度字段，不与 slot 0 打包。
- correction 使用固定列/槽调度和标准 K RAM bank 路由。
- 线性列计数、K RAM 预译码直达读口和对应接口撤回。

已有同条件报告为 LUT 24,110、FF 11,129、Slice 8,519、BRAM Tile 505、RAMB36 464、RAMB18 82、
整体 WNS `+0.629 ns`、TNS 0、hold WHS `+0.036 ns`。这些数字来自阶段 4 的历史 placed/routed 报告；
回退后重新运行 Vivado 的资源、时序和 top-path 结果为待测。

验证结果：

- `make check-format-rtl` 通过。
- tracked `rtl/*.sv` 与 `tb/*.sv` 的 Verible lint 通过。
- `make test-unit` 全部通过，包括 `tb_k_sign_update` 的 K=3 检查。
- `make test-integration` 通过；toy case 固定 154 拍，residual 0、exact 1。
- TRIKE-512、seed 1 完整随机回归通过；固定 23,425,443 拍，target/output weight 877，residual 0、
  exact 1。
- 完整 `make lint-rtl` 被工作区未跟踪的 `rtl/test.sv` 文件名规则阻断，该文件不属于回退范围。
- 其余 TRIKE 参数等级随机回归和回退后的 Vivado placed/routed 复现结果待测。

状态：RTL 已恢复为阶段 4，功能与维护 RTL lint 通过，完整实现结果待复核。

## 17. K-sign correction 跨 tile 重叠

时间：2026-07-15。

目标与假设：固定 correction 为每个 tile 增加独立串行窗口，且总 correction 周期随
`TILES_TOTAL` 线性增加。K-sign 记录在 tile V2C 完成后已经确定，后续 tile 的 V2C 使用另一份局部工作
状态，因此可让完成 tile 的 correction 与后续主窗口并行。目标是在保持 K=3、high-mag top-K、tie-break
和固定访问深度的条件下，把每轮可见 correction 尾部限制为一个 tile 扫描窗口。

关键实现：

- `ram_k_tile` 使用两个 distributed-RAM 工作 buffer，按 `tile_linear[0]` ping-pong；V2C 维护当前
  buffer，correction 读取上一完成 buffer。
- `k_sign_overlap_scheduler` 在 tile 0 的 V2C 尾拍启动，固定扫描全部 `N0*TILE_COUNT` 个 tile，每个 tile
  执行 `W*Q_TILE` 拍。扫描次数与命中数量、invalid 槽和消息幅值无关。
- check 符号状态拆成 `ram_m.sign_xor_base` 和 `ram_sign_delta.dev_xor`。主 V2C 累积 base parity，
  correction 对每个命中位置翻转 deviation parity，下一轮 C2V 读取后将两者异或。
- `ram_sign_delta` 使用两个 iteration pair，使 C2V 读取和重叠 correction 写入落在不同 pair；连续同地址
  flip 使用固定 RMW 旁路。
- `ram_i` 提供 C2V、V2C 和 correction 三个固定同步读视图。correction 使用独立 `edge_addr_gen`，每拍
  并行处理 L 列。
- 固定周期公式为
  `I_MAX * (ROW_SEG_SIZE + (N0*TILE_COUNT+1)*W*Q_TILE + 8 + W*Q_TILE) + 6`。

功能验证：

- `make test-unit` 通过；新增 `tb_ram_sign_delta` 覆盖单次翻转、同地址连续翻转旁路和跨 pair 并行读写。
- `make test-integration` 通过；toy case 固定 154 拍，residual 0、exact 1。
- TRIKE-128/160/256/384/512、seed 1 完整随机译码全部 residual 0、exact 1；固定周期依次为
  333,990、657,341、2,353,770、7,135,995、16,641,183。
- TRIKE-128 追加 seed 2 至 5，五个 seed 均固定 333,990 拍、residual 0、exact 1。
- TRIKE-512 追加 seed 2，固定 16,641,183 拍、residual 0、exact 1。
- 五档结果验证了 RTL 固定周期公式和该组测试向量的译码一致性。K-sign 选择规则与符号近似定义保持，
  多 seed 低 DFR campaign 待运行，当前结果不作为统计 DFR 结论。

与阶段 4 架构的固定周期比较：

| 参数等级 | 串行 correction 周期 | 重叠 correction 周期 | 减少拍数 | 降幅 |
| --- | ---: | ---: | ---: | ---: |
| TRIKE128 | 621,270 | 333,990 | 287,280 | 46.24% |
| TRIKE160 | 1,253,181 | 657,341 | 595,840 | 47.55% |
| TRIKE256 | 4,237,694 | 2,353,770 | 1,883,924 | 44.46% |
| TRIKE384 | 10,991,791 | 7,135,995 | 3,855,796 | 35.08% |
| TRIKE512 | 23,425,443 | 16,641,183 | 6,784,260 | 28.96% |

Vivado 报告条件：`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`，最大等级
TRIKE-512，`xc7k355tffg901-2L`，Vivado 2023.2，100 MHz/10 ns，clock uncertainty 0.100 ns；资源为
Fully Placed，时序为 Routed。报告时间为 2026-07-15 14:38 至 14:41，结果由用户提供。

与阶段 4 同条件参考基线相比：

- Slice LUT：24,110 → 29,099，增加 4,989（20.69%）；其中 LUT as Logic 增加 3,513，distributed
  RAM LUT 增加 1,472。
- Slice Register：11,129 → 11,653，增加 524（4.71%）。
- Slice：8,519 → 9,327，增加 808（9.48%）。
- Block RAM Tile：505 → 521.5，增加 16.5（3.27%）；RAMB36 保持 464，RAMB18 从 82 增至 115。
- DSP48E1：1 → 0；CARRY4 从 1,416 增至 1,697。
- setup WNS：`+0.629 ns` → `+0.309 ns`，下降 0.320 ns，TNS 保持 0。
- hold WHS 保持 `+0.036 ns`，THS 为 0；WPWS 保持 `+4.232 ns`。

新的最差 setup 路径从 `k_sign_selector` 的 `diag_idx_local_q` 寄存器到 `ram_k_tile` buffer 0、bank 5
的 distributed RAM 数据输入。数据路径延迟 9.223 ns，其中 logic 1.568 ns、route 7.655 ns，17 级逻辑；
前十条 setup 路径均属于同类 tile LUTRAM 写入路径。

结论与状态：五档固定周期降低 28.96% 至 47.55%，100 MHz setup/hold 收敛。代价为 LUT 增加 20.69%、
Slice 增加 9.48% 和 BRAM Tile 增加 3.27%，器件总利用率分别为 13.07%、16.76% 和 72.94%。相对周期收益
明显，资源仍在器件容量内，方案保留为新的 placed/routed 基线。关键路径集中在双 buffer tile LUTRAM 写入
布线，后续优化优先处理该路径。

## 18. 21-bit correction snapshot与delta pair端口审查

时间：2026-07-15。

目标与假设：阶段9的两个tile工作buffer都保存34-bit `base_sign + K*(dev_pos+magnitude)`，但correction
只使用三个 `dev_pos`。将上一完成tile的correction状态压缩为21-bit位置snapshot，可减少LUTRAM容量和
双buffer选择路由，同时保持K=3选择结果、扫描顺序和固定周期。

关键实现：

- `ram_k_tile`包含一份34-bit候选工作RAM和一份21-bit位置snapshot RAM，深度均为 `Q_BASE`，按L个
  variable-column bank组织。
- V2C在最后一个对角线同时把22-bit全局K-sign记录提交到 `ram_k_global`，并把其中三个位置写入
  snapshot。snapshot不保存correction未使用的 `base_sign` 和幅值。
- correction读取上一tile snapshot的同时，当前tile在最后一个对角线覆盖写入相同地址。同步RAM的
  read-first语义保证读出上一tile位置，随后保存当前tile位置。
- 工作RAM在下一tile的第一个对角线通过既有clear输入重建候选记录，因此只需要一份34-bit状态。
- `k_sign_overlap_scheduler`和顶层移除tile buffer选择信号；固定扫描坐标、delta翻转路径和周期公式保持。

逻辑容量变化：

```text
阶段9 tile工作状态 = 2 * 34 * 1168 = 79,424 bit
阶段10工作+snapshot = (34 + 21) * 1168 = 64,240 bit
减少                              = 15,184 bit（19.12%）
```

同时审查了将 `ram_sign_delta` 两个iteration pair合并为每bank一块true-dual-port RAM的方案。重叠阶段每个
bank同拍需要：C2V读取read pair、correction读取write pair的新flip地址、写回上一拍flip地址，即两个独立
读地址和一个独立写地址。单块TDP RAM只有两个地址端口，无法在任意连续flip地址下维持每拍吞吐。使用固定
读写子周期会增加correction周期，复制存储则不节省BRAM。当前两个RAMB18可共置为一个Block RAM Tile/bank，
因此delta pair合并方案撤回，`ram_sign_delta`结构保留。

验证结果：

- `tb_k_sign_update`增加snapshot位置0/1/2的命中读回检查，覆盖有效、无效位置。
- `make test-unit`全部通过。
- `make test-integration`通过；toy case固定154拍，residual 0、exact 1。
- TRIKE-128/160/256/384/512、seed 1完整随机译码全部residual 0、exact 1；固定周期依次为
  333,990、657,341、2,353,770、7,135,995、16,641,183。

Vivado报告条件：`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`，最大等级
TRIKE-512，`xc7k355tffg901-2L`，Vivado 2023.2，100 MHz/10 ns，clock uncertainty 0.100 ns；资源为
Fully Placed，时序为 Routed。资源报告时间为2026-07-15 15:29:25，时序报告时间为15:31:47，结果由
用户提供。

同一实现的hierarchical utilization补充报告时间为2026-07-15 16:53:15，报告阶段为Fully Routed，
层级深度为6。该报告与15:29:25 aggregate utilization的总量完全一致，并确认以下资源归属：

- `k_sign_selector`含 `ram_k_tile`：6,421 Slice LUT，其中4,053 LUT as Logic、2,368 distributed
  RAM LUT，1,350 FF；`ram_k_tile`自身为5,719 LUT、2,368 distributed RAM LUT和864 FF。
- `ram_accum`：5,152 Slice LUT，其中3,104 LUT as Logic和2,048 distributed RAM LUT。
- `ram_k_global`：2,263 LUT、670 FF、256 RAMB36；占全设计RAMB36数量的55.17%。
- `ram_m`：3,412 LUT、1,107 FF、128 RAMB36和32 RAMB18。
- `ram_t`：720 LUT、32 FF、64 RAMB36和32 RAMB18。其每个buffer/lane bank的8436×5存储映射为
  2个RAMB36和1个RAMB18；若通过等价地址映射将有效深度压到8192以内，理论上可减少32个RAMB36，
  RAMB18数量不变。该数字仅为原生宽深模式推导，RTL实施、固定周期验证和Vivado结果均待测。
- `ram_decision`：2,191 LUT、4 FF、16 RAMB36；`ram_sign_delta`为32 RAMB18，`ram_syndrome`为
  16 RAMB18，`ram_i`为3 RAMB18。
- 全部4,416个distributed RAM LUT由 `ram_k_tile` 的2,368个和 `ram_accum` 的2,048个组成。

因此，BRAM优化的实测优先对象依次是 `ram_t` 的深度边界、`ram_decision` 的只读结果副本，以及不增加
端口冲突的窄RAM打包；LUT和时序优化的实测优先对象是 `ram_k_tile` 的snapshot写路径、`ram_accum` 的
双读口分布式RAM及其旋转网络。层级报告也修正了 `ram_t` 深度优化的预估：目标收益为32 Block RAM
Tile，而不是48 Tile。所有收益在取得同条件placed/routed报告前均标记为待测。

与阶段9同条件基线相比：

- Slice LUT：29,099 → 27,070，减少2,029（6.97%）。
- LUT as Logic：23,894 → 22,441，减少1,453（6.08%）。
- LUT as Memory：5,205 → 4,629，减少576（11.07%）；其中distributed RAM LUT从4,992降到4,416，
  减少576（11.54%）。
- Slice Register：11,653 → 11,491，减少162（1.39%）。
- Slice：9,327 → 9,193，减少134（1.44%）。
- Block RAM Tile保持521.5，RAMB36保持464，RAMB18保持115，DSP保持0。
- CARRY4：1,697 → 1,664，减少33（1.94%）。
- setup WNS：`+0.309 ns` → `+0.072 ns`，下降0.237 ns；TNS保持0。
- hold WHS：`+0.036 ns` → `+0.035 ns`，THS保持0；WPWS保持`+4.232 ns`。

新的最差setup路径从 `k_sign_selector` 的 `diag_idx_local_q` 寄存器进入 `ram_k_tile` bank 6的snapshot
distributed RAM写数据端。数据路径延迟9.481 ns，其中logic 1.547 ns、route 7.934 ns，route占83.68%，
包含15级逻辑。阶段9最差路径的数据路径延迟为9.223 ns，其中route 7.655 ns；snapshot减少了逻辑和
LUTRAM资源，但新的物理布局布线使关键路径route增加0.279 ns，100 MHz仍无setup、hold或pulse-width
违例。时序报告没有unconstrained internal endpoint；顶层I/O delay仍需按实际系统接口补充。

结论与状态：21-bit snapshot使tile状态逻辑容量减少19.12%，placed Slice LUT减少6.97%，Slice减少
1.44%，固定周期和译码结果保持。BRAM Tile没有变化，setup余量减少0.237 ns但仍满足100 MHz。该方案以
明确的逻辑资源收益保留为当前完整基线；delta pair TDP合并方案撤回。后续若继续优化，应针对snapshot
写入的高布线占比做寄存器复制、bank局部化或写数据流水实验，并分别检查固定周期和routed WNS。

## 19. `ram_accum` 单读口buffer实验

时间：2026-07-15。

目标与假设：阶段10层级报告显示 `ram_accum` 使用5,152个Slice LUT，其中2,048个为distributed RAM
LUT。每个物理buffer的数组在RTL中分别出现C2V和V2C两个异步读表达式，可能导致Vivado复制存储阵列。
`tile_scheduler`由同一个公开窗口编号生成互补的 `fill_buf` 和 `active_buf`，两条路径到 `ram_accum` 的
buffer选择经过等长流水，因此一个物理buffer同拍只需要一个读地址。

关键实现：

- 每个buffer/bank只保留一次 `mem[bank_raddr]` 引用，C2V和V2C请求先按buffer选择合并为一个读使能和
  一个读地址，再把读数据返回对应通路。
- C2V同地址读写继续使用写数据旁路，保持累加读改写语义。
- 仿真断言检查同一个buffer/bank不会同时收到C2V和V2C读请求；冲突不通过重试或数据相关调度处理。
- `tb_ram_accum`同时读取两个互补buffer，并检查两个方向的C2V/V2C返回值。
- 主调度、buffer数量、访问拍数、迭代次数和固定周期表达式均保持不变。

验证结果：

- `make format-rtl`、`make check-format-rtl`和 `make lint-rtl`通过。
- `make test-unit`全部通过，`tb_ram_accum`覆盖两个buffer的同时读取。
- `make test-integration`通过；toy case固定154拍，residual 0、exact 1。
- TRIKE-128/160/256/384/512、seed 1完整随机译码全部residual 0、exact 1；固定周期依次为
  333,990、657,341、2,353,770、7,135,995、16,641,183。

Vivado待测条件：`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`，最大等级
TRIKE-512，`xc7k355tffg901-2L`，Vivado 2023.2，100 MHz/10 ns，clock uncertainty 0.100 ns。需要记录
aggregate和hierarchical utilization、`ram_accum`层级的LUT/LUTRAM、Slice、RAMB36/RAMB18，以及Routed
setup/hold和top paths。不能根据RTL中的单次数组引用推测最终资源收益。

状态：RTL和功能验证保留为待测候选；资源、时序和最终保留/撤回结论等待同条件Vivado实现报告。

## 20. K=4与 `ram_accum` 单读口组合实现

时间：2026-07-17。

目标与配置：测量K=4的资源和时序，同时包含阶段19的 `ram_accum` 单读口结构。参数为
`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=4`、`COLS_PER_TILE=1168`，最大等级TRIKE-512，器件
`xc7k355tffg901-2L`，Vivado 2023.2，目标时钟100 MHz/10 ns。资源报告为Fully Placed，时间
2026-07-17 10:06:47；时序报告为Routed，时间10:09:15，结果由用户提供。附件没有单列clock
uncertainty和implementation strategy；WNS增减只在确认这些设置与K=3基线一致时作直接比较。

资源结果：

- Slice LUT 29,315，其中LUT as Logic 24,943、LUT as Memory 4,372。
- Distributed RAM LUT 4,160，SRL LUT 212，Slice Register 11,917，Slice 9,927。
- Block RAM Tile 601.5，其中RAMB36 544、RAMB18 115；DSP 0，CARRY4 1,713。
- K=4全局记录为29 bit，物理全局K RAM为336 RAMB36；相对K=3的256 RAMB36增加80，符合
  `16 banks × 5 segments × 1 slot` 的原生几何推导。

与阶段10的K=3完整基线相比，该结果同时包含K从3增至4和 `ram_accum` 单读口两个变化：

- Slice LUT增加2,245（8.29%），LUT as Logic增加2,502（11.15%）。
- LUT as Memory减少257（5.55%），Distributed RAM LUT减少256（5.80%）。
- FF增加426（3.71%），Slice增加734（7.98%），CARRY4增加49（2.94%）。
- RAMB36增加80，RAMB18不变，Block RAM Tile增加80至601.5，利用率84.13%。

阶段10层级报告确认全部4,416个distributed RAM LUT由 `ram_k_tile` 的2,368个和 `ram_accum` 的
2,048个组成。K=4多一个11-bit工作槽和7-bit snapshot槽，aggregate总量可按当前映射反推为：

```text
ram_k_tile(K=4)  = 3,136 distributed RAM LUT
ram_accum        = 1,024 distributed RAM LUT
total            = 4,160 distributed RAM LUT
```

因此总量与 `ram_accum` LUTRAM减半、K=4 tile LUTRAM增加768的预期完全闭合。该归属尚缺K=4
hierarchical utilization直接确认，不能把反推值当作层级报告原始数据。

时序结果：setup WNS/TNS为 `+0.818 ns / 0.000 ns`，hold WHS/THS为
`+0.037 ns / 0.000 ns`，WPWS/TPWS为 `+4.232 ns / 0.000 ns`，100 MHz全部满足。最差setup路径从
`ram_k_tile` bank 7的snapshot输出寄存器到 `ram_sign_delta` pair 1、bank 8的旁路valid寄存器，数据路径
8.859 ns，其中logic 1.196 ns、route 7.663 ns，route占86.50%，包含11级逻辑。内部endpoint全部受约束；
69个输入和7个输出没有I/O delay，另有1个输入由false path覆盖。

功能验证：使用 `BIKE_K_SIGN_K=4` 的 `make test-unit`全部通过，`tb_k_sign_update`报告K=4。统一TRIKE
K=4完整随机译码和固定周期回归待运行，Vivado实现通过不能替代该验证。

状态：K=4组合实现的placed资源和routed时序结果保留为独立可选配置基线；`ram_accum`单读口的资源归因
得到aggregate总量支持，等待K=4 hierarchical utilization或K=3同条件实现直接确认。

## 21. `ram_t` tile-offset bank紧凑地址实验

时间：2026-07-17。

目标与假设：阶段10层级报告显示 `ram_t` 使用64个RAMB36和32个RAMB18。最大配置下每个
buffer/lane bank的逻辑深度为 `W × Q_TILE = 111 × 76 = 8436`、宽度5 bit，跨过8192深度边界。
若把guard拍从存储地址中消除并把有效边压到 `W × Q_BASE = 8103`，按Kintex-7原生宽深模式推导，每个
bank可由2个RAMB36和1个RAMB18缩减为1个RAMB36和1个RAMB18。

地址有效性分析：不能直接把原始 `lane_group_idx` 的stride从 `Q_TILE`改成 `Q_BASE`。当
`edge_addr_gen`在模 `R` 回绕处拆成pre/post两拍时，两拍可能在同一check-row bank中各含不同有效边；而且
`R mod L != 0`使单个check-row bank在一个完整tile中最多收到 `Q_BASE+1` 条边。TRIKE-512、`L=16`时，
实际范围为每bank 72至74条，不能装入73地址而保持原bank映射。

关键实现：

- 物理bank由 `tile_offset mod L`确定，bank内地址为
  `diag_idx_local × Q_BASE + floor(tile_offset/L)`；每个对角线的地址数严格不超过 `Q_BASE`。
- C2V写请求和V2C读请求分别使用组合桶形旋转从check-row lane路由到tile-offset bank；同步BRAM读回使用
  延迟一拍的shift旋转回原lane。
- fill/active双buffer、BRAM同步读延迟、主调度、guard拍、迭代次数和固定周期表达式保持不变。
- 仿真断言检查所有valid tile offset的bank内地址小于 `Q_BASE`；`tb_ram_t`覆盖非零旋转、最大diag、
  最大group、地址隔离和两个buffer。

验证结果：

- `make format-rtl`、`make check-format-rtl`和 `make lint-rtl`通过。
- `make test-unit`和 `make test-integration`通过；toy case固定154拍，residual 0、exact 1。
- 统一TRIKE-128/160/256/384/512、`L=16`、`COLS_PER_TILE=1168`、K=3、seed 1完整随机译码全部
  residual 0、exact 1；固定周期依次为333,990、657,341、2,353,770、7,135,995、16,641,183。
- 相同五档、seed 1的K=4完整随机译码也全部residual 0、exact 1，固定周期与K=3一致。回归入口和
  Vivado脚本增加显式 `TRIKE_UNIFIED_KSIGN_K`/`BIKE_K_SIGN_K`参数，避免K=4验证与实现配置脱节。

Vivado结果：配置为 `TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`，最大等级
TRIKE-512，器件 `xc7k355tffg901-2L`，Vivado 2023.2，100 MHz/10 ns，user clock uncertainty
0.100 ns。资源报告为Fully Placed，时间2026-07-17 10:51:56；时序报告为Routed，时间10:54:27，结果
由用户提供。aggregate资源为：

- Slice LUT 28,412，其中LUT as Logic 24,811、LUT as Memory 3,601。
- Distributed RAM LUT 3,392，SRL LUT 209，Slice Register 11,481，Slice 9,260。
- Block RAM Tile 489.5，其中RAMB36 432、RAMB18 115；DSP 0，CARRY4 1,786。

相对阶段10的同条件K=3完整基线，该结果同时包含阶段19的 `ram_accum` 单读口和本阶段的 `ram_t` 紧凑
地址两个变化：Slice LUT增加1,342（4.96%），LUT as Logic增加2,370（10.56%）；LUT as Memory减少
1,028（22.21%），Distributed RAM LUT减少1,024（23.19%）；FF减少10（0.09%），Slice增加67
（0.73%），CARRY4增加122（7.33%）。Block RAM Tile和RAMB36均精确减少32，RAMB18保持115，与
`ram_t` 的原生宽深目标完全一致。由于没有阶段19单独的K=3实现报告和本次hierarchical utilization，
`ram_t` 的直接BRAM归属仍是基于整体差值的推断，也不能把新增logic LUT在 `ram_accum` 与 `ram_t` 之间
直接拆分归因。

时序结果：setup WNS/TNS为 `+0.769 ns / 0.000 ns`，hold WHS/THS为
`+0.034 ns / 0.000 ns`，WPWS/TPWS为 `+4.232 ns / 0.000 ns`。最差setup路径仍为K-sign snapshot写入，
数据路径8.836 ns，其中logic 1.280 ns、route 7.556 ns，包含15级逻辑。前十条setup路径中有一条
`ram_t` BRAM读出经返回旋转和VNU运算到 `v2c_scaled_q` 的路径，slack为 `+0.878 ns`，数据路径
8.779 ns，其中logic 2.999 ns、route 5.780 ns，包含11级逻辑。内部endpoint全部受约束；顶层仍有
69个输入和7个输出未设置I/O delay，另有1个输入由false path覆盖。

状态：K=3方案保留为当前完整placed/routed基线。它以1,342个总LUT和67个Slice的增加换取32个Block
RAM Tile，并把整体WNS从阶段10的 `+0.072 ns`提高到 `+0.769 ns`；固定周期和译码结果保持。K=4紧凑
地址版本的资源和时序待运行，不能直接套用K=3的LUT或WNS结果。

## 22. K=4的 `ram_t` 紧凑地址实现结果

时间：2026-07-17。资源报告时间为11:27:42，时序报告时间为11:30:33。

目标与配置：确认阶段21的紧凑地址映射在K=4配置下能否兑现32个RAMB36的预期节省，并检查增加的
K-sign记录宽度和旋转网络对100 MHz时序的影响。配置为 `TRIKE_UNIFIED_PARAMS`、`L=16`、`K=4`、
`COLS_PER_TILE=1168`，最大等级TRIKE-512，器件 `xc7k355tffg901-2L`，Vivado 2023.2，目标时钟
100 MHz/10 ns，user clock uncertainty 0.100 ns。资源为Fully Placed，时序为Routed，结果由用户提供。

aggregate资源结果：

- Slice LUT 30,696，其中LUT as Logic 26,327、LUT as Memory 4,369。
- Distributed RAM LUT 4,160，SRL LUT 209，Slice Register 11,906，Slice 10,408。
- Block RAM Tile 569.5，其中RAMB36 512、RAMB18 115；DSP 0，CARRY4 1,803。

与阶段20的相同K=4配置相比，阶段20已经包含 `ram_accum` 单读口，因此两份报告之间的主要架构变化是
阶段21的 `ram_t` 紧凑地址映射：

- Block RAM Tile：601.5 → 569.5，减少32（5.32%）；RAMB36：544 → 512，减少32（5.88%）；
  RAMB18保持115。该结果与每个buffer/lane bank减少1个RAMB36的原生几何推导完全一致。
- Slice LUT：29,315 → 30,696，增加1,381（4.71%）；其中LUT as Logic增加1,384（5.55%），
  LUT as Memory减少3。Slice：9,927 → 10,408，增加481（4.85%）。
- Slice Register减少11，SRL LUT减少3，Distributed RAM LUT保持4,160；CARRY4增加90。

时序结果：setup WNS/TNS为 `+0.565 ns / 0.000 ns`，hold WHS/THS为
`+0.033 ns / 0.000 ns`，WPWS/TPWS为 `+4.232 ns / 0.000 ns`，全部满足100 MHz。相对阶段20，setup
WNS从 `+0.818 ns`减少0.253 ns，hold WHS从 `+0.037 ns`减少0.004 ns。

最差setup路径从 `ram_k_global` bank 14、slot 1、segment 2的RAMB36同步读口到
`c2v_ksign_sign_q[7]`，数据路径9.297 ns，其中logic 2.144 ns、route 7.153 ns，route占76.94%，包含
8级逻辑。第二条及其后的多条路径从 `k_sign_selector` 的 `diag_idx_local_q` 到 `ram_k_tile` snapshot
distributed RAM写输入，第二条slack为 `+0.658 ns`，数据路径9.062 ns，其中route占87.11%。前十条
setup路径中没有 `ram_t` 路径。内部endpoint全部受约束；69个输入和7个输出未设置I/O delay，另有1个
输入由false path覆盖；methodology仍报告76项TIMING-18。

阶段21已经完成相同RTL的K=4五档、seed 1完整随机译码和固定周期验证；本次只新增Vivado实现报告，
没有以实现通过替代功能验证。aggregate报告没有hierarchical utilization，因此新增logic LUT不能直接
全部归因于 `ram_t` 旋转网络，仍需层级报告确认。

状态：K=4紧凑地址方案保留为当前可选配置的完整placed/routed基线。相同K=4条件下，它用1,381个LUT、
481个Slice和0.253 ns setup余量换取32个Block RAM Tile，使BRAM Tile利用率从84.13%降至79.65%；
固定周期和译码结果保持，100 MHz setup/hold/pulse width全部通过。

## 23. K=4后续整机资源优化审查

时间：2026-07-17。

目标：从状态生命周期、端口并发和目标器件原生RAM几何出发，寻找能够降低Block RAM Tile并控制
LUT/FF代价的后续方案。本节只记录RTL静态分析、历史层级报告依据和待验证目标；没有对应RTL、功能回归
或Vivado实现结果，所有资源数字均不得当作实测收益。

分析基线为阶段22的K=4结果：Slice LUT 30,696、FF 11,906、Block RAM Tile 569.5、RAMB36 512、
RAMB18 115、setup WNS `+0.565 ns`。资源归属参考阶段10同器件、同几何的hierarchical utilization；
其中 `ram_decision` 为2,191 LUT、4 FF、16 RAMB36，`ram_m` 为3,412 LUT、1,107 FF、128 RAMB36和
32 RAMB18，`ram_syndrome` 为29 LUT、16 FF和16 RAMB18。模块绝对资源可能随整机布局变化，只有物理
RAM原生几何可以作为确定的实施目标。

### 23.1 复用全局K记录的base sign作为最终判决

最终一轮中，VNU的posterior sign已经作为 `base_sign` 写入每个变量的全局K记录；`ram_decision`又保存
同一变量符号，形成重复状态。测试接口只在 `o_done` 后逐列同步读取错误向量，此时内部C2V全局K读口空闲，
可以把外部列地址复用到该读口并直接返回记录的base-sign位。

结构目标：

- K-sign配置删除 `ram_decision` 的16个RAMB36及16×16 lane-to-bank写入选择网络。
- 删除只服务判决RAM的 `decision_we_s/c/p` 48个流水FF、`posterior_sign_p` 16个流水FF以及
  `ram_decision` 的4个读bank选择FF；保留K候选提交需要的 `posterior_sign_c`。
- 外部读地址只在译码流水完全排空后进入全局K读口；主译码访问次数、固定周期和K-sign记录内容不变。

待验证资源目标为减少16个RAMB36/Block RAM Tile。根据历史层级结果和需要增加的外部读请求mux，净LUT
预计减少约1,900至2,200，净FF预计减少约60至70；目标区间约为28.5k至28.8k LUT、11.83k至
11.85k FF。该估算需要K=3/K=4 placed结果确认。功能验证必须逐列比较 `ram_decision` 历史输出与最终
全局base sign，并保持一拍同步读接口。

### 23.2 `ram_m` 的9+9 bit物理字段拆分

最大配置下 `COMP_C2V_W=18`，可拆为两个9-bit字段，例如
`{min1[3:0], min2[3:0], sign_xor}` 和9-bit `min_diag_global`。每个字段深度6,787，按Kintex-7
`4K × 9`几何需要两个RAMB36；32个pair/bank合计仍为128个RAMB36。历史完整18-bit XPM映射另外使用
32个RAMB18，因此字段拆分的物理目标是删除32个RAMB18，即减少16个Block RAM Tile。

地址、读写使能、旁路数据和顶层接口保持共享，字段拼接为连线，不引入新的算法状态或固定周期。RTL结构
没有必需的新流水FF；预计FF基本不变，LUT变化应控制在约 `-50` 至 `+100`，但XPM拆分后的控制吸收和
布局结果必须实测。该方案主要是确定的RAM优化，不单独承诺LUT收益。

### 23.3 syndrome与deviation parity共存储

K-sign C2V对每个check row同时读取syndrome和当前read pair的deviation parity；两个地址相同。
可把每个 `ram_sign_delta` pair的word扩为 `{syndrome, dev_xor}` 两位。外部加载时把syndrome写入两个pair；
迭代clear阶段从read pair读取syndrome并流水复制到write pair，同时把目标 `dev_xor` 清零。主窗口仍由
read pair执行C2V读取、write pair执行correction RMW，两个pair不能合成一块存储。

2 bit × 6,787仍应映射为每pair/bank一个RAMB18，因此总量保持32个RAMB18并删除独立
`ram_syndrome` 的16个RAMB18，目标减少8个Block RAM Tile。顶层可删除48个
`c2v_syndrome_q/s/c`流水FF和 `ram_syndrome` 的16个read-valid FF；clear复制需要增加公共valid、地址和
pair流水。净FF预计减少约40至55，LUT预计小幅下降或基本不变。必须证明最后一个clear复制写可被既有
C2V prime流水吸收，否则不能以增加固定周期为代价强行保留。

### 23.4 `COLS_PER_TILE=576`的RAM/LUT联合几何

当前 `COLS_PER_TILE=1168`、`Q_BASE=73`，K=4的全部4,160个distributed RAM LUT来自
`ram_k_tile`约3,136个和 `ram_accum`约1,024个。将tile宽度设为576后：

```text
Q_BASE       : 73 -> 36
Q_TILE       : 76 -> 39
TILES_TOTAL  : 279 -> 567
ram_t depth  : 111*73=8103 -> 111*36=3996
```

深度36落在64-deep LUTRAM的单段范围，预计 `ram_k_tile` 和 `ram_accum` 的distributed RAM LUT接近
减半；`ram_t` 的3996×5 bank可落入一个 `4K × 9` RAMB36，预计删除当前32个RAMB18，即减少16个
Block RAM Tile。tile-offset、work地址和旋转payload各缩短1 bit，部分地址流水FF和旋转LUT也会减少；
tile计数器宽度增加1 bit。整机净目标暂估减少约1,800至2,600 LUT、120至180 FF，必须以同条件K=4
placed/hierarchical报告确认。

TRIKE-512固定周期的精确变化为：

```text
COLS_PER_TILE=1168 : 16,641,183 cycles, 166.41183 ms @ 100 MHz
COLS_PER_TILE=576  : 17,289,978 cycles, 172.89978 ms @ 100 MHz
increase           : 648,795 cycles, 3.899%
```

tile划分只由公开参数决定，算法扫描集合和轮数不变，因此仍为常数时间；是否保持DFR和bit-exact输出需要
五档K=3/K=4随机回归确认。该方案是在RAM/LUT与固定时延之间的显式折中，不应与零周期代价方案混为一项。

### 23.5 组合目标与实施顺序

按 `base_sign` 判决复用、`ram_m` 9+9拆分、syndrome共存储、576列tile几何依次叠加，物理RAM目标为：

| 状态 | RAMB36 | RAMB18 | Block RAM Tile | LUT/FF口径 |
| --- | ---: | ---: | ---: | --- |
| 阶段22 K=4实测基线 | 512 | 115 | 569.5 | 30,696 / 11,906，实测 |
| 判决复用后目标 | 496 | 115 | 553.5 | 约28.5k–28.8k / 11.83k–11.85k，待测 |
| 加 `ram_m` 9+9目标 | 496 | 83 | 537.5 | LUT约±100、FF基本不变，待测 |
| 加syndrome共存储目标 | 496 | 67 | 529.5 | FF再降约40–55，LUT小幅变化，待测 |
| 加576列tile目标 | 496 | 35 | 513.5 | 合计约26.0k–27.0k / 11.6k–11.7k，待测 |

组合目标相对阶段22减少56个Block RAM Tile，目标利用率约71.82%，同时预计减少约3.7k至4.7k LUT和
约0.2k至0.3k FF。应逐项保留独立Vivado检查点，不能一次合并后丢失资源归因。优先实施判决复用，因为
它是当前唯一具有历史层级数据支持、零固定周期代价且预期同时显著降低RAM和LUT的方案；随后实施
`ram_m`字段拆分。syndrome共存储和tile几何分别需要clear端口证明和固定时延取舍后再推进。

曾实测的base-sign与slot 0打包可再减少16个RAMB36，但历史结果为LUT增加41、Slice增加36且WNS下降
0.093 ns；阶段22的K=4最差路径已经位于全局K读出和符号重建，因此该方案只作为最后的独立存储实验，
不列入优先组合目标。

## 24. 复用全局K记录的 `base_sign` 作为最终判决

时间：2026-07-17。

目标与假设：删除K-sign配置中与最终全局 `base_sign` 重复的 `ram_decision`。最后一轮V2C已经把每个
变量节点的posterior sign提交为全局K记录的 `base_sign`；`o_done` 后主C2V流水停止，全局K记录读口可用于
外部错误向量串行读取。该变化只调整结果的保存和读出位置，不改变候选选择、sign reconstruction、
correction、迭代次数或主译码访存次数。

关键实现：

- `decoder_top` 在K-sign配置下不实例化 `ram_decision`；full-sign配置继续使用原有判决RAM。
- `ctrl_done_final` 有效后，`i_e_read_col_idx` 从K-sign lane 0请求通道进入既有bank/segment读路由，
  `c2v_ksign_record_mem[0][0]` 的base-sign位作为 `o_e_rdata`。
- 译码进行期间请求仍来自固定C2V调度；外部请求只在完成状态接管空闲读口，因此固定窗口和周期公式不变。
- 保持同步串行读接口；没有增加译码状态、窗口或周期。

功能验证：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`通过。
- `make test-unit`通过全部14个单元测试；`make test-integration`通过，toy case residual 0、exact 1、
  154周期。
- K=3与K=4分别运行统一TRIKE五档seed 1完整随机译码。两种K值在五档均为residual 0、exact 1，
  output weight等于目标weight；固定周期均为333,990、657,341、2,353,770、7,135,995和
  16,641,183。
- 该回归证明已测向量的最终全局base sign与原判决输出逐列一致。译码内部状态和访问调度保持相同，因此
  本变化没有引入新的DFR算法近似；统计DFR结论仍由独立campaign覆盖。

K=3 Vivado结果：配置为 `TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`，最大等级
TRIKE-512，器件 `xc7k355tffg901-2L`，Vivado 2023.2，100 MHz/10 ns，user clock uncertainty
0.100 ns。资源报告为Fully Placed，时间2026-07-17 14:44:33；时序报告为Routed，时间14:46:43，结果
由用户提供。aggregate资源为：

- Slice LUT 26,637，其中LUT as Logic 23,085、LUT as Memory 3,552。
- Distributed RAM LUT 3,392，SRL LUT 160，Slice Register 11,083，Slice 9,133。
- Block RAM Tile 473.5，其中RAMB36 416、RAMB18 115；DSP 0，CARRY4 1,787。

相对阶段21的相同K=3配置，Block RAM Tile从489.5降至473.5，减少16（3.27%）；RAMB36从432降至
416，减少16（3.70%）；RAMB18保持115，精确达到删除16-bank判决存储的物理目标。Slice LUT从28,412
降至26,637，减少1,775（6.25%），其中LUT as Logic减少1,726（6.96%）、LUT as Memory减少49；FF从
11,481降至11,083，减少398（3.47%）；Slice从9,260降至9,133，减少127（1.37%）；CARRY4增加1。
FF降幅大于阶段23的结构估算，说明常量生成分支还使判决写入流水及其相关控制获得了进一步综合裁剪；没有
hierarchical utilization时不把全部398个FF都强行归因到单一RTL信号组。

Routed timing满足全部已定义约束。整体setup WNS/TNS为 `+0.451 ns / 0.000 ns`，最差路径属于
`**async_default**` 异步复位释放组；主 `decoder_clk` 组setup WNS/TNS为
`+0.862 ns / 0.000 ns`，相对阶段21报告的主同步WNS `+0.769 ns`改善0.093 ns。hold WHS/THS为
`+0.026 ns / 0.000 ns`，WPWS/TPWS为 `+4.232 ns / 0.000 ns`。最差主时钟路径从 `ram_t` bank 11的
RAMB36读口到 `u_vnu/v2c_scaled_q_reg[9][15]`，数据路径8.626 ns，其中logic 3.050 ns、route
5.576 ns，共11级逻辑。最差异步路径从 `u_reset_sync/rst_sync_n_reg` 到 `ram_k_global` segment读选择
寄存器的CLR端，数据路径9.164 ns，其中route占95.995%。

时序边界说明：内部endpoint全部受约束，但69个普通输入和7个输出没有I/O delay，另有1个输入由false
path覆盖。新的最终判决路径从全局base-sign RAM到 `o_e_rdata` 的数据延迟为11.902 ns，属于未约束输出，
因此不能用内部WNS证明器件引脚上的一拍100 MHz读接口已经收敛。后续需要根据真实板级接口补充output
delay并重新签核，或增加输出寄存器并明确额外读延迟；这不改变已经验证的固定译码周期。

K=4 Vivado结果：配置保持相同，仅K值为4。资源报告为Fully Placed，时间2026-07-17 14:57:42；时序
报告为Routed，时间15:00:45，结果由用户提供。aggregate资源为：

- Slice LUT 29,013，其中LUT as Logic 24,692、LUT as Memory 4,321。
- Distributed RAM LUT 4,160，SRL LUT 161，Slice Register 11,494，Slice 10,070。
- Block RAM Tile 553.5，其中RAMB36 496、RAMB18 115；DSP 0，CARRY4 1,803。

相对阶段22的相同K=4配置，Block RAM Tile从569.5降至553.5，减少16（2.81%）；RAMB36从512降至
496，减少16（3.12%）；RAMB18保持115，精确达到物理目标。Slice LUT从30,696降至29,013，减少
1,683（5.48%），其中LUT as Logic减少1,635（6.21%）、LUT as Memory减少48；FF从11,906降至
11,494，减少412（3.46%）；Slice从10,408降至10,070，减少338（3.25%）；CARRY4保持1,803。

K=4 Routed timing满足全部已定义约束。整体setup WNS/TNS为 `+0.535 ns / 0.000 ns`，最差路径属于
`**async_default**` 异步复位释放组；主 `decoder_clk` 组setup WNS/TNS为
`+0.717 ns / 0.000 ns`，相对阶段22的主同步WNS `+0.565 ns`改善0.152 ns。hold WHS/THS为
`+0.022 ns / 0.000 ns`，WPWS/TPWS为 `+4.232 ns / 0.000 ns`。最差主时钟路径从 `ram_k_tile`
snapshot读寄存器到 `ram_sign_delta` pair 1、bank 2的旁路valid寄存器，数据路径9.054 ns，其中logic
1.241 ns、route 7.813 ns，共12级逻辑。最差异步路径从 `u_reset_sync/rst_sync_n_reg` 到
`c2v_comp_c_reg[13][12]` 的CLR端，数据路径9.197 ns，其中route占96.325%。

K=4同样有69个普通输入和7个输出没有I/O delay，另有1个输入由false path覆盖。全局base-sign RAM到
`o_e_rdata` 的未约束外部输出路径为12.209 ns，进一步确认最终判决接口需要真实output delay约束或输出
寄存器才能完成板级一拍100 MHz签核。

状态：K=3和K=4 RTL及实现结果均保留；两种配置都精确减少16个Block RAM Tile，同时降低LUT、FF和
Slice，并满足内部100 MHz。hierarchical utilization和外部判决接口时序闭合待补充。阶段21、阶段22和
本阶段结果使用独立报告，不覆盖旧检查点。

## 25. `ram_m` 9+9 bit物理字段拆分

时间：2026-07-17。

目标与假设：最大统一配置的 `COMP_C2V_W=18`，原生物理字段可组织为9-bit
`{sign_xor,min2,min1}` 和9-bit `min_diag_global`。在 `ROW_SEG_SIZE=6787` 下，每个9-bit字段使用两个
`4K × 9` RAMB36；32个pair/bank合计物理目标为128个RAMB36和0个RAMB18。该映射保持逻辑记录、地址、
读写使能、同步读延迟和固定调度不变。

关键实现：

- `ram_m` 的每个pair/bank实例化两个共享地址和使能的 `ram_bram`，读出后按原
  `{sign_xor,min_diag_global,min2,min1}` 布局组合。
- clear和V2C写把逻辑记录同时拆到两个字段；flip RMW只改变 `sign_xor`，但沿用完整记录旁路，使连续同
  地址flip与并发新读请求保持原有固定规则。
- 顶层接口、pair交换、C2V/V2C流水和周期公式均未修改。

功能验证：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`通过。
- `make test-unit`通过全部14个单元测试；`tb_ram_m`覆盖完整记录写读、clear、单次flip和连续同地址
  flip。
- `make test-integration`通过，toy case residual 0、exact 1、154周期。
- K=3统一TRIKE五档seed 1随机译码全部为residual 0、exact 1，固定周期分别为333,990、657,341、
  2,353,770、7,135,995和16,641,183。

定量状态：当前执行环境未提供Vivado可执行文件，Slice LUT、LUT as Logic、LUT as Memory、FF、Slice、
Block RAM Tile、RAMB36、RAMB18、DSP、CARRY4、setup WNS/TNS和hold WHS均为待测。按目标器件原生几何，
K=3物理目标为416个RAMB36、83个RAMB18和457.5个Block RAM Tile；K=4物理目标为496个RAMB36、
83个RAMB18和537.5个Block RAM Tile。上述数字是待Vivado确认的物理目标，不是综合或实现结果。

状态：RTL保留，功能验证完成。需要为K=3和K=4分别运行同器件、同Vivado 2023.2、同100 MHz XDC的
独立Fully Placed/Routed检查点；只有RAMB18减少32、Block RAM Tile减少16且LUT/时序没有明显回退时，
才把该方案记为完整实现基线。

## 26. 装载/启动协议与控制RTL修补

时间：2026-07-17。

目标与假设：补齐参数等级、H、syndrome和启动之间的硬件绑定，避免运行期间重复启动改变固定调度，消除
无效控制寄存器的仿真X传播，并清理未进入成品数据通路的遗留模块。修补仅影响译码前后的配置接受条件和
无效周期输出，不增加主译码状态、窗口、访存或迭代周期。

关键实现：

- `decoder_top` 在首个有效H或syndrome写请求时锁存公开参数等级；首个写周期直接使用输入等级生成配置，
  后续H校验、syndrome装载和译码调度使用锁存等级。
- syndrome装载控制只接受公开范围内按 `0..R-1` 递增的完整帧，完整帧就绪后才允许启动；启动时消费就绪
  状态，为下一帧装载恢复地址0。syndrome RAM写使能由该协议控制。
- `decode_start` 同时要求控制器空闲、H校验通过且syndrome完整；运行期间的 `i_start` 不进入scheduler。
  H和syndrome写请求仅在各自合法装载窗口进入RAM。iteration pair选择对启动和迭代尾拍使用互斥优先级。
- `ram_syndrome` 的读valid、`ram_t` 的读返回选择/valid和 `ram_decision` 的读bank选择增加控制复位；数据
  RAM阵列保持无复位写循环。
- `ram_accum`、`ram_k_global`、`ram_syndrome`和 `ram_decision` 增加仿真期地址范围及bank映射断言；断言
  位于综合保护块内，不进入硬件数据通路。
- 删除无实例引用的 `k_sign_correction` 及构建源清单条目；删除 `tile_scheduler` 中恒定保持的guard、slot和
  lane状态及对应无效端口。K-sign重叠尾部周期使用 `bike_pkg` 的共享常量并保留正值参数检查。
- 顶层和随机testbench在时钟下降沿驱动配置与启动，时钟上升沿后采样 `done`，消除active-region竞态。
  toy集成测试增加syndrome未就绪启动拒绝和忙时重复启动不重启两项检查。

功能验证：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`通过。
- `make test-unit`通过全部14个单元测试；`make test-integration`通过，toy case residual 0、exact 1、固定
  154周期。忙时重复 `i_start` 未改变周期，syndrome未完整装载时控制器保持等待状态；同一H下重新装载
  syndrome并启动第二帧时 `o_done` 正确清除，第二帧仍固定154周期。
- K=3和K=4分别运行统一TRIKE五档seed 1完整随机译码。两种K值在五档均为residual 0、exact 1，固定
  周期均为333,990、657,341、2,353,770、7,135,995和16,641,183。
- 最终代码追加运行TRIKE-512、seed 1的K=3与K=4最大档；两者均为16,641,183周期、residual 0、exact 1，
  新增全局K RAM地址及bank映射断言均未触发。

定量状态：固定周期和已测译码结果保持上述数值。当前执行环境未提供Vivado可执行文件；Slice LUT、LUT
as Logic、LUT as Memory、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、CARRY4、setup WNS/TNS和
hold WHS均为待测。删除的 `k_sign_correction` 未被 `decoder_top` 实例化，因此不把源文件清理记为硬件
资源收益；协议门控和少量控制状态的实现影响等待同配置Vivado报告确认。

状态：RTL与验证修补保留。主译码固定周期和存储访问序列未改变；当前RTL的资源、时序、methodology和CDC
结果待K=3、K=4独立Vivado实现检查。

## 27. `ram_m` 9+9 bit字段拆分的K=3实现结果与撤回

时间：2026-07-17。

目标与假设：验证阶段25把每个18-bit压缩check-state记录拆成两个9-bit物理字段后，Vivado是否会把
`ROW_SEG_SIZE=6787` 的尾部容量吸收到RAMB36，从而删除32个RAMB18、减少16个Block RAM Tile。该检查点
同时包含阶段26的装载/启动协议与控制RTL修补，因此只有与RAM原生几何直接对应的BRAM变化可归因于字段
拆分；LUT、FF、Slice和时序变化不能在缺少独立检查点时强行归因。

报告配置：`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`、最大等级TRIKE-512，器件
`xc7k355tffg901-2L`，Vivado 2023.2 build 4029153，100 MHz/10 ns，user clock uncertainty 0.100 ns。
aggregate utilization为Fully Placed，报告时间2026-07-17 16:19:26；timing summary为Routed，报告时间
16:21:35；结果由用户提供。对照为阶段24的同器件、同参数、同约束K=3检查点。

资源结果：

| 资源 | 阶段24基线 | 9+9 bit检查点 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 26,637 | 26,125 | -512（-1.92%） |
| LUT as Logic | 23,085 | 22,575 | -510（-2.21%） |
| LUT as Memory | 3,552 | 3,550 | -2（-0.06%） |
| Distributed RAM LUT | 3,392 | 3,392 | 0 |
| SRL LUT | 160 | 158 | -2 |
| Slice Register | 11,083 | 11,078 | -5（-0.05%） |
| Slice | 9,133 | 9,071 | -62（-0.68%） |
| Block RAM Tile | 473.5 | 489.5 | +16（+3.38%） |
| RAMB36 | 416 | 416 | 0 |
| RAMB18 | 115 | 147 | +32（+27.83%） |
| DSP | 0 | 0 | 0 |
| CARRY4 | 1,787 | 1,803 | +16（+0.90%） |

Vivado没有把两个9-bit字段的尾部共同装入同一物理Tile：RAMB36保持416，RAMB18精确增加32，Block RAM
Tile增加16。结果与阶段25预期的RAMB18减少32方向相反；说明在该XPM实例边界和端口组织下，每个9-bit
字段分别产生尾部RAMB18，拆分使每个pair/bank的尾部primitive数量翻倍。

Routed timing结果：

| 指标 | 阶段24基线 | 9+9 bit检查点 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.451 ns / 0.000 ns | +0.862 ns / 0.000 ns | WNS +0.411 ns |
| `decoder_clk` setup WNS/TNS | +0.862 ns / 0.000 ns | +1.143 ns / 0.000 ns | WNS +0.281 ns |
| hold WHS/THS | +0.026 ns / 0.000 ns | +0.039 ns / 0.000 ns | WHS +0.013 ns |
| WPWS/TPWS | +4.232 ns / 0.000 ns | +4.232 ns / 0.000 ns | 0 |
| 未约束 `o_e_rdata` 数据路径 | 11.902 ns | 12.958 ns | +1.056 ns（+8.87%） |

全部已定义约束满足。最差主时钟路径从K-sign selector的bank 0局部位置索引寄存器到 `ram_k_tile` bank 4
snapshot distributed RAM写入口，数据路径8.470 ns，其中logic 1.503 ns、route 6.967 ns，共15级逻辑。
报告仍有TIMING-18告警：69个普通输入和7个输出缺少I/O delay，另有1个输入由false path覆盖；内部未约束
endpoint为0。全局base-sign RAM到 `o_e_rdata` 的12.958 ns路径仍不能作为板级一拍100 MHz接口签核。

结论与状态：9+9 bit字段拆分撤回，`ram_m` 恢复为每个pair/bank一个完整18-bit记录的 `ram_bram`。K=3
已经给出精确且显著的BRAM反向结果，因此不继续消耗一次K=4实现来验证同一实例几何。LUT、FF和同步WNS
改善可能来自阶段26控制修补、实现随机性或两者共同作用，待使用撤回字段拆分后的独立检查点确认。撤回不改
变逻辑记录、读写时序、固定调度或译码周期。撤回后 `make format-rtl`、`make check-format-rtl` 和
`make lint-rtl` 通过；`make test` 通过全部14个单元测试及集成测试，toy case为residual 0、exact 1、
固定154周期。撤回后K=3/K=4随机大参数回归与Vivado实现待测。

## 28. 撤回 `ram_m` 字段拆分后的K=3当前RTL基线

时间：2026-07-17。

目标与假设：在 `ram_m` 恢复为完整18-bit记录后，对阶段26保留的装载/启动协议、控制复位、仿真断言和
无效控制清理进行独立K=3实现检查。该检查点用于确认BRAM恢复情况，并量化当前RTL相对阶段24完整基线的
资源与时序变化；固定周期功能验证沿用阶段27撤回后的测试结果。

报告配置：`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=3`、`COLS_PER_TILE=1168`、最大等级TRIKE-512，器件
`xc7k355tffg901-2L`，Vivado 2023.2 build 4029153，100 MHz/10 ns，user clock uncertainty 0.100 ns。
aggregate utilization为Fully Placed，报告时间2026-07-17 16:55:05；timing summary为Routed，报告时间
16:57:31；结果由用户提供。

资源结果：

| 资源 | 阶段24基线 | 当前K=3 RTL | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 26,637 | 26,117 | -520（-1.95%） |
| LUT as Logic | 23,085 | 22,566 | -519（-2.25%） |
| LUT as Memory | 3,552 | 3,551 | -1（-0.03%） |
| Distributed RAM LUT | 3,392 | 3,392 | 0 |
| SRL LUT | 160 | 159 | -1 |
| Slice Register | 11,083 | 11,078 | -5（-0.05%） |
| Slice | 9,133 | 9,331 | +198（+2.17%） |
| Block RAM Tile | 473.5 | 473.5 | 0 |
| RAMB36 | 416 | 416 | 0 |
| RAMB18 | 115 | 115 | 0 |
| DSP | 0 | 0 | 0 |
| CARRY4 | 1,787 | 1,803 | +16（+0.90%） |

相对阶段27的9+9 bit检查点，RAMB36保持416，RAMB18从147恢复为115，Block RAM Tile从489.5恢复为
473.5；该结果确认单个18-bit XPM实例是当前几何下的有效组织。当前控制修补没有增加BRAM。LUT下降520，
但Slice增加198，表明LUT减少没有直接转化为更少的placed Slice；缺少hierarchical utilization和多次实现
样本时，不把全部LUT、Slice或CARRY4变化归因到某个单独控制信号。

Routed timing结果：

| 指标 | 阶段24基线 | 当前K=3 RTL | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.451 ns / 0.000 ns | +0.656 ns / 0.000 ns | WNS +0.205 ns |
| `decoder_clk` setup WNS/TNS | +0.862 ns / 0.000 ns | +0.812 ns / 0.000 ns | WNS -0.050 ns |
| hold WHS/THS | +0.026 ns / 0.000 ns | +0.039 ns / 0.000 ns | WHS +0.013 ns |
| WPWS/TPWS | +4.232 ns / 0.000 ns | +4.232 ns / 0.000 ns | 0 |
| 未约束 `o_e_rdata` 数据路径 | 11.902 ns | 11.823 ns | -0.079 ns（-0.66%） |

全部已定义约束满足。最差主时钟路径从 `ram_k_global` bank 6的deviation位置RAMB36读口到
`c2v_ksign_sign_q_reg[6]`，数据路径8.667 ns，其中logic 2.144 ns、route 6.523 ns，共8级逻辑。最差
异步路径从 `u_reset_sync/rst_sync_n_reg` 到 `v2c_comp_c_reg[15]` 的CLR端，数据路径9.237 ns，其中route
占96.308%。主同步WNS相对阶段24减少0.050 ns，仍保留0.812 ns裕量，未形成100 MHz回退。

时序边界保持：TIMING-18报告76项，69个普通输入和7个输出缺少I/O delay，另有1个输入由false path覆盖，
内部未约束endpoint为0。全局base-sign RAM到 `o_e_rdata` 的11.823 ns路径仍未完成板级一拍100 MHz签核。

功能验证：阶段27记录的14个单元测试和集成测试通过，toy case为residual 0、exact 1、固定154周期。
当前RTL追加运行K=3统一TRIKE五档seed 1随机译码，五档均为residual 0、exact 1，固定周期分别为
333,990、657,341、2,353,770、7,135,995和16,641,183。

状态：当前K=3 RTL及该Fully Placed/Routed结果保留，并作为新的完整K=3实现基线。K=4当前RTL功能回归和
Vivado实现，以及hierarchical utilization、最新methodology、CDC和完整messages报告待补充。

## 29. 当前RTL的K=4实现基线

时间：2026-07-17。

目标与假设：在阶段28确认K=3当前RTL后，对相同RTL和最大统一硬件几何执行K=4实现，确认协议与控制修补
没有改变K=4的BRAM映射，并量化相对阶段24 K=4基线的资源、布局和时序变化。

报告配置：`TRIKE_UNIFIED_PARAMS`、`L=16`、`K=4`、`COLS_PER_TILE=1168`、最大等级TRIKE-512，器件
`xc7k355tffg901-2L`，Vivado 2023.2 build 4029153，100 MHz/10 ns，user clock uncertainty 0.100 ns。
aggregate utilization为Fully Placed，报告时间2026-07-17 17:15:01；timing summary为Routed，报告时间
17:17:46；结果由用户提供。

资源结果：

| 资源 | 阶段24 K=4基线 | 当前K=4 RTL | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 29,013 | 28,243 | -770（-2.65%） |
| LUT as Logic | 24,692 | 23,924 | -768（-3.11%） |
| LUT as Memory | 4,321 | 4,319 | -2（-0.05%） |
| Distributed RAM LUT | 4,160 | 4,160 | 0 |
| SRL LUT | 161 | 159 | -2 |
| Slice Register | 11,494 | 11,489 | -5（-0.04%） |
| Slice | 10,070 | 9,911 | -159（-1.58%） |
| Block RAM Tile | 553.5 | 553.5 | 0 |
| RAMB36 | 496 | 496 | 0 |
| RAMB18 | 115 | 115 | 0 |
| DSP | 0 | 0 | 0 |
| CARRY4 | 1,803 | 1,819 | +16（+0.89%） |

当前K=4 BRAM映射保持496个RAMB36、115个RAMB18和553.5个Block RAM Tile，说明保留的协议与控制修补
没有增加存储资源。LUT和Slice同时下降，但缺少hierarchical utilization和多次实现样本时，不把全部变化
归因到单独信号或模块。

Routed timing结果：

| 指标 | 阶段24 K=4基线 | 当前K=4 RTL | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.535 ns / 0.000 ns | +0.547 ns / 0.000 ns | WNS +0.012 ns |
| `decoder_clk` setup WNS/TNS | +0.717 ns / 0.000 ns | +0.547 ns / 0.000 ns | WNS -0.170 ns |
| hold WHS/THS | +0.022 ns / 0.000 ns | +0.027 ns / 0.000 ns | WHS +0.005 ns |
| WPWS/TPWS | +4.232 ns / 0.000 ns | +4.232 ns / 0.000 ns | 0 |
| 未约束 `o_e_rdata` 数据路径 | 12.209 ns | 12.743 ns | +0.534 ns（+4.37%） |

全部已定义约束满足。最差主时钟路径从K-sign selector的bank 0局部位置索引寄存器到 `ram_k_tile` bank 10
snapshot distributed RAM写入口，数据路径9.013 ns，其中logic 1.245 ns、route 7.768 ns，共12级逻辑，
布线占86.186%。最差异步路径从 `u_reset_sync/rst_sync_n_reg` 到 `ram_k_global` bank 6的segment选择
寄存器CLR端，数据路径8.858 ns，其中route占96.207%。主同步WNS相对阶段24减少0.170 ns，仍保留
0.547 ns裕量，满足内部100 MHz目标。

时序边界保持：TIMING-18报告76项，69个普通输入和7个输出缺少I/O delay，另有1个输入由false path覆盖，
内部未约束endpoint为0。全局base-sign RAM到 `o_e_rdata` 的12.743 ns路径仍未完成板级一拍100 MHz签核。

功能验证：当前RTL运行K=4统一TRIKE五档seed 1随机译码，五档均为residual 0、exact 1，固定周期分别为
333,990、657,341、2,353,770、7,135,995和16,641,183。

状态：当前K=4 RTL及该Fully Placed/Routed结果保留，并作为新的完整K=4实现基线。K=3和K=4当前RTL均
具备五档随机功能回归及独立Fully Placed/Routed结果；hierarchical utilization、最新methodology、CDC和
完整messages报告待补充。

## 30. K=4统一TRIKE的32-lane并行度探索

时间：2026-07-20。

目标与假设：将统一TRIKE K-sign配置从 `L=16` 提高到 `L=32`，先验证五个公开参数等级的固定周期和
译码正确性，再由Vivado判断并行度翻倍后的资源、频率和整体固定译码时间。`COLS_PER_TILE=1168` 不满足
大tile宽度必须整除 `L` 的参数约束，因此本次选择相邻且保持 `Q_BASE=37` 的
`COLS_PER_TILE=1184=32*37`；该选择同时避免每个完整tile末组出现16个invalid lane。

验证配置：`TRIKE_UNIFIED_PARAMS`、`L=32`、`K=4`、`COLS_PER_TILE=1184`、message width 5 bit、
五档统一硬件几何、seed 1、每档1个随机样本。运行 `make format-rtl`、`make check-format-rtl` 和
`make lint-rtl` 均通过；K=4 toy配置的14个单元测试和集成测试通过，集成case为residual 0、exact 1、
固定154周期。统一TRIKE随机回归命令为：

```sh
make test-trike-unified-ksign-random \
  BIKE_RANDOM_TRIALS=1 \
  TRIKE_UNIFIED_KSIGN_K=4 \
  TRIKE_UNIFIED_KSIGN_PARALLEL_L=32 \
  TRIKE_UNIFIED_KSIGN_COLS_PER_TILE=1184
```

五档随机功能结果：

| profile | `L=16, COLS_PER_TILE=1168` 固定周期 | `L=32, COLS_PER_TILE=1184` 固定周期 | 周期变化 | 结果 |
| --- | ---: | ---: | ---: | --- |
| TRIKE-128 | 333,990 | 175,720 | -158,270（-47.39%） | residual 0，exact 1 |
| TRIKE-160 | 657,341 | 345,855 | -311,486（-47.39%） | residual 0，exact 1 |
| TRIKE-256 | 2,353,770 | 1,192,316 | -1,161,454（-49.34%） | residual 0，exact 1 |
| TRIKE-384 | 7,135,995 | 3,685,394 | -3,450,601（-48.35%） | residual 0，exact 1 |
| TRIKE-512 | 16,641,183 | 8,664,060 | -7,977,123（-47.94%） | residual 0，exact 1 |

周期数由公开profile、`L`、tile几何和固定7轮调度决定；每档仿真实测值与固定周期公式一致。单个seed的
译码通过只能确认该配置的RTL功能和固定调度检查点，不能替代多seed DFR评估。

Vivado报告配置：`xc7k355tffg901-2L`，Vivado 2023.2 build 4029153，100 MHz/10 ns，user clock
uncertainty 0.100 ns。aggregate utilization为Fully Placed，报告时间2026-07-20 14:59:15；timing
summary为Routed，报告时间15:03:27；结果由用户提供。

资源结果：

| 资源 | `L=16, K=4` | `L=32, K=4` | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 28,243 | 50,805 | +22,562（+79.89%） |
| LUT as Logic | 23,924 | 46,357 | +22,433（+93.77%） |
| LUT as Memory | 4,319 | 4,448 | +129（+2.99%） |
| Distributed RAM LUT | 4,160 | 4,160 | 0 |
| SRL LUT | 159 | 288 | +129（+81.13%） |
| Slice Register | 11,489 | 20,947 | +9,458（+82.32%） |
| Slice | 9,911 | 17,311 | +7,400（+74.66%） |
| Block RAM Tile | 553.5 | 673.5 | +120.0（+21.68%） |
| RAMB36 | 496 | 576 | +80（+16.13%） |
| RAMB18 | 115 | 195 | +80（+69.57%） |
| DSP | 0 | 0 | 0 |
| CARRY4 | 1,819 | 3,078 | +1,259（+69.21%） |

根据当前RTL实例数、地址宽度和7-series RAM原生宽深模式，可以重建以下物理BRAM归属；各模块之和与
aggregate报告精确一致：

| 模块 | `L=16` RAMB36/RAMB18/Tile | `L=32` RAMB36/RAMB18/Tile | Tile变化 | 主要原因 |
| --- | ---: | ---: | ---: | --- |
| `ram_k_global` | 336 / 0 / 336 | 384 / 32 / 400 | +64 | 位置段由16×4×5变为32×4×3；base-sign bank由16个RAMB36变为32个RAMB18 |
| `ram_m` | 128 / 32 / 144 | 128 / 0 / 128 | -16 | 32个深度6787 bank变为64个深度3394 bank，地址宽度13→12，尾部RAMB18消失 |
| `ram_t` | 32 / 32 / 48 | 64 / 64 / 96 | +48 | 双buffer bank由32增至64；深度8103→4107但地址宽度均为13，每bank原语数未降低 |
| `ram_sign_delta` | 0 / 32 / 16 | 0 / 64 / 32 | +16 | 两个iteration pair的1-bit bank数量随L翻倍 |
| `ram_syndrome` | 0 / 16 / 8 | 0 / 32 / 16 | +8 | 1-bit syndrome bank数量随L翻倍 |
| `ram_i` | 0 / 3 / 1.5 | 0 / 3 / 1.5 | 0 | H第一列的三份读视图不按lane复制 |
| 合计 | 496 / 115 / 553.5 | 576 / 195 / 673.5 | +120 | 与Fully Placed aggregate报告一致 |

该表是RTL和原语几何重建，不替代hierarchical utilization。timing报告中L=32的 `ram_k_global`
base-sign读路径源原语为RAMB18E1，与上述跨界映射一致；正式模块归属仍应由同次实现的hierarchical报告
直接确认。

LUT逻辑、寄存器和Slice随lane datapath复制接近翻倍，共享控制和存储总容量使增长低于2倍；BRAM bank
深度随 `L` 增大而降低，因此Block RAM Tile增加21.68%，没有随bank数量翻倍。该映射符合32-lane架构的
总体预期，但673.5个Block RAM Tile已占器件715个Tile的94.20%，只剩41.5个Tile，后续存储扩展和布局
余量很小。缺少hierarchical utilization时，不把RAMB36和RAMB18的具体增量归因到单一RAM模块。

Routed timing结果：

| 指标 | `L=16, K=4` | `L=32, K=4` | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.547 ns / 0.000 ns | +0.226 ns / 0.000 ns | WNS -0.321 ns |
| `decoder_clk` setup WNS/TNS | +0.547 ns / 0.000 ns | +0.226 ns / 0.000 ns | WNS -0.321 ns |
| hold WHS/THS | +0.027 ns / 0.000 ns | +0.033 ns / 0.000 ns | WHS +0.006 ns |
| WPWS/TPWS | +4.232 ns / 0.000 ns | +4.232 ns / 0.000 ns | 0 |
| 未约束 `o_e_rdata` 数据路径 | 12.743 ns | 14.597 ns | +1.854 ns（+14.55%） |

全部已定义约束满足。最差主时钟路径从 `v2c_tile_offset_c_reg[13][7]` 到 `ram_k_tile` bank 9工作
distributed RAM的读数据寄存器，数据路径9.533 ns，其中logic 0.266 ns、route 9.267 ns，布线占
97.210%，源网络fanout为1472。其余前列路径集中在同一tile-offset广播和V2C地址生成，说明L=32的时序
余量主要受高扇出布线和物理拥塞限制，而非深组合逻辑。最差异步复位释放路径WNS为+3.243 ns，目的端为
lane 31的V2C bypass地址寄存器CLR。

时序边界保持：TIMING-18报告76项，69个普通输入和7个输出缺少I/O delay，另有1个输入由false path覆盖，
内部未约束endpoint为0。`o_e_rdata` 的14.597 ns外部输出路径未完成板级一拍100 MHz签核。

状态：RTL无须修改；该L=32配置通过五档功能回归并完成Fully Placed/Routed，内部100 MHz满足，TRIKE-512
固定译码时间由166.41183 ms降为86.64060 ms。作为高吞吐候选保留；采用前需接受94.20% BRAM占用和仅
+0.226 ns setup裕量，并单独完成接口时序签核。

## 31. L=32的1152列tile BRAM边界探索

时间：2026-07-20。

目标与假设：阶段30的 `L=32`、`K=4`、`COLS_PER_TILE=1184` 配置中，`ram_t` bank深度为
`111*37=4107`，刚超过 `4K*9` RAMB36的4096深度边界，因此64个双buffer/lane bank各使用1个RAMB36和
1个RAMB18。将tile宽度设为 `1152=32*36` 后，`Q_BASE=36`、`ram_t` 深度为3996，目标是删除每bank的
尾部RAMB18，以较小固定周期代价降低BRAM Tile占用。

实现方式：仓库统一TRIKE K-sign默认构建参数设为 `L=32`、`K=4`、`COLS_PER_TILE=1152`。Makefile随机
回归和Vivado入口使用该组默认值；`bike_pkg.sv` 的无命令行宏fallback使用相同的K与tile宽度。decoder
datapath、RAM端口、调度状态机和固定迭代数不变。

验证范围：`make format-rtl`、`make check-format-rtl`、`make lint-rtl` 全部通过；`make test` 通过14个
单元测试及集成测试，`tb_k_sign_update` 报告K=4，toy集成case为residual 0、exact 1、固定154周期。
只定义 `TRIKE_UNIFIED_PARAMS`、其余参数使用 `bike_pkg.sv` fallback的 `decoder_top` Verilator elaboration
通过。统一TRIKE五档seed 1随机回归均为residual 0、exact 1：

| profile | 1184列固定周期 | 1152列固定周期 | 周期变化 | 结果 |
| --- | ---: | ---: | ---: | --- |
| TRIKE-128 | 175,720 | 193,486 | +17,766（+10.11%） | residual 0，exact 1 |
| TRIKE-160 | 345,855 | 365,945 | +20,090（+5.81%） | residual 0，exact 1 |
| TRIKE-256 | 1,192,316 | 1,207,716 | +15,400（+1.29%） | residual 0，exact 1 |
| TRIKE-384 | 3,685,394 | 3,729,550 | +44,156（+1.20%） | residual 0，exact 1 |
| TRIKE-512 | 8,664,060 | 8,720,781 | +56,721（+0.65%） | residual 0，exact 1 |

Vivado条件：Windows Vivado 2023.2，`xc7k355tffg901-2L`，100 MHz `decoder_clk`、10 ns周期和
0.100 ns user uncertainty；资源报告阶段为Fully Placed，时序报告阶段为Routed。与阶段30仅
`COLS_PER_TILE` 不同，器件、参数族、`L=32`、`K=4` 和约束保持一致。

资源实测：

| 资源 | 1184列 | 1152列 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 50,805 | 50,316 | -489（-0.96%） |
| LUT as Logic | 46,357 | 45,868 | -489（-1.05%） |
| LUT as Memory | 4,448 | 4,448 | 0 |
| Slice Register | 20,947 | 20,931 | -16（-0.08%） |
| Slice | 17,311 | 16,721 | -590（-3.41%） |
| Block RAM Tile | 673.5 | 641.5 | -32.0（-4.75%） |
| RAMB36E1 | 576 | 576 | 0 |
| RAMB18E1 | 195 | 131 | -64（-32.82%） |
| DSP | 0 | 0 | 0 |
| CARRY4 | 3,078 | 2,998 | -80（-2.60%） |

BRAM结果精确命中原生几何预测：64个 `ram_t` bank各删除1个尾部RAMB18，全设计RAMB36不变，Block RAM
Tile利用率从94.20%降至89.72%，可用Tile从41.5增至73.5。LUT memory、distributed RAM和SRL不变；
`ram_t` 地址宽度从13降至12伴随489个logic LUT、16个FF和80个CARRY4减少。报告未包含hierarchical
utilization，因此实例归属结论来自XPM深度边界与aggregate总量的精确对应。

Routed时序实测：

| 指标 | 1184列 | 1152列 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.226 / 0.000 ns | +0.062 / 0.000 ns | WNS -0.164 ns |
| `decoder_clk` setup WNS/TNS | +0.226 / 0.000 ns | +0.062 / 0.000 ns | WNS -0.164 ns |
| hold WHS/THS | +0.033 / 0.000 ns | +0.026 / 0.000 ns | WHS -0.007 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| `**async_default**` setup WNS | +3.243 ns | +2.222 ns | -1.021 ns |
| `o_e_rdata` 未约束输出路径 | 14.597 ns | 13.791 ns | -0.806 ns |

内部100 MHz约束满足，但setup裕量仅0.062 ns。最差主时钟路径从
`v2c_tile_offset_c_reg[13][9]` 到 `ram_k_tile` bank 28工作distributed RAM读数据寄存器，数据路径
9.731 ns，其中route为9.465 ns、占97.267%；资源减少没有形成routed timing收益。TIMING-18仍为76项，
内部未约束endpoint为0，69个普通输入和7个输出缺少I/O delay，另有1个输入由false path覆盖。

结论与状态：方案保留为默认配置。BRAM Tile节省32个的收益成立，TRIKE-512固定周期增加56,721拍
（+0.65%），100 MHz固定译码时间为87.20781 ms；内部时序通过但裕量很薄，板级I/O仍未签核。后续在
确认可复现时序裕量或完成针对tile-offset高扇出布线的优化前，不把本次改动记为频率收益。

## 32. L=32、K=4全局K记录的双位置18-bit字段映射

时间：2026-07-21。

目标与假设：默认 `L=32`、`K=4`、`COLS_PER_TILE=1152` 配置中，`ram_k_global` 的bank深度为
`ceil(325761/32)=10181`。阶段31基线将四个7-bit位置分别按 `4K × 9` 深度分段，每个位置需要3段，
每bank共12个RAMB36；1-bit `base_sign` 另映射为一个RAMB18。32个bank合计384个RAMB36和32个
RAMB18，即400个Block RAM Tile。实验目标是保持29-bit逻辑记录和每拍32读/32写接口不变，改用
`2K × 18` 原生几何降低物理RAM数量。

关键实现：

- 仅在 `L=32 && K=4 && DIAG_IDX_W=7` 时启用配对字段，其他参数继续使用独立base-sign和位置字段。
- field 0保存 `{base_sign, dev_pos[1], dev_pos[0]}` 共15 bit，field 1保存
  `{dev_pos[3], dev_pos[2]}` 共14 bit；两个字段的物理数据宽度均固定为18 bit。
- 每个字段按2048深度显式切成 `ceil(10181/2048)=5` 段；每bank共10个RAMB36，32个bank的静态目标
  为320个RAMB36，不再需要独立base-sign RAMB18。
- 读segment编号与同步RAM延迟对齐，字段读出后恢复为原29-bit记录；写地址、写valid和记录数据保持原有
  寄存边界。K候选选择、无效位置、严格大于替换、符号重构和固定调度均未改变。

验证范围：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`和 `git diff --check`通过。
- `make test-unit`通过14个单元测试；`make test-integration`通过，toy case为residual 0、exact 1、固定
  154周期。
- `TRIKE_UNIFIED_PARAMS`、`L=32`、`K=4`、`COLS_PER_TILE=1152`、seed 1的五档随机回归全部通过：

| profile | 固定周期 | 结果 |
| --- | ---: | --- |
| TRIKE-128 | 193,486 | residual 0，exact 1 |
| TRIKE-160 | 365,945 | residual 0，exact 1 |
| TRIKE-256 | 1,207,716 | residual 0，exact 1 |
| TRIKE-384 | 3,729,550 | residual 0，exact 1 |
| TRIKE-512 | 8,720,781 | residual 0，exact 1 |

物理资源目标：若Vivado按显式的10个 `2K × 18` RAMB36/bank映射，`ram_k_global` 将由
384 RAMB36 + 32 RAMB18变为320 RAMB36，全设计预计由576 RAMB36、131 RAMB18、641.5 Tile变为
512 RAMB36、99 RAMB18、561.5 Tile，目标减少80个Block RAM Tile，利用率目标为78.53%。这些数字是
RTL实例数与7-series原生几何推导，不是综合或布局布线实测。

时序与实现状态：当前环境没有Vivado可执行文件。Slice LUT、LUT as Logic、LUT as Memory、FF、Slice、
CARRY4、实际RAMB36/RAMB18、setup WNS/TNS、hold WHS和top paths均待同器件、同XDC的Fully Placed /
Routed报告确认。配对字段的5段读选择比原每位置3段选择更深，默认基线仅有 `+0.062 ns` setup裕量；只有
物理RAM目标兑现且100 MHz继续收敛时才保留。状态：RTL候选已实现并通过功能回归，Vivado待测。

## 33. 全局K记录的bank侧符号重构与窄返回路由

时间：2026-07-21。

目标与假设：`ram_k_global` 的读请求先旋转到column bank，原结构将每bank完整29-bit K=4记录通过5级
桶型网络逆旋转回32条lane，再在每lane执行K个位置命中比较。该返回网络包含
`29 × 32 × 5 = 4640`个1-bit 2选1 MUX节点。实验目标是在bank侧完成相同的invalid过滤、位置命中和
`base_sign XOR hit`重构，只跨lane返回必要结果，减少组合路由宽度且不改变RAM访问和固定周期。

关键实现：

- `ram_k_global` 接收当前请求的公共 `diag_idx_local`，与同步RAM读延迟一起寄存。
- 每个bank在完整记录组合完成后生成 `{sign, hit, base_sign}` 三位结果；命中规则与
  `k_sign_reconstruct`相同，invalid sentinel不参与命中。
- 三位结果使用原读shift逆旋转回请求lane，主译码直接使用返回sign，完成后的串行错误向量接口使用返回
  base-sign。
- 29-bit完整记录返回端口保留给模块级验证，但顶层只连接到无消费者的内部信号，使实现优化可以裁剪原
  `29 × 32 × 5`宽返回网络。活动返回网络为 `3 × 32 × 5 = 480`个1-bit MUX节点，结构上减少4160个
  1-bit MUX节点；实际Slice LUT和布线收益必须由placed层级报告确认。
- correction继续读取tile位置snapshot；全局K RAM写接口、配对字段、候选提交和固定调度不变。

验证范围：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`、`git diff --check`通过。
- `make test`通过14个单元测试和toy集成，toy case为residual 0、exact 1、固定154周期。
- `L=32`、`K=4`、`COLS_PER_TILE=1152`五档seed 1回归全部为residual 0、exact 1，周期保持
  193,486、365,945、1,207,716、3,729,550和8,720,781。
- 非配对字段路径追加运行 `L=16`、`K=3`、`COLS_PER_TILE=1168` 的TRIKE-128 seed 1，结果为
  residual 0、exact 1、固定333,990周期。

定量状态：当前环境没有Vivado可执行文件。该结构明确缩小全局K读返回的桶型payload，但Slice LUT、LUT
as Logic、FF、Slice、布线拥塞、setup WNS/TNS和hold WHS均待测。阶段32的BRAM字段映射和本阶段的窄返回
路由已同时存在于当前候选，因此下一份实现报告相对阶段31可确认组合净收益；若需要严格拆分LUT归因，应
分别保留启用/禁用窄返回的实现检查点。状态：RTL候选已实现并通过功能回归，Vivado待测。

## 34. L=32配对K字段与窄返回路由的组合实现检查点

时间：2026-07-22。

目标与范围：对阶段32的全局K记录双位置18-bit字段映射和阶段33的bank侧符号重构、3-bit窄返回路由做
同一次物理实现，确认BRAM原生几何预测是否兑现，以及组合后的LUT和时序净结果。比较基线为阶段31的
`L=32`、`K=4`、`COLS_PER_TILE=1152`实现；译码参数、固定周期、器件、Vivado版本和XDC保持一致。

Vivado条件：Windows Vivado 2023.2，`xc7k355tffg901-2L`，`TRIKE_UNIFIED_PARAMS`，100 MHz
`decoder_clk`、10 ns周期、0.100 ns user uncertainty；资源报告为2026-07-22 Fully Placed aggregate
utilization，时序报告为Routed。功能验证沿用阶段32/33的格式、lint、14个单元测试、toy集成和统一TRIKE
五档seed 1随机回归；固定周期保持193,486、365,945、1,207,716、3,729,550和8,720,781。

资源实测：

| 资源 | 阶段31基线 | 配对字段+窄返回 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 50,316 | 49,147 | -1,169（-2.32%） |
| LUT as Logic | 45,868 | 44,699 | -1,169（-2.55%） |
| LUT as Memory | 4,448 | 4,448 | 0 |
| Distributed RAM LUT | 4,160 | 4,160 | 0 |
| SRL LUT | 288 | 288 | 0 |
| Slice Register | 20,931 | 20,936 | +5（+0.02%） |
| Slice | 16,721 | 15,899 | -822（-4.92%） |
| Block RAM Tile | 641.5 | 561.5 | -80.0（-12.47%） |
| RAMB36E1 | 576 | 512 | -64（-11.11%） |
| RAMB18E1 | 131 | 99 | -32（-24.43%） |
| DSP | 0 | 0 | 0 |
| CARRY4 | 2,998 | 2,998 | 0 |

BRAM结果精确命中阶段32预测：`ram_k_global` 的32个bank合计由384 RAMB36和32 RAMB18变为320
RAMB36，全设计减少64个RAMB36、32个RAMB18和80个Block RAM Tile；Tile利用率从89.72%降至
78.53%，可用Tile从73.5增至153.5。LUT减少全部来自logic LUT，LUT memory、distributed RAM和SRL
均未变化，说明本检查点没有用LUTRAM换取BRAM。由于配对字段和窄返回在同一检查点启用，1,169个logic
LUT只能记为组合净收益；没有关闭窄返回的同次实现报告，不能把全部LUT下降单独归因于桶型路由收窄。

Routed时序实测：

| 指标 | 阶段31基线 | 配对字段+窄返回 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.062 / 0.000 ns | +0.098 / 0.000 ns | WNS +0.036 ns |
| `decoder_clk` setup WNS/TNS | +0.062 / 0.000 ns | +0.098 / 0.000 ns | WNS +0.036 ns |
| hold WHS/THS | +0.026 / 0.000 ns | +0.028 / 0.000 ns | WHS +0.002 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| `**async_default**` setup WNS | +2.222 ns | +1.293 ns | -0.929 ns |
| `o_e_rdata`未约束输出路径 | 13.791 ns | 12.509 ns | -1.282 ns |

内部100 MHz约束继续满足，配对字段的5段选择没有形成时序回退。最差主时钟路径从K-sign selector的
bank 11 snapshot distributed RAM读数据寄存器到 `ram_sign_delta` pair 0、bank 0的read-bypass valid
寄存器，数据路径9.713 ns，其中logic 0.913 ns、route 8.800 ns，route占90.600%，逻辑深度10级。
前十条setup路径主要落在selector snapshot到 `ram_sign_delta` 地址/旁路控制，以及 `ram_t` 到VNU；
`ram_k_global`窄返回没有出现在关键路径前列。异步复位组裕量下降但仍为正。

TIMING-18仍为76项；内部未约束endpoint为0，69个普通输入和7个输出缺少I/O delay，另有1个输入由
false path覆盖。`o_e_rdata`的12.509 ns是未约束器件输出路径，不能据此宣称板级一拍100 MHz接口通过。

结论与状态：两个方案组合保留。相对阶段31，在固定周期和100 MHz内部收敛不变的条件下，实测减少
1,169个LUT、822个Slice和80个Block RAM Tile，BRAM容量从高占用区降至78.53%，setup WNS小幅改善
0.036 ns。该结果构成当前 `L=32`、`K=4`、`COLS_PER_TILE=1152` 的完整Fully Placed/Routed基线；若
后续需要拆分1,169个LUT的归因，再增加仅启用配对字段的消融实现，不影响当前方案保留结论。

## 35. correction snapshot的bank侧命中与1-bit返回路由

时间：2026-07-22。

目标与假设：阶段34的最差主时钟路径从 `ram_k_tile` bank 11的snapshot distributed RAM读数据寄存器
到 `ram_sign_delta` 的read-bypass valid寄存器，数据路径9.713 ns，route占90.600%。原数据流先把每个
column bank的完整29-bit K=4记录经过5级逆桶型网络返回32条请求lane，再在lane侧实例化K路位置比较、
invalid过滤和有效命中判断。该实验把命中判断移到snapshot所在bank，仅将已经用read-valid门控的1-bit
命中结果逆路由回原请求lane，目标是同时缩小组合网络和改善snapshot到delta写控制的物理局部性。

关键实现：

- correction请求的 `diag_idx_local`、bank侧read-valid和原有逆路由shift均寄存一拍，与snapshot同步读出
  对齐；固定RAM读延迟和correction调度拍数不变。
- 每个snapshot bank直接对K个位置执行与 `k_sign_reconstruct`相同的比较：invalid sentinel不命中，任一
  有效位置等于当前 `diag_idx_local` 时输出1；无效请求强制输出0。
- 活动逆返回网络从 `29 × 32 × 5 = 4640` 个1-bit 2选1 MUX节点缩为
  `1 × 32 × 5 = 160`个，结构上减少4480个1-bit MUX节点。完整记录返回端口仅保留给模块级等价验证，
  顶层连接到无消费者信号，使实现工具可以裁剪原29-bit返回网络。
- 顶层删除32个lane侧 `k_sign_reconstruct` correction实例和末端 `valid && hit`逻辑，直接把已经门控的
  1-bit返回结果作为 `ram_sign_delta.i_flip_valid`。row地址仍按原流水寄存，RAM访问数、pair选择、连续
  同地址翻转旁路和固定周期不变。
- read-valid寄存器从lane侧移到column bank侧，7-bit correction位置寄存器同步移入selector，理论FF
  数量基本不变；BRAM和LUTRAM结构不变。

验证范围：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`和 `git diff --check`通过。
- `tb_k_sign_update`同时比较保留的完整记录lane侧重构结果和新的bank侧命中结果；14个单元测试全部通过。
- toy集成通过，residual 0、exact 1、固定154周期。
- `L=32`、`K=4`、`COLS_PER_TILE=1152`统一TRIKE五档seed 1随机回归均为residual 0、exact 1，固定周期
  保持193,486、365,945、1,207,716、3,729,550和8,720,781。
- `L=16`、`K=3`、`COLS_PER_TILE=1168`统一TRIKE五档seed 1随机回归均为residual 0、exact 1，固定周期
  保持333,990、657,341、2,353,770、7,135,995和16,641,183，覆盖非2次幂K和通用存储路径。

定量状态：该候选尚未运行Vivado。相对阶段34的Slice LUT、LUT as Logic、FF、Slice、Block RAM Tile、
setup WNS/TNS、hold WHS和top-path集合均待同器件、同XDC的Fully Placed/Routed报告。4480个MUX节点是
RTL网络规模差，不等于4480个物理LUT；只有aggregate utilization下降才能记录LUT收益。由于阶段34的
关键路径正穿过被重构的数据流，本实验以该路径退出前列、整体WNS不下降且固定周期不变作为保留条件。
状态：RTL候选已实现并通过K=3/K=4五档功能回归，Vivado待测。

## 36. correction 1-bit返回路由的实现检查点

时间：2026-07-22。

目标与范围：对阶段35的bank侧correction命中和1-bit逆返回路由做独立物理实现。比较基线为阶段34的
全局K配对字段与3-bit全局读返回版本；两次报告均使用 `TRIKE_UNIFIED_PARAMS`、`L=32`、`K=4`、
`COLS_PER_TILE=1152`、Windows Vivado 2023.2、`xc7k355tffg901-2L`、100 MHz时钟和0.100 ns user
uncertainty。资源报告为Fully Placed aggregate utilization，时序报告为Routed。

资源实测：

| 资源 | 阶段34基线 | correction 1-bit返回 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 49,147 | 48,027 | -1,120（-2.28%） |
| LUT as Logic | 44,699 | 43,580 | -1,119（-2.50%） |
| LUT as Memory | 4,448 | 4,447 | -1 |
| Distributed RAM LUT | 4,160 | 4,160 | 0 |
| SRL LUT | 288 | 287 | -1 |
| Slice Register | 20,936 | 20,946 | +10（+0.05%） |
| Slice | 15,899 | 16,053 | +154（+0.97%） |
| Block RAM Tile | 561.5 | 561.5 | 0 |
| RAMB36E1 | 512 | 512 | 0 |
| RAMB18E1 | 99 | 99 | 0 |
| DSP | 0 | 0 | 0 |
| CARRY4 | 2,998 | 2,998 | 0 |

1,120个LUT的净下降确认完整29-bit correction返回网络和lane侧重构逻辑已被裁剪，收益量级不能由
4480个RTL MUX节点直接换算。LUT下降没有增加distributed RAM或BRAM；FF增加10，且由于布局装箱变化，
Slice反而增加154，因此该方案的面积结论应表述为logic LUT下降，而不是所有Slice资源同时下降。

Routed时序实测：

| 指标 | 阶段34基线 | correction 1-bit返回 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.098 / 0.000 ns | +0.590 / 0.000 ns | WNS +0.492 ns |
| `decoder_clk` setup WNS/TNS | +0.098 / 0.000 ns | +0.590 / 0.000 ns | WNS +0.492 ns |
| hold WHS/THS | +0.028 / 0.000 ns | +0.027 / 0.000 ns | WHS -0.001 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| `**async_default**` setup WNS | +1.293 ns | +3.239 ns | +1.946 ns |
| `o_e_rdata`未约束输出路径 | 12.509 ns | 14.515 ns | +2.006 ns |

阶段35直接命中的目标成立：snapshot到 `ram_sign_delta` 的路径未进入前十条setup路径。新的最差主时钟
路径从 `v2c_tile_offset_c_reg[27][10]` 的布局复制寄存器到K-sign selector bank 29工作distributed RAM
读数据寄存器，数据路径9.303 ns，其中logic 0.266 ns、route 9.037 ns，route占97.141%。第二条为同源
相邻bit；其余前列包括 `ram_t` 到VNU、selector局部位置索引到snapshot写入口和全局K RAM到C2V符号
寄存器。整体100 MHz裕量由0.098 ns提高到0.590 ns。

TIMING-18仍为76项，内部未约束endpoint为0；69个普通输入和7个输出缺少I/O delay，另有1个输入由
false path覆盖。`o_e_rdata`未约束输出路径增至14.515 ns，因此本次内部时序收益不能扩展为板级输出
接口收益。

功能与周期沿用阶段35已经完成的K=4、L=32五档及K=3、L=16五档seed 1回归；全部residual 0、exact 1，
固定周期不变。结论与状态：方案保留并形成新的 `L=32`、`K=4`、`COLS_PER_TILE=1152`完整基线。相对
阶段34，实测减少1,120个LUT并提高0.492 ns setup WNS，代价为10个FF和154个Slice；BRAM和译码时间不变。
后续时序优化目标转为 `v2c_tile_offset_c` 到K-sign工作distributed RAM的高扇出布线路径。

## 37. L=16、K=4通用窄返回路由实现检查点与K=3方向收束

时间：2026-07-25。

目标与范围：

- 保存用户提供的最新`L=16`完整实现结果，确认面向`L=32`实现的窄返回路由结构在`L=16`配置下的物理效果；
- 与阶段29同器件、同工具、同约束、同参数的`L=16`、`K=4`基线比较；
- 根据已有DFR探索中`K=3`相对明显的性能劣化，收束后续主优化方向，同时保留现有`K=3` RTL、验证覆盖
  和实现结果。

配置与报告条件：

- 参数：`TRIKE_UNIFIED_PARAMS`，`L=16`，`K_SIGN_K=4`，`COLS_PER_TILE=1168`；
- FPGA：`xc7k355tffg901-2L`；
- 工具：Vivado 2023.2；
- 时钟：`decoder_clk = 100 MHz`，周期`10.000 ns`，用户不确定度`0.100 ns`；
- 资源报告阶段：Fully Placed，2026-07-25 15:36:58；
- 时序报告阶段：Routed，2026-07-25 15:39:23；
- 比较基线：阶段29的2026-07-17 `L=16`、`K=4`、`COLS_PER_TILE=1168`结果。

资源结果：

| 指标 | 阶段29基线 | 2026-07-25结果 | 变化 |
|---|---:|---:|---:|
| Slice LUTs | 28243 | 27011 | -1232（-4.36%） |
| LUT as Logic | 23924 | 22691 | -1233（-5.15%） |
| LUT as Memory | 4319 | 4320 | +1 |
| Distributed RAM LUT | 4160 | 4160 | 0 |
| SRL LUT | 159 | 160 | +1 |
| Slice Registers | 11489 | 11359 | -130（-1.13%） |
| Slice | 9911 | 9691 | -220（-2.22%） |
| Block RAM Tile | 553.5 | 553.5 | 0 |
| RAMB36 | 496 | 496 | 0 |
| RAMB18 | 115 | 115 | 0 |
| DSP | 0 | 0 | 0 |
| CARRY4 | 1819 | 1851 | +32（+1.76%） |

时序结果：

| 指标 | 阶段29基线 | 2026-07-25结果 | 变化 |
|---|---:|---:|---:|
| 整体WNS | +0.547 ns | +0.576 ns | +0.029 ns |
| `decoder_clk` WNS | +0.547 ns | +0.725 ns | +0.178 ns |
| hold WHS | +0.027 ns | +0.028 ns | +0.001 ns |
| pulse width WPWS | +4.232 ns | +4.232 ns | 0 |
| `o_e_rdata`无约束数据路径 | 12.743 ns | 11.388 ns | -1.355 ns |

- 最差内部路径：`v2c_tile_offset_c_reg[0][5]`到
  `u_k_sign_selector/u_ram_k_tile/g_bank[14].u_work_bram/g_distributed.o_rdata_reg[35]/D`；
- 数据路径`8.878 ns`，其中逻辑`0.309 ns`、布线`8.569 ns`，逻辑级数`2`，布线占比`96.519%`；
- 最差异步路径从复位同步器到`v2c_bypass_comp_b_reg[10][6]/PRE`，数据路径`9.135 ns`，布线占比
  `96.267%`；
- `TIMING-18`共`76`项，包含`69`个普通输入和`7`个输出未设置I/O delay；`o_e_rdata`仍不能作为板级
  接口时序签核结果。

功能、周期与验证边界：

- 本项附件只提供物理实现报告，没有增加新的RTL仿真；
- 当前RTL的功能正确性和固定周期性质沿用阶段35的五参数随机回归结果；
- 在`L=16`、`COLS_PER_TILE=1168`下，K-sign的`K`只改变记录宽度，不改变固定调度；五个参数档的固定
  周期仍为`333990`、`657341`、`2353770`、`7135995`、`16641183`；
- `K=3`的劣化判断来自已有算法/DFR探索，本项没有新增DFR定量试验，因此不补写未经本次报告验证的数值。

结论与状态：

- 通用的bank侧窄返回路由对`L=16`同样有效：逻辑LUT减少`1233`，Slice LUT减少`1232`，FF减少`130`，
  Slice减少`220`，BRAM保持`553.5 Tile`；
- `decoder_clk`裕量达到`+0.725 ns`；当前主要限制是低逻辑级数、强布线主导的局部K-sign RAM路径；
- 当前RTL结构保留，`L=16`、`K=4`的2026-07-25结果作为新的完整实现检查点；
- `K=3`实现和已有结果保留，用于兼容、回归和复现实验，不作为后续主要架构优化方向；后续默认以`K=4`
  评估资源、时序与算法效果；
- 状态：**L=16、K=4检查点保留；K=3结果保留并转为参考方向**。

## 38. L=16、K=4全局K记录的双位置18-bit字段映射

时间：2026-07-25。

目标与假设：阶段32的双位置18-bit字段只在`L=32 && K=4 && DIAG_IDX_W=7`时启用。`L=16`统一参数下，
`ram_k_global`的bank深度为`ceil(325761/16)=20361`；独立字段结构中，四个7-bit位置各使用5个
`4K × 9` RAMB36段，另有一个1-bit全深度base-sign RAMB36，即每bank 21个、16个bank共336个
RAMB36。实验目标是在不改变29-bit逻辑记录、端口和固定调度的前提下，把已验证的18-bit配对映射推广到
`L=16`，消除独立base-sign存储。

关键实现：

- `USE_K4_PAIR_FIELDS`的启用条件扩展为`(L == 16 || L == 32) && K_SIGN_K == 4 &&
  DIAG_IDX_W == 7`；
- field 0保存`{base_sign, dev_pos[1], dev_pos[0]}`共15 bit，field 1保存
  `{dev_pos[3], dev_pos[2]}`共14 bit，两个物理字段宽度均为18 bit；
- `L=16`时每个字段按2048深度切成`ceil(20361/2048)=10`段，每bank共20个RAMB36，16个bank的
  静态目标为320个RAMB36；
- 逻辑记录格式、写地址/valid/数据寄存边界、同步读segment对齐、bank侧符号重构、严格大于替换规则、
  invalid sentinel和固定周期均保持不变；
- `L=32`配对路径及其他参数的通用独立字段路径保持原有启用范围。

验证结果：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`通过；
- `make test`通过14个单元测试和toy集成，toy case为residual 0、exact 1、固定154周期；
- `TRIKE_UNIFIED_PARAMS`、`L=16`、`K=4`、`COLS_PER_TILE=1168`、seed 1五档随机回归全部通过：

| profile | 固定周期 | 结果 |
| --- | ---: | --- |
| TRIKE-128 | 333,990 | residual 0，exact 1 |
| TRIKE-160 | 657,341 | residual 0，exact 1 |
| TRIKE-256 | 2,353,770 | residual 0，exact 1 |
| TRIKE-384 | 7,135,995 | residual 0，exact 1 |
| TRIKE-512 | 16,641,183 | residual 0，exact 1 |

Vivado实现条件：Windows Vivado 2023.2，`xc7k355tffg901-2L`，`TRIKE_UNIFIED_PARAMS`，`L=16`，
`K=4`，`COLS_PER_TILE=1168`，100 MHz `decoder_clk`、10 ns周期、0.100 ns user uncertainty；
资源报告为2026-07-25 16:03:20 Fully Placed aggregate utilization，时序报告为2026-07-25
16:05:59 Routed。与阶段37未配对结果的器件、工具、参数、XDC和报告阶段一致。

资源实测：

| 资源 | 阶段37未配对 | 18-bit配对 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 27,011 | 28,174 | +1,163（+4.31%） |
| LUT as Logic | 22,691 | 23,854 | +1,163（+5.13%） |
| LUT as Memory | 4,320 | 4,320 | 0 |
| Distributed RAM LUT | 4,160 | 4,160 | 0 |
| SRL LUT | 160 | 160 | 0 |
| Slice Register | 11,359 | 11,370 | +11（+0.10%） |
| Slice | 9,691 | 10,001 | +310（+3.20%） |
| Block RAM Tile | 553.5 | 537.5 | -16（-2.89%） |
| RAMB36E1 | 496 | 480 | -16（-3.23%） |
| RAMB18E1 | 115 | 115 | 0 |
| DSP | 0 | 0 | 0 |
| CARRY4 | 1,851 | 1,851 | 0 |

BRAM结果精确命中静态预测：`ram_k_global`的16个bank各删除一个独立base-sign RAMB36，全设计减少
16个RAMB36和16个Block RAM Tile，Tile利用率从77.41%降到75.17%。LUT memory、distributed RAM和
SRL完全不变，说明没有用LUTRAM替代BRAM；代价集中在配对字段分段选择和控制形成的1,163个logic LUT，
同时增加11个FF和310个Slice。

Routed时序实测：

| 指标 | 阶段37未配对 | 18-bit配对 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.576 / 0.000 ns | +0.537 / 0.000 ns | WNS -0.039 ns |
| `decoder_clk` setup WNS/TNS | +0.725 / 0.000 ns | +0.537 / 0.000 ns | WNS -0.188 ns |
| hold WHS/THS | +0.028 / 0.000 ns | +0.024 / 0.000 ns | WHS -0.004 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| `**async_default**` setup WNS | +0.576 ns | +0.778 ns | +0.202 ns |
| `o_e_rdata`未约束输出路径 | 11.388 ns | 14.243 ns | +2.855 ns |

- 最差主时钟路径从`ram_t` buffer 1、bank 5的RAMB18读口到
  `u_vnu/v2c_scaled_q_reg[15][17]/D`，数据路径8.811 ns，其中logic 3.103 ns、route 5.708 ns，
  route占64.781%，逻辑深度11级；
- 全局K配对RAM没有进入前十条主时钟setup路径，10段字段选择没有成为内部100 MHz瓶颈；
- 最差异步路径从`u_reset_sync/rst_sync_n_reg`到K-sign selector bank 13的读地址寄存器CLR端，数据
  路径8.723 ns，其中route 8.419 ns、占96.515%；
- `o_e_rdata`路径从配对field 0、segment 7的RAMB36经过segment和bank选择到输出，逻辑深度7级，
  数据路径14.243 ns，其中logic 4.673 ns、route 9.570 ns。该端口没有output delay约束，不能作为板级
  同步接口签核结果；相对阶段37的增长表明配对后的深segment选择明显增加最终判决读出路径。

TIMING-18仍为76项，内部未约束endpoint为0；69个普通输入和7个输出缺少I/O delay，另有1个输入由
false path覆盖。所有已定义内部100 MHz setup、hold和pulse width约束满足。

结论与状态：L=16、K=4的18-bit配对在功能、固定周期和内部100 MHz不变的条件下，实测减少16个
RAMB36/Block RAM Tile，代价为增加1,163个LUT、11个FF和310个Slice，`decoder_clk` WNS降低
0.188 ns但仍为正。该方案是明确的BRAM换LUT折中，而不是全资源维度同时下降；当前RTL保留，是否作为
L=16最终配置应根据BRAM容量优先级决定。未约束`o_e_rdata`路径增长到14.243 ns，板级输出接口需要补充
约束或输出寄存器后再签核。

## 39. 按并行度选择原生宽深几何的全局K RAM整体映射

时间：2026-07-25。

目标与方案选择：阶段38把L=32的双18-bit字段直接推广到L=16，虽然精确减少16个BRAM Tile，但增加
1,163个logic LUT和310个Slice。根因不是18-bit打包本身，而是L=16的bank深度20,361需要每个18-bit
字段切成10个`2K × 18`段；两个字段共20个RAMB36，读出端需要10段选择。L=16也可以用四个
`4K × 9`字段实现相同的20个RAMB36/bank，其中field 0打包base sign和slot 0，其余三个字段各保存一个
位置；该组织把segment数量从10降到5，不牺牲阶段38已经得到的BRAM容量。

本项把`ram_k_global`重构为按并行度选择原生宽深几何的统一映射：

| 配置 | 字段组织 | 单字段段数 | RAMB36/bank | 全局K RAMB36 |
| --- | --- | ---: | ---: | ---: |
| `L=16, K=4` | 4个`4K × 9`字段 | 5 | 20 | 320 |
| `L=32, K=4` | 2个`2K × 18`字段 | 5 | 10 | 320 |
| 其他配置 | 独立base sign和位置字段 | 参数化 | 参数化 | 参数化 |

关键实现：

- 统一使用`USE_K4_PACKED_FIELDS`选择K=4打包路径，`USE_K4_NARROW_PACK_FIELDS`在L=16时选择9-bit
  字段、12-bit段内地址和4096深度，在L=32时选择18-bit字段、11-bit段内地址和2048深度；
- L=16 field 0保存`{base_sign, dev_pos[0]}`，field 1至3分别保存`dev_pos[1..3]`；
- L=32继续使用`{base_sign, dev_pos[1], dev_pos[0]}`和`{dev_pos[3], dev_pos[2]}`两个字段；
- 打包函数使用固定18-bit中间值，再按当前物理字段宽度显式截取，避免未激活宽字段分支在L=16编译时
  产生越界选择；
- RAM实例化、segment选择和字段恢复由同一参数化generate结构生成；逻辑记录格式、写回流水、bank侧
  符号重构、窄返回路由、固定访存次数和译码周期不变。

方案依据与预期：

- 阶段11曾在L=16、K=3下实测`base_sign + slot 0`的9-bit打包只增加41个LUT、减少5个FF，同时减少
  16个RAMB36；该历史结果只能作为结构依据，不能直接预测当前K=4绝对资源；
- 相对阶段38，静态RAMB36实例数保持480、RAMB18保持115、Block RAM Tile目标保持537.5；
- 物理目标是显著回收阶段38新增的1,163个logic LUT，并缩短由10段选择造成的14.243 ns未约束
  `o_e_rdata`路径；实际LUT、Slice和时序必须由同条件Vivado报告确认。

验证结果：

- 初版函数在L=16编译时对未激活18-bit分支产生`SELRANGE`告警；在TRIKE-128功能通过后主动停止剩余
  回归，改为固定18-bit中间值和显式字段宽度截取，告警消除；
- 最终代码通过`make format-rtl`、`make check-format-rtl`和`make lint-rtl`；
- `make test`通过14个单元测试和toy集成，toy case为residual 0、exact 1、固定154周期；
- `L=16`、`K=4`、`COLS_PER_TILE=1168`统一TRIKE五档seed 1回归全部residual 0、exact 1，周期为
  333,990、657,341、2,353,770、7,135,995和16,641,183；
- `L=32`、`K=4`、`COLS_PER_TILE=1152`统一TRIKE五档seed 1回归全部residual 0、exact 1，周期为
  193,486、365,945、1,207,716、3,729,550和8,720,781；

Vivado实现条件：Windows Vivado 2023.2，`xc7k355tffg901-2L`，`TRIKE_UNIFIED_PARAMS`，`L=16`，
`K=4`，`COLS_PER_TILE=1168`，100 MHz `decoder_clk`、10 ns周期、0.100 ns user uncertainty；
资源报告为2026-07-25 16:40:35 Fully Placed aggregate utilization，时序报告为2026-07-25
16:43:10 Routed。阶段37、38、39的器件、工具、参数、XDC和报告阶段一致。

三方案资源实测：

| 资源 | 阶段37独立字段 | 阶段38双18-bit字段 | 阶段39四9-bit字段 |
| --- | ---: | ---: | ---: |
| Slice LUT | 27,011 | 28,174 | 27,059 |
| LUT as Logic | 22,691 | 23,854 | 22,739 |
| LUT as Memory | 4,320 | 4,320 | 4,320 |
| Distributed RAM LUT | 4,160 | 4,160 | 4,160 |
| SRL LUT | 160 | 160 | 160 |
| Slice Register | 11,359 | 11,370 | 11,359 |
| Slice | 9,691 | 10,001 | 9,672 |
| Block RAM Tile | 553.5 | 537.5 | 537.5 |
| RAMB36E1 | 496 | 480 | 480 |
| RAMB18E1 | 115 | 115 | 115 |
| DSP | 0 | 0 | 0 |
| CARRY4 | 1,851 | 1,851 | 1,851 |

相对阶段38，四9-bit字段减少1,115个Slice LUT和logic LUT、11个FF、329个Slice，BRAM保持不变；
回收了双18-bit字段新增1,163个LUT中的95.87%。相对阶段37独立字段，仅增加48个LUT，FF完全相同，
Slice反而减少19，同时保留16个RAMB36/Block RAM Tile收益。LUT memory、distributed RAM和SRL均不变，
确认该收益来自segment选择结构缩小，不是把BRAM转移到LUTRAM。

三方案Routed时序：

| 指标 | 阶段37独立字段 | 阶段38双18-bit字段 | 阶段39四9-bit字段 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.576 / 0.000 ns | +0.537 / 0.000 ns | +0.437 / 0.000 ns |
| `decoder_clk` setup WNS/TNS | +0.725 / 0.000 ns | +0.537 / 0.000 ns | +0.656 / 0.000 ns |
| hold WHS/THS | +0.028 / 0.000 ns | +0.024 / 0.000 ns | +0.040 / 0.000 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | +4.232 / 0.000 ns |
| `**async_default**` setup WNS | +0.576 ns | +0.778 ns | +0.437 ns |
| `o_e_rdata`未约束输出路径 | 11.388 ns | 14.243 ns | 12.869 ns |

- 阶段39最差主时钟路径从K-sign selector bank 0的`diag_idx_local_q_reg[0][4]`到bank 13 snapshot
  distributed RAM写入口，数据路径8.846 ns，其中logic 1.103 ns、route 7.743 ns，route占87.531%，
  逻辑深度12级；全局K RAM没有进入前十条主时钟setup路径；
- 最差异步路径从`u_reset_sync/rst_sync_n_reg`到
  `ram_k_global/pack_read_segment_idx_q_reg[3][0]/CLR`，数据路径8.973 ns，其中route 8.606 ns、
  占95.910%，整体WNS由该异步复位恢复路径限制；
- `o_e_rdata`从阶段38的14.243 ns降至12.869 ns，改善1.374 ns；其路径从field 0、segment 2的
  RAMB36经过5段选择和bank返回到输出，逻辑深度6级。该路径仍未设置output delay，不能作为板级同步
  接口签核结果。

TIMING-18仍为76项，内部未约束endpoint为0；69个普通输入和7个输出缺少I/O delay，另有1个输入由
false path覆盖。所有已定义内部100 MHz setup、hold和pulse width约束满足。

保留标准全部满足：

- `480 RAMB36 + 115 RAMB18 = 537.5 Tile`，容量与阶段38等价；
- Slice LUT为27,059，显著低于阶段38的28,174，并接近阶段37的27,011；
- `decoder_clk` WNS为+0.656 ns，setup/hold通过，全局K RAM未进入前十条关键路径；
- `o_e_rdata`相对阶段38缩短1.374 ns。

结论与状态：按并行度选择9/18-bit原生几何的方案保留为当前L=16/L=32统一实现。L=16四9-bit字段在
固定周期、功能和内部100 MHz不变的条件下，获得与双18-bit字段相同的16 Tile收益，同时基本消除其LUT和
Slice代价；相对独立字段只增加48个LUT并减少19个Slice，是当前三种L=16全局K RAM映射中的综合最优方案。
整体WNS受异步复位恢复布线限制，但仍满足约束；板级输出时序仍需单独签核。

## 40. K=4、L=16/L=32下一阶段架构联合优化审计

时间：2026-07-26。

目标与范围：在阶段36的L=32完整实现和阶段39的L=16完整实现基础上，审计K=4译码器是否仍存在不改变
算法语义和固定时间性质的资源/时序优化空间，并把允许周期变化的候选统一换算为
`固定周期 / 可实现频率`。本阶段只完成RTL、调度、RAM原生几何和既有Vivado报告的静态分析，没有修改
RTL；候选资源数为原语几何目标或RTL网络规模，不是新的Fully Placed/Routed实测结果。

当前可比基线：

| 指标 | `L=16, C=1168` | `L=32, C=1152` | `L=32`相对`L=16` |
| --- | ---: | ---: | ---: |
| Slice LUT | 27,059 | 48,027 | +20,968（+77.49%） |
| Slice Register | 11,359 | 20,946 | +9,587（+84.40%） |
| Slice | 9,672 | 16,053 | +6,381（+65.97%） |
| Block RAM Tile | 537.5 | 561.5 | +24.0（+4.47%） |
| RAMB36E1 / RAMB18E1 | 480 / 115 | 512 / 99 | +32 / -16 |
| `decoder_clk` WNS | +0.656 ns | +0.590 ns | -0.066 ns |
| TRIKE-512固定周期 | 16,641,183 | 8,720,781 | -47.60% |
| TRIKE-512@100 MHz | 166.41183 ms | 87.20781 ms | -47.60% |

两份报告使用Windows Vivado 2023.2、`xc7k355tffg901-2L`、100 MHz和0.100 ns user uncertainty；
参数中的`L`与`COLS_PER_TILE`按比较目的不同。按`10 ns - decoder_clk WNS`只作一阶频率外推时，两者
分别约107.02 MHz和106.27 MHz；该外推不是新的时序签核。L=16若要在L=32保持100 MHz时达到同一
TRIKE-512延时，需要约190.82 MHz，现有报告没有支持这种频率差。因此L=32仍是当前高吞吐主配置；
L=16适合作为LUT/FF受限配置。

### 候选A：tile-local公共bank地址与旋转payload收窄

`edge_addr_gen`对每个固定lane group生成：

```text
tile_offset = lane_group_idx_eff * L + lane_idx
floor(tile_offset / L) = lane_group_idx_eff
```

该等式在普通group和模`R`回绕的pre/post拆分micro-cycle中都成立；拆分的两拍使用同一个
`lane_group_idx_eff`。因此同一拍内以下bank-local地址对所有lane相同：

- `ram_accum.offset_addr = floor(tile_offset/L)`；
- `ram_t.t_addr = diag_idx_local * Q_BASE + floor(tile_offset/L)`；
- `k_sign_selector.work_addr = floor(tile_offset/L)`，包括主selector和correction snapshot读。

当前RTL仍把这些公共地址作为每lane payload送入前向`barrel_rotate`。候选实现只旋转valid、bank相关数据
和必须保持lane关联的元数据；公共地址计算一次后广播到目标bank，并允许综合器在bank/cluster附近复制地址
寄存器。先只修改`k_sign_selector`，再分别扩展到`ram_t`和`ram_accum`，以保留物理归因和回退点。

按`DATA_W × L × log2(L)`计算被删除的1-bit 2:1 MUX节点，不把节点数等同于物理LUT：

| 模块中的地址payload | `L=16` | `L=32` |
| --- | ---: | ---: |
| `k_sign_selector`主读+correction读 | 896 | 1,920 |
| `ram_accum`三条前向地址路由 | 1,344 | 2,880 |
| `ram_t`读+写地址路由 | 1,664 | 3,840 |
| 合计 | 3,904 | 8,640 |

`ram_t`还可把当前每lane重复的`diag_idx_local * Q_BASE + group_addr`显式收敛为一份公共地址算术。该候选
不改变RAM深度、读写次数、同步读延迟、候选tie规则、有效写次数或固定周期。阶段36的L=32最差路径正是
`v2c_tile_offset_c`到K-sign工作distributed RAM输出寄存器，数据路径9.303 ns、route占97.141%，因此
候选A是最直接的下一项时序实验。实际LUT、FF、Slice、fanout和WNS全部待同条件Vivado确认。

### 候选B：三个9-bit字段的精确27-bit K位置编码

当前K=4全局逻辑记录为`base_sign + 4*7 = 29 bit`。完整组合数rank可把最多4个有效位置压到23 bit，
但复杂的rank/unrank没有比三个9-bit字段带来更多物理BRAM收益。更适合当前RAM原生几何的精确编码为：

1. 把四个位置连同`K_SIGN_DIAG_INVALID=127`按数值排序；
2. 每个7-bit位置拆成`group=pos[6:5]`和`low=pos[4:0]`；
3. 四个非降序2-bit group是从4类中取4项的多重组合，共
   `C(4+4-1,4)=35`种，用6 bit编码；
4. 保存四个5-bit low、6-bit group code和base sign，总宽度为
   `4*5 + 6 + 1 = 27 bit`。

最大合法位置为110；127只表示invalid，同一group内按完整位置排序后可以无损恢复四个位置。全局记录的槽
顺序不参与Top-K tie-break或C2V命中语义，因此编码/解码完全等价时不会改变DFR语义、correction snapshot
或固定周期。工作记录和snapshot保持当前45/28 bit；编码只放在`ram_k_global`物理写入/读出边界。

三个9-bit字段的静态物理目标：

| 配置 | 当前全局K RAM | 27-bit目标 | 全设计Block RAM Tile静态目标 |
| --- | ---: | ---: | ---: |
| `L=16`，bank深20,361 | 320 RAMB36 | 240 RAMB36 | 537.5 -> 457.5（-80） |
| `L=32`，bank深10,181 | 320 RAMB36 | 288 RAMB36 | 561.5 -> 529.5（-32） |

编码端需要固定4项排序和35态映射，解码端需要6-to-8 bit group恢复；增加的logic LUT、对bank侧命中路径和
`o_e_rdata`路径的影响待实现。保留标准是encode/decode逐项等价、K=4五档固定周期回归通过，并在
Fully Placed/Routed后确认RAMB36目标兑现且`decoder_clk` WNS不下降到影响总延时。若`W_MAX >= 128`，
当前invalid哨兵和本编码都必须重新设计。

### 候选C：L=32 tile大小与BRAM边界联合扫描

当前固定周期公式为：

```text
Q_TILE   = ceil(C/L) + 3
T_ITER   = ceil(R/L) + (N0*ceil(R/C)+1)*W*Q_TILE + 8 + W*Q_TILE
T_DECODE = I_MAX*T_ITER + 6
```

对统一TRIKE五档扫描`C`为32的整数倍后，`L=16,C=1168`不存在一个同时不增加五档周期且至少一档更快的
单一tile大小，属于当前公式下的多等级Pareto点。`L=32,C=1152`不是Pareto点；若允许`ram_t`每个
buffer/bank从一个RAMB36增加为一个RAMB36加一个RAMB18，以下点值得验证：

| 配置 | `Q_BASE/Q_TILE` | TRIKE五档固定周期 | TRIKE-512变化 |
| --- | --- | --- | ---: |
| 当前`L=32,C=1152` | 36 / 39 | 193,486 / 365,945 / 1,207,716 / 3,729,550 / 8,720,781 | 基线 |
| `L=32,C=1664` | 52 / 55 | 178,555 / 353,205 / 1,192,316 / 3,624,389 / 8,570,820 | -149,961（-1.72%） |
| `L=32,C=1728` | 54 / 57 | 184,981 / 365,945 / 1,235,436 / 3,656,344 / 8,483,019 | -237,762（-2.73%） |

`C=1664`同时改善五档周期，适合作为统一硬件首选扫描点；`C=1728`更偏向最大等级，TRIKE-256周期增加。
两者的`Q_BASE <= 64`，`ram_k_tile`和`ram_accum`仍处于同一64-deep distributed RAM原生深度档；
`ram_t`最大bank深度从3,996增至5,772或5,994，静态增加64个RAMB18，即32个Block RAM Tile。
`C=1664`的TRIKE-512周期收益允许频率相对当前下降最多1.72%而不劣化总延时；`C=1728`对应2.73%。

候选B在L=32静态节省32个Tile，候选C恰好增加32个Tile。因此先验证27-bit编码、再验证
`C=1664`，理论上可在全设计仍为561.5 Tile的条件下把TRIKE-512周期降到8,570,820；预计RAMB36/RAMB18
构成变为480/163，实际映射、LUT、布局拥塞和频率必须由Vivado确认。候选A应先完成，以抵消更大`ram_t`
地址宽度和布局范围带来的时序风险。

### 候选D：把每diag重复guard压成连续流

当前每个diag执行`Q_BASE+3`个group。跨模拆分最坏需要`Q_BASE+1`个micro-cycle，另外两拍用于固定输入/
写回对齐。高风险候选是在diag之间连续传递完整tag，只保留每diag的一拍拆分预算，并把流水排空集中到
tile边界：

```text
T_WINDOW_candidate = W*(Q_BASE+1) + TILE_DRAIN
```

若静态估算`TILE_DRAIN=2`，L=32、C=1152、TRIKE-512可从8,720,781拍降到约8,278,801拍，
减少约5.07%；即使频率下降约5.07%，总延时仍可持平。该数字只是调度上界估算，不是已实现周期。

实现前必须逐项证明跨diag和tile边界的`ram_accum`读改写、`ram_t`fill/active切换、`ram_m`连续同row
bypass、K-sign work RAM读改写、最后diag snapshot提交、correction read-first重叠、`ram_sign_delta`
连续flip旁路及最后tile排空均保持等价。主调度器和correction调度器都必须使用同一新的固定窗口定义。
该候选不属于layered Min-Sum，不能改变同一迭代的消息反馈语义。状态为高收益、高验证成本的后续原型，
排在候选A至C之后。

### 时序兜底与不优先方向

- 若候选A后L=32关键路径仍停留在K-sign work distributed RAM，可只把45-bit work RAM切到block RAM；
  静态代价约32个Block RAM Tile。L=16若关键路径保持在28-bit snapshot写入口，可单独测试snapshot
  block RAM，静态代价约16个RAMB18，即8个Tile。两者同步读语义由`ram_bram`保持，但LUT节省和时序收益
  必须实测，不能把逻辑bit数换算为LUT。
- L=16的最差路径跨bank使用等价的`diag_idx_local_q`寄存器。若Vivado合并bank-local副本，可在不增加
  周期的条件下测试显式cluster级寄存器复制或`MAX_FANOUT`约束；先比较top-path和FF增量，再决定是否保留。
- 进一步折叠32-lane Top-K/CNU/VNU会让V2C吞吐下降到接近L=16；当前L=16与L=32频率接近，频率收益没有
  足够余量抵消约1.91倍的周期比，不作为低延时方向。
- `ram_m` 9+9拆分已经实测增加Block RAM Tile并撤回；完整组合数position rank在当前三9-bit物理目标下
  不比27-bit分组编码少用BRAM；这两项不重复探索。
- 真正row/block-layered Min-Sum需要posterior RAM、旧C2V删除、同迭代反馈和固定冲突归并，并会使当前
  K-sign base/Top-K生命周期失效。它属于算法与架构联合研究，不是当前资源/时序小步优化。

结论与状态：

1. 当前L=32以77.49% LUT和84.40% FF增量换取47.60%固定周期下降，BRAM只增加4.47%，且主时钟频率
   与L=16接近；在器件容量允许时继续以L=32作为性能主线。
2. 下一步优先实现候选A的`k_sign_selector`公共地址收窄，形成独立功能/Vivado检查点；随后把同一不变量
   扩展到`ram_t`和`ram_accum`。
3. 资源主线验证候选B的精确27-bit物理编码；通过后用释放的32个L=32 Tile验证`C=1664`联合点。
4. 候选D可能提供约5%周期收益，但需要调度和所有RAM边界的系统验证，放在无周期变化的候选之后。
5. 本阶段状态为**架构审计完成，候选A至D均待实现/待功能回归/待Vivado**；没有产生新的资源或时序实测
   基线。

## 41. K-sign selector公共bank地址与旋转payload收窄

时间：2026-07-26。

目标与假设：实施阶段40的候选A第一步，消除`k_sign_selector`主工作RAM读和correction snapshot读前向
旋转网络中逐lane重复的bank-local地址。调度器生成
`tile_offset = lane_group_idx_eff * L + lane_idx`，因此同一micro-cycle内所有有效lane均满足
`work_addr = floor(tile_offset/L) = lane_group_idx_eff`。该不变量对普通group和回绕pre/post拆分拍均
成立。

关键实现：

- 主路径`ROUTE_W`删除`K_SIGN_WORK_AW`地址字段，只旋转valid、`col_idx`、V2C消息和base sign；
- correction前向`barrel_rotate`从`1+K_SIGN_WORK_AW` bit缩为只旋转1-bit valid；
- 主路径和correction分别从lane 0计算一份公共`work_addr`，广播到所有目标bank；
- 添加`ifndef SYNTHESIS`保护的时钟沿检查：任一有效lane若与公共地址不一致，仿真立即失败；
- `ram_k_tile`深度、数据宽度、同步读延迟、read-first行为、读写次数、Top-K tie规则、snapshot内容、
  correction扫描和调度状态机均未改变。

结构规模：L=16/C=1168时`K_SIGN_WORK_AW=7`，两条前向网络合计删除
`2*7*16*log2(16)=896`个1-bit 2:1 mux节点；L=32/C=1152时`K_SIGN_WORK_AW=6`，合计删除
`2*6*32*log2(32)=1,920`个节点。节点数只描述RTL旋转网络规模，不等同于物理LUT。

验证范围与结果：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`通过；
- 标准`make test-unit`的14项单元测试全部通过；toy `make test-integration`通过，
  `residual=0`、`exact=1`、固定周期154；
- `tb_k_sign_update`增加`Q_BASE>1`条件下的非零group、非零bank旋转覆盖；toy L=4定向编译运行通过；
- 尝试运行完整toy L=4单元套件时，既有`tb_tile_scheduler`在clear address range断言处失败；
  失败发生在K-sign单测之前，属于该非标准toy并行度的独立测试假设，因此改为定向运行
  `tb_k_sign_update`完成本结构覆盖；
- `L=16`、`K=4`、`COLS_PER_TILE=1168`统一TRIKE五档seed 1均
  `residual=0`、`exact=1`，固定周期为333,990、657,341、2,353,770、7,135,995和16,641,183；
- `L=32`、`K=4`、`COLS_PER_TILE=1152`统一TRIKE五档seed 1均
  `residual=0`、`exact=1`，固定周期为193,486、365,945、1,207,716、3,729,550和8,720,781；
- 两组完整调度均未触发公共地址不变量检查。

周期：RTL没有新增流水级或调度拍，两组固定周期逐项保持参考基线。L=16、TRIKE-512在100 MHz下仍为
166.41183 ms。

L=16 Vivado物理复测：用户提供的报告使用Windows Vivado 2023.2、`xc7k355tffg901-2L`、
`TRIKE_UNIFIED_PARAMS`、`L=16`、K=4、`COLS_PER_TILE=1168`、100 MHz和相同XDC；资源报告时间为
2026-07-26 13:36:18、Design State为Fully Placed，时序报告时间为13:39:04、Design State为Routed。
与阶段39公共地址实施前的四9-bit字段基线可直接比较。

| 资源 | 阶段39基线 | 公共地址配置 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 27,059 | 27,104 | +45（+0.17%） |
| LUT as Logic | 22,739 | 22,784 | +45 |
| LUT as Memory | 4,320 | 4,320 | 0 |
| Distributed RAM LUT / SRL LUT | 4,160 / 160 | 4,160 / 160 | 0 / 0 |
| Slice Register | 11,359 | 11,372 | +13（+0.11%） |
| Slice | 9,672 | 9,632 | -40（-0.41%） |
| Block RAM Tile | 537.5 | 537.5 | 0 |
| RAMB36E1 / RAMB18E1 | 480 / 115 | 480 / 115 | 0 / 0 |
| DSP / CARRY4 | 0 / 1,851 | 0 / 1,851 | 0 / 0 |

资源结论是基本中性：删除896个RTL mux节点没有转化为aggregate LUT下降，LUT增加45、FF增加13，但Slice
减少40且所有存储资源完全不变。没有同次hierarchical utilization报告，不能把45 LUT和13 FF的变化精确
归因到单个模块。

| 时序指标 | 阶段39基线 | 公共地址配置 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.437 / 0.000 ns | +0.608 / 0.000 ns | +0.171 ns |
| `decoder_clk` setup WNS/TNS | +0.656 / 0.000 ns | +0.794 / 0.000 ns | +0.138 ns |
| hold WHS/THS | +0.040 / 0.000 ns | +0.037 / 0.000 ns | -0.003 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| `**async_default**` setup WNS | +0.437 ns | +0.608 ns | +0.171 ns |
| `o_e_rdata`未约束输出路径 | 12.869 ns | 14.651 ns | +1.782 ns |

阶段39的最差主路径从K-sign selector的`diag_idx_local_q`到snapshot distributed RAM写入口，数据路径
8.846 ns、route占87.531%。公共地址配置的前十条主时钟setup路径均转移为`ram_t` BRAM读口到VNU
`v2c_scaled_q`寄存器；最差路径数据延迟8.519 ns，其中logic 3.228 ns、route 5.291 ns、route占
62.109%，逻辑深度13级。K-sign工作RAM和snapshot路径均未进入前十条，说明目标瓶颈已经被切断。

最差异步路径从复位同步器到`ram_t` buffer 0、bank 5的`bank_read_valid_q` CLR端，数据路径9.293 ns，
route占96.051%。内部未约束endpoint为0；TIMING-18仍为76项，69个普通输入和7个输出缺少I/O delay，
另有1个输入由false path覆盖。未约束`o_e_rdata`退化1.782 ns，不能作为板级同步接口签核；若接口要求
一拍100 MHz输出，应添加真实output delay约束或输出寄存器后重新实现。

按`10 ns - decoder_clk WNS`作一阶频率外推，阶段39与公共地址配置分别约107.02 MHz和108.62 MHz；
TRIKE-512固定周期对应155.495 ms和153.199 ms，外推总延时改善约1.48%。该计算不是新的Fmax签核，也
没有覆盖多实现seed；在已签核100 MHz下固定延时保持166.41183 ms。

L=32 Vivado物理复测：用户提供的报告使用Windows Vivado 2023.2、`xc7k355tffg901-2L`、
`TRIKE_UNIFIED_PARAMS`、`L=32`、K=4、`COLS_PER_TILE=1152`、100 MHz和相同XDC；资源报告时间为
2026-07-26 21:08:47、Design State为Fully Placed，时序报告时间为21:13:12、Design State为Routed。
与阶段36的L=32/C=1152基线可直接比较。

| 资源 | 阶段36基线 | 公共地址配置 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 48,027 | 47,104 | -923（-1.92%） |
| LUT as Logic | 43,580 | 42,656 | -924（-2.12%） |
| LUT as Memory | 4,447 | 4,448 | +1 |
| Distributed RAM LUT / SRL LUT | 4,160 / 287 | 4,160 / 288 | 0 / +1 |
| Slice Register | 20,946 | 20,811 | -135（-0.64%） |
| Slice | 16,053 | 15,957 | -96（-0.60%） |
| Block RAM Tile | 561.5 | 561.5 | 0 |
| RAMB36E1 / RAMB18E1 | 512 / 99 | 512 / 99 | 0 / 0 |
| DSP / CARRY4 | 0 / 2,998 | 0 / 2,998 | 0 / 0 |

L=32的资源收益明确：aggregate LUT减少923、FF减少135、Slice减少96，BRAM和DSP完全不变。LUT memory
的+1由SRL变化构成，distributed RAM保持4,160。虽然没有同次hierarchical utilization报告，但变化方向
与删除1,920个RTL mux节点一致。

| 时序指标 | 阶段36基线 | 公共地址配置 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.590 / 0.000 ns | +0.505 / 0.000 ns | -0.085 ns |
| `decoder_clk` setup WNS/TNS | +0.590 / 0.000 ns | +0.505 / 0.000 ns | -0.085 ns |
| hold WHS/THS | +0.027 / 0.000 ns | +0.030 / 0.000 ns | +0.003 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| `**async_default**` setup WNS | +3.239 ns | +3.594 ns | +0.355 ns |
| `o_e_rdata`未约束输出路径 | 14.515 ns | 13.694 ns | -0.821 ns |

阶段36最差主路径从`v2c_tile_offset_c_reg[27][10]`到K-sign selector bank 29工作distributed RAM读数据
寄存器，数据路径9.303 ns、route占97.141%。公共地址配置中该路径和snapshot路径均退出前十条。
新的最差主路径从`ram_k_global` bank 7、field 0、segment 0的RAMB36读口到
`c2v_ksign_sign_q_reg[28]`，数据路径8.834 ns，其中logic 2.144 ns、route 6.690 ns、route占
75.730%，逻辑深度8级。前十条由八条全局K RAM读回路径和两条`ram_t`到VNU路径组成。

最差异步路径从复位同步器到`old_c2v_sum_c_reg[19][4]` CLR端，数据路径6.162 ns、route占94.466%。
内部未约束endpoint为0；TIMING-18仍为76项，69个普通输入和7个输出缺少I/O delay，另有1个输入由
false path覆盖。未约束`o_e_rdata`改善0.821 ns，但仍不能作为板级同步接口签核。

按`10 ns - decoder_clk WNS`作一阶频率外推，阶段36与公共地址配置分别约106.27 MHz和105.32 MHz；
TRIKE-512固定周期对应82.063 ms和82.804 ms，外推总延时增加约0.90%。该计算不是新的Fmax签核，也
没有覆盖多实现seed；在已签核100 MHz下固定延时保持87.20781 ms。

结论与状态：L=16和L=32公共地址收窄均保留。L=16资源基本中性且`decoder_clk` WNS提高0.138 ns；
L=32减少923 LUT、135 FF和96 Slice，代价是`decoder_clk` WNS下降0.085 ns，一阶外推总延时增加
约0.90%。两种并行度的目标K-sign tile地址路径均退出前十条，固定周期、功能、BRAM、setup、hold和
pulse width均通过。该独立物理检查点完成；`ram_t`和`ram_accum`的公共地址收窄应作为新的独立实验，
分别复测资源、关键路径和`固定周期/Fmax`，避免与本结果混合归因。

## 42. ram_t公共读写地址与旋转payload收窄

时间：2026-07-26。

目标与假设：在阶段41完成K-sign selector双并行度物理检查点后，独立实施阶段40候选A的第二步。
`ram_t`的读写对角线索引分别是标量输入，同一lane group内
`floor(tile_offset/L)=lane_group_idx_eff`，因此：

```text
t_addr = diag_idx_local * Q_BASE + floor(tile_offset/L)
```

在同一读micro-cycle或写micro-cycle内对所有有效lane相同。地址不需要随lane-to-bank请求旋转。

关键实现：

- 读前向`barrel_rotate`从`1+T_ADDR_W` bit缩为只旋转1-bit valid；
- 写前向`barrel_rotate`从`1+T_ADDR_W+MSG_W` bit缩为只旋转valid和`MSG_W`位消息；
- 读写两侧分别只计算一份完整`t_addr`，直接广播到两个buffer的所有bank；
- fill/active buffer选择、bank映射、返回逆旋转、RAM深度、同步读延迟、read-first语义和valid流水不变；
- 在`ifndef SYNTHESIS`保护下检查地址范围和公共地址不变量，任一有效lane不满足条件即仿真失败。

结构规模：

| 配置 | `T_ADDR_W` | 读路由宽度 | 写路由宽度 | 删除的1-bit 2:1 mux节点 |
| --- | ---: | ---: | ---: | ---: |
| `L=16, C=1168` | 13 | 14 -> 1 | 19 -> 6 | `2*13*16*4 = 1,664` |
| `L=32, C=1152` | 12 | 13 -> 1 | 18 -> 6 | `2*12*32*5 = 3,840` |

地址算术也从读写各L份收敛为各一份。节点数和表达式份数只描述RTL结构，不等同于物理LUT、FF或时序收益。

验证范围与结果：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`通过；
- 标准`make test-unit`的14项单元测试全部通过；
- toy `L=4`定向`tb_ram_t`通过，覆盖非零group、`Q_BASE-1`最大group、非零旋转、不同diag和双buffer；
- `make test-integration`通过，`residual=0`、`exact=1`、固定周期154；
- `L=16`、K=4、`COLS_PER_TILE=1168`统一TRIKE五档seed 1均
  `residual=0`、`exact=1`，固定周期为333,990、657,341、2,353,770、7,135,995和16,641,183；
- `L=32`、K=4、`COLS_PER_TILE=1152`统一TRIKE五档seed 1均
  `residual=0`、`exact=1`，固定周期为193,486、365,945、1,207,716、3,729,550和8,720,781；
- 两组完整调度均未触发`ram_t`地址范围或公共地址不变量检查。

周期与物理基线：没有新增流水级或调度拍。L=16和L=32的100 MHz固定译码延时分别保持
166.41183 ms和87.20781 ms。物理复测使用阶段41 selector公共地址配置作为直接基线：

| 指标 | `L=16, C=1168`参考 | `L=32, C=1152`参考 |
| --- | ---: | ---: |
| Slice LUT / FF / Slice | 27,104 / 11,372 / 9,632 | 47,104 / 20,811 / 15,957 |
| Block RAM Tile | 537.5 | 561.5 |
| RAMB36E1 / RAMB18E1 | 480 / 115 | 512 / 99 |
| 整体 / `decoder_clk` WNS | +0.608 / +0.794 ns | +0.505 / +0.505 ns |
| hold WHS / pulse WPWS | +0.037 / +4.232 ns | +0.030 / +4.232 ns |
| `o_e_rdata`未约束路径 | 14.651 ns | 13.694 ns |

用户提供的L=32同条件Vivado 2023.2报告使用`xc7k355tffg901-2L`、10 ns时钟和0.100 ns不确定度。
资源报告为2026-07-26 22:22:26的Fully Placed Design，时序报告为22:26:09的Routed Design。与上表
阶段41直接基线相比：

| L=32指标 | 阶段41 selector公共地址 | 本阶段`ram_t`公共地址 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 47,104 | 45,316 | -1,788（-3.80%） |
| LUT as Logic | 42,656 | 40,868 | -1,788（-4.19%） |
| LUT as Memory | 4,448 | 4,448 | 0 |
| Slice Register | 20,811 | 20,798 | -13（-0.06%） |
| Slice | 15,957 | 15,392 | -565（-3.54%） |
| Block RAM Tile | 561.5 | 561.5 | 0 |
| RAMB36E1 / RAMB18E1 | 512 / 99 | 512 / 99 | 0 / 0 |
| DSP | 0 | 0 | 0 |
| CARRY4 | 2,998 | 2,812 | -186（-6.20%） |

LUT as Memory和BRAM几何完全不变，资源下降来自组合地址/旋转逻辑；这与结构假设一致，但结论以
Fully Placed实测为准。

| L=32时序指标 | 阶段41 selector公共地址 | 本阶段`ram_t`公共地址 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.505 / 0.000 ns | +0.276 / 0.000 ns | WNS -0.229 ns |
| `decoder_clk` setup WNS/TNS | +0.505 / 0.000 ns | +0.276 / 0.000 ns | WNS -0.229 ns |
| hold WHS/THS | +0.030 / 0.000 ns | +0.034 / 0.000 ns | WHS +0.004 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| 异步复位释放WNS | +3.594 ns | +2.875 ns | -0.719 ns |
| `o_e_rdata`未约束路径 | 13.694 ns | 14.315 ns | +0.621 ns |

最差主时钟路径从`ram_t` buffer 0、bank 6的RAMB36读口到VNU lane 19的
`v2c_scaled_q_reg[19][17]`，WNS为+0.276 ns，数据路径9.240 ns，其中logic 3.244 ns、route
5.996 ns，共13级逻辑。前十条路径以`ram_t`到VNU为主，说明地址旋转收窄降低了面积，但没有切断
RAM读回后13级VNU组合链。第二差路径从selector bank 0的`diag_idx_local_q_reg[0][1]`到
`ram_k_tile` bank 23 snapshot distributed RAM输入，WNS为+0.316 ns，数据路径9.313 ns，其中
route 8.222 ns、占88.285%；阶段41被消除的tile地址计算路径仍未进入前十条，但snapshot数据/控制
布线重新成为邻近瓶颈。

最差异步路径从复位同步器到全局K bank 30的`pack_read_segment_idx_q_reg[30][1]` CLR端，数据路径
7.053 ns，其中route 6.715 ns、占95.208%。内部未约束endpoint为0；TIMING-18仍报告76项，即69个
普通输入和7个输出没有I/O delay，另有1个输入由false path覆盖。`o_e_rdata`的14.315 ns路径不属于
板级I/O时序签核。

没有新增周期，TRIKE-512在100 MHz下仍为8,720,781拍和87.20781 ms。仅用单次WNS对可达频率作一阶
外推，本阶段约为102.84 MHz、延时约84.80 ms；阶段41约为105.32 MHz、82.80 ms，约劣化2.41%。
该外推不是新的时钟约束或实现签核，只用于在周期不变时量化资源/频率权衡。

结论与状态：L=32检查点保留。它以0 BRAM代价减少1,788 LUT和565 Slice，内部100 MHz继续收敛，
代价是setup WNS减少0.229 ns和一阶外推延时增加约2.41%，未构成明显延时劣化。L=16当前结构的
Slice LUT、FF、Slice、BRAM、setup/hold和top paths仍待同条件Vivado复测；完成该检查点前不修改
`ram_accum`，以保持物理归因和回退边界。

## 43. K=4有限长度外推参数写入统一TRIKE硬件

时间：2026-07-28。

目标与依据：把
[K=4 Min-Sum与TRIKE BF的DFR有限长度外推说明](../verification/k4_minsum_trike_bf_fls_extrapolation.md)
中满足TRIKE环条件的五档候选写入K-sign硬件。采用的公开参数为：

| 等级 | `r` | `W` | `T` |
| --- | ---: | ---: | ---: |
| TRIKE128 | 8291 | 27 | 201 |
| TRIKE160 | 12899 | 35 | 263 |
| TRIKE256 | 29917 | 55 | 429 |
| TRIKE384 | 63997 | 83 | 659 |
| TRIKE512 | 106781 | 111 | 877 |

五个`r`均重新检查为素数，且2是模`r`的本原元。修改范围包括`rtl/bike_pkg.sv`的统一硬件
`P_R_VALS`、`scripts/run_bike_random.py`的随机fixture参数和`scripts/min_sum_model.c`的参考模型
profile。`W`、`T`、5-bit消息、K=4、7次固定迭代、`L=32`和`COLS_PER_TILE=1152`保持不变。
BF/BGF阈值没有固化到硬件参数表，相关软件路径仍按具体`r`自动计算阈值。

派生几何与固定周期：

| 等级 | `ROW_SEG_SIZE` | `TILE_COUNT` | 固定周期 | 100 MHz延时 |
| --- | ---: | ---: | ---: | ---: |
| TRIKE128 | 260 | 8 | 193,528 | 1.93528 ms |
| TRIKE160 | 404 | 12 | 365,980 | 3.65980 ms |
| TRIKE256 | 935 | 26 | 1,207,807 | 12.07807 ms |
| TRIKE384 | 2000 | 56 | 3,866,092 | 38.66092 ms |
| TRIKE512 | 3337 | 93 | 8,538,564 | 85.38564 ms |

验证范围与结果：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`通过；
- 14项单元测试全部通过；
- toy集成测试为`residual=0`、`exact=1`、固定154周期；
- `make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1 TRIKE_UNIFIED_KSIGN_K=4`
  的五档seed 1回归全部`residual=0`、`exact=1`，实测周期与上表逐项一致；
- Python参数生成脚本通过语法编译，C参考模型通过`-Wall -Wextra -Werror`语法检查并重新构建；
  五档profile各运行seed 1单例，均为`residual_weight=0`、`exact=yes`。

物理边界：统一最大几何从`R_MAX=108587`改为106781，最大等级`TILE_COUNT`从95改为93，
`ROW_SEG_SIZE`从3394改为3337。虽然全局K RAM的分段数量保持不变，其他RAM尾段、布局和关键路径仍可能
变化。2026-07-17至2026-07-26的Vivado资源和时序报告只作为旧`r`历史参考；新参数下的LUT、FF、
Slice、Block RAM Tile、RAMB36、RAMB18、setup WNS/TNS、hold WHS和I/O约束状态均为待测，不能从
RTL深度变化直接推断。

结论与状态：K=4外推候选已作为当前统一TRIKE硬件参数保留，功能和固定周期验证完成；新参数Vivado
实现待测。

## 44. 新r参数下L=16 ram_t公共地址物理检查点与下一步排序

时间：2026-07-28。

配置与归因边界：用户提供的报告使用Vivado 2023.2、`xc7k355tffg901-2L`、
`TRIKE_UNIFIED_PARAMS`、`L=16`、K=4、`COLS_PER_TILE=1168`、10 ns时钟和0.100 ns不确定度。
资源报告时间为2026-07-28 16:41:27、Design State为Fully Placed；时序报告时间为16:46:36、
Design State为Routed。该检查点同时包含阶段42的`ram_t`公共地址结构和阶段43的新
`R={8291,12899,29917,63997,106781}`，而阶段41参考同时使用旧`r`且尚未修改`ram_t`。因此下表差值
表示当前成品相对旧检查点的组合变化，不能作为严格的单变量`ram_t`归因。

| L=16资源 | 阶段41旧`r` selector公共地址 | 当前新`r`及`ram_t`公共地址 | 组合变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 27,104 | 26,034 | -1,070（-3.95%） |
| LUT as Logic | 22,784 | 21,714 | -1,070（-4.70%） |
| LUT as Memory | 4,320 | 4,320 | 0 |
| Distributed RAM LUT / SRL LUT | 4,160 / 160 | 4,160 / 160 | 0 / 0 |
| Slice Register | 11,372 | 11,365 | -7（-0.06%） |
| Slice | 9,632 | 9,286 | -346（-3.59%） |
| Block RAM Tile | 537.5 | 537.5 | 0 |
| RAMB36E1 / RAMB18E1 | 480 / 115 | 480 / 115 | 0 / 0 |
| DSP / CARRY4 | 0 / 1,851 | 0 / 1,731 | 0 / -120（-6.48%） |

新旧最大几何的全局K分段数、BRAM数量、`Q_BASE=73`、tile RAM深度档和各地址位宽均未变化；同时，
L=16的LUT、Slice和CARRY4下降比例与阶段42同结构L=32结果方向接近。因此大部分组合资源下降来自
`ram_t`地址旋转收窄是合理推断，但缺少“新`r`、旧`ram_t`”控制组，不能把1,070 LUT全部记为
`ram_t`的严格实测收益。

| L=16时序 | 阶段41旧`r` selector公共地址 | 当前新`r`及`ram_t`公共地址 | 组合变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.608 / 0.000 ns | +0.611 / 0.000 ns | WNS +0.003 ns |
| `decoder_clk` setup WNS/TNS | +0.794 / 0.000 ns | +0.667 / 0.000 ns | WNS -0.127 ns |
| hold WHS/THS | +0.037 / 0.000 ns | +0.034 / 0.000 ns | WHS -0.003 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| 异步复位释放WNS | +0.608 ns | +0.611 ns | +0.003 ns |
| `o_e_rdata`未约束路径 | 14.651 ns | 13.213 ns | -1.438 ns |

当前最差主时钟路径从`ram_t` buffer 1、bank 3的RAMB36读口到VNU lane 11的
`v2c_scaled_q_reg[11][17]`，WNS为+0.667 ns，数据路径8.722 ns，其中logic 2.905 ns、route
5.817 ns，共11级逻辑。旧检查点的同类最差路径为8.519 ns、logic 3.228 ns、route 5.291 ns和13级；
当前逻辑部分缩短0.323 ns，但布线增加0.526 ns，净数据路径增加0.203 ns。公共地址收窄位于前向请求，
不会切断BRAM读回、逆旋转、减法和alpha缩放组成的返回路径。

前十条主时钟路径中七条为`ram_t`到VNU；另外三条从`ram_m.c2v_pair_sel_q`到
`c2v_comp_s_reg[3]`，最差同为+0.667 ns，数据路径9.310 ns中route为9.008 ns、占96.756%，只有
1级LUT。该路径说明L=16的下一时序瓶颈还包括跨pair输出选择，而不是单独给VNU加流水即可解决。

最差异步路径从复位同步器到全局K RAM的`pack_read_segment_idx_q_reg[2][2]` CLR端，数据路径
8.914 ns，其中route 8.547 ns、占95.883%。内部未约束endpoint为0；TIMING-18仍为76项，即69个
普通输入和7个输出缺少I/O delay，另有1个输入由false path覆盖。`o_e_rdata`的13.213 ns路径不能作为
板级同步接口签核。

新`r`下L=16固定周期为：

| 等级 | `ROW_SEG_SIZE` | `TILE_COUNT` | 固定周期 | 100 MHz延时 |
| --- | ---: | ---: | ---: | ---: |
| TRIKE128 | 519 | 8 | 377,159 | 3.77159 ms |
| TRIKE160 | 807 | 12 | 713,271 | 7.13271 ms |
| TRIKE256 | 1,870 | 26 | 2,353,952 | 23.53952 ms |
| TRIKE384 | 4,000 | 55 | 7,402,114 | 74.02114 ms |
| TRIKE512 | 6,674 | 92 | 16,463,236 | 164.63236 ms |

功能验证单独使用以下命令运行五档seed 1：

```sh
make test-trike-unified-ksign-random BIKE_RANDOM_TRIALS=1 \
  TRIKE_UNIFIED_KSIGN_PARALLEL_L=16 \
  TRIKE_UNIFIED_KSIGN_COLS_PER_TILE=1168 \
  TRIKE_UNIFIED_KSIGN_K=4
```

五档全部`residual=0`、`exact=1`，实测周期与上表逐项一致。Vivado物理通过和该功能结果分别成立。

相对旧`r`的L=16历史周期，五档分别变化+12.93%、+8.51%、+0.01%、+3.73%和-1.07%。这是
`ceil(R/COLS_PER_TILE)`跨整数边界造成的固定tile数量变化；`r`更接近外推目标不等于每个等级的硬件周期
都会下降。若L=16需要兼顾前四档延时，应按新`r`重新扫描tile大小，不能只观察TRIKE-512。

仅按`10 ns - decoder_clk WNS`作一阶频率外推，当前约为107.15 MHz，TRIKE-512约153.651 ms。
阶段41旧参数检查点约为108.62 MHz和153.199 ms；两项变化混合后的外推总延时增加约0.30%，而100 MHz
固定延时因新`r`减少约1.07%。该计算不是Fmax签核，也不能用于拆分`r`与RTL结构的独立贡献。

下一步按以下顺序推进：

1. 先在不修改RTL结构的条件下取得新`r`、L=32、K=4、`COLS_PER_TILE=1152`报告。阶段42的L=32报告
   仍使用旧`r`，缺少该报告会使后续L=32资源和总延时继续混合归因。
2. 下一项无周期结构实验为`ram_accum`公共地址收窄。C2V读、C2V写和V2C读各自满足同拍所有有效lane
   的`floor(tile_offset/L)`相同；L=16可把两条`1+7`读请求和一条`1+7+ACC_W`写请求中的地址移出
   旋转网络，删除1,344个1-bit 2:1 mux节点，L=32对应2,880个节点。只广播三份公共地址，RAM深度、
   单读口buffer、异步读、旁路和固定周期保持不变。预期目标是logic LUT/Slice下降；当前top paths
   不经过这些前向地址，因此不预设WNS改善，并单独复测广播扇出。
3. 独立的L=16时序实验可移除`ram_m`输出端的标量`c2v_pair_sel_q/v2c_pair_sel_q`选择，改用每个
   pair/bank已经寄存的`c2v_bank_read_valid`和`v2c_bank_read_valid`作局部one-hot选择，并增加
   one-hot断言。该实验不增加周期，直接针对当前三条96%以上route路径；必须与`ram_accum`分开实现和
   复测。
4. 资源主线仍可验证27-bit精确K位置编码。新最大`r`下L=16和L=32全局K分段档不变，静态目标仍分别
   节省80和32个RAMB36。新`r`重新扫描L=32统一tile后，`C=1504`、`Q_BASE/Q_TILE=47/50`的五档周期为
   190,882、358,140、1,200,107、3,819,612和8,376,171，相对`C=1152`分别减少1.37%、2.14%、
   0.64%、1.20%和1.90%。它预计为`ram_t`增加64个RAMB18，即32个Block RAM Tile，可与27-bit编码
   释放的32个Tile配对验证；旧参数下优先的`C=1664`不是新参数最大等级的最优联合点。
   L=16的新`r`统一扫描只有`C=1312`同时不劣化五档，周期为373,190、672,111、2,336,627、
   7,386,427和16,425,940；TRIKE-512只减少0.23%，而`ram_t`最大深度从8,103跨到9,102，静态预计
   增加32个RAMB18，即16个Block RAM Tile，因此不作为最大等级低延时主线。
5. VNU流水只在证明不会把每个diag的`Q_TILE`增加1拍时考虑。若每个diag增加1拍，新`r`的TRIKE-512
   将增加约216,006拍（L=16，+1.31%）或218,337拍（L=32，+2.56%）。L=16移除`ram_t`路径后仍有同为
   +0.667 ns的`ram_m`路径；旧`r` L=32的次差路径只比最差路径多0.040 ns，单独切断VNU路径的一阶
   频率收益约0.41%，不足以抵消+2.56%周期，因此该方案不作为下一项。

结论与状态：当前新`r` L=16检查点保留，内部100 MHz、BRAM、setup、hold和pulse width均满足要求；
相对旧检查点表现为明显logic资源下降和约0.30%的一阶外推总延时变化，属于可接受权衡。下一步先补齐
新`r` L=32物理基线，再实施`ram_accum`公共地址收窄；`ram_m`局部one-hot选择作为随后独立的零周期
时序候选。

## 45. 新r参数下L=32 ram_t公共地址物理基线

时间：2026-07-28。

配置：用户提供的报告使用Vivado 2023.2、`xc7k355tffg901-2L`、`TRIKE_UNIFIED_PARAMS`、`L=32`、
K=4、`COLS_PER_TILE=1152`、10 ns时钟和0.100 ns不确定度。资源报告时间为2026-07-28 20:41:06、
Design State为Fully Placed；时序报告时间为20:47:10、Design State为Routed。与阶段42相比仅将统一
TRIKE的公开`r`参数更新为阶段43数值，K-sign selector和`ram_t`公共地址RTL结构保持相同，因此可直接
观察新旧参数几何对当前结构的影响。

| L=32资源 | 旧`r` | 新`r` | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 45,316 | 45,309 | -7（-0.02%） |
| LUT as Logic | 40,868 | 40,861 | -7（-0.02%） |
| LUT as Memory | 4,448 | 4,448 | 0 |
| Distributed RAM LUT / SRL LUT | 4,160 / 288 | 4,160 / 288 | 0 / 0 |
| Slice Register | 20,798 | 20,802 | +4（+0.02%） |
| Slice | 15,392 | 15,406 | +14（+0.09%） |
| Block RAM Tile | 561.5 | 561.5 | 0 |
| RAMB36E1 / RAMB18E1 | 512 / 99 | 512 / 99 | 0 / 0 |
| DSP / CARRY4 | 0 / 2,812 | 0 / 2,812 | 0 / 0 |

资源差异均处于布局/综合波动量级，新`r`没有跨越任何物理存储档，当前结构的LUT、FF、Slice和BRAM容量
可视为保持稳定。

| L=32时序 | 旧`r` | 新`r` | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.276 / 0.000 ns | +0.439 / 0.000 ns | WNS +0.163 ns |
| `decoder_clk` setup WNS/TNS | +0.276 / 0.000 ns | +0.439 / 0.000 ns | WNS +0.163 ns |
| hold WHS/THS | +0.034 / 0.000 ns | +0.028 / 0.000 ns | WHS -0.006 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| 异步复位释放WNS | +2.875 ns | +2.499 ns | -0.376 ns |
| `o_e_rdata`未约束路径 | 14.315 ns | 14.105 ns | -0.210 ns |

最差主时钟路径从`ram_t` buffer 0、bank 22的RAMB36读口到VNU lane 13的
`v2c_scaled_q_reg[13][17]`，数据路径8.992 ns，其中logic 3.226 ns、route 5.766 ns、route占
64.122%，共13级逻辑。旧`r`同类最差路径为9.240 ns，当前缩短0.248 ns，其中route缩短0.230 ns。
前十条主时钟路径全部为`ram_t`到VNU，WNS范围为+0.439至+0.546 ns；旧报告中的snapshot邻近瓶颈未进入
当前前十条。最差异步路径从复位同步器到全局K RAM的
`pack_read_segment_idx_q_reg[18][1]` CLR端，数据路径6.998 ns，其中route 6.634 ns、占94.798%。

内部未约束endpoint为0；TIMING-18仍为76项，即69个普通输入和7个输出缺少I/O delay，另有1个输入由
false path覆盖。`o_e_rdata`的14.105 ns路径不能作为板级同步接口签核。

TRIKE-512固定周期从8,720,781降至8,538,564，减少182,217拍（2.09%）；100 MHz固定延时从
87.20781 ms降至85.38564 ms。仅按`10 ns - decoder_clk WNS`作一阶外推，频率从102.84 MHz提高到
104.59 MHz，总延时从84.801 ms降至81.637 ms，改善3.73%。该外推不是新的Fmax签核。

在同一新`r`下，L=32相对L=16增加19,275 LUT、9,437 FF、6,120 Slice和24个Block RAM Tile，分别为
74.04%、83.04%、65.91%和4.47%；TRIKE-512固定周期减少48.14%，100 MHz延时从164.63236 ms降至
85.38564 ms。一阶外推延时从153.651 ms降至81.637 ms，改善46.87%。因此L=32继续作为低延时主配置，
L=16作为逻辑资源受限配置。

结论与状态：新`r` L=32检查点保留并作为当前默认物理基线。资源保持稳定，固定周期和主时钟WNS同时
改善；阶段44要求的双并行度基线已经闭合。下一项可以独立实施`ram_accum`公共地址收窄，保持周期和
存储语义不变，并分别对L=16/L=32复测logic LUT、Slice、广播扇出和top paths。

## 46. `ram_accum`公共地址广播与前向旋转载荷收窄

时间：2026-07-28。

目标与假设：`ram_accum`的C2V读、C2V写和V2C读分别由同一个lane group生成地址。对其中任一路径，
同拍所有有效lane的`floor(tile_offset/L)`相同，lane之间只需要按`tile_offset mod L`旋转到目标bank。
因此三条前向路由中的组地址可以从barrel rotate载荷移出，每条路径只保留目标bank相关字段。该变换
不修改公开调度、RAM深度、fill/active buffer选择、异步读、C2V读改写、同址旁路或返回数据旋转。

关键实现：

- `c2v_read_addr_common`、`c2v_write_addr_common`和`v2c_read_addr_common`分别从各路径lane 0的
  `tile_offset`计算，并广播到所有bank；
- C2V读和V2C读的前向route宽度从`1+ACCUM_BANK_AW`收窄为1，只旋转valid；
- C2V写的前向route宽度从`1+ACCUM_BANK_AW+ACC_W`收窄为`1+ACC_W`，只旋转valid和写数据；
- 仿真期断言逐lane检查有效请求的`offset_addr`等于对应公共地址，并保留原有地址范围断言。

结构量化如下。这里的mux节点是barrel rotate各级的1-bit 2:1选择节点数量，只用于描述被删除的
组合选择负载，不能等同于综合后的LUT数量。

| 配置 | `ACCUM_BANK_AW` | 两条读route | 一条写route | 删除的1-bit 2:1 mux节点 |
| --- | ---: | ---: | ---: | ---: |
| L=16，`COLS_PER_TILE=1168`，`Q_BASE=73` | 7 | 各`8 -> 1` bit | `1+7+ACC_W -> 1+ACC_W` bit | `3 × 7 × 16 × 4 = 1,344` |
| L=32，`COLS_PER_TILE=1152`，`Q_BASE=36` | 6 | 各`7 -> 1` bit | `1+6+ACC_W -> 1+ACC_W` bit | `3 × 6 × 32 × 5 = 2,880` |

功能与固定周期验证：

- `make format-rtl`、`make check-format-rtl`和`make lint-rtl`通过；
- `make test-unit`的14项单元测试全部通过，`tb_ram_accum`通过；
- `make test-integration`通过，toy结果为`residual=0`、`exact=1`、固定154周期；
- 新`r`、L=16、K=4、`COLS_PER_TILE=1168`的五档seed 1回归全部`residual=0`、`exact=1`，周期为
  377,159、713,271、2,353,952、7,402,114和16,463,236；
- 新`r`、L=32、K=4、`COLS_PER_TILE=1152`的五档seed 1回归全部`residual=0`、`exact=1`，周期为
  193,528、365,980、1,207,807、3,866,092和8,538,564；
- 两个真实`Q_BASE>1`配置的完整调度均未触发公共地址或地址范围断言。固定周期逐项等于阶段44和阶段45
  基线，因此该结构没有周期退化。

同条件Vivado复测基线：

| 配置 | Slice LUT | FF | Slice | Block RAM Tile | RAMB36/RAMB18 | setup WNS | hold WHS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| L=16，K=4，C=1168 | 26,034 | 11,365 | 9,286 | 537.5 | 480/115 | 整体+0.611 ns；`decoder_clk`+0.667 ns | +0.034 ns |
| L=32，K=4，C=1152 | 45,309 | 20,802 | 15,406 | 561.5 | 512/99 | 整体及`decoder_clk`+0.439 ns | +0.028 ns |

两组基线均为Vivado 2023.2、`xc7k355tffg901-2L`、10 ns时钟和0.100 ns不确定度；L=16详见阶段44，
L=32详见阶段45。

L=32物理结果：用户提供的报告时间为2026-07-28 22:31:33（Fully Placed资源）和22:39:32
（Routed时序），器件、速度等级、Vivado版本、XDC及公开参数与阶段45相同，阶段46的`ram_accum`
是两次报告间唯一RTL结构变化，可直接比较。

| L=32资源 | 阶段45基线 | `ram_accum`公共地址 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 45,309 | 45,266 | -43（-0.09%） |
| LUT as Logic | 40,861 | 40,819 | -42（-0.10%） |
| LUT as Memory | 4,448 | 4,447 | -1 |
| Distributed RAM LUT / SRL LUT | 4,160 / 288 | 4,160 / 287 | 0 / -1 |
| Slice Register | 20,802 | 20,820 | +18（+0.09%） |
| Slice | 15,406 | 14,770 | -636（-4.13%） |
| Block RAM Tile | 561.5 | 561.5 | 0 |
| RAMB36E1 / RAMB18E1 | 512 / 99 | 512 / 99 | 0 / 0 |
| DSP / CARRY4 | 0 / 2,812 | 0 / 2,812 | 0 / 0 |

前向旋转减少2,880个1-bit mux节点后，aggregate logic LUT只减少42，说明这些选择大部分被综合共享、
折叠或未映射为独立LUT；结构节点数不能作为LUT收益。Placed Slice减少636，但LUT总量近似不变，收益
主要表现为装箱与布局密度变化。缺少不同placer seed或重复实现，不能确认该Slice降幅的稳定性。

| L=32时序 | 阶段45基线 | `ram_accum`公共地址 | 变化 |
| --- | ---: | ---: | ---: |
| 整体及`decoder_clk` setup WNS/TNS | +0.439 / 0.000 ns | +0.306 / 0.000 ns | WNS -0.133 ns |
| hold WHS/THS | +0.028 / 0.000 ns | +0.032 / 0.000 ns | WHS +0.004 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| 异步复位释放WNS | +2.499 ns | +2.863 ns | +0.364 ns |
| `o_e_rdata`未约束路径 | 14.105 ns | 15.134 ns | +1.029 ns |

最差主时钟路径仍为`ram_t` BRAM读口到VNU，当前从buffer 0、bank 14到lane 14的
`v2c_scaled_q_reg[14][17]`，数据路径9.083 ns，其中logic 3.332 ns、route 5.751 ns，共13级。
相对阶段45，数据路径增加0.091 ns，其中logic增加0.106 ns而route减少0.015 ns；前十条仍全部为
`ram_t`到VNU，说明`ram_accum`前向地址网络不是当前top-path瓶颈。WNS下降还包含布局后时钟偏斜变化，
不能只由数据路径差值解释。内部100 MHz、hold和pulse width均通过；TIMING-18仍为76项，板级I/O约束
边界未改变。

固定周期保持8,538,564。按`10 ns - WNS`作一阶外推，估算频率从104.59 MHz降至103.16 MHz，
TRIKE-512延时从81.637 ms增至82.773 ms，约退化1.39%；该计算不是Fmax签核。在固定100 MHz目标下周期
和85.38564 ms延时均不变。

L=16物理结果：用户提供的报告时间为2026-07-29 00:17:56（Fully Placed资源）和00:22:51
（Routed时序），器件、速度等级、Vivado版本、XDC及公开参数与阶段44相同，阶段46的`ram_accum`
是两次报告间唯一RTL结构变化，可直接比较。

| L=16资源 | 阶段44基线 | `ram_accum`公共地址 | 变化 |
| --- | ---: | ---: | ---: |
| Slice LUT | 26,034 | 26,430 | +396（+1.52%） |
| LUT as Logic | 21,714 | 22,111 | +397（+1.83%） |
| LUT as Memory | 4,320 | 4,319 | -1 |
| Distributed RAM LUT / SRL LUT | 4,160 / 160 | 4,160 / 159 | 0 / -1 |
| Slice Register | 11,365 | 11,366 | +1（+0.01%） |
| Slice | 9,286 | 9,443 | +157（+1.69%） |
| Block RAM Tile | 537.5 | 537.5 | 0 |
| RAMB36E1 / RAMB18E1 | 480 / 115 | 480 / 115 | 0 / 0 |
| DSP / CARRY4 | 0 / 1,731 | 0 / 1,731 | 0 / 0 |

L=16删除1,344个1-bit旋转mux节点后，Logic LUT和Slice均增加，说明公共地址广播及其布局代价超过
被综合移除的选择逻辑；该结构在资源受限配置上没有收益。

| L=16时序 | 阶段44基线 | `ram_accum`公共地址 | 变化 |
| --- | ---: | ---: | ---: |
| 整体setup WNS/TNS | +0.611 / 0.000 ns | +0.363 / 0.000 ns | WNS -0.248 ns |
| `decoder_clk` setup WNS/TNS | +0.667 / 0.000 ns | +0.363 / 0.000 ns | WNS -0.304 ns |
| hold WHS/THS | +0.034 / 0.000 ns | +0.026 / 0.000 ns | WHS -0.008 ns |
| pulse WPWS/TPWS | +4.232 / 0.000 ns | +4.232 / 0.000 ns | 0 |
| 异步复位释放WNS | +0.611 ns | +0.568 ns | -0.043 ns |
| `o_e_rdata`未约束路径 | 13.213 ns | 13.152 ns | -0.061 ns |

当前前十条主时钟路径全部从`u_ram_m.c2v_pair_sel_q`到lane 10的`c2v_comp_s`寄存器，最差数据路径
9.426 ns，其中logic 0.302 ns、route 9.124 ns、route占96.796%，只有1级LUT。阶段44中同类路径
数据延迟为9.310 ns、route为9.008 ns，公共地址改动引起的整体布局变化使该高扇出选择路径route增加
0.116 ns，并取代`ram_t`到VNU成为唯一的前十条瓶颈。内部100 MHz、hold和pulse width仍通过；
TIMING-18仍为76项。

固定周期保持16,463,236。按`10 ns - decoder_clk WNS`作一阶外推，估算频率从107.15 MHz降至
103.77 MHz，TRIKE-512延时从153.651 ms增至158.656 ms，约退化3.26%；该计算不是Fmax签核。
在固定100 MHz目标下周期和164.63236 ms延时均不变。

双并行度决策：L=32只减少43 LUT，同时WNS下降0.133 ns、外推延时增加1.39%；L=16增加396 LUT和
157 Slice，同时WNS下降0.304 ns、外推延时增加3.26%。该方案未形成稳定的资源收益，且两个并行度的
时序均退化，因此撤回阶段46。

回退与验证：`rtl/ram_accum.sv`恢复为阶段46之前的逐lane地址旋转结构，并与提交`7efdabc`中的文件
逐字一致；`make format-rtl`、`make check-format-rtl`、`make lint-rtl`、14项`make test-unit`和
`make test-integration`全部通过，toy结果为`residual=0`、`exact=1`、固定154周期。新`r`的五档
L=16/L=32固定周期与译码结果直接继承阶段44/45已经验证的相同RTL检查点。

结论与状态：阶段46撤回，当前成品恢复阶段44/45的`ram_accum`结构和物理基线。下一项独立候选为
`ram_m`局部one-hot输出选择，直接针对L=16当前96%以上route占比的高扇出pair选择路径；实施前保留本次
回退点，并单独验证连续同row访问、旁路、pair隔离、固定周期以及L=16/L=32物理结果。

### 阶段47：TRIKE KEM公共密码核首批RTL（2026-07-30）

目标与假设：在TRIKE字节级哈希实例化、固定重量采样和参数表尚未冻结的条件下，先实现不会绑定上述选择的
公共核。Keccak-f[1600]状态置换、标准SHAKE256 sponge以及隐式拒绝比较/选择可以由后续
`H1/H2/H3/H4/K/L`共享。

关键实现：

- `keccak_f1600`保存1600-bit状态，每拍组合执行一轮Theta、Rho、Pi、Chi和Iota，固定24轮完成；
- `shake256_stream`使用136-byte rate、`0x1f/0x80` padding和8-bit valid/ready接口，
  `INPUT_BYTES/OUTPUT_BYTES`由公开参数在elaboration时确定；
- absorb消息恰好结束于rate边界时先置换完整消息块，再吸收独立padding block；
- squeeze超过一个rate block时对当前sponge状态继续置换；
- `kem_ct_compare_select`对完整比较向量做XOR归约，并用全宽mask选择正常或拒绝数据；
- Makefile增加`test-kem-unit`，并将其纳入`test-unit`依赖。

验证范围：

- `tb_keccak_f1600`对拍全零输入的25个标准输出lane，并检查24轮busy周期；
- `tb_shake256_stream`对拍独立软件SHAKE256：272-byte顺序消息和200-byte输出覆盖两个完整absorb
  block、独立padding block、第二个squeeze block和输出backpressure；
- `tb_kem_ct_compare_select`覆盖全相等、257个单bit不等和100组随机数据选择；
- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`和`make test-kem-unit`通过。

定量结果：Keccak置换固定24轮；SHAKE接口在无停顿时的absorb/squeeze字节数由公开参数固定。LUT、FF、
Slice、BRAM、DSP、setup WNS/TNS和hold WHS均为待测，尚未运行Vivado综合或布局布线。

结论与状态：保留。公共核不写入TRIKE函数标签、序列化、奇偶环映射、固定重量采样或各等级`l`，因此当前
结果只确认FIPS 202公共数据通路和隐式拒绝选择功能，不构成完整TRIKE KEM硬件签核。

### 阶段48：TRIKE随包SM3链调研与首批RTL（2026-07-30）

目标与假设：以`trike-电子版材料0629`的四档KAT、Reference C和Optimized C为实现依据，识别KEM实际
哈希链，并建立可独立对拍的SM3/HMAC硬件基线。BIKE多项式硬件论文用于后续乘法与求逆架构，AWS
`bike-kem`用于软件控制流参考。

调研结果：

- 四档KAT与随包Reference C生成结果逐byte一致，参数为
  `r={15581,35363,69691,114043}`、`d={35,55,83,111}`、`t={263,429,659,877}`；
- H1/H2/H3和H4使用ICCS SM3-DRNG，K和L使用ICCS `pseudohash512`；
- `pseudohash512`由HMAC-SM3与SM3级联组成，固定HMAC key为64 byte；
- AWS `bike-kem`为Apache-2.0 CPU软件，不含RTL；Racing BIKE提供可迁移的稀疏乘法和divstep/extGCD
  求逆架构，其Keccak随机预言机不用于随包TRIKE哈希链；
- 公开`ljgibbslf/SM3_core`具有32/64-bit RTL和随机对拍环境，但仓库页面未给出明确许可证声明，因此
  本阶段只参考接口与性能，不复制RTL。

关键实现：

- `sm3_compress`保存68个32-bit schedule word，用52周期生成`W[16]..W[67]`，再固定执行64轮；
- `sm3_hash_stream`使用公开`INPUT_BYTES`和8-bit valid/ready输入，复用一个压缩核完成多block
  chaining、`0x80`padding和64-bit big-endian长度；
- `hmac_sm3_64byte_key_stream`实现`(K xor ipad)||message`和
  `(K xor opad)||inner_digest`，使用两个固定长度SM3实例；
- Makefile的`test-kem-unit`加入三个SM3/HMAC testbench。

验证范围：

- `tb_sm3_compress`对拍`SM3("abc")`，并检查116个busy周期；
- `tb_sm3_hash_stream`对拍`"abc"`和55/56/64/65-byte顺序消息，覆盖单padding block、双padding
  block和整block末尾；
- `tb_hmac_sm3_64byte_key_stream`使用ICCS固定key和`02 00 || "abc"`，对拍独立软件HMAC-SM3；
- `make test-kem-unit`的SM3、HMAC、Keccak、SHAKE和比较选择共6项测试通过。

定量结果：SM3单block压缩固定116个busy周期。连续供数时，流式SM3和HMAC的block数由公开输入长度
固定。LUT、FF、Slice、BRAM、DSP、setup WNS/TNS和hold WHS均为待测，尚未运行Vivado综合或
布局布线。

结论与状态：保留。首批核建立了随包TRIKE实际SM3数据通路；下一阶段实现`SM3_df`、55-byte DRNG状态
算术和Generate，并用随包C生成的中间状态fixture对拍。

### 阶段49：SM3-DRNG与pseudohash512公共核（2026-07-31）

目标与假设：在阶段48的SM3/HMAC基础上实现随包TRIKE实际调用的`SM3_df`、Instantiate、Generate和
`pseudohash512`，使用可重放输入流承载最大参数档的大消息，避免巨型寄存器缓存。

关键实现：

- `sm3_df_stream`计算两次`SM3(counter || 0x000001b8 || input)`并拼接55-byte输出；
- `trike_sm3_drng_instantiate_stream`生成55-byte大端`V/C/reseed_counter`；
- `trike_sm3_drng_generate_stream`按32-byte block输出，块间递增55-byte`data`，并执行
  `V = V + (0^184 || SM3(0x03 || V)) + C + reseed_counter mod 2^440`；
- `trike_pseudohash512_stream`执行固定ICCS key的HMAC-SM3、suffix SM3和`SM3(k1 || h1)`级联；
- `SM3_df`和pseudohash消息均通过pass信号请求上层重放，接口存储量不随KEM消息长度增长。

验证范围：

- 从随包Reference C直接导出32-byte顺序seed的`SM3_df`、Instantiate状态、64-byte Generate结果、
  Generate更新状态和pseudohash512结果；
- `tb_sm3_df_stream`逐byte对拍55-byte输出，连续输入下固定314个busy周期；
- `tb_trike_sm3_drng_instantiate_stream`对拍`V/C/reseed_counter`，固定916个busy周期；
- `tb_trike_sm3_drng_generate_stream`对拍64-byte输出和更新后的`V/C/reseed_counter`，连续接收下固定
  708个busy周期；
- `tb_trike_pseudohash512_stream`对拍完整512-bit输出，连续输入下固定1,128个busy周期。

定量结果：上述周期只对应TB公开参数`SEED_BYTES=32`、`OUTPUT_BYTES=64`和`MESSAGE_BYTES=32`。
其他公开长度的周期由哈希block数和固定控制开销决定。LUT、FF、Slice、BRAM、DSP、setup WNS/TNS和
hold WHS均为待测，尚未运行Vivado综合或布局布线。

结论与状态：保留。K/L和H1/H2/H3/H4所需的公共伪随机与pseudohash路径已经具备；下一项实现
H1/H2/H3环元素padding/奇偶映射，以及H4固定重量位置采样。

### 阶段50：H1/H2/H3奇偶映射与H4固定扫描采样（2026-07-31）

目标与假设：按随包Reference C补齐`set_hamming_weight`和`generate_random_idx`公共核，并将H4
碰撞处理写成固定存储访问调度。给定公开`R/LENGTH/WEIGHT`且接口连续传输时，控制路径和busy周期不依赖
输入向量、随机数或碰撞模式。

关键实现：

- `trike_parity_map_stream`顺序缓存`ceil(R/8)`个byte，清除最后有效系数以上的padding，重新设置
  系数`R-1`以形成H1/H2所需偶校验或H3所需奇校验，再顺序读出同一byte RAM；
- `trike_sampler_candidate`计算
  `pos + high32(random * (length - pos))`；
- `trike_fixed_weight_sampler`从`WEIGHT-1`降序处理位置，每个候选固定读取全部`WEIGHT`个index RAM
  槽位；`j<=pos`读取以dummy mask屏蔽，碰撞时写入`pos`，无碰撞时写入candidate；
- 每个候选只接收一个32-bit随机数，没有数据相关重抽；上层H4控制器需要按Reference C执行固定
  `WEIGHT`次Generate(4 byte)，每次Generate后的DRNG状态更新不能合并；
- valid/ready在停顿期间保持输出payload稳定。固定周期KEM顶层需要连续驱动接口，或用公开的固定等待
  预算封装。

验证范围：

- `tb_trike_parity_map_stream`使用`R=13`覆盖偶/奇目标、padding bit清零、输出停顿保持和连续流固定周期；
- `tb_trike_sampler_candidate`覆盖零随机数、最大随机数、碰撞候选和TRIKE-2长度边界；
- `tb_trike_fixed_weight_sampler`使用`LENGTH=17, WEIGHT=5`分别运行碰撞密集和无碰撞输入，两者输出
  正确且busy周期均为40；额外输出停顿4拍时busy周期只增加4拍，payload保持稳定；
- `make test-kem-unit`包含13项KEM公共核testbench并全部通过。

定量结果：奇偶映射连续流busy周期为`2*R_BYTES+1`。固定扫描采样连续流busy周期为
`WEIGHT*(WEIGHT+3)`，四档H4为69,958、185,328、436,258和771,760拍，不包含各候选
Generate(4 byte)周期。index RAM逻辑容量分别为4,208、7,293、11,862和16,663 bit。LUT、FF、
Slice、BRAM、DSP、setup WNS/TNS和hold WHS均为待测，没有运行Vivado综合或布局布线。

常数时间边界：上述模块的状态路径和存储访问次数由公开参数固定；输入valid空拍和输出ready停顿会延长
接口总周期，普通FPGA数据通路的翻转活动也随数据变化。Reference C `generate_secret_key`包含由
`weak_key_test`结果控制的重采样循环，因此完整KeyGen固定周期策略仍需设计和KAT/失败概率验证。

结论与状态：保留。H1/H2/H3的后处理与H4的无重抽固定扫描公共核具备功能和周期回归；下一个独立实现项为
循环二元多项式乘法器与求逆器，H1/H2/H3/H4组合控制器在多项式RAM接口确定后接入。

### 阶段51：TRIKE KEM统一流程与共享模块划分（2026-07-31）

目标与假设：将KeyGen、Encaps和Decaps的算法步骤映射到RTL模块，识别三条流程中不并发的哈希、DRNG、
采样、多项式和存储资源，形成面积优先的完整KEM模块边界。统一微程序必须保持公开固定调度，资源复用不能
引入秘密数据相关仲裁、重试或RAM访问次数。

架构分析：

- 当前DF、DRNG、HMAC和pseudohash控制器顺序发起SM3调用；完成态可使用一个物理`sm3_compress`，
  由block-builder/context RAM和固定command序列服务全部逻辑函数。该面积基线放弃pseudohash
  `k1/h1`的可选并行机会；
- H1/H2/H3、H4、秘密h采样使用同一DRNG状态算术；一个context寄存器组按阶段装载和覆盖；
- 秘密采样与H4采用相同`generate_random_idx`，一个按最大`t`配置、运行时装载公开`length/weight`的
  采样核和临时index RAM覆盖全部调用；
- 一个循环移位/XOR accumulator支持稀疏×稠密与稠密×稠密模式，覆盖KeyGen的`t0/r2`、Encaps的
  `u/v`和Decaps的syndrome；Decaps使用`s=h0*u+t0*(u+v)`减少为一次稀疏和一次稠密乘法；
- 多项式求逆保留独立固定轮divstep/extGCD控制，但与乘法核时分共享scratch RAM；
- `decoder_top`保持独立物理边界，不与KEM乘法核共享其lane路由、`ram_m`或`ram_t`；
- 大错误向量验证采用固定word数流式XOR归约，不能形成最大34万bit单拍比较树；
- H1/H2/H3、H4、KeyGen/Encaps/Decaps表现为统一`trike_kem_top`中的微程序段，不分别拥有算术实例；
  pk/sk/ct序列化由一个IO控制器和公开格式描述符完成。

RAM生命周期：

- 持久key/ct RAM在一次操作内保留；
- t1/t2/r1、h1/h2临时值、u/v/s和乘法accumulator使用静态liveness分配的scratch bank；
- 采样index RAM在每组结果流出后覆盖；
- Decaps写完`s`后回收`u/v/t1/t2/r1`的scratch空间，`e'`保持到L和流式比较完成；
- decoder内部RAM保持独占，避免跨几何复用引入大mux和时序风险。

验证范围：本阶段只更新
[TRIKE KEM硬件架构、公共核与复用设计](trike_kem_common_cores.md)，没有修改RTL，没有运行新的功能仿真、
Vivado综合或布局布线。阶段50的公共核功能和固定周期结果继续作为已有验证边界。

定量结果：共享实例数目标为一个SM3压缩数据通路、一个DRNG context、一个固定重量采样核、一个多模式
循环乘法核、一个求逆核和一个`decoder_top`。LUT、FF、Slice、BRAM、DSP、端到端固定周期、setup
WNS/TNS和hold WHS均为待测，不能据逻辑实例数直接推测资源收益。

结论与状态：目标架构待实现。优先次序为共享循环多项式乘法核、求逆核、SM3服务化、统一采样服务和KEM
微程序控制器。每次只改变一个物理共享边界，保留独立TB和四档KAT回退点；只有在端到端
`cycles/Fmax`证明单实例成为主要瓶颈后才增加第二个lane。

### 阶段52：TRIKE128固定点对验证参数集成（2026-07-31）

目标与假设：将预声明固定点对验证得到的TRIKE128 K=4参数写入统一译码器。验证配置固定为
5-bit、K=4、`high_mag_dev`、`low_index`、`alpha=0.1875`和`C_VAL=4`；两点在仿真前固定，
不进行参数重选或事后点对筛选。

统计依据：

- `r=7050`运行10000次，失败508次，DFR为`5.08e-2`，95% Clopper-Pearson区间为
  `[4.65774849e-2, 5.52864844e-2]`；
- `r=7300`运行2000000次，失败14次，DFR为`7.00e-6`，95% Clopper-Pearson区间为
  `[3.82697026e-6, 1.17447827e-5]`；
- 目标`2^-128`的连续交点为`r*=8234.272`；首个合法值8237的模型余量为0.46 bit，最终采用
  下一个合法值8243，其置信DFR上界为`2^-129.48`。

关键实现：统一RTL参数表、随机回归生成器、C参考模型和软件KEM配置同步采用
`R=8243/C_VAL=4`；myTRIKE命名参数集和tie比较默认初始LLR同步为4。L=32、K=4、
`COLS_PER_TILE=1152`的TRIKE128固定周期预算为193514；L=16、K=4、
`COLS_PER_TILE=1168`的预算为377138。

验证范围：

- C模型TRIKE128 seed 1得到`residual_weight=0`、`exact=yes`；
- 软件KEM TRIKE128自测通过，正常密文有效，篡改密文执行隐式拒绝；
- myTRIKE使用`PARAM_SET=trike128`编译并通过全部C单元测试，配置输出确认`r=8243`且BF/BGF阈值
  继续针对每个`r`自动计算；
- 统一TRIKE五档、seed 1、K=4在L=32/`COLS_PER_TILE=1152`和
  L=16/`COLS_PER_TILE=1168`两组回归均为`residual=0`、`exact=1`，实测周期与预算一致；
- `make test-unit`和`make test-integration`通过；
- RTL格式检查和Verible lint通过。

Vivado LUT、FF、Slice、BRAM、DSP、setup WNS/TNS和hold WHS均为待测；2026-07-28的资源和时序
报告使用`R=8291/C_VAL=5`，只作为历史物理参考。

结论与状态：保留。TRIKE128公开参数采用`R=8243`，译码初始值采用`C_VAL=4`。若后续改变Top-K
等幅值规则，需要在新规则下重新完成参数确认和固定样本FLS验证。

### 阶段53：最新四档KAT软件基线与循环多项式乘法功能核（2026-07-31）

目标与假设：把`trike-电子版材料0629`的TRIKE-2/5/7/9 Reference C和官方KAT设为完整KEM
golden，并建立一个固定调度的循环二元多项式乘法功能基线。首版优先锁定系数顺序、非word对齐折返、
稠密/稀疏输入语义和数据无关周期；BRAM映射与稀疏模式延时优化作为后续独立物理实验。

关键实现：

- `scripts/run_trike_reference_kat.py`使用本机C编译器直接构建四档随包Reference C，各运行10组
  KeyGen/Encaps/Decaps，并在CRLF/LF归一化后逐byte比较官方KAT；
- `trike_poly_mul_core`按little-endian coefficient word接收操作数，使用`DIGIT_W`位carryless
  digit乘法累加双长度product，再按$x^r-1$固定word数折返；
- 稠密模式固定接收`WORDS`个A word；稀疏模式固定清零A存储、接收`SPARSE_WEIGHT`个index并展开，
  两者共享同一主乘法和reduction调度；
- 输出valid/ready停顿期间保持word和last稳定；busy只因公开接口停顿延长。

验证范围：

- TRIKE-2/5/7/9生成KAT与随包官方PK、SK、CT和SS全部匹配，每档10组；
- `tb_trike_poly_mul_core`使用`R_BITS=13, WORD_W=8, DIGIT_W=4`覆盖非word对齐折返；
- 同一个三项稀疏A分别通过稠密word和稀疏index输入，输出完全相同；
- 两组不同稠密操作数busy周期均为28拍；稀疏模式为31拍；输出停顿3拍时总busy增加3拍。
- `tb_trike_poly_mul_reference`从官方TRIKE-2 KAT第0组提取$t_0$、$r_2$和$h_0$支持集，在
  `R_BITS=15581, WORD_W=64, DIGIT_W=8`下逐word对拍稠密$t_0r_2$和稀疏$h_0r_2$。

定量结果：令`WORDS=ceil(R_BITS/WORD_W)`、`DIGITS=WORD_W/DIGIT_W`，连续流稠密周期为
`6*WORDS+2*WORDS^2*DIGITS`，稀疏周期增加`SPARSE_WEIGHT`。该公式属于功能基线；最大四档固定周期、
LUT、FF、Slice、BRAM、DSP、setup WNS/TNS和hold WHS均为待测。数组尚未通过Vivado证明映射到
同步Block RAM，不能把`ram_style`属性视为资源结论。

TRIKE-2真实参数回归的稠密模式固定954,040拍，稀疏模式固定954,075拍。该数字只表示首版单lane
digit-serial功能延时，不含KeyGen/Encaps/Decaps其他步骤，也没有结合实现后Fmax。

结论与状态：功能基线保留。官方四档KAT已经形成可重复的软件边界；乘法核的下一实验是在保持接口和对拍
不变的前提下使用显式同步BRAM，并加入稀疏index直接旋转累加，比较固定`cycles/Fmax`和BRAM/LUT。

### 阶段54：循环多项式乘法核显式同步Block RAM端口（2026-07-31）

目标与假设：只改变`trike_poly_mul_core`的存储接口和读改写时序，保持digit-serial算法、word流接口、
稠密/稀疏输入语义和golden不变。目标是建立可由Vivado识别的同步RAM结构，并把同步读取引入的所有等待拍
纳入公开参数决定的固定预算。

关键实现：

- A、B、双长度product和result分别实例化公共`ram_bram`，综合分支使用
  `xpm_memory_sdpram(MEMORY_PRIMITIVE="block", READ_LATENCY_B=1)`；
- A/B读取、product低/高word读改写、三次归约读取和result输出均使用显式请求/使用状态；
- 稀疏输入固定执行`WORDS`拍A RAM清零以及每个index一次读取、一次写回；越界index执行相同两拍调度并
  对dummy地址做原值写回，不改变busy周期；
- 数据、系数重量、index值和中间product不参与状态跳转；valid/ready外部空拍仍是唯一接口延长因素。

验证范围：

- `make format-rtl`、`make check-format-rtl`和`make lint-rtl`通过；
- `tb_trike_poly_mul_core`在`R_BITS=13, WORD_W=8, DIGIT_W=4, SPARSE_WEIGHT=3`下对拍稠密/稀疏
  环乘，检查两组不同稠密数据、越界稀疏index dummy写回的相同周期和3拍输出backpressure；
- `tb_trike_poly_mul_reference`在`R_BITS=15581, WORD_W=64, DIGIT_W=8`下逐word对拍TRIKE-2官方
  KAT派生的稠密$t_0r_2$和稀疏$h_0r_2$；
- `make test-kem-unit`、`make test-unit`和`make test-integration`通过；
- 随机fixture生成器同步`K_SIGN_POS_RECORD_W`和`K_SIGN_OVERLAP_DRAIN_CYCLES`后，
  `make test-bike-random BIKE_RANDOM_TRIALS=1`通过，seed 1固定7轮、543,941拍、残余重量0。

定量结果：令`WORDS=ceil(R_BITS/WORD_W)`、`DIGITS=WORD_W/DIGIT_W`，连续流稠密busy周期为
`11*WORDS+WORDS^2*(1+4*DIGITS)`，稀疏busy周期增加`2*SPARSE_WEIGHT`。13-bit toy的稠密/稀疏周期
分别为58/64拍；TRIKE-2真实参数的稠密/稀疏周期分别为1,967,372/1,967,442拍。输出ready停顿3拍时
busy精确增加3拍。与阶段53同参数的异步数组功能基线相比，稠密增加1,013,332拍（106.2%），稀疏增加
1,013,367拍（106.2%）；该代价来自同步A/B读取以及product逐digit读改写，必须结合实现后Fmax判断。

Vivado综合和布局布线待测；LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、setup WNS/TNS和
hold WHS均无新报告。XPM配置只证明RTL的映射请求，不能代替目标器件上的资源和时序结果。

结论与状态：保留同步RAM功能基线。下一项单变量实验是稀疏index直接循环旋转累加，保持稠密路径、接口和
真实参数golden不变；是否保留该优化由同器件、同Vivado、同XDC、同报告阶段的固定`cycles/Fmax`、
Block RAM Tile和LUT结果决定。

### 阶段55：稀疏index直接循环移位累加（2026-07-31）

目标与假设：只替换`trike_poly_mul_core`的稀疏×稠密执行路径，保持阶段54的同步RAM接口、稠密
digit-serial路径、外部word/index协议和golden不变。利用稀疏A只有公开固定`SPARSE_WEIGHT`个非零位置，
将稀疏复杂度从稠密$W^2D$调度降为$SW$固定扫描。

关键实现：

- 输入的`SPARSE_WEIGHT`个index写入独立同步index RAM；B仍按`WORDS`个little-endian word装载；
- 每个index固定读取一次，并对全部B word逐word计算`dest=(b_word*WORD_W+index) mod R_BITS`；
- 每个移位word先按$r$边界分成回卷前后两段，再按result word边界形成最多三个XOR贡献；
- 每个index/B word组合固定执行一次B读取和三组result RAM读取/写回。贡献为零、不跨word和越界index
  仍执行相同地址数量；越界index使用地址0和零贡献完成dummy读改写；
- 稠密A/B、双长度product和四拍/word归约状态保持阶段54结构。

验证范围：

- `make format-rtl`、`make check-format-rtl`和`make lint-rtl`通过；
- 13-bit toy覆盖非word对齐回卷、三个稀疏位置、越界index dummy路径、两组稠密数据和输出
  backpressure；
- TRIKE-2官方KAT派生的15581-bit稠密$t_0r_2$与稀疏$h_0r_2$均逐word匹配；
- `make test-kem-unit`、`make test-unit`、`make test-integration`和一组BIKE随机回归通过。

定量结果：令`WORDS=ceil(R_BITS/WORD_W)`、`DIGITS=WORD_W/DIGIT_W`、
`S=SPARSE_WEIGHT`。稠密busy周期保持`11*WORDS+WORDS^2*(1+4*DIGITS)`；稀疏busy周期为
`4*WORDS+2*S+7*S*WORDS`。13-bit toy稠密/稀疏为58/56拍。TRIKE-2稠密保持1,967,372拍，稀疏从
阶段54的1,967,442拍降至60,826拍，减少1,906,616拍（96.9%），固定周期缩短约32.34倍。

Vivado综合和布局布线待测；新增index RAM、可变移位/掩码逻辑和result地址路径的LUT、FF、Block RAM
Tile、RAMB36、RAMB18、setup WNS/TNS与hold WHS均无报告。周期收益不能代替Fmax和物理资源结论。

结论与状态：保留RTL功能方案，作为稀疏乘法候选基线。该路径直接覆盖Encaps的稀疏错误乘法和Decaps的
稀疏syndrome项；进入KEM顶层前需用目标Vivado环境确认组合移位路径，并与稠密乘法核和后续求逆核的
scratch RAM生命周期统一规划。

### 阶段56：Reference C固定加法链多项式求逆核（2026-07-31）

目标与假设：实现KeyGen所需的稠密多项式求逆，并保持输入系数、秘密密钥和中间多项式不影响状态路径、
乘法次数或RAM访问次数。算法边界以最新四档Reference C为准；独立多项式Euclid只用于fixture golden，
不进入RTL控制流。

关键实现：

- `trike_inv_schedule_pkg`保存TRIKE-2/5/7/9公开$r$对应的Frobenius置换步长和固定addition-chain
  stage数，并提供13-bit toy调度；
- `trike_poly_inv_core`使用`f/g/t`三份同步`ram_bram`，每个Frobenius映射对全部$r$个输出系数各执行
  一次RAM读取和一次捕获，固定为`2r`拍；
- 链内所有环乘时分复用一个稠密`trike_poly_mul_core`；A/B采用同步fetch/send，结果按固定word数写回
  `f`或`t`；
- 最后一轮固定对`t`执行平方置换并按little-endian coefficient word流输出；输出backpressure期间保持
  word和last稳定；
- `scripts/gen_trike_poly_inv_fixture.py`从官方TRIKE-2第0组KAT解析稠密$h_0$，用独立Python
  多项式Euclid生成逆元并检查环乘为一。

验证范围：

- `tb_trike_poly_inv_core`在`R_BITS=13, WORD_W=8, DIGIT_W=4`下运行两组不同可逆输入，检查
  输入与输出环乘为一、两组固定477拍，以及输出停顿只按停顿拍数增加busy；
- `tb_trike_poly_inv_reference`在`R_BITS=15581, WORD_W=64, DIGIT_W=8`下逐word对拍官方KAT
  派生golden，固定44,010,400拍；
- TRIKE-2 Reference C加法链还用独立Python模型逐stage与Euclid逆元交叉检查；
- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`、`make test-kem-unit`、
  `make test-trike-poly-reference`、`make test-trike-poly-inv-reference`、`make test-unit`、
  `make test-integration`和一组BIKE随机回归通过；随机seed 1固定7轮、543,941拍、残余重量0。

定量结果：令$W=\lceil r/\mathrm{WORD\_W}\rceil$，$C_\mathrm{mul}$为同参数稠密乘法busy周期，
$P/M$为公开参数加法链中的Frobenius/乘法数量。连续流求逆busy周期为
$3W+2rP+M(C_\mathrm{mul}+2W+1)$。TRIKE-2的$P=23$、$M=22$、
$C_\mathrm{mul}=1,967,372$，总计44,010,400拍。toy的$P=6$、$M=5$、
$C_\mathrm{mul}=58$，总计477拍。

常数时间边界：stage数、置换步长、每次置换扫描长度、稠密乘法次数以及所有scratch RAM访问数均由公开
$r$确定。输入valid空拍和输出ready停顿会延长接口总周期；普通FPGA数据翻转活动仍随秘密数据变化，本核
未提供功耗masking或平衡逻辑。

Vivado综合和布局布线待测；当前独立核包含三份外层scratch RAM以及乘法核内部A/B/product/result RAM。
LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、setup WNS/TNS和hold WHS均无报告，不能据
固定周期结果推测物理面积或Fmax。

结论与状态：保留功能方案。最新Reference C并未在求逆处采用数据相关迭代的extGCD，而是公开参数固定
Frobenius加法链，因此控制与存储调度满足固定工作量要求。下一项物理实验是合并不重叠生命周期的
operand/scratch RAM并测量相同器件、Vivado、XDC和报告阶段下的资源、Fmax及`cycles/Fmax`。

### 阶段57：求逆稠密乘法外部RAM直连（2026-07-31）

目标与假设：去除阶段56求逆路径中外层`f/g/t`与乘法器内部A/B/result的重复整环存储。稠密普通多项式
乘积完成前不写回结果，因此A可直接读取`f/t`、B可直接读取`g`，归约阶段再覆盖源`f/t`，不存在读写
生命周期冲突。

关键实现：

- `trike_poly_mul_core`增加elaboration-time `USE_EXTERNAL_DENSE_RAM`模式和A/B同步读、result同步写
  端口；该模式从start直接进入product清零，不接受稀疏模式或流式operand；
- generate分支在外部模式下不实例化A、B、result和稀疏index RAM，只保留双长度product RAM及同一套
  digit-serial乘法/固定归约状态机；
- `trike_poly_inv_core`把乘法A端口接到当前`f/t`、B端口接到`g`，result端口按公开目的选择写回`f/t`；
- 乘法最后一个归约word写入的同一拍推进addition-chain，避免额外done等待；外部模式的每次稠密乘法固定
  周期为`7*WORDS+WORDS^2*(1+4*DIGITS)`；
- 普通流式稠密/稀疏模式的接口、RAM和周期保持阶段55结构。

验证范围：

- 13-bit求逆toy的两组不同可逆输入继续满足输入与输出环乘为一，固定周期由477拍降为417拍；
- TRIKE-2官方KAT派生的15581-bit$h_0$逐word匹配独立Euclid golden，固定周期由44,010,400拍降为
  43,978,192拍；
- TRIKE-2普通流式乘法保持稠密1,967,372拍、稀疏60,826拍，两个golden均逐word匹配；
- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`、`make test-kem-unit`、
  `make test-trike-poly-reference`、`make test-trike-poly-inv-reference`、`make test-unit`、
  `make test-integration`和一组BIKE随机回归通过；随机seed 1固定7轮、543,941拍、残余重量0。

定量结果：TRIKE-2的word数组逻辑容量从外层三份整环、内部A/B/result三份整环和一份双长度product，
即`7*244*64=124,928 bit`，降为三份整环和一份双长度product，即`5*244*64=78,080 bit`，减少
46,848 bit（37.5%）。求逆减少32,208拍（0.0732%）；乘法主项为$W^2D$，因此本实验的主要目标是RAM
容量而非周期。13-bit toy因线性word开销占比较高，周期减少60拍（12.6%）。

常数时间边界：外部模式只删除固定operand装载和result输出状态；product清零、A/B读取、所有digit乘积、
归约写回和addition-chain次数仍由公开$r$、`WORD_W`和`DIGIT_W`决定。外部valid/ready只存在于整个
求逆输入和最终输出边界，秘密多项式不控制内部握手。

物理验证边界：当前运行环境未发现`vivado`可执行文件，没有生成新的synthesis、placed或routed报告。
逻辑bit减少不等于Block RAM Tile按37.5%下降；LUT、FF、Slice、RAMB36、RAMB18、DSP、setup WNS/TNS
和hold WHS均为待测，外部RAM地址mux对Fmax的影响也不能由Verilator功能回归判断。

结论与状态：保留。外部RAM模式在不改变golden和固定调度的前提下消除了三份重复整环存储。取得目标
Vivado环境后，需要使用同一器件、版本、XDC和报告阶段比较阶段56/57的Block RAM Tile、top path、
Fmax和`cycles/Fmax`；下一项独立RTL工作为单物理SM3压缩服务。

### 阶段58：单物理SM3压缩服务与KEM公共核Vivado检查点（2026-07-31）

目标与假设：DF、HMAC、DRNG和pseudohash内部的多个hash阶段均按公开FSM串行执行，可让多个
`sm3_hash_stream` context时分复用一个`sm3_compress`，减少消息扩展和压缩轮数据通路副本，同时保持
既有接口、摘要结果和固定busy周期。求逆外部RAM模式与共享SM3路径分别建立独立Vivado top，避免两个
架构变量混入同一资源报告。

关键实现：

- `sm3_hash_stream`增加`USE_EXTERNAL_COMPRESS`参数以及block、chaining state、start、busy、done和
  返回state接口；内部模式仍封装一个`sm3_compress`；
- `trike_sm3_service`封装单个物理`sm3_compress`，HMAC内/外层、DRNG Instantiate的两个DF、
  DRNG Generate的输出/更新hash以及pseudohash的HMAC/h1/h2均按公开状态时分复用；
- 复合模块的请求选择只由公开FSM阶段决定，不根据消息、摘要、秘密状态或压缩结果动态仲裁；
- `scripts/check_trike_sm3_sharing.ys`以Yosys层次统计验证每个复合顶层只含一个`sm3_compress`；
- `trike_poly_inv_synth_top`固定使用TRIKE-2的`R_BITS=15581, WORD_W=64, DIGIT_W=8`，
  `trike_pseudohash_synth_top`固定32-byte消息；两个wrapper均使用同步复位释放；
- `constraints/trike_kem_core.xdc`约束100 MHz `core_clk`、0.100 ns不确定度和2 ns实现级I/O delay；
  `scripts/vivado_trike_kem_cores.tcl`执行synthesis、opt、place、phys_opt和route，并输出资源、层次资源、
  setup/hold、methodology、CDC、DRC、messages和DCP。

验证范围：

- `make check-trike-sm3-sharing`通过；HMAC、DRNG Instantiate、DRNG Generate和pseudohash每个
  复合顶层的`sm3_compress`层次实例数均为1；
- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`和`make test-kem-unit`通过；
- DF、Instantiate、Generate和pseudohash512分别保持314、916、708和1,128个busy周期；
- TRIKE-2多项式乘法与求逆reference、完整单元测试、toy集成和一组BIKE随机译码回归保持通过；随机
  seed 1固定7轮、543,941拍、残余重量0。

定量结构结果：pseudohash复合顶层的物理压缩核由HMAC内层、HMAC外层、h1和h2四个副本收敛为1个；
HMAC、DRNG Instantiate和DRNG Generate各自由2个收敛为1个。hash context数保持算法所需数量，
因此该计数不代表LUT按相同比例下降。固定busy周期没有增加，面积、布线和Fmax收益需要Vivado实现确认。

Vivado待测条件：`xc7k355tffg901-2L`、Vivado 2023.2、100 MHz/10 ns、0.100 ns clock uncertainty、
2 ns实现级I/O delay，分别实现TRIKE-2求逆和32-byte pseudohash。当前运行环境没有`vivado`可执行
文件，LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、setup WNS/TNS和hold WHS均为待测。
wrapper未分配package pin，报告只用于公共核实现和内部时序比较。

结论与状态：保留RTL并形成可运行的Vivado检查点。目标环境使用
`make vivado-impl-trike-kem-cores VIVADO_PART=xc7k355tffg901-2L
VIVADO_RUN_TAG=trike_kem_core_shared_sm3`生成两个独立报告目录。共享SM3的物理收益和求逆外部RAM的
实际BRAM映射以该次post-route报告为准。

### 阶段59：TRIKE160 K=4固定点对FLS参数更新（2026-08-01）

目标与依据：将TRIKE-2 K=4局部寻优和预声明固定点对FLS的最新结果写入统一
TRIKE译码参数。寻优固定`alpha=0.1875`和初始LLR 4；FLS点对为
`r=10900`的719/10000失败与`r=11100`的2907/2000000失败，独立seed为
`202607312801605`。连续交点为`r*=12576.529`，目标为`2^-128`。

关键实现：

- 向上搜索并独立检查得到首个满足素数且 2 为模`r`本原元的合法值`r=12589`；
- `rtl/bike_pkg.sv`的TRIKE160参数更新为`R=12589`、`C_VAL=4`，`W=35`、`T=263`、
  5-bit消息、K=4、7轮固定调度和alpha移位`3/4`保持不变；
- 随机fixture参数、C参考模型和KEM软件profile同步同一`R/C_VAL`；
- BF/BGF阈值未写入公开参数表，仍由软件按具体`r`自动计算。

验证范围与定量结果：

- `L=32`、`COLS_PER_TILE=1152`的seed 1回归为337,245拍，
  `target_weight=263`、`output_weight=263`、`residual=0`、`exact=1`；
- `L=16`、`COLS_PER_TILE=1168`的seed 1回归为657,271拍，输出重量、残余综合征和
  exact结果相同；
- 与旧`r=12899`相比，L=32固定周期由365,980降为337,245，减少28,735拍
  （7.85%）；L=16由713,271降为657,271，减少56,000拍（7.85%）。

置信与物理验证边界：合法`r`处的FLS 95% DFR上界为`1.0215e-39`，即
`2^-129.52`。该结果是有限样本和FLS模型外推，不是在目标DFR处的直接观测。本次没有
新的Vivado结果；LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、setup WNS/TNS
和hold WHS均待相同器件、Vivado、XDC和报告阶段复测。

结论与状态：保留。TRIKE160当前K=4参数为`R=12589`、`C_VAL=4`；译码RTL仍执行
由公开等级决定的7轮固定周期，仿真端的收敛提前退出不改变硬件调度。

### 阶段60：TRIKE256 K=4固定点对FLS参数更新（2026-08-02）

目标与依据：将TRIKE-5 K=4局部寻优和预声明固定点对FLS的最新结果写入统一
TRIKE译码参数。寻优结果为`alpha=0.1875`、初始LLR 5；FLS点对为
`r=24800`的154/10000失败与`r=25200`的392/2000000失败，独立seed为
`202607312562501`。连续交点为`r*=30358.007`，目标为`2^-256`。

关键实现：

- 向上搜索并独立检查得到首个满足素数且 2 为模`r`本原元的合法值`r=30389`；
- `rtl/bike_pkg.sv`的TRIKE256参数更新为`R=30389`；`C_VAL=5`、`W=55`、`T=429`、
  5-bit消息、K=4、7轮固定调度和alpha移位`3/4`保持不变；
- 随机fixture参数、C参考模型和KEM软件profile同步同一`R/C_VAL`；
- BF/BGF阈值未写入公开参数表，仍由软件按具体`r`自动计算。

验证范围与定量结果：

- `L=32`、`COLS_PER_TILE=1152`的seed 1回归为1,252,957拍，
  `target_weight=429`、`output_weight=429`、`residual=0`、`exact=1`；
- `L=16`、`COLS_PER_TILE=1168`的seed 1回归为2,441,942拍，输出重量、残余综合征和
  exact结果相同；
- 与旧`r=29917`相比，L=32固定周期由1,207,807增加为1,252,957，增加45,150拍
  （3.74%）；L=16由2,353,952增加为2,441,942，增加87,990拍（3.74%）。

置信与物理验证边界：合法`r`处的FLS 95% DFR上界为`1.8200e-78`，即
`2^-258.25`。该结果是有限样本和FLS模型外推，不是在目标DFR处的直接观测。本次没有
新的Vivado结果；LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、setup WNS/TNS
和hold WHS均待相同器件、Vivado、XDC和报告阶段复测。

结论与状态：保留。TRIKE256当前K=4参数为`R=30389`、`C_VAL=5`；译码RTL仍执行
由公开等级决定的7轮固定周期，仿真端的收敛提前退出不改变硬件调度。

### 阶段61：TRIKE384 K=4固定点对FLS参数更新（2026-08-04）

目标与依据：将TRIKE-7 K=4扩大局部寻优和预声明固定点对FLS的结果写入统一
TRIKE译码参数。硬件合法的9个alpha与整数LLR 1至9的81个粗筛候选中，寻优结果为
`alpha=0.140625`、初始LLR 5，精筛为231/100000失败。FLS点对为`r=52600`的
45/10000失败与`r=53100`的179/2000000失败，独立seed为`202607313845291`。
连续交点为`r*=63735.176`，目标为`2^-384`。

关键实现：

- 向上搜索并独立检查得到首个满足素数且2为模`r`本原元的合法值`r=63773`；
- `rtl/bike_pkg.sv`的TRIKE384参数更新为`R=63773`；`C_VAL=5`、`W=83`、`T=659`、
  5-bit消息、K=4、7轮固定调度和alpha移位`3/6`保持不变；
- 随机fixture参数、C参考模型和KEM软件profile同步同一`R/C_VAL`；
- BF/BGF阈值未写入公开参数表，仍由软件按具体`r`自动计算。

验证范围与定量结果：

- `make format-rtl`、`make check-format-rtl`、`make lint-rtl`、`make test-unit`和
  `make test-integration`通过；
- `L=32`、K=4、`COLS_PER_TILE=1152`的五档seed 1回归均为`residual=0`、`exact=1`，
  周期为193,514、337,245、1,252,957、3,866,043和8,538,564；
- `L=16`、K=4、`COLS_PER_TILE=1168`的TRIKE384 seed 1回归为7,402,016拍，
  `target_weight=659`、`output_weight=659`、`residual=0`、`exact=1`；
- C参考模型的TRIKE384 seed 1为`decision_weight=659`、`residual=0`、`exact=yes`；
- 五档TRIKE KEM软件自检通过，TRIKE384的正常密文有效且篡改密文执行隐式拒绝。

与`r=63997`的历史功能检查点相比，L=32固定周期由3,866,092降为3,866,043，
减少49拍（约0.0013%）；L=16由7,402,114降为7,402,016，减少98拍（约0.0013%）。
两种并行度的tile数分别保持L=32的56个和L=16的55个，因此周期只有少量改变。

置信与物理验证边界：合法`r`处的FLS 95% DFR上界为`6.0288e-117`，即
`2^-386.07`。该结果是有限样本和FLS模型外推，不是在目标DFR处的直接观测。本次没有
新的Vivado结果；LUT、FF、Slice、Block RAM Tile、RAMB36、RAMB18、DSP、setup WNS/TNS
和hold WHS均待相同器件、Vivado、XDC和报告阶段复测。

结论与状态：保留。TRIKE384当前K=4参数为`R=63773`、`C_VAL=5`；译码RTL仍执行
由公开等级决定的7轮固定周期，仿真端的收敛提前退出不改变硬件调度。

### 阶段62：TRIKE KEM公共核Vivado首轮实现与pseudohash窄I/O封装（2026-08-04）

目标与假设：在Vivado 2023.2、`xc7k355tffg901-2L`上实现TRIKE-2求逆核和32-byte
pseudohash核，检查公共核资源、100 MHz时序与封装边界。实现用top需要保留完整功能逻辑，同时不能把
内部宽状态直接映射为物理package I/O。

首轮结果：

- `trike_poly_inv_synth_top`完成placement和routing，报告2,132 Slice LUT、611 Slice Register、
  720 Slice、4 Block RAM Tile（4个RAMB36E1）、0 DSP和138 Bonded IOB；
- 10 ns时钟下setup WNS为0.364 ns、TNS为0，hold WHS为0.080 ns、THS为0；
- 工程同时加载`decoder.xdc`和`trike_kem_core.xdc`，产生clock覆盖；KEM XDC中的`if`与
  `remove_from_collection`被工程模式XDC reader忽略，timing summary仍有136项缺失I/O delay；
- `trike_pseudohash_synth_top`综合得到12个IBUF和516个OBUF，共528个顶层I/O，超过器件300个
  Bonded IOB，implementation在I/O placement阶段失败。516个输出由512-bit摘要和4个状态信号组成，
  不是pseudohash内部运算资源耗尽。

关键实现：

- pseudohash实现wrapper使用64-bit result valid/ready流，按MSB优先固定输出8个word，并保留last；
- wrapper在输出停顿时保持word、valid和last，结果全部握手后发出done；顶层I/O从528降为83；
- `trike_kem_core.xdc`使用`get_ports -filter`静态集合表达式，对数据输入和全部输出施加2 ns delay；
- KEM公共核工程只使用`trike_kem_core.xdc`，不加载译码器`decoder.xdc`。

验证范围：pseudohash本体标准fixture继续逐bit匹配，新增wrapper测试覆盖两遍输入、64-bit八拍摘要重组、
输出backpressure和last。RTL格式、lint和KEM单元回归通过。窄I/O wrapper在相同Vivado、器件和
100 MHz约束下完成route，使用9,711 LUT、8,767 FF、4,029 Slice、0 Block RAM Tile、0 DSP和83
Bonded IOB。

窄I/O routed timing整体setup WNS为-2.008 ns、TNS为-118.367 ns，共70个失败端点；hold WHS为
0.051 ns、THS为0。失败端点数与70个输出bit一致，top paths均为摘要或word选择寄存器经过LUT/MUXF7
和OBUF到`o_result_data[*]`，并计入2 ns output delay。内部寄存器到寄存器没有出现在失败top path中，
其精确WNS需从现有routed checkpoint用register-to-register限定报告确认。

register-to-register限定报告得到WNS 0.883 ns，内部100 MHz通过；按`1/(10-0.883 ns)`估算的内部Fmax
约109.7 MHz，对应1,128核心busy周期约10.29 us。最差内部路径从共享SM3的`o_done`到HMAC outer
`chaining_state_q[*].CE`，数据延迟8.431 ns中逻辑0.359 ns、路由8.072 ns，扇出先为31再形成256-bit
状态CE网。该路径表明下一项时序优化是共享完成信号的本地寄存/复制，不是增加SM3算术流水。

hierarchical report中，单个`sm3_compress`占5,293 LUT/3,002逻辑FF；HMAC占2,061/2,627，H1占
1,445/1,044，H2占766/1,043，pseudohash本层占151/1,044。flat physical report为9,711 LUT和
8,767 Slice Register，hierarchical顶层为8,795逻辑FF；前者用于物理总量，后者只用于层次归因。
当前0 BRAM说明message schedule与各hash context block/chaining buffer全部由FF/LUT承载。

结论与状态：保留窄I/O wrapper和工程模式兼容XDC。求逆首轮资源能够说明逻辑已被实现，但由于重复clock
和I/O路径未约束，不作为最终Fmax或板级I/O签核。pseudohash窄I/O实现解决了package IOB超限，物理
资源结果保留；片内核100 MHz通过，带2 ns外部output delay的wrapper整体时序未通过。完整KEM把摘要
写入片内RAM/寄存器时采用内部时序结论；若该wrapper用于板级流接口，则对64-bit输出增加寄存流水。
面积优化优先统一四个顺序hash context，其次评估68×32-bit schedule同步RAM；时序优化优先对
compress-done和256-bit状态CE进行本地寄存/物理复制。

### 阶段63：H4错误采样与Encaps u/v共享乘法调度（2026-08-04）

目标与假设：先形成可由官方公钥独立驱动的Encaps算术链，避免完整KEM顶层同时引入KeyGen弱密钥重采样
和Decaps译码边界。H4必须保持Reference C每个candidate单独Generate(4 byte)的状态更新语义；
`e0/e1/e2`的秘密分块重量不能改变后续乘法装载数量和执行周期。

关键实现：

- `trike_drng_weight_sampler`复用一个Generate context，每个candidate接收4个byte并按little-endian
  `uint32_t`组装，完成状态更新后才向固定重量采样器提交随机数；
- `trike_h4_error_sampler`执行Instantiate(`m || r2`)和固定`t`次Generate(4 byte)，整个组合按公开阶段
  共享一个`trike_sm3_service`；
- `trike_encaps_uv_core`保存`t`个全局错误位置，复用一个`trike_poly_mul_core`顺序计算
  `e1*r1`、`e2*r2`、`e1*t1`、`e2*t2`，使用e0/u/v三个word RAM形成最终结果；
- 四次乘法均回放全部`t`个support位置，不属于目标块的位置使用`index=R_BITS`的越界零贡献dummy。
  有效项和dummy执行相同B扫描、result读改写和状态路径。

验证范围与定量结果：

- 独立Python SM3 fixture逐次检查三个Generate(4 byte)输出、候选位置和最终DRNG状态；含3拍index输出
  backpressure的组合固定1,448拍；
- H4 toy对拍Instantiate(`m || r2`)、三个错误位置和最终`V/C/reseed_counter`，连续输入输出固定
  2,313拍；Yosys层次检查H4组合恰好包含一个`sm3_compress`；
- 13-bit u/v toy用独立GF(2)循环乘法模型检查四次乘法和最终word流。`e0/e1/e2`重量分别为`2/1/2`
  与`0/3/2`时均为384拍；3拍结果backpressure使总周期固定增加3拍；
- RTL格式、Verible lint、全部KEM单元回归和SM3层次共享检查通过。真实TRIKE-2的H4/u/v固定周期、
  LUT、FF、Slice、Block RAM Tile、RAMB36/RAMB18、DSP、setup WNS/TNS和hold WHS均待测。

结论与状态：保留。Encaps继续按H1/H2/H3、阶段控制、L/K与序列化顺序闭环；KeyGen在固定候选预算和
失败行为确定后实现，避免把数据相关弱密钥重试带入完整KEM固定周期基线。

### 阶段64：H1/H2/H3组合向量服务（2026-08-04）

目标与假设：把Encaps、KeyGen和Decaps都会调用的`generate_hash_vectors`形成独立固定调度服务，保持
Reference C中同一DRNG context连续三次Generate(`R_BYTES`)的状态边界，并为完整KEM保留单SM3物理核
接口。

关键实现：`trike_h123_vectors`先从可重放`sigma`流执行Instantiate，再用一个Generate context依次产生
`t1/t2/r1`。三次原始byte流通过同一个`trike_parity_map_stream`，目标parity固定为偶、偶、奇；只有前一
次Generate状态更新与parity输出均完成后才启动下一次。Instantiate和Generate的压缩请求由公开FSM选择，
默认独立实例包含一个`trike_sm3_service`，外部压缩端口允许完整KEM并入全局服务。

验证范围与定量结果：13-bit、4-byte顺序seed的fixture由独立Python `hashlib` SM3模型生成，三组映射
结果逐byte为`2d00`、`7908`和`210d`，最终440-bit `V/C`及`reseed_counter=4`匹配。测试加入3拍输出
backpressure并检查payload稳定，busy固定2,281拍。Yosys层次检查组合顶层恰好包含一个`sm3_compress`；
RTL格式、KEM单元回归和共享检查通过。真实TRIKE-2 `R_BYTES=1948`配置的固定周期、LUT、FF、Slice、
Block RAM Tile、RAMB36/RAMB18、DSP、setup WNS/TNS和hold WHS均待测。

结论与状态：保留。下一阶段从官方KAT提取Encaps输入和中间向量，连接H1/H2/H3、H4、u/v与pseudohash
消息RAM，形成不依赖KeyGen硬件的Encaps端到端链。

### 阶段65：官方TRIKE-2 Encaps组件对拍与错误向量持久存储（2026-08-05）

目标与假设：在编写Encaps单顶层前，先锁定官方KAT中未直接打印的随机消息、所有中间向量、密文序列化和
真实参数固定周期；H4的稀疏support与L所需padded dense error必须由同一组位置确定性生成。

关键实现：

- `gen_trike_encaps_fixture.py`解析官方Count=0的Seed/PK/CT/SS。全局DRNG在KeyGen依次生成
  `seed/sigma2/sigma`，秘密采样使用局部DRNG，因此第四次32-byte Generate恢复Encaps消息`m`；
- Python独立SM3/SM3-DRNG/HMAC-SM3模型重算H1/H2/H3、263个H4位置、四次环乘、三个独立1,984-byte
  padding块、`c2`和`K(m||ct)`，生成fixture前强制逐byte匹配官方3,928-byte CT和32-byte SS；
- `trike_error_support_store`固定清零5,952-byte dense RAM，对每个位置执行一次support写入和dense byte
  读改写；`trike_h4_error_vector`把H4与该存储组合并保留外部SM3压缩端口；
- 新增真实参数组件、L/K摘要、错误RAM和H4 error-vector四组Reference testbench。

验证范围与定量结果：

- 官方TRIKE-2 H1/H2/H3、H4与u/v逐byte/逐word匹配，连续流busy周期分别为44,640、207,017和
  1,805,550拍；单复用稀疏乘法核的u/v是当前Encaps主要固定延时；
- 完整5,952-byte L输入和3,960-byte `m||ct`输入的512-bit pseudohash摘要匹配独立模型，固定周期分别为
  34,916和23,616拍；摘要前32 byte分别匹配`m xor c2`和官方SS；
- error store逐项检查263-entry support RAM和全部5,952个dense byte，固定6,478拍；H4与store并行启动的
  组合固定207,018拍，RAM清零被长seed Instantiate阶段覆盖；
- RTL格式检查通过。所有周期均为连续输入输出的RTL结果；新增组合尚无Vivado LUT、FF、Slice、
  Block RAM Tile、RAMB36/RAMB18、DSP、setup WNS/TNS和hold WHS报告。

结论与状态：保留。官方Encaps算法、随机消息恢复、字节序列化和各组件真实参数行为已经锁定；下一阶段只
剩阶段总控制、operand RAM适配、L/K重放和窄I/O密文/共享密钥串行器，不需要等待硬件KeyGen。

### 阶段66：TRIKE-2完整Encaps固定调度顶层（2026-08-05）

目标与假设：把阶段65锁定的组件组合为一个可综合窄I/O顶层，避免把公钥、多项式、错误向量或摘要直接
展开为package引脚；所有片内消息重放、RAM预取和阶段选择必须只由公开参数及计数器控制。

关键实现：

- `trike_encaps_core`从单8-bit输入流加载官方格式`r2 || sigma || m`，使用64-bit同步word RAM保存
  `r2/t1/t2/r1/u/v`，小型byte寄存器保存`sigma/m/c2`；
- H123输出按little-endian聚合为word，H4 support以同步RAM一拍预取后固定回放263项，UV operand在每次
  乘法开头预取首word并在握手边界预取下一word；
- L从5,952-byte padded error RAM执行两遍固定重放，K从`m || u || v || c2`执行两遍固定重放；
  `c2`按32个公开byte顺序写回，密文与共享密钥分别用8-bit valid/ready流输出；
- H123、H4、L和K的压缩请求由公开FSM mux连接到一个`trike_sm3_service`，各阶段顺序执行。
- `trike_encaps_synth_top`加入异步置位、同步释放reset wrapper，保留8-bit数据流边界；
  `vivado_trike_kem_cores.tcl`加入该顶层的独立源文件清单和实现入口。

验证范围与定量结果：官方TRIKE-2 Count=0从输入到输出完整运行，3,928-byte CT和32-byte SS逐byte匹配
fixture；连续输入、连续接收时固定2,121,759个busy周期并由testbench断言。Yosys层次检查、RTL格式、
Verible lint和KEM/官方组件回归纳入验证入口。该结果属于RTL功能与固定周期证明；目标
`xc7k355tffg901-2L`上的LUT、FF、Slice、Block RAM Tile、RAMB36/RAMB18、DSP、setup WNS/TNS、hold
WHS和实际Fmax均待Vivado测量。

结论与状态：保留。Encaps已经形成端到端功能基线；下一项先建立窄I/O Vivado物理基线，再进入需要明确
固定弱密钥候选预算的KeyGen。

## 形成的设计结论

1. 存储优化必须以目标器件的原生宽深模式和 BRAM Tile 为依据；只改数组声明或逻辑字段宽度不能保证映射。
2. 深 RAM 使用显式分段可以换取确定的容量结果，但 segment 译码和使能扇出必须进入 routed timing 检查。
3. 浅而宽的 tile 工作状态更适合 distributed RAM，深状态更适合 block RAM。
4. 固定流水可以同时改善地址关键路径和布局，并将新增拍数纳入公开参数决定的固定周期预算。
5. RTL 运算符更少、表达式更短或实例数量更少，都不能单独作为资源优化成立的依据。
6. 每项方案需要同时比较 LUT、FF、Slice、BRAM Tile、routed setup/hold 和固定周期功能回归。
7. 器件、速度等级、参数、XDC 或 Vivado 版本变化后的报告不能与基线直接计算增减量。
8. 切断一条关键路径可能把瓶颈转移到相邻流水；只有 routed top-path 集合和固定译码时间共同改善时，才能
   判定为时序性能收益。

### 阶段67：完整Encaps首轮物理基线与关键路径寄存分段（2026-08-05）

目标与假设：根据完整TRIKE-2 Encaps的首轮Fully Routed报告，分离package I/O边界和片内关键路径，
用固定寄存边界切断RAM到OBUF、H123完成脉冲高扇出以及稀疏乘法组合移位到BRAM写数据三类路径。所有
新增状态只由公开计数器、ready/valid握手或固定阶段完成脉冲控制，不引入秘密相关调度。

首轮物理基线：用户提供的报告使用Windows Vivado 2023.2、`xc7k355tffg901-2L`、10 ns时钟、
0.100 ns clock uncertainty、2 ns I/O delay，设计`trike_encaps_synth_top`为Fully Routed。

| 指标 | 首轮Encaps检查点 |
| --- | ---: |
| LUT / FF / Slice | 48,575 / 60,982 / 24,554 |
| RAMB36 / RAMB18 / Block RAM Tile | 15 / 3 / 16.5 |
| DSP / IOB | 4 / 37 |
| 整体setup WNS / TNS / failing endpoints | -3.937 ns / -214.375 ns / 435 |
| 内部register-to-register WNS | -1.534 ns |
| hold WHS | +0.034 ns |

hierarchical utilization中H123为17,032 LUT/27,472 FF，其中Generate为7,205/5,478、共享SM3为
6,026/3,000；H4错误采样约8,072/11,137；L和K分别为5,662/5,776和4,841/5,772；UV为
3,289/632及7 RAMB36/2 RAMB18。整体最差路径来自片内输出RAM，经byte选择网络和OBUF到package输出。
内部最差路径从`u_h123/u_generate/generate_done`到父级440-bit状态寄存器，扇出1,322、数据路径
11.158 ns，其中route为10.856 ns。第二组负裕量路径从稀疏乘法`b_word_idx_q`到result RAM `DI`，
约10.8至10.93 ns、34级逻辑，其中约7.5 ns为route、3.39 ns为logic。

methodology报告共137项warning：49项DPIR-1来自采样器32x32 multiply-high的异步复位输入寄存器不能
合入DSP输入寄存器，4项SYNTH-10对应预期DSP乘法，49项TIMING-16包含内部和I/O负裕量，35项XDCH-2
来自输入输出min/max delay同时为2 ns。reset BUFG扇出38,244但slack为+2.516 ns，不是该检查点的
setup瓶颈。DPIR-1的同步复位或DSP输入流水调整会改变采样器寄存边界，留待本阶段物理复测后单独探索。

关键实现：

- `trike_encaps_synth_top`在8-bit输入端加入单项寄存缓冲，密文和共享密钥使用片内暂存寄存器加IOB输出
  寄存器两级边界；done只在最后一个共享密钥byte被外部接收时产生；
- `trike_h123_vectors`将Generate完成脉冲寄存复制为12组，分别控制V/C/reseed三份440-bit状态的四个
  110-bit分组；
- `trike_poly_mul_core`在每个稀疏B word开始时寄存三组贡献与result地址，后续三次BRAM读改写不再经过
  `b_word_idx_q`到循环移位和地址计算的完整组合链；FSM状态数和稀疏乘法周期公式不变；
- XDC明确使用输入输出max 2 ns、min 0 ns；Vivado脚本增加内部register-to-register setup和高扇出报告。

验证范围与定量结果：RTL格式、Verible lint、KEM单元测试、单SM3层次检查、官方组件、L/K、错误存储、
H4向量、原始Encaps核和寄存I/O wrapper完整回归通过。H123 toy由2,281拍变为固定2,284拍，真实TRIKE-2
H123保持44,640拍；官方多项式稠密/稀疏周期保持1,967,372/60,826拍。原始Encaps核保持2,121,759拍；
wrapper连续流为2,127,733拍，增加5,974拍固定接口开销，3,928-byte CT与32-byte SS均匹配官方KAT。

物理复测结果：用户提供的第二组报告使用相同Vivado 2023.2、`xc7k355tffg901-2L`、10 ns时钟、
0.100 ns uncertainty和Fully Routed阶段。资源与时序如下：

| 指标 | 首轮检查点 | 寄存分段RTL | 变化 |
| --- | ---: | ---: | ---: |
| LUT | 48,575 | 47,859 | -716 |
| FF | 60,982 | 61,222 | +240 |
| Slice | 24,554 | 23,354 | -1,200 |
| RAMB36 / RAMB18 / Tile | 15 / 3 / 16.5 | 15 / 3 / 16.5 | 不变 |
| DSP / IOB | 4 / 37 | 4 / 37 | 不变 |
| 整体setup WNS / TNS | -3.937 ns / -214.375 ns | +0.025 ns / 0 | WNS +3.962 ns |
| 内部register-to-register WNS | -1.534 ns | +0.378 ns | +1.912 ns |
| hold WHS / THS | +0.034 ns / 0 | +0.050 ns / 0 | WHS +0.016 ns |

整体最差setup路径为IOB寄存的`o_done`经OBUF到输出端口。内部最差路径从共享SM3压缩状态
`o_state_reg[119]`到L的H2摘要寄存器，数据路径9.761 ns，其中route 9.538 ns、logic 0.223 ns、0级
组合逻辑；H123 Generate完成脉冲与稀疏乘法BRAM写数据路径均退出内部前20条。高扇出报告中reset BUFG
slack为+6.335 ns；其余1320级DRNG控制网络最差slack为+1.638 ns。按内部WNS作一阶外推约
103.93 MHz，不是超频签核；2,127,733拍在100 MHz下为21.27733 ms。

约束边界：该Vivado工程仍引用工程目录中旧的导入XDC副本，第16和18行分别是未区分min/max的2 ns
input/output delay，因此methodology仍报告35项XDCH-2。仓库`constraints/trike_kem_core.xdc`已使用
max 2 ns、min 0 ns；替换工程副本后需要重新生成timing summary和methodology。49项DPIR-1和4项
SYNTH-10分别对应采样器异步复位DSP输入与预期的multiply-high DSP分解，不是当前top path。

结论与状态：寄存分段RTL保留，功能、固定周期和片内100 MHz物理验证完成；LUT与Slice同时下降，FF小幅
增加，BRAM/DSP不变。当前进入KeyGen固定候选预算与微程序实现；板级I/O约束状态在工程XDC更新前保持
待签核。

### 阶段68：KeyGen固定候选秘密采样与弱密钥检测（2026-08-05）

目标与假设：消除Reference C在弱密钥时继续重采样产生的数据相关循环，先闭合KeyGen的
`h0/h1/h2`生成边界。候选预算、每组采样数、六项弱检测和结果复制长度均由公开TRIKE参数决定；弱检测
结果只允许控制首个合格候选的写mask和最终success，不进入调度状态转移条件。

关键实现：

- `trike_weak_key_test`使用一份8-bit、深度`r`的同步距离直方图RAM，依次执行三项自相关和三项互相关；
  每项固定完成全RAM清零、公开pair数的读改写和固定score地址扫描，累计`sum C(count[d],2)`；
- `trike_keygen_secret_sampler`从一个32-byte seed实例化DRNG，固定执行16组候选；每组顺序调用三次
  weight-35采样并执行完整弱检测，DRNG状态跨全部48次采样连续传递；
- 首个合格候选在每组固定105拍复制扫描期间通过write mask保存；后续候选仍完整运行。16组均不合格时
  固定完成并返回`success=0`和全零support，上层不得在本次调用内转入秘密相关重试；
- fixture生成器直接解析官方TRIKE-2 Count=0，并额外确定性搜索一组候选0弱、候选1合格的调度向量。

验证范围与定量结果：13-bit toy的两组support逐项匹配六项分数和弱键判定，均固定330拍。官方
TRIKE-2 Count=0 support分数为`28/19/16/50/48/51`，弱检测固定244,638拍。完整秘密采样器逐项匹配
105个support索引、首个候选号、六项分数和跑满16组后的`V/C/reseed_counter`；候选0合格与候选0弱、
候选1合格两种输入的busy周期均为4,778,975拍。10,000个确定性软件样本中首候选弱22次，最长连续弱
候选为1；该样本不构成16组全弱失败概率的严格证明。

本阶段完成RTL格式、Verible lint、KEM单元测试和两组真实参数回归。尚未运行Vivado；LUT、FF、Slice、
Block RAM Tile、RAMB36/RAMB18、DSP、setup WNS/TNS、hold WHS和Fmax均为待测。完整KeyGen还需要接通
H1/H2/H3、两次求逆、环乘法、sigma/sigma2保存和PK/SK序列化。

结论与状态：保留固定16候选架构作为KeyGen秘密support阶段的常数周期基线。下一步实现KeyGen算术
微程序，并保持所有乘法、求逆和RAM回放次数由公开参数固定。

### 阶段69：KeyGen固定环算术微程序与官方t0/r2闭环（2026-08-06）

目标与假设：在秘密support阶段之后闭合KeyGen的两个除法表达式，并复用已有环乘法和固定加法链求逆核。
四次乘法、两次求逆、operand装载、结果写回和输出扫描均由公开`r/d/WORD_W/DIGIT_W`决定；多项式值与
support位置只影响RAM数据和XOR mask，不改变FSM状态数或访问次数。

关键实现：

- `trike_keygen_arith_core`用七份word RAM保存`t1/t2/r1`、共享分子、共享逆元、`t0/r2`；三组
  support保留为index数组，并按当前公开word地址生成稀疏mask；
- 一个外层`trike_poly_mul_core`依次执行`h0*r1`、分子乘第一逆元、`t0*t2`和分子乘第二逆元；
- 一个`trike_poly_inv_core`依次计算`inverse(t1+r1)`和`inverse(t0+h0)`，核内同一个乘法器复用全部
  固定加法链乘法；
- `h1/h2`在对应乘法结果写入共享分子RAM时XOR，`h0`在第二分母送入求逆核时XOR，避免增加独立
  全向量加法阶段；
- KeyGen fixture从官方Count=0恢复`t1/t2/r1/t0/r2`，同时保留秘密采样fixture的support和DRNG证据。

验证范围与定量结果：13-bit、`SECRET_WEIGHT=3`的两组不同输入逐项匹配独立Python环算术，均固定925拍。
TRIKE-2、`R_BITS=15581`、`WORD_W=64`、`DIGIT_W=8`下，从官方`t1/t2/r1`和105个support开始，输出
244个`t0` word与244个`r2` word全部匹配KAT，连续握手busy周期固定93,924,706拍。该周期包含一次
稀疏乘法、三次稠密乘法、两次固定链求逆和两段结果输出，不包含秘密采样、H1/H2/H3或PK/SK序列化。

RTL格式、Verible lint、KEM单元回归、官方算术回归和Yosys层次解析通过。Yosys层次解析使用未提供XPM
定义的黑盒边界，不证明Vivado Block RAM映射。尚未运行本模块Vivado；LUT、FF、Slice、Block RAM Tile、
RAMB36/RAMB18、DSP、setup WNS/TNS、hold WHS与Fmax均为待测。

资源复用边界：当前算术核有两个物理乘法数据通路，即外层通用乘法器与求逆核内部乘法器。它们在KeyGen
中不并发；将两者收敛为一个实例需要把求逆核改成外部乘法请求/响应接口。该重构可能减少product RAM，
但会改变求逆接口和固定周期，留到完整KeyGen顶层功能闭合后作为独立物理优化实验。

结论与状态：保留当前两数据通路结构作为完整KeyGen集成前的功能和固定周期基线。下一步连接秘密采样、
H1/H2/H3、算术结果存储和PK/SK窄流序列化。

### 阶段70：完整KeyGen固定微程序与官方PK/SK闭环（2026-08-06）

目标与假设：把固定候选秘密采样、H1/H2/H3、KeyGen算术和官方密钥布局连接为一条完整硬件微程序。
外部随机源边界固定为Reference C的三次32-byte请求，所有内部阶段、RAM扫描和输出长度由公开参数决定；
秘密候选是否合格只进入首个结果写mask和最终success状态。

关键实现：

- `trike_keygen_core`输入96 byte `key_seed || sigma2 || sigma`，缓存后顺序启动秘密采样、H123和算术核；
- 秘密采样器与H123均使用外部压缩端口，顶层公开FSM将两者请求mux到一个`trike_sm3_service`；
- 秘密support输出同时保存到顶层数组并装载算术核；H123 byte输出按little-endian每8 byte组成operand word，
  最后一个非对齐word的未使用bit保持零；
- 算术核的`t0/r2`输出保存到两份同步word RAM。PK固定输出`r2 || sigma`共1,980 byte；SK固定输出三组
  32-bit little-endian support、`h0 || t0 || r2 || sigma || sigma2`共6,328 byte；
- fixture生成器从官方KAT恢复完整随机输入和PK/SK，并独立计算一组候选0弱、候选1合格的完整密钥golden。

验证范围与定量结果：官方Count=0完整1,980-byte PK和6,328-byte SK逐byte匹配；补充输入的候选0弱、
候选1合格，完整PK/SK同样逐byte匹配独立Python环算术与序列化。两组连续输入输出busy周期均为
98,757,463拍。该周期包含96-byte输入、固定16候选秘密采样、H123、四次外层环乘、两次固定链求逆及
PK/SK序列化；外部主动施加的valid空拍或ready停顿不计入连续流周期。

RTL格式、Verible lint、KEM单元回归、完整KeyGen双向量回归与Yosys共享层次检查通过。层次检查确认
`trike_keygen_core`只有一个`sm3_compress`；该检查不证明XPM RAM物理映射。完整KeyGen尚未运行Vivado，
LUT、FF、Slice、Block RAM Tile、RAMB36/RAMB18、DSP、setup WNS/TNS、hold WHS与Fmax均为待测。

常数时间边界：16组均不合格时仍继续H123、算术和固定长度PK/SK输出，并通过`success=0`报告本次调用失败；
模块不执行数据相关内部重试。普通数据翻转活动仍可能随秘密变化，本阶段没有提供功耗masking或平衡逻辑。

结论与状态：完整KeyGen功能和固定周期基线保留。下一步增加窄I/O寄存wrapper及Vivado实现入口，测量两个
物理乘法数据通路、七份算术RAM、两份输出RAM和共享SM3的实际资源与100 MHz时序。

### 阶段71：完整KeyGen窄I/O物理边界与Vivado入口（2026-08-06）

目标与假设：为完整KeyGen建立不会导出多项式或密钥RAM的实现顶层，避免宽输出造成Bonded IOB超限，并在
核与实现级I/O delay之间插入明确的寄存边界。wrapper只改变公开握手流水，不改变秘密候选、哈希、环算术
或密钥序列化算法。

关键实现：

- `trike_keygen_synth_top`固定TRIKE-2参数，外部使用8-bit随机输入、8-bit PK输出和8-bit SK输出；
- 三条数据流各设置一项片内缓冲，PK/SK再经过标记`IOB=TRUE`的valid/data/last寄存器；
- 顶层只导出时钟、复位、启动、三条窄数据流和`busy/done/success`，所有support、多项式word和结果RAM
  保持在层次内部；
- `scripts/vivado_trike_kem_cores.tcl`加入完整源文件分支，使用同一100 MHz、0.100 ns uncertainty、输入输出
  max 2 ns/min 0 ns约束；Makefile提供独立KeyGen实现入口；
- 共享SM3层次检查覆盖wrapper，确认层次内仍只有一个`sm3_compress`。

验证范围与定量结果：官方Count=0的96-byte随机输入经wrapper产生完整1,980-byte PK和6,328-byte SK，
所有byte与`last`位置逐项匹配。连续外部valid/ready下busy周期固定98,765,138拍，比核心边界增加7,675拍；
输入/输出寄存流水与核心的同步RAM fetch空拍重叠，因此差值不等于输入和输出byte数之和。格式、Verible
lint、wrapper参考向量和Yosys单SM3检查通过。

本阶段未运行Vivado。目标器件为`xc7k355tffg901-2L`、工具目标版本Vivado 2023.2、时钟周期10 ns；
LUT、FF、Slice、Block RAM Tile、RAMB36/RAMB18、DSP、setup WNS/TNS、hold WHS、Fmax及
`98,765,138/Fmax`实际时间均为待测。XDC不分配package pin，结果属于实现级核心基线而非板级I/O签核。

结论与状态：保留窄I/O wrapper和Vivado入口。下一步运行完整placement/routing，检查RAM推断、两个乘法
数据通路的资源、内部register-to-register最差路径和顶层I/O约束状态，再决定是否把两个乘法器重构为单一
共享服务。

### 阶段72：KeyGen SK support顺序输出RAM切断动态索引路径（2026-08-06）

目标与假设：处理完整KeyGen首轮route的最差setup路径，同时只改变SK support的公开序列化存储边界。
秘密采样、H123、算术、共享SM3和候选调度保持不变；新增的写入与读取地址均由固定3组、每组35个support
及每项4 byte的公开布局决定，不根据support值、候选合格位置或`success`改变访问次数。

首轮物理基线来自用户提供的Vivado 2023.2报告，器件为`xc7k355tffg901-2L`，时钟周期10 ns、uncertainty
0.100 ns、实现阶段Fully Routed，顶层为`trike_keygen_synth_top`。报告结果为48,523 LUT、55,622 FF、
23,576 Slice、21 RAMB36、1 RAMB18、21.5 Block RAM Tile、5 DSP和38 IOB；setup WNS/TNS为
-1.812 ns/-403.875 ns，共619个失败端点，hold WHS/THS为+0.049 ns/0。内部与I/O端点均受约束，外部
reset输入使用false path；工程未分配package pin，因此结果属于核心实现基线而非板级I/O签核。

最差路径从`support_flat_q`到wrapper的`sk_buffer_data_q`，数据路径11.478 ns，31级逻辑包含15个
`CARRY4`，logic/route分别为4.029/7.449 ns。原序列化表达式以32-bit `integer support_flat_q`执行
除以35、模35和二维动态索引，使105项support选择网络直接到达wrapper缓冲寄存器。前八条TIMING-16
均为该路径到8个输出数据bit。下一组路径从秘密采样FSM到440-bit `reseed_counter_q/v_q/c_q`，WNS约
-0.884 ns且97.5%数据延迟为route；该高扇出问题不属于本阶段修改范围。

关键实现：

- 秘密采样器固定输出105个support时，顶层继续写稀疏视图和算术核，同时按
  `block*SECRET_WEIGHT+position`写入一份32-bit、深度`3*SECRET_WEIGHT`的`ram_bram`；
- SK输出使用`ST_SK_SUPPORT_FETCH/ST_SK_SUPPORT_DATA`，按地址0至104同步读取，每个word固定输出4个
  little-endian byte；地址计数器宽度为`clog2(3*SECRET_WEIGHT)`，byte计数器为2 bit；
- 删除SK输出端的32-bit扁平计数、除法、取模和105项二维动态索引；新增RAM的物理映射及资源、时序结果
  由同条件Vivado复测确认。

验证范围与定量结果：`make format-rtl`、`make check-format-rtl`、`make lint-rtl`和
`make check-trike-sm3-sharing`通过，层次仍只有一个`sm3_compress`。官方Count=0与候选0弱/候选1合格
两组完整KeyGen均逐byte匹配1,980-byte PK和6,328-byte SK，busy周期同为98,757,568拍；同步fetch使核心
固定增加105拍。窄I/O wrapper官方向量逐byte通过，固定98,765,139拍；wrapper原有交替缓冲空拍覆盖104个
中间fetch，边界总周期只增加1拍。

物理复测使用与首轮相同的Vivado 2023.2、`xc7k355tffg901-2L`、10 ns时钟、0.100 ns uncertainty、
实现级I/O delay和Fully Routed阶段。定量结果如下：

| 指标 | 首轮检查点 | support顺序输出RAM | 变化 |
| --- | ---: | ---: | ---: |
| LUT | 48,523 | 46,859 | -1,664（-3.43%） |
| FF | 55,622 | 54,571 | -1,051（-1.89%） |
| Slice | 23,576 | 21,725 | -1,851（-7.85%） |
| RAMB36 / RAMB18 / Tile | 21 / 1 / 21.5 | 21 / 2 / 22 | RAMB18 +1，Tile +0.5 |
| DSP / IOB | 5 / 38 | 5 / 38 | 不变 |
| setup WNS / TNS | -1.812 ns / -403.875 ns | +0.025 ns / 0 | WNS +1.837 ns |
| setup失败端点 | 619 | 0 | -619 |
| 内部register-to-register WNS | -1.812 ns | +0.414 ns | +2.226 ns |
| hold WHS / THS | +0.049 ns / 0 | +0.050 ns / 0 | WHS +0.001 ns |

层次报告确认`u_support_output_mem`映射为1个RAMB18并使用15 LUT。`trike_keygen_core`本层资源从
2,583 LUT/2,501 FF降至1,052 LUT/1,466 FF，解释了整体资源下降的主要部分；H123、算术、秘密采样和
共享SM3的层次资源仅有实现波动。原`support_flat_q`动态索引路径完全退出内部前20条和高扇出报告。

整体最差setup路径为IOB寄存的`o_pk_valid`经OBUF到输出端口，WNS为+0.025 ns。内部最差路径从秘密
采样FSM到`v_q[371]`，WNS为+0.414 ns，数据路径9.319 ns中9.017 ns为route，扇出1,321；第二条为外层
稀疏乘法`b_word_idx_q`到`sparse_contribution_q`，WNS为+0.416 ns、33级逻辑。H123状态扇出2,144时
slack为+0.852 ns。methodology从61项降至53项，8项TIMING-16全部消失，剩余49项DPIR-1和4项
SYNTH-10；timing summary无未约束路径。

结论与状态：保留support顺序输出RAM结构。该方案用0.5 Block RAM Tile和wrapper固定1拍换取LUT、FF、
Slice同时下降，并使100 MHz整体与内部时序收敛。固定98,765,139拍在100 MHz下为0.98765139 s。当前
不继续修改440-bit高扇出控制；若后续提高频率目标，将高扇出控制与稀疏乘法贡献路径作为两个独立实验。

### 阶段73：Decaps syndrome、decoder装载与固定长度验证边界（2026-08-06）

目标与假设：先闭合Decaps中可独立对拍的三个固定调度边界，再连接完整译码与哈希后处理。syndrome使用
`s=h0*u+t0*(u+v)`，使一项稀疏乘法和一项稠密乘法顺序复用同一个环乘核；错误向量比较按word累计
difference，避免形成最大超过34万bit的单拍XOR树。所有循环数、RAM地址和start次数只由公开参数决定。

关键实现：

- `trike_decaps_syndrome_core`固定装载`h0` support、`t0/u/v`，第一项乘法写syndrome RAM，第二项在
  RAM读写边界XOR；外层四份word RAM保存`t0/u/v/syndrome`，环乘核内部RAM由两个阶段顺序复用；
- `trike_decoder_load_adapter`按block-major输出`3w`项H写请求，把little-endian syndrome word展开为
  恰好`r`次顺序bit写，等待H校验完成后发出一次decoder start；
- `trike_ct_verify_stream`固定同时接收全部reference/candidate word，累计
  `difference |= |(a xor b)`，并把`decoder_ok`与最终相等位一起送入`kem_ct_compare_select`选择正常消息
  或拒绝秘密；首次不匹配位置不控制ready、计数器或结束条件；
- `scripts/gen_trike_decaps_syndrome_fixture.py`直接从官方TRIKE-2 Count=0解析SK/CT，独立计算syndrome
  golden，不复用RTL结果。

验证范围与定量结果：官方TRIKE-2 `r=15581,w=35,t=263,WORD_W=64,DIGIT_W=8`下，35项H0 support、
244个`t0/u/v` word输入后，244个syndrome word全部匹配Python环乘模型，syndrome重量为5,425，连续
握手busy周期固定2,030,223拍。13-bit decoder装载桥检查3组H坐标、全部13次syndrome bit写和单次start。
流式验证toy覆盖全相等、首/中/末word单点不等、decoder失败和一拍输入停顿；前五种连续输入均消费固定
7个word并具有相同内部周期，显式停顿只使外层事务增加1拍。格式与定向Verilator测试通过。

参数边界：官方KAT的TRIKE-2使用`r=15581,w=35,t=263`；当前K-sign译码参数表中相同`w/t`档位使用
FLS选择后的`r=12589`。本阶段只证明官方参数syndrome算术，以及参数化装载/比较控制；没有声称当前
`decoder_top`已经完成官方KAT Decaps。若选择官方KAT闭环，需要新增并验证`r=15581`译码profile；若
选择当前优化参数完整KEM，需要同步产生`r=12589`的KeyGen、Encaps和Decaps向量。

结论与状态：保留三个模块作为Decaps固定调度边界。LUT、FF、Slice、RAMB36/RAMB18、Block RAM Tile、
DSP、setup WNS/TNS、hold WHS和Fmax均待完整Decaps物理顶层建立后测量。下一步先确定统一KEM采用官方
KAT参数还是当前FLS参数，再连接decoder错误读回、L、H4重生成、流式验证和K输出，避免混合两套参数证据。

### 阶段74：`r=12589`固定求逆链与Min-Sum KEM项目向量（2026-08-06）

目标与假设：完整KEM采用当前FLS参数与Min-Sum decoder，不以官方BF Decaps输出作为译码golden。官方
KAT继续约束SM3、DRNG、pseudohash、序列化和环算术语义；当前参数的完整闭环使用单独命名的
`TRIKE_MINSUM_KAT_V1`确定性项目向量。KeyGen求逆链和向量生成均只依赖公开参数与测试seed。

关键实现：

- `scripts/gen_trike_inv_schedule.py`由`r-2`的二进制分解生成Itoh--Tsujii/Frobenius固定链，逐stage验证
  `l0/l1`是对应`2^k mod r`的乘法逆元；
- `trike_inv_schedule_pkg`加入`r=12589`的13个主置换步长和6个累积置换步长；链执行19次稠密乘法、
  20次置换，控制与RAM访问数不依赖被求逆多项式；
- `gen_trike_poly_inv_fixture.py`支持由确定性seed生成可逆稠密输入，扩展Euclid只生成独立golden；
- `gen_trike_minsum_kem_case.py`参数化官方SM3-DRNG、H123、H4、pseudohash和环算术，调用仓库C Min-Sum
  模型执行固定7轮并记录原始错误、syndrome、判决、residual、重生成比较、正常/拒绝SS；
- SK保存原始support顺序，decoder fixture保存每块升序support，以保持既有DFR扫描和`low_index` tie
  定义；`trike_fixed_support_sorter`逐块缓存support，以固定bubble compare-swap次数产生升序流，并接入
  `trike_decoder_load_adapter`的H装载路径。

验证范围与定量结果：`r=12589,WORD_W=64,DIGIT_W=8`的197-word输入/逆元逐word匹配，固定
24,863,614拍。回归`r=15581`官方输入继续逐word匹配并保持43,978,192拍。Min-Sum项目seed 1选择
候选0，weak score为`19/28/30/51/57/60`；PK/SK/CT为1,606/5,206/3,180 byte。H4生成263项错误，
syndrome重量4,741；Min-Sum输出重量263、residual 0、exact true，正常Encaps/Decaps SS相同。固定
翻转`u/v`首bit后均重新执行固定7轮Min-Sum，判决重量为3,306/4,680，residual重量为6,304/6,309；
翻转`c2`首bit保持263项原判决和residual 0，但H4重生成比较失败。三类篡改均产生`sigma2`拒绝SS。
`w=4,BLOCKS=3`排序toy的两组不同输入排列均逐项匹配升序输出，连续握手固定43拍；映射到`w=35`
时每块595次比较，三块从start到末项输出的固定接口预算为1,996拍。该单例是功能向量，不是DFR概率
结论。排序器逻辑存储为35×14 bit，尚无综合或布局布线资源结论。

结论与状态：保留`r=12589`求逆链和项目向量格式。RTL格式、求逆新旧参数对拍和Python生成器检查通过；
固定support排序及其decoder装载连接保留。LUT、FF、Slice、BRAM、DSP、setup/hold与Fmax待目标顶层
实现。下一步补充至少一个合法格式但Min-Sum失败的项目向量，再连接decoder错误读回、L/H4/K后处理。

### 阶段75：decoder判决固定读回与padded error存储（2026-08-06）

目标与假设：Min-Sum完成后需要把串行decision接口转换为`L(e')`和H4比较共用的padded dense error。
读回必须遍历全部`3r`个公开地址，不得根据判决重量、1-bit位置或residual改变读数、写数和完成时刻。
decoder外部读口按同步一拍延迟使用。

关键实现：新增`trike_decoder_error_vector`。每帧先固定清零`3*PADDED_R_BYTES`，随后地址从0到`3r-1`
逐拍请求decision bit，以块内little-endian bit顺序写入byte RAM；每块末尾不足一byte的高bit以及块间padding
保持为零。写地址由公开block/local计数器产生，decision数据只进入byte bit mux，不进入状态转移。

验证范围与定量结果：toy `r=13,BLOCKS=3,PADDED_R_BYTES=4`注入三组不同稀疏decision，12个输出byte
逐项匹配`09 10 00 00 / 82 01 00 00 / 30 08 00 00`，从start到done固定53拍。项目参数
`r=12589,BLOCKS=3,PADDED_R_BYTES=1600`的公开周期公式为
`1 + 4800(clear) + 37767(read) + 1(drain) = 42569`拍，逻辑存储为38,400 bit。尚未使用项目完整向量
对拍该RTL，也没有Vivado综合、布局布线、LUT、FF、Slice、RAMB36/RAMB18、DSP、setup/hold或Fmax结果。

结论与状态：保留固定判决读回与padded error RAM边界。下一步把该RAM的固定4,800-byte读流连接到
`pseudohash`得到`L(e')`，执行`m'=c2 xor L(e')`，再驱动H4和`trike_ct_verify_stream`完成隐式拒绝闭环。

### 阶段76：Min-Sum Decaps后处理L/H4/compare/K闭环（2026-08-08）

目标与假设：以`TRIKE_MINSUM_KAT_V1`而非官方BF输出验证Min-Sum译码后的密码后处理。L、H4、全错误
比较、隐式拒绝选择和K均遍历公开固定长度；error内容、首个差异位置和选择结果不得改变内部循环数、
RAM重放次数或完成时刻。各模块保留external-compress端口，统一顶层再顺序共享一个SM3压缩服务。

关键实现：

- `trike_decaps_message_recover`固定装载32-byte `c2`，按pseudohash两个pass重放4,800-byte padded `e'`，
  保存512-bit `L(e')`并逐byte输出`m'=c2 xor L(e')`；同步RAM握手接受当前byte时预取下一公开地址；
- `trike_decaps_reencrypt_verify`以`m'||r2`驱动`trike_h4_error_vector`，随后同步预取decoder/H4两侧error
  RAM并调用`trike_ct_verify_stream`比较全部4,800 byte；最终选择条件为`decoder_ok && error_equal`；
- `trike_decaps_kdf`锁存选中的`m'`或`sigma2`，两次重放固定3,180-byte ciphertext，输出K摘要前32 byte；
- `gen_trike_minsum_kem_case.py`同时产生RTL fixture，包含padded decoder error、c2、m、r2、sigma2、完整
  ciphertext、L摘要以及正常/拒绝共享密钥golden。

验证范围与定量结果：`r=12589,w=35,t=263,M_BYTES=32,PADDED_R_BYTES=1600`的seed 1项目向量下，L模块
逐byte恢复原消息且512-bit摘要匹配Python；有效error和全零error均固定28,431拍。H4比较模块的有效
重生成error与decoder error全部4,800 byte相等；翻转H4 seed首byte后比较失败并选择`sigma2`，两者均
固定209,659拍。KDF的正常`K(m,ct)`和拒绝`K(sigma2,ct)`各32 byte均匹配Python，两者固定19,323拍。
三个模块的独立连续握手周期和判决读回42,569拍相加为299,982拍，但该和数不包含统一控制器状态边界，
不能作为最终Decaps后处理顶层周期。

结论与状态：保留L恢复、H4重生成/比较/选择和KDF三个固定调度模块。RTL格式、Verible lint、项目向量
逐byte对拍和数据无关周期对比通过。LUT、FF、Slice、RAMB36/RAMB18、Block RAM Tile、DSP、setup
WNS/TNS、hold WHS与Fmax待统一顶层Vivado实现。下一步建立一个窄I/O Decaps控制器，连接syndrome、
support排序/decoder、decision读回和本阶段三个后处理模块，并让L/H4/K顺序共享单个SM3服务。

### 阶段77：单SM3的统一Decaps后处理控制器（2026-08-08）

目标与假设：把阶段76的L、H4/compare/select和K三个独立边界串成一个固定调度复合核，消除三个内部
SM3服务并形成可供完整Decaps顶层调用的单start/done接口。有效性只影响最终mask选择；正常与拒绝路径
必须经历相同状态、相同error/ciphertext RAM地址序列和相同SM3压缩请求数。

关键实现：新增`trike_decaps_postprocess_core`。顶层依次启动message recover、reencryption verify和
KDF，保存32-byte `m'`，固定重放`r2`作为H4 seed后半段，并在K阶段重放完整ciphertext。三个子模块均
设置`USE_EXTERNAL_COMPRESS=1`，顶层按公开互斥状态把compress block/state/start路由到唯一的
`trike_sm3_service`。项目fixture加入`c2`首bit篡改的完整ciphertext与拒绝SS。

验证范围与定量结果：`r=12589,w=35,t=263` seed 1下，正常路径的H4比较为equal并输出与Encaps一致的
32-byte SS；`c2`首bit篡改路径保持同一decoder error，恢复不同`m'`、H4全长比较失败、选择`sigma2`，
最终32-byte SS逐项匹配`K(sigma2,tampered_ct)`。两条连续握手路径从postprocess start到末个SS接受均为
257,417拍。`check-trike-sm3-sharing`的Yosys层次断言确认`trike_decaps_postprocess_core`中恰好一个
`sm3_compress`实例。该检查证明逻辑层次结构，不是Vivado布局布线资源证据。

结论与状态：保留统一后处理FSM和单SM3共享结构。LUT、FF、Slice、RAMB36/RAMB18、Block RAM Tile、
DSP、setup WNS/TNS、hold WHS和Fmax均待物理实现。下一步连接`trike_decaps_syndrome_core`、排序/decoder
装载、`decoder_top`、`trike_decoder_error_vector`与本复合核，形成完整Min-Sum Decaps控制器和统一固定
周期，再建立窄I/O synth wrapper与Vivado入口。

### 阶段78：Min-Sum residual固定重算（2026-08-08）

目标与假设：`decoder_top.o_done`只表示公开固定迭代完成，不能直接作为KEM有效性条件。Decaps必须独立
检查`syndrome xor H*e'`是否为零，并把该结果与H4错误相等位共同送入隐式拒绝选择。检查调度不得跳过
`e'=0`变量，也不得在发现首个非零residual后提前结束。

关键实现：新增`trike_decoder_residual_check`。模块被动接收decoder装载路径产生的排序H写和原始
syndrome bit写；decoder完成后逐row扫描，每个row固定遍历3个block和全部`w`项support，根据公开循环
计数和support数据计算decision列地址，使用同步一拍decision口读取并累计parity。每行均完整执行`3w`
次读取，只在全部`r`行结束后输出residual weight和zero位。

验证范围与定量结果：toy `r=13,w=3,BLOCKS=3`的合法syndrome和单bit扰动分别得到residual重量0/1，
两者固定261拍。`TRIKE_MINSUM_KAT_V1`的`r=12589,w=35`排序support、syndrome和Min-Sum decision直接
生成RTL fixture；正常结果为0，翻转syndrome第0 bit后为1，两者从start到done均固定2,668,869拍，即
`1 + 12589*(2 + 2*3*35)`。该串行基线优先保证可解释固定调度；LUT、FF、BRAM和Fmax尚未测量。

结论与状态：保留residual重算模块，并以`o_residual_zero`驱动postprocess的`decoder_ok`，避免把固定轮
完成误解释为译码成功。下一步完成总控制器的RAM生命周期连接：syndrome和排序H同时写入decoder/checker，
decoder完成后顺序运行decision error存储与residual checker，再启动单SM3 postprocess；随后对正常、
`u/v/c2`篡改路径测统一固定周期。

### 阶段79：完整Min-Sum Decaps流水控制器（2026-08-08）

目标与假设：把syndrome、support排序/装载、固定7轮Min-Sum、decision导出、residual重算和单SM3后处理
连接成单一start/done事务。decoder只有一个同步decision读口，因此error-vector写入和residual检查必须
按公开状态顺序复用；有效性只能影响最终常数时间选择，不能改变阶段数和RAM遍历长度。

关键实现：新增`trike_decaps_pipeline_core`。首个`w`项H support使用联合ready，在同一握手中写入syndrome
核的H0 support RAM和完整H排序器；后两个块继续写排序器。排序器输出的H写、adapter展开的syndrome bit写
同时送入decoder与residual checker。decoder完成后先固定清零/写入4,800-byte padded decision RAM，再
逐row执行完整`r*3w` residual扫描，最后以residual-zero启动`trike_decaps_postprocess_core`。顶层锁存
`sigma2`，外部r2/ciphertext使用同步byte RAM协议。修正profile-specific `PROFILE_DEFAULT`，使TRIKE160
宏选择的运行profile与`R/W/T`及RAM几何一致；BIKE/TRIKE其他固定profile同样按对应编译宏选择默认值。

验证范围与定量结果：fixture加入原始support顺序以及197个64-bit `t0/u/v` word。以
`TRIKE_160_PARAMS,L=32,K=4,MSG_BITS=5,COLS_PER_TILE=256`编译完整层次，seed 1正常密文和u/v/c2首bit
篡改密文分别从独立复位运行。四条路径均接受105项support、各197个多项式word和32-byte c2，完成7轮
Min-Sum、全部37,767个decision导出、2,668,869拍residual扫描和完整L/H4/compare/K；start到done均为
4,727,351拍。RTL residual重量依次为0/6,233/6,314/0；正常路径error比较相等并逐byte匹配Encaps SS，
三条篡改路径比较不等并逐byte匹配各自`K(sigma2,tampered_ct)`。C模型在非收敛u/v样本上的residual为
6,304/6,309，故失败判决不作bit-exact声明，只验证非零residual、隐式拒绝byte golden和固定周期。
Verilator完整层次编译和仿真通过。

结论与状态：保留总控制器、共享decision读口调度和profile默认值修正。当前结果闭合了正常/u/v/c2篡改的
RTL功能、byte golden与固定周期边界；非收敛失败样本的C/RTL判决差异作为显式限制保留。LUT、FF、Slice、
RAMB36/RAMB18、Block RAM Tile、DSP、setup WNS/TNS、hold WHS和Fmax均待窄I/O synth wrapper及Vivado
实现，不能从Verilator层次或逻辑bit数推测。

### 阶段80：TRIKE160 Min-Sum Decaps窄I/O物理边界（2026-08-08）

目标与假设：为阶段79的完整Decaps流水建立可比较Vivado边界，避免将14/64/256-bit算法端口直接映射为
器件I/O并污染资源和关键路径。外部只发送规范化SK与CT byte流，片内RAM按后续消费者的读取粒度保存。
wrapper装载和输出缓冲使用公开固定长度，不依据support、密文或译码结果改变字节数。

关键实现：新增`trike_decaps_synth_top`，输入格式固定为5,206-byte SK后接3,180-byte CT。SK中的420-byte
原始support组装为105个14-bit坐标；H0与sigma字段固定消费但不保存；t0、u、v组装为各197个64-bit word；
r2和完整ciphertext写入同步byte RAM；sigma2写入256-bit寄存器。core启动后，各RAM以valid/ready预取
驱动`trike_decaps_pipeline_core`，最终SS通过片内单项缓冲和IOB寄存输出。decoder的H/syndrome RAM仅支持
初次装载，因此wrapper明确为每次复位一项事务。新增`vivado-impl-trike-decaps`，Tcl固定定义
`TRIKE_160_PARAMS,L=32,K=4,MSG_BITS=5,COLS_PER_TILE=256`并加载完整源文件清单。

验证范围与定量结果：fixture加入完整SK byte golden。正常、u首bit、v首bit和c2首bit篡改四项从独立
复位运行，均接受8,386个输入byte并输出32-byte SS。正常SS和三项`sigma2`拒绝SS逐byte匹配Python；
residual-zero依次为1/0/0/1，ciphertext-equal依次为1/0/0/0。四条路径从wrapper start到末个SS接受均为
4,737,077拍，比内部流水4,727,351拍多9,726拍固定装载/预取/IOB边界开销。Verilator完整层次编译、
wrapper仿真、格式和lint通过；Makefile dry-run确认top、器件、XDC和输出目录参数正确。本机没有Vivado，
没有生成综合、布局布线、LUT、FF、Slice、RAMB36/RAMB18、Block RAM Tile、DSP或时序数据。

结论与状态：保留窄I/O wrapper与Vivado入口，可以在Vivado 2023.2环境运行首个完整Decaps物理基线。
报告必须使用`xc7k355tffg901-2L`、10 ns、0.100 ns uncertainty和同一Tcl阶段；wrapper结果属于实现级
核心边界，不是板级package-pin签核。

### 阶段81：完整Decaps首轮物理基线与两组关键路径寄存分段（2026-08-09）

目标与假设：根据`trike_decaps_synth_top`的首轮Fully Routed报告，同时处理syndrome稀疏环乘的长进位链
和residual到decoder全局K-sign RAM的跨层级地址路径。新增状态、RAM预取和寄存边界均由公开
`WORDS/SPARSE_WEIGHT/r/w`以及固定FSM状态决定，不根据support值、syndrome、判决或residual改变调度。

首轮物理基线由用户在Windows Vivado 2023.2生成，器件为`xc7k355tffg901-2L`，时钟10 ns，设计
`trike_decaps_synth_top`为Fully Routed。资源为65,746 LUT、66,149 FF、28,128 Slice、575 RAMB36、
119 RAMB18、634.5 Block RAM Tile和4 DSP；BRAM利用率为88.74%。层次报告把634.5 Tile完整归属为
decoder 537.5、syndrome 36.5、窄接口缓存24.5、error-vector 16、postprocess 16和residual 4；decoder
内部`ram_k_global`与`ram_m`分别使用320和144 Tile。

setup WNS/TNS为-0.304 ns/-13.669 ns，共160个失败端点；hold WHS为+0.049 ns。内部前20条失败路径由
两组组成：12条从稀疏乘法`b_word_idx_q`经过模地址、mask和可变移位到`sparse_contribution_q`，最差
-0.304 ns、34级逻辑且包含22个CARRY4；8条从residual的support寄存阵列经过动态读取与列地址计算到
decoder的`ram_k_global`读地址网络，最差-0.282 ns。高扇出报告中的reset、SM3、排序器和K-sign地址复制
网络均为正裕量，故全局高扇出不是该检查点的setup根因。该检查点没有达到内部100 MHz签核。

关键实现：

- `trike_poly_mul_core`增加固定`ST_SPARSE_PREPARE`状态，先用`INDEX_W+1`位算术寄存循环起点、有效源word
  和末word有效bit数，再在下一拍产生三组贡献及result地址；稀疏busy公式为
  `4*WORDS+2*S+8*S*WORDS`；
- `trike_decoder_residual_check`使用一份`(3w) x ROW_W`同步Block RAM保存排序support。每行
  `ST_ROW_FETCH`预取第0项，每个`ST_DECISION_ISSUE`预取下一项；`decision_col_q`在送入decoder全局
  K-sign RAM前形成寄存边界。该预取与原有decision一拍读延迟重叠，residual仍固定
  `1+r*(2+2*3w)`拍；
- 测试中的稀疏周期断言以及KeyGen/Encaps/Decaps当前状态文档同步到新增公开流水拍。

验证范围与定量结果：`make format-rtl`、`make check-format-rtl`、`make lint-rtl`、`make test-unit`和
`make test-integration`通过。13-bit稠密/稀疏toy、越界dummy index和backpressure通过；官方TRIKE-2
多项式结果逐word匹配，稠密/稀疏固定1,967,372/69,366拍。官方KeyGen算术固定93,933,246拍并逐word
匹配`t0/r2`；候选0与候选1才合格的完整KeyGen均逐byte匹配PK/SK并固定98,766,108拍，窄I/O为
98,773,679拍。完整Encaps核与wrapper逐byte匹配CT/SS并固定2,378,447/2,384,421拍。

官方参数syndrome的244个word逐项匹配，固定2,038,763拍。项目参数residual正常/单bit扰动结果为0/1，
均保持2,668,869拍。完整Min-Sum Decaps正常与u/v/c2首bit篡改四条路径的residual、比较结果和最终SS
逐项通过；pipeline固定4,734,246拍，窄I/O wrapper固定4,743,972拍。K=3和K=4的五档seed-1回归均为
`residual=0, exact=1`，固定译码周期依次为193,514、337,245、1,252,957、3,866,043和8,538,564。

物理待测边界：support RAM按当前XPM参数目标映射为1个RAMB18，即0.5 Block RAM Tile；这只是RTL映射
意图，不是实现结果。新RTL的LUT、FF、Slice、RAMB36/RAMB18、Block RAM Tile、DSP、setup WNS/TNS、
hold WHS、pulse width和两组top path均待相同器件、Vivado、XDC和Fully Routed阶段复测。只有复测确认
WNS/TNS收敛且`cycles/Fmax`改善后，才判定为物理时序收益。

结论与状态：RTL结构保留并进入Vivado复测。功能、byte/word golden和公开固定周期已闭合；100 MHz、
资源变化和Fmax保持待测，不使用Verilator或XPM意图推测物理收益。

### 阶段82：统一Decaps最大几何寄存分段复测（2026-08-10）

目标与假设：在与阶段81相同的`xc7k355tffg901-2L`、Vivado 2023.2、10 ns时钟、
0.100 ns uncertainty和Fully Routed阶段复测稀疏乘法与residual support RAM寄存分段。该实现按
五档统一配置的TRIKE-9最大`R/W/N`展开存储与数据通路；Decaps pipeline的profile绑到
`PROFILE_DEFAULT`，所以这是最大档物理包络，不是wrapper端的五档运行时KEM切换证明。

验证范围与定量结果：用户提供的报告显示63,228 LUT、60,542 FF、25,653 Slice、635 Block RAM
Tile（575 RAMB36/120 RAMB18）和4 DSP。setup WNS/TNS为`+0.033 ns/0`，hold WHS/THS为
`+0.050 ns/0`。相对阶段81首轮分别减少2,518 LUT、5,607 FF和2,475 Slice，Block RAM Tile增加0.5，
setup WNS改善0.337 ns且TNS清零。新RAMB18位于residual support RAM；原两组失败路径没有进入
新的前20条路径。功能门禁与物理报告分层记录，详见EXP-0082和RUN-20260810-01。

结论与状态：寄存分段保留，统一最大几何在100 MHz下Fully Routed通过。该结果随阶段83的
参数范围修改标记为历史参考，四档当前RTL的物理基线待同条件复测。

### 阶段83：统一TRIKE架构收缩到四个提交档（2026-08-10）

目标与假设：删除非提交的TRIKE-1/TRIKE128实验profile，保留TRIKE-2/5/7/9四档统一运行时
数据通路。最大档TRIKE-9不变，因此K-sign、message、syndrome和tile RAM深度、K-sign位置字段
宽度与最大固定周期不变；只有profile表、公开选择ID和其控制mux收缩。

关键实现：RTL和随机fixture的TRIKE profile数组改为四项，ID宽度由3 bit改为2 bit，值0/1/2/3
分别对应TRIKE160/256/384/512。Makefile、C量化模型、量化campaign、软件KEM、当前设计文档、
DFR汇总CSV和对应图表同步删除TRIKE128入口。Decaps Vivado批处理入口使用
`TRIKE_UNIFIED_PARAMS`生成最大档物理包络；固定TRIKE160 golden门禁保持独立。历史实验保留删除原因
与旧报告配置。

验证范围与定量结果：`make format-rtl`、`make check-format-rtl`、`make lint-rtl`和`make ci-fast`
通过，Decaps固定TRIKE160与统一最大几何的Verilator/Slang lint均通过。K=4、L=32、seed 1四档
随机回归分别固定337,245、1,252,957、3,866,043和8,538,564拍，
均为`residual=0, exact=1`。四档软件KEM正常解封装与篡改隐式拒绝通过；`make ci-kem-reference`
的官方TRIKE-2/5/7/9 KAT和RTL KEM分层golden/固定周期门禁通过。未运行四档当前RTL的Vivado实现，
LUT、FF、Slice、RAMB36/RAMB18、Block RAM Tile、DSP、setup WNS/TNS和hold WHS待测。

结论与状态：四档profile收缩保留，功能状态为通过。不将profile ID减少解释为物理收益；
最大RAM几何不变，同条件Fully Routed复测完成前，当前物理结果保持待测。

### 阶段84：四档统一Decaps同条件物理复测（2026-08-11）

目标与假设：在阶段83删除非提交TRIKE-1档后，使用与阶段82相同的`xc7k355tffg901-2L`、Vivado
2023.2、10 ns时钟、0.100 ns uncertainty、XDC、L32/K4/C256最大几何和Fully Routed阶段复测。
最大TRIKE-9几何不变，预期RAM资源不变；profile控制收缩是否形成物理资源变化只由实现报告判断。

验证范围与定量结果：用户提供的四档报告为63,386 LUT、60,521 FF、25,759 Slice、635 Block RAM
Tile（575 RAMB36/120 RAMB18）和4 DSP。setup WNS/TNS为`+0.033 ns/0`，hold WHS/THS为
`+0.051 ns/0`，pulse-width裕量为`+4.232 ns`。相对阶段82五档参考，LUT增加158、FF减少21、Slice
增加106，BRAM/DSP和setup WNS不变，判定为实现级小幅波动。methodology保留49项`DPIR-1`和4项
`SYNTH-10`告警；没有无约束内部端点。

时序证据边界：全局setup最差路径位于registered输出到OBUF，wrapper没有package pin约束。用户提供的
两份internal-setup附件内容重复，报告中的20条路径全部是async reset recovery检查，最差`+0.275 ns`，
不能据此声明片内同步数据通路WNS。后续优化前需要以register output pin到register data pin重新生成
同步数据路径top-N报告。该缺项不改变所有已指定100 MHz约束均满足的结果。

结论与状态：保留四档统一架构并把本次运行作为当前统一Decaps物理基线。删除一档使提交范围与公开控制
一致，但没有可声明的面积或时序收益。完整配置、层次资源和补充报告命令见EXP-0084与
RUN-20260811-01-trike-decaps。
