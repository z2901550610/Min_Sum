#!/usr/bin/env python3
"""Produce a read-only validation plan from the current repository diff."""

from __future__ import annotations

import argparse
import json
import shlex
import subprocess
from datetime import UTC, datetime
from pathlib import Path

from validation_profiles import (
    ValidationProfiles,
    classify_paths,
    covered_profiles,
    load_profiles,
)


REPO_ROOT = Path(__file__).resolve().parents[1]
CONFIG = load_profiles()


def changed_paths() -> list[str]:
    tracked = subprocess.run(
        ["git", "diff", "--name-only", "--diff-filter=ACMRD", "HEAD", "--"],
        cwd=REPO_ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    ).stdout.splitlines()
    untracked = subprocess.run(
        ["git", "ls-files", "--others", "--exclude-standard"],
        cwd=REPO_ROOT,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    ).stdout.splitlines()
    return sorted(set(tracked + untracked))


def build_plan(
    paths: list[str],
    config: ValidationProfiles = CONFIG,
    *,
    scope_diff: bool = True,
) -> dict[str, object]:
    selected_profiles: set[str] = set()
    fallback_profiles: set[str] = set()
    owner_targets: list[str] = []
    unrouted: list[str] = []
    for path in paths:
        profiles, owners = classify_paths([path], config)
        selected_profiles.update(profiles)
        if not profiles and not owners:
            unrouted.append(path)
        handled = {profile for owner in owners for profile in owner.covers_profiles}
        # Coverage is local to this file. A proof for another file cannot replace
        # this file's test merely because both have the same profile label.
        candidates = {
            profile for profile in profiles
            if profile not in handled and config.profiles[profile].targets
        }
        fallback_profiles.update(candidates - covered_profiles(list(candidates), config))
        for owner in owners:
            owner_targets.extend(owner.targets)
    profile_ids = [p for p in config.profile_order if p in selected_profiles]
    targets = [target for p in config.profile_order if p in fallback_profiles
               for target in config.profiles[p].targets]
    targets = list(dict.fromkeys([*targets, *owner_targets]))
    commands: list[str] = []
    if paths:
        diff_command = "git diff --check"
        if scope_diff:
            diff_command += " -- " + " ".join(shlex.quote(path) for path in paths)
        commands.append(diff_command)
    if targets:
        commands.append("make " + " ".join(targets))
    return {
        "schema_version": 5,
        "generated_at": datetime.now(UTC).isoformat(),
        "read_only": True,
        "changed_paths": paths,
        "unrouted_paths": unrouted,
        "profiles": [
            {
                "id": profile_id,
                "description": config.profiles[profile_id].description,
            }
            for profile_id in profile_ids
        ],
        "commands": commands,
        "targets": targets,
        "guidance": "docs/workflow.md",
        "note": "Suggested focused checks only; select additional checks for changed behavior, not as a closing ritual.",
    }


def print_human(plan: dict[str, object]) -> None:
    paths = plan["changed_paths"]
    if not paths:
        print("Validation plan: no tracked or untracked changes")
        return
    print(f"Validation plan: {len(paths)} changed path(s)")
    print("Profiles:")
    for profile in plan["profiles"]:
        print(f"  - {profile['id']}: {profile['description']}")
    if plan["unrouted_paths"]:
        print("Unrouted research files (choose task-appropriate checks; registration optional):")
        for path in plan["unrouted_paths"]:
            print(f"  - {path}")
    print("Commands:")
    for command in plan["commands"]:
        print(f"  {command}")
    print(f"Behavior-dependent checks: see {plan['guidance']}")
    print("NOT_RUN: this command only planned validation; it did not execute any gate.")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument("--paths", nargs="*", help="plan explicit paths instead of the Git diff")
    arguments = parser.parse_args()
    paths = sorted(set(arguments.paths)) if arguments.paths is not None else changed_paths()
    plan = build_plan(paths, scope_diff=arguments.paths is not None)
    if arguments.json:
        print(json.dumps(plan, indent=2, sort_keys=True))
    else:
        print_human(plan)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
