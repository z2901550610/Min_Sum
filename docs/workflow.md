# 本地 SystemVerilog 工作流

这是研究仓库。日常修改以相关静态检查和定向自检测试为主，完整验证用于集成、工具链资格和明确的研究结论。常数时间、功能正确性和证据真实性不因流程精简而放宽。

## 环境

checkout 或 Python 依赖变化后执行 `uv sync --frozen`；每个新终端执行 `source scripts/eda-env.sh`。环境脚本选择已安装的 OSS CAD Suite 和项目 `.venv`，不隐式安装工具。

`make tool-versions` 输出实际版本：与 `config/rtl_toolchain.lock` 不同只告警，命令缺失或执行失败仍失败。`make check-tool-versions` 显式要求基线版本匹配；`make check-local-tools` 检查完整工具集和 Yosys Slang frontend 能力。日常定向测试只需要其实际使用的工具，不预先要求整个工具集。

## 选择验证范围

| 场景 | 命令或要求 |
| --- | --- |
| 局部 RTL/TB 修改 | `make format FILES="..."`、`make check-fast`、所属 `make test-<name>` |
| 日常集成/自动 CI | `make ci-fast`：`check-fast` 加单元及集成测试 |
| 控制、调度或形式属性改变 | 相关 `make formal-<name>` proof/cover；改变参数时覆盖受影响 public profiles |
| 算法、KEM共享语义或接口改变 | 相关 reference、集成和固定周期/访问计数检查；按研究结论决定随机试验规模 |
| 广泛集成、工具链资格 | `make check`：完整工具检查、记录、静态、短形式矩阵、仿真、展开和本地综合 |
| 核心 Make、验证 runner、环境或 smoke 机制改变 | `make validate-workflow`：工作流单测、正/负工具 smoke；生产 recipe 改变另运行所属目标 |
| 普通工作流辅助脚本 | `make check-agent-workflow` 和脚本实际功能所需检查；无需完整 RTL 资格验证 |
| 文档、Skill、实验记录 | 普通文档/Skill仅 `git diff --check` 并核对修改涉及的链接；实验/物理记录才运行 `make check-records` |
| FPGA 资源/时序结论 | 同条件 Vivado 实现；本地 Yosys 结果不能代替 |

`check-fast` 执行 filelist 检查和 Slang 展开；不声称覆盖所有运行参数或建立行为正确性，所属 TB 必须自检。`make lint`/`check-rtl` 仍保留完整 filelist、格式、Verible、Verilator、Slang 检查，供诊断或完整资格使用。`make format-check` 只读检查维护中的 SV 格式；`format-changed` 和 `format-all` 是显式批量修改入口。

GitHub 的 `.github/workflows/ci.yml` 在 push/PR 调用 `make ci-fast`，手动 `workflow_dispatch` 调用完整 `make check`。CI 使用明确的安装版本；YAML 不复制测试、proof 或综合 recipe。`ci-nightly` 保留短形式矩阵、扩展形式及多 seed 随机测试；`ci-kem-reference` 保留 KEM 参考/KAT 边界。

## 定向规划

`make check-plan VALIDATION_PATHS="..."` 为指定文件选择检查；全部差异属于当前任务时可省略路径。它只规划，不执行或产生 PASS。已知测试时直接运行，无需在每轮编辑前重复规划；范围明确且未变化时，完成定向检查即可，无需结束前再次规划。

`config/test_catalog.toml` 是测试命令、fixture 前置条件、测试分组和测试 owner 的唯一维护入口，`scripts/test_catalog.py` 为 Make 生成忽略的 `build/test_catalog.mk`。Make 会在清单或生成器变化时重建它；现有 `make test-*` 名称不变。规划器直接读取同一清单，不解析生成文件。测试命令保留 Make 原生变量展开，生产 `filelists/*.f` 仍控制规范源顺序。

`config/validation_profiles.toml` 只保存验证策略、非测试 owner、覆盖关系和生成表格；`docs/verification/validation_matrix.md` 展示最小门禁。owner 是选择最小测试的可选映射，缺少 owner 的硬件回退到 profile。已配置的无效 target、重叠硬件 owner 或核心文件未路由仍报错。普通研究脚本和数据可以不登记；规划器列出未路由文件，由任务选择适当检查，不自动将其算作通过。

