# Workflow Conflict Matrix

审计日期：2026-08-28

| Existing Asset | Target Design | Conflict | Decision | Reason | Validation | Final State |
| --- | --- | --- | --- | --- | --- | --- |
| `filelists/*.f` | 单一 source-of-truth | 计划示例使用 `config/rtl.f` | KEEP | 现有 9 个 top 需要不同有序闭包，且已有审计器 | `make check-filelists` | filelists 继续 canonical |
| 大量 self-checking SV TB | cocotb 主仿真模板 | 整体迁移会改动高保护 oracle | KEEP | SV TB 已覆盖 fixed-cycle、reference 和 KEM 层次 | `make test-unit test-integration` | cocotb 仅用于 PoC/适合的新模块 |
| `make format-rtl/check-rtl/test-*` | `make format/lint/test/...` | 名称不对称但能力成熟 | MIGRATE | 保留细粒度入口，新增一层直接 alias | alias 与原目标结果相同 | 短名称成为文档入口，原名称作为诊断子目标 |
| `ci-fast/ci-smoke/ci-nightly` | `check/regress` | 计划名称与项目风险分层不同 | KEEP + ALIAS | 现有 gate 已编码正式矩阵与 K=3/K=4 范围 | `make check`、`make regress` | 不删除 CI 风险层级 |
| 单独安装的 Homebrew/local 工具 | 固定 OSS CAD Suite | 版本来源分散 | MIGRATE + COMPATIBILITY | Suite补齐Yosys Slang与solver闭包；主机工具只保留已验证兼容层 | 版本锁 + PoC + `ci-fast` | EDA来自2026-08-27 Suite；Verible/Surfer与Python/cocotb来自主机 |
| Yosys native SV frontend | Yosys Slang frontend | 原Homebrew Yosys缺少`slang.so` | ADD | PoC与真实模块需验证Slang frontend；生产formal的受控子集继续原sby脚本 | `yosys -m slang`, PoC/真实模块synth | Suite的`read_slang`用于local synth；formal保持scoped native frontend |
| Verible/Slang/Verilator 全仓检查 | 单一 `lint` | 三层职责不同 | KEEP + AGGREGATE | 不能用一个工具替另一个证据层 | `make lint` | `lint` 聚合并保留子目标 |
| 3 个 scoped formal harness | 全项目 formal | 大型 decoder/KEM 状态空间不适合无界扩张 | KEEP/EXTEND selectively | 当前属性覆盖 constant-time 小控制且含 cover | `make formal-fast/nightly` | 只为可审查小控制增加属性 |
| Vivado batch targets | 本地 Xilinx QoR | 本机无 Vivado | KEEP + SEPARATE | Yosys estimate 不能替代 mapping/timing | manifest/XDC/Windows run | `synth/qor` 标注 estimate，Vivado 仍为 physical authority |
| `AGENTS.md` + `CLAUDE.md` | 一个 Agent contract | 两个文件名可能看似重复 | KEEP identical | 两种 Agent 入口需要，内容逐字相同且已有校验规则 | `cmp` + records check | 同一合约的镜像，不再叠加 prompt |
| 无 repo skills | 分职责 Skills | 细节若继续加入 AGENTS 会膨胀 | ADD | 官方 Codex 路径为 `.agents/skills` | discovery + dry run | focused skills，AGENTS 只导航 |
| 根目录 K-sign PNG/CSV | `docs/figures/` 或 `reports/` | 当前路径污染根目录 | MIGRATE later | 数据有验证价值但 provenance 尚未完全核对 | 引用搜索 + 内容核验 | 本次不删除；形成独立数据迁移任务 |
| ignored `build/`, `obj_dir/`, `tb/generated/` | 统一生成目录政策 | Verilator 默认仍使用 `obj_dir/` | KEEP | wrapper 与大量现有 target 已依赖，且均被忽略 | clean-clone gate | 不为目录模板进行无收益重写 |
| `sim` alias | 唯一 `test` | 两个同义入口 | DELETE after docs cutover | `sim` 没有独有能力 | 全文引用搜索、`make test` | 兼容窗口结束后移除 |

## 取舍原则

本次迁移不以模板目录一致性为目标。优先保留经过项目验证的 filelist、SV testbench、formal
harness 和 Vivado 记录体系；只在确有能力缺口或入口歧义时增加或删除内容。Suite自带
cocotb在本机存在动态库兼容问题，因此以主机Python/cocotb作为已验证兼容层。所有本地综合
结论均标注为 Yosys 结构/资源估算，不写成 Vivado 实现结果。
