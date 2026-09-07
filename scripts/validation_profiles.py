#!/usr/bin/env python3
"""Load and apply the repository validation-profile configuration."""

from __future__ import annotations

import re
import subprocess
import tomllib
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from test_catalog import CATALOG_PATH, load_catalog, owners as catalog_owners


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG_PATH = REPO_ROOT / "config" / "validation_profiles.toml"
MATCH_KEYS = ("exact", "prefixes", "suffixes", "contains")
MAKE_TARGET_RE = re.compile(r"^([^\s:#=][^:#=]*?)\s*::?(?:\s|$)")


class ProfileConfigError(ValueError):
    """Raised when validation_profiles.toml violates its schema."""


@dataclass(frozen=True)
class Profile:
    profile_id: str
    description: str
    targets: tuple[str, ...]
    release_targets: tuple[str, ...]
    iteration_targets: tuple[str, ...]
    manual_requirements: tuple[str, ...]
    covers: tuple[str, ...]
    scope: str
    minimum_gate: str
    boundary: str


@dataclass(frozen=True)
class ValidationProfiles:
    profiles: dict[str, Profile]
    profile_order: tuple[str, ...]
    routing: tuple[dict[str, Any], ...]
    manual_rules: tuple[dict[str, Any], ...]
    owners: tuple[dict[str, Any], ...]


@dataclass(frozen=True)
class OwnerAction:
    targets: tuple[str, ...]
    covers_profiles: tuple[str, ...]


def _string_list(value: object, context: str) -> tuple[str, ...]:
    if not isinstance(value, list) or any(
        not isinstance(item, str) or not item for item in value
    ):
        raise ProfileConfigError(f"{context} must be a list of non-empty strings")
    return tuple(value)


def _required_string(table: dict[str, Any], key: str, context: str) -> str:
    value = table.get(key)
    if not isinstance(value, str) or not value:
        raise ProfileConfigError(f"{context}.{key} must be a non-empty string")
    return value


def _validate_rule(rule: object, context: str, profile_ids: set[str]) -> dict[str, Any]:
    if not isinstance(rule, dict):
        raise ProfileConfigError(f"{context} must be a table")
    normalized: dict[str, Any] = {}
    if "profile" in rule:
        profile_id = rule["profile"]
        if profile_id not in profile_ids:
            raise ProfileConfigError(f"{context}.profile names unknown profile {profile_id!r}")
        normalized["profile"] = profile_id
    if "requirement" in rule:
        normalized["requirement"] = _required_string(rule, "requirement", context)
    for key in (*MATCH_KEYS, "within_prefixes"):
        if key in rule:
            normalized[key] = _string_list(rule[key], f"{context}.{key}")
    if not any(key in normalized for key in MATCH_KEYS):
        raise ProfileConfigError(f"{context} needs at least one path matcher")
    if "within_prefixes" in normalized and "contains" not in normalized:
        raise ProfileConfigError(f"{context}.within_prefixes requires contains")
    return normalized


