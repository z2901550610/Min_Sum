#!/usr/bin/env python3
"""Generate a TRIKE-2 Encaps RTL fixture from the first official KAT record."""

from __future__ import annotations

import argparse
from pathlib import Path

from trike_fixture_utils import (
    Sm3Drng,
    WORD_W,
    cyclic_multiply,
    first_hex_field,
    format_byte_array,
    format_word_array,
    h123_vectors,
    pseudohash,
    sample_indices,
    support_blocks,
    words_from_bytes,
)


R_BITS = 15581
WEIGHT = 263
M_BYTES = 32


def h4_support(message: bytes, r2: bytes) -> list[int]:
    return sample_indices(Sm3Drng(message + r2), 3 * R_BITS, WEIGHT)


def generate_fixture(kat_path: Path, output_path: Path) -> None:
    kat_text = kat_path.read_text(encoding="ascii")
    kat_seed = first_hex_field(kat_text, "Seed")
    public_key = first_hex_field(kat_text, "PK")
    ciphertext = first_hex_field(kat_text, "CT")
    shared_secret = first_hex_field(kat_text, "SS")

    r_bytes = (R_BITS + 7) // 8
    padded_r_bytes = ((R_BITS + 511) // 512) * 64
    if len(public_key) != r_bytes + M_BYTES:
        raise ValueError("unexpected TRIKE-2 public-key length")
    if len(ciphertext) != (2 * r_bytes) + M_BYTES:
        raise ValueError("unexpected TRIKE-2 ciphertext length")

    r2 = public_key[:r_bytes]
    sigma = public_key[r_bytes:]
    kat_u = ciphertext[:r_bytes]
    kat_v = ciphertext[r_bytes : 2 * r_bytes]
    kat_c2 = ciphertext[2 * r_bytes :]

    global_drng = Sm3Drng(kat_seed)
    key_seed = global_drng.generate(M_BYTES)
    sigma2 = global_drng.generate(M_BYTES)
    generated_sigma = global_drng.generate(M_BYTES)
    message = global_drng.generate(M_BYTES)
    if generated_sigma != sigma:
        raise ValueError("recovered global-DRNG sigma does not match public key")

    t1, t2, r1 = h123_vectors(sigma, R_BITS)
    support = h4_support(message, r2)
    e0, e1, e2 = support_blocks(support, R_BITS)
    r1_value = int.from_bytes(r1, "little")
    r2_value = int.from_bytes(r2, "little")
    t1_value = int.from_bytes(t1, "little")
    t2_value = int.from_bytes(t2, "little")
    u_value = e0 ^ cyclic_multiply(e1, r1_value, R_BITS) ^ cyclic_multiply(e2, r2_value, R_BITS)
    v_value = e0 ^ cyclic_multiply(e1, t1_value, R_BITS) ^ cyclic_multiply(e2, t2_value, R_BITS)
    u = u_value.to_bytes(r_bytes, "little")
    v = v_value.to_bytes(r_bytes, "little")
    if u != kat_u or v != kat_v:
        raise ValueError("recomputed u/v does not match official ciphertext")

    error_message = b"".join(
        value.to_bytes(r_bytes, "little") + bytes(padded_r_bytes - r_bytes)
        for value in (e0, e1, e2)
    )
    l_digest = pseudohash(error_message)
    error_hash = l_digest[:M_BYTES]
    c2 = bytes(left ^ right for left, right in zip(message, error_hash))
    if c2 != kat_c2:
        raise ValueError("recomputed c2 does not match official ciphertext")
    k_digest = pseudohash(message + ciphertext)
    ss = k_digest[:M_BYTES]
    if ss != shared_secret:
        raise ValueError("recomputed shared secret does not match official KAT")

    words = (R_BITS + WORD_W - 1) // WORD_W
    lines = [
        "// Generated from Count=0 of the official TRIKE-2 KAT.",
        "// m is the fourth 32-byte global-DRNG Generate after KeyGen inputs.",
        f"localparam int REF_R_BITS = {R_BITS};",
        f"localparam int REF_R_BYTES = {r_bytes};",
        f"localparam int REF_PADDED_R_BYTES = {padded_r_bytes};",
        f"localparam int REF_ERROR_WEIGHT = {WEIGHT};",
        f"localparam int REF_M_BYTES = {M_BYTES};",
        f"localparam int REF_WORDS = {words};",
        "localparam int REF_GLOBAL_INDEX_W = $clog2(3*REF_R_BITS);",
        "",
    ]
    for name, data in (
        ("REF_KAT_SEED", kat_seed),
        ("REF_KEY_SEED", key_seed),
        ("REF_SIGMA2", sigma2),
        ("REF_SIGMA", sigma),
        ("REF_MESSAGE", message),
        ("REF_R2", r2),
        ("REF_T1", t1),
        ("REF_T2", t2),
        ("REF_R1", r1),
        ("REF_ERROR_PADDED", error_message),
        ("REF_CIPHERTEXT", ciphertext),
        ("REF_C2", c2),
        ("REF_SS", ss),
        ("REF_ERROR_HASH", error_hash),
        ("REF_L_DIGEST", l_digest),
        ("REF_K_DIGEST", k_digest),
    ):
        lines.extend(format_byte_array(name, data))
        lines.append("")

    lines.append(
        "localparam logic [REF_GLOBAL_INDEX_W-1:0] "
        "REF_ERROR_INDICES [0:REF_ERROR_WEIGHT-1] = '{"
    )
    for index, coefficient in enumerate(support):
        suffix = "," if index != len(support) - 1 else ""
        lines.append(f"    REF_GLOBAL_INDEX_W'({coefficient}){suffix}")
    lines.append("};")
    lines.append("")

    for name, data in (
        ("REF_R1_WORDS", r1),
        ("REF_R2_WORDS", r2),
        ("REF_T1_WORDS", t1),
        ("REF_T2_WORDS", t2),
        ("REF_U_WORDS", u),
        ("REF_V_WORDS", v),
    ):
        lines.extend(format_word_array(name, words_from_bytes(data, words)))
        lines.append("")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines), encoding="ascii")
    print(
        "TRIKE-2 Encaps fixture PASS "
        f"m={message.hex()} support={len(support)} "
        f"ct={len(ciphertext)} ss={ss.hex()}"
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
