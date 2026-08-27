#!/usr/bin/env python3
"""Generate a TRIKE-2 Decaps syndrome RTL fixture from the first official KAT."""

from __future__ import annotations

import argparse
from pathlib import Path

from trike_fixture_utils import (
    WORD_W,
    cyclic_multiply,
    first_hex_field,
    format_word_array,
    words_from_bytes,
)


R_BITS = 15581
SECRET_WEIGHT = 35


def generate_fixture(kat_path: Path, output_path: Path) -> None:
    kat_text = kat_path.read_text(encoding="utf-8-sig")
    secret_key = first_hex_field(kat_text, "SK")
    ciphertext = first_hex_field(kat_text, "CT")
    r_bytes = (R_BITS + 7) // 8
    words = (R_BITS + WORD_W - 1) // WORD_W
    support_bytes = 3 * SECRET_WEIGHT * 4

    if len(ciphertext) < 2 * r_bytes:
        raise ValueError("unexpected TRIKE-2 ciphertext length")
    if len(secret_key) < support_bytes + 2 * r_bytes:
        raise ValueError("unexpected TRIKE-2 secret-key length")

    h0_support = [
        int.from_bytes(secret_key[offset : offset + 4], "little")
        for offset in range(0, SECRET_WEIGHT * 4, 4)
    ]
    h0_value = sum(1 << coefficient for coefficient in h0_support)
    t0 = secret_key[support_bytes + r_bytes : support_bytes + 2 * r_bytes]
    u = ciphertext[:r_bytes]
    v = ciphertext[r_bytes : 2 * r_bytes]
    t0_value = int.from_bytes(t0, "little")
    u_value = int.from_bytes(u, "little")
    v_value = int.from_bytes(v, "little")
    syndrome_value = cyclic_multiply(h0_value, u_value, R_BITS) ^ cyclic_multiply(
        t0_value, u_value ^ v_value, R_BITS
    )
    syndrome = syndrome_value.to_bytes(r_bytes, "little")

    lines = [
        "// Generated from Count=0 of the official TRIKE-2 KAT.",
        f"localparam int REF_R_BITS = {R_BITS};",
        f"localparam int REF_SECRET_WEIGHT = {SECRET_WEIGHT};",
        f"localparam int REF_WORD_W = {WORD_W};",
        f"localparam int REF_WORDS = {words};",
        "localparam int REF_INDEX_W = $clog2(REF_R_BITS);",
        "",
        "localparam logic [REF_INDEX_W-1:0] REF_H0_SUPPORT [0:REF_SECRET_WEIGHT-1] = '{",
    ]
    for index, coefficient in enumerate(h0_support):
        suffix = "," if index != len(h0_support) - 1 else ""
        lines.append(f"    REF_INDEX_W'({coefficient}){suffix}")
    lines.extend(["};", ""])

    for name, data in (
        ("REF_T0_WORDS", t0),
        ("REF_U_WORDS", u),
        ("REF_V_WORDS", v),
        ("REF_SYNDROME_WORDS", syndrome),
    ):
        lines.extend(format_word_array(name, words_from_bytes(data, words)))
        lines.append("")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines), encoding="ascii")
    print(
        "TRIKE-2 Decaps syndrome fixture PASS "
        f"support={len(h0_support)} words={words} syndrome_weight={syndrome_value.bit_count()}"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kat", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    generate_fixture(args.kat, args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
