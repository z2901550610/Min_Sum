#!/usr/bin/env python3
"""Generate one deterministic SM3-semantics TRIKE Min-Sum KEM case."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re
import subprocess

from run_bike_random import PARAM_SETS
from trike_fixture_utils import (
    Sm3Drng,
    cyclic_multiply,
    h123_vectors,
    is_weak,
    pseudohash,
    sample_indices,
    serialize_key_pair,
    support_blocks,
    weak_scores,
)


M_BYTES = 32
CANDIDATE_COUNT = 16


@dataclass(frozen=True)
class Profile:
    name: str
    profile_id: int
    r_bits: int
    secret_weight: int
    error_weight: int
    iterations: int
    msg_bits: int
    c_val: int
    alpha_shift_0: int
    alpha_shift_1: int
    self_threshold: int
    cross_threshold: int


PROFILE_METADATA = {
    "trike160": {"profile_id": 0, "self_threshold": 46, "cross_threshold": 83},
    "trike256": {"profile_id": 1, "self_threshold": 105, "cross_threshold": 172},
    "trike384": {"profile_id": 2, "self_threshold": 235, "cross_threshold": 405},
    "trike512": {"profile_id": 3, "self_threshold": 433, "cross_threshold": 737},
}


def load_profile(name: str) -> Profile:
    decoder = PARAM_SETS[name]
    metadata = PROFILE_METADATA[name]
    return Profile(
        name=name,
        profile_id=metadata["profile_id"],
        r_bits=decoder["r"],
        secret_weight=decoder["w"],
        error_weight=decoder["error_count"],
        iterations=decoder["i_max"],
        msg_bits=decoder["msg_bits"],
        c_val=decoder["c_val"],
        alpha_shift_0=decoder["alpha_shift_0"],
        alpha_shift_1=decoder["alpha_shift_1"],
        self_threshold=metadata["self_threshold"],
        cross_threshold=metadata["cross_threshold"],
    )


def select_secret_support(
    key_seed: bytes, profile: Profile
) -> tuple[list[list[int]], int, tuple[int, ...]]:
    drng = Sm3Drng(key_seed)
    selected = None
    selected_number = 0
    selected_scores = (0, 0, 0, 0, 0, 0)
    for candidate_number in range(CANDIDATE_COUNT):
        blocks = [
            sample_indices(drng, profile.r_bits, profile.secret_weight),
            sample_indices(drng, profile.r_bits, profile.secret_weight),
            sample_indices(drng, profile.r_bits, profile.secret_weight),
        ]
        scores = weak_scores(blocks, profile.r_bits)
        weak = is_weak(scores, profile.self_threshold, profile.cross_threshold)
        if selected is None and not weak:
            selected = blocks
            selected_number = candidate_number
            selected_scores = scores
    if selected is None:
        raise ValueError("fixed candidate budget produced no acceptable secret support")
    return selected, selected_number, selected_scores


def padded_error_bytes(blocks: tuple[int, int, int], r_bits: int) -> bytes:
    r_bytes = (r_bits + 7) // 8
    padded_r_bytes = ((r_bits + 511) // 512) * 64
    return b"".join(
        value.to_bytes(r_bytes, "little") + bytes(padded_r_bytes - r_bytes)
        for value in blocks
    )


def write_decoder_fixture(
    path: Path,
    sorted_support: list[list[int]],
    error_positions: list[int],
    syndrome_positions: list[int],
    profile: Profile,
) -> None:
    lines = [
        "MIN_SUM_FIXTURE_V1",
        "seed 1",
        "n0 3",
        f"r {profile.r_bits}",
        f"w {profile.secret_weight}",
        f"error_count {len(error_positions)}",
        f"iterations {profile.iterations}",
        f"msg_bits {profile.msg_bits}",
        f"c_val {profile.c_val}",
        f"alpha_shift_0 {profile.alpha_shift_0}",
        f"alpha_shift_1 {profile.alpha_shift_1}",
    ]
    for block, values in enumerate(sorted_support):
        lines.append(f"h {block} " + " ".join(str(value) for value in values))
    lines.append("error_positions " + " ".join(str(value) for value in error_positions))
    lines.append(f"syndrome_weight {len(syndrome_positions)}")
    lines.append("syndrome_positions " + " ".join(str(value) for value in syndrome_positions))
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def read_decision(path: Path) -> list[int]:
    lines = path.read_text(encoding="ascii").splitlines()
    if not lines or lines[0] != "MIN_SUM_DECISION_V1":
        raise ValueError("unexpected Min-Sum decision format")
    return [int(value) for value in lines[1:] if value]


def run_decoder(
    model_path: Path,
    work_dir: Path,
    label: str,
    decoder_support: list[list[int]],
    expected_error: list[int],
    syndrome_value: int,
    profile: Profile,
) -> tuple[list[int], int, str]:
    syndrome_positions = [bit for bit in range(profile.r_bits) if (syndrome_value >> bit) & 1]
    fixture_path = work_dir / f"decoder_fixture_{label}.txt"
    decision_path = work_dir / f"decoder_decision_{label}.txt"
    write_decoder_fixture(
        fixture_path, decoder_support, expected_error, syndrome_positions, profile
    )
    model = subprocess.run(
        [str(model_path), "--fixture-in", str(fixture_path), "--decision-out", str(decision_path)],
        check=True,
        capture_output=True,
        text=True,
    )
    decoded_positions = read_decision(decision_path)
    match = re.search(r"decision_weight=(\d+) residual_weight=(\d+) exact=(yes|no)", model.stdout)
    if match is None:
        raise ValueError("could not parse Min-Sum model result")
    return decoded_positions, int(match.group(2)), model.stdout.strip()


def evaluate_decapsulation(
    ciphertext: bytes,
    c2: bytes,
    decoded_positions: list[int],
    residual_weight: int,
    r2: bytes,
    sigma2: bytes,
    profile: Profile,
) -> dict[str, object]:
    decoded_blocks = support_blocks(decoded_positions, profile.r_bits)
    decoded_l = pseudohash(padded_error_bytes(decoded_blocks, profile.r_bits))
    message_prime = bytes(left ^ right for left, right in zip(c2, decoded_l[:M_BYTES]))
    calculated_error = sample_indices(
        Sm3Drng(message_prime + r2), 3 * profile.r_bits, profile.error_weight
    )
    error_equal = sorted(decoded_positions) == sorted(calculated_error)
    valid = residual_weight == 0 and error_equal
    selected_message = message_prime if valid else sigma2
    return {
        "reencryption_error_equal": error_equal,
        "ciphertext_valid": valid,
        "shared_secret": pseudohash(selected_message + ciphertext)[:M_BYTES],
    }


def write_decaps_message_fixture(
    path: Path,
    c2: bytes,
    decoded_positions: list[int],
    expected_message: bytes,
    t0: bytes,
    u: bytes,
    v: bytes,
    r2: bytes,
    sigma2: bytes,
    secret_key: bytes,
    ciphertext: bytes,
    raw_support: list[list[int]],
    decoder_support: list[list[int]],
    syndrome_positions: list[int],
    tampered_cases: dict[str, dict[str, object]],
    profile: Profile,
) -> None:
    error_bytes = padded_error_bytes(
        support_blocks(decoded_positions, profile.r_bits), profile.r_bits
    )
    l_digest = pseudohash(error_bytes)
    tampered_ciphertext = bytearray(ciphertext)
    tampered_ciphertext[2 * ((profile.r_bits + 7) // 8)] ^= 1
    tampered_ciphertext = bytes(tampered_ciphertext)
    tampered_c2 = tampered_ciphertext[-M_BYTES:]
    tampered_u = bytearray(u)
    tampered_u[0] ^= 1
    tampered_u = bytes(tampered_u)
    tampered_v = bytearray(v)
    tampered_v[0] ^= 1
    tampered_v = bytes(tampered_v)
    u_tampered_ciphertext = bytes.fromhex(str(tampered_cases["u_bit0"]["ciphertext"]))
    v_tampered_ciphertext = bytes.fromhex(str(tampered_cases["v_bit0"]["ciphertext"]))
    u_tampered_shared_secret = bytes.fromhex(str(tampered_cases["u_bit0"]["shared_secret"]))
    v_tampered_shared_secret = bytes.fromhex(str(tampered_cases["v_bit0"]["shared_secret"]))
    row_width = (profile.r_bits - 1).bit_length()
    raw_support_packed = 0
    for position, value in enumerate(value for block in raw_support for value in block):
        raw_support_packed |= value << (position * row_width)
    support_packed = 0
    for position, value in enumerate(value for block in decoder_support for value in block):
        support_packed |= value << (position * row_width)
    word_w = 64
    words = (profile.r_bits + word_w - 1) // word_w
    word_bytes = word_w // 8

    def pack_words(data: bytes) -> int:
        return int.from_bytes(data + bytes(words * word_bytes - len(data)), "little")

    decision_packed = sum(1 << value for value in decoded_positions)
    syndrome_packed = sum(1 << value for value in syndrome_positions)
    lines = [
        "// Generated by scripts/gen_trike_minsum_kem_case.py",
        f"localparam logic [1:0] REF_PARAM_LEVEL = 2'd{profile.profile_id};",
        f'localparam string REF_PROFILE_NAME = "{profile.name}";',
        f"localparam int REF_R_BITS = {profile.r_bits};",
        "localparam int REF_BLOCKS = 3;",
        f"localparam int REF_M_BYTES = {M_BYTES};",
        f"localparam int REF_ERROR_BYTES = {len(error_bytes)};",
        f"localparam int REF_SECRET_WEIGHT = {profile.secret_weight};",
        f"localparam int REF_ROW_WIDTH = {row_width};",
        f"localparam int REF_WORD_W = {word_w};",
        f"localparam int REF_WORDS = {words};",
        f"localparam logic [{3 * profile.secret_weight * row_width - 1}:0] REF_H_SUPPORT_RAW = "
        f"{3 * profile.secret_weight * row_width}'h{raw_support_packed:x};",
        f"localparam logic [{3 * profile.secret_weight * row_width - 1}:0] REF_H_SUPPORT = "
        f"{3 * profile.secret_weight * row_width}'h{support_packed:x};",
        f"localparam logic [{word_w * words - 1}:0] REF_T0_WORDS = "
        f"{word_w * words}'h{pack_words(t0):x};",
        f"localparam logic [{word_w * words - 1}:0] REF_U_WORDS = "
        f"{word_w * words}'h{pack_words(u):x};",
        f"localparam logic [{word_w * words - 1}:0] REF_U_TAMPERED_WORDS = "
        f"{word_w * words}'h{pack_words(tampered_u):x};",
        f"localparam logic [{word_w * words - 1}:0] REF_V_WORDS = "
        f"{word_w * words}'h{pack_words(v):x};",
        f"localparam logic [{word_w * words - 1}:0] REF_V_TAMPERED_WORDS = "
        f"{word_w * words}'h{pack_words(tampered_v):x};",
        f"localparam logic [{3 * profile.r_bits - 1}:0] REF_DECISION = "
        f"{3 * profile.r_bits}'h{decision_packed:x};",
        f"localparam logic [{profile.r_bits - 1}:0] REF_SYNDROME = "
        f"{profile.r_bits}'h{syndrome_packed:x};",
        f"localparam logic [{8 * len(error_bytes) - 1}:0] REF_ERROR_DATA = "
        f"{8 * len(error_bytes)}'h{int.from_bytes(error_bytes, 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_C2 = "
        f"{8 * M_BYTES}'h{int.from_bytes(c2, 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_TAMPERED_C2 = "
        f"{8 * M_BYTES}'h{int.from_bytes(tampered_c2, 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_MESSAGE = "
        f"{8 * M_BYTES}'h{int.from_bytes(expected_message, 'little'):x};",
        f"localparam logic [{8 * len(r2) - 1}:0] REF_R2 = "
        f"{8 * len(r2)}'h{int.from_bytes(r2, 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_SIGMA2 = "
        f"{8 * M_BYTES}'h{int.from_bytes(sigma2, 'little'):x};",
        f"localparam int REF_SECRET_KEY_BYTES = {len(secret_key)};",
        f"localparam logic [{8 * len(secret_key) - 1}:0] REF_SECRET_KEY = "
        f"{8 * len(secret_key)}'h{int.from_bytes(secret_key, 'little'):x};",
        f"localparam int REF_CIPHERTEXT_BYTES = {len(ciphertext)};",
        f"localparam logic [{8 * len(ciphertext) - 1}:0] REF_CIPHERTEXT = "
        f"{8 * len(ciphertext)}'h{int.from_bytes(ciphertext, 'little'):x};",
        f"localparam logic [{8 * len(ciphertext) - 1}:0] REF_TAMPERED_CIPHERTEXT = "
        f"{8 * len(ciphertext)}'h{int.from_bytes(tampered_ciphertext, 'little'):x};",
        f"localparam logic [{8 * len(ciphertext) - 1}:0] REF_U_TAMPERED_CIPHERTEXT = "
        f"{8 * len(ciphertext)}'h{int.from_bytes(u_tampered_ciphertext, 'little'):x};",
        f"localparam logic [{8 * len(ciphertext) - 1}:0] REF_V_TAMPERED_CIPHERTEXT = "
        f"{8 * len(ciphertext)}'h{int.from_bytes(v_tampered_ciphertext, 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(pseudohash(expected_message + ciphertext)[:M_BYTES], 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_REJECT_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(pseudohash(sigma2 + ciphertext)[:M_BYTES], 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_TAMPERED_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(pseudohash(sigma2 + tampered_ciphertext)[:M_BYTES], 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_U_TAMPERED_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(u_tampered_shared_secret, 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_V_TAMPERED_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(v_tampered_shared_secret, 'little'):x};",
        f"localparam int REF_U_TAMPERED_RESIDUAL_WEIGHT = "
        f"{tampered_cases['u_bit0']['decoder_residual_weight']};",
        f"localparam int REF_V_TAMPERED_RESIDUAL_WEIGHT = "
        f"{tampered_cases['v_bit0']['decoder_residual_weight']};",
        f"localparam logic [511:0] REF_L_DIGEST = 512'h{l_digest.hex()};",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def write_runtime_decaps_fixture(
    path: Path,
    secret_key: bytes,
    ciphertext: bytes,
    tampered_cases: dict[str, dict[str, object]],
    shared_secret: bytes,
    profile: Profile,
) -> None:
    fixture_dir = path.parent / f"trike_decaps_runtime_minsum_{profile.name}"
    fixture_dir.mkdir(parents=True, exist_ok=True)
    inputs = {
        "valid": secret_key + ciphertext,
        "u_tampered": secret_key + bytes.fromhex(str(tampered_cases["u_bit0"]["ciphertext"])),
        "v_tampered": secret_key + bytes.fromhex(str(tampered_cases["v_bit0"]["ciphertext"])),
        "c2_tampered": secret_key + bytes.fromhex(str(tampered_cases["c2_bit0"]["ciphertext"])),
    }
    for label, data in inputs.items():
        (fixture_dir / f"{label}.hex").write_text(
            "".join(f"{byte:02x}\n" for byte in data), encoding="ascii"
        )

    relative_dir = fixture_dir.as_posix()
    lines = [
        "// Generated by scripts/gen_trike_minsum_kem_case.py",
        f"localparam logic [1:0] REF_PARAM_LEVEL = 2'd{profile.profile_id};",
        f'localparam string REF_PROFILE_NAME = "{profile.name}";',
        f"localparam int REF_R_BITS = {profile.r_bits};",
        f"localparam int REF_M_BYTES = {M_BYTES};",
        f"localparam int REF_INPUT_BYTES = {len(secret_key) + len(ciphertext)};",
        f'localparam string REF_VALID_INPUT_HEX = "{relative_dir}/valid.hex";',
        f'localparam string REF_U_TAMPERED_INPUT_HEX = "{relative_dir}/u_tampered.hex";',
        f'localparam string REF_V_TAMPERED_INPUT_HEX = "{relative_dir}/v_tampered.hex";',
        f'localparam string REF_C2_TAMPERED_INPUT_HEX = "{relative_dir}/c2_tampered.hex";',
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(shared_secret, 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_U_TAMPERED_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(bytes.fromhex(str(tampered_cases['u_bit0']['shared_secret'])), 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_V_TAMPERED_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(bytes.fromhex(str(tampered_cases['v_bit0']['shared_secret'])), 'little'):x};",
        f"localparam logic [{8 * M_BYTES - 1}:0] REF_TAMPERED_SHARED_SECRET = "
        f"{8 * M_BYTES}'h{int.from_bytes(bytes.fromhex(str(tampered_cases['c2_bit0']['shared_secret'])), 'little'):x};",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def generate_case(
    output_path: Path,
    model_path: Path,
    work_dir: Path,
    seed_number: int,
    decaps_message_svh: Path | None,
    runtime_decaps_svh: Path | None,
    profile: Profile,
) -> None:
    kat_seed = hashlib.shake_256(
        f"trike-minsum-kat-r{profile.r_bits}-seed{seed_number}".encode("ascii")
    ).digest(64)
    global_drng = Sm3Drng(kat_seed)
    key_seed = global_drng.generate(M_BYTES)
    sigma2 = global_drng.generate(M_BYTES)
    sigma = global_drng.generate(M_BYTES)
    message = global_drng.generate(M_BYTES)

    support, selected_candidate, scores = select_secret_support(key_seed, profile)
    decoder_support = [sorted(block) for block in support]
    t1, t2, r1 = h123_vectors(sigma, profile.r_bits)
    public_key, secret_key, t0, r2 = serialize_key_pair(
        support, t1, t2, r1, sigma, sigma2, profile.r_bits
    )

    error_support = sample_indices(
        Sm3Drng(message + r2), 3 * profile.r_bits, profile.error_weight
    )
    error_blocks = support_blocks(error_support, profile.r_bits)
    r1_value = int.from_bytes(r1, "little")
    r2_value = int.from_bytes(r2, "little")
    t1_value = int.from_bytes(t1, "little")
    t2_value = int.from_bytes(t2, "little")
    e0, e1, e2 = error_blocks
    u_value = e0 ^ cyclic_multiply(e1, r1_value, profile.r_bits) ^ cyclic_multiply(
        e2, r2_value, profile.r_bits
    )
    v_value = e0 ^ cyclic_multiply(e1, t1_value, profile.r_bits) ^ cyclic_multiply(
        e2, t2_value, profile.r_bits
    )
    r_bytes = (profile.r_bits + 7) // 8
    u = u_value.to_bytes(r_bytes, "little")
    v = v_value.to_bytes(r_bytes, "little")
    error_bytes = padded_error_bytes(error_blocks, profile.r_bits)
    l_digest = pseudohash(error_bytes)
    c2 = bytes(left ^ right for left, right in zip(message, l_digest[:M_BYTES]))
    ciphertext = u + v + c2
    encaps_ss = pseudohash(message + ciphertext)[:M_BYTES]

    h0_value = sum(1 << coefficient for coefficient in support[0])
    t0_value = int.from_bytes(t0, "little")
    syndrome_value = cyclic_multiply(h0_value, u_value, profile.r_bits) ^ cyclic_multiply(
        t0_value, u_value ^ v_value, profile.r_bits
    )
    work_dir.mkdir(parents=True, exist_ok=True)
    decoded_positions, residual_weight, model_output = run_decoder(
        model_path,
        work_dir,
        "valid",
        decoder_support,
        sorted(error_support),
        syndrome_value,
        profile,
    )
    decapsulation = evaluate_decapsulation(
        ciphertext, c2, decoded_positions, residual_weight, r2, sigma2, profile
    )

    tampered_cases = {}
    for label, byte_index in (("u_bit0", 0), ("v_bit0", r_bytes), ("c2_bit0", 2 * r_bytes)):
        tampered = bytearray(ciphertext)
        tampered[byte_index] ^= 1
        tampered_ciphertext = bytes(tampered)
        tampered_u = int.from_bytes(tampered_ciphertext[:r_bytes], "little")
        tampered_v = int.from_bytes(tampered_ciphertext[r_bytes : 2 * r_bytes], "little")
        tampered_c2 = tampered_ciphertext[2 * r_bytes :]
        tampered_syndrome = cyclic_multiply(
            h0_value, tampered_u, profile.r_bits
        ) ^ cyclic_multiply(
            t0_value, tampered_u ^ tampered_v, profile.r_bits
        )
        if label == "c2_bit0":
            tampered_decoded = decoded_positions
            tampered_residual = residual_weight
            tampered_model_output = model_output
            decoder_reused = True
        else:
            tampered_decoded, tampered_residual, tampered_model_output = run_decoder(
                model_path,
                work_dir,
                label,
                decoder_support,
                sorted(error_support),
                tampered_syndrome,
                profile,
            )
            decoder_reused = False
        tampered_result = evaluate_decapsulation(
            tampered_ciphertext,
            tampered_c2,
            tampered_decoded,
            tampered_residual,
            r2,
            sigma2,
            profile,
        )
        if tampered_result["ciphertext_valid"]:
            raise ValueError(f"directed {label} corruption unexpectedly passed verification")
        tampered_cases[label] = {
            "ciphertext": tampered_ciphertext.hex(),
            "syndrome_weight": tampered_syndrome.bit_count(),
            "decoder_reused": decoder_reused,
            "decoder_decision_weight": len(tampered_decoded),
            "decoder_residual_weight": tampered_residual,
            "decoder_exact_original_error": sorted(tampered_decoded) == sorted(error_support),
            "reencryption_error_equal": tampered_result["reencryption_error_equal"],
            "ciphertext_valid": tampered_result["ciphertext_valid"],
            "shared_secret": tampered_result["shared_secret"].hex(),
            "model_output": tampered_model_output,
        }

    result = {
        "format": "TRIKE_MINSUM_KAT_V1",
        "profile": {
            "name": profile.name,
            "profile_id": profile.profile_id,
            "r": profile.r_bits,
            "w": profile.secret_weight,
            "t": profile.error_weight,
            "iterations": profile.iterations,
            "msg_bits": profile.msg_bits,
            "c_val": profile.c_val,
            "alpha_shift_0": profile.alpha_shift_0,
            "alpha_shift_1": profile.alpha_shift_1,
            "self_threshold": profile.self_threshold,
            "cross_threshold": profile.cross_threshold,
        },
        "seed": kat_seed.hex(),
        "selected_candidate": selected_candidate,
        "weak_scores": list(scores),
        "support_raw": support,
        "support_decoder_sorted": decoder_support,
        "key_seed": key_seed.hex(),
        "sigma": sigma.hex(),
        "sigma2": sigma2.hex(),
        "message": message.hex(),
        "public_key": public_key.hex(),
        "secret_key": secret_key.hex(),
        "t1": t1.hex(),
        "t2": t2.hex(),
        "r1": r1.hex(),
        "t0": t0.hex(),
        "r2": r2.hex(),
        "error_positions": sorted(error_support),
        "u": u.hex(),
        "v": v.hex(),
        "c2": c2.hex(),
        "ciphertext": ciphertext.hex(),
        "syndrome_positions": [
            bit for bit in range(profile.r_bits) if (syndrome_value >> bit) & 1
        ],
        "decoded_positions": decoded_positions,
        "decoder_residual_weight": residual_weight,
        "decoder_exact_original_error": sorted(decoded_positions) == sorted(error_support),
        "reencryption_error_equal": decapsulation["reencryption_error_equal"],
        "ciphertext_valid": decapsulation["ciphertext_valid"],
        "encaps_shared_secret": encaps_ss.hex(),
        "decaps_shared_secret": decapsulation["shared_secret"].hex(),
        "tampered_cases": tampered_cases,
        "model_output": model_output,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    if decaps_message_svh is not None:
        write_decaps_message_fixture(
            decaps_message_svh,
            c2,
            decoded_positions,
            message,
            t0,
            u,
            v,
            r2,
            sigma2,
            secret_key,
            ciphertext,
            support,
            decoder_support,
            [bit for bit in range(profile.r_bits) if (syndrome_value >> bit) & 1],
            tampered_cases,
            profile,
        )
    if runtime_decaps_svh is not None:
        write_runtime_decaps_fixture(
            runtime_decaps_svh,
            secret_key,
            ciphertext,
            tampered_cases,
            encaps_ss,
            profile,
        )
    print(
        "TRIKE Min-Sum KEM case PASS "
        f"profile={profile.name} r={profile.r_bits} candidate={selected_candidate} "
        f"residual={residual_weight} "
        f"exact={result['decoder_exact_original_error']} "
        f"valid={decapsulation['ciphertext_valid']} tampered_rejected={len(tampered_cases)}"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--work-dir", type=Path, required=True)
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--profile", choices=PROFILE_METADATA, default="trike160")
    parser.add_argument("--decaps-message-svh", type=Path)
    parser.add_argument("--runtime-decaps-svh", type=Path)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    generate_case(
        args.output,
        args.model,
        args.work_dir,
        args.seed,
        args.decaps_message_svh,
        args.runtime_decaps_svh,
        load_profile(args.profile),
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
