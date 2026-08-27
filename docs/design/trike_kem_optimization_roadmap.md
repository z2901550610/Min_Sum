# TRIKE KEM优化路线图

> 更新日期：2026-08-27<br>
> 起点源码：`e2fbb8df068c`；EXP-0115至0119工作树待提交。
> 当前推进点：EXP-0119整多项式Karatsuba depth 2已通过局部与TRIKE-2 reference，等待同条件Vivado物理门。

本文是TRIKE KEM优化工作的长期推进入口，回答三个问题：已经完成哪些架构收敛、当前门禁是什么、
下一个实验应验证什么。当前成品架构仍以[实现状态](implementation_status.md)为准，实验细节以
[实验索引](../experiments/index.md)为准，精确物理数字以
[Vivado基线注册表](vivado_baseline_registry.md)和RUN manifest为准。

## 维护规则

1. 本文只维护工作流状态、依赖、优先级、进入条件和退出条件，不复制RTL diff或完整Vivado数字。
2. 新实验仍在`docs/experiments/index.md`按实际实施顺序分配EXP ID；路线图不预占EXP编号。
3. 每个实验只改变一个主要结构变量。实验结束后，在同一提交中更新对应EXP状态和本文的推进状态。
4. `retained`表示该结构进入成品；`pending`表示缺少既定验证层；`rejected`保留失败原因，不删除历史。
5. 物理比较只有在part、Vivado、XDC、defines、公开参数、存储几何和报告阶段一致时才计算增减。
6. 路线顺序可以根据新证据调整，但调整时记录原因和被替代的决策门，不重写历史实验结论。

## 目标与硬约束

| 方向 | 当前基线问题 | 长期目标 | 不可破坏的边界 |
| --- | --- | --- | --- |
| 统一KEM时序 | EXP-0114 pending run内部setup WNS `-4.017 ns` | 100 MHz内部setup/hold收敛 | 单SM3、固定握手和固定周期 |
| KeyGen周期 | 两次求逆占KeyGen core约85.27% | 降低D×D与Frobenius总延时 | 两次固定求逆、无数据相关退出 |
| Encaps周期 | UV sparse阶段占Encaps core约86.71% | 减少support-word扫描和RMW | 每bank访问次数与秘密tag无关 |
| Decaps周期 | syndrome与residual为主要阶段 | 优先降低syndrome多项式延时 | decoder与拒绝路径固定调度 |
| KEM存储 | 最大几何统一入口受BRAM和路由约束 | 复用生命周期，减少乘法scratch | 不用重算秘密结果换取存储 |
| 物理证据 | 多个GUI报告缺少完整provenance | 每个保留点具备可比较RUN manifest | 不用Yosys结构代替Vivado映射 |

官方TRIKE-2 KeyGen/Encaps与项目TRIKE160/256/384/512 Min-Sum Decaps是两个参数验证域，路线图中的
系统数字始终标明所属域。

## 当前工作流状态

| Workstream | 状态 | 已有证据 | 当前缺口 | 下一门禁 |
| --- | --- | --- | --- | --- |
| KEM功能与固定周期 | `pending`当前G2高档复测 | KeyGen、Encaps及TRIKE160/256当前golden | TRIKE384/512当前周期 | 候选保留时运行完整门禁 |
| 单发射统一服务 | `retained`，物理待收敛 | EXP-0100至0105结构与reference | 可比较统一ASIC route | 完成G0/G1 |
| RAM生命周期复用 | `retained`，物理收益待归因 | EXP-0106至0110功能/结构门禁 | 层次RAMB映射和mux代价 | 纳入统一基线报告 |
| D×D diagonal/Comba | `pending` | EXP-0115/0116局部golden与三档base周期矩阵 | Vivado资源、RAM映射与100 MHz route | 优先实现32-bit物理候选 |
| 统一KEM时序 | `in_progress` | EXP-0114中SM3退出内部top-20 | high-fanout、DRC和provenance缺失；support sorter/reset成为新瓶颈 | 先完成G0 |
| Sparse accumulator | `planned` | 当前8拍/support-word基线 | forwarding/ping-pong实测 | G4 |
| Encaps tagged pass | `planned` | 算法和constant-access方案已评估 | RTL、访问轨迹和route | G5 |
| Frobenius单元 | `planned` | 当前固定`2r`拍基线 | direct/repeated交叉点 | G6 |
| Divstep inverter | `research` | Racing BIKE公开设计空间 | TRIKE同条件系统AT | G7 |
| Karatsuba + Comba | `in_progress` | EXP-0117 base及EXP-0118/0119 word-array depth 1/2 | TRIKE-9 golden与Vivado实测 | G8 |

## 已有EXP证据地图

EXP继续保留为按时间追加的原始决策记录；本节只按架构主题建立索引。

