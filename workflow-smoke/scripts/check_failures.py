#!/usr/bin/env python3
"""Verify that lint, simulation, and formal gates reject injected RTL faults."""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SMOKE = ROOT / "workflow-smoke"
OUTPUT = ROOT / "build" / "workflow-smoke" / "fault-injection"
GOOD_RTL = SMOKE / "rtl" / "workflow_counter.sv"


def run_expected_failure(name: str, command: list[str], cwd: Path) -> None:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    log_path = OUTPUT / f"{name}.log"
    log_path.write_text(result.stdout + result.stderr, encoding="utf-8")
    if result.returncode == 0:
        raise SystemExit(f"FAIL {name}: injected fault was not detected; log={log_path}")
    print(f"PASS {name}: rejected injected fault; log={log_path}")


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    source = GOOD_RTL.read_text(encoding="utf-8")

    lint_rtl = OUTPUT / "workflow_counter_lint_fault.sv"
    lint_rtl.write_text(
        source.replace("o_wrap  <= &o_count;", "o_wrap  <= undeclared_signal;"),
        encoding="utf-8",
    )
    run_expected_failure(
        "lint",
        [
            "verilator",
            "--lint-only",
            "--sv",
            "-Wall",
            "--top-module",
            "workflow_counter",
            str(lint_rtl),
        ],
        ROOT,
    )

    behavior_rtl = OUTPUT / "workflow_counter_behavior_fault.sv"
    behavior_rtl.write_text(
        source.replace("o_count <= o_count + 1'b1;", "o_count <= o_count - 1'b1;"),
        encoding="utf-8",
    )
    sim_build = OUTPUT / "sim"
    run_expected_failure(
        "simulation",
        [
            "make",
            "-C",
            str(SMOKE),
            "test",
            f"COUNTER_RTL={behavior_rtl}",
            f"BUILD_DIR={sim_build}",
        ],
        ROOT,
    )

    formal_project = OUTPUT / "formal-project"
    shutil.copytree(SMOKE, formal_project, dirs_exist_ok=True)
    formal_rtl = formal_project / "rtl" / "workflow_counter.sv"
    formal_rtl.write_text(
        source.replace("o_count <= o_count + 1'b1;", "o_count <= o_count - 1'b1;"),
        encoding="utf-8",
    )
    formal_build = OUTPUT / "formal"
    run_expected_failure(
        "formal",
        [
            "make",
            "-C",
            str(formal_project),
            "formal",
            f"BUILD_DIR={formal_build}",
            f"SBY={ROOT / 'scripts' / 'sby_quiet.py'}",
            "REAL_SBY=sby",
            f"SBY_LOG_DIR={OUTPUT / 'sby-logs'}",
        ],
        ROOT,
    )

    if os.environ.get("KEEP_FAILURE_ARTIFACTS") != "1":
        print("Fault sources and logs retained under build/workflow-smoke/fault-injection")


if __name__ == "__main__":
    main()
