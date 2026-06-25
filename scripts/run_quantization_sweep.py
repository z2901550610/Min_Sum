#!/usr/bin/env python3
"""Run deterministic C-model searches over message width, C, and alpha shifts."""

from __future__ import annotations

import argparse
import csv
import itertools
import subprocess
import tempfile
from pathlib import Path


def parse_int_list(text: str) -> list[int]:
    values = []
    for item in text.split(","):
        value = int(item.strip())
        if value not in values:
            values.append(value)
    if not values:
        raise argparse.ArgumentTypeError("list must contain at least one integer")
    return values


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Search uniform quantized min-sum parameters with the C model."
    )
    parser.add_argument("--model", default="build/model/min_sum_model")
    parser.add_argument(
        "--profile", choices=("toy", "bike128", "bike192", "bike256"), default="bike128"
    )
    parser.add_argument("--msg-bits", type=parse_int_list, default=[3, 4, 5])
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--trials", type=int, default=100)
    parser.add_argument("--threads", type=int, default=0)
    parser.add_argument("--shift-min", type=int, default=1)
    parser.add_argument("--shift-max", type=int, default=6)
    parser.add_argument("--output", default="build/model/quantization_sweep.csv")
    parser.add_argument("--verbose", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    model = Path(args.model)
    output = Path(args.output)

    if not model.is_file():
        raise SystemExit(f"model executable not found: {model}; run make model-min-sum")
    if args.trials < 1:
        raise SystemExit("--trials must be positive")
    if args.shift_min < 1 or args.shift_max > 6 or args.shift_min > args.shift_max:
        raise SystemExit("shift range must satisfy 1 <= shift-min <= shift-max <= 6")

    output.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "profile",
        "msg_bits",
        "c_val",
        "alpha_shift_0",
        "alpha_shift_1",
        "alpha",
        "trials",
        "syndrome_success",
        "exact",
        "mean_residual_weight",
        "mean_decision_weight",
        "wall_seconds",
    ]

    with output.open("w", newline="", encoding="utf-8") as output_file:
        writer = csv.DictWriter(output_file, fieldnames=fields)
        writer.writeheader()

        for msg_bits in args.msg_bits:
            if msg_bits < 2 or msg_bits > 16:
                raise SystemExit("each message width must be in 2..16")
            magnitude_max = (1 << (msg_bits - 1)) - 1
            shifts = range(args.shift_min, args.shift_max + 1)
            for c_val, (shift_0, shift_1) in itertools.product(
                range(1, magnitude_max + 1), itertools.combinations_with_replacement(shifts, 2)
            ):
                with tempfile.TemporaryDirectory(prefix="min-sum-sweep-") as temp_dir:
                    trial_csv = Path(temp_dir) / "trials.csv"
                    command = [
                        str(model),
                        "--profile",
                        args.profile,
                        "--msg-bits",
                        str(msg_bits),
                        "--c-val",
                        str(c_val),
                        "--alpha-shift-0",
                        str(shift_0),
                        "--alpha-shift-1",
                        str(shift_1),
                        "--seed",
                        str(args.seed),
                        "--trials",
                        str(args.trials),
                        "--threads",
                        str(args.threads),
                        "--csv",
                        str(trial_csv),
                    ]
                    completed = subprocess.run(
                        command,
                        check=True,
                        text=True,
                        stdout=subprocess.PIPE,
                    )
                    with trial_csv.open(newline="", encoding="utf-8") as trial_file:
                        rows = list(csv.DictReader(trial_file))

                successes = sum(int(row["residual_weight"]) == 0 for row in rows)
                exact = sum(int(row["exact"]) for row in rows)
                mean_residual = sum(int(row["residual_weight"]) for row in rows) / len(rows)
                mean_decision = sum(int(row["decision_weight"]) for row in rows) / len(rows)
                summary_line = completed.stdout.strip().splitlines()[-1]
                wall_token = next(
                    token for token in summary_line.split() if token.startswith("wall_seconds=")
                )
                wall_seconds = float(wall_token.split("=", 1)[1])
                writer.writerow(
                    {
                        "profile": args.profile,
                        "msg_bits": msg_bits,
                        "c_val": c_val,
                        "alpha_shift_0": shift_0,
                        "alpha_shift_1": shift_1,
                        "alpha": (2.0**-shift_0) + (2.0**-shift_1),
                        "trials": len(rows),
                        "syndrome_success": successes,
                        "exact": exact,
                        "mean_residual_weight": f"{mean_residual:.6f}",
                        "mean_decision_weight": f"{mean_decision:.6f}",
                        "wall_seconds": f"{wall_seconds:.6f}",
                    }
                )
                output_file.flush()
                if args.verbose:
                    print(
                        f"bits={msg_bits} C={c_val} shifts=({shift_0},{shift_1}) "
                        f"success={successes}/{len(rows)} exact={exact}/{len(rows)}"
                    )

    print(f"wrote {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
