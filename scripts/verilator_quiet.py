#!/usr/bin/env python3
"""Run Verilator with compact terminal output and full logs on disk."""

from __future__ import annotations

import os
import re
import subprocess
import sys
import time
from pathlib import Path


IMPORTANT_RE = re.compile(
    r"(%(Error|Warning|Fatal)|\b(error|warning|fatal):|undefined reference|"
    r"Segmentation fault|Assertion|Exiting due to)",
    re.IGNORECASE,
)
TOP_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")


def option_value(args: list[str], option: str) -> str | None:
    for idx, arg in enumerate(args):
        if arg == option and idx + 1 < len(args):
            return args[idx + 1]
        if arg.startswith(option + "="):
            return arg.split("=", 1)[1]
    return None


def infer_top(args: list[str]) -> str:
    top = option_value(args, "--top-module")
    if top:
        return top

    for arg in reversed(args):
        path = Path(arg)
        if path.suffix in {".sv", ".v"} and TOP_RE.match(path.stem):
            return path.stem

    return "verilator"


def log_path(args: list[str]) -> Path:
    log_dir = Path(os.environ.get("VERILATOR_LOG_DIR", "build/logs/verilator"))
    log_dir.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y%m%d-%H%M%S")
    unique = f"{time.time_ns() % 1_000_000_000:09d}"
    top = re.sub(r"[^A-Za-z0-9_.-]+", "_", infer_top(args))
    return log_dir / f"{stamp}-{unique}-{top}.log"


def emit_filtered(output: str, *, failed: bool, log_file: Path) -> None:
    lines = output.splitlines()
    important = [line for line in lines if IMPORTANT_RE.search(line)]

    if important:
        print("---- verilator important output ----", file=sys.stderr)
        for line in important[:160]:
            print(line, file=sys.stderr)
        if len(important) > 160:
            print(
                f"... suppressed {len(important) - 160} more important-looking lines; see {log_file}",
                file=sys.stderr,
            )

    if failed:
        tail = lines[-80:]
        if tail:
            print("---- verilator tail ----", file=sys.stderr)
            for line in tail:
                print(line, file=sys.stderr)


def main() -> int:
    args = sys.argv[1:]
    real_verilator = os.environ.get("REAL_VERILATOR", "verilator")

    if os.environ.get("VERILATOR_QUIET") == "0":
        return subprocess.run([real_verilator, *args]).returncode

    log_file = log_path(args)
    try:
        proc = subprocess.run(
            [real_verilator, *args],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
    except FileNotFoundError:
        print(f"verilator FAIL: executable not found: {real_verilator}", file=sys.stderr)
        return 127
    output = proc.stdout or ""
    log_file.write_text(output, encoding="utf-8", errors="replace")

    top = infer_top(args)
    status = "FAIL" if proc.returncode else "OK"
    print(f"verilator {status}: {top} (log: {log_file})")
    emit_filtered(output, failed=proc.returncode != 0, log_file=log_file)
    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main())
