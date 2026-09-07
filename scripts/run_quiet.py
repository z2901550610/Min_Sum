#!/usr/bin/env python3
"""Run a command while suppressing Verilator runtime boilerplate."""

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

from validation_events import append_event


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


def executable_signature(executable: str) -> str:
    path = Path(executable)
    metadata_path = path.with_name(path.name + ".validation.json")
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        signature = metadata.get("compile_signature")
        if isinstance(signature, str) and signature:
            return signature
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        pass
    try:
        stat = path.stat()
        fallback = f"{path.resolve()}:{stat.st_size}:{stat.st_mtime_ns}"
    except OSError:
        fallback = str(path)
    return hashlib.sha256(fallback.encode("utf-8")).hexdigest()


def main() -> int:
    command = sys.argv[1:]
    if not command:
        print("usage: run_quiet.py COMMAND [ARG ...]", file=sys.stderr)
        return 2

    log_file = log_path(command)
    start = time.monotonic()
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
    duration_seconds = time.monotonic() - start
    log_file.write_text(output, encoding="utf-8", errors="replace")

    binary_signature = executable_signature(command[0])
    signature = hashlib.sha256(
        (binary_signature + "\0" + "\0".join(command)).encode("utf-8")
    ).hexdigest()
    try:
        append_event(
            {
                "evidence_layer": "simulation",
                "name": Path(command[0]).name,
                "status": "PASS" if proc.returncode == 0 else "FAIL",
                "returncode": proc.returncode,
                "duration_seconds": round(duration_seconds, 3),
                "command": command,
                "signature": f"simulation:{signature}",
                "executable_signature": binary_signature,
                "log": str(log_file),
                "output_bytes": len(output.encode("utf-8")),
                "output_lines": len(output.splitlines()),
            }
        )
    except (OSError, ValueError) as error:
        print(f"command FAIL: could not update validation evidence: {error}", file=sys.stderr)
        return proc.returncode if proc.returncode != 0 else 1

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
