#!/usr/bin/env python3
"""Run a command while suppressing Verilator runtime boilerplate."""

from __future__ import annotations

import os
import re
import subprocess
import sys
import time
from pathlib import Path


SUPPRESS_RE = re.compile(
    r"^-\s+(S i m u l a t i o n\s+R e p o r t|Verilator:|.*Verilog \$finish)"
)
IMPORTANT_RE = re.compile(
    r"(\bPASS\b|\bFAIL\b|seed=|%(Error|Warning|Fatal)|\b(error|warning|fatal):|"
    r"Assertion|Segmentation fault)",
    re.IGNORECASE,
)


def log_path(command: list[str]) -> Path:
    log_dir = Path(os.environ.get("RUN_QUIET_LOG_DIR", "build/logs/run"))
    log_dir.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y%m%d-%H%M%S")
    unique = f"{time.time_ns() % 1_000_000_000:09d}"
    name = Path(command[0]).name if command else "command"
    safe_name = re.sub(r"[^A-Za-z0-9_.-]+", "_", name)
    return log_dir / f"{stamp}-{unique}-{safe_name}.log"


def filtered_lines(output: str) -> list[str]:
    return [line for line in output.splitlines() if not SUPPRESS_RE.search(line)]


def main() -> int:
    command = sys.argv[1:]
    if not command:
        print("usage: run_quiet.py COMMAND [ARG ...]", file=sys.stderr)
        return 2

    log_file = log_path(command)
    try:
        proc = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
    except FileNotFoundError:
        print(f"command FAIL: executable not found: {command[0]}", file=sys.stderr)
        return 127
    output = proc.stdout or ""
    log_file.write_text(output, encoding="utf-8", errors="replace")

    lines = filtered_lines(output)
    max_lines = int(os.environ.get("RUN_QUIET_MAX_LINES", "200"))
    if proc.returncode == 0:
        for line in lines[:max_lines]:
            print(line)
        if len(lines) > max_lines:
            print(f"... suppressed {len(lines) - max_lines} more lines; see {log_file}")
    else:
        important = [line for line in lines if IMPORTANT_RE.search(line)]
        for line in important[:max_lines]:
            print(line, file=sys.stderr)
        if len(important) > max_lines:
            print(f"... suppressed {len(important) - max_lines} more important lines; see {log_file}", file=sys.stderr)
        print("---- command tail ----", file=sys.stderr)
        for line in lines[-80:]:
            print(line, file=sys.stderr)
        print(f"command FAIL: {command[0]} (log: {log_file})", file=sys.stderr)

    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main())
