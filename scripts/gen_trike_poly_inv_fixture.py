#!/usr/bin/env python3
"""Generate a TRIKE polynomial-inversion fixture from an official KAT."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path

from trike_fixture_utils import (
    WORD_W,
    first_hex_field,
    format_word_array,
    polynomial_inverse,
    words_from_value,
)
from gen_trike_inv_schedule import inversion_counts


def deterministic_invertible_input(r_bits: int, seed: int) -> int:
    r_bytes = (r_bits + 7) // 8
    for attempt in range(256):
        domain = f"trike-inv-r{r_bits}-seed{seed}-attempt{attempt}".encode("ascii")
        candidate = int.from_bytes(hashlib.shake_256(domain).digest(r_bytes), "little")
        candidate &= (1 << r_bits) - 1
        if candidate.bit_count() % 2 == 0:
            candidate ^= 1
        try:
            polynomial_inverse(candidate, r_bits)
            return candidate
        except ValueError:
            continue
    raise ValueError("could not generate an invertible deterministic input")


def schedule_counts(r_bits: int) -> tuple[int, int]:
    return inversion_counts(r_bits)


def generate_fixture(
    kat_path: Path | None,
    output_path: Path,
    r_bits: int,
    weight: int,
    input_seed: int | None,
) -> None:
    r_bytes = (r_bits + 7) // 8
    if input_seed is not None:
        input_value = deterministic_invertible_input(r_bits, input_seed)
        source_comment = f"deterministic seed {input_seed}"
    elif kat_path is not None:
        kat_text = kat_path.read_text(encoding="ascii")
        secret_key = first_hex_field(kat_text, "SK")
        support_bytes = 3 * weight * 4
        h0_data = secret_key[support_bytes : support_bytes + r_bytes]
        if len(h0_data) != r_bytes:
            raise ValueError("secret key does not contain a complete h0 polynomial")
        input_value = int.from_bytes(h0_data, "little") & ((1 << r_bits) - 1)
        source_comment = "h0 in the first official TRIKE KAT record"
    else:
        raise ValueError("either --kat or --input-seed is required")

    inverse_value = polynomial_inverse(input_value, r_bits)
    word_count = (r_bits + WORD_W - 1) // WORD_W
    permutations, multiplications = schedule_counts(r_bits)

    lines = [
        f"// Generated from {source_comment}.",
        f"localparam int REF_INV_R_BITS = {r_bits};",
        f"localparam int REF_INV_WORD_W = {WORD_W};",
        "localparam int REF_INV_DIGIT_W = 16;",
        f"localparam int REF_INV_WORDS = {word_count};",
        f"localparam int REF_INV_PERMUTATIONS = {permutations};",
        f"localparam int REF_INV_MULTIPLICATIONS = {multiplications};",
        "",
    ]
    for name, value in (
        ("REF_INV_INPUT", input_value),
        ("REF_INV_RESULT", inverse_value),
    ):
        lines.extend(
            format_word_array(
                name,
                words_from_value(value, word_count),
                width="REF_INV_WORD_W-1:0",
                size_expr="REF_INV_WORDS",
            )
        )
        lines.append("")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines), encoding="ascii")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--kat", type=Path)
    source.add_argument("--input-seed", type=int)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--r-bits", type=int, default=15581)
    parser.add_argument("--weight", type=int, default=35)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    generate_fixture(args.kat, args.output, args.r_bits, args.weight, args.input_seed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
