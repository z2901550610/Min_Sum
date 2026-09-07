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
    OwnerAction,
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


def retained_owner_actions(
    profile_ids: list[str],
    required_aggregate_profiles: set[str],
    actions: list[OwnerAction],
    config: ValidationProfiles,
) -> list[OwnerAction]:
    """Drop owner targets already subsumed by a selected aggregate profile."""
    selected = set(profile_ids)
    aggregate_handled = required_aggregate_profiles | covered_profiles(
        sorted(required_aggregate_profiles), config
    )
    retained = [
        action
        for action in actions
        if not (set(action.covers_profiles) & selected).issubset(aggregate_handled)
    ]
    return [
        action
        for action in retained
        if not any(
            (set(action.covers_profiles) & selected)
            < (set(other.covers_profiles) & selected)
            for other in retained
        )
    ]


def build_plan(
    paths: list[str],
    config: ValidationProfiles = CONFIG,
    *,
    scope_diff: bool = True,
) -> dict[str, object]:
    profile_ids, owner_actions, routed_manual = classify_paths(paths, config)
    required_aggregate_profiles: set[str] = set()
    for path in paths:
        path_profiles, path_actions, _ = classify_paths([path], config)
        for profile_id in path_profiles:
            if not any(
                profile_id in action.covers_profiles for action in path_actions
            ):
                required_aggregate_profiles.add(profile_id)
    owner_actions = retained_owner_actions(
        profile_ids, required_aggregate_profiles, owner_actions, config
    )
    covered = covered_profiles(sorted(required_aggregate_profiles), config)
    targets: list[str] = []
    iteration_targets: list[str] = []
    manual: list[str] = routed_manual
    for profile_id in profile_ids:
        profile = config.profiles[profile_id]
        manual.extend(profile.manual_requirements)
        if profile_id not in required_aggregate_profiles or profile_id in covered:
            continue
        iteration_targets.extend(profile.iteration_targets)
        targets.extend(profile.targets)
    for action in owner_actions:
        targets.extend(action.targets)
    targets = list(dict.fromkeys(targets))
    release_covered = covered_profiles(profile_ids, config)
    release_targets: list[str] = []
    for profile_id in profile_ids:
        if profile_id in release_covered:
            continue
        release_targets.extend(config.profiles[profile_id].release_targets)
    release_targets = [
        target
        for target in dict.fromkeys(release_targets)
        if target not in targets
    ]
    iteration_targets = [
        target
        for target in dict.fromkeys(iteration_targets)
        if target not in targets
    ]
    manual = list(dict.fromkeys(manual))
    commands: list[str] = []
    if paths:
        diff_command = "git diff --check"
        if scope_diff:
            diff_command += " -- " + " ".join(shlex.quote(path) for path in paths)
        commands.append(diff_command)
    if targets:
        commands.append("make " + " ".join(targets))
    release_commands = (
        ["make " + " ".join(release_targets)] if release_targets else []
    )
    iteration_commands = (
        ["make " + " ".join(iteration_targets)] if iteration_targets else []
    )
    return {
        "schema_version": 3,
        "generated_at": datetime.now(UTC).isoformat(),
        "read_only": True,
        "changed_paths": paths,
        "profiles": [
            {
                "id": profile_id,
                "description": config.profiles[profile_id].description,
            }
            for profile_id in profile_ids
        ],
        "commands": commands,
        "targets": targets,
        "release_commands": release_commands,
        "release_targets": release_targets,
        "optional_iteration_commands": iteration_commands,
        "optional_iteration_targets": iteration_targets,
        "manual_requirements": manual,
        "note": "This is a conservative plan, not evidence that any command passed.",
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
    print("Commands:")
    for command in plan["commands"]:
        print(f"  {command}")
    if plan["release_commands"]:
        print("Release/shared-scope escalation commands:")
        for command in plan["release_commands"]:
            print(f"  {command}")
    if plan["optional_iteration_commands"]:
        print("Optional iteration commands:")
        for command in plan["optional_iteration_commands"]:
            print(f"  {command}")
    if plan["manual_requirements"]:
        print("Manual requirements:")
        for requirement in plan["manual_requirements"]:
            print(f"  - {requirement}")
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
