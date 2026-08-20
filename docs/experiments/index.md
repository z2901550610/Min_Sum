# 实验索引

下一个实验ID：`EXP-0100`。

| ID | 日期 | 主题 | 配置/比较键 | 功能与周期 | Vivado | 结论 | 详情 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| LEGACY-0001-0081 | 2026-07-10至2026-08-09 | 解码器、K-sign与TRIKE KEM阶段1至81 | 多配置 | 见归档 | 见归档 | `superseded` | [历史探索归档](../design/optimization_exploration_history.md) |
| EXP-0082 | 2026-08-10 | 统一Decaps寄存分段物理复测 | 五档统一最大几何，L32/K4/C256 | 五档decoder与KEM分层门禁通过 | [RUN-20260810-01-trike-decaps](../../reports/vivado/manifests/RUN-20260810-01-trike-decaps.toml) | `superseded` | [详情](EXP-0082-decaps-route-config-audit.md) |
| EXP-0083 | 2026-08-10 | 统一架构删除非提交TRIKE-1档 | `TRIKE_UNIFIED_PARAMS`，TRIKE-2/5/7/9 | 四档K=4、软件KEM与参考门禁通过 | [EXP-0084](EXP-0084-four-profile-decaps-route.md) | `retained` | [详情](EXP-0083-four-submission-profiles.md) |
| EXP-0084 | 2026-08-11 | 四档统一Decaps物理复测 | 四档统一最大几何，L32/K4/C256 | 沿用EXP-0083分层门禁 | [RUN-20260811-01-trike-decaps](../../reports/vivado/manifests/RUN-20260811-01-trike-decaps.toml) | `retained` | [详情](EXP-0084-four-profile-decaps-route.md) |
| EXP-0085 | 2026-08-13 | 当前KeyGen同条件物理复测 | TRIKE-2窄I/O，当前共享乘法调度 | 核心两路径及wrapper byte golden/固定周期通过 | [RUN-20260811-02-trike-keygen](../../reports/vivado/manifests/RUN-20260811-02-trike-keygen.toml) | `retained` | [详情](EXP-0085-current-keygen-route.md) |
| EXP-0086 | 2026-08-13 | 当前Encaps同条件物理复测 | TRIKE-2窄I/O，当前共享乘法调度 | CT/SS byte golden与2,384,421固定周期通过 | [RUN-20260813-01-trike-encaps](../../reports/vivado/manifests/RUN-20260813-01-trike-encaps.toml) | `retained` | [详情](EXP-0086-current-encaps-route.md) |
| EXP-0087 | 2026-08-13 | Decaps四档运行时输入事务前端 | 四档项目Min-Sum参数，8-bit `SK || CT` | 分档长度、地址、写次数和数据无关周期通过 | 待测 | `retained` | [详情](EXP-0087-decaps-runtime-input-loader.md) |
| EXP-0088 | 2026-08-13 | Decaps四档最大几何输入存储 | 四档项目Min-Sum参数，最大档RAM几何 | 全档有效地址逐项回读通过 | 待测 | `retained` | [详情](EXP-0088-decaps-runtime-input-store.md) |
| EXP-0089 | 2026-08-13 | Decaps运行时syndrome环几何 | 最大乘法器，运行时公开`r/w/word` | 小几何逐word golden及旧reference通过 | 待测 | `retained` | [详情](EXP-0089-decaps-runtime-syndrome-geometry.md) |
| EXP-0090 | 2026-08-13 | Decaps输入存储到syndrome固定预取 | 最大输入RAM，运行时活动几何 | 小几何逐word及TRIKE160端到端golden通过 | 待测 | `retained` | [详情](EXP-0090-decaps-syndrome-prefetch.md) |
| EXP-0091 | 2026-08-17 | Decaps运行时support排序与decoder装载 | 最大`r/w`，三块support | 三档逐项golden及成对固定周期通过 | 待测 | `retained` | [详情](EXP-0091-runtime-support-sorter-adapter.md) |
| EXP-0092 | 2026-08-17 | Decaps共享support固定预取 | 单support读口，运行时`r/w` | 小几何读次数及TRIKE160装载golden通过 | 待测 | `retained` | [详情](EXP-0092-shared-support-prefetch.md) |
| EXP-0093 | 2026-08-17 | Decaps运行时decoder后检查 | 最大RAM，活动`r/w`，共享decision读口 | padding跨界、error逐byte及residual固定周期通过 | 待测 | `retained` | [详情](EXP-0093-runtime-decoder-postcheck.md) |
| EXP-0094 | 2026-08-17 | Decaps运行时pseudohash长度底座 | 最大消息几何，公开活动byte数 | 跨padding digest golden及L/K reference通过 | 待测 | `retained` | [详情](EXP-0094-runtime-pseudohash-lengths.md) |
| EXP-0095 | 2026-08-17 | Decaps运行时H4与完整postprocess | 最大H4/error RAM，活动`r/t/byte` | 三档golden、隐式拒绝及成对固定周期通过 | 待测 | `retained` | [详情](EXP-0095-runtime-h4-postprocess.md) |
| EXP-0096 | 2026-08-18 | 四档运行时Decaps流水线集成 | 最大几何，L32/K4/C256，8-bit I/O | TRIKE160完整golden、四档decoder分层通过 | 待测 | `retained` | [详情](EXP-0096-unified-runtime-decaps-pipeline.md) |
| EXP-0097 | 2026-08-18 | 四档运行时Decaps端到端golden | 四档项目Min-Sum参数，L32/K4/C256 | 全档有效/c2拒绝byte golden与固定周期通过 | 待测 | `retained` | [详情](EXP-0097-four-profile-runtime-decaps-golden.md) |
| EXP-0098 | 2026-08-19 | 双行并行residual扫描 | 两个decision读bank，相邻row固定配对 | 四档byte golden，residual与固定周期通过 | 待测 | `retained` | [详情](EXP-0098-dual-row-residual-scan.md) |
| EXP-0099 | 2026-08-20 | KEM稠密乘法16-bit digit并行化 | 64-bit word，16-bit digit，KeyGen与四档Decaps | KeyGen及四档Decaps golden/固定周期通过 | [placed待补时序](../../reports/vivado/manifests/RUN-20260820-01-trike-poly-inv.toml) | `retained` | [详情](EXP-0099-kem-dense-mul-digit16.md) |

新实验只追加一行。需要详细说明时，详情列链接到`EXP-xxxx-<slug>.md`；Vivado列链接到
`reports/vivado/manifests/<run-id>.toml`。
