#!/usr/bin/env python3
"""Generate fixed Frobenius inversion schedules for a public TRIKE r."""

from __future__ import annotations

import argparse


TRIKE2_SHORT_CHAIN = (
    1,
    2,
    4,
    8,
    9,
    18,
    36,
    72,
    144,
    288,
    576,
    577,
    1154,
    2308,
    4616,
    5193,
    10386,
    15579,
)

TRIKE2_SHORT_STEPS = (
    (1, 1),
    (2, 2),
    (4, 4),
    (8, 1),
    (9, 9),
    (18, 18),
    (36, 36),
    (72, 72),
    (144, 144),
    (288, 288),
    (1, 576),
    (577, 577),
    (1154, 1154),
    (2308, 2308),
    (577, 4616),
    (5193, 5193),
    (10386, 5193),
)


def short_addition_chain(r_bits: int) -> tuple[int, ...] | None:
    if r_bits == 15581:
        return TRIKE2_SHORT_CHAIN
    return None


def inversion_counts(r_bits: int) -> tuple[int, int]:
    chain = short_addition_chain(r_bits)
    if chain is not None:
        multiplications = len(chain) - 1
    else:
        target = r_bits - 2
        multiplications = target.bit_length() - 1 + target.bit_count() - 1
    return multiplications + 1, multiplications


def validate_short_chain(r_bits: int, chain: tuple[int, ...]) -> None:
    if chain[0] != 1 or chain[-1] != (r_bits - 2):
        raise ValueError("short addition-chain endpoints are invalid")
    if len(TRIKE2_SHORT_STEPS) != (len(chain) - 1):
        raise ValueError("short addition-chain operation count is invalid")
    known = {1}
    for value, (left, right) in zip(chain[1:], TRIKE2_SHORT_STEPS, strict=True):
        if left not in known or right not in known or (left + right) != value:
            raise ValueError(
                f"short addition-chain step {value} has invalid operands {left},{right}"
            )
        known.add(value)


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
    short_chain = short_addition_chain(args.r_bits)
    if short_chain is not None:
        validate_short_chain(args.r_bits, short_chain)
        permutations, multiplications = inversion_counts(args.r_bits)
        print(
            f"r={args.r_bits} permutations={permutations} "
            f"multiplications={multiplications}"
        )
        print("chain=" + ",".join(str(value) for value in short_chain))
        print("operation left right permutation_stride")
        for operation, (left, right) in enumerate(TRIKE2_SHORT_STEPS):
            stride = pow(pow(2, left, args.r_bits), -1, args.r_bits)
            print(f"{operation} {left} {right} {stride}")
        return 0
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
