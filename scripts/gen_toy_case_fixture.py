#!/usr/bin/env python3
"""Generate the deterministic toy decoder fixture include."""

from __future__ import annotations

import argparse
from pathlib import Path

from qc_matrix_data import DEFAULT_SUPPORTS
from run_bike_random import bit_vector_hex, calc_syndrome, sv_array


def parse_positions(value: str) -> list[int]:
    if not value:
        return []
    return [int(item, 0) for item in value.split(",")]


def emit_fixture(path: Path, *, error_positions: list[int]) -> None:
    r_value = 8
    w_value = 3
    c_val = 2
    alpha_shift_0 = 1
    alpha_shift_1 = 3
    supports = DEFAULT_SUPPORTS["test"]
    n_value = len(supports) * r_value
    error_bits = [0 for _ in range(n_value)]
    for pos in error_positions:
        if pos < 0 or pos >= n_value:
            raise ValueError(f"error position {pos} is outside 0..{n_value - 1}")
        error_bits[pos] = 1
    syndrome = calc_syndrome(supports, error_bits, r_value, w_value)

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        f"""`ifndef BIKE_TOY_CASE_SVH
`define BIKE_TOY_CASE_SVH

localparam int TOY_CASE_C_VAL = {c_val};
localparam int TOY_CASE_ALPHA_SHIFT_0 = {alpha_shift_0};
localparam int TOY_CASE_ALPHA_SHIFT_1 = {alpha_shift_1};
localparam logic [R-1:0] TOY_CASE_SYNDROME = {bit_vector_hex(syndrome, r_value)};
localparam logic [N-1:0] TOY_CASE_ERROR = {bit_vector_hex(error_bits, n_value)};
localparam int unsigned TOY_CASE_SUPPORTS [0:N0-1][0:W-1] = '{{
  {sv_array(supports[0])},
  {sv_array(supports[1])}
}};

`endif
""",
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", default="tb/generated/bike_toy_case.svh")
    parser.add_argument("--error-positions", default="14")
    args = parser.parse_args()

    emit_fixture(Path(args.output), error_positions=parse_positions(args.error_positions))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
