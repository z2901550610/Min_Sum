#!/usr/bin/env python3
"""Run Verilator with compact terminal output and full logs on disk."""

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

from validation_events import append_event
from tool_runner import new_log, run_logged, diagnostic_lines


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
    top = infer_top(args)
    build_dir = option_value(args, "--Mdir")
    target = Path(build_dir).parent.name if build_dir else "compile"
    return new_log(log_dir, f"{target}-{top}")


def executable_path(args: list[str], top: str) -> Path | None:
    if "--binary" not in args:
        return None
    build_dir = Path(option_value(args, "--Mdir") or "obj_dir")
    prefix = option_value(args, "--prefix") or f"V{top}"
    return build_dir / prefix


def write_executable_metadata(
    args: list[str], top: str, signature: str, real_verilator: str
) -> Path | None:
    executable = executable_path(args, top)
    if executable is None:
        return None
    metadata_path = executable.with_name(executable.name + ".validation.json")
    metadata_path.parent.mkdir(parents=True, exist_ok=True)
    metadata_path.write_text(
        json.dumps(
            {
                "schema_version": 1,
                "top": top,
                "compiler": real_verilator,
                "compile_signature": signature,
                "arguments": args,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )
    return metadata_path


def emit_filtered(output: str, *, failed: bool, log_file: Path) -> None:
    lines = output.splitlines()
    selected = diagnostic_lines(output, IMPORTANT_RE, failed=failed)
    for line in selected:
        print(line, file=sys.stderr)
    if len(lines) > len(selected) and (selected or failed):
        print(f"full Verilator output: {log_file}", file=sys.stderr)


def main() -> int:
    args = sys.argv[1:]
    real_verilator = os.environ.get("REAL_VERILATOR", "verilator")
    child_environment = os.environ.copy()
    for make_variable in ("MAKEFLAGS", "MFLAGS", "MAKELEVEL"):
        child_environment.pop(make_variable, None)
    build_dir = option_value(args, "--Mdir")
    if build_dir:
        try:
            Path(build_dir).mkdir(parents=True, exist_ok=True)
        except OSError as error:
            print(
                f"verilator FAIL: could not create build directory {build_dir}: {error}",
                file=sys.stderr,
            )
            return 1

    if os.environ.get("VERILATOR_QUIET") == "0":
        return subprocess.run(
            [real_verilator, *args], env=child_environment
        ).returncode

    log_file = log_path(args)
    returncode, output, duration_seconds = run_logged(
        [real_verilator, *args], log_file, env=child_environment
    )

    top = infer_top(args)
    signature = hashlib.sha256("\0".join(args).encode("utf-8")).hexdigest()
    try:
        if returncode == 0:
            write_executable_metadata(args, top, signature, real_verilator)
        append_event(
            {
                "evidence_layer": "compile",
                "name": top,
                "status": "PASS" if returncode == 0 else "FAIL",
                "returncode": returncode,
                "duration_seconds": round(duration_seconds, 3),
                "command": [real_verilator, *args],
                "signature": f"verilator:{signature}",
                "log": str(log_file),
                "output_bytes": len(output.encode("utf-8")),
                "output_lines": len(output.splitlines()),
            }
        )
    except (OSError, ValueError) as error:
        print(f"verilator FAIL: could not update validation evidence: {error}", file=sys.stderr)
        return returncode if returncode != 0 else 1
    status = "FAIL" if returncode else "OK"
    print(f"verilator {status}: {top} (log: {log_file})")
    emit_filtered(output, failed=returncode != 0, log_file=log_file)
    return returncode


if __name__ == "__main__":
    raise SystemExit(main())
