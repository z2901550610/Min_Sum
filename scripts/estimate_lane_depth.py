#!/usr/bin/env python3
"""Compute lane-depth overflow probabilities for random QC-MDPC H columns."""

from __future__ import annotations

import argparse
import math
from math import ceil, comb


def is_power_of_two(value: int) -> bool:
    return value > 0 and (value & (value - 1)) == 0


def lane_bucket_sizes(r_value: int, lane_count: int) -> list[int]:
    sizes: list[int] = []
    for lane_idx in range(lane_count):
        if lane_idx >= r_value:
            sizes.append(0)
        else:
            sizes.append((r_value - 1 - lane_idx) // lane_count + 1)
    return sizes


def fit_count_one_matrix(bucket_sizes: list[int], weight: int, lane_depth: int) -> int:
    coeff = [0 for _ in range(weight + 1)]
    coeff[0] = 1
    for bucket_size in bucket_sizes:
        next_coeff = [0 for _ in range(weight + 1)]
        max_take = min(bucket_size, lane_depth, weight)
        choices = [comb(bucket_size, take) for take in range(max_take + 1)]
        for used, used_count in enumerate(coeff):
            if used_count == 0:
                continue
            remaining = weight - used
            for take in range(min(max_take, remaining) + 1):
                next_coeff[used + take] += used_count * choices[take]
        coeff = next_coeff
    return coeff[weight]


def h_overflow_from_one(one_overflow: float, matrix_count: int) -> float:
    if one_overflow <= 0.0:
        return 0.0
    if one_overflow >= 1.0:
        return 1.0
    return -math.expm1(matrix_count * math.log1p(-one_overflow))


def fixed_column_probability(
    fit_count: int,
    total_count: int,
    matrix_count: int,
) -> tuple[float, float, float, float]:
    fit_one = fit_count / total_count
    overflow_one = 1.0 - fit_one
    overflow_h = h_overflow_from_one(overflow_one, matrix_count)
    fit_h = 1.0 - overflow_h
    return fit_one, overflow_one, fit_h, overflow_h


def log_comb(total: int, take: int) -> float:
    if take < 0 or take > total:
        return float("-inf")
    return (
        math.lgamma(total + 1)
        - math.lgamma(take + 1)
        - math.lgamma(total - take + 1)
    )


def hypergeom_tail(population: int, marked: int, draws: int, threshold: int) -> float:
    if threshold <= 0:
        return 1.0
    if threshold > draws or threshold > marked:
        return 0.0

    low = max(threshold, draws - (population - marked))
    high = min(marked, draws)
    if low > high:
        return 0.0

    denom = log_comb(population, draws)
    terms = [
        log_comb(marked, hits) + log_comb(population - marked, draws - hits) - denom
        for hits in range(low, high + 1)
    ]
    scale = max(terms)
    return math.exp(scale) * sum(math.exp(term - scale) for term in terms)


def all_shift_scan_probability(
    fixed_overflow_one: float,
    r_value: int,
    lane_count: int,
    weight: int,
    lane_depth: int,
    matrix_count: int,
) -> tuple[float, float, float, float, float, float]:
    if r_value % lane_count == 0:
        overflow_h = h_overflow_from_one(fixed_overflow_one, matrix_count)
        return (
            fixed_overflow_one,
            fixed_overflow_one,
            fixed_overflow_one,
            overflow_h,
            overflow_h,
            overflow_h,
        )

    window_len = ceil(r_value / lane_count)
    start_tail = hypergeom_tail(
        population=r_value - 1,
        marked=window_len - 1,
        draws=weight - 1,
        threshold=lane_depth,
    )
    expected_bad_starts = weight * start_tail
    overflow_one_upper = min(1.0, expected_bad_starts)
    overflow_one_est = -math.expm1(-expected_bad_starts)

    overflow_one_lower = fixed_overflow_one
    overflow_one_est = min(max(overflow_one_est, overflow_one_lower), overflow_one_upper)
    overflow_one_upper = max(overflow_one_upper, overflow_one_lower)

    overflow_h_lower = h_overflow_from_one(overflow_one_lower, matrix_count)
    overflow_h_est = h_overflow_from_one(overflow_one_est, matrix_count)
    overflow_h_upper = h_overflow_from_one(overflow_one_upper, matrix_count)
    return (
        overflow_one_lower,
        overflow_one_est,
        overflow_one_upper,
        overflow_h_lower,
        overflow_h_est,
        overflow_h_upper,
    )


def fmt_pct(value: float) -> str:
    return f"{100.0 * value:.8f}"


def parse_targets(text: str) -> list[float]:
    targets: list[float] = []
    for item in text.split(","):
        item = item.strip()
        if item:
            targets.append(float(item) / 100.0)
    return targets


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lanes", "-L", type=int, required=True, help="Parallel lane count")
    parser.add_argument("--matrices", "-n", type=int, required=True, help="Number of circulant matrices")
    parser.add_argument("--r", type=int, required=True, help="Circulant row/column size")
    parser.add_argument("--weight", "-v", type=int, required=True, help="Column weight per circulant")
    parser.add_argument("--error-weight", "-t", type=int, default=None, help="Recorded for context only")
    parser.add_argument("--depth-min", type=int, default=None, help="Smallest lane depth in the table")
    parser.add_argument("--depth-max", type=int, default=None, help="Largest lane depth in the table")
    parser.add_argument("--depth-step", type=int, default=1, help="Lane depth table increment")
    parser.add_argument(
        "--shift-mode",
        choices=("all", "fixed"),
        default="all",
        help="Use all cyclic shifts or only one fixed column",
    )
    parser.add_argument(
        "--targets",
        default="10,1,0.1",
        help="Comma-separated target H-overflow percentages to summarize",
    )
    parser.add_argument("--csv", action="store_true", help="Emit the depth table as CSV")
    return parser.parse_args()


def validate_args(args: argparse.Namespace) -> None:
    if args.lanes <= 0:
        raise ValueError("--lanes must be positive")
    if not is_power_of_two(args.lanes):
        raise ValueError("--lanes must be a power of two for low-bit row grouping")
    if args.matrices <= 0:
        raise ValueError("--matrices must be positive")
    if args.r <= 0:
        raise ValueError("--r must be positive")
    if args.weight <= 0 or args.weight > args.r:
        raise ValueError("--weight must be between 1 and r")
    if args.depth_step <= 0:
        raise ValueError("--depth-step must be positive")
    if (
        args.shift_mode == "all"
        and args.r % args.lanes != 0
        and math.gcd(args.r, args.lanes) != 1
    ):
        raise ValueError(
            "--shift-mode all supports r divisible by lanes exactly, or gcd(r, lanes)=1 "
            "for the scan-statistic estimate"
        )


def main() -> int:
    args = parse_args()
    validate_args(args)

    buckets = lane_bucket_sizes(args.r, args.lanes)
    total_count = comb(args.r, args.weight)
    depth_min = args.depth_min if args.depth_min is not None else ceil(args.weight / args.lanes)
    depth_max = args.depth_max if args.depth_max is not None else args.weight
    targets = parse_targets(args.targets)

    rows: list[tuple[int, float, float, float, float, float, float, float, float, float]] = []
    for lane_depth in range(depth_min, depth_max + 1, args.depth_step):
        fit_count = fit_count_one_matrix(buckets, args.weight, lane_depth)
        fit_one, fixed_overflow_one, _fit_h, fixed_overflow_h = fixed_column_probability(
            fit_count,
            total_count,
            args.matrices,
        )
        (
            all_overflow_one_lower,
            all_overflow_one_est,
            all_overflow_one_upper,
            all_overflow_h_lower,
            all_overflow_h_est,
            all_overflow_h_upper,
        ) = all_shift_scan_probability(
            fixed_overflow_one,
            args.r,
            args.lanes,
            args.weight,
            lane_depth,
            args.matrices,
        )
        rows.append(
            (
                lane_depth,
                fit_one,
                fixed_overflow_one,
                fixed_overflow_h,
                all_overflow_one_lower,
                all_overflow_one_est,
                all_overflow_one_upper,
                all_overflow_h_lower,
                all_overflow_h_est,
                all_overflow_h_upper,
            )
        )

    if args.csv:
        if args.shift_mode == "fixed":
            print("lane_depth,fit_one_pct,fixed_overflow_one_pct,fit_h_pct,fixed_overflow_h_pct")
        else:
            print(
                "lane_depth,fit_one_pct,fixed_overflow_h_pct,"
                "all_shift_lower_h_pct,all_shift_est_h_pct,all_shift_upper_h_pct"
            )
    else:
        print(
            "params "
            f"matrices={args.matrices} r={args.r} weight={args.weight} "
            f"lanes={args.lanes} shift_mode={args.shift_mode}"
        )
        if args.error_weight is not None:
            print(f"error_weight={args.error_weight} (does not affect lane occupancy)")
        print(f"lane_bucket_sizes={buckets}")
        if args.shift_mode == "fixed":
            print(
                "note=fixed-column exact probability; when r is divisible by lanes, "
                "the same value also covers all cyclic shifts."
            )
        elif args.r % args.lanes == 0:
            print("note=all-shift exact probability equals the fixed-column exact probability.")
        else:
            print(
                "note=all-shift scan-statistic model: lower is the exact fixed-column "
                "probability, estimate uses the selected-start Poisson approximation, "
                "upper is the selected-start union bound."
            )
            print(f"scan_window_len={ceil(args.r / args.lanes)}")
        for target in targets:
            chosen_depth = None
            chosen_overflow = None
            chosen_upper = None
            for row in rows:
                lane_depth = row[0]
                overflow_h = row[3] if args.shift_mode == "fixed" else row[8]
                if overflow_h <= target:
                    chosen_depth = lane_depth
                    chosen_overflow = overflow_h
                    chosen_upper = row[9] if args.shift_mode == "all" else overflow_h
                    break
            if chosen_depth is None:
                label = "target_h_overflow" if args.shift_mode == "fixed" else "target_h_overflow_est"
                print(f"{label}<={100.0 * target:g}% lane_depth=not_found")
            else:
                if args.shift_mode == "fixed":
                    print(
                        f"target_h_overflow<={100.0 * target:g}% "
                        f"lane_depth={chosen_depth} observed_h_overflow_pct={fmt_pct(chosen_overflow)}"
                    )
                else:
                    print(
                        f"target_h_overflow_est<={100.0 * target:g}% "
                        f"lane_depth={chosen_depth} est_h_overflow_pct={fmt_pct(chosen_overflow)} "
                        f"upper_h_overflow_pct={fmt_pct(chosen_upper)}"
                    )
        print()
        if args.shift_mode == "fixed":
            print("lane_depth fit_one_pct fixed_overflow_one_pct fit_h_pct fixed_overflow_h_pct")
        else:
            print(
                "lane_depth fit_one_pct fixed_overflow_h_pct "
                "all_shift_lower_h_pct all_shift_est_h_pct all_shift_upper_h_pct"
            )

    for row in rows:
        (
            lane_depth,
            fit_one,
            fixed_overflow_one,
            fixed_overflow_h,
            _all_overflow_one_lower,
            _all_overflow_one_est,
            _all_overflow_one_upper,
            all_overflow_h_lower,
            all_overflow_h_est,
            all_overflow_h_upper,
        ) = row
        if args.csv:
            if args.shift_mode == "fixed":
                print(
                    f"{lane_depth},{fmt_pct(fit_one)},{fmt_pct(fixed_overflow_one)},"
                    f"{fmt_pct(1.0 - fixed_overflow_h)},{fmt_pct(fixed_overflow_h)}"
                )
            else:
                print(
                    f"{lane_depth},{fmt_pct(fit_one)},{fmt_pct(fixed_overflow_h)},"
                    f"{fmt_pct(all_overflow_h_lower)},{fmt_pct(all_overflow_h_est)},"
                    f"{fmt_pct(all_overflow_h_upper)}"
                )
        else:
            if args.shift_mode == "fixed":
                print(
                    f"{lane_depth:10d} {fmt_pct(fit_one):>11s} "
                    f"{fmt_pct(fixed_overflow_one):>22s} "
                    f"{fmt_pct(1.0 - fixed_overflow_h):>9s} "
                    f"{fmt_pct(fixed_overflow_h):>20s}"
                )
            else:
                print(
                    f"{lane_depth:10d} {fmt_pct(fit_one):>11s} "
                    f"{fmt_pct(fixed_overflow_h):>20s} "
                    f"{fmt_pct(all_overflow_h_lower):>22s} "
                    f"{fmt_pct(all_overflow_h_est):>19s} "
                    f"{fmt_pct(all_overflow_h_upper):>21s}"
                )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
