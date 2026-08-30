#!/usr/bin/env python3
"""Model binary-polynomial Bernstein-Yang inversion and its public cycle schedule."""

from __future__ import annotations

import argparse
import hashlib
import math

from trike_fixture_utils import polynomial_inverse


def reverse_bits(value: int, width: int) -> int:
    result = 0
    for bit_idx in range(width):
        result |= ((value >> bit_idx) & 1) << (width - 1 - bit_idx)
    return result


def bernstein_yang_inverse(value: int, r_bits: int) -> int:
    """Run exactly 2*r-1 characteristic-two divsteps."""
    width = r_bits + 1
    mask = (1 << width) - 1
    f_value = (1 << r_bits) | 1
    g_value = reverse_bits(value, r_bits)
    v_value = 0
    w_value = 1
    delta = 1

    for _ in range(2 * r_bits - 1):
        alpha = g_value & 1
        swap = delta > 0 and alpha != 0
        old_f = f_value
        old_g = g_value
        old_v = v_value
        old_w = w_value
        delta = 1 - delta if swap else 1 + delta
        f_value = (old_g if swap else old_f) & mask
        g_value = (((old_g ^ old_f) if alpha else old_g) >> 1) & mask
        v_value = ((old_w if swap else old_v) << 1) & mask
        w_value = ((old_w ^ old_v) if alpha else old_w) & mask

    return reverse_bits(v_value >> 1, r_bits)


def racing_cycle_model(
    r_bits: int,
    word_bits: int,
    steps_per_round: int,
    control_unroll: int,
    update_unroll: int,
) -> int:
    """Equation 3 from Racing BIKE; the paper has a separate s=1 special case."""
    if min(r_bits, word_bits, steps_per_round, control_unroll, update_unroll) <= 0:
        raise ValueError("cycle-model parameters must be positive")
    if steps_per_round > word_bits:
        raise ValueError("steps_per_round must not exceed word_bits")
    total_steps = 2 * r_bits - 1
    full_rounds = total_steps // steps_per_round
    remainder = total_steps - full_rounds * steps_per_round
    word_count = math.ceil(r_bits / word_bits)
    main_round_cycles = (
        3
        + math.ceil(steps_per_round / control_unroll)
        + math.ceil(steps_per_round / update_unroll)
        + word_count
    )
    remainder_cycles = (
        math.ceil(remainder / update_unroll)
        + math.ceil(steps_per_round / control_unroll)
        + word_count
    )
    return (
        full_rounds * main_round_cycles
        + remainder_cycles
        + 3 * word_count
        + 13
    )


def deterministic_invertible_input(r_bits: int, seed: int) -> int:
    byte_count = (r_bits + 7) // 8
    mask = (1 << r_bits) - 1
    counter = 0
    while True:
        material = bytearray()
        block_idx = 0
        while len(material) < byte_count:
            material.extend(
                hashlib.sha256(
                    f"trike-by:{r_bits}:{seed}:{counter}:{block_idx}".encode("ascii")
                ).digest()
            )
            block_idx += 1
        value = int.from_bytes(material[:byte_count], "little") & mask
        try:
            polynomial_inverse(value, r_bits)
            return value
        except ValueError:
            counter += 1


def self_test() -> None:
    checked = 0
    for value in range(1, 1 << 13):
        try:
            expected = polynomial_inverse(value, 13)
        except ValueError:
            continue
        actual = bernstein_yang_inverse(value, 13)
        if actual != expected:
            raise ValueError(
                f"r=13 mismatch input={value:#x} actual={actual:#x} expected={expected:#x}"
            )
        checked += 1

    trike2_input = deterministic_invertible_input(15581, 1)
    trike2_expected = polynomial_inverse(trike2_input, 15581)
    trike2_actual = bernstein_yang_inverse(trike2_input, 15581)
    if trike2_actual != trike2_expected:
        raise ValueError("TRIKE-2 deterministic inversion mismatch")
    print(f"Bernstein-Yang model PASS r13_cases={checked} trike2_cases=1")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--r-bits", type=int, default=15581)
    parser.add_argument("--word-bits", type=int, default=64)
    parser.add_argument("--control-unroll", type=int, default=2)
    parser.add_argument("--update-unroll", type=int, default=8)
    parser.add_argument("--step-sizes", type=int, nargs="+", default=[1, 2, 4, 8, 16, 32, 64])
    parser.add_argument("--self-test", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.self_test:
        self_test()
    print("s cycles latency_ms_at_100mhz")
    for step_size in args.step_sizes:
        cycles = racing_cycle_model(
            args.r_bits,
            args.word_bits,
            step_size,
            args.control_unroll,
            args.update_unroll,
        )
        print(f"{step_size} {cycles} {cycles / 100_000.0:.5f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
