#!/usr/bin/env python3
"""Generate RAM-I initialization hex files from script-owned QC matrix data."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from qc_matrix_data import DEFAULT_SUPPORTS
from ram_i_hex import generate_hex_files


def extract_param_values(text: str, name: str) -> list[int]:
    return [
        int(value)
        for value in re.findall(
            rf"(?:localparam|parameter)\s+int\s+{re.escape(name)}\s*=\s*(\d+)\s*;",
            text,
        )
    ]


def pair_values(values: list[int], default: int | None = None) -> list[int]:
    if not values:
        if default is None:
            raise ValueError("missing required parameter value")
        return [default, default]
    if len(values) == 1:
        return [values[0], values[0]]
    return values[:2]


def validate_supports(name: str, supports: list[list[int]], r_value: int, w_value: int) -> None:
    if len(supports) != 2:
        raise ValueError(f"{name} must contain two circulant-block supports")
    for block_idx, support in enumerate(supports):
        if len(support) != w_value:
            raise ValueError(f"{name}[{block_idx}] has {len(support)} entries, expected {w_value}")
        for row_idx in support:
            if row_idx < 0 or row_idx >= r_value:
                raise ValueError(f"{name}[{block_idx}] row {row_idx} is outside 0..{r_value - 1}")


def select_w_value(values: list[int], supports: list[list[int]]) -> int:
    support_width = len(supports[0])
    if support_width in values:
        return support_width
    return values[0]


def select_r_value(values: list[int], supports: list[list[int]]) -> int:
    max_row_idx = max(max(support) for support in supports)
    candidates = [value for value in values if value > max_row_idx]
    if candidates:
        return min(candidates)
    return values[0]


def is_power_of_two(value: int) -> bool:
    return value > 0 and (value & (value - 1)) == 0


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="rtl/bike_pkg.sv", help="Source bike_pkg.sv path")
    parser.add_argument(
        "--output-dir",
        default="rtl/generated",
        help="Output directory for hex files",
    )
    parser.add_argument("--parallel-l", type=int, default=None)
    args = parser.parse_args()

    input_path = Path(args.input)
    output_dir = Path(args.output_dir)

    source_text = input_path.read_text(encoding="utf-8")
    r_values = extract_param_values(source_text, "R")
    w_values = extract_param_values(source_text, "W")
    l1_r_value = select_r_value(r_values, DEFAULT_SUPPORTS["l1"])
    l1_w_value = select_w_value(w_values, DEFAULT_SUPPORTS["l1"])
    test_r_value = select_r_value(r_values, DEFAULT_SUPPORTS["test"])
    test_w_value = select_w_value(w_values, DEFAULT_SUPPORTS["test"])
    l_values = (
        [args.parallel_l, args.parallel_l]
        if args.parallel_l is not None
        else pair_values(extract_param_values(source_text, "L"), default=2)
    )
    if min(l_values) < 1:
        raise ValueError("--parallel-l must be positive")
    if not all(is_power_of_two(l_value) for l_value in l_values):
        raise ValueError("--parallel-l must be a power of two")
    lane_depth_values_raw = extract_param_values(source_text, "RAM_LANE_DEPTH")
    if lane_depth_values_raw:
        lane_depth_values = pair_values(lane_depth_values_raw)
    else:
        lane_depth_values = [
            max((l1_w_value + l_values[0] - 1) // l_values[0], 3),
            max((test_w_value + l_values[1] - 1) // l_values[1], 3),
        ]

    jobs = [
        ("l1", DEFAULT_SUPPORTS["l1"], l1_r_value, l1_w_value, l_values[0], lane_depth_values[0]),
        ("test", DEFAULT_SUPPORTS["test"], test_r_value, test_w_value, l_values[1], lane_depth_values[1]),
    ]

    for tag, supports, r_value, w_value, l_value, lane_depth in jobs:
        validate_supports(tag, supports, r_value, w_value)
        generate_hex_files(
            supports,
            r_value,
            w_value,
            tag,
            output_dir,
            group_count=l_value,
            memory_depth=lane_depth,
        )

    print(f"Generated hex files in {output_dir}")


if __name__ == "__main__":
    main()
