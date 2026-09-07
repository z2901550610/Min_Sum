#!/usr/bin/env python3
"""Run a command while suppressing Verilator runtime boilerplate."""

from __future__ import annotations

import hashlib
import json
import os
import re
import sys
from pathlib import Path

from validation_events import append_event
from tool_runner import new_log, run_logged, diagnostic_lines


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
    name = Path(command[0]).name if command else "command"
    return new_log(log_dir, name)


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
    returncode, output, duration_seconds = run_logged(command, log_file)

    binary_signature = executable_signature(command[0])
    signature = hashlib.sha256(
        (binary_signature + "\0" + "\0".join(command)).encode("utf-8")
    ).hexdigest()
    try:
        append_event(
            {
                "evidence_layer": "simulation",
                "name": Path(command[0]).name,
                "status": "PASS" if returncode == 0 else "FAIL",
                "returncode": returncode,
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
        return returncode if returncode != 0 else 1

    lines = filtered_lines(output)
    max_lines = int(os.environ.get("RUN_QUIET_MAX_LINES", "20"))
    if returncode == 0:
        for line in lines[:max_lines]:
            print(line)
        if len(lines) > max_lines:
            print(f"... suppressed {len(lines) - max_lines} more lines; see {log_file}")
    else:
        selected = diagnostic_lines("\n".join(lines), IMPORTANT_RE, failed=True, limit=max_lines)
        for line in selected:
            print(line, file=sys.stderr)
        print(f"command FAIL: {command[0]} (log: {log_file})", file=sys.stderr)

    return returncode


if __name__ == "__main__":
    raise SystemExit(main())
