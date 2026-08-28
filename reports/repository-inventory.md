# Repository Inventory

审计日期：2026-08-28  
审计基线：`c877513b5aa82544ff3994a3285cfae4b8d78941`，`main`，工作区干净  
范围：Git 跟踪文件、默认构建入口、忽略的生成目录和机器本地配置边界

## 总览

仓库共有 335 个跟踪文件，其中 88 个 RTL、84 个 SystemVerilog testbench、6 个 formal
文件、9 个实现 filelist、25 个脚本和 66 个 Markdown 文档。仓库已经具备成熟的
Verilator/Slang/Verible、SymbiYosys、随机回归、Reference C/KAT 和 Vivado batch
实现流程。本次工作流建设以补齐缺口和统一入口为主，不重排 RTL 目录，不改变算法语义。

| 类别 | 路径/数量 | 用途与依赖 | 当前状态 | 目标状态 | 风险 |
| --- | --- | --- | --- | --- | --- |
| RTL sources | `rtl/*.sv`，88 | BIKE decoder、TRIKE KEM 与共享 primitive | canonical implementation | KEEP | 高；固定周期、密码语义和 RAM 推断 |
| Packages | `rtl/bike_pkg.sv`、`rtl/trike_inv_schedule_pkg.sv` | 参数、几何、类型、逆元链 | canonical | KEEP | 高；需同步 filelist/fixture/define |
| Implementation filelists | `filelists/*.f`，9 | 各实现 top 的有序源文件集合 | canonical source-of-truth | KEEP | 中；由 `check_filelists.py` 审计 |
| Testbench | `tb/*.sv`，84 | unit、integration、reference、fixed-cycle | canonical simulation oracle | KEEP | 高；不得为迁就 DUT 改 expected |
| Generated fixtures | `tb/generated/` | Python/C 生成的 KAT、随机和 reference fixture | ignored/rebuildable | KEEP | 高；生成器与来源必须同步 |
| Reference software | `software/trike_kem/`、`scripts/min_sum_model.c` | 独立软件语义与量化模型 | canonical oracle | KEEP | 高；语义修改需独立依据 |
| Formal | `formal/*.sby`、`formal/*_formal.sv` | constant-time compare/control safety 与 cover | canonical scoped proof | KEEP/EXTEND | 中；不得外推到完整 KEM |
| Build interface | `Makefile`，711 行 | 全部本地、随机、formal 和 Vivado 入口 | canonical but specialized names dominate | MIGRATE | 中；增加短 canonical aliases，不包裹多层脚本 |
| Tool wrappers | `scripts/verilator_quiet.py`、`scripts/run_quiet.py` | 抑制成功日志并保留失败诊断 | canonical | KEEP | 低 |
| Static checks | Verible rules、waiver、Slang/Verilator targets | 格式、风格、类型、elaboration | canonical | KEEP | 中；warning 仍为 fatal |
| Random regression | `scripts/run_bike_random.py` + Make targets | BIKE/TRIKE 参数化随机回归 | canonical | KEEP | 高；seed/trials/profile 是报告边界 |
| Vivado flow | `scripts/vivado_*.tcl`、`constraints/*.xdc` | Windows/远端 FPGA synth/impl | canonical physical authority | KEEP | 高；本机不执行，不得用 Yosys 替代 |
| Vivado records | `reports/vivado/manifests/*.toml` | 运行条件与物理结果摘要 | canonical record | KEEP | 高；raw report 位于外部 run ID |
| Tool lock | `config/rtl_toolchain.lock` | 已共同验证的版本 | canonical | KEEP/EXTEND | 中；补记 PoC/cocotb/Surfer 能力 |
| Local config | ignored `config/local.mk` | 机器特定 Reference C/KAT 路径 | canonical local override | KEEP | 高；不得提交本地绝对路径 |
| Agent rules | `AGENTS.md`、`CLAUDE.md` | 仓库级行为与证据边界 | canonical identical pair | KEEP/EXTEND | 中；二者必须逐字一致 |
| Project skills | 当前缺失 | 可复用 RTL 工作说明 | missing | ADD | 低；放入 `.agents/skills/` |
| Current docs | `docs/design/`、`docs/verification/`、`docs/project_workflow.md` | 当前架构、验证和项目记录边界 | canonical | KEEP/EXTEND | 中 |
| Experiment ledger | `docs/experiments/` | EXP-0082 起的 append-only 探索 | canonical history/current decisions | KEEP | 中 |
| Frozen history | `docs/design/optimization_exploration_history.md` | 阶段 1-81 | historical | KEEP frozen | 低 |
| Archive | `docs/archive/` | 已降级的旧设计与图 | historical only | KEEP archived | 低 |
| Root result artifacts | `ksign_results_summary.csv`、6 个跟踪 PNG | K-sign/DFR 数据与图 | useful but misplaced | MIGRATE later | 中；先核对 provenance 与文档引用 |
| Build products | `build/`、`obj_dir/`、`tb/generated/`、`tmp/` | 日志、formal、仿真与 fixture | ignored/rebuildable | KEEP ignored | 低 |