### 1. Decaps运行时与独立物理边界

| Evidence | 已形成的基础 | 路线图用途 |
| --- | --- | --- |
| [EXP-0084](../experiments/EXP-0084-four-profile-decaps-route.md) | 固定profile最大几何routed物理包络 | BRAM和decoder路由历史参考 |
| [EXP-0087至0090](../experiments/index.md) | 运行时输入、存储、syndrome几何和预取 | 保证G2/G3可进入运行时Decaps |
| [EXP-0091至0097](../experiments/index.md) | support/decoder/postprocess及四档端到端 | 保证算术改变不破坏KEM闭环 |
| [EXP-0098](../experiments/EXP-0098-dual-row-residual-scan.md) | 双行固定residual扫描 | residual作为独立后续方向，不与syndrome混改 |

### 2. KeyGen、Encaps和D×D基线

| Evidence | 结论 | 尚未闭合的边界 |
| --- | --- | --- |
| [EXP-0085](../experiments/EXP-0085-current-keygen-route.md) | KeyGen窄I/O历史routed参考 | 当前16-bit配置同源物理基线 |
| [EXP-0086](../experiments/EXP-0086-current-encaps-route.md) | Encaps窄I/O当前routed指针 | tagged sparse后的同条件比较 |
| [EXP-0099](../experiments/EXP-0099-kem-dense-mul-digit16.md) | 16-bit digit保留；四档Decaps周期下降18.18%至31.35% | diagonal/Comba和direct fold |

### 3. 统一计算与存储服务

| Evidence | 已保留结构 | 物理待确认项 |
| --- | --- | --- |
| [EXP-0100](../experiments/EXP-0100-unified-kem-asic-sm3.md) | 单发射operation与一个SM3 | 全局分发routing |
| [EXP-0101](../experiments/EXP-0101-unified-kem-poly-mul-service.md) | 一个普通乘法服务和一个KeyGen求逆内部乘法器 | 最大几何mux、RAM和Fmax |
| [EXP-0102](../experiments/EXP-0102-unified-kem-h123-service.md) | KeyGen/Encaps共享H123计算 | 客户端分发布线 |
| [EXP-0103](../experiments/EXP-0103-unified-kem-weight-sampler-service.md) | 三阶段共享固定重量采样链 | 最大几何资源和布局 |
| [EXP-0104](../experiments/EXP-0104-unified-kem-h4-store-service.md) | Encaps/Decaps共享H4结果存储 | 最大几何RAM映射 |
| [EXP-0105](../experiments/EXP-0105-unified-kem-h123-vector-store.md) | KeyGen/Encaps共享三组H123 RAM | 三读口复制行为 |

### 4. RAM生命周期收敛

| Evidence | 已保留生命周期 | 后续原则 |
| --- | --- | --- |
| [EXP-0106](../experiments/EXP-0106-encaps-uv-persistent-store.md) | UV累加与持久u/v共用两组RAM | tagged方案继续使用同一持久结果边界 |
| [EXP-0107](../experiments/EXP-0107-keygen-numerator-r2-store.md) | numerator原位覆盖为r2 | D×D不得提前覆盖未读操作数 |
| [EXP-0108](../experiments/EXP-0108-keygen-persistent-result-store.md) | 算术与序列化共用t0/r2 RAM | 新乘法服务直接写持久store |
| [EXP-0109](../experiments/EXP-0109-keygen-shared-support-view.md) | stage support视图服务算术 | 不恢复第二份support寄存副本 |
| [EXP-0110](../experiments/EXP-0110-keygen-inverse-t1-bank.md) | inverse依次复用t1 bank | permutation/D×D遵守t1生命周期 |

### 5. 统一KEM物理收敛

| Evidence | 结果 | 后续动作 |
| --- | --- | --- |
| [EXP-0111](../experiments/EXP-0111-unified-kem-asic-route.md) | `rejected`；变量除法和复位路径失控 | 失败原因保留，不作为基线 |
| [EXP-0112](../experiments/EXP-0112-h4-index-map.md) | 无除法映射保留；关键路径转为全局控制routing | 结构已进入成品 |
| [EXP-0113](../experiments/EXP-0113-fixed-weight-index-bram.md) | 索引RAM映射1个RAMB36；关键路径转到SM3广播 | 目标层次映射已确认 |
| [EXP-0114](../experiments/EXP-0114-sm3-result-local-fanout.md) | RTL/结构/周期通过；SM3退出内部top-20，物理仍`pending` | 补齐fanout/DRC/provenance后定结论 |

