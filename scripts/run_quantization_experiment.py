#!/usr/bin/env python3
"""Run quantized min-sum parameter experiments."""

from __future__ import annotations

import argparse
import csv
import itertools
import os
import subprocess
import tempfile
from collections import defaultdict
from pathlib import Path


PROFILE_TARGETS = {
    "trike128": 201,
    "trike160": 263,
    "trike256": 429,
    "trike384": 659,
    "trike512": 877,
    "bike128": 134,
    "bike192": 199,
    "bike256": 264,
}

MODE_PRESETS = {
    "smoke": {"coarse_trials": 2, "target_trials": 20, "stress_trials": 20},
    "quick": {"coarse_trials": 20, "target_trials": 1000, "stress_trials": 500},
    "full": {"coarse_trials": 100, "target_trials": 10000, "stress_trials": 5000},
}

DEFAULT_CONFIRM_CANDIDATES = [
    (3, 2, 3, 4),
    (3, 3, 3, 4),
    (4, 5, 3, 4),
    (4, 6, 3, 4),
    (4, 7, 3, 4),
    (5, 5, 3, 4),
    (5, 13, 3, 4),
    (5, 15, 3, 4),
]

RESULT_FIELDS = [
    "profile",
    "msg_bits",
    "c_val",
    "alpha_shift_0",
    "alpha_shift_1",
    "alpha",
    "errors",
    "trials",
    "syndrome_success",
    "exact",
    "mean_residual_weight",
    "mean_decision_weight",
    "wall_seconds",
]


def parse_int_list(text: str) -> list[int]:
    values = []
    for item in text.split(","):
        value = int(item.strip())
        if value not in values:
            values.append(value)
    if not values:
        raise argparse.ArgumentTypeError("list must contain at least one integer")
    return values


def parse_candidate(text: str) -> tuple[int, int, int, int]:
    parts = text.split(":")
    if len(parts) != 4:
        raise argparse.ArgumentTypeError("candidate must use bits:C:shift0:shift1")
    try:
        msg_bits, c_val, shift_0, shift_1 = (int(part) for part in parts)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("candidate fields must be integers") from exc
    if msg_bits < 2:
        raise argparse.ArgumentTypeError("bits must be at least 2")
    magnitude_max = (1 << (msg_bits - 1)) - 1
    if c_val < 1 or c_val > magnitude_max:
        raise argparse.ArgumentTypeError(f"C must be in 1..{magnitude_max}")
    if shift_0 < 1 or shift_1 < 1 or shift_0 > 6 or shift_1 > 6:
        raise argparse.ArgumentTypeError("alpha shifts must be in 1..6")
    if shift_0 > shift_1:
        shift_0, shift_1 = shift_1, shift_0
    return (msg_bits, c_val, shift_0, shift_1)


def add_common_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--model", default="build/model/min_sum_model")
    parser.add_argument("--profile", choices=sorted(PROFILE_TARGETS), default="trike128")
    parser.add_argument("--seed", type=int, default=1)
    parser.add_argument("--threads", type=int, default=0)


def add_grid_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--msg-bits", type=parse_int_list, default=[3, 4, 5])
    parser.add_argument("--shift-min", type=int, default=1)
    parser.add_argument("--shift-max", type=int, default=6)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run quantized min-sum experiments.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    sweep = subparsers.add_parser("sweep", help="enumerate the uniform quantization grid")
    add_common_options(sweep)
    add_grid_options(sweep)
    sweep.add_argument("--errors", type=int, default=None)
    sweep.add_argument("--trials", type=int, default=100)
    sweep.add_argument("--output", default="build/model/quantization_sweep.csv")

    optimum = subparsers.add_parser("optimum", help="rank a complete uniform grid")
    add_common_options(optimum)
    add_grid_options(optimum)
    optimum.add_argument("--trials", type=int, default=10000)
    optimum.add_argument("--top", type=int, default=10)
    optimum.add_argument("--out-dir", default=None)

    campaign = subparsers.add_parser("campaign", help="coarse search and validate candidates")
    add_common_options(campaign)
    campaign.add_argument("--mode", choices=sorted(MODE_PRESETS), default="quick")
    campaign.add_argument("--out-dir", default=None)
    campaign.add_argument("--top-per-width", type=int, default=3)

    confirm = subparsers.add_parser("confirm", help="validate selected nearby candidates")
    add_common_options(confirm)
    confirm.add_argument("--mode", choices=sorted(MODE_PRESETS), default="quick")
    confirm.add_argument("--out-dir", default=None)
    confirm.add_argument("--candidate", action="append", type=parse_candidate, default=[])
    confirm.add_argument("--stress-errors", type=parse_int_list, default=None)
    confirm.add_argument("--target-trials", type=int, default=None)
    confirm.add_argument("--stress-trials", type=int, default=None)
    return parser.parse_args()


