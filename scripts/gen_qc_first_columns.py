#!/usr/bin/env python3
"""Generate RAM-I initialization hex files from bike_pkg.H_BASE."""

from __future__ import annotations

import argparse
import math
import re
from pathlib import Path


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


def first_column_tables(banks: list[list[int]]) -> tuple[list[list[int]], list[list[list[tuple[int, int] | None]]]]:
    lane_count_table: list[list[int]] = []
    lane_entry_table: list[list[list[tuple[int, int] | None]]] = []

    for bank_support in banks:
        lane_counts = [0, 0]
        lane_entries: list[list[tuple[int, int] | None]] = [
            [None for _ in range(len(bank_support))],
            [None for _ in range(len(bank_support))],
        ]
        for one_idx, row_value in enumerate(bank_support):
            lane_idx = row_value & 1
            row_local = row_value >> 1
            slot_idx = lane_counts[lane_idx]
            lane_entries[lane_idx][slot_idx] = (one_idx, row_local)
            lane_counts[lane_idx] += 1
        lane_count_table.append(lane_counts)
        lane_entry_table.append(lane_entries)

    return lane_count_table, lane_entry_table


def cl2(v: int) -> int:
    """SystemVerilog $clog2 equivalent."""
    if v <= 1:
        return 1
    return (v - 1).bit_length()


def packed_entry(one_idx: int, row_local: int, row_idx_w: int) -> int:
    """Pack {one_idx, row_local} into an integer matching RTL I_ENTRY format."""
    return (one_idx << row_idx_w) | row_local


def write_hex_file(path: Path, values: list[int], width: int) -> None:
    """Write a hex file with one value per line."""
    lines = [f"{v:x}" for v in values]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def generate_hex_files(banks: list[list[int]], r_value: int, w_value: int, tag: str, output_dir: Path) -> None:
    row_idx_w = cl2(r_value)

    lane_counts, lane_entries = first_column_tables(banks)

    # One set of files per lane (row group)
    lane_names = ["ram_i0", "ram_i1"]

    for lane_idx in range(2):
        entries: list[int] = []
        counts: list[int] = []
        for hblk in range(len(banks)):
            counts.append(lane_counts[hblk][lane_idx])
            for entry_idx in range(w_value):
                item = lane_entries[hblk][lane_idx][entry_idx]
                if item is None:
                    entries.append(0)
                else:
                    one_idx, row_local = item
                    entries.append(packed_entry(one_idx, row_local, row_idx_w))

        write_hex_file(output_dir / f"{lane_names[lane_idx]}_entries_{tag}.hex", entries, 0)
        write_hex_file(output_dir / f"{lane_names[lane_idx]}_counts_{tag}.hex", counts, 0)


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
