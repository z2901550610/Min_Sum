#!/usr/bin/env python3
"""Validate the compact experiment and Vivado record structure."""

from __future__ import annotations

import re
import tomllib
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MANIFEST_DIR = REPO_ROOT / "reports" / "vivado" / "manifests"
RUN_ID_RE = re.compile(r"RUN-\d{8}-\d{2}-[a-z0-9][a-z0-9-]*$")
EXPERIMENT_ID_RE = re.compile(r"EXP-\d{4}$")
ALLOWED_STATUS = {"pending", "pass", "fail", "incomparable", "superseded"}
ALLOWED_VERDICT = {"retained", "rejected", "pending", "incomparable", "superseded"}
REQUIRED_TABLES = {"design", "tool", "functional", "results"}
MARKDOWN_LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def validate_manifest(path: Path, seen_run_ids: set[str], experiment_ids: set[str]) -> None:
    with path.open("rb") as stream:
        data = tomllib.load(stream)
    run_id = data.get("run_id", "")
    require(RUN_ID_RE.fullmatch(run_id) is not None, f"{path}: invalid run_id {run_id!r}")
    require(path.stem == run_id, f"{path}: filename must match run_id")
    require(run_id not in seen_run_ids, f"{path}: duplicate run_id {run_id}")
    seen_run_ids.add(run_id)
    experiment_id = data.get("experiment_id", "")
    require(
        EXPERIMENT_ID_RE.fullmatch(experiment_id) is not None,
        f"{path}: invalid experiment_id {experiment_id!r}",
    )
    require(experiment_id in experiment_ids, f"{path}: experiment_id is missing from index.md")
    require(data.get("status") in ALLOWED_STATUS, f"{path}: invalid status")
    require(data.get("verdict") in ALLOWED_VERDICT, f"{path}: invalid verdict")
    require(data.get("schema_version") == 1, f"{path}: unsupported schema_version")
    require(REQUIRED_TABLES <= data.keys(), f"{path}: missing required TOML table")
    for key in ("date", "source_revision", "report_root"):
        require(bool(data.get(key)), f"{path}: missing {key}")
    for table, keys in {
        "design": ("top", "profile", "memory_geometry"),
        "tool": ("vivado", "part", "xdc", "report_stage", "clock_period_ns"),
        "functional": ("fixed_cycles", "tests", "result"),
    }.items():
        for key in keys:
            require(key in data[table], f"{path}: missing {table}.{key}")
    require(run_id in data["report_root"], f"{path}: report_root must contain run_id")
    if data.get("dirty_tree"):
        require(bool(data.get("notes")), f"{path}: dirty_tree run requires notes")
    if data.get("verdict") == "retained":
        require(data.get("status") == "pass", f"{path}: retained run must pass")
        require(
            data["tool"].get("report_stage") == "fully_routed",
            f"{path}: retained run must be fully_routed",
        )


def validate_markdown_links() -> None:
    documents = [REPO_ROOT / "README.md", *sorted((REPO_ROOT / "docs").rglob("*.md"))]
    for path in documents:
        text = path.read_text(encoding="utf-8")
        for raw_target in MARKDOWN_LINK_RE.findall(text):
            target = raw_target.strip().strip("<>")
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            file_target = target.split("#", maxsplit=1)[0]
            if not file_target:
                continue
            require(not file_target.startswith("/"), f"{path}: absolute Markdown link {target}")
            require((path.parent / file_target).exists(), f"{path}: broken Markdown link {target}")


def main() -> None:
    required_files = (
        REPO_ROOT / "docs" / "experiments" / "index.md",
        REPO_ROOT / "docs" / "experiments" / "template.md",
        REPO_ROOT / "docs" / "design" / "vivado_baseline_registry.md",
        REPO_ROOT / "docs" / "project_workflow.md",
        REPO_ROOT / "docs" / "verification" / "validation_matrix.md",
        REPO_ROOT / "README.md",
        REPO_ROOT / "config" / "local.mk.example",
        MANIFEST_DIR / "README.md",
        MANIFEST_DIR / "template.toml.example",
    )
    for path in required_files:
        require(path.is_file(), f"missing project record file: {path}")
    history = (REPO_ROOT / "docs" / "design" / "optimization_exploration_history.md").read_text(
        encoding="utf-8"
    )
    require("归档状态" in history[:500], "legacy exploration history is not marked frozen")
    index = (REPO_ROOT / "docs" / "experiments" / "index.md").read_text(encoding="utf-8")
    next_match = re.search(r"下一个实验ID：`(EXP-\d{4})`", index)
    require(next_match is not None, "experiment index lacks next ID")
    experiment_ids = set(re.findall(r"^\| (EXP-\d{4}) \|", index, flags=re.MULTILINE))
    require(len(experiment_ids) == len(re.findall(r"^\| EXP-\d{4} \|", index, flags=re.MULTILINE)),
            "experiment index contains duplicate IDs")
    require(next_match.group(1) not in experiment_ids, "next experiment ID is already used")
    if experiment_ids:
        expected_next = f"EXP-{max(int(value.removeprefix('EXP-')) for value in experiment_ids) + 1:04d}"
        require(next_match.group(1) == expected_next, f"next experiment ID must be {expected_next}")
    agents = (REPO_ROOT / "AGENTS.md").read_bytes()
    claude = (REPO_ROOT / "CLAUDE.md").read_bytes()
    require(agents == claude, "AGENTS.md and CLAUDE.md differ")
    validate_markdown_links()
    seen_run_ids: set[str] = set()
    for path in sorted(MANIFEST_DIR.glob("RUN-*.toml")):
        validate_manifest(path, seen_run_ids, experiment_ids)
    print(f"Project records PASS ({len(seen_run_ids)} Vivado manifest(s))")


if __name__ == "__main__":
    main()
