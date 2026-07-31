#!/usr/bin/env python3
"""Build the supplied TRIKE reference code and verify its official KAT files."""

from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path
import shlex
import subprocess
import sys


PARAMETER_SETS = ("TRIKE-2", "TRIKE-5", "TRIKE-7", "TRIKE-9")


def normalized_bytes(path: Path) -> bytes:
    return path.read_bytes().replace(b"\r\n", b"\n")


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def run(
    command: list[str], *, cwd: Path | None = None, quiet: bool = False
) -> None:
    subprocess.run(
        command,
        cwd=cwd,
        check=True,
        stdout=subprocess.DEVNULL if quiet else None,
    )


def compile_kat(
    source_dir: Path,
    executable: Path,
    compiler: str,
    cflags: list[str],
) -> None:
    sources = sorted((source_dir / "ICCS").glob("*.c"))
    sources += sorted((source_dir / "src").glob("*.c"))
    sources.append(source_dir / "tests" / "KAT_KEM.c")
    missing = [path for path in sources if not path.is_file()]
    if missing:
        raise FileNotFoundError(f"missing TRIKE reference source: {missing[0]}")

    executable.parent.mkdir(parents=True, exist_ok=True)
    command = [
        compiler,
        *cflags,
        f"-I{source_dir / 'ICCS'}",
        f"-I{source_dir / 'src'}",
        *(str(path) for path in sources),
        "-lm",
        "-o",
        str(executable),
    ]
    run(command)


def verify_parameter_set(
    reference_root: Path,
    vector_root: Path,
    build_root: Path,
    parameter_set: str,
    compiler: str,
    cflags: list[str],
) -> None:
    source_dir = reference_root / parameter_set
    parameter_build = build_root / parameter_set.lower()
    executable = parameter_build / "kat_kem"
    generated = parameter_build / "output" / f"KAT_KEM_{parameter_set}.txt"
    expected = vector_root / f"KAT_KEM_{parameter_set}.txt"

    if not source_dir.is_dir():
        raise FileNotFoundError(f"missing reference directory: {source_dir}")
    if not expected.is_file():
        raise FileNotFoundError(f"missing official KAT: {expected}")

    compile_kat(source_dir, executable, compiler, cflags)
    run([str(executable)], cwd=parameter_build, quiet=True)

    generated_data = normalized_bytes(generated)
    expected_data = normalized_bytes(expected)
    if generated_data != expected_data:
        raise RuntimeError(
            f"{parameter_set} KAT mismatch: "
            f"generated={sha256_hex(generated_data)} "
            f"expected={sha256_hex(expected_data)}"
        )

    print(
        f"{parameter_set} reference KAT PASS "
        f"bytes={len(expected_data)} sha256={sha256_hex(expected_data)}"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source-root",
        type=Path,
        required=True,
        help="TRIKE代码和测试向量 directory",
    )
    parser.add_argument(
        "--build-root",
        type=Path,
        default=Path("build/software/trike_reference"),
    )
    parser.add_argument(
        "--parameter-sets",
        nargs="+",
        choices=PARAMETER_SETS,
        default=list(PARAMETER_SETS),
    )
    parser.add_argument("--cc", default=os.environ.get("CC", "cc"))
    parser.add_argument(
        "--cflags",
        default="-O3 -std=c11",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source_root = args.source_root.resolve()
    reference_root = (
        source_root / "Implementations" / "Reference_Implementation"
    )
    vector_root = source_root / "Test_Vectors"
    build_root = args.build_root.resolve()
    cflags = shlex.split(args.cflags)

    try:
        for parameter_set in args.parameter_sets:
            verify_parameter_set(
                reference_root,
                vector_root,
                build_root,
                parameter_set,
                args.cc,
                cflags,
            )
    except (FileNotFoundError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f"TRIKE reference KAT ERROR: {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