整合结论：EXP-0100至0110已经完成统一服务和RAM生命周期的RTL收敛；不应在算术优化中重新建立stage私有副本。
EXP-0111至0114形成一条连续的物理问题定位链。用户选择不补EXP-0114缺失报告，RUN-20260826-01只作为
当前工作基线；后续算术run可以做同环境诊断比较，不能把缺少source provenance的增减升级为严格可复现结论。

## 执行门禁

### G0：结束EXP-0114物理证据

目标：验证`max_fanout`是否真的形成SM3结果寄存器复制和局部布线，而不是仅保留RTL属性。

- 源码固定为`e2fbb8df068c`，记录clean/dirty状态；
- Vivado 2023.2、`xc7k355tffg901-2L`、统一KEM当前defines和XDC；
- reset synthesis/implementation并Fully Route；
- 收集utilization、hierarchical utilization、timing summary、内部同步setup、hold/recovery和high-fanout；
- 检查单SM3结构、复制后单网fanout、SM3路径是否退出top path，以及FF/Slice代价。

RUN-20260826-01已提供资源、timing、内部setup和methodology：SM3不在内部top-20，support sorter的
fanout-2033状态网成为`-4.017 ns`内部最差路径，decoder reset的fanout-9206 recovery为`-3.550 ns`。

状态：缺失项不再补采，EXP-0114保持`pending`。不在后续算术实验中同时修改support sorter或reset结构。

### G1：建立统一KEM可复现基线

RUN-20260826-01作为当前工作基线。新的候选run仍记录revision、filelist、defines、XDC、part、directive和
报告阶段；只有候选与基线条件足以严格对齐时才计算正式增减并更新Vivado基线注册表。

退出条件：后续实验可以计算LUT/BRAM/WNS和`cycles/Fmax`严格增减。

### G2：64-bit diagonal/Comba D×D

目标：先消除当前每个word pair的product-RAM low/high反复RMW，不引入Karatsuba。

第一组设计点：

| 变量 | 设计点 |
| --- | --- |
| `WORD_W` | 64 |
| base digit | 16、32、64 |
| word-pair initiation interval目标 | 4、2、1 |
| result | 独立`W`-word RAM |
| reduction | 先保持清晰的固定折叠边界 |

开发功能门：非64对齐、external dense、inversion official golden、KeyGen byte golden和精确访问计数。
候选保留门再运行完整KEM公开profile；物理门要求100 MHz内部setup不失败，并以routed `cycles/Fmax`和
BRAM而不是RTL周期单独选择Pareto点。

EXP-0115已实现16x64 base：稳态word-pair initiation interval为4拍，保留完整`2W` product RAM与独立
归约/result边界。TRIKE-2 internal/external dense固定240,585/239,609拍，求逆5,988,878拍；开发功能门已通过，
状态保持`pending`直到Vivado确认RAM映射、资源和100 MHz内部setup/hold，并在候选保留点完成完整KEM门禁。

EXP-0116在相同结构边界下完成16/32/64-bit base局部矩阵。TRIKE-2求逆固定周期分别为
5,988,878/3,369,294/2,059,502；Yosys Estimated LC诊断为2,379/3,147/4,252，三档均为4个RAMB36。
该结构结果不作为Vivado资源证据。32-bit以43.74%求逆周期降幅和32.28%本地LC增幅作为首选物理候选，
64-bit作为激进候选；双lane因同时改变A/B读带宽和RAM复制边界，待三档同条件Vivado后独立比较。

### G3：D×D direct cyclic fold

前置条件：G2存在可保留的Comba基线。目标是删除`2W` product store或把它缩为`W`结果store。

必须证明：末wordmask、high word跨两个目的word、连续同址RMW forwarding，以及inverter源bank在所有读取
完成前不被覆盖。该门只改变reduction/store策略，不改变Karatsuba depth。

### G4：Sparse accumulator

目标：降低当前`8*S*W`主项。按64、32、128 bit顺序比较single-bank forwarding与ping-pong accumulator。

保留点必须报告：support-word对周期、结果RAM数量、rotation路径WNS、KeyGen S×D、Encaps UV和Decaps
syndrome集成周期。不能以Racing BIKE的不同器件结果替代本工程route。

### G5：Encaps constant-access tagged two-pass

前置条件：G4的64-bit或其他获胜sparse内核。顺序执行u pass和v pass；每个support-word迭代固定同时读取
两个候选dense bank，tag只mask数据，不决定bank是否访问。

安全门：不同`|e0|/|e1|/|e2|`输入具有相同总周期、每bank读次数和地址序列。物理门：先评估单tagged实例，
只有它route通过后才考虑双u/v实例。

### G6：Frobenius permutation

比较direct `k`-permutation、repeated single-square和公开`k`选择的hybrid。对当前schedule实际出现的所有`k`
测量`L_square(k)`，重新确定FPGA阈值；不采用optimized C的`K_SQR_THRESHOLD=64`作为默认值。