## SystemVerilog 与工具兼容性画像

- 111 个文件使用 `always_ff`，84 个使用 `always_comb`，44 个使用 enum，58 个使用
  generate；项目不是 Verilog-2001 子集。
- 现有 Slang 与 Verilator 顶层检查覆盖 decoder、Encaps、KeyGen、Decaps runtime 和统一
  KEM 顶层。
- Yosys formal 只读取三个受控的小型 harness；Vivado 是 XPM/RAMB、布局和时序的裁判。
- 仓库未使用 cocotb 作为生产 oracle；成熟的 SystemVerilog TB 和 C/Python fixture 不适合
  为模板一致性而整体改写。

## 文档状态

| 状态 | 内容 | 处理 |
| --- | --- | --- |
| CURRENT | `docs/design/` 中除冻结历史外的生产架构、`docs/verification/`、`docs/project_workflow.md`、`docs/vivado_systemverilog_guidelines.md` | 保持唯一导航并补齐工作流说明 |
| HISTORICAL | `docs/archive/`、`docs/design/optimization_exploration_history.md` | 保持降级，不作为当前实现依据 |
| EXPERIMENTAL | `docs/experiments/EXP-*.md` 与 `index.md` | append-only；结论需注明证据层 |
| SUPERSEDED | 未发现仍暴露在默认导航中的重复当前文档 | 不创建额外兼容文档 |
| UNKNOWN/HIGH-RISK | 根目录 K-sign 图/CSV 的完整生成 provenance、ignored `output/`/`tmp/` 内容 | 不删除；后续单独迁移或记录限制 |

## 当前维护痛点

1. 常用能力已经存在，但计划要求的短入口 `format/lint/compile/regress/synth/qor/check`
   尚未形成完整、对称的 canonical interface。
2. 没有与真实项目隔离的 SystemVerilog+cocotb+formal+synthesis PoC，无法独立区分环境问题和
   项目问题。
3. 当前 Yosys 安装缺少 `slang.so`，`yosys -m slang` 失败；生产 RTL 不能宣称已通过
   Yosys Slang frontend。
4. Surfer 未安装，仓库也没有统一 `WAVES=1` 复现示例。
5. 缺少机器可读 QoR `latest.json` 和明确的本地估算边界。
6. 缺少仓库级 Skills；Agent 行为集中在 `AGENTS.md`，细分工作流还不能按任务渐进加载。

## 落地结果

上述六项缺口均已处理：Make短入口、`workflow-smoke/`、OSS CAD Suite的Yosys Slang
frontend、Surfer/FST示例、`reports/qor/latest.{json,md}`和`.agents/skills/`已落位。
Suite自带cocotb的动态库问题由主机Python/cocotb兼容层处理，详情见
`docs/known-limitations.md`。本inventory的数量和“当前维护痛点”保留审计起点语义，新增
文件不回写到起点统计。
