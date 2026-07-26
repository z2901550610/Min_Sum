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

当前环境没有Vivado可执行文件。当前`ram_t`版本的Slice LUT、LUT as Logic、LUT as Memory、FF、Slice、
Block RAM Tile、RAMB36/RAMB18、DSP、CARRY4、setup WNS/TNS、hold WHS、pulse width和top paths
全部待同条件Vivado确认，不能用删除的mux节点数代替实测。

结论与状态：`ram_t`公共地址收窄保留为当前RTL候选，功能和固定周期验证完成，物理结果待测。L=16复测
重点是阶段41已成为前十条的`ram_t` BRAM到VNU路径是否改善或恶化；L=32同时检查两条`ram_t`到VNU路径、
全局K RAM新瓶颈和aggregate LUT。完成该独立检查点前不修改`ram_accum`，以保持物理归因和回退边界。

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