修改配置后运行 `make update-validation-matrix` 和 `make check-validation-profiles`。后者由工作流单测入口执行，与文档记录检查分离。配置字段和覆盖关系需要有效，但文档句子的具体措辞不再作为机器门禁。

只运行适用的任务命令和升级项。已经通过且输入未变的检查无需重复；参数/接口、共享行为或新的失败证据改变了范围时再扩大。完整 `make check` 和 `validate-workflow` 不属于每个 helper、Skill 或局部 RTL 修改的默认要求。

## 日志与证据

toy fixture 内容未变时不重写文件，避免无意义地改变依赖时间戳；测试仍每次执行。

三个工具包装和工作流 runner 共用 `scripts/tool_runner.py` 的命令执行和诊断提取；工具日志通过原子分配独立路径，完整输出和退出码均保留。工具专属的参数、编译元数据和既有 SBY 摘要格式仍由相应包装维护。

直接仿真使用 `build/verilator/<make-target>/<variant>/`；并行任务必须使用独立构建目录和原子创建的日志。终端输出简短状态和日志位置；详细诊断留在 `build/logs/`，需要时读取相应失败日志。默认只显示最多 20 行主要诊断和 20 行失败尾部并去重；仿真正常输出默认最多 20 行，`RUN_QUIET_MAX_LINES` 可显式调整。不要为减少输出而吞掉非零退出码。

`make validate-workflow` 不调用生产 `check` 或生成 QoR 报告；其 PASS 只表示工作流与独立计数器 smoke 通过，不能表示产品 RTL 通过。`check` 与 `qor` 分别是独立的硬件验证和资源研究入口，只有任务需要时才组合执行。

`make validate-workflow` 默认 `VALIDATION_JOBS=2`（用于工具 smoke），输出到 `build/results/runs/<run-id>/`：`run.json` 记录提交和非忽略工作树摘要，`run.log` 保存完整输出，`events.jsonl` 和 `summary.json`/`summary.txt` 记录实际执行结果。负向 smoke 的预期失败使用隔离环境。状态为 PASS、FAIL、NOT_RUN、NOT_APPLICABLE；未执行的层不能被其他 PASS 掩盖。重复 signature 和最慢任务仅用于诊断，不另设形式化门禁。当前不自动复用历史缓存证据。

`make regress` 是固定 seed 随机 smoke。DFR/FLS 结论另须记录参数、trials、failures、停止规则和置信界。仿真比较数据结果、协议、访问次数和准确 start/done 周期；形式结论受 harness 和 assumptions 限定。

`make synth` 使用 Yosys+Slang 做结构与资源估计。`make qor` 验证 `kem_ct_compare_select` 并写入 `build/results/qor/`；只有显式 `make qor-record` 更新 tracked 报告。普通修复由 Git 和测试记录；架构/QoR 假设使用一个 EXP 系列。

## 按需参考与物理实现

`.agents/skills/` 提供 spec、architecture、implement、lint-debug、verification、formal、synthesis 和 qor-opt 的专题指导。只读本任务真正需要的技能，没有强制级联；局部等价修改不要求新建规格或架构阶段。RTL 命名和编码细节见 `docs/design/naming_conventions.md`、`docs/vivado_systemverilog_guidelines.md`。

Vivado 使用 Windows Tcl Console 或 `vivado -mode batch -source scripts/vivado_trike_kem_cores.tcl`，Make 包装可选。明确报告根目录、run ID、top、part、XDC、defines 和 directives；每次执行保存 RUN manifest，原始报告置于 `${VIVADO_REPORT_ROOT}/<run-id>/`。比较须保持器件/速度等级、版本、时钟、参数、L/K、存储几何和报告阶段一致，并记录 LUT、FF、Slice、BRAM/RAMB、DSP、setup WNS/TNS、hold WHS。只有保留的完整可比 placed/routed 结果才能更新物理基线。功能修改不要求额外跑 Vivado，也不宣称未经验证的物理收益。

独立工具链 smoke 位于 `workflow-smoke/`，不进入生产 filelist。可用 `make workflow-smoke`、`make -C workflow-smoke check-failures` 单独定位环境问题；可选波形使用 `make -C workflow-smoke test WAVES=1 LZ4_PREFIX=/installed/lz4/prefix`。
