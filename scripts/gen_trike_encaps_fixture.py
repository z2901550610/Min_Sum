#!/usr/bin/env python3
"""Generate a TRIKE-2 Encaps RTL fixture from the first official KAT record."""

from __future__ import annotations

import argparse
import hashlib
import hmac
from pathlib import Path


R_BITS = 15581
WEIGHT = 263
M_BYTES = 32
WORD_W = 64
ICCS_HMAC_KEY = bytes.fromhex(
    "5307f6d5eb6a3ced3d24c53cc9c82cce"
    "2f8936397023f0695c26c80c1ab182a7"
    "1db02ba92f544018115a96e719662ca3"
    "2b7c7efc0a6d2482150766ba6f655b8e"
)


def first_hex_field(kat_text: str, name: str) -> bytes:
    prefix = f"{name} = "
    for line in kat_text.splitlines():
        if line.startswith(prefix):
            return bytes.fromhex(line[len(prefix) :])
    raise ValueError(f"missing {name} field in KAT")


def sm3(data: bytes) -> bytes:
    return hashlib.new("sm3", data).digest()


def sm3_df(seed: bytes) -> bytes:
    output = b""
    for counter in (1, 2):
        output += sm3(bytes([counter]) + bytes.fromhex("000001b8") + seed)
    return output[:55]


class Sm3Drng:
    def __init__(self, seed: bytes):
        self.v = sm3_df(seed)
        self.c = sm3_df(b"\x00" + self.v)
        self.counter = 1

    def generate(self, output_bytes: int) -> bytes:
        data = int.from_bytes(self.v, "big")
        output = b""
        while len(output) < output_bytes:
            output += sm3(data.to_bytes(55, "big"))
            data = (data + 1) % (1 << 440)
        h_value = b"\x00" * 23 + sm3(b"\x03" + self.v)
        self.v = (
            int.from_bytes(self.v, "big")
            + int.from_bytes(h_value, "big")
            + int.from_bytes(self.c, "big")
            + self.counter
        ).to_bytes(56, "big")[-55:]
        self.counter += 1
        return output[:output_bytes]


def set_parity(vector: bytes, target: int) -> bytes:
    result = bytearray(vector)
    parity_bit = (R_BITS - 1) & 7
    result[-1] &= (1 << parity_bit) - 1
    parity = sum(byte.bit_count() for byte in result) & 1
    result[-1] |= (target ^ parity) << parity_bit
    return bytes(result)


def h123_vectors(sigma: bytes) -> tuple[bytes, bytes, bytes]:
    r_bytes = (R_BITS + 7) // 8
    drng = Sm3Drng(sigma)
    return (
        set_parity(drng.generate(r_bytes), 0),
        set_parity(drng.generate(r_bytes), 0),
        set_parity(drng.generate(r_bytes), 1),
    )


def h4_support(message: bytes, r2: bytes) -> list[int]:
    length = 3 * R_BITS
    drng = Sm3Drng(message + r2)
    indices = [0] * WEIGHT
    for position in range(WEIGHT - 1, -1, -1):
        random_word = int.from_bytes(drng.generate(4), "little")
        candidate = position + ((random_word * (length - position)) >> 32)
        if candidate in indices[position + 1 :]:
            candidate = position
        indices[position] = candidate
    return indices


def support_blocks(indices: list[int]) -> tuple[int, int, int]:
    blocks = [0, 0, 0]
    for index in indices:
        block, coefficient = divmod(index, R_BITS)
        blocks[block] |= 1 << coefficient
    return blocks[0], blocks[1], blocks[2]


def cyclic_multiply(a_value: int, b_value: int) -> int:
    product = 0
    while a_value:
        low_bit = a_value & -a_value
        product ^= b_value << (low_bit.bit_length() - 1)
        a_value ^= low_bit
    mask = (1 << R_BITS) - 1
    return ((product & mask) ^ (product >> R_BITS)) & mask


def pseudohash(message: bytes) -> bytes:
    k1 = hmac.new(ICCS_HMAC_KEY, b"\x02\x00" + message, digestmod="sm3").digest()
    h1 = sm3(message + b"\x02\x00")
    return h1 + sm3(k1 + h1)


def words_from_bytes(data: bytes) -> list[int]:
    word_bytes = WORD_W // 8
    words = (R_BITS + WORD_W - 1) // WORD_W
    padded = data + bytes(words * word_bytes - len(data))
    return [
        int.from_bytes(padded[offset : offset + word_bytes], "little")
        for offset in range(0, len(padded), word_bytes)
    ]


def format_byte_array(name: str, data: bytes) -> list[str]:
    lines = [f"localparam logic [7:0] {name} [0:{len(data)-1}] = '{{"]
    for offset in range(0, len(data), 8):
        chunk = data[offset : offset + 8]
        values = []
        for index, value in enumerate(chunk, start=offset):
            suffix = "," if index != len(data) - 1 else ""
            values.append(f"8'h{value:02x}{suffix}")
        lines.append("    " + " ".join(values))
    lines.append("};")
    return lines


def format_word_array(name: str, words: list[int]) -> list[str]:
    lines = [f"localparam logic [63:0] {name} [0:REF_WORDS-1] = '{{"]
    for index, word in enumerate(words):
        suffix = "," if index != len(words) - 1 else ""
        lines.append(f"    64'h{word:016x}{suffix}")
    lines.append("};")
    return lines


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

    t1, t2, r1 = h123_vectors(sigma)
    support = h4_support(message, r2)
    e0, e1, e2 = support_blocks(support)
    r1_value = int.from_bytes(r1, "little")
    r2_value = int.from_bytes(r2, "little")
    t1_value = int.from_bytes(t1, "little")
    t2_value = int.from_bytes(t2, "little")
    u_value = e0 ^ cyclic_multiply(e1, r1_value) ^ cyclic_multiply(e2, r2_value)
    v_value = e0 ^ cyclic_multiply(e1, t1_value) ^ cyclic_multiply(e2, t2_value)
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

    lines = [
        "// Generated from Count=0 of the official TRIKE-2 KAT.",
        "// m is the fourth 32-byte global-DRNG Generate after KeyGen inputs.",
        f"localparam int REF_R_BITS = {R_BITS};",
        f"localparam int REF_R_BYTES = {r_bytes};",
        f"localparam int REF_PADDED_R_BYTES = {padded_r_bytes};",
        f"localparam int REF_ERROR_WEIGHT = {WEIGHT};",
        f"localparam int REF_M_BYTES = {M_BYTES};",
        f"localparam int REF_WORDS = {(R_BITS + WORD_W - 1) // WORD_W};",
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
        lines.extend(format_word_array(name, words_from_bytes(data)))
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