def load_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def ensure_model(path: Path) -> None:
    if not path.is_file():
        raise SystemExit(f"model executable not found: {path}; run make model-min-sum")
    if not os.access(path, os.X_OK):
        raise SystemExit(f"model is not executable: {path}; run chmod +x {path} or rebuild it")


def validate_grid_args(args: argparse.Namespace) -> None:
    if args.shift_min < 1 or args.shift_max > 6 or args.shift_min > args.shift_max:
        raise SystemExit("shift range must satisfy 1 <= shift-min <= shift-max <= 6")
    for msg_bits in args.msg_bits:
        if msg_bits < 2 or msg_bits > 16:
            raise SystemExit("each message width must be in 2..16")


def candidate_key(row: dict[str, object]) -> tuple[float, ...]:
    alpha = float(row["alpha"])
    return (
        -int(row["exact"]),
        -int(row["syndrome_success"]),
        float(row["mean_residual_weight"]),
        abs(alpha - 0.1875),
        -int(row["c_val"]),
        int(row["alpha_shift_0"]),
        int(row["alpha_shift_1"]),
    )


def run_configuration(
    model: Path,
    profile: str,
    errors: int,
    trials: int,
    threads: int,
    seed: int,
    candidate: tuple[int, int, int, int],
) -> dict[str, object]:
    msg_bits, c_val, shift_0, shift_1 = candidate
    with tempfile.TemporaryDirectory(prefix="min-sum-quant-") as temp_dir:
        trial_csv = Path(temp_dir) / "trials.csv"
        command = [
            str(model),
            "--profile",
            profile,
            "--errors",
            str(errors),
            "--msg-bits",
            str(msg_bits),
            "--c-val",
            str(c_val),
            "--alpha-shift-0",
            str(shift_0),
            "--alpha-shift-1",
            str(shift_1),
            "--seed",
            str(seed),
            "--trials",
            str(trials),
            "--threads",
            str(threads),
            "--csv",
            str(trial_csv),
        ]
        try:
            completed = subprocess.run(
                command,
                check=True,
                text=True,
                stdout=subprocess.PIPE,
            )
        except OSError as exc:
            raise SystemExit(
                f"failed to execute model: {model}\n"
                f"system error: {exc}\n"
                "Rebuild the model on this machine with `make clean model-min-sum`."
            ) from exc
        rows = load_csv(trial_csv)

    summary = completed.stdout.strip().splitlines()[-1]
    wall_seconds = float(
        next(token.split("=", 1)[1] for token in summary.split() if token.startswith("wall_seconds="))
    )
    return {
        "profile": profile,
        "msg_bits": msg_bits,
        "c_val": c_val,
        "alpha_shift_0": shift_0,
        "alpha_shift_1": shift_1,
        "alpha": (2.0**-shift_0) + (2.0**-shift_1),
        "errors": errors,
        "trials": trials,
        "syndrome_success": sum(int(row["residual_weight"]) == 0 for row in rows),
        "exact": sum(int(row["exact"]) for row in rows),
        "mean_residual_weight": sum(int(row["residual_weight"]) for row in rows) / len(rows),
        "mean_decision_weight": sum(int(row["decision_weight"]) for row in rows) / len(rows),
        "wall_seconds": wall_seconds,
    }