def load_profiles(path: Path = DEFAULT_CONFIG_PATH, *, catalog_path: Path = CATALOG_PATH) -> ValidationProfiles:
    try:
        with path.open("rb") as profile_file:
            data = tomllib.load(profile_file)
    except (OSError, tomllib.TOMLDecodeError) as error:
        raise ProfileConfigError(f"cannot load {path}: {error}") from error

    if data.get("schema_version") != 3:
        raise ProfileConfigError("schema_version must be 3")
    raw_profiles = data.get("profiles")
    if not isinstance(raw_profiles, dict) or not raw_profiles:
        raise ProfileConfigError("profiles must be a non-empty table")
    order = _string_list(data.get("profile_order"), "profile_order")
    if len(order) != len(set(order)) or set(order) != set(raw_profiles):
        raise ProfileConfigError("profile_order must name every profile exactly once")

    profiles: dict[str, Profile] = {}
    for profile_id in order:
        raw = raw_profiles[profile_id]
        context = f"profiles.{profile_id}"
        if not isinstance(raw, dict):
            raise ProfileConfigError(f"{context} must be a table")
        profiles[profile_id] = Profile(
            profile_id=profile_id,
            description=_required_string(raw, "description", context),
            targets=_string_list(raw.get("targets"), f"{context}.targets"),
            release_targets=_string_list(
                raw.get("release_targets"), f"{context}.release_targets"
            ),
            iteration_targets=_string_list(
                raw.get("iteration_targets"), f"{context}.iteration_targets"
            ),
            manual_requirements=_string_list(
                raw.get("manual_requirements"), f"{context}.manual_requirements"
            ),
            covers=_string_list(raw.get("covers"), f"{context}.covers"),
            scope=_required_string(raw, "scope", context),
            minimum_gate=_required_string(raw, "minimum_gate", context),
            boundary=_required_string(raw, "boundary", context),
        )

    profile_ids = set(profiles)
    for profile in profiles.values():
        unknown = set(profile.covers) - profile_ids
        if unknown:
            raise ProfileConfigError(
                f"profiles.{profile.profile_id}.covers names unknown profiles: {sorted(unknown)}"
            )
        if profile.profile_id in profile.covers:
            raise ProfileConfigError(f"profiles.{profile.profile_id} cannot cover itself")
    for start_id in profiles:
        pending = list(profiles[start_id].covers)
        visited: set[str] = set()
        while pending:
            profile_id = pending.pop()
            if profile_id == start_id:
                raise ProfileConfigError(
                    f"profile coverage contains a cycle through {start_id!r}"
                )
            if profile_id not in visited:
                visited.add(profile_id)
                pending.extend(profiles[profile_id].covers)

    raw_routing = data.get("routing")
    if not isinstance(raw_routing, list) or not raw_routing:
        raise ProfileConfigError("routing must be a non-empty array of tables")
    routing = tuple(
        _validate_rule(rule, f"routing[{index}]", profile_ids)
        for index, rule in enumerate(raw_routing)
    )
    if any("profile" not in rule for rule in routing):
        raise ProfileConfigError("every routing rule needs a profile")
    routed_profiles = {rule["profile"] for rule in routing}
    if routed_profiles != profile_ids:
        missing = sorted(profile_ids - routed_profiles)
        raise ProfileConfigError(f"profiles without path routing: {missing}")

    raw_manual_rules = data.get("manual_rules", [])
    if not isinstance(raw_manual_rules, list):
        raise ProfileConfigError("manual_rules must be an array of tables")
    manual_rules = tuple(
        _validate_rule(rule, f"manual_rules[{index}]", profile_ids)
        for index, rule in enumerate(raw_manual_rules)
    )
    if any("requirement" not in rule for rule in manual_rules):
        raise ProfileConfigError("every manual rule needs a requirement")

    raw_owners = data.get("owners", [])
    if not isinstance(raw_owners, list):
        raise ProfileConfigError("owners must be an array of tables")
    raw_owners = raw_owners + catalog_owners(load_catalog(catalog_path))
    owners: list[dict[str, Any]] = []
    for index, raw_rule in enumerate(raw_owners):
        context = f"owners[{index}]"
        rule = _validate_rule(raw_rule, context, profile_ids)
        targets = _string_list(raw_rule.get("targets"), f"{context}.targets")
        covers_profiles = _string_list(
            raw_rule.get("covers_profiles"), f"{context}.covers_profiles"
        )
        if not targets or not covers_profiles:
            raise ProfileConfigError(
                f"{context} needs non-empty targets and covers_profiles"
            )
        unknown = set(covers_profiles) - profile_ids
        if unknown:
            raise ProfileConfigError(
                f"{context}.covers_profiles names unknown profiles: {sorted(unknown)}"
            )
        rule["targets"] = targets
        rule["covers_profiles"] = covers_profiles
        owners.append(rule)

    return ValidationProfiles(
        profiles=profiles,
        profile_order=order,
        routing=routing,
        manual_rules=manual_rules,
        owners=tuple(owners),
    )


def path_matches(path: str, rule: dict[str, Any]) -> bool:
    within = rule.get("within_prefixes")
    if within and not path.startswith(within):
        return False
    return (
        path in rule.get("exact", ())
        or path.startswith(rule.get("prefixes", ()))
        or path.endswith(rule.get("suffixes", ()))
        or any(token in path for token in rule.get("contains", ()))
    )


