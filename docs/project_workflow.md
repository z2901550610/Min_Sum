# 项目记录与基线工作流

## 信息边界

| 问题 | 唯一主要记录 |
| --- | --- |
| RTL具体改了什么 | Git commit/diff |
| 为什么做架构、RAM、周期、资源或时序实验 | `docs/experiments/index.md`及必要的`EXP-xxxx-*.md` |
| 一次Vivado运行的精确条件和数字 | `reports/vivado/manifests/*.toml` |
| 当前哪个物理结果是基线 | `docs/design/vivado_baseline_registry.md` |
| 当前成品架构和验证状态 | `docs/design/implementation_status.md` |
| Vivado原始`.rpt`/`.dcp` | `D:/trike_reports/<run-id>/` |

Git负责普通修改，不为格式化、拼写、局部bugfix或等价重构建立实验项。只有形成
可验证假设、需要避免重复探索或会改变物理/周期判断时，才增加实验记录。

## 实验流程

1. 在索引分配下一个`EXP-xxxx`，用一句话写清假设和比较对象。
2. 提交可复现的起点，一次实验只改一个主要结构变量。
3. 记录功能、固定周期、K=3/K=4和公开参数覆盖；未运行的层明确写`pending`。
4. 每次Vivado运行分配唯一`RUN-YYYYMMDD-NN-<top>`，原始报告放在同名外部目录，
   仓库仅提交TOML manifest。KEM实现脚本同时生成`run_provenance.txt`，记录run ID、Git revision、
   dirty状态、filelist、defines、XDC、器件和实现directive。
5. 将器件、Vivado、XDC、参数、`L/K`、存储几何、时钟和报告阶段完全一致的运行
   标记为`comparable`；否则只能单列。
6. 结论只使用`retained`、`rejected`、`pending`、`incomparable`或`superseded`。
7. 只有`retained`且完整placed/routed的运行才能更新基线注册表；形成当前架构时再更新
   `implementation_status.md`。

## 生成物

- 可重建仿真数据、Verilator产物、波形、日志和Vivado运行目录不进入Git。
- 对于必须依赖外部KAT的fixture，Make目标和`config/local.mk.example`共同记录重建入口。
- 报告、演示文稿和临时导出物使用与`build/`分离的明确交付目录，不依赖未说明的
  `output`/`outputs`名称差异。
