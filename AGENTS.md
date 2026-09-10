# Research RTL Agent Instructions

This is a graduate research exploration repository, not a production qualification program.
RTL lives in `rtl/`, ordered by `filelists/*.f`; tests, proofs and references live in `tb/`, `formal/`, `software/`.

## Preserve the research contract

- Preserve golden/KAT semantics. Within each public parameter level, cycles and memory-access counts must not depend on secrets, data, mismatch position, success or convergence. No early exit.
- Distinguish simulation, scoped formal, local synthesis estimates and Vivado results. Never call unfinished or unrun checks PASS. DFR claims need trials, failures and a confidence bound.
- Physical comparisons need matching device/tool/XDC/parameters/defines/report stage and RUN evidence. Functional exploration needs no Vivado. Use Windows Tcl Console or direct batch Tcl.

## Work and stop

- Inspect Git status and relevant sources/callers; preserve unrelated changes. Review requests do not authorize edits. Existing implementation authorization covers necessary reversible work; clarify only material scope/interface/cryptographic/cycle-contract changes.
- Read only what resolves the current question. Known local work needs no mandatory planner, design-status/matrix read, specification phase or Skill chain. Skills are references for unfamiliar work, not stages.
- Prefer one canonical implementation and existing scripts/Make entrypoints. Migrate callers together; avoid speculative compatibility layers, extra runners and one-task configuration systems.
- Use `./eda <command>` for local tools. Sync Python dependencies only for a missing environment or changed dependencies. Git and file operations need no EDA setup.
- Format only task-owned SV files. Start with the smallest self-checking test that detects the changed behavior; its compilation supplies local syntax/elaboration feedback. During debugging rerun only the failing test.
- Add caller/reference checks when interfaces or shared behavior change; add relevant elaboration for filelist/package/top changes. Run affected existing proof/cover for changed scheduling/control properties; do not create a formal project for every FSM edit.
- Test changed parameter entries directly. Shared geometry changes use the smallest/largest relevant profiles (TRIKE160/512, BIKE128/256), plus cheap boundary cases. Do not run unrelated families or add middle profiles without a changed branch/table or explicit request.
- `make check-plan VALIDATION_PATHS="..."` is optional advice when test selection is unclear. It does not execute checks or establish PASS. Missing owners require selecting a relevant test, not running every suite.
- `check-fast`/`ci-fast`, full KEM reference, random campaigns and `check` are explicit integration/research tools, not automatic closing gates. Workflow helpers/Make recipes need relevant unit tests and the changed command; environment/runner interoperability needs `validate-workflow`. A new toolchain baseline needs `check`.
- Reuse passing results when inputs/conditions are unchanged. Wait for required running checks, report unresolved limits, then stop. Do not add another review, benchmark, report or test because it is available.

## Keep records small

- Batch independent reads, inspect failure excerpts, and wait on the original process. Keep full automatic logs and exit codes; return a short result and useful log path.
- Exploration and routine debugging need no tracked diary or plan. Record a short lesson only for an evidence-backed rejected direction: conditions, reason, evidence/reproduction and retry conditions. Pending/cancelled/untested is not failure.
- Successful changes update only affected current design facts and necessary evidence. Keep historical EXP/RUN references; read old records only for a relevant question. Do not duplicate results across documents or append stages. Generated artifacts stay outside source directories.
- Keep `AGENTS.md` and `CLAUDE.md` identical. Use conventional commit subjects. Details: [workflow](docs/workflow.md), [record policy](docs/project_workflow.md), [historical lessons](docs/experiments/index.md).
