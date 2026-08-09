#!/usr/bin/env python3
"""Generate fixed Frobenius inversion schedules for a public TRIKE r."""

from __future__ import annotations

import argparse


def inversion_schedule(r_bits: int) -> list[tuple[int, int, int, int]]:
    if r_bits < 3:
        raise ValueError("r must be at least 3")
    target = r_bits - 2
    accumulated = 1
    schedule = []
    for stage in range(1, target.bit_length()):
        k0 = 1 << (stage - 1)
        l0 = pow(pow(2, k0, r_bits), -1, r_bits)
        k1 = accumulated if ((target >> stage) & 1) else 0
        l1 = pow(pow(2, k1, r_bits), -1, r_bits) if k1 else 0
        schedule.append((stage, l0, k1, l1))
        if k1:
            accumulated += 1 << stage
    if accumulated != target:
        raise ValueError("addition chain did not cover r-2")
    return schedule


def validate_schedule(r_bits: int, schedule: list[tuple[int, int, int, int]]) -> None:
    target = r_bits - 2
    accumulated = 1
    for stage, l0, k1, l1 in schedule:
        k0 = 1 << (stage - 1)
        if (l0 * pow(2, k0, r_bits)) % r_bits != 1:
            raise ValueError(f"invalid l0 at stage {stage}")
        expected_k1 = accumulated if ((target >> stage) & 1) else 0
        if k1 != expected_k1:
            raise ValueError(f"invalid k1 at stage {stage}")
        if k1:
            if (l1 * pow(2, k1, r_bits)) % r_bits != 1:
                raise ValueError(f"invalid l1 at stage {stage}")
            accumulated += 1 << stage
        elif l1 != 0:
            raise ValueError(f"unexpected l1 at stage {stage}")
    if accumulated != target:
        raise ValueError("invalid final addition-chain exponent")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--r-bits", type=int, required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    schedule = inversion_schedule(args.r_bits)
    validate_schedule(args.r_bits, schedule)
    multiplications = len(schedule) + sum(k1 != 0 for _, _, k1, _ in schedule)
    print(
        f"r={args.r_bits} stage_count={len(schedule) + 1} "
        f"permutations={multiplications + 1} multiplications={multiplications}"
    )
    print("stage l0 k1 l1")
    for stage, l0, k1, l1 in schedule:
        print(f"{stage} {l0} {k1} {l1}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
