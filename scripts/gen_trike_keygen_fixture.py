#!/usr/bin/env python3
"""Generate and analyze TRIKE-2 KeyGen secret-candidate fixtures."""

from __future__ import annotations

import argparse
from pathlib import Path

from trike_fixture_utils import (
    Sm3Drng,
    first_hex_field,
    format_byte_array,
    format_word_array,
    h123_vectors,
    is_weak as is_weak_scores,
    sample_indices,
    serialize_key_pair,
    weak_scores,
    words_from_bytes,
)


R_BITS = 15581
WEIGHT = 35
M_BYTES = 32
WORDS = (R_BITS + 63) // 64
SELF_THRESHOLD = 46
CROSS_THRESHOLD = 83


def is_weak(scores: tuple[int, ...]) -> bool:
    return is_weak_scores(scores, SELF_THRESHOLD, CROSS_THRESHOLD)


def first_record(text: str) -> str:
    records = [record for record in text.split("count = ") if record.strip()]
    if not records:
        raise ValueError("KAT has no records")
    return "count = " + records[0]


def parse_support(secret_key: bytes) -> list[list[int]]:
    support_bytes = 3 * WEIGHT * 4
    raw = secret_key[:support_bytes]
    return [
        [
            int.from_bytes(raw[4 * (block * WEIGHT + pos) : 4 * (block * WEIGHT + pos + 1)], "little")
            for pos in range(WEIGHT)
        ]
        for block in range(3)
    ]


def candidate_stream(key_seed: bytes, count: int) -> tuple[list[list[list[int]]], Sm3Drng]:
    drng = Sm3Drng(key_seed)
    candidates = []
    for _ in range(count):
        candidates.append(
            [
                sample_indices(drng, R_BITS, WEIGHT),
                sample_indices(drng, R_BITS, WEIGHT),
                sample_indices(drng, R_BITS, WEIGHT),
            ]
        )
    return candidates, drng


def find_weak_first_seed(kat_seed: bytes) -> bytes:
    source = Sm3Drng(kat_seed)
    for _ in range(2000):
        key_seed = source.generate(M_BYTES)
        candidates, _ = candidate_stream(key_seed, 2)
        scores = [weak_scores(candidate, R_BITS) for candidate in candidates]
        if is_weak(scores[0]) and not is_weak(scores[1]):
            return key_seed
    raise ValueError("no weak-first schedule fixture found in 2000 deterministic trials")


def serialize_support(
    blocks: list[list[int]],
    t1: bytes,
    t2: bytes,
    r1: bytes,
    sigma: bytes,
    sigma2: bytes,
) -> tuple[bytes, bytes]:
    public_key, secret_key, _, _ = serialize_key_pair(
        blocks, t1, t2, r1, sigma, sigma2, R_BITS
    )
    return public_key, secret_key


def format_support_array(name: str, blocks: list[list[int]]) -> list[str]:
    flat = [index for block in blocks for index in block]
    lines = [f"localparam logic [REF_INDEX_W-1:0] {name} [0:{len(flat)-1}] = '{{"]
    for position, index in enumerate(flat):
        suffix = "," if position != len(flat) - 1 else ""
        lines.append(f"    REF_INDEX_W'({index}){suffix}")
    lines.append("};")
    return lines


