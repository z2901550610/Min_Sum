#!/usr/bin/env python3
"""Generate a TRIKE polynomial-multiplier fixture from an official KAT."""

from __future__ import annotations

import argparse
from pathlib import Path
import struct

from trike_fixture_utils import (
    WORD_W,
    cyclic_multiply_bytes,
    first_hex_field,
    format_word_array,
    words_from_bytes,
)


def generate_fixture(kat_path: Path, output_path: Path, r_bits: int, weight: int) -> None:
    kat_text = kat_path.read_text(encoding="ascii")
    public_key = first_hex_field(kat_text, "PK")
    secret_key = first_hex_field(kat_text, "SK")

    r_bytes = (r_bits + 7) // 8
    support_bytes = 3 * weight * 4
    expected_pk_bytes = r_bytes + 32
    expected_sk_min = support_bytes + (3 * r_bytes) + 64
    if len(public_key) != expected_pk_bytes:
        raise ValueError(
            f"PK length {len(public_key)} does not match {expected_pk_bytes}"
        )
    if len(secret_key) < expected_sk_min:
        raise ValueError(
            f"SK length {len(secret_key)} is smaller than {expected_sk_min}"
        )

    h0_support = list(struct.unpack(f"<{weight}I", secret_key[: 4 * weight]))
    h0_offset = support_bytes
    t0_offset = h0_offset + r_bytes
    r2_offset = t0_offset + r_bytes
    h0 = secret_key[h0_offset:t0_offset]
    t0 = secret_key[t0_offset:r2_offset]
    secret_r2 = secret_key[r2_offset : r2_offset + r_bytes]
    public_r2 = public_key[:r_bytes]
    if secret_r2 != public_r2:
        raise ValueError("public and secret r2 encodings differ")

    dense_result = cyclic_multiply_bytes(t0, public_r2, r_bits)
    sparse_result = cyclic_multiply_bytes(h0, public_r2, r_bits)
    word_count = (r_bits + WORD_W - 1) // WORD_W

    lines = [
        "// Generated from the first record of the official TRIKE-2 KAT.",
        f"localparam int REF_R_BITS = {r_bits};",
        f"localparam int REF_WORD_W = {WORD_W};",
        "localparam int REF_DIGIT_W = 16;",
        f"localparam int REF_SPARSE_WEIGHT = {weight};",
        f"localparam int REF_WORDS = {word_count};",
        "localparam int REF_INDEX_W = $clog2(REF_R_BITS);",
        "",
    ]
    for name, data in (
        ("REF_DENSE_A", t0),
        ("REF_DENSE_B", public_r2),
        ("REF_DENSE_RESULT", dense_result),
        ("REF_SPARSE_RESULT", sparse_result),
    ):
        lines.extend(
            format_word_array(
                name, words_from_bytes(data, word_count), width="REF_WORD_W-1:0"
            )
        )
        lines.append("")
    lines.append(
        "localparam logic [REF_INDEX_W-1:0] "
        "REF_SPARSE_INDICES [0:REF_SPARSE_WEIGHT-1] = '{"
    )
    for index, coefficient in enumerate(h0_support):
        suffix = "," if index != (len(h0_support) - 1) else ""
        lines.append(f"    REF_INDEX_W'({coefficient}){suffix}")
    lines.append("};")
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
