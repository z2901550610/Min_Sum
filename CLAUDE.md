# Research RTL Agent Instructions

This graduate research repository contains fixed-schedule BIKE/MDPC decoding and TRIKE KEM RTL. Production sources are in `rtl/`, ordered by `filelists/*.f`; tests, proofs and references are in `tb/`, `formal/` and `software/`.

## Non-negotiable boundaries

- Preserve functional and golden/KAT semantics. Within each public parameter level, cycles and memory-access counts must not depend on secrets, input data, mismatch position, success or convergence. No early exit. Public profiles may use different fixed schedules.
- Keep simulation, formal, local synthesis estimates and Vivado physical evidence distinct. Never report an unfinished or unavailable check as PASS. DFR results need trials, failures and a confidence bound.
- Physical claims require comparable Vivado device/version/XDC/parameters/defines/report stage and a RUN manifest. Functional-only work does not require Vivado. Use Windows Tcl Console or direct batch Tcl; see `docs/workflow.md`.

## Work within the task

- Inspect `git status --short` and relevant sources/callers first. Preserve unrelated changes. Review requests do not authorize edits; existing implementation authorization covers necessary reversible work without repeated approval. Clarify only material scope, interface, cryptographic or cycle-contract changes.
- Prefer one canonical implementation. Migrate internal callers together; do not add speculative compatibility layers, aliases or fallback paths. Preserve external contracts and experiment provenance.
- Read only relevant documentation and failing-log excerpts; avoid dumping whole files, unchanged diffs or successful logs. Skills in `.agents/skills/` are task-specific references, not a mandatory stage sequence. A local equivalent fix needs no new specification or architecture ceremony. Consult the appropriate skill for unfamiliar design, verification or tool work; do not reread unchanged guidance.

## Proportional validation

- Use `source scripts/eda-env.sh` in each terminal; run `uv sync --frozen` after checkout or Python dependency changes. Required tools must work. Day-to-day version differences are warnings; `make check-tool-versions` verifies the recorded baseline explicitly.
- For local RTL edits: format task-owned files with `make format FILES="..."`, run `make check-fast` and the smallest self-checking test. Keep interfaces, fixtures and filelists synchronized. Follow existing naming and Vivado coding conventions when editing RTL.
- Use `make check-plan VALIDATION_PATHS="..."` when test selection is unclear or the task scope changes; a known focused test needs no planning round. Maintain test commands/groups/owners in `config/test_catalog.toml`; Make and the planner consume it. Owners select focused tests; unowned hardware falls back to its profile. Unrouted research scripts/data need task-appropriate review, not registration.
- Run affected proof/cover when control, scheduling or formal properties change; affected public profiles when parameters change; integration/reference tests when shared behavior changes. Use `make check` for broad integration/toolchain qualification and `make validate-workflow` for core build/runner changes. Workflow validation runs only unit tests and tool smoke; it never substitutes for production RTL checks or invokes QoR. Neither is required for every local edit, documentation update or helper script.
- Reuse checks already passed in this task if inputs and conditions are unchanged. Follow required running checks to completion. Report unavailable gates as NOT_RUN with a concrete blocker; inapplicable evidence is NOT_APPLICABLE.

Keep active docs about the current design, historical comparisons in experiment records, and generated artifacts out of source directories. Use one EXP per architecture/QoR hypothesis, not per ordinary fix. Keep `AGENTS.md` and `CLAUDE.md` identical; use conventional commit subjects. Detailed commands and evidence rules: `docs/workflow.md` and `docs/verification/validation_matrix.md`.