def classify_paths(
    paths: list[str], config: ValidationProfiles
) -> tuple[list[str], list[OwnerAction], list[str]]:
    selected = {
        rule["profile"]
        for rule in config.routing
        if any(path_matches(path, rule) for path in paths)
    }
    owner_actions = [
        OwnerAction(
            targets=rule["targets"],
            covers_profiles=rule["covers_profiles"],
        )
        for rule in config.owners
        if any(path_matches(path, rule) for path in paths)
    ]
    manual = {
        rule["requirement"]
        for rule in config.manual_rules
        if any(path_matches(path, rule) for path in paths)
    }
    ordered = [profile_id for profile_id in config.profile_order if profile_id in selected]
    return ordered, owner_actions, sorted(manual)


def covered_profiles(selected: list[str], config: ValidationProfiles) -> set[str]:
    covered: set[str] = set()
    pending = list(selected)
    while pending:
        profile_id = pending.pop()
        for covered_id in config.profiles[profile_id].covers:
            if covered_id not in covered:
                covered.add(covered_id)
                pending.append(covered_id)
    return covered


def render_profile_table(config: ValidationProfiles) -> str:
    lines = [
        "| 改动范围 | 最小必跑 | 附加边界 |",
        "| --- | --- | --- |",
    ]
    for profile_id in config.profile_order:
        profile = config.profiles[profile_id]
        lines.append(
            f"| {profile.scope} | {profile.minimum_gate} | {profile.boundary} |"
        )
    return "\n".join(lines)


def repository_paths(repo_root: Path = REPO_ROOT) -> list[str]:
    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard"],
        cwd=repo_root,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return sorted(set(result.stdout.splitlines()))


def makefile_targets(makefile: Path) -> set[str]:
    targets: set[str] = set()
    for line in makefile.read_text(encoding="utf-8").splitlines():
        if not line or line[0].isspace() or ":=" in line or "?=" in line:
            continue
        match = MAKE_TARGET_RE.match(line)
        if match:
            targets.update(match.group(1).split())
    return targets


def configured_targets(config: ValidationProfiles) -> list[str]:
    targets: list[str] = []
    for profile in config.profiles.values():
        targets.extend(profile.targets)
        targets.extend(profile.release_targets)
        targets.extend(profile.iteration_targets)
    for rule in config.owners:
        targets.extend(rule["targets"])
    return list(dict.fromkeys(targets))


def repository_binding_errors(
    config: ValidationProfiles, repo_root: Path = REPO_ROOT
) -> list[str]:
    paths = repository_paths(repo_root)
    errors: list[str] = []
    for category, rules in (
        ("routing", config.routing),
        ("owners", config.owners),
        ("manual_rules", config.manual_rules),
    ):
        for index, rule in enumerate(rules):
            if not any(path_matches(path, rule) for path in paths):
                errors.append(f"{category}[{index}] matches no repository path")
    for path in paths:
        if path.startswith(("rtl/", "tb/", "formal/", "filelists/")) and not any(
            path_matches(path, rule) for rule in config.routing
        ):
            errors.append(f"core source has no validation profile: {path}")
        matched_owners = [rule for rule in config.owners if path_matches(path, rule)]
        if path.startswith(("rtl/", "tb/", "formal/")) and path.endswith(
            (".sv", ".sby")
        ):
            if len(matched_owners) > 1:
                errors.append(f"hardware source has multiple validation owners: {path}")
        selected_profiles = {
            rule["profile"] for rule in config.routing if path_matches(path, rule)
        }
        for owner in matched_owners:
            if not (set(owner["covers_profiles"]) & selected_profiles):
                errors.append(
                    f"validation owner covers no routed profile for {path}: "
                    f"{list(owner['covers_profiles'])}"
                )
    known_targets = makefile_targets(repo_root / "Makefile") | {test["name"] for test in load_catalog()}
    for target in configured_targets(config):
        if target not in known_targets:
            errors.append(f"configured owner names unknown Make target {target!r}")
    return errors
