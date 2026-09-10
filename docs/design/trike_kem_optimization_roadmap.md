# TRIKE KEM候选与下一步

更新：2026-09-09。仅维护值得跨任务保留的候选与进入条件，不记录推进过程。
当前结构、周期和验证范围以[实现状态](implementation_status.md)和所属设计说明为准；
失败教训与旧结果见[历史索引](../experiments/index.md)，物理基线见[注册表](vivado_baseline_registry.md)。

## 当前进入条件

- 一层Karatsuba直接折叠、原地XOR恢复已集成；[设计与复现](trike_karatsuba_fold.md)。
- 稀疏路径已为6拍/support-word；Encaps已采用error RAM流和四次稠密乘法，见[公共核](trike_kem_common_cores.md)。
- 当前集成的同条件Vivado仍NOT_RUN。EXP-0123的Decaps160/256结果属于旧八拍稀疏检查点；
  384当时CANCELLED、512当时NOT_RUN，不能作为当前整机周期或全参数通过证据。
- EXP-0114旧run缺失provenance，不补采旧缺项；新比较须建立可复现基线。旧support sorter/reset
  瓶颈是诊断线索，不能假定仍是当前关键路径。

## 候选队列

| 方向 | 进入条件与最小待解决问题 |
| --- | --- |
| 当前集成物理比较 | 固定源码/参数/XDC等条件，对求逆、KeyGen、统一KEM测RAM映射、关键路径及cycles/Fmax；不混改sorter/reset |
| 稀疏与Encaps物理收益 | 检查6拍RMW的转发/rotation路径，以及error流移除存储后的实际RAM与mux成本；功能范围见EXP-0124/0125 |
| Frobenius | 比较当前schedule实际k的direct/repeated置换成本；不照搬C的阈值64 |
| Divstep | EXP-0122仅局部锚点；先做b=64、s=8全长四多项式BRAM扫描，处理padding/carry和固定访问，再决定是否接KeyGen |
| 求逆系统比较 | 基于实际D×D和置换成本比较当前加法链与divstep的增量面积、延时；TRIKE仍需D×D，不能套用BIKE移除稠密核的收益 |
| 二层直接折叠 | EXP-0126只有软件/预算证据；先证明真实SDP绑定与固定调度，再评估大r收益；旧EXP-0119完整product RAM数据不适用 |
| 更深递归/Toom-3 | 只有前一层系统收益能覆盖重组、扫描与RAM代价才继续；FFT不纳入当前路线 |
| 统一共享与时序 | 先取得当前层次资源/关键路径，再选择乘法共享、scratch或sorter/reset中的一个结构问题 |

候选不是自动执行清单，不为填齐表格扩展参数扫点。验证范围遵循[工作流](../workflow.md)。
方向被有证据地放弃才写错题；采用时更新所属设计；状态未变不更新本页。
