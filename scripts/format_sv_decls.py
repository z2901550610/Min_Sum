#!/usr/bin/env python3
"""Project-local SystemVerilog declaration cleanup after Verible formatting."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


DECL_START_RE = re.compile(
    r"^\s*(?:\(\*.*?\*\)\s*)?"
    r"(?:(?:input|output|inout)\s+)?"
    r"(?:logic|wire|reg|integer)\b"
)
UNPACKED_GAP_RE = re.compile(
    r"(?P<name>\b[A-Za-z_][A-Za-z0-9_$]*)(?P<gap>[ \t]+)"
    r"(?P<dims>(?:\[[^\]\n]+\][ \t]*)+)(?=\s*(?:[,;]|//|$))"
)


def cleanup_text(text: str) -> str:
    text = text.replace("*)logic", "*) logic")
    text = re.sub(r"\binput logic\b", "input  logic", text)

    lines = []
    for line in text.splitlines(keepends=True):
        if DECL_START_RE.match(line):
            line = UNPACKED_GAP_RE.sub(
                lambda match: match.group("name") + re.sub(r"\]\s+\[", "][", match.group("dims").rstrip()),
                line,
            )
        lines.append(line)
    return "".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="report files that need cleanup")
    parser.add_argument("files", nargs="+", type=Path)
    args = parser.parse_args()

    failed = False
    for path in args.files:
        original = path.read_text()
        cleaned = cleanup_text(original)
        if cleaned != original:
            if args.check:
                print(f"{path}: declaration cleanup needed")
                failed = True
            else:
                path.write_text(cleaned)

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
