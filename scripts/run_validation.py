#!/usr/bin/env python3
"""Run compact, run-scoped repository workflow validation."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from datetime import UTC, datetime
from pathlib import Path

from validation_events import append_event, summary_text, write_summary


REPO_ROOT = Path(__file__).resolve().parents[1]
IMPORTANT_RE = re.compile(
    r"(\bFAIL(?:ED)?\b|\bERROR\b|fatal|traceback|assert|not found|missing required)",
    re.IGNORECASE,
)


def new_run_id() -> str:
    stamp = datetime.now(UTC).strftime("%Y%m%d-%H%M%S")
    return f"{stamp}-workflow-{os.getpid()}"


def git_value(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=REPO_ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return result.stdout.strip() if result.returncode == 0 else "unknown"


def command_signature(command: list[str]) -> str:
    return hashlib.sha256("\0".join(command).encode("utf-8")).hexdigest()


def repository_worktree_digest(repo_root: Path = REPO_ROOT) -> str:
    """Hash tracked and untracked, non-ignored working-tree file contents."""
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=repo_root,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if result.returncode != 0:
        return "unknown"

    digest = hashlib.sha256()
    try:
        for encoded_path in sorted(filter(None, result.stdout.split(b"\0"))):
            path = repo_root / os.fsdecode(encoded_path)
            digest.update(encoded_path)
            digest.update(b"\0")
            if path.is_symlink():
                digest.update(b"symlink\0")
                digest.update(os.fsencode(os.readlink(path)))
            elif path.is_file():
                digest.update(b"file\0")
                digest.update(path.read_bytes())
            else:
                digest.update(b"missing\0")
            digest.update(b"\0")
    except OSError:
        return "unknown"
    return digest.hexdigest()


def diagnostic_lines(output: str) -> list[str]:
    lines = output.splitlines()
    important = [line for line in lines if IMPORTANT_RE.search(line)]
    selected: list[str] = []
    for line in important[:30] + lines[-20:]:
        if line not in selected:
            selected.append(line)
    return selected


def write_metadata(path: Path, payload: dict[str, object]) -> None:
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def run_stage(
    *,
    name: str,
    layer: str,
    command: list[str],
    environment: dict[str, str],
    log_file: Path,
    show_output: bool,
) -> int:
    print(f"validation RUN: {name}", flush=True)
    start = time.monotonic()
    process = subprocess.run(
        command,
        cwd=REPO_ROOT,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    duration = time.monotonic() - start
    output = process.stdout or ""
    with log_file.open("a", encoding="utf-8") as log:
        log.write(f"\n===== {name}: {' '.join(command)} =====\n")
        log.write(output)
        if output and not output.endswith("\n"):
            log.write("\n")
    status = "PASS" if process.returncode == 0 else "FAIL"
    append_event(
        {
            "evidence_layer": layer,
            "name": name,
            "status": status,
            "returncode": process.returncode,
            "duration_seconds": round(duration, 3),
            "command": command,
            "signature": f"stage:{command_signature(command)}",
            "log": str(log_file),
            "output_bytes": len(output.encode("utf-8")),
            "output_lines": len(output.splitlines()),
        }
    )
    if show_output:
        print(output, end="" if output.endswith("\n") else "\n")
    elif process.returncode != 0:
        print(f"validation FAIL: {name}", file=sys.stderr)
        for line in diagnostic_lines(output):
            print(line, file=sys.stderr)
        print(f"full log: {log_file}", file=sys.stderr)
    else:
        print(f"validation PASS: {name} ({duration:.2f}s)", flush=True)
    return process.returncode


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-id")
    parser.add_argument("--make", default="make")
    parser.add_argument("--jobs", type=int, default=1)
    parser.add_argument("--run-root", type=Path, default=Path("build/results/runs"))
    parser.add_argument("--show-output", action="store_true")
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs must be at least 1")

    run_id = args.run_id or new_run_id()
    run_root = args.run_root
    if not run_root.is_absolute():
        run_root = REPO_ROOT / run_root
    run_dir = run_root / run_id
    if run_dir.exists():
        print(f"validation FAIL: run directory already exists: {run_dir}", file=sys.stderr)
        return 2
    run_dir.mkdir(parents=True)
    events_path = run_dir / "events.jsonl"
    log_file = run_dir / "run.log"
    log_root = run_dir / "logs"
    log_root.mkdir()
    validation_environment = {
        "VALIDATION_RUN_ID": run_id,
        "VALIDATION_RUN_ROOT": str(run_root),
        "VALIDATION_EVENTS_PATH": str(events_path),
        "SBY_LOG_DIR": str(log_root / "sby"),
        "VERILATOR_LOG_DIR": str(log_root / "verilator"),
        "RUN_QUIET_LOG_DIR": str(log_root / "simulation"),
        "CHECK_SUMMARY_PATH": str(run_dir / "check-summary.json"),
    }
    os.environ.update(validation_environment)
    environment = os.environ.copy()
    metadata = {
        "schema_version": 1,
        "run_id": run_id,
        "profile": "workflow",
        "started_at": datetime.now(UTC).isoformat(),
        "git_commit": git_value("rev-parse", "HEAD"),
        "git_dirty": bool(git_value("status", "--porcelain")),
        "worktree_digest_sha256": repository_worktree_digest(),
        "run_directory": str(run_dir),
        "log_directory": str(log_root),
        "make_jobs": args.jobs,
    }
    write_metadata(run_dir / "run.json", metadata)

    check_command = [args.make]
    if args.jobs > 1:
        check_command.append(f"-j{args.jobs}")
    check_command.append("check")

    stages = [
        (
            "workflow unit tests",
            "workflow",
            [args.make, "check-agent-workflow"],
            environment,
        ),
        (
            "workflow tool smoke",
            "workflow",
            [args.make, "workflow-smoke"],
            environment,
        ),
        (
            "complete local RTL gate",
            "workflow",
            check_command,
            environment,
        ),
        (
            "negative workflow smoke",
            "workflow",
            [args.make, "-C", "workflow-smoke", "check-failures"],
            {
                key: value
                for key, value in environment.items()
                if key not in validation_environment
            },
        ),
        (
            "QoR report from current gate",
            "qor",
            [
                args.make,
                "qor-report",
                f"QOR_REPORT_DIR={run_dir / 'qor'}",
                "QOR_LINT_STATUS=PASS",
                "QOR_SIMULATION_STATUS=PASS",
                "QOR_FORMAL_STATUS=PASS",
                f"QOR_VALIDATION_RUN_ID={run_id}",
            ],
            environment,
        ),
    ]

    returncode = 0
    for name, layer, command, stage_environment in stages:
        returncode = run_stage(
            name=name,
            layer=layer,
            command=command,
            environment=stage_environment,
            log_file=log_file,
            show_output=args.show_output,
        )
        if returncode != 0:
            break

    json_path, text_path, summary = write_summary(events_path, run_id)
    print(summary_text(summary), end="")
    print(f"summary: {json_path}")
    print(f"log: {log_file}")
    metadata["finished_at"] = datetime.now(UTC).isoformat()
    metadata["status"] = summary["status"]
    metadata["summary"] = str(json_path)
    metadata["summary_text"] = str(text_path)
    write_metadata(run_dir / "run.json", metadata)
    return returncode if returncode != 0 else (0 if summary["status"] == "PASS" else 1)


if __name__ == "__main__":
    raise SystemExit(main())
