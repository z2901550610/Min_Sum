#!/usr/bin/env python3
"""Run Verilator with compact terminal output and full logs on disk."""

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

from validation_events import append_event


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
    top = re.sub(r"[^A-Za-z0-9_.-]+", "_", infer_top(args))
    build_dir = option_value(args, "--Mdir")
    target = Path(build_dir).parent.name if build_dir else "compile"
    target = re.sub(r"[^A-Za-z0-9_.-]+", "_", target) or "compile"
    descriptor, path = tempfile.mkstemp(
        prefix=f"{stamp}-{target}-{top}-", suffix=".log", dir=log_dir
    )
    os.close(descriptor)
    return Path(path)


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
    start = time.monotonic()
    try:
        proc = subprocess.run(
            [real_verilator, *args],
            env=child_environment,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
    except FileNotFoundError:
        print(f"verilator FAIL: executable not found: {real_verilator}", file=sys.stderr)
        return 127
    output = proc.stdout or ""
    duration_seconds = time.monotonic() - start
    log_file.write_text(output, encoding="utf-8", errors="replace")

    top = infer_top(args)
    signature = hashlib.sha256("\0".join(args).encode("utf-8")).hexdigest()
    try:
        if proc.returncode == 0:
            write_executable_metadata(args, top, signature, real_verilator)
        append_event(
            {
                "evidence_layer": "compile",
                "name": top,
                "status": "PASS" if proc.returncode == 0 else "FAIL",
                "returncode": proc.returncode,
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
        return proc.returncode if proc.returncode != 0 else 1
    status = "FAIL" if proc.returncode else "OK"
    print(f"verilator {status}: {top} (log: {log_file})")
    emit_filtered(output, failed=proc.returncode != 0, log_file=log_file)
    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main())
