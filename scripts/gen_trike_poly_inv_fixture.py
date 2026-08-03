#!/usr/bin/env python3
"""Generate a TRIKE polynomial-inversion fixture from an official KAT."""

from __future__ import annotations

import argparse
from pathlib import Path


WORD_W = 64


def first_hex_field(kat_text: str, name: str) -> bytes:
    prefix = f"{name} = "
    for line in kat_text.splitlines():
        if line.startswith(prefix):
            return bytes.fromhex(line[len(prefix) :])
    raise ValueError(f"missing {name} field in KAT")


def cyclic_reduce(value: int, r_bits: int) -> int:
    mask = (1 << r_bits) - 1
    while value.bit_length() > r_bits:
        value = (value & mask) ^ (value >> r_bits)
    return value & mask


def cyclic_multiply(a_value: int, b_value: int, r_bits: int) -> int:
    product = 0
    while a_value:
        low_bit = a_value & -a_value
        product ^= b_value << (low_bit.bit_length() - 1)
        a_value ^= low_bit
    return cyclic_reduce(product, r_bits)


def polynomial_inverse(value: int, r_bits: int) -> int:
    modulus = (1 << r_bits) | 1
    u = value
    v = modulus
    g1 = 1
    g2 = 0
    while u != 1:
        if u == 0:
            raise ValueError("fixture polynomial is not invertible")
        shift = u.bit_length() - v.bit_length()
        if shift < 0:
            u, v = v, u
            g1, g2 = g2, g1
            shift = -shift
        u ^= v << shift
        g1 ^= g2 << shift
    inverse = cyclic_reduce(g1, r_bits)
    if cyclic_multiply(value, inverse, r_bits) != 1:
        raise ValueError("generated inverse does not multiply to one")
    return inverse


def words_from_value(value: int, word_count: int) -> list[int]:
    mask = (1 << WORD_W) - 1
    return [(value >> (word * WORD_W)) & mask for word in range(word_count)]


def format_word_array(name: str, words: list[int]) -> list[str]:
    lines = [
        f"localparam logic [REF_INV_WORD_W-1:0] {name} "
        "[0:REF_INV_WORDS-1] = '{"
    ]
    for index, word in enumerate(words):
        suffix = "," if index != (len(words) - 1) else ""
        lines.append(f"    64'h{word:016x}{suffix}")
    lines.append("};")
    return lines


def generate_fixture(kat_path: Path, output_path: Path, r_bits: int, weight: int) -> None:
    kat_text = kat_path.read_text(encoding="ascii")
    secret_key = first_hex_field(kat_text, "SK")
    r_bytes = (r_bits + 7) // 8
    support_bytes = 3 * weight * 4
    h0_data = secret_key[support_bytes : support_bytes + r_bytes]
    if len(h0_data) != r_bytes:
        raise ValueError("secret key does not contain a complete h0 polynomial")

    input_value = int.from_bytes(h0_data, "little") & ((1 << r_bits) - 1)
    inverse_value = polynomial_inverse(input_value, r_bits)
    word_count = (r_bits + WORD_W - 1) // WORD_W

    lines = [
        "// Generated from h0 in the first official TRIKE-2 KAT record.",
        f"localparam int REF_INV_R_BITS = {r_bits};",
        f"localparam int REF_INV_WORD_W = {WORD_W};",
        "localparam int REF_INV_DIGIT_W = 8;",
        f"localparam int REF_INV_WORDS = {word_count};",
        "",
    ]
    lines.extend(
        format_word_array(
            "REF_INV_INPUT", words_from_value(input_value, word_count)
        )
    )
    lines.append("")
    lines.extend(
        format_word_array(
            "REF_INV_RESULT", words_from_value(inverse_value, word_count)
        )
    )
    lines.append("")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines), encoding="ascii")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kat", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--r-bits", type=int, default=15581)
    parser.add_argument("--weight", type=int, default=35)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    generate_fixture(args.kat, args.output, args.r_bits, args.weight)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
