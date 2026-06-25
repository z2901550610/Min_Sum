#!/usr/bin/env python3
"""Generate one shared fixture and compare C-model and RTL decisions."""

from __future__ import annotations

import argparse
import subprocess
import tempfile
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compare C-model and RTL min-sum decisions.")
    parser.add_argument("--model", default="build/model/min_sum_model")
    parser.add_argument("--seed", type=int, default=2)
    parser.add_argument("--r", type=int, default=8)
    parser.add_argument("--w", type=int, default=3)
    parser.add_argument("--errors", type=int, default=1)
    parser.add_argument("--iterations", type=int, default=4)
    parser.add_argument("--msg-bits", type=int, default=5)
    parser.add_argument("--c-val", type=int, default=2)
    parser.add_argument("--alpha-shift-0", type=int, default=1)
    parser.add_argument("--alpha-shift-1", type=int, default=3)
    parser.add_argument("--parallel-l", type=int, default=8)
    parser.add_argument("--c-tile", type=int, default=8)
    parser.add_argument("--verilator", default="./scripts/verilator_quiet.py")
    parser.add_argument("--keep-dir", default=None)
    return parser.parse_args()


def read_decision(path: Path) -> list[int]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "MIN_SUM_DECISION_V1":
        raise RuntimeError(f"{path}: invalid decision header")
    return [int(line) for line in lines[1:] if line]


def run(command: list[str], cwd: Path) -> None:
    subprocess.run(command, cwd=cwd, check=True)


def execute(args: argparse.Namespace, work_dir: Path, repo_root: Path) -> None:
    fixture = work_dir / "case.fixture"
    c_decision = work_dir / "c.decision"
    rtl_decision = work_dir / "rtl.decision"
    rtl_out = work_dir / "rtl_case"

    common = [
        "--n0",
        "2",
        "--r",
        str(args.r),
        "--w",
        str(args.w),
        "--error-count",
        str(args.errors),
        "--i-max",
        str(args.iterations),
        "--msg-bits",
        str(args.msg_bits),
        "--c-val",
        str(args.c_val),
        "--alpha-shift-0",
        str(args.alpha_shift_0),
        "--alpha-shift-1",
        str(args.alpha_shift_1),
        "--parallel-l",
        str(args.parallel_l),
        "--c-tile",
        str(args.c_tile),
    ]
    run(
        [
            "python3",
            "scripts/run_bike_random.py",
            "--base-seed",
            str(args.seed),
            "--trials",
            "1",
            "--fixture-out",
            str(fixture),
            "--generate-only",
            "--out-dir",
            str(rtl_out),
            *common,
        ],
        repo_root,
    )
    run(
        [
            "python3",
            "scripts/run_bike_random.py",
            "--trials",
            "1",
            "--fixture-in",
            str(fixture),
            "--result-out",
            str(rtl_decision),
            "--allow-decode-failure",
            "--out-dir",
            str(rtl_out),
            "--timeout-cycles",
            "5000000",
            "--verilator",
            args.verilator,
            "--parallel-l",
            str(args.parallel_l),
            "--c-tile",
            str(args.c_tile),
        ],
        repo_root,
    )
    run(
        [
            str(Path(args.model).resolve()),
            "--fixture-in",
            str(fixture),
            "--decision-out",
            str(c_decision),
        ],
        repo_root,
    )

    c_positions = read_decision(c_decision)
    rtl_positions = read_decision(rtl_decision)
    if c_positions != rtl_positions:
        c_only = sorted(set(c_positions) - set(rtl_positions))
        rtl_only = sorted(set(rtl_positions) - set(c_positions))
        raise RuntimeError(
            "C/RTL decision mismatch: "
            f"C-only={c_only[:16]} RTL-only={rtl_only[:16]} "
            f"C-weight={len(c_positions)} RTL-weight={len(rtl_positions)}"
        )
    print(
        f"PASS: C/RTL decisions match seed={args.seed} "
        f"n={2 * args.r} w={args.w} weight={len(c_positions)}"
    )


def main() -> int:
    args = parse_args()
    repo_root = Path(__file__).resolve().parents[1]
    if args.keep_dir:
        work_dir = Path(args.keep_dir).resolve()
        work_dir.mkdir(parents=True, exist_ok=True)
        execute(args, work_dir, repo_root)
    else:
        with tempfile.TemporaryDirectory(prefix="min-sum-diff-") as temp_dir:
            execute(args, Path(temp_dir), repo_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
