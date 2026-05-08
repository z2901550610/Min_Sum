#!/usr/bin/env python3
"""Generate RAM-I initialization hex files from bike_pkg.H_BASE."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from ram_i_hex import generate_hex_files


def extract_r_values(text: str) -> list[int]:
    values = [int(value) for value in re.findall(r"parameter\s+int\s+R\s*=\s*(\d+)\s*;", text)]
    if len(values) != 2:
        raise ValueError("expected exactly two R parameter values in bike_pkg")
    return values


def extract_w_values(text: str) -> list[int]:
    values = [int(value) for value in re.findall(r"parameter\s+int\s+W\s*=\s*(\d+)\s*;", text)]
    if len(values) < 2:
        raise ValueError("expected at least two W parameter values in bike_pkg")
    return values


def extract_h_base_literal(text: str, start: int) -> str:
    eq_idx = text.find("=", start)
    brace_idx = text.find("{", eq_idx)
    if eq_idx < 0 or brace_idx < 0:
        raise ValueError("malformed H_BASE declaration")

    depth = 0
    end_idx = -1
    for idx in range(brace_idx, len(text)):
        char = text[idx]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                end_idx = idx
                break
    if end_idx < 0:
        raise ValueError("unterminated H_BASE literal")
    return text[brace_idx:end_idx + 1]


def tokenize_literal(literal: str) -> list[str]:
    tokens: list[str] = []
    idx = 0
    while idx < len(literal):
        char = literal[idx]
        if char.isspace() or char == "," or char == "'":
            idx += 1
            continue
        if char in "{}":
            tokens.append(char)
            idx += 1
            continue
        if char.isdigit():
            end = idx + 1
            while end < len(literal) and literal[end].isdigit():
                end += 1
            tokens.append(literal[idx:end])
            idx = end
            continue
        raise ValueError(f"unexpected character {char!r} in H_BASE literal")
    return tokens


def parse_list(tokens: list[str], pos: int = 0) -> tuple[object, int]:
    if tokens[pos] != "{":
        raise ValueError("expected '{' while parsing H_BASE literal")
    pos += 1
    values: list[object] = []
    while pos < len(tokens) and tokens[pos] != "}":
        token = tokens[pos]
        if token == "{":
            value, pos = parse_list(tokens, pos)
            values.append(value)
        else:
            values.append(int(token))
            pos += 1
    if pos >= len(tokens) or tokens[pos] != "}":
        raise ValueError("unterminated list in H_BASE literal")
    return values, pos + 1


def parse_h_base_literal(literal: str) -> list[list[int]]:
    parsed, end_pos = parse_list(tokenize_literal(literal))
    if end_pos < 0:
        raise ValueError("failed to parse H_BASE literal")
    if not isinstance(parsed, list) or len(parsed) != 1:
        raise ValueError("expected H_NUM=1 outer dimension in H_BASE literal")
    banks = parsed[0]
    if not isinstance(banks, list):
        raise ValueError("expected bank list in H_BASE literal")
    return banks


def extract_h_base_values(text: str) -> list[list[list[int]]]:
    marker = "localparam int unsigned H_BASE"
    positions: list[int] = []
    search_from = 0
    while True:
        pos = text.find(marker, search_from)
        if pos < 0:
            break
        positions.append(pos)
        search_from = pos + len(marker)
    if len(positions) != 2:
        raise ValueError("expected exactly two H_BASE declarations in bike_pkg")
    return [parse_h_base_literal(extract_h_base_literal(text, pos)) for pos in positions]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="rtl/bike_pkg.sv", help="Source bike_pkg.sv path")
    parser.add_argument(
        "--output-dir",
        default="rtl/generated",
        help="Output directory for hex files",
    )
    args = parser.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output_dir)

    source_text = input_path.read_text(encoding="utf-8")
    r_values = extract_r_values(source_text)
    w_values = extract_w_values(source_text)
    h_base_values = extract_h_base_values(source_text)

    # Branch 0: BIKE_L1_PARAMS (first H_BASE, first R, first W)
    generate_hex_files(h_base_values[0], r_values[0], w_values[0], "l1", output_dir)

    # Branch 1: default test params (second H_BASE, second R, second W)
    generate_hex_files(h_base_values[1], r_values[1], w_values[1], "test", output_dir)

    print(f"Generated hex files in {output_dir}")


if __name__ == "__main__":
    main()