def write_results(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=RESULT_FIELDS)
        writer.writeheader()
        writer.writerows(rows)


def run_sweep(
    *,
    model: Path,
    profile: str,
    errors: int,
    msg_bits_values: list[int],
    shift_min: int,
    shift_max: int,
    trials: int,
    threads: int,
    seed: int,
    output: Path,
) -> list[dict[str, object]]:
    output.parent.mkdir(parents=True, exist_ok=True)
    shifts = range(shift_min, shift_max + 1)
    candidates = []
    for msg_bits in msg_bits_values:
        magnitude_max = (1 << (msg_bits - 1)) - 1
        for c_val, (shift_0, shift_1) in itertools.product(
            range(1, magnitude_max + 1), itertools.combinations_with_replacement(shifts, 2)
        ):
            candidates.append((msg_bits, c_val, shift_0, shift_1))

    results = []
    for idx, candidate in enumerate(candidates, start=1):
        print(
            f"[{idx}/{len(candidates)}] bits={candidate[0]} C={candidate[1]} "
            f"shifts=({candidate[2]},{candidate[3]}) errors={errors} trials={trials}",
            flush=True,
        )
        results.append(
            run_configuration(model, profile, errors, trials, threads, seed, candidate)
        )
        write_results(output, results)
    return results


def group_by_width(rows: list[dict[str, object]]) -> dict[int, list[dict[str, object]]]:
    grouped: dict[int, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        grouped[int(row["msg_bits"])].append(row)
    return grouped


def select_candidates(
    rows: list[dict[str, object]], top_per_width: int
) -> list[tuple[int, int, int, int]]:
    selected = []
    for msg_bits, width_rows in sorted(group_by_width(rows).items()):
        ranked = sorted(width_rows, key=candidate_key)
        width_candidates = [
            (
                msg_bits,
                int(row["c_val"]),
                int(row["alpha_shift_0"]),
                int(row["alpha_shift_1"]),
            )
            for row in ranked[:top_per_width]
        ]
        magnitude_max = (1 << (msg_bits - 1)) - 1
        width_candidates.append((msg_bits, magnitude_max, 3, 4))
        if msg_bits == 5:
            width_candidates.append((5, 5, 3, 4))
        for candidate in width_candidates:
            if candidate not in selected:
                selected.append(candidate)
    return selected


def rank_validated_candidates(
    rows: list[dict[str, object]], target_weight: int
) -> dict[int, list[tuple[tuple[float, ...], tuple[int, int, int, int]]]]:
    by_candidate: dict[tuple[int, int, int, int], dict[int, dict[str, object]]] = defaultdict(dict)
    for row in rows:
        candidate = (
            int(row["msg_bits"]),
            int(row["c_val"]),
            int(row["alpha_shift_0"]),
            int(row["alpha_shift_1"]),
        )
        by_candidate[candidate][int(row["errors"])] = row

    ranked_by_width: dict[int, list[tuple[tuple[float, ...], tuple[int, int, int, int]]]] = {}
    for candidate, records in by_candidate.items():
        stress_weights = sorted(records, reverse=True)
        target = records[target_weight]
        exact_rates = [
            int(records[weight]["exact"]) / int(records[weight]["trials"])
            for weight in stress_weights
        ]
        residuals = [
            float(records[weight]["mean_residual_weight"]) for weight in stress_weights
        ]
        score = (
            int(target["exact"]) / int(target["trials"]),
            *exact_rates,
            *(-value for value in residuals),
            candidate[1],
        )
        ranked_by_width.setdefault(candidate[0], []).append((score, candidate))

    for msg_bits in ranked_by_width:
        ranked_by_width[msg_bits].sort(reverse=True)
    return ranked_by_width


def write_optimum_summary(
    path: Path,
    rows: list[dict[str, object]],
    profile: str,
    target_weight: int,
    trials: int,
    seed: int,
    top: int,
) -> None:
    grouped = group_by_width(rows)
    lines = [
        f"# {profile} exhaustive quantization optimum",
        "",
        f"- Target error weight: `{target_weight}`",
        f"- Trials per configuration: `{trials}`",
        f"- Seed base: `{seed}`",
        "- Search grid: `C = 1 .. 2^(bits-1)-1`, `shift_0 <= shift_1`, `shift = 1 .. 6`",
        "",
        "## Best candidate per message width",
        "",
        "| Message bits | C | Alpha shifts | Alpha | Exact | Syndrome success | Mean residual |",
        "| ---: | ---: | --- | ---: | ---: | ---: | ---: |",
    ]
    for msg_bits in sorted(grouped):
        ranked = sorted(grouped[msg_bits], key=candidate_key)
        best = ranked[0]
        lines.append(
            f"| {msg_bits} | {best['c_val']} | "
            f"({best['alpha_shift_0']}, {best['alpha_shift_1']}) | "
            f"{float(best['alpha']):.6f} | "
            f"{best['exact']}/{best['trials']} | "
            f"{best['syndrome_success']}/{best['trials']} | "
            f"{float(best['mean_residual_weight']):.6f} |"
        )

    lines.extend(
        [
            "",
            f"## Top {top} candidates per message width",
            "",
            "| Message bits | Rank | C | Alpha shifts | Alpha | Exact | Syndrome success | Mean residual | Mean decision |",
            "| ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: |",
        ]
    )
    for msg_bits in sorted(grouped):
        ranked = sorted(grouped[msg_bits], key=candidate_key)
        for rank_idx, row in enumerate(ranked[:top], start=1):
            lines.append(
                f"| {msg_bits} | {rank_idx} | {row['c_val']} | "
                f"({row['alpha_shift_0']}, {row['alpha_shift_1']}) | "
                f"{float(row['alpha']):.6f} | "
                f"{row['exact']}/{row['trials']} | "
                f"{row['syndrome_success']}/{row['trials']} | "
                f"{float(row['mean_residual_weight']):.6f} | "
                f"{float(row['mean_decision_weight']):.6f} |"
            )

    lines.extend(
        [
            "",
            "The ranking is exhaustive for the listed uniform-quantization grid and finite seed range.",
            "Use the DFR Monte Carlo flow for failure-rate estimation at larger trial budgets.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def write_validation_summary(
    path: Path,
    title: str,
    profile: str,
    mode: str,
    target_weight: int,
    target_trials: int,
    stress_trials: int,
    rows: list[dict[str, object]],
) -> None:
    error_weights = sorted({int(row["errors"]) for row in rows})
    ranked = rank_validated_candidates(rows, target_weight)
    lookup = {
        (
            int(row["msg_bits"]),
            int(row["c_val"]),
            int(row["alpha_shift_0"]),
            int(row["alpha_shift_1"]),
            int(row["errors"]),
        ): row
        for row in rows
    }
    lines = [
        f"# {profile} {title}",
        "",
        f"- Mode: `{mode}`",
        f"- Target error weight: `{target_weight}`",
        f"- Target trials: `{target_trials}`",
        f"- Stress trials per point: `{stress_trials}`",
        "",
        "## Ranking by message width",
        "",
        "| Message bits | Rank | C | Alpha shifts | Alpha |",
        "| ---: | ---: | ---: | --- | ---: |",
    ]
    for msg_bits in sorted(ranked):
        for rank_idx, (_, candidate) in enumerate(ranked[msg_bits], start=1):
            _, c_val, shift_0, shift_1 = candidate
            alpha = (2.0**-shift_0) + (2.0**-shift_1)
            lines.append(f"| {msg_bits} | {rank_idx} | {c_val} | ({shift_0}, {shift_1}) | {alpha:.6f} |")

    lines.extend(
        [
            "",
            "## Candidate measurements",
            "",
            "| Bits | C | Alpha shifts | Alpha | Errors | Exact | Syndrome success | Mean residual | Mean decision |",
            "| ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |",
        ]
    )
    for msg_bits in sorted(ranked):
        for _, candidate in ranked[msg_bits]:
            _, c_val, shift_0, shift_1 = candidate
            alpha = (2.0**-shift_0) + (2.0**-shift_1)
            for errors in error_weights:
                row = lookup[(*candidate, errors)]
                lines.append(
                    f"| {msg_bits} | {c_val} | ({shift_0}, {shift_1}) | "
                    f"{alpha:.6f} | {errors} | "
                    f"{row['exact']}/{row['trials']} | "
                    f"{row['syndrome_success']}/{row['trials']} | "
                    f"{float(row['mean_residual_weight']):.6f} | "
                    f"{float(row['mean_decision_weight']):.6f} |"
                )

    lines.extend(
        [
            "",
            "Stress points above the profile target weight are parameter-selection experiments.",
            "DFR estimation uses the Monte Carlo framework with larger trial budgets.",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8")


def run_sweep_command(args: argparse.Namespace) -> int:
    model = Path(args.model).resolve()
    ensure_model(model)
    validate_grid_args(args)
    errors = args.errors if args.errors is not None else PROFILE_TARGETS[args.profile]
    run_sweep(
        model=model,
        profile=args.profile,
        errors=errors,
        msg_bits_values=args.msg_bits,
        shift_min=args.shift_min,
        shift_max=args.shift_max,
        trials=args.trials,
        threads=args.threads,
        seed=args.seed,
        output=Path(args.output),
    )
    print(f"wrote {args.output}", flush=True)
    return 0


def run_optimum_command(args: argparse.Namespace) -> int:
    model = Path(args.model).resolve()
    ensure_model(model)
    validate_grid_args(args)
    if args.trials < 1 or args.top < 1:
        raise SystemExit("trial count and top count must be positive")
    out_dir = (
        Path(args.out_dir)
        if args.out_dir
        else Path("build/model/optimum") / f"{args.profile}_{args.trials}"
    )
    out_dir.mkdir(parents=True, exist_ok=True)
    sweep_csv = out_dir / "exhaustive_sweep.csv"
    summary_md = out_dir / "summary.md"
    rows = run_sweep(
        model=model,
        profile=args.profile,
        errors=PROFILE_TARGETS[args.profile],
        msg_bits_values=args.msg_bits,
        shift_min=args.shift_min,
        shift_max=args.shift_max,
        trials=args.trials,
        threads=args.threads,
        seed=args.seed,
        output=sweep_csv,
    )
    write_optimum_summary(
        summary_md,
        rows,
        args.profile,
        PROFILE_TARGETS[args.profile],
        args.trials,
        args.seed,
        args.top,
    )
    print(f"summary: {summary_md}", flush=True)
    print(f"exhaustive results: {sweep_csv}", flush=True)
    return 0


def run_campaign_command(args: argparse.Namespace) -> int:
    model = Path(args.model).resolve()
    ensure_model(model)
    if args.top_per_width < 1:
        raise SystemExit("--top-per-width must be positive")
    preset = MODE_PRESETS[args.mode]
    target_weight = PROFILE_TARGETS[args.profile]
    out_dir = (
        Path(args.out_dir)
        if args.out_dir
        else Path("build/model/campaign") / f"{args.profile}_{args.mode}"
    )
    out_dir.mkdir(parents=True, exist_ok=True)

    coarse_csv = out_dir / "coarse_sweep.csv"
    results_csv = out_dir / "candidate_results.csv"
    summary_md = out_dir / "summary.md"
    print(
        f"[1/3] coarse sweep: profile={args.profile} mode={args.mode} "
        f"trials={preset['coarse_trials']} threads={args.threads}",
        flush=True,
    )
    coarse_rows = run_sweep(
        model=model,
        profile=args.profile,
        errors=target_weight,
        msg_bits_values=[3, 4, 5],
        shift_min=1,
        shift_max=6,
        trials=preset["coarse_trials"],
        threads=args.threads,
        seed=args.seed,
        output=coarse_csv,
    )
    candidates = select_candidates(coarse_rows, args.top_per_width)
    stress_weights = [target_weight + 11, target_weight + 21, target_weight + 31]

    results = []
    total_runs = len(candidates) * (1 + len(stress_weights))
    run_idx = 0
    print(f"[2/3] validating {len(candidates)} candidates", flush=True)
    for candidate in candidates:
        for errors in [target_weight, *stress_weights]:
            run_idx += 1
            trials = (
                preset["target_trials"]
                if errors == target_weight
                else preset["stress_trials"]
            )
            print(
                f"  [{run_idx}/{total_runs}] bits={candidate[0]} C={candidate[1]} "
                f"shifts=({candidate[2]},{candidate[3]}) errors={errors} trials={trials}",
                flush=True,
            )
            results.append(
                run_configuration(
                    model, args.profile, errors, trials, args.threads, args.seed, candidate
                )
            )
            write_results(results_csv, results)

    write_validation_summary(
        summary_md,
        "quantization campaign",
        args.profile,
        args.mode,
        target_weight,
        preset["target_trials"],
        preset["stress_trials"],
        results,
    )
    print("[3/3] campaign complete", flush=True)
    print(f"summary: {summary_md}", flush=True)
    print(f"coarse results: {coarse_csv}", flush=True)
    print(f"candidate results: {results_csv}", flush=True)
    return 0


def run_confirm_command(args: argparse.Namespace) -> int:
    model = Path(args.model).resolve()
    ensure_model(model)
    preset = MODE_PRESETS[args.mode]
    target_weight = PROFILE_TARGETS[args.profile]
    target_trials = args.target_trials if args.target_trials is not None else preset["target_trials"]
    stress_trials = args.stress_trials if args.stress_trials is not None else preset["stress_trials"]
    if target_trials < 1 or stress_trials < 1:
        raise SystemExit("trial counts must be positive")
    stress_weights = (
        args.stress_errors
        if args.stress_errors is not None
        else [target_weight + 11, target_weight + 21, target_weight + 31]
    )
    candidates = args.candidate if args.candidate else DEFAULT_CONFIRM_CANDIDATES
    unique_candidates = []
    for candidate in candidates:
        if candidate not in unique_candidates:
            unique_candidates.append(candidate)

    out_dir = (
        Path(args.out_dir)
        if args.out_dir
        else Path("build/model/confirm") / f"{args.profile}_{args.mode}"
    )
    out_dir.mkdir(parents=True, exist_ok=True)
    results_csv = out_dir / "candidate_results.csv"
    summary_md = out_dir / "summary.md"

    print(
        f"confirming {len(unique_candidates)} candidates: profile={args.profile} "
        f"mode={args.mode} threads={args.threads}",
        flush=True,
    )
    results = []
    total_runs = len(unique_candidates) * (1 + len(stress_weights))
    run_idx = 0
    for candidate in unique_candidates:
        for errors in [target_weight, *stress_weights]:
            run_idx += 1
            trials = target_trials if errors == target_weight else stress_trials
            print(
                f"[{run_idx}/{total_runs}] bits={candidate[0]} C={candidate[1]} "
                f"shifts=({candidate[2]},{candidate[3]}) errors={errors} trials={trials}",
                flush=True,
            )
            results.append(
                run_configuration(
                    model, args.profile, errors, trials, args.threads, args.seed, candidate
                )
            )
            write_results(results_csv, results)

    write_validation_summary(
        summary_md,
        "selected quantization candidate confirmation",
        args.profile,
        args.mode,
        target_weight,
        target_trials,
        stress_trials,
        results,
    )
    print(f"summary: {summary_md}", flush=True)
    print(f"candidate results: {results_csv}", flush=True)
    return 0


def main() -> int:
    args = parse_args()
    if args.command == "sweep":
        return run_sweep_command(args)
    if args.command == "optimum":
        return run_optimum_command(args)
    if args.command == "campaign":
        return run_campaign_command(args)
    if args.command == "confirm":
        return run_confirm_command(args)
    raise SystemExit(f"unknown command: {args.command}")


if __name__ == "__main__":
    raise SystemExit(main())