def generate_fixture(kat_path: Path, output_path: Path, candidate_count: int) -> None:
    record = first_record(kat_path.read_text(encoding="utf-8-sig"))
    kat_seed = first_hex_field(record, "Seed")
    public_key = first_hex_field(record, "PK")
    secret_key = first_hex_field(record, "SK")

    global_drng = Sm3Drng(kat_seed)
    key_seed = global_drng.generate(M_BYTES)
    sigma2 = global_drng.generate(M_BYTES)
    sigma = global_drng.generate(M_BYTES)
    candidates, final_drng = candidate_stream(key_seed, candidate_count)
    t1, t2, r1 = h123_vectors(sigma, R_BITS)

    r_bytes = (R_BITS + 7) // 8
    support_bytes = 3 * WEIGHT * 4
    h0_offset = support_bytes
    t0_offset = h0_offset + r_bytes
    r2_offset = t0_offset + r_bytes
    t0 = secret_key[t0_offset:r2_offset]
    r2 = secret_key[r2_offset : r2_offset + r_bytes]
    if r2 != public_key[:r_bytes]:
        raise ValueError("public and secret r2 encodings differ")

    alternate_key_seed = find_weak_first_seed(kat_seed)
    alternate_candidates, alternate_final_drng = candidate_stream(
        alternate_key_seed, candidate_count
    )

    selected = None
    selected_number = 0
    score_table = []
    for number, candidate in enumerate(candidates):
        scores = weak_scores(candidate, R_BITS)
        score_table.append(scores)
        if selected is None and not is_weak(scores):
            selected = candidate
            selected_number = number
    if selected is None:
        selected = [[0] * WEIGHT for _ in range(3)]

    kat_support = parse_support(secret_key)
    if selected != kat_support:
        raise ValueError(
            f"fixed candidate budget did not select official support; selected={selected_number}"
        )

    alternate_selected_number = next(
        number
        for number, candidate in enumerate(alternate_candidates)
        if not is_weak(weak_scores(candidate, R_BITS))
    )
    alternate_selected = alternate_candidates[alternate_selected_number]
    alternate_scores = weak_scores(alternate_selected, R_BITS)
    computed_public_key, computed_secret_key = serialize_support(
        selected, t1, t2, r1, sigma, sigma2
    )
    if computed_public_key != public_key or computed_secret_key != secret_key:
        raise ValueError("recomputed official KeyGen output does not match KAT")
    alternate_public_key, alternate_secret_key = serialize_support(
        alternate_selected, t1, t2, r1, sigma, sigma2
    )

    lines = [
        "// Generated from Count=0 of the official TRIKE-2 KAT.",
        f"localparam int REF_R_BITS = {R_BITS};",
        f"localparam int REF_SECRET_WEIGHT = {WEIGHT};",
        f"localparam int REF_CANDIDATE_COUNT = {candidate_count};",
        f"localparam int REF_WORDS = {WORDS};",
        f"localparam int REF_PK_BYTES = {len(public_key)};",
        f"localparam int REF_SK_BYTES = {len(secret_key)};",
        "localparam int REF_INDEX_W = $clog2(REF_R_BITS);",
        f"localparam int REF_SELECTED_CANDIDATE = {selected_number};",
        f"localparam int REF_ALT_SELECTED_CANDIDATE = {alternate_selected_number};",
        f"localparam logic [439:0] REF_FINAL_V = 440'h{final_drng.v.hex()};",
        f"localparam logic [439:0] REF_FINAL_C = 440'h{final_drng.c.hex()};",
        f"localparam logic [439:0] REF_FINAL_RESEED = 440'd{final_drng.counter};",
        f"localparam logic [439:0] REF_ALT_FINAL_V = 440'h{alternate_final_drng.v.hex()};",
        f"localparam logic [439:0] REF_ALT_FINAL_C = 440'h{alternate_final_drng.c.hex()};",
        f"localparam logic [439:0] REF_ALT_FINAL_RESEED = 440'd{alternate_final_drng.counter};",
        "",
    ]
    for name, data in (
        ("REF_KAT_SEED", kat_seed),
        ("REF_KEY_SEED", key_seed),
        ("REF_SIGMA", sigma),
        ("REF_SIGMA2", sigma2),
        ("REF_ALT_KEY_SEED", alternate_key_seed),
        ("REF_PUBLIC_KEY", public_key),
        ("REF_SECRET_KEY", secret_key),
        ("REF_ALT_PUBLIC_KEY", alternate_public_key),
        ("REF_ALT_SECRET_KEY", alternate_secret_key),
    ):
        lines.extend(format_byte_array(name, data))
        lines.append("")
    lines.extend(format_support_array("REF_SELECTED_SUPPORT", selected))
    lines.append("")
    lines.extend(format_support_array("REF_ALT_SELECTED_SUPPORT", alternate_selected))
    lines.append("")
    lines.append("localparam logic [31:0] REF_SELECTED_SCORES [0:5] = '{")
    for score_index, score in enumerate(score_table[selected_number]):
        suffix = "," if score_index != 5 else ""
        lines.append(f"    32'd{score}{suffix}")
    lines.append("};")
    lines.append("")
    lines.append("localparam logic [31:0] REF_ALT_SELECTED_SCORES [0:5] = '{")
    for score_index, score in enumerate(alternate_scores):
        suffix = "," if score_index != 5 else ""
        lines.append(f"    32'd{score}{suffix}")
    lines.append("};")
    lines.append("")
    for name, data in (
        ("REF_T1_WORDS", t1),
        ("REF_T2_WORDS", t2),
        ("REF_R1_WORDS", r1),
        ("REF_T0_WORDS", t0),
        ("REF_R2_WORDS", r2),
    ):
        lines.extend(format_word_array(name, words_from_bytes(data, WORDS)))
        lines.append("")
    for number, scores in enumerate(score_table):
        lines.append(
            f"// candidate {number}: self={scores[:3]} cross={scores[3:]} weak={int(is_weak(scores))}"
        )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="ascii")
    print(
        "TRIKE-2 KeyGen fixture PASS "
        f"candidates={candidate_count} selected={selected_number} scores={score_table[selected_number]}"
    )


def analyze(kat_path: Path, trials: int) -> None:
    record = first_record(kat_path.read_text(encoding="utf-8-sig"))
    kat_seed = first_hex_field(record, "Seed")
    source = Sm3Drng(kat_seed)
    weak_count = 0
    max_run = 0
    run = 0
    maxima = [0] * 6
    for _ in range(trials):
        key_seed = source.generate(M_BYTES)
        candidates, _ = candidate_stream(key_seed, 1)
        scores = weak_scores(candidates[0], R_BITS)
        maxima = [max(left, right) for left, right in zip(maxima, scores)]
        weak = is_weak(scores)
        weak_count += int(weak)
        run = run + 1 if weak else 0
        max_run = max(max_run, run)
    print(
        f"TRIKE-2 weak-key analysis trials={trials} weak={weak_count} "
        f"rate={weak_count/trials:.8f} max_run={max_run} maxima={tuple(maxima)}"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--kat", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--candidate-count", type=int, default=4)
    parser.add_argument("--analyze", type=int, default=0, metavar="TRIALS")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.analyze:
        analyze(args.kat, args.analyze)
    if args.output is not None:
        generate_fixture(args.kat, args.output, args.candidate_count)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
