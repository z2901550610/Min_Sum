#!/usr/bin/env python3
"""Render or verify the generated profile table in validation_matrix.md."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from validation_profiles import (
    DEFAULT_CONFIG_PATH,
    load_profiles,
    render_profile_table,
    repository_binding_errors,
)


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DOCUMENT_PATH = REPO_ROOT / "docs" / "verification" / "validation_matrix.md"
BEGIN_MARKER = "<!-- BEGIN GENERATED VALIDATION PROFILES -->"
END_MARKER = "<!-- END GENERATED VALIDATION PROFILES -->"


def render_document(document: str, table: str) -> str:
    if document.count(BEGIN_MARKER) != 1 or document.count(END_MARKER) != 1:
        raise ValueError("validation matrix needs exactly one generated-profile marker pair")
    before, remainder = document.split(BEGIN_MARKER, 1)
    _, after = remainder.split(END_MARKER, 1)
    return f"{before}{BEGIN_MARKER}\n{table}\n{END_MARKER}{after}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="fail if the document drifts")
    mode.add_argument("--write", action="store_true", help="update the generated table")
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG_PATH)
    parser.add_argument("--document", type=Path, default=DEFAULT_DOCUMENT_PATH)
    arguments = parser.parse_args()

    try:
        current = arguments.document.read_text(encoding="utf-8")
        config = load_profiles(arguments.config)
        binding_errors = repository_binding_errors(config)
        if binding_errors:
            raise ValueError("; ".join(binding_errors))
        expected = render_document(current, render_profile_table(config))
    except (OSError, ValueError) as error:
        print(f"validation profile check FAIL: {error}", file=sys.stderr)
        return 1
    if arguments.check:
        if current != expected:
            print(
                "validation profile check FAIL: generated table is stale; "
                "run make update-validation-matrix",
                file=sys.stderr,
            )
            return 1
        print("Validation profile matrix PASS")
        return 0
    arguments.document.write_text(expected, encoding="utf-8")
    print(f"Updated {arguments.document}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
