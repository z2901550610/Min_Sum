#!/usr/bin/env python3
"""Read the canonical test catalog and render its native Make rules."""
from __future__ import annotations

import argparse
import re
import tomllib
from pathlib import Path

CATALOG_PATH = Path(__file__).resolve().parents[1] / 'config/test_catalog.toml'


def load_catalog(path: Path = CATALOG_PATH) -> list[dict]:
    with path.open('rb') as stream:
        data = tomllib.load(stream)
    if data.get('schema_version') != 1:
        raise ValueError('unsupported test catalog schema')
    tests = data['tests']
    names = [test['name'] for test in tests]
    if len(set(names)) != len(names) or any(not re.fullmatch(r'test(?:-[\w-]+)?', n) for n in names):
        raise ValueError('test target names must be unique Make identifiers')
    return tests


def owners(tests: list[dict]) -> list[dict]:
    return [
        {**{k: v for k, v in owner.items() if k != 'also_targets'},
         'targets': [test['name'], *owner.get('also_targets', [])]}
        for test in tests for owner in test.get('owners', [])
    ]


def render_make(tests: list[dict]) -> str:
    groups: dict[str, list[str]] = {}
    for test in tests:
        for group in test.get('groups', []):
            groups.setdefault(group, []).append(test['name'])
    lines = ['# Generated from config/test_catalog.toml; do not edit.']
    lines += [f'{group} := {" ".join(names)}' for group, names in groups.items()]
    lines += ['.PHONY: ' + ' '.join(test['name'] for test in tests)]
    for test in tests:
        lines += ['', f'{test["name"]}: {test.get("prerequisites", "")}']
        lines += ['\t' + command for command in test.get('commands', [])]
    return '\n'.join(lines) + '\n'


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--makefile', type=Path, required=True)
    args = parser.parse_args()
    rendered = render_make(load_catalog())
    args.makefile.parent.mkdir(parents=True, exist_ok=True)
    args.makefile.write_text(rendered, encoding='utf-8')


if __name__ == '__main__':
    main()
