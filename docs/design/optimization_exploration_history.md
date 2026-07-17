# 译码器架构与资源优化探索记录

本文档按实施顺序记录统一 TRIKE K-sign 译码器已经探索的架构与 RTL 方案、验证结果以及取舍结论。
它用于保留设计决策过程；成品架构、资源和时序基线见
[implementation_status.md](implementation_status.md)。

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
