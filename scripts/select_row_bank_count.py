#!/usr/bin/env python3
"""Select a speed-safe RAM-M row-bank count for script-owned QC data."""

from __future__ import annotations

import argparse
from pathlib import Path

from gen_qc_first_columns import extract_param_values
from gen_qc_first_columns import select_r_value
from gen_qc_first_columns import select_w_value
from qc_matrix_data import DEFAULT_SUPPORTS
from ram_i_hex import select_row_bank_count


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="rtl/bike_pkg.sv")
    parser.add_argument("--parallel-l", type=int, required=True)
    parser.add_argument("--tag", choices=sorted(DEFAULT_SUPPORTS), default="l1")
    args = parser.parse_args()

    source_text = Path(args.input).read_text(encoding="utf-8")
    supports = DEFAULT_SUPPORTS[args.tag]
    r_value = select_r_value(extract_param_values(source_text, "R"), supports)
    w_value = select_w_value(extract_param_values(source_text, "W"), supports)
    target_depth = max((w_value + args.parallel_l - 1) // args.parallel_l, 3)
    row_bank_count = select_row_bank_count(supports, r_value, args.parallel_l, target_depth)
    print(row_bank_count)


if __name__ == "__main__":
    main()
