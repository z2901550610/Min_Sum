#!/usr/bin/env python3
"""Run SymbiYosys with compact terminal output and structured evidence logs."""

from __future__ import annotations

import hashlib
import os
import re
import shlex
import subprocess
import sys
from datetime import UTC, datetime
from pathlib import Path

from validation_events import append_event
from tool_runner import new_log, run_logged, diagnostic_lines


IMPORTANT_RE = re.compile(
    r"(\bERROR\b|\bFAIL(?:ED)?\b|assert|counterexample|traceback|"
    r"status returned|DONE \(|warning:)",
    re.IGNORECASE,
)


def option_value(args: list[str], option: str) -> str | None:
    for index, argument in enumerate(args):
        if argument == option and index + 1 < len(args):
            return args[index + 1]
        if argument.startswith(option + "="):
            return argument.split("=", maxsplit=1)[1]
    return None


def infer_project_and_task(args: list[str]) -> tuple[Path | None, str]:
    for index, argument in enumerate(args):
        if argument.endswith(".sby"):
            project = Path(argument)
            task = "default"
            for candidate in args[index + 1 :]:
                if not candidate.startswith("-"):
                    task = candidate
                    break
            return project, task
    return None, "default"


def safe_name(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", value).strip("_") or "sby"


def display_path(path: Path, cwd: Path) -> str:
    try:
        return path.resolve().relative_to(cwd.resolve()).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def project_sources(project: Path | None, cwd: Path) -> list[Path]:
    if project is None or not project.is_file():
        return []

    sources: list[Path] = [project]
    in_files = False
    for raw_line in project.read_text(encoding="utf-8").splitlines():
        line = raw_line.split("#", maxsplit=1)[0].strip()
        if line.startswith("[") and line.endswith("]"):
            in_files = line == "[files]"
            continue
        if not in_files or not line:
            continue
        try:
            parts = [part for part in shlex.split(line) if not part.endswith(":")]
        except ValueError:
            parts = line.split()
        for part in parts:
            candidate = Path(part)
            if not candidate.is_absolute():
                candidate = cwd / candidate
            if candidate.is_file():
                sources.append(candidate)
                break
    return sources


def source_digest(project: Path | None, cwd: Path, args: list[str]) -> tuple[str, list[str]]:
    digest = hashlib.sha256()
    digest.update("\0".join(args).encode("utf-8"))
    sources = project_sources(project, cwd)
    for source in sources:
        name = display_path(source, cwd)
        digest.update(name.encode("utf-8"))
        digest.update(b"\0")
        digest.update(source.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest(), [display_path(source, cwd) for source in sources]


def tool_version(real_sby: str) -> str:
    try:
        result = subprocess.run(
            [real_sby, "--version"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=10,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return "unavailable"
    lines = (result.stdout or "").splitlines()
    return lines[0].strip() if lines else "unknown"


def log_path(project: Path | None, task: str) -> Path:
    log_dir = Path(os.environ.get("SBY_LOG_DIR", "build/logs/sby"))
    project_name = project.stem if project is not None else "sby"
    return new_log(log_dir, f"{project_name}-{task}")


def emit_failure(output: str, log_file: Path) -> None:
    for line in diagnostic_lines(output, IMPORTANT_RE, failed=True):
        print(line, file=sys.stderr)
    print(f"full log: {log_file}", file=sys.stderr)


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print("usage: sby_quiet.py SBY_ARGUMENTS...", file=sys.stderr)
        return 2

    cwd = Path.cwd()
    project, task = infer_project_and_task(args)
    digest, sources = source_digest(project, cwd, args)
    output_directory = option_value(args, "-d")
    real_sby = os.environ.get("REAL_SBY", "sby")
    log_file = log_path(project, task)
    started_at = datetime.now(UTC)
    returncode, output, duration_seconds = run_logged([real_sby, *args], log_file)

    project_name = display_path(project, cwd) if project is not None else "unknown"
    result_id = f"sby:{project_name}:{task}"
    result = {
        "id": result_id,
        "evidence_layer": "formal",
        "status": "PASS" if returncode == 0 else "FAIL",
        "returncode": returncode,
        "started_at": started_at.isoformat(),
        "duration_seconds": round(duration_seconds, 3),
        "project": project_name,
        "task": task,
        "arguments": args,
        "output_directory": output_directory,
        "log": display_path(log_file, cwd),
        "source_digest": digest,
        "sources": sources,
        "tool": {"command": real_sby, "version": tool_version(real_sby)},
    }
    try:
        os.environ.setdefault("VALIDATION_RUN_ID", log_file.stem)
        events_path = append_event({
            **result,
            "name": f"{project_name} {task}",
            "command": [real_sby, *args],
            "signature": f"sby:{digest}",
            "output_bytes": len(output.encode("utf-8")),
            "output_lines": len(output.splitlines()),
        })
    except (OSError, ValueError) as error:
        print(f"sby FAIL: could not update validation evidence: {error}", file=sys.stderr)
        return returncode if returncode != 0 else 1

    if os.environ.get("SBY_QUIET") == "0":
        print(output, end="" if output.endswith("\n") else "\n")
    status = "PASS" if returncode == 0 else "FAIL"
    print(
        f"sby {status}: {project_name} {task} "
        f"({duration_seconds:.2f}s, digest: {digest[:12]}, log: {log_file}, events: {events_path})"
    )
    if returncode != 0:
        emit_failure(output, log_file)
    return returncode


if __name__ == "__main__":
    raise SystemExit(main())
