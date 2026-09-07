"""Shared command execution, atomic log allocation and compact diagnostics."""
from __future__ import annotations

import os
import re
import subprocess
import tempfile
import time
from pathlib import Path


def new_log(directory: Path, name: str) -> Path:
    directory.mkdir(parents=True, exist_ok=True)
    name = re.sub(r'[^A-Za-z0-9_.-]+', '_', name)
    descriptor, path = tempfile.mkstemp(
        prefix=f'{time.strftime("%Y%m%d-%H%M%S")}-{name}-', suffix='.log', dir=directory
    )
    os.close(descriptor)
    return Path(path)


def run_command(command: list[str], *, env=None, cwd=None) -> tuple[int, str, float]:
    start = time.monotonic()
    try:
        result = subprocess.run(command, env=env, cwd=cwd, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
        returncode, output = result.returncode, result.stdout or ''
    except FileNotFoundError:
        returncode, output = 127, f'executable not found: {command[0]}\n'
    duration = time.monotonic() - start
    return returncode, output, duration


def run_logged(command: list[str], log: Path, *, env=None, cwd=None) -> tuple[int, str, float]:
    result = run_command(command, env=env, cwd=cwd)
    log.write_text(result[1], encoding='utf-8', errors='replace')
    return result


def diagnostic_lines(output: str, pattern: re.Pattern, *, failed: bool,
                     limit: int = 20) -> list[str]:
    lines = output.splitlines()
    important = [line for line in lines if pattern.search(line)]
    return list(dict.fromkeys(important[:limit] + (lines[-20:] if failed else [])))
