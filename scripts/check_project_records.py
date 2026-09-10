#!/usr/bin/env python3
"""Validate project links and Vivado records."""

from __future__ import annotations

import re
import subprocess
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
FORMAL_AGGREGATES = ("formal-fast", "formal-nightly")
ROOT_DATA_SUFFIXES = {".csv", ".pdf", ".png", ".svg"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def validate_manifest(path: Path, seen_run_ids: set[str]) -> None:
    with path.open("rb") as stream:
        data = tomllib.load(stream)
    run_id = data.get("run_id", "")
    require(RUN_ID_RE.fullmatch(run_id) is not None, f"{path}: invalid run_id {run_id!r}")
    require(path.stem == run_id, f"{path}: filename must match run_id")
    require(run_id not in seen_run_ids, f"{path}: duplicate run_id {run_id}")
    seen_run_ids.add(run_id)
    if "experiment_id" in data:
        require(
            EXPERIMENT_ID_RE.fullmatch(data["experiment_id"]) is not None,
            f"{path}: invalid legacy experiment_id",
        )
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


def parse_make_targets(makefile: str) -> tuple[dict[str, list[str]], dict[str, str]]:
    dependencies: dict[str, list[str]] = {}
    recipes: dict[str, str] = {}
    current_targets: list[str] = []
    for line in makefile.splitlines():
        match = re.match(r"^([A-Za-z0-9_.-]+(?:\s+[A-Za-z0-9_.-]+)*):\s*(.*)$", line)
        if match:
            current_targets = match.group(1).split()
            target_dependencies = [
                token for token in match.group(2).split() if re.fullmatch(r"[A-Za-z0-9_.-]+", token)
            ]
            for target in current_targets:
                dependencies[target] = target_dependencies
                recipes.setdefault(target, "")
        elif line.startswith("\t"):
            for target in current_targets:
                recipes[target] = f"{recipes.get(target, '')}\n{line}"
        elif line and not line[0].isspace():
            current_targets = []
    return dependencies, recipes


def dependency_closure(root: str, dependencies: dict[str, list[str]]) -> set[str]:
    reachable: set[str] = set()
    pending = [root]
    while pending:
        target = pending.pop()
        if target in reachable:
            continue
        reachable.add(target)
        pending.extend(dependencies.get(target, []))
    return reachable


def validate_formal_registration() -> None:
    makefile = (REPO_ROOT / "Makefile").read_text(encoding="utf-8")
    dependencies, recipes = parse_make_targets(makefile)
    aggregate_targets: set[str] = set()
    for aggregate in FORMAL_AGGREGATES:
        require(aggregate in dependencies, f"Makefile: missing {aggregate} aggregate")
        aggregate_targets |= dependency_closure(aggregate, dependencies)
    for path in sorted((REPO_ROOT / "formal").glob("*.sby")):
        relative = path.relative_to(REPO_ROOT).as_posix()
        owners = {target for target, recipe in recipes.items() if relative in recipe}
        require(owners, f"{path}: no Make target invokes this proof")
        require(
            bool(owners & aggregate_targets),
            f"{path}: owning target is not registered in formal-fast or formal-nightly",
        )


def validate_root_artifacts() -> None:
    misplaced = sorted(
        path.name
        for path in REPO_ROOT.iterdir()
        if path.is_file()
        and path.suffix.lower() in ROOT_DATA_SUFFIXES
        and subprocess.run(
            ["git", "check-ignore", "-q", path.name], cwd=REPO_ROOT, check=False
        ).returncode
        != 0
    )
    require(not misplaced, f"root data/figure artifacts must move under docs/figures or reports: {misplaced}")


def main() -> None:
    required_files = (
        REPO_ROOT / "docs" / "experiments.md",
        REPO_ROOT / "docs" / "design" / "vivado_baseline_registry.md",
        REPO_ROOT / "docs" / "design" / "coding.md",
        REPO_ROOT / "docs" / "workflow.md",
        REPO_ROOT / "README.md",
        REPO_ROOT / "pyproject.toml",
        REPO_ROOT / "uv.lock",
        REPO_ROOT / "config" / "local.mk.example",
        MANIFEST_DIR / "README.md",
        MANIFEST_DIR / "template.toml.example",
    )
    for path in required_files:
        require(path.is_file(), f"missing project record file: {path}")
    validate_root_artifacts()
    agents = (REPO_ROOT / "AGENTS.md").read_bytes()
    claude = (REPO_ROOT / "CLAUDE.md").read_bytes()
    require(agents == claude, "AGENTS.md and CLAUDE.md differ")
    validate_markdown_links()
    validate_formal_registration()
    seen_run_ids: set[str] = set()
    for path in sorted(MANIFEST_DIR.glob("RUN-*.toml")):
        validate_manifest(path, seen_run_ids)
    print(f"Project records PASS ({len(seen_run_ids)} Vivado manifest(s))")


if __name__ == "__main__":
    main()
