#!/usr/bin/env python3
"""Print or verify the repository's validated RTL toolchain versions."""

from __future__ import annotations

import argparse
import os
import subprocess
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
LOCK_PATH = REPO_ROOT / "config" / "rtl_toolchain.lock"
COMMANDS = {
    "verilator": [os.environ.get("REAL_VERILATOR", "verilator"), "--version"],
    "verible": ["verible-verilog-lint", "--version"],
    "slang": ["slang", "--version"],
    "yosys": ["yosys", "-V"],
    "sby": ["sby", "--version"],
    "z3": ["z3", "--version"],
    "boolector": ["boolector", "--version"],
    "bitwuzla": ["bitwuzla", "--version"],
    "cocotb": ["cocotb-config", "--version"],
    "surfer": ["surfer", "--version"],
    "python": ["python3", "--version"],
}


def load_lock() -> dict[str, str]:
    versions = {}
    for raw_line in LOCK_PATH.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        name, expected = line.split("=", maxsplit=1)
        versions[name] = expected.replace("\\t", "\t")
    return versions


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected_versions = load_lock()
    failed = False
    for name, expected in expected_versions.items():
        command = COMMANDS.get(name)
        if command is None:
            print(f"{name:10} UNKNOWN  no version command registered")
            failed = True
            continue
        try:
            result = subprocess.run(command, text=True, capture_output=True, check=False)
        except FileNotFoundError:
            print(f"{name:10} MISSING  executable not found")
            failed = True
            continue
        output = (result.stdout + result.stderr).strip()
        first_line = output.splitlines()[0] if output else "<no output>"
        status = "PASS" if result.returncode == 0 and expected in output else "MISMATCH"
        print(f"{name:10} {status:8} {first_line}")
        failed |= status != "PASS"
    if args.check and failed:
        raise SystemExit("RTL toolchain differs from config/rtl_toolchain.lock")


if __name__ == "__main__":
    main()
