#!/usr/bin/env python3
"""Shared helpers for TRIKE KAT-derived RTL fixture generators."""

from __future__ import annotations

from collections import Counter
import hashlib
import hmac


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


def pseudohash(message: bytes) -> bytes:
    k1 = hmac.new(ICCS_HMAC_KEY, b"\x02\x00" + message, digestmod="sm3").digest()
    h1 = sm3(message + b"\x02\x00")
    return h1 + sm3(k1 + h1)


def set_parity(vector: bytes, target: int, r_bits: int) -> bytes:
    result = bytearray(vector)
    parity_bit = (r_bits - 1) & 7
    result[-1] &= (1 << parity_bit) - 1
    parity = sum(byte.bit_count() for byte in result) & 1
    result[-1] |= (target ^ parity) << parity_bit
    return bytes(result)


def h123_vectors(sigma: bytes, r_bits: int) -> tuple[bytes, bytes, bytes]:
    r_bytes = (r_bits + 7) // 8
    drng = Sm3Drng(sigma)
    return (
        set_parity(drng.generate(r_bytes), 0, r_bits),
        set_parity(drng.generate(r_bytes), 0, r_bits),
        set_parity(drng.generate(r_bytes), 1, r_bits),
    )


def sample_indices(drng: Sm3Drng, length: int, weight: int) -> list[int]:
    indices = [0] * weight
    for position in range(weight - 1, -1, -1):
        random_word = int.from_bytes(drng.generate(4), "little")
        candidate = position + ((random_word * (length - position)) >> 32)
        if candidate in indices[position + 1 :]:
            candidate = position
        indices[position] = candidate
    return indices


def support_blocks(indices: list[int], r_bits: int) -> tuple[int, int, int]:
    blocks = [0, 0, 0]
    for index in indices:
        block, coefficient = divmod(index, r_bits)
        blocks[block] |= 1 << coefficient
    return blocks[0], blocks[1], blocks[2]


def collision_score(values: list[int]) -> int:
    counts = Counter(values)
    return sum(count * (count - 1) // 2 for count in counts.values())


def self_score(indices: list[int], r_bits: int) -> int:
    distances = []
    for upper in range(1, len(indices)):
        for lower in range(upper):
            distance = (indices[lower] - indices[upper]) % r_bits
            distances.append(min(distance, r_bits - distance))
    return collision_score(distances)


def cross_score(left: list[int], right: list[int], r_bits: int) -> int:
    return collision_score(
        [(right_index - left_index) % r_bits for left_index in left for right_index in right]
    )


def weak_scores(blocks: list[list[int]], r_bits: int) -> tuple[int, int, int, int, int, int]:
    return (
        self_score(blocks[0], r_bits),
        self_score(blocks[1], r_bits),
        self_score(blocks[2], r_bits),
        cross_score(blocks[0], blocks[1], r_bits),
        cross_score(blocks[1], blocks[2], r_bits),
        cross_score(blocks[2], blocks[0], r_bits),
    )


def is_weak(
    scores: tuple[int, ...], self_threshold: int, cross_threshold: int
) -> bool:
    return any(score > self_threshold for score in scores[:3]) or any(
        score > cross_threshold for score in scores[3:]
    )


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


def cyclic_multiply_bytes(a_data: bytes, b_data: bytes, r_bits: int) -> bytes:
    result = cyclic_multiply(
        int.from_bytes(a_data, "little"), int.from_bytes(b_data, "little"), r_bits
    )
    return result.to_bytes((r_bits + 7) // 8, "little")


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


def serialize_key_pair(
    support: list[list[int]],
    t1: bytes,
    t2: bytes,
    r1: bytes,
    sigma: bytes,
    sigma2: bytes,
    r_bits: int,
) -> tuple[bytes, bytes, bytes, bytes]:
    h_values = [sum(1 << coefficient for coefficient in block) for block in support]
    t1_value = int.from_bytes(t1, "little")
    t2_value = int.from_bytes(t2, "little")
    r1_value = int.from_bytes(r1, "little")
    denominator1_inv = polynomial_inverse(t1_value ^ r1_value, r_bits)
    numerator1 = cyclic_multiply(h_values[0], r1_value, r_bits) ^ h_values[1]
    t0_value = cyclic_multiply(numerator1, denominator1_inv, r_bits)
    denominator2_inv = polynomial_inverse(t0_value ^ h_values[0], r_bits)
    numerator2 = cyclic_multiply(t0_value, t2_value, r_bits) ^ h_values[2]
    r2_value = cyclic_multiply(numerator2, denominator2_inv, r_bits)
    r_bytes = (r_bits + 7) // 8
    h0 = h_values[0].to_bytes(r_bytes, "little")
    t0 = t0_value.to_bytes(r_bytes, "little")
    r2 = r2_value.to_bytes(r_bytes, "little")
    support_data = b"".join(
        int(coefficient).to_bytes(4, "little")
        for block in support
        for coefficient in block
    )
    return r2 + sigma, support_data + h0 + t0 + r2 + sigma + sigma2, t0, r2


def words_from_bytes(data: bytes, word_count: int) -> list[int]:
    word_bytes = WORD_W // 8
    padded = data + bytes(word_count * word_bytes - len(data))
    return [
        int.from_bytes(padded[offset : offset + word_bytes], "little")
        for offset in range(0, len(padded), word_bytes)
    ]


def words_from_value(value: int, word_count: int) -> list[int]:
    mask = (1 << WORD_W) - 1
    return [(value >> (word * WORD_W)) & mask for word in range(word_count)]


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


def format_word_array(
    name: str, words: list[int], width: str = "63:0", size_expr: str = "REF_WORDS"
) -> list[str]:
    lines = [f"localparam logic [{width}] {name} [0:{size_expr}-1] = '{{"]
    for index, word in enumerate(words):
        suffix = "," if index != len(words) - 1 else ""
        lines.append(f"    64'h{word:016x}{suffix}")
    lines.append("};")
    return lines
