#!/usr/bin/env python3
"""Generate static first-column QC lane tables from bike_pkg.H_BASE."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def extract_r_values(text: str) -> list[int]:
    values = [int(value) for value in re.findall(r"parameter\s+int\s+R\s*=\s*(\d+)\s*;", text)]
    if len(values) != 2:
        raise ValueError("expected exactly two R parameter values in bike_pkg")
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


def first_column_tables(banks: list[list[int]], r_value: int) -> tuple[list[list[int]], list[list[list[tuple[int, int] | None]]]]:
    lane_count_table: list[list[int]] = []
    lane_entry_table: list[list[list[tuple[int, int] | None]]] = []

    for bank_support in banks:
        lane_counts = [0, 0]
        lane_entries: list[list[tuple[int, int] | None]] = [
            [None for _ in range(len(bank_support))],
            [None for _ in range(len(bank_support))],
        ]
        for edge_slot, row_value in enumerate(bank_support):
            lane_idx = row_value & 1
            row_local = row_value >> 1
            slot_idx = lane_counts[lane_idx]
            lane_entries[lane_idx][slot_idx] = (edge_slot, row_local)
            lane_counts[lane_idx] += 1
        lane_count_table.append(lane_counts)
        lane_entry_table.append(lane_entries)

    return lane_count_table, lane_entry_table


def render_lane_counts(lane_counts: list[list[int]]) -> str:
    lines = ["  localparam logic [GROUP_COUNT_W-1:0] QC_FIRST_COL_GROUP_COUNT [0:N0-1][0:L-1] = '{"] 
    for bank_idx, counts in enumerate(lane_counts):
        suffix = "," if bank_idx != len(lane_counts) - 1 else ""
        lines.append(
            "    '{"
            + ", ".join(f"GROUP_COUNT_W'({count})" for count in counts)
            + "}"
            + suffix
        )
    lines.append("  };")
    return "\n".join(lines)


def render_lane_entries(lane_entries: list[list[list[tuple[int, int] | None]]]) -> str:
    lines = ["  localparam logic [I_ENTRY_W-1:0] QC_FIRST_COL_GROUP_ENTRY [0:N0-1][0:L-1][0:W-1] = '{"] 
    for bank_idx, bank_entries in enumerate(lane_entries):
        bank_suffix = "," if bank_idx != len(lane_entries) - 1 else ""
        lines.append("    '{")
        for lane_idx, lane_slots in enumerate(bank_entries):
            lane_suffix = "," if lane_idx != len(bank_entries) - 1 else ""
            slot_exprs: list[str] = []
            for item in lane_slots:
                if item is None:
                    slot_exprs.append("'0")
                else:
                    edge_slot, row_local = item
                    slot_exprs.append(f"{{ONE_IDX_W'({edge_slot}), ROW_IDX_W'({row_local})}}")
            lines.append("      '{" + ", ".join(slot_exprs) + "}" + lane_suffix)
        lines.append("    }" + bank_suffix)
    lines.append("  };")
    return "\n".join(lines)


def render_branch(r_value: int, banks: list[list[int]]) -> str:
    lane_counts, lane_entries = first_column_tables(banks, r_value)
    return "\n".join([render_lane_counts(lane_counts), render_lane_entries(lane_entries)])


def generate_include(input_path: Path, output_path: Path) -> None:
    source_text = input_path.read_text(encoding="utf-8")
    r_values = extract_r_values(source_text)
    h_base_values = extract_h_base_values(source_text)
    output_text = "\n".join(
        [
            "// Auto-generated by scripts/gen_qc_first_columns.py.",
            "// Source: rtl/bike_pkg.sv H_BASE first-column supports.",
            "`ifdef BIKE_L1_PARAMS",
            render_branch(r_values[0], h_base_values[0]),
            "`else",
            render_branch(r_values[1], h_base_values[1]),
            "`endif",
            "",
        ]
    )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(output_text, encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="rtl/bike_pkg.sv", help="Source bike_pkg.sv path")
    parser.add_argument(
        "--output",
        default="rtl/generated/qc_first_columns.svh",
        help="Generated include output path",
    )
    args = parser.parse_args()
    generate_include(Path(args.input), Path(args.output))


if __name__ == "__main__":
    main()