### G7：Inversion break-even

前置条件：G2/G3与G6给出稳定的`L_DD`和`L_perm(k)`。比较：

- 更新后的固定addition-chain；
- constant-time divstep：先扫描`b=32/64`、`s=1/4/8/16/32`，再局部增加点；
- 新EEA变体只有软件证据时保持`research`状态。

选择指标是KeyGen系统的增量面积、routed latency和AT。TRIKE仍需要D×D，因此不把BIKE中“ExtGCD移除
dense multiplier”的面积收益带入模型。

### G8：Karatsuba + Comba

前置条件：Comba base已经稳定。按depth 0、1、2推进；只有depth 2仍改善系统`cycles/Fmax`与AT时才运行
depth 3。TRIKE-2检查系统收益，TRIKE-9几何检查扩展性。512-bit AVX-512 base不作为FPGA默认点。

EXP-0117先隔离64x64 base递归：depth 1在Yosys独立base中较schoolbook Estimated LC下降19.54%，
depth 2/3因重组XOR反而增加，所有点周期不变。base层只保留depth 1进入Vivado；整多项式层另设公开
Karatsuba depth，使用banked halves保证cross product不增加秘密相关访问或双倍读拍。EXP-0118的depth 1
在TRIKE-2由61,977降至50,993拍（-17.72%），Yosys诊断为6个RAMB36；先以depth 2确认更深递归能否
补偿bank和重组代价。EXP-0119的depth 2进一步降至44,216拍，但TRIKE-2 block诊断增至10个RAMB36；
TRIKE-9公式为1,646,057拍且depth 1/2静态block容量同为19个RAMB36。depth 2进入同条件Vivado门，
depth 3暂停。Toom-3至少等到word-array depth-2 Karatsuba完成物理门后再比较，避免同时引入评价/插值
scratch和新RAM带宽。

### G9：统一KEM收敛

重新评估外层D×D与KeyGen inverter内部D×D的物理共享、scratch bank仲裁和跨stage服务路由。只有各独立
实验进入Pareto前沿后才合并，避免一次改变共享、乘法算法、RAM和流水边界。

退出条件：完整reference、random、formal、固定周期和comparable Fully Routed门禁通过；更新成品实现状态
和Vivado基线注册表。

## 优先级与依赖

```text
G0 EXP-0114 route
  -> G1 reproducible unified baseline
       -> G2 diagonal/Comba -> G3 direct fold -> G7 inversion break-even -> G8 Karatsuba
       -> G4 sparse accumulator -> G5 tagged Encaps
       -> G6 Frobenius -----------^
       -> G9 unified convergence（汇合所有保留点）
```

G2、G4和G6在G1之后可以作为独立分支研究，但每个分支仍遵守“一次一个结构变量”。G7依赖真实的D×D和
Frobenius结果，G8依赖稳定Comba base，因此不能提前。

## 每个实验的统一记录字段

| 类别 | 必填内容 |
| --- | --- |
| 假设 | 改变哪个结构变量、预期影响哪项主导周期或路径 |
| 配置 | revision、defines、参数域、`L/K/C`、RAM几何、时钟 |
| 功能 | 最小单元golden、KEM byte golden、有效/拒绝路径 |
| 固定调度 | start/done边界、周期、RAM访问次数、backpressure口径 |
| Formal | counter/address、RAW、访问计数、constant-time assertion和cover |
| 物理 | LUT、FF、Slice、Tile、RAMB36/18、DSP、setup/hold、critical path |
| 比较 | 同条件baseline、`cycles/Fmax`、增量面积、AT和证据限制 |
| 结论 | `retained/rejected/pending/incomparable/superseded`及下一门禁 |

## 验证节奏

多项式运算和SM3核的开发迭代采用局部优先门禁：运行受影响单元、独立golden/reference、固定周期与访问计数，
再运行`make check-rtl`。完整KeyGen/Encaps/Decaps只在候选准备保留、跨模块接口改变或发布/里程碑时运行；
未运行的完整KEM层明确记为`pending`，不阻塞局部结构搜索。

## 近期执行队列

1. **立即执行**：对EXP-0115运行同条件Vivado，检查product RAM映射、资源和100 MHz内部setup/hold。
2. **若G2物理门通过**：在获胜Comba点上独立验证direct cyclic fold。
3. **并列独立方向**：64-bit sparse accumulator和direct Frobenius实验核。
4. **统一时序方向**：support sorter和reset分别立项，不与算术结构混改。
5. **后置决策**：tagged Encaps、divstep与Karatsuba。

研究依据、周期模型和文献比较见
[TRIKE KEM硬件优化分析](TRIKE_HARDWARE_OPTIMIZATION_ANALYSIS.md)。
