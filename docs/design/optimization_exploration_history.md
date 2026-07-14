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
`decoder_clk` 内部 WNS 为 `+0.653 ns`，阶段 8 为 `+0.145 ns`。当前 RTL 对应阶段 4，回退后的
placed/routed 复现结果待测。

## 同条件实现结果总表

| 顺序 | 阶段 | LUT | FF | Slice | BRAM Tile | RAMB36 | RAMB18 | WNS | 结论 |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 桶形路由和直接 correction 后、地址流水前基准 | 24,711 | 10,023 | 8,497 | 601 | 560 | 82 | -1.165 ns | 未满足 100 MHz |
| 2 | `edge_addr_gen` 固定两级流水 | 23,613 | 10,416 | 8,017 | 601 | 560 | 82 | +0.211 ns | 保留 |
| 3 | 全局 K 记录按逻辑字段初步拆分 | 23,895 | 10,364 | 8,279 | 601 | 560 | 82 | +0.424 ns | BRAM 无收益，继续细化 |
| 4 | 按 `4K × 9` 原生几何显式分段 | 24,110 | 11,129 | 8,519 | 505 | 464 | 82 | +0.629 ns | 恢复为当前 RTL |
| 5 | `base_sign` 与 slot 0 打包 | 24,151 | 11,124 | 8,555 | 489 | 448 | 82 | +0.536 ns | 撤回，优先时序余量 |
| 6 | `ram_t` 地址交织双缓冲 | 24,493 | 11,004 | 8,590 | 489 | 464 | 50 | +0.532 ns | 撤回 |
| 7 | `k_sign_update` valid 状态折叠 | 24,315 | 11,012 | 8,571 | 489 | 448 | 82 | +0.197 ns | 撤回 |
| 8 | correction 线性计数与 K RAM 预译码直达读口 | 23,917 | 11,179 | 8,430 | 489 | 448 | 82 | +0.145 ns | 撤回，时序收益为负 |

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
