#!/usr/bin/env python3
"""Generate a TRIKE polynomial-inversion fixture from an official KAT."""

from __future__ import annotations

import argparse
import hashlib
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
    target = r_bits - 2
    main_multiplications = target.bit_length() - 1
    accumulation_multiplications = target.bit_count() - 1
    multiplications = main_multiplications + accumulation_multiplications
    return multiplications + 1, multiplications


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
