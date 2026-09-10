---
name: rtl-implement
description: Implement SystemVerilog RTL changes authorized by the current task while preserving fixed schedule, filelists, tests, and documentation.
---

# RTL implementation

Follow `AGENTS.md`. Inspect affected sources and callers; use naming/Vivado
references only for unfamiliar constructs. Keep changed interfaces, fixtures,
filelists and assumptions consistent. Format task-owned SV and run the smallest
self-checking test. Add caller/reference or existing proof checks only for the
changed behavior. Known work needs no planner, status-document/matrix read or
Skill chain. Stop after relevant checks; preserve unrelated worktree changes.
